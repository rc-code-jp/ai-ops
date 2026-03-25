# Claude Code Skills ベストプラクティス詳細リファレンス

Claude Code Skills 公式ドキュメントを前提に、`claude-skill-improver` が参照する確認観点を整理したもの。

## 0. 最低限の仕様

Claude Code のスキルは、`SKILL.md` を必須とするディレクトリで構成する。テンプレート、examples、scripts、references などの補助ファイルを追加できる。

典型構成:

```text
my-skill/
├── SKILL.md
├── template.md
├── examples/
│   └── sample.md
└── scripts/
    └── validate.sh
```

`SKILL.md` のフロントマター必須項目は次の 2 つ。

```yaml
---
name: skill-name
description: いつ自動読込すべきかが分かる説明
---
```

よく使う任意項目:

- `disable-model-invocation`
- `user-invocable`
- `allowed-tools`
- `context`
- `agent`

## 1. `description` の評価軸

Claude Code では `description` が自動読込の主要な判断材料になる。したがって、能力一覧よりも発火境界を優先する。

良い形:

`[何をするか] + [いつ使うか] + [使わない場面]`

例:

```yaml
description: Claude Code 用の SKILL.md をレビューし、description の自動読込境界、frontmatter、サポートファイル構成を改善する。スキルが自動で読まれないとき、disable-model-invocation や allowed-tools の使い分けを見直したいときに使う。コードレビューや一般文書の校正には使わない。
```

悪い形:

- `スキルを改善する`
- `エージェントの品質を上げる`
- `Claude と Codex のスキル全部を見る`

## 2. slash command と自動読込の切り分け

Claude Code のスキルは自動読込と `/skill-name` 呼び出しの両方を持てる。

確認点:

- 普段は自動読込させたいのか
- 明示実行専用にしたいのか
- ユーザーが直接呼ぶべきか、内部専用か

判断基準:

- 自動読込が有益ならデフォルトのままにする
- 明示実行専用なら `disable-model-invocation: true`
- 内部自動化専用なら `user-invocable: false`

## 3. Claude Code 固有 frontmatter

### `disable-model-invocation`

自動読込してほしくないときに使う。引数付き slash command や破壊的操作前提のスキルで有効。

### `user-invocable`

ユーザーが `/skill-name` で直接呼ぶべきでない内部用スキルに使う。

### `allowed-tools`

職務に必要な最小ツールへ絞る。読み取り専用スキルなら `Read, Grep, Glob` のように狭める。

### `context: fork`

サブエージェントとして分離実行したいときに使う。単なるガイドライン集ではなく、実行可能なタスク本文が必要。

### `agent`

分離実行時の役割を指定する。使う理由が説明できないなら追加しない。

## 4. 引数と動的コンテキスト

### `$ARGUMENTS`

slash command の後ろに渡した引数を受け取る。引数が必要なスキルでは、本文で利用箇所を明示する。

### `$ARGUMENTS[N]` / `$1`

位置ベース引数を使う場合は、期待する順序をドキュメント化する。

### `!`command``

Claude に渡す前にシェルで展開される。ライブデータ注入に便利だが、重いコマンドや不安定なコマンドを多用しない。

## 5. サポートファイルの扱い

Claude Code のスキルは、`SKILL.md` 以外にテンプレート、examples、scripts を持てる。

確認点:

- `SKILL.md` から各ファイルの用途と参照タイミングが分かるか
- テンプレートが出力の骨格として有効か
- examples が期待出力の基準として機能するか
- scripts が決定的な検証に限定されているか

## 6. 手順の書き方

説明文より、Claude がそのまま実行できる順序を優先する。

悪い例:

```md
必要なら関連情報を集めて、いい感じに要約する。
```

改善例:

```md
1. 対象の `SKILL.md` を読む
入力: スキルファイル
出力: 現状の責務要約

2. `description` の自動読込境界を確認する
入力: `description`
出力: 発火上の問題一覧
```

## 7. よくある改善ポイント

- `description` が短すぎて自動読込条件が分からない
- `disable-model-invocation` を付けた結果、自動読込されず使いづらい
- `user-invocable: false` なのにユーザー向け slash command として説明している
- `allowed-tools` が広すぎる
- `context: fork` を付けたが、タスク本文がなく意味のある作業になっていない
- `$ARGUMENTS` を使うべきなのに固定文で書いている

## 8. 発火テスト

最低でも以下を確認する。

- 自動読込すべき依頼: 5 件以上
- 自動読込すべきでない依頼: 5 件以上
- slash command 前提なら `/skill-name ...` の実行例

見るポイント:

- 直接表現で自動読込できるか
- 言い換え表現でも読めるか
- 類似だが別スキルへ寄せるべき依頼で誤読込しないか

## 9. このスキルでのレビュー優先順

1. 自動読込境界
2. slash command と frontmatter の整合
3. 1 スキル 1 責務
4. 手順の命令形と入出力
5. サポートファイル構成
6. 文体の細部
