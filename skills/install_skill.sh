#!/usr/bin/env bash

# skills/ 配下のスキルを一覧表示し、上下キーで選択してインストールする。
# ローカルのリポジトリ内からも、GitHub 上の生スクリプトからも実行できる。

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
DEFAULT_REPO_URL="https://github.com/rc-code-jp/ai-ops"
REPO_URL="${SKILLS_REPO_URL:-$DEFAULT_REPO_URL}"
SKILLS_REF="${SKILLS_REF:-main}"
SKILLS_SOURCE="${SKILLS_SOURCE:-auto}"
SELECTED_INDEX="${SKILL_INDEX:-}"
SKILLS_DIR="${REPO_ROOT}/skills"

skill_dirs=()
skill_names=()
skill_descriptions=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --index)
      if [[ -z "${2:-}" ]]; then
        echo "--index には数値を指定してください。" >&2
        exit 1
      fi
      SELECTED_INDEX="$2"
      shift 2
      ;;
    *)
      echo "不明な引数です: $1" >&2
      echo "使い方: bash skills/install_skill.sh [--index 数値]" >&2
      exit 1
      ;;
  esac
done

extract_field() {
  local file="$1"
  local key="$2"

  awk -F': ' -v target="$key" '
    BEGIN { in_frontmatter = 0 }
    /^---$/ {
      if (in_frontmatter == 0) {
        in_frontmatter = 1
        next
      }
      exit
    }
    in_frontmatter == 1 && $1 == target {
      sub(/^[^:]+: /, "", $0)
      print $0
      exit
    }
  ' "$file"
}

repo_slug() {
  local url="$1"

  url="${url#https://github.com/}"
  url="${url#http://github.com/}"
  url="${url#git@github.com:}"
  url="${url%.git}"

  printf "%s\n" "$url"
}

raw_base_url() {
  local slug="$1"
  local ref="$2"
  printf "https://raw.githubusercontent.com/%s/%s" "$slug" "$ref"
}

append_skill() {
  local skill_slug="$1"
  local skill_name="$2"
  local skill_description="$3"

  if [[ -z "$skill_name" ]]; then
    skill_name="$skill_slug"
  fi

  if [[ -z "$skill_description" ]]; then
    skill_description="説明なし"
  fi

  skill_dirs+=("$skill_slug")
  skill_names+=("$skill_name")
  skill_descriptions+=("$skill_description")
}

load_local_skills() {
  if [[ ! -d "$SKILLS_DIR" ]]; then
    return 1
  fi

  while IFS= read -r skill_dir; do
    local skill_file="${skill_dir}/SKILL.md"
    local skill_slug
    local skill_name
    local skill_description

    skill_slug="$(basename "$skill_dir")"
    skill_name="$(extract_field "$skill_file" "name")"
    skill_description="$(extract_field "$skill_file" "description")"

    append_skill "$skill_slug" "$skill_name" "$skill_description"
  done < <(find "$SKILLS_DIR" -mindepth 1 -maxdepth 1 -type d | sort)
}

load_remote_skills() {
  local slug raw_url skill_list
  slug="$(repo_slug "$REPO_URL")"
  raw_url="$(raw_base_url "$slug" "$SKILLS_REF")"

  if ! command -v curl >/dev/null 2>&1; then
    echo "リモート実行には curl が必要です。" >&2
    exit 1
  fi

  skill_list="$(curl -fsSL "${raw_url}/skills/index.txt")"

  if [[ -z "$skill_list" ]]; then
    echo "GitHub からスキル一覧を取得できませんでした: ${raw_url}/skills/index.txt" >&2
    exit 1
  fi

  while IFS= read -r skill_slug; do
    local skill_content skill_name skill_description

    [[ -z "$skill_slug" ]] && continue
    [[ "$skill_slug" =~ ^# ]] && continue

    skill_content="$(curl -fsSL "${raw_url}/skills/${skill_slug}/SKILL.md")"
    skill_name="$(printf "%s\n" "$skill_content" | awk -F': ' '
      BEGIN { in_frontmatter = 0 }
      /^---$/ {
        if (in_frontmatter == 0) {
          in_frontmatter = 1
          next
        }
        exit
      }
      in_frontmatter == 1 && $1 == "name" {
        sub(/^[^:]+: /, "", $0)
        print $0
        exit
      }
    ')"
    skill_description="$(printf "%s\n" "$skill_content" | awk -F': ' '
      BEGIN { in_frontmatter = 0 }
      /^---$/ {
        if (in_frontmatter == 0) {
          in_frontmatter = 1
          next
        }
        exit
      }
      in_frontmatter == 1 && $1 == "description" {
        sub(/^[^:]+: /, "", $0)
        print $0
        exit
      }
    ')"

    append_skill "$skill_slug" "$skill_name" "$skill_description"
  done <<< "$skill_list"
}

case "$SKILLS_SOURCE" in
  auto)
    if ! load_local_skills; then
      load_remote_skills
    fi
    ;;
  local)
    if ! load_local_skills; then
      echo "skills ディレクトリが見つかりません: $SKILLS_DIR" >&2
      exit 1
    fi
    ;;
  remote)
    load_remote_skills
    ;;
  *)
    echo "SKILLS_SOURCE は auto / local / remote のいずれかを指定してください。" >&2
    exit 1
    ;;
esac

if [[ ${#skill_dirs[@]} -eq 0 ]]; then
  echo "インストール可能なスキルが見つかりませんでした。" >&2
  exit 1
fi

render_menu() {
  local i

  for ((i = 0; i < ${#skill_dirs[@]}; i++)); do
    printf "  %d) %s\n" "$((i + 1))" "${skill_names[$i]}" >&2
    printf "     %s\n" "${skill_descriptions[$i]}" >&2
  done
}

select_skill() {
  local choice=""
  local selected_index=0

  echo "インストールするスキルを番号で選択してください。" >&2
  render_menu
  echo "" >&2

  while true; do
    printf "選択 (1-%d)> " "${#skill_dirs[@]}" >&2
    IFS= read -r choice

    if ! [[ "$choice" =~ ^[0-9]+$ ]]; then
      echo "無効な選択です。1-${#skill_dirs[@]} の番号を入力してください。" >&2
      continue
    fi

    selected_index=$((choice - 1))
    if (( selected_index >= 0 && selected_index < ${#skill_dirs[@]} )); then
      break
    fi

    echo "無効な選択です。1-${#skill_dirs[@]} の番号を入力してください。" >&2
  done

  printf "%s\n" "$selected_index"
}

if [[ -n "$SELECTED_INDEX" ]]; then
  if ! [[ "$SELECTED_INDEX" =~ ^[0-9]+$ ]]; then
    echo "選択インデックスは 0 以上の整数で指定してください。" >&2
    exit 1
  fi
  if (( SELECTED_INDEX < 0 || SELECTED_INDEX >= ${#skill_dirs[@]} )); then
    echo "選択インデックスが範囲外です: $SELECTED_INDEX" >&2
    exit 1
  fi
  selected_index="$SELECTED_INDEX"
else
  if [[ ! -t 0 ]]; then
    echo "対話モードでは TTY が必要です。非対話で使う場合は \`--index\` を指定してください。" >&2
    exit 1
  fi
  selected_index="$(select_skill)"
fi

selected_skill="${skill_dirs[$selected_index]}"
skill_url="${REPO_URL}/tree/${SKILLS_REF}/skills/${selected_skill}"

echo "選択したスキル: ${skill_names[$selected_index]}"
echo "インストール元: ${skill_url}"
echo "実行コマンド: npx skills add ${skill_url}"

echo "`npx skills add` を実行します..."
exec npx skills add "$skill_url"
