#!/usr/bin/env bash
# SKILL.md / エージェント定義ファイルの YAML フロントマターを検証するスクリプト
# 使い方: bash scripts/validate_frontmatter.sh <ファイルパス>
#
# チェック項目:
#   1. --- デリミタの存在（開始・終了）
#   2. name フィールドの形式（kebab-case、スペースなし、大文字なし）
#   3. description フィールドの存在と文字数（1024文字以内）
#   4. XML タグ（< >）の不在
#   5. "claude" / "anthropic" プレフィックスの不在
#   6. compatibility フィールドの文字数（500文字以内、存在する場合）

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

# --- 1. デリミタチェック ---
FIRST_LINE=$(head -1 "$FILE")
if [[ "$FIRST_LINE" != "---" ]]; then
  error "1行目に開始デリミタ '---' がありません（実際: '$FIRST_LINE'）"
else
  ok "開始デリミタ '---' あり"
fi

# 閉じデリミタを探す（2行目以降で最初の ---）
CLOSING_LINE=$(tail -n +2 "$FILE" | grep -n '^---$' | head -1 | cut -d: -f1 || true)
if [[ -z "$CLOSING_LINE" ]]; then
  error "閉じデリミタ '---' が見つかりません"
else
  ok "閉じデリミタ '---' あり（$(( CLOSING_LINE + 1 ))行目）"
fi

# フロントマター部分を抽出
if [[ -n "$CLOSING_LINE" ]]; then
  FRONTMATTER=$(sed -n "2,$(( CLOSING_LINE ))p" "$FILE")
else
  echo ""
  echo "=== 結果: デリミタ不在のため検証を中断 ==="
  exit 1
fi

# --- 2. name フィールド ---
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

  # claude / anthropic プレフィックスチェック
  if echo "$NAME" | grep -qiE '^(claude|anthropic)'; then
    error "name に予約語プレフィックス 'claude' または 'anthropic' が使われています: '$NAME'"
  fi
fi

# --- 3. description フィールド ---
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

# --- 4. XML タグチェック ---
if echo "$FRONTMATTER" | grep -qE '[<>]'; then
  error "フロントマターに XML タグ（< >）が含まれています（セキュリティリスク）"
else
  ok "XML タグなし"
fi

# --- 5. compatibility 文字数チェック ---
COMPAT=$(echo "$FRONTMATTER" | grep -E '^compatibility:' | head -1 | sed 's/^compatibility:[[:space:]]*//' || true)
if [[ -n "$COMPAT" ]]; then
  COMPAT_LEN=${#COMPAT}
  if (( COMPAT_LEN > 500 )); then
    error "compatibility が 500 文字を超えています（${COMPAT_LEN}文字）"
  else
    ok "compatibility: ${COMPAT_LEN}文字（500文字以内）"
  fi
fi

# --- 結果サマリー ---
echo ""
echo "=== 結果: エラー ${ERRORS} 件、警告 ${WARNINGS} 件 ==="
if (( ERRORS > 0 )); then
  exit 1
else
  exit 0
fi
