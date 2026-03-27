#!/usr/bin/env bash

set -euo pipefail

if [ "$#" -ne 1 ]; then
  echo "使い方: $0 <SKILL.md>" >&2
  exit 1
fi

file="$1"

if [ ! -f "$file" ]; then
  echo "ファイルが見つかりません: $file" >&2
  exit 1
fi

first_line="$(sed -n '1p' "$file")"
if [ "$first_line" != "---" ]; then
  echo "先頭の YAML フロントマター開始行がありません" >&2
  exit 1
fi

if ! awk '
  BEGIN { count = 0 }
  /^---$/ { count++; if (count == 2) exit 0 }
  END { exit count >= 2 ? 0 : 1 }
' "$file"; then
  echo "YAML フロントマター終了行がありません" >&2
  exit 1
fi

if ! rg -n '^name:' "$file" >/dev/null; then
  echo "name フィールドがありません" >&2
  exit 1
fi

if ! rg -n '^description:' "$file" >/dev/null; then
  echo "description フィールドがありません" >&2
  exit 1
fi

echo "frontmatter を確認しました: $file"
