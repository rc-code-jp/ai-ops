#!/usr/bin/env python3
"""いらすとや画像の検索・ダウンロード CLI（標準ライブラリのみ）。

いらすとや (https://www.irasutoya.com) は Blogger 製サイトのため、
Blogger の公開フィード API を検索エンジンとして利用する。
スクレイピング（HTML パース）は行わず、構造化された JSON のみ扱う。

使い方:
  検索（複数キーワード可・結果は JSON で標準出力へ）
    python3 irasutoya_search.py search 会議 サーバー --max 8

  ダウンロード（URL を列挙し、--dir へ保存。保存パスを1行ずつ出力）
    python3 irasutoya_search.py download URL1 URL2 --dir ./images

注意:
  - サイトへの負荷配慮のため、リクエスト間に既定 1 秒の待機を入れる
  - いらすとやの利用規約（商用は1制作物あたり素材20点まで無料）は
    呼び出し側（SKILL.md）で管理すること
"""

import argparse
import http.client
import json
import os
import re
import sys
import time
import urllib.parse
import urllib.request

FEED_URL = "https://www.irasutoya.com/feeds/posts/summary"
USER_AGENT = (
    "Mozilla/5.0 (compatible; irasutoya-docs-skill/0.1; "
    "+https://github.com/rc-code-jp/ai-ops)"
)
DEFAULT_IMAGE_SIZE = "s800"  # Blogger の画像 URL サイズ指定
REQUEST_WAIT_SEC = 1.0
MAX_RETRIES = 3


def http_get(url: str, timeout: int = 30) -> bytes:
    """チャンク読み込み + リトライ付き GET（IncompleteRead 等の一時エラー対策）。"""
    last_exc = None
    for attempt in range(MAX_RETRIES):
        if attempt > 0:
            time.sleep(REQUEST_WAIT_SEC * attempt)
        req = urllib.request.Request(url, headers={"User-Agent": USER_AGENT})
        try:
            with urllib.request.urlopen(req, timeout=timeout) as res:
                chunks = []
                while True:
                    chunk = res.read(64 * 1024)
                    if not chunk:
                        break
                    chunks.append(chunk)
                return b"".join(chunks)
        except (http.client.IncompleteRead, TimeoutError, ConnectionError, OSError) as exc:
            last_exc = exc
    raise last_exc


def to_fullsize(thumbnail_url: str, size: str = DEFAULT_IMAGE_SIZE) -> str:
    """Blogger サムネイル URL (…/s72-c/xxx.png) をフルサイズ URL に変換する。"""
    return re.sub(r"/s\d+(-c)?/", f"/{size}/", thumbnail_url)


def search_one(keyword: str, max_results: int, size: str) -> list:
    query = urllib.parse.urlencode(
        {"q": keyword, "alt": "json", "max-results": max_results}
    )
    raw = http_get(f"{FEED_URL}?{query}")
    feed = json.loads(raw).get("feed", {})
    results = []
    for entry in feed.get("entry", []):
        title = entry.get("title", {}).get("$t", "")
        thumb = entry.get("media$thumbnail", {}).get("url", "")
        page_url = next(
            (
                link.get("href", "")
                for link in entry.get("link", [])
                if link.get("rel") == "alternate"
            ),
            "",
        )
        if not thumb:
            continue
        results.append(
            {
                "title": title,
                "page_url": page_url,
                "image_url": to_fullsize(thumb, size),
            }
        )
    return results


def cmd_search(args: argparse.Namespace) -> int:
    output = {}
    for i, keyword in enumerate(args.keywords):
        if i > 0:
            time.sleep(args.wait)
        try:
            output[keyword] = search_one(keyword, args.max, args.size)
        except Exception as exc:  # noqa: BLE001 - CLI として失敗理由を返す
            output[keyword] = {"error": str(exc)}
    json.dump(output, sys.stdout, ensure_ascii=False, indent=2)
    print()
    has_hit = any(isinstance(v, list) and v for v in output.values())
    return 0 if has_hit else 2


def cmd_download(args: argparse.Namespace) -> int:
    os.makedirs(args.dir, exist_ok=True)
    status = 0
    for i, url in enumerate(args.urls):
        if i > 0:
            time.sleep(args.wait)
        name = os.path.basename(urllib.parse.urlparse(url).path)
        if not name:
            print(f"ERROR: ファイル名を特定できません: {url}", file=sys.stderr)
            status = 1
            continue
        path = os.path.join(args.dir, name)
        try:
            data = http_get(url)
        except Exception as exc:  # noqa: BLE001
            print(f"ERROR: {url}: {exc}", file=sys.stderr)
            status = 1
            continue
        with open(path, "wb") as fp:
            fp.write(data)
        print(path)
    return status


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest="command", required=True)

    p_search = sub.add_parser("search", help="キーワードでイラストを検索")
    p_search.add_argument("keywords", nargs="+", help="検索キーワード（複数可）")
    p_search.add_argument("--max", type=int, default=8, help="キーワードごとの最大件数")
    p_search.add_argument("--size", default=DEFAULT_IMAGE_SIZE, help="画像サイズ (例: s400, s800)")
    p_search.add_argument("--wait", type=float, default=REQUEST_WAIT_SEC, help="リクエスト間隔(秒)")
    p_search.set_defaults(func=cmd_search)

    p_dl = sub.add_parser("download", help="画像 URL をダウンロード")
    p_dl.add_argument("urls", nargs="+", help="画像 URL（複数可）")
    p_dl.add_argument("--dir", required=True, help="保存先ディレクトリ")
    p_dl.add_argument("--wait", type=float, default=REQUEST_WAIT_SEC, help="リクエスト間隔(秒)")
    p_dl.set_defaults(func=cmd_download)

    args = parser.parse_args()
    return args.func(args)


if __name__ == "__main__":
    sys.exit(main())
