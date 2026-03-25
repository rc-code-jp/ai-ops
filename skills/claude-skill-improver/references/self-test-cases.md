# claude-skill-improver 自身のテスト設計

## 発火テスト

### 発火すべき依頼（5 件）

1. 「この SKILL.md を Claude Code 向けに見直して」
2. 「スキルが Claude で自動的に読まれないので改善して」
3. 「disable-model-invocation を付けるべきか見て」
4. 「allowed-tools の絞り方をレビューして」
5. 「Codex 向けスキルを Claude Code に移植したい」

### 発火すべきでない依頼（5 件）

1. 「このプルリクエストをレビューして」→ コードレビュー / PR レビュー
2. 「AGENTS.md を改善して」→ agents-md-improver
3. 「Codex の custom agent を見直して」→ codex-subagent-improver
4. 「README.md を自然な日本語にして」→ 一般文書改善
5. 「新しいスキルを 1 から作って」→ skill-creator 系の作成タスク

## 機能テスト

### 正常系

#### ケース 1: `description` が自動読込条件を持たない
入力: `description: スキルを改善する。`
期待出力:
- 重大度「高」: 自動読込境界が成立していない
- 使う場面と使わない場面を含む改善案が出る

#### ケース 2: frontmatter の誤用
入力: 通常の自動読込スキルなのに `disable-model-invocation: true` が付いている
期待出力:
- 重大度「中」以上: 自動読込不能のリスク
- フィールド削除または用途再定義の提案が出る

#### ケース 3: `context: fork` にタスク本文がない
入力: ガイドライン列挙だけの SKILL.md に `context: fork` を付与
期待出力:
- 重大度「高」: 分離実行しても意味のある作業にならない
- タスク本文追加または `context: fork` 削除の提案が出る

#### ケース 4: 引数つきスキルの品質確認
入力: `/fix-issue 123` のような用途なのに `$ARGUMENTS` が未使用
期待出力:
- 重大度「中」以上: 引数契約が曖昧
- `$ARGUMENTS` または位置引数の利用案が出る

### エラー系

#### ケース 5: YAML フロントマターが壊れている
入力: `---` デリミタ欠落
期待出力:
- 構文エラーを報告する
- `scripts/validate_frontmatter.sh` の実行または修正案が示される

#### ケース 6: `SKILL.md` が存在しない
入力: テンプレートと scripts だけがあるディレクトリ
期待出力:
- スキルとして不完全だと報告する
- 必須ファイルとして `SKILL.md` の追加を求める

## ベースライン比較

| 指標 | スキルなし（手動レビュー） | スキルあり |
|---|---|---|
| Claude Code 固有 frontmatter の見落とし | 起きやすい | 毎回同じ観点で確認 |
| 自動読込境界の評価 | 感覚的になりやすい | `description` 中心に修正文まで出る |
| slash command 設計の妥当性 | ばらつく | `name` と引数契約まで確認できる |
| サブエージェント化の妥当性 | 過剰設定しやすい | `context: fork` の必要性を整理できる |
