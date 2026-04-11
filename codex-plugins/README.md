# Codex Plugins

このディレクトリには、用途ごとに分割した Codex plugin を置いています。

## plugin 一覧

- `agent-design-toolkit`: エージェント設計、`SKILL.md`、`AGENTS.md` の改善
- `planning-facilitator`: 設計や要件の深掘り
- `git-ops-helper`: 差分確認、commit、push の運用支援
- `ui-craft`: 見た目の強い UI 実装支援

## 補足

このリポジトリでは、ルート `skills/` ではなく `codex-plugins/` 配下を正式な配布単位として扱います。

## インストール方法

このリポジトリの repo ローカル marketplace は `.agents/plugins/marketplace.json` です。marketplace 名は `ai-ops`、Codex 上の表示名は `AI Ops` です。

1. このリポジトリを Codex で開く。
2. Codex を再起動して、repo ローカル marketplace を読み込ませる。
3. CLI では `codex` を起動して `/plugins` を実行する。Codex app では Plugins を開く。
4. marketplace で `AI Ops` を選ぶ。
5. 対象 plugin を開き、`Install plugin` を選ぶ。
6. 新しい thread で plugin または同梱 skill を呼び出す。
