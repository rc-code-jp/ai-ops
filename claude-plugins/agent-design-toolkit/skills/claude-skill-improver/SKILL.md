---
name: claude-skill-improver
description: Claude Code 用のスキル定義をレビューし、description の自動読込境界、slash command としての呼び出し方、フロントマター、サポートファイル構成、サブエージェント連携を改善する。SKILL.md を Claude Code 向けに最適化したいとき、自動トリガーが弱いとき、disable-model-invocation や user-invocable や allowed-tools の使い分けを見直したいとき、Codex 向けスキルを Claude Code に移植したいときに使う。一般的な Markdown 校正、コードレビュー、PR レビューには使わない。
metadata:
  author: rc-code-jp
  version: 0.1.0
  category: development-tooling
---

# Claude Skill Improver

Claude Code の `SKILL.md` を、自動読込しやすく、slash command としても使いやすく、Claude 固有機能まで含めて運用できる形へ改善する。

## 重要方針

- 評価軸は Claude Code Skills 公式ドキュメントを最優先にする
- `description` は自動読込の境界として扱う
- Claude Code 固有の frontmatter を必要なときだけ使う
- 手順は命令形で書き、各ステップの入力と出力を明示する
- サポートファイルは `SKILL.md` から参照できる前提で整理する
- `context: fork` や `agent` は実行タスクが明確な場合だけ提案する

## 対象

- Claude Code 用の `SKILL.md`
- 同一スキル配下のテンプレート、examples、scripts、references
- 必要に応じて `.claude/skills/` または `~/.claude/skills/` の配置

## このスキルが重視する観点

- `description` が自動読込境界として十分に具体的か
- slash command 名として `name` が自然か
- `disable-model-invocation`、`user-invocable`、`allowed-tools` の設定が妥当か
- `$ARGUMENTS`、`$1` などの引数利用が必要十分か
- `context: fork` と `agent` が意味のある実行単位になっているか
- `!`command`` による動的コンテキスト注入が過剰でないか

## 手順

### 1. 対象ファイルを特定する

入力: ユーザーが指定したパス、またはレビュー対象候補
出力: 対象スキルの構成一覧

- 対象が `SKILL.md` を持つスキルディレクトリか確認する
- 関連ファイルとしてテンプレート、examples、scripts、references の有無を確認する
- 配置場所が `.claude/skills/`、`~/.claude/skills/`、またはプラグイン配下のどれかを確認する

### 2. 現状の役割を短く要約する

入力: `SKILL.md`
出力: 現状の責務要約 2〜4 文

- 何をするスキルか
- いつ自動読込されるべきか
- `/skill-name` で明示呼び出ししたときに何を進めるか
- 要約しづらい場合は、その時点で責務境界が曖昧だと判断する

### 3. 構造とフロントマターを確認する

入力: スキル構成一覧
出力: 構造上の問題一覧

- `SKILL.md` が存在するか
- YAML フロントマターに `name` と `description` があるか
- `name` が slash command として自然な kebab-case か
- `disable-model-invocation`、`user-invocable`、`allowed-tools`、`context`、`agent` を使っている場合、その意図が説明できるか
- 形式チェックが必要なら `bash scripts/validate_frontmatter.sh <対象ファイル>` を実行する

### 4. `description` を自動読込境界として評価する

入力: `description`
出力: 発火上の問題一覧

- 自動読込で使えるだけの具体性があるか確認する
- 何をするか、いつ使うか、いつ使わないかが読めるか確認する
- slash command 前提の手動専用スキルなら `disable-model-invocation: true` を検討する
- 類似依頼で誤読込しそうなら、境界条件や除外条件を追加する

### 5. Claude Code 固有の frontmatter を評価する

入力: フロントマター
出力: Claude 固有設定の問題一覧

- `disable-model-invocation: true` は自動読込させたくないスキルにだけ使っているか
- `user-invocable: false` は内部自動化や委譲専用スキルにだけ使っているか
- `allowed-tools` は職務に対して最小化されているか
- `context: fork` を使うなら、単なるガイドラインではなく実行可能なタスク本文になっているか
- `agent` を使うなら、実際に分離実行の利益があるか

### 6. 指示内容を Claude Code 向けに評価する

入力: `SKILL.md` 本文
出力: 指示品質の問題一覧

- 手順が命令形で書かれているか確認する
- 各ステップに入力と出力があるか確認する
- `$ARGUMENTS`、`$ARGUMENTS[N]`、`$1` などを使う場合、引数契約が曖昧でないか確認する
- `!`command`` を使う場合、事前展開される前提に合った書き方になっているか確認する
- サポートファイルを使うなら、`SKILL.md` から読むタイミングが分かるように書かれているか確認する

### 7. Findings と修正版を出す

- 先頭は必ず `## Findings` にする
- findings は重大度順に並べる
- 各 finding で「重大度」「問題」「影響」「改善案」を短く示す
- 可能なら `SKILL.md` の修正版をそのまま差し替えられる形で出す
- 必要があればテンプレートや examples や scripts の追加案も示す

## 出力ルール

- 構成は `## Findings`、`## Revised Skill`、`## Residual Risks` の順を基本とする
- findings がない場合も、残るリスクと未検証項目は必ず書く
- 細かな文体指摘より、自動読込失敗、frontmatter の誤用、責務過多、タスク不在の `context: fork` を優先する

## Claude Code 公式仕様として前提に置くこと

- Claude は `description` に基づいてスキルを自動読込できる
- `/skill-name` で明示呼び出しできる
- `disable-model-invocation: true` で自動読込を止められる
- `user-invocable: false` でユーザーからの直接呼び出しを禁止できる
- `allowed-tools` でツールアクセスを制限できる
- `$ARGUMENTS` と位置引数を使って slash command 引数を受け取れる
- `!`command`` は Claude に渡る前に展開される
- `context: fork` を付けるとサブエージェント実行になり、会話履歴は見えない

## 補足

- 詳細なレビュー観点は `references/best-practices.md` を参照する
- 発火テストとベースライン比較は `references/self-test-cases.md` を参照する
- 構文検証には `scripts/validate_frontmatter.sh` を使う
