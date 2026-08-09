# Codex Plugins

このディレクトリには、用途ごとに分割した Codex plugin を置いています。

## plugin 一覧

- `agent-design-toolkit`: エージェント設計、`SKILL.md`、`AGENTS.md` の改善
- `planning-facilitator`: 設計や要件の深掘り
- `multi-agent-deliberation`: 複数エージェントによる独立分析と反証の統合
- `git-ops-helper`: 差分確認、commit、push の運用支援
- `ui-craft`: 見た目の強い UI 実装支援
- `html-plan-renderer`: 実行プランを読みやすい HTML として `./plans/` に出力
- `html-doc-renderer`: 仕様書・計画資料などのドキュメントを PDF 印刷にも適した HTML として出力

## 補足

このリポジトリでは、ルート `skills/` ではなく `codex-plugins/` 配下を正式な配布単位として扱います。

## インストール方法

このリポジトリの repo ローカル marketplace は `.agents/plugins/marketplace.json` です。marketplace 名は `ai-ops`、Codex 上の表示名は `AI Ops` です。

1. CLI で初めて使う場合は、`codex plugin marketplace add <このリポジトリの絶対パス>` を実行する。
2. `codex plugin list` で一覧を確認し、`codex plugin add <plugin-name>@ai-ops` でインストールする。
3. Codex app ではこのリポジトリを開いて再起動し、Plugins を開く。
4. marketplace で `AI Ops` を選び、対象 plugin の `Install plugin` を選ぶ。
5. 新しいタスクで plugin または同梱 skill を呼び出す。
