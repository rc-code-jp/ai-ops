#!/usr/bin/env bash
# Claude Code 用 SKILL.md の YAML フロントマターを検証するスクリプト
# 使い方: bash scripts/validate_frontmatter.sh <ファイルパス>
#
# チェック項目:
#   1. --- デリミタの存在（開始・終了）
#   2. name フィールドの形式（kebab-case、スペースなし、大文字なし）
#   3. description フィールドの存在と文字数（1024文字以内）
#   4. XML タグ（< >）の不在
#   5. frontmatter の主要 boolean 値の形式

set -uo pipefail

FILE="${1:-}"
if [[ -z "$FILE" || ! -f "$FILE" ]]; then
  echo "エラー: ファイルが指定されていないか存在しません: $FILE"
  echo "使い方: bash scripts/validate_frontmatter.sh <ファイルパス>"
  exit 1
fi

ERRORS=0
WARNINGS=0

error() { echo "  [エラー] $1"; ((ERRORS++)); }
warn()  { echo "  [警告]   $1"; ((WARNINGS++)); }
ok()    { echo "  [OK]     $1"; }

echo "=== フロントマター検証: $FILE ==="
echo ""

FIRST_LINE=$(head -1 "$FILE")
if [[ "$FIRST_LINE" != "---" ]]; then
  error "1行目に開始デリミタ '---' がありません（実際: '$FIRST_LINE'）"
else
  ok "開始デリミタ '---' あり"
fi

CLOSING_LINE=$(tail -n +2 "$FILE" | grep -n '^---$' | head -1 | cut -d: -f1 || true)
if [[ -z "$CLOSING_LINE" ]]; then
  error "閉じデリミタ '---' が見つかりません"
else
  ok "閉じデリミタ '---' あり（$(( CLOSING_LINE + 1 ))行目）"
fi

if [[ -n "$CLOSING_LINE" ]]; then
  FRONTMATTER=$(sed -n "2,$(( CLOSING_LINE ))p" "$FILE")
else
  echo ""
  echo "=== 結果: デリミタ不在のため検証を中断 ==="
  exit 1
fi

NAME=$(echo "$FRONTMATTER" | grep -E '^name:' | head -1 | sed 's/^name:[[:space:]]*//' || true)
if [[ -z "$NAME" ]]; then
  error "name フィールドがありません"
else
  if echo "$NAME" | grep -qE '[A-Z]'; then
    error "name に大文字が含まれています: '$NAME'"
  elif echo "$NAME" | grep -qE '[[:space:]]'; then
    error "name にスペースが含まれています: '$NAME'"
  elif echo "$NAME" | grep -qE '[_]'; then
    error "name にアンダースコアが含まれています: '$NAME'（kebab-case を使用してください）"
  elif ! echo "$NAME" | grep -qE '^[a-z0-9][a-z0-9-]*$'; then
    error "name が kebab-case ではありません: '$NAME'"
  else
    ok "name: '$NAME'（kebab-case）"
  fi
fi

DESC=$(echo "$FRONTMATTER" | grep -E '^description:' | head -1 | sed 's/^description:[[:space:]]*//' || true)
if [[ -z "$DESC" ]]; then
  error "description フィールドがありません"
else
  DESC_LEN=${#DESC}
  if (( DESC_LEN > 1024 )); then
    error "description が 1024 文字を超えています（${DESC_LEN}文字）"
  else
    ok "description: ${DESC_LEN}文字（1024文字以内）"
  fi
fi

if echo "$FRONTMATTER" | grep -qE '[<>]'; then
  error "フロントマターに XML タグ（< >）が含まれています"
else
  ok "XML タグなし"
fi

for field in disable-model-invocation user-invocable; do
  VALUE=$(echo "$FRONTMATTER" | grep -E "^${field}:" | head -1 | sed "s/^${field}:[[:space:]]*//" || true)
  if [[ -n "$VALUE" ]]; then
    if [[ "$VALUE" == "true" || "$VALUE" == "false" ]]; then
      ok "${field}: ${VALUE}"
    else
      error "${field} は true または false を指定してください（実際: '${VALUE}'）"
    fi
  fi
done

echo ""
echo "=== 結果: エラー ${ERRORS} 件、警告 ${WARNINGS} 件 ==="
if (( ERRORS > 0 )); then
  exit 1
else
  exit 0
fi
