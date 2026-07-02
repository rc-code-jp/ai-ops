"""GitHub issue へコメントを一括投稿するタスク(フェーズ 2 用)。

コメントの宛先と本文の「判断」はサブエージェント 2 が行い、このタスクは
指定された comments ファイルの内容を機械的に投稿して結果を記録するだけを
担当する。1 件の失敗で全体を止めず、issue ごとに成否を返す。

comments ファイルの形式(サブエージェント 2 が作成):
    [
      {"number": 123, "body": "@user コメント本文..."},
      ...
    ]
"""

import json
import subprocess
from pathlib import Path


def add_arguments(parser):
    parser.add_argument(
        "--repo",
        required=True,
        help="対象リポジトリ(owner/repo 形式)",
    )
    parser.add_argument(
        "--comments-file",
        required=True,
        help="投稿するコメント一覧の JSON ファイルパス",
    )


def _post_comment(repo, number, body):
    cmd = [
        "gh", "api",
        f"repos/{repo}/issues/{number}/comments",
        "--method", "POST",
        "-f", f"body={body}",
    ]
    proc = subprocess.run(cmd, capture_output=True, text=True)
    if proc.returncode != 0:
        detail = proc.stderr.strip().splitlines()
        return None, (detail[-1] if detail else f"gh exit {proc.returncode}")
    return json.loads(proc.stdout).get("html_url"), None


def run(args):
    comments = json.loads(Path(args.comments_file).read_text(encoding="utf-8"))
    if not isinstance(comments, list):
        raise ValueError("comments ファイルはオブジェクトの配列である必要があります")

    results = []
    for i, item in enumerate(comments):
        number = item.get("number")
        body = (item.get("body") or "").strip()
        if not isinstance(number, int) or not body:
            results.append({
                "number": number,
                "ok": False,
                "comment_url": None,
                "error": f"要素 {i}: number(int) と body(非空) が必須です",
            })
            continue
        url, error = _post_comment(args.repo, number, body)
        results.append({
            "number": number,
            "ok": error is None,
            "comment_url": url,
            "error": error,
        })

    posted = sum(1 for r in results if r["ok"])
    return {
        "params": {"repo": args.repo, "comments_file": args.comments_file},
        "stats": {
            "requested": len(comments),
            "posted": posted,
            "failed": len(results) - posted,
        },
        "data": results,
    }
