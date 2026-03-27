# Agent Design Toolkit for Claude Code

Claude Code のスキル定義と custom sub-agent 定義を、公式仕様に沿って見直すためのプラグインです。

## 含まれる skills

- `claude-skill-improver`
- `claude-subagent-improver`

## 使いどころ

- Claude Code 用の `SKILL.md` を公式準拠で改善したい
- `description`、frontmatter、`allowed-tools`、`context: fork` の使い方を見直したい
- custom sub-agent の routing 文、権限、自己完結性を再設計したい

## ローカルテスト

```bash
claude --plugin-dir ./claude-plugins/agent-design-toolkit
```

読み込み後は `/agent-design-toolkit:claude-skill-improver` または `/agent-design-toolkit:claude-subagent-improver` で呼び出せます。
