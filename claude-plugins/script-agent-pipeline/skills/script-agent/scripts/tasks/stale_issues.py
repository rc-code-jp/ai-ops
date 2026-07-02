"""GitHub の open issue を全件取得し、N 日以上更新されていないものを抽出するタスク。

gh CLI(認証済み前提)を subprocess で呼び出す。追加の pip 依存はない。
「停滞しているか・誰に確認すべきか」といった判断は行わず、判断材料
(最終更新からの経過日数、担当者、ラベル、本文冒頭など)を JSON に
まとめるところまでを担当する。
"""

import json
import subprocess
from datetime import datetime, timezone


def add_arguments(parser):
    parser.add_argument(
        "--repo",
        required=True,
        help="対象リポジトリ(owner/repo 形式)",
    )
    parser.add_argument(
        "--days",
        type=int,
        default=3,
        help="この日数以上更新されていない issue を抽出する(デフォルト: 3)",
    )
    parser.add_argument(
        "--body-chars",
        type=int,
        default=200,
        help="data に含める issue 本文の先頭文字数(デフォルト: 200)",
    )


def _fetch_open_issues(repo):
    cmd = [
        "gh", "api",
        f"repos/{repo}/issues",
        "--method", "GET",
        "-f", "state=open",
        "-f", "per_page=100",
        "--paginate",
        "--slurp",
    ]
    proc = subprocess.run(cmd, capture_output=True, text=True)
    if proc.returncode != 0:
        detail = proc.stderr.strip().splitlines()
        raise RuntimeError(
            f"gh api が失敗しました (exit {proc.returncode}): "
            + (detail[-1] if detail else "(stderr なし)")
        )
    pages = json.loads(proc.stdout)
    issues = [item for page in pages for item in page]
    # /issues エンドポイントは PR も返すため除外する
    return [i for i in issues if "pull_request" not in i]


def run(args):
    now = datetime.now(timezone.utc)
    issues = _fetch_open_issues(args.repo)

    stale = []
    for issue in issues:
        updated_at = datetime.fromisoformat(issue["updated_at"].replace("Z", "+00:00"))
        days = (now - updated_at).total_seconds() / 86400
        if days < args.days:
            continue
        body = issue.get("body") or ""
        stale.append({
            "number": issue["number"],
            "title": issue["title"],
            "url": issue["html_url"],
            "author": (issue.get("user") or {}).get("login"),
            "assignees": [a["login"] for a in issue.get("assignees", [])],
            "labels": [l["name"] for l in issue.get("labels", [])],
            "milestone": (issue.get("milestone") or {}).get("title"),
            "comments": issue.get("comments", 0),
            "created_at": issue["created_at"],
            "updated_at": issue["updated_at"],
            "days_since_update": round(days, 1),
            "body_head": body[: args.body_chars],
        })

    stale.sort(key=lambda i: i["days_since_update"], reverse=True)

    return {
        "params": {"repo": args.repo, "days": args.days},
        "stats": {
            "open_issues_total": len(issues),
            "stale_issues": len(stale),
            "threshold_days": args.days,
        },
        "data": stale,
    }
