# プレースホルダ仕様

`html-plan` スキルが `scripts/render_plan.py` に渡す JSON のキー一覧と、各値の書式を定義する。
親 Codex はプラン本文からこの仕様に従って値を抽出し、JSON にして渡す。

## 値の扱い区分

- **エスケープ対象キー**: `{{TITLE}}`, `{{GENERATED_AT}}` などプレーンテキストとして埋め込む値。スクリプトが自動で HTML エスケープする。
- **raw キー**(HTML 断片を含むキー): 以下の 6 個だけ。スクリプトはエスケープせず、そのまま挿入する。値の中身は親 Codex 側で HTML エスケープを徹底すること(`<`, `>`, `&`, `"`, `'` を実体参照に)。
  - `TOC`
  - `FILES_TABLE`
  - `MUST_READ`
  - `STEPS`
  - `VERIFICATION`
  - `CONTEXT`

## キー一覧

### 基本メタ

- `TITLE`: プラン主題を 1 行で
- `GENERATED_AT_ISO`: ISO 8601(例: `2026-05-12T10:30:00+09:00`)
- `GENERATED_AT`: 人間向け表記(例: `2026-05-12 10:30`)
- `REPO`: `org/repo` 形式。取れなければ `-`
- `BRANCH`: ブランチ名。取れなければ `-`
- `TOC`: 目次。`<li><a href="#anchor">章タイトル</a></li>` を必要数。各 `<section>` の id と一致させる。テンプレートにある章 id は `context`, `files`, `must-read`, `steps`, `verification`
- `META`: フッター用補足(例: `skill: html-plan / branch: foo`)

### TL;DR(冒頭バナー、最も目立つ場所)

- `TLDR_3_LINES`: 3 行以内の超要約。「何を・なぜ・どんな成果になるか」を 1 文ずつ
- `TLDR_MAX_IMPACT`: 最も影響の大きい変更点を 1 文(壊れたら誰が困るかの観点)
- `TLDR_REVIEW_FOCUS`: レビューで最初に見るべき箇所(例: `ファイル X の関数 Y / マイグレーション順序`)

### 全体メタチップ(影響・所要時間・ロールバック)

- `IMPACT_LEVEL`: `high` / `med` / `low` のいずれか(チップの色分け用)
- `IMPACT_SCOPE`: 影響範囲を短句で(例: `認証フロー全体`, `管理画面のみ`)
- `ESTIMATED_TIME`: 推定実装時間(例: `2〜3 時間`, `半日`)
- `ROLLBACK_LEVEL`: `high`(困難)/ `med` / `low`(容易) のいずれか
- `ROLLBACK_DIFFICULTY`: ロールバック容易度の短句(例: `revert で完結`, `DB マイグレーション要逆行`)

### 要点ブロック

- `SUMMARY_WHAT`: 要点: 何を
- `SUMMARY_WHY`: 要点: なぜ
- `SUMMARY_HOW`: 要点: どう
- `SUMMARY_SIDE_EFFECTS`: 要点: 副作用と影響範囲
- `SUMMARY_OUT_OF_SCOPE`: 要点: スコープ外

### 本文(raw HTML)

- `CONTEXT`: 背景/目的の本文(`<p>` タグで段落化)
- `FILES_TABLE`: 後述「ファイル変更行の書式」参照
- `MUST_READ`: レビュー時の重点ポイント。`<div class="must-read">...</div>` のブロックを 1〜3 個。各ブロックには「該当箇所のパス・関数名」「気をつけて読むべき理由」を含める
- `STEPS`: 後述「ステップ行の書式」参照
- `VERIFICATION`: `<li>検証項目</li>` を必要数(チェック記号 ☐ は CSS が付ける)

## ファイル変更行の書式(`FILES_TABLE` の中身)

```html
<tr>
  <td class="path"><code>path/to/file.ts</code></td>
  <td class="op" data-op="add|edit|delete">add|edit|delete</td>
  <td class="size" data-size="S|M|L">S|M|L</td>
  <td class="risk" data-risk="low|med|high">低|中|高</td>
  <td>1 行サマリ</td>
</tr>
```

- 規模(size): S = 〜30 行 / M = 30〜200 行 / L = 200 行以上
- リスク(risk): 既存呼び出し元が多い・本番影響あり・ロールバック困難 のいずれかで `high` を、純粋追加や独立モジュールは `low`

## ステップ行の書式(`STEPS` の中身、`<details>` で折りたたみ可能)

```html
<li>
  <details>
    <summary>ステップタイトル(動詞で始める)</summary>
    <div class="step-goal">目的: 〜 / 完了条件: 〜</div>
    <div class="step-detail">
      <p>詳細な手順や注意点</p>
    </div>
  </details>
</li>
```

- `summary` は短く 1 行。詳細は `details` の中。これにより冒頭スキャン時はタイトルだけ見える

## 共通制約

- raw キーの値を作るときは、文字列リテラルとして埋め込む箇所は親 Codex 側で必ず HTML エスケープする(`<` → `&lt;`、`>` → `&gt;`、`&` → `&amp;`、`"` → `&quot;`、`'` → `&#x27;`)
- テンプレ内の `<style>` 領域は改変しない(プレースホルダ部分のみが置換対象)
- 外部 CDN や `<script>` を値の中に入れない
- 抽出時にプラン内容を要約・脚色しない(忠実に転記)
- `MUST_READ` に該当するレビュー重点ポイントがプランに無い場合は、要点ブロックから推定できる注意点(副作用・スコープ境界・破壊的変更)を 1 つ抽出して書く。全く無ければ「特記なし」とだけ書いた must-read ブロックを 1 つ置く
