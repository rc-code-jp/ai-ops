# Plugins

このディレクトリには、用途ごとに分割した plugin を置いています。

## plugin 一覧

- `agent-design-toolkit`: エージェント設計、`SKILL.md`、`AGENTS.md` の改善
- `planning-facilitator`: 設計や要件の深掘り
- `git-ops-helper`: 差分確認、commit、push の運用支援
- `ui-craft`: 見た目の強い UI 実装支援

## 補足

このリポジトリでは、ルート `skills/` ではなく `plugins/` 配下を正式な配布単位として扱います。
利用側で APM を使う場合も、各 plugin ディレクトリを依存として指定します。

## APM での利用

利用側プロジェクトの `apm.yml` に必要な plugin だけを追加します。

```yaml
dependencies:
  apm:
    - rc-code-jp/ai-ops/plugins/agent-design-toolkit#main
    - rc-code-jp/ai-ops/plugins/planning-facilitator#main
    - rc-code-jp/ai-ops/plugins/git-ops-helper#main
    - rc-code-jp/ai-ops/plugins/ui-craft#main
```

追加後、利用側プロジェクトで `apm install` を実行します。
