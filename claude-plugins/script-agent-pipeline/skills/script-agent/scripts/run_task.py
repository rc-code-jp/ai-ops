#!/usr/bin/env python3
"""script-agent スキルの中央ディスパッチャ。

タスク名を受け取り、tasks/ 配下の同名モジュールへ処理を委譲する。
結果は共通の JSON エンベロープで stdout(または --output で指定した
ファイル)へ書き出す。LLM による判断は一切行わず、確定的なデータ取得と
機械的な前処理(件数計算・閾値フィルタなど)だけを担当する。

使い方:
    python3 run_task.py --list
    python3 run_task.py <task> [タスク固有の引数...] [--output path.json]

タスクモジュールの契約:
    tasks/<task>.py に次の 2 つを実装する。
    - add_arguments(parser: argparse.ArgumentParser) -> None
    - run(args: argparse.Namespace) -> dict
      戻り値は {"params": dict, "stats": dict, "data": list|dict} の形。
"""

import argparse
import importlib
import json
import sys
from datetime import datetime, timezone
from pathlib import Path

TASKS_DIR = Path(__file__).resolve().parent / "tasks"
ENVELOPE_VERSION = 1


def list_tasks():
    return sorted(
        p.stem for p in TASKS_DIR.glob("*.py") if not p.stem.startswith("_")
    )


def load_task(name):
    if name not in list_tasks():
        available = ", ".join(list_tasks()) or "(なし)"
        sys.exit(f"error: 未知のタスク '{name}'。利用可能: {available}")
    sys.path.insert(0, str(TASKS_DIR.parent))
    return importlib.import_module(f"tasks.{name}")


def main():
    parser = argparse.ArgumentParser(
        description="script-agent 中央ディスパッチャ",
        add_help=True,
    )
    parser.add_argument("task", nargs="?", help="実行するタスク名")
    parser.add_argument("--list", action="store_true", help="タスク一覧を表示")
    parser.add_argument("--output", help="JSON の出力先ファイルパス(省略時は stdout)")
    args, task_argv = parser.parse_known_args()

    if args.list:
        print("\n".join(list_tasks()))
        return

    if not args.task:
        parser.error("task を指定するか --list を使ってください")

    module = load_task(args.task)
    task_parser = argparse.ArgumentParser(prog=f"run_task.py {args.task}")
    module.add_arguments(task_parser)
    task_args = task_parser.parse_args(task_argv)

    started_at = datetime.now(timezone.utc)
    try:
        result = module.run(task_args)
        ok = True
        error = None
    except Exception as exc:  # タスク失敗もエンベロープとして返す
        result = {"params": vars(task_args), "stats": {}, "data": None}
        ok = False
        error = f"{type(exc).__name__}: {exc}"

    envelope = {
        "envelope_version": ENVELOPE_VERSION,
        "task": args.task,
        "generated_at": started_at.isoformat(timespec="seconds"),
        "ok": ok,
        "error": error,
        "params": result.get("params", {}),
        "stats": result.get("stats", {}),
        "data": result.get("data"),
    }

    text = json.dumps(envelope, ensure_ascii=False, indent=2)
    if args.output:
        out = Path(args.output)
        out.parent.mkdir(parents=True, exist_ok=True)
        out.write_text(text + "\n", encoding="utf-8")
        # 親 Claude が確認しやすいよう、サマリだけ stdout に出す
        summary = {
            "task": args.task,
            "ok": ok,
            "error": error,
            "stats": envelope["stats"],
            "output": str(out),
        }
        print(json.dumps(summary, ensure_ascii=False))
    else:
        print(text)

    if not ok:
        sys.exit(1)


if __name__ == "__main__":
    main()
