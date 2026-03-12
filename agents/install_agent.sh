#!/bin/bash
# Sub Agents インストールスクリプト
# 使い方: bash install.sh <ai-type> <agent-name>
# ai-type: codex | claude | opencode

set -e

BASE_URL="https://raw.githubusercontent.com/rc-code-jp/ai-ops/main/agents"

# インストールモード選択
echo "インストールモードを選択してください:"
echo "  1) Local  (現在のディレクトリの .<ai-type>/agents/)"
echo "  2) Global (ホームディレクトリの .<ai-type>/agents/)"
while true; do
  printf "選択 (1-2)> "
  read -r choice
  case "$choice" in
    1) BASE_PATH="."; break ;;
    2) BASE_PATH="$HOME"; break ;;
    *) echo "無効な選択です。1-2の番号を入力してください。" ;;
  esac
done

echo ""

# AIタイプ選択
if [ -z "${1:-}" ]; then
  echo "AIツールを選択してください:"
  echo "  1) claude (Claude Code)"
  echo "  2) codex (OpenAI Codex)"
  echo "  3) opencode (OpenCode)"
  while true; do
    printf "選択 (1-3)> "
    read -r choice
    case "$choice" in
      1) AI_TYPE="claude"; break ;;
      2) AI_TYPE="codex"; break ;;
      3) AI_TYPE="opencode"; break ;;
      *) echo "無効な選択です。1-3の番号を入力してください。" ;;
    esac
  done
else
  AI_TYPE="$1"
fi

# エージェント名選択
if [ -z "${2:-}" ]; then
  echo ""
  echo "インストールするエージェントを選択してください:"
  echo "  1) ios-expert (iOS開発エキスパート)"
  while true; do
    printf "選択 (1)> "
    read -r choice
    case "$choice" in
      1) AGENT_NAME="ios-expert"; break ;;
      *) echo "無効な選択です。1の番号を入力してください。" ;;
    esac
  done
else
  AGENT_NAME="$2"
fi

# AIタイプに応じたディレクトリを設定
if [ "$BASE_PATH" == "$HOME" ]; then
  # Global インストール
  case "$AI_TYPE" in
    claude)
      INSTALL_DIR="${HOME}/.claude/agents"
      ;;
    codex)
      INSTALL_DIR="${HOME}/.codex/agents"
      ;;
    opencode)
      # OpenCodeのグローバルパスは ~/.config/opencode/agents
      INSTALL_DIR="${HOME}/.config/opencode/agents"
      ;;
  esac
else
  # Local インストール
  case "$AI_TYPE" in
    claude)
      INSTALL_DIR="./.claude/agents"
      ;;
    codex)
      INSTALL_DIR="./.codex/agents"
      ;;
    opencode)
      INSTALL_DIR="./.opencode/agents"
      ;;
  esac
fi

# ディレクトリ作成
mkdir -p "$INSTALL_DIR"

# ダウンロード
DOWNLOAD_URL="${BASE_URL}/${AGENT_NAME}.md"
DEST_FILE="${INSTALL_DIR}/${AGENT_NAME}.md"

echo "インストール中..."
echo "  AIタイプ: $AI_TYPE"
echo "  エージェント: $AGENT_NAME"
echo "  保存先: $DEST_FILE"

if curl -fL -o "$DEST_FILE" "$DOWNLOAD_URL"; then
  echo ""
  echo "✓ インストール完了: $DEST_FILE"
else
  echo ""
  echo "✗ エラー: ダウンロードに失敗しました"
  echo "  エージェント名を確認してください: $AGENT_NAME"
  exit 1
fi
