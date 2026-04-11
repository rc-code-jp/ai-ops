# Codex Plugins

このディレクトリには、用途ごとに分割した Codex plugin を置いています。

## plugin 一覧

- `agent-design-toolkit`: エージェント設計、`SKILL.md`、`AGENTS.md` の改善
- `multi-agent-coordination`: 複数 agent 運用の coordination pattern 設計
- `planning-facilitator`: 設計や要件の深掘り
- `git-ops-helper`: 差分確認、commit、push の運用支援
- `ui-craft`: 見た目の強い UI 実装支援

## 使い方

必要な plugin の README を確認し、対応するインストールスクリプトを実行します。

- `agent-design-toolkit` -> `codex-plugins/agent-design-toolkit/README.md`
- `multi-agent-coordination` -> `codex-plugins/multi-agent-coordination/README.md`
- `planning-facilitator` -> `codex-plugins/planning-facilitator/README.md`
- `git-ops-helper` -> `codex-plugins/git-ops-helper/README.md`
- `ui-craft` -> `codex-plugins/ui-craft/README.md`

## 補足

このリポジトリでは、ルート `skills/` ではなく `codex-plugins/` 配下を正式な配布単位として扱います。
