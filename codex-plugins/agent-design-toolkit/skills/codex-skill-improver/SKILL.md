---
name: codex-skill-improver
description: Codex 用のスキル定義をレビューし、`description` の発火境界、1 スキル 1 責務、段階的開示、明示的な入出力ステップ、補助ファイル構成を改善する。SKILL.md を Codex 向けに最適化したいとき、暗黙発火が不安定なとき、Claude 前提のスキルを Codex に移植したいとき、Codex の公式ベストプラクティスに合わせたいときに使う。一般的な Markdown 校正、コードレビュー、PR レビュー、custom agent TOML の改善には使わない。
metadata:
  author: rc-code-jp
  version: 3.0.0
  category: development-tooling
---

# Codex Skill Improver

Codex の `SKILL.md` を、暗黙発火しやすく、読み込みコストが低く、再現性のあるワークフローとして機能する形へ改善する。

## 重要方針

- 評価軸は OpenAI の Codex Skills 公式ドキュメントを最優先にする
- `description` は能力紹介ではなく routing 文として扱う
- 1 スキル 1 責務を優先し、広い責務は分割を提案する
- 指示は命令形で書き、各ステップの入力と出力を明示する
- スクリプトは決定的な検証や外部ツールが必要な場合だけ推奨する
- 詳細は `references/` へ逃がし、`SKILL.md` 本体はコア指示に絞る

## 対象

- Codex 用の `SKILL.md`
- 同一スキル配下の `scripts/`
- 同一スキル配下の `references/`
- 必要に応じて `agents/openai.yaml`

## このスキルが重視する観点

- `description` が暗黙発火用の境界として十分に具体的か
- スキルが 1 つの仕事に集中しているか
- 手順が命令形で、入力と出力が追えるか
- `SKILL.md` に詰め込みすぎず、段階的開示ができているか
- `scripts/` や `references/` の使い分けが妥当か
- `agents/openai.yaml` を追加する価値が本当にあるか

## 手順

### 1. 対象ファイルを特定する

入力: ユーザーが指定したパス、またはレビュー対象候補
出力: 対象スキルの構成一覧

- まず対象が `SKILL.md` を持つスキルディレクトリか確認する
- 関連ファイルとして `scripts/`、`references/`、`assets/`、`agents/openai.yaml` の有無を確認する
- `SKILL.md` 以外しか渡されていない場合は、そのファイル単独ではなくスキル全体を確認する前提で扱う

### 2. 現状の役割を短く要約する

入力: `SKILL.md`
出力: 現状の責務要約 2〜4 文

- 何をするスキルか
- いつ起動されるべきか
- 何を返すか、またはどこまで進めるか
- 要約しづらい場合は、その時点で責務境界が曖昧だと判断する

### 3. 構造と必須要件を確認する

入力: スキル構成一覧
出力: 構造上の問題一覧

- `SKILL.md` が存在するか
- YAML フロントマターに `name` と `description` があるか
- `name` がフォルダ名と一致するか
- フォルダ構成が `SKILL.md` と必要に応じた `scripts/`、`references/`、`assets/`、`agents/openai.yaml` に整理されているか
- 形式チェックが必要なら `bash scripts/validate_frontmatter.sh <対象ファイル>` を実行する

### 4. `description` を routing 文として評価する

入力: `description`
出力: 発火上の問題一覧

- 暗黙発火で使えるだけの具体性があるか確認する
- 「何をするか」だけでなく「いつ使うか」と「使わない場面」が読めるか確認する
- 類似依頼で誤発火しそうなら、境界条件や除外条件を追加する
- Claude や他製品固有の呼称に依存している場合は、Codex の用語へ直す

### 5. 指示内容を Codex 向けに評価する

入力: `SKILL.md` 本文
出力: 指示品質の問題一覧

- 手順が命令形で書かれているか確認する
- 各ステップに入力と出力があるか確認する
- 「適切に」「必要なら」だけで進む曖昧な記述を減らす
- Codex がそのまま実行できる調査、判断、編集、検証の順序になっているか確認する
- 説明だけが長く、行動手順が薄い場合は書き換えを提案する

### 6. スコープと段階的開示を評価する

入力: `SKILL.md` と補助ファイル
出力: 分割または整理の提案

- スキルが複数の独立タスクを抱えていないか確認する
- 詳細な例、長いチェックリスト、背景説明を `references/` へ逃がせるか確認する
- 決定的な検証や外部ツール連携が必要な場面だけ `scripts/` を使っているか確認する
- UI 用の表示名、依存ツール、暗黙起動ポリシーが必要な場合だけ `agents/openai.yaml` を提案する

### 7. Findings と修正版を出す

- 先頭は必ず `## Findings` にする
- findings は重大度順に並べる
- 各 finding で「重大度」「問題」「影響」「改善案」を短く示す
- 可能なら `SKILL.md` の修正版をそのまま差し替えられる形で出す
- 必要があれば `references/` や `agents/openai.yaml` の追加案も示す

## 出力ルール

- 構成は `## Findings`、`## Revised Skill`、`## Residual Risks` の順を基本とする
- findings がない場合も、残るリスクと未検証項目は必ず書く
- 細かな文体指摘より、発火失敗、責務過多、手順の曖昧さ、過剰な文脈消費を優先する

## Codex 公式仕様として前提に置くこと

- Codex は `description` に基づいてスキルを暗黙起動できる
- `description` の境界が曖昧だと誤発火または未発火が起きやすい
- スキルは `SKILL.md` を必須とし、`scripts/`、`references/`、`assets/`、`agents/openai.yaml` を任意で持てる
- Codex は段階的開示で、まず metadata を見て必要なときだけ `SKILL.md` 本文を読む
- `agents/openai.yaml` では UI 情報、暗黙起動ポリシー、依存ツールを追加定義できる
- スキルは CLI、IDE、Codex app で利用される

## 補足

- 詳細なレビュー観点は `references/best-practices.md` を参照する
- 発火テストとベースライン比較は `references/self-test-cases.md` を参照する
- 構文検証には `scripts/validate_frontmatter.sh` を使う
