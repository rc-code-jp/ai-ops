# Codex / Claude Skills 比較

`codex-skill-improver` と `claude-skill-improver` の共通点と差分を整理した比較表。

## 比較表

| 観点 | `codex-skill-improver` | `claude-skill-improver` |
|---|---|---|
| 対象 | Codex 用 `SKILL.md` | Claude Code 用 `SKILL.md` |
| 主目的 | Codex で暗黙発火しやすく、低コンテキストで再現性のあるスキルへ改善する | Claude Code で自動読込しやすく、slash command としても使いやすいスキルへ改善する |
| `description` の役割 | 暗黙起動の routing 文 | 自動読込の境界説明 |
| 発火評価の中心 | 暗黙発火、誤発火、未発火 | 自動読込、手動 slash command、誤読込 |
| 1 スキル 1 責務 | 重視する | 重視する |
| 手順の書き方 | 命令形 + 入力 / 出力を明示 | 命令形 + 入力 / 出力を明示 |
| 段階的開示 | 強く重視する。`SKILL.md` を短くし、詳細を `references/` に逃がす | 重視するが、テンプレートや examples などの補助ファイル利用も前提に置く |
| 補助ファイルの主眼 | `scripts/`、`references/`、`assets/`、`agents/openai.yaml` | template、examples、scripts、references |
| スクリプトの扱い | 決定的な検証や外部ツール連携時だけ推奨 | 決定的な検証に加え、Claude が参照する補助構成の一部として評価 |
| 追加メタデータ | `agents/openai.yaml` の必要性を評価 | Claude 固有 frontmatter を評価 |
| 固有 frontmatter | `SKILL.md` の基本 metadata と `agents/openai.yaml` を中心に扱う | `disable-model-invocation`、`user-invocable`、`allowed-tools`、`context`、`agent` を扱う |
| 明示呼び出し | スキル名の明示指定はあるが、主眼は暗黙起動 | `/skill-name` を前提に明示呼び出しを強く意識する |
| 引数の扱い | 特に中核観点ではない | `$ARGUMENTS`、`$ARGUMENTS[N]`、`$1` を明示的に評価する |
| 動的コンテキスト注入 | `agents/openai.yaml` の依存宣言を必要に応じて評価 | `!`command`` による事前展開を評価する |
| サブエージェント連携 | `agents/openai.yaml` や構成の必要性を控えめに評価 | `context: fork` と `agent` の妥当性を明示的に評価する |
| 配置場所の観点 | Codex のスキャン対象とスキル構成を前提にする | `.claude/skills/`、`~/.claude/skills/`、プラグイン配下を前提にする |
| 改善時に強く見る失敗 | 発火失敗、責務過多、手順の曖昧さ、過剰な文脈消費 | 自動読込失敗、frontmatter の誤用、引数契約の曖昧さ、タスク不在の `context: fork` |
| 出力の基本形 | `## Findings` → `## Revised Skill` → `## Residual Risks` | `## Findings` → `## Revised Skill` → `## Residual Risks` |

## 共通点

| 項目 | 共通内容 |
|---|---|
| レビュー単位 | `SKILL.md` を中心に、同一スキル配下の補助ファイルもまとめて見る |
| 重視する品質 | 発火境界、責務境界、実行可能な手順、再現性 |
| 推奨設計 | 1 スキル 1 責務、命令形の手順、入力 / 出力の明示 |
| テスト観点 | 発火テスト、機能テスト、残留リスクの明示 |
| 対象外 | 一般的な Markdown 校正、コードレビュー、PR レビュー |

## 使い分けの目安

| 状況 | 使うべきスキル |
|---|---|
| Codex で暗黙起動しない SKILL.md を見直したい | `codex-skill-improver` |
| `agents/openai.yaml` を追加すべきか判断したい | `codex-skill-improver` |
| Claude Code の `/skill-name` 設計を見直したい | `claude-skill-improver` |
| `disable-model-invocation` や `allowed-tools` の妥当性を確認したい | `claude-skill-improver` |
| `context: fork` や `agent` を付けるべきか見たい | `claude-skill-improver` |
| Codex 向けスキルを Claude Code へ移植したい | `claude-skill-improver` |
| Claude 向けスキルを Codex へ移植したい | `codex-skill-improver` |
