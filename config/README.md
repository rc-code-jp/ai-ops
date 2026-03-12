# AI設定ファイル

このディレクトリには、AIツール向けの設定ファイルを配置しています。

## フォルダ構成

- `codex/config.toml`: Codex のグローバル設定ファイル
- `codex.gitignore`: Codex のローカル `.codex/.gitignore` 用テンプレート
- `opencode/_opencode.json`: OpenCode のグローバル設定ファイル

## AGENTS.md の初期セットアップ

```bash
mkdir -p .agents
touch .agents/.gitkeep

curl -L -o AGENTS.md \
  https://raw.githubusercontent.com/rc-code-jp/ai-ops/main/AGENTS.md

ln -s AGENTS.md CLAUDE.md
ln -s .agents .claude
```

## Codex

### グローバル設定

```bash
curl -L -o ~/.codex/config.toml \
  https://raw.githubusercontent.com/rc-code-jp/ai-ops/main/config/codex/config.toml
```

### ローカル `.gitignore`

```bash
mkdir -p .codex
curl -L -o .codex/.gitignore \
  https://raw.githubusercontent.com/rc-code-jp/ai-ops/main/config/codex.gitignore
```

## OpenCode

### グローバル設定

```bash
mkdir -p ~/.config/opencode
curl -L -o ~/.config/opencode/opencode.json \
  https://raw.githubusercontent.com/rc-code-jp/ai-ops/main/config/opencode/_opencode.json
```
