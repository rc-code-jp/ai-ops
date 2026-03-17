#!/usr/bin/env bash

# skills/ 配下のスキルを一覧表示し、上下キーで選択してインストールする。

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
SKILLS_DIR="${REPO_ROOT}/skills"
DEFAULT_REPO_URL="https://github.com/rc-code-jp/ai-ops"
REPO_URL="${SKILLS_REPO_URL:-$DEFAULT_REPO_URL}"
SKILLS_REF="${SKILLS_REF:-main}"
DRY_RUN=false
SELECTED_INDEX="${SKILL_INDEX:-}"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)
      DRY_RUN=true
      shift
      ;;
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
      echo "使い方: bash scripts/install_skill.sh [--dry-run] [--index 数値]" >&2
      exit 1
      ;;
  esac
done

if [[ ! -d "$SKILLS_DIR" ]]; then
  echo "skills ディレクトリが見つかりません: $SKILLS_DIR" >&2
  exit 1
fi

skill_dirs=()
skill_names=()
skill_descriptions=()

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

while IFS= read -r skill_dir; do
  skill_file="${skill_dir}/SKILL.md"
  skill_slug="$(basename "$skill_dir")"
  skill_name="$(extract_field "$skill_file" "name")"
  skill_description="$(extract_field "$skill_file" "description")"

  if [[ -z "$skill_name" ]]; then
    skill_name="$skill_slug"
  fi

  if [[ -z "$skill_description" ]]; then
    skill_description="説明なし"
  fi

  skill_dirs+=("$skill_slug")
  skill_names+=("$skill_name")
  skill_descriptions+=("$skill_description")
done < <(find "$SKILLS_DIR" -mindepth 1 -maxdepth 1 -type d | sort)

if [[ ${#skill_dirs[@]} -eq 0 ]]; then
  echo "インストール可能なスキルが見つかりませんでした。" >&2
  exit 1
fi

cleanup_terminal() {
  tput cnorm 2>/dev/null || true
  stty echo icanon min 1 time 0 2>/dev/null || true
}

render_menu() {
  local selected_index="$1"
  local i

  printf "\r"
  for ((i = 0; i < ${#skill_dirs[@]}; i++)); do
    if [[ "$i" -eq "$selected_index" ]]; then
      printf "> %s\n" "${skill_names[$i]}"
      printf "  %s\n" "${skill_descriptions[$i]}"
    else
      printf "  %s\n" "${skill_names[$i]}"
      printf "  %s\n" "${skill_descriptions[$i]}"
    fi
  done
}

select_skill() {
  local selected_index=0
  local key=""

  trap cleanup_terminal EXIT
  stty -echo -icanon min 1 time 0
  tput civis 2>/dev/null || true

  echo "インストールするスキルを上下キーで選択し、Enter で決定してください。"
  render_menu "$selected_index"

  while true; do
    IFS= read -rsn1 key

    if [[ "$key" == $'\x1b' ]]; then
      IFS= read -rsn2 key
      case "$key" in
        "[A")
          if (( selected_index > 0 )); then
            selected_index=$((selected_index - 1))
          fi
          printf "\033[%dA" $(( ${#skill_dirs[@]} * 2 ))
          render_menu "$selected_index"
          ;;
        "[B")
          if (( selected_index < ${#skill_dirs[@]} - 1 )); then
            selected_index=$((selected_index + 1))
          fi
          printf "\033[%dA" $(( ${#skill_dirs[@]} * 2 ))
          render_menu "$selected_index"
          ;;
      esac
      continue
    fi

    if [[ -z "$key" || "$key" == $'\n' || "$key" == $'\r' || "$key" == $'\x0a' || "$key" == $'\x0d' ]]; then
      break
    fi
  done

  cleanup_terminal
  trap - EXIT
  echo ""
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
    echo "対話モードでは TTY が必要です。非対話で使う場合は `--index` を指定してください。" >&2
    exit 1
  fi
  selected_index="$(select_skill)"
fi

selected_skill="${skill_dirs[$selected_index]}"
skill_url="${REPO_URL}/tree/${SKILLS_REF}/skills/${selected_skill}"

echo "選択したスキル: ${skill_names[$selected_index]}"
echo "インストール元: ${skill_url}"
echo "実行コマンド: npx skills add ${skill_url}"

if [[ "$DRY_RUN" == true ]]; then
  echo 'ドライランのため、`npx skills add` は実行していません。'
  exit 0
fi

echo "`npx skills add` を実行します..."
exec npx skills add "$skill_url"
