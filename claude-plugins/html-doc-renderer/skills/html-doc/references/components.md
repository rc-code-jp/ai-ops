# html-doc コンポーネントカタログ

`template.html` の `{{BODY}}` に流し込む HTML 断片は、このカタログの部品だけで組み立てる。
CSS はすべてテンプレートに定義済み。**新しい style 属性や `<style>` を追加しない**（例外: `.gantt` 系の CSS 変数指定のみ `style` 属性を使う）。

## 使用方針

1. **視覚優先**: フロー・スケジュール・体制・数値・比較などは文章の羅列にせず、フロー図 / タイムライン / ガント / カード / 数値ハイライト / 表で表現する。段落だけが続く章を作らない
2. **章構成は自由**: ドキュメントの種類（仕様書 / 設計書 / 計画資料 / 説明資料など）に合わせて章を組む
3. **改ページを意識**: 章 = 印刷時のページ単位。1 章が A4 で 1〜3 ページに収まる粒度に分ける
4. **HTML エスケープを徹底**: `<` `>` `&` `"` `'` は実体参照にする（`<code>` 内も同様）

---

## A. 構造系

### A1. 章セクション（改ページ単位）

印刷時、章の前で自動改ページされる。先頭の章は自動的に改ページされない。
表紙・目次の直後に続けたい章には `no-break` を付けると改ページを抑制できる。

```html
<section class="chapter" id="sec-1">
  <h2 class="chapter-heading">1. 概要</h2>
  <p>本文…</p>
</section>
```

- `id` は `{{TOC}}` のアンカー（`<li><a href="#sec-1">1. 概要</a></li>`）と一致させる
- 章番号はタイトル文字列に含める（自動採番しない）

### A2. 小節・段落

```html
<h3>1.1 背景</h3>
<h4>補足タイトル</h4>
<p>段落テキスト。<code>inline code</code> も使える。</p>
```

---

## B. コールアウト（注意書き）

```html
<div class="callout callout--info">
  <p class="callout-label">ℹ 情報</p>
  <p>補足説明をここに書く。</p>
</div>
```

| クラス | ラベル例 | 用途 |
|---|---|---|
| `callout--info` | ℹ 情報 | 補足説明・参考情報 |
| `callout--warning` | ⚠ 注意 | 注意事項・制約 |
| `callout--danger` | ⛔ 危険 | 誤ると障害・データ損失につながる警告 |
| `callout--success` | ✓ 完了条件 | チェック観点・受け入れ基準 |

---

## C. テーブル

### C1. データ表

```html
<table class="doc-table">
  <thead>
    <tr><th>項目</th><th>内容</th><th>備考</th></tr>
  </thead>
  <tbody>
    <tr><td>…</td><td>…</td><td>…</td></tr>
  </tbody>
</table>
```

### C2. 改訂履歴表

`doc-table` に `revision-table` を併記する（版数・日付・変更者の列幅が最適化される）。

```html
<table class="doc-table revision-table">
  <thead>
    <tr><th>版数</th><th>日付</th><th>変更者</th><th>変更内容</th></tr>
  </thead>
  <tbody>
    <tr><td>1.0</td><td>2026-06-05</td><td>山田</td><td>初版作成</td></tr>
  </tbody>
</table>
```

---

## D. リスト

### D1. 番号付き手順（丸数字 + 接続線）

```html
<ol class="procedure-steps">
  <li>
    <span class="step-title">環境変数を設定する</span>
    <span class="step-note">完了条件: .env に API_KEY が定義されている</span>
  </li>
  <li>
    <span class="step-title">マイグレーションを実行する</span>
    <span class="step-note">所要: 約 5 分</span>
  </li>
</ol>
```

### D2. チェックリスト（☐ は CSS が付ける）

```html
<ul class="checklist">
  <li>確認項目 1</li>
  <li>確認項目 2</li>
</ul>
```

### D3. 用語定義リスト

```html
<dl class="definition-list">
  <dt>用語A</dt><dd>定義の説明</dd>
  <dt>用語B</dt><dd>定義の説明</dd>
</dl>
```

---

## E. コード

```html
<pre class="code-block"><code>$ npm install
$ npm run build</code></pre>
```

インラインは `<code>…</code>` をそのまま使う。

---

## F. 図 + キャプション

画像ファイルは埋め込めないため、テキスト図（ASCII / 罫線文字）を使う。
構成図・画面レイアウトなど、下記 G 系の部品で表現しきれない図に使う。

```html
<figure class="doc-figure">
  <pre class="figure-content">┌─────────┐     ┌─────────┐
│ Client  │ ──► │  API    │
└─────────┘     └─────────┘</pre>
  <figcaption>図1. システム構成</figcaption>
</figure>
```

---

## G. 視覚表現（フロー / タイムライン / ガント / 数値 / カード）

### G1. 横フロー図（工程・データフロー）

矢印は CSS が自動で付ける。`<small>` で補足（担当・所要など）を併記できる。
`data-emphasis="strong"` で強調（アクセント色）。

```html
<ol class="flow">
  <li>受付<small>営業</small></li>
  <li>審査<small>2 営業日</small></li>
  <li data-emphasis="strong">承認</li>
  <li>通知</li>
</ol>
```

### G2. 縦フロー図（上から下のプロセス）

```html
<ol class="flow flow--vertical">
  <li>要件定義<small>〜6月</small></li>
  <li>設計</li>
  <li>実装・テスト</li>
</ol>
```

### G3. タイムライン（マイルストーン・計画資料向け）

`data-state="done"` でドットが塗りつぶしになる（実績済みの表現）。

```html
<ul class="timeline">
  <li data-state="done">
    <span class="timeline-date">2026-04</span>
    <span class="timeline-title">キックオフ</span>
    <p>体制確定・要件ヒアリング開始</p>
  </li>
  <li>
    <span class="timeline-date">2026-07</span>
    <span class="timeline-title">β リリース</span>
    <p>社内限定公開</p>
  </li>
</ul>
```

### G4. 簡易ガントチャート（フェーズ計画）

- `.gantt` の `--cols` に期間の列数を指定（`style` 属性での CSS 変数指定はこの部品のみ許可）
- `.gantt-cols` の先頭 `<span>` は空（ラベル列）、以降が期間ラベル
- 各バーは `--start`（開始列・1 始まり）と `--span`（長さ）で位置指定
- 色: 既定は青。`data-color="green|yellow|red"` で変更

```html
<div class="gantt" style="--cols: 6">
  <div class="gantt-cols">
    <span></span><span>4月</span><span>5月</span><span>6月</span><span>7月</span><span>8月</span><span>9月</span>
  </div>
  <div class="gantt-row">
    <span class="gantt-label">要件定義</span>
    <span class="gantt-bar" style="--start: 1; --span: 2">要件定義</span>
  </div>
  <div class="gantt-row">
    <span class="gantt-label">開発</span>
    <span class="gantt-bar" data-color="green" style="--start: 3; --span: 3">開発</span>
  </div>
</div>
```

### G5. 数値ハイライト（KPI・規模感）

```html
<div class="stat-grid">
  <div class="stat"><span class="stat-value">12 万</span><span class="stat-label">月間ユーザー数</span></div>
  <div class="stat"><span class="stat-value">99.9%</span><span class="stat-label">稼働率目標</span></div>
  <div class="stat"><span class="stat-value">3 名</span><span class="stat-label">開発体制</span></div>
</div>
```

### G6. カードグリッド（機能一覧・体制・構成要素）

```html
<div class="card-grid">
  <div class="card">
    <p class="card-title">認証機能</p>
    <p>SSO / 多要素認証に対応。</p>
  </div>
  <div class="card">
    <p class="card-title">通知機能</p>
    <p>メール・Slack 連携。</p>
  </div>
</div>
```

### G7. ステータスチップ

表のセルや見出し横で使う。

```html
<span class="tag" data-state="done">完了</span>
<span class="tag" data-state="active">進行中</span>
<span class="tag" data-state="todo">未着手</span>
<span class="tag" data-state="risk">リスク</span>
```

---

## H. 改ページ制御

```html
<!-- 任意の位置で強制改ページ（画面では不可視） -->
<div class="page-break"></div>

<!-- ひとまとまりをページ境界で分断させない -->
<div class="keep-together">
  <h3>…</h3>
  <table class="doc-table">…</table>
</div>
```

備考: 表・コールアウト・図・ガント・カード等の主要部品には `break-inside: avoid` が既に適用済み。複数部品をまとめて 1 ページに収めたい時だけ `.keep-together` を使う。

---

## 禁止事項

- `<script>` タグ・イベントハンドラ属性（`onclick` 等）の追加
- 外部 CDN（フォント・CSS・画像・Mermaid 等）への参照
- `<style>` の追加、テンプレート `<style>` 領域の改変
- カタログにないクラス名の発明（既存部品の組み合わせで表現する）
- `style` 属性の使用（例外: `.gantt` / `.gantt-bar` の CSS 変数のみ）
