# Agent Design Toolkit

Codex のスキル定義、subagent 定義、routing 文、権限設計を見直すためのプラグインです。

## 含まれる skills

- `agents-md-improver`
- `codex-skill-improver`
- `codex-subagent-improver`

## 使いどころ

- Codex 用の `SKILL.md` を改善したい
- `AGENTS.md` / `CLAUDE.md` の指示設計を見直したい
- subagent 定義の責務境界や権限設定を再設計したい

## APM での利用

利用側プロジェクトの `apm.yml` にこの plugin を追加します。

```yaml
dependencies:
  apm:
    - rc-code-jp/ai-ops/plugins/agent-design-toolkit#main
```
