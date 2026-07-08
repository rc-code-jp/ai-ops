# irasutoya-doc コンポーネントカタログ

このカタログにある部品**だけ**を使って本文を組み立てる。カタログに無いクラスを発明しない。
画像はすべて `images/` 配下のローカルファイルを相対パスで参照する（例: `images/kaigi_shinken.png`）。
`<img>` には必ず `alt`（イラストの内容の短い説明）を付ける。

---

## A. スライド用（slide-template.html の `{{SLIDES}}` に入れる部品）

### A-1. セクション区切りスライド

```html
<section class="slide slide--section">
  <div class="slide-inner">
    <p class="section-no">SECTION 1</p>
    <h2>現状の課題</h2>
    <img src="images/nayamu_man.png" alt="悩む人">
  </div>
</section>
```

### A-2. コンテンツスライドの外枠（共通）

すべてのコンテンツスライドはこの外枠を使う。`slide-body` の中に A-3〜A-10 のレイアウトを 1〜2 個入れる。

```html
<section class="slide">
  <div class="slide-inner">
    <header class="slide-header">
      <h2>スライドタイトル</h2>
      <p class="lead">補足の一言（省略可）</p>
    </header>
    <div class="slide-body">
      <!-- ここにレイアウト部品 -->
    </div>
  </div>
</section>
```

### A-3. 箇条書き + 画像（定番の 2 カラム）

```html
<div class="cols">
  <div class="col">
    <ul class="bullets">
      <li><strong>ポイント1</strong>：説明テキスト</li>
      <li><strong>ポイント2</strong>：説明テキスト</li>
      <li><strong>ポイント3</strong>：説明テキスト</li>
    </ul>
  </div>
  <div class="col col--narrow">
    <figure class="irasuto">
      <img src="images/xxx.png" alt="説明">
      <figcaption>キャプション（省略可）</figcaption>
    </figure>
  </div>
</div>
```

### A-4. 箇条書きのみ

```html
<ul class="bullets">
  <li><strong>ポイント</strong>：説明</li>
</ul>
```

### A-5. カードグリッド（機能一覧・選択肢・体制など）

列数はカード数に合わせて `card-grid--2`（2列）/ 無印（3列）/ `card-grid--4`（4列）。

```html
<div class="card-grid">
  <div class="card">
    <img src="images/xxx.png" alt="説明">
    <h3>カード見出し</h3>
    <p>短い説明</p>
  </div>
  <!-- 繰り返し -->
</div>
```

### A-6. ステップフロー（手順・プロセス。3〜4 ステップ推奨）

```html
<div class="step-flow">
  <div class="step">
    <span class="step-no">STEP 1</span>
    <img src="images/xxx.png" alt="説明">
    <h3>ステップ名</h3>
    <p>短い説明</p>
  </div>
  <div class="step-arrow">▶</div>
  <div class="step">…</div>
</div>
```

### A-7. 数値ハイライト（KPI・実績。2〜3 個推奨）

```html
<div class="stat-grid">
  <div class="stat">
    <img src="images/xxx.png" alt="説明">
    <p class="stat-value">120%</p>
    <p class="stat-label">前年比売上</p>
  </div>
  <!-- 繰り返し。2個なら stat-grid--2 -->
</div>
```

### A-8. 比較（Before/After・現状/理想・○×）

```html
<div class="compare">
  <div class="compare-pane compare-pane--bad">
    <h3>現状</h3>
    <img src="images/xxx.png" alt="説明">
    <p>課題の説明</p>
  </div>
  <div class="compare-pane compare-pane--good">
    <h3>導入後</h3>
    <img src="images/xxx.png" alt="説明">
    <p>改善の説明</p>
  </div>
</div>
```

### A-9. 表

```html
<table class="slide-table">
  <thead><tr><th>項目</th><th>内容</th></tr></thead>
  <tbody><tr><td>…</td><td>…</td></tr></tbody>
</table>
```

### A-10. コールアウト（注意・強調）

```html
<div class="callout">
  <img src="images/xxx.png" alt="説明">
  <p>強調したいメッセージ</p>
</div>
<!-- 注意喚起は --warning -->
<div class="callout callout--warning">
  <img src="images/xxx.png" alt="説明">
  <p>注意事項</p>
</div>
```

### A-11. 大きな画像 1 枚で見せるスライド

`slide-body` に `irasuto--large` を 1 つだけ置く。メッセージ 1 行を添える。

```html
<figure class="irasuto irasuto--large">
  <img src="images/xxx.png" alt="説明">
  <figcaption>メッセージ</figcaption>
</figure>
```

### タイトルスライドの {{HERO}}

テンプレートの `{{HERO}}` には次を入れる（画像が無ければ空文字）。

```html
<figure class="hero"><img src="images/xxx.png" alt="説明"></figure>
```

---

## B. ドキュメント用（doc-template.html の `{{BODY}}` に入れる部品）

### B-1. 章（改ページ単位）

```html
<section class="chapter" id="sec-1">
  <h2 class="chapter-heading">1. 章タイトル</h2>
  <!-- ここに B-2 以降の部品 -->
</section>
```

`{{TOC}}` には章の数だけ `<li><a href="#sec-1">1. 章タイトル</a></li>` を入れる。

### B-2. 小見出しと段落

```html
<h3>小見出し</h3>
<p>本文テキスト。</p>
```

### B-3. 右回り込みの挿絵（段落に添える小さい画像）

回り込みを解除したい要素に `clearfix` を付ける。

```html
<figure class="irasuto irasuto--float">
  <img src="images/xxx.png" alt="説明">
</figure>
<p>本文テキスト（画像の左に回り込む）。</p>
<div class="clearfix"></div>
```

### B-4. 画像 + テキストの横並び

```html
<div class="row">
  <figure class="irasuto"><img src="images/xxx.png" alt="説明"></figure>
  <div class="row-text">
    <p>説明テキスト。</p>
  </div>
</div>
```

### B-5. 中央配置の画像

```html
<figure class="irasuto">
  <img src="images/xxx.png" alt="説明">
  <figcaption>キャプション</figcaption>
</figure>
```

### B-6. カードグリッド / ステップフロー / 数値ハイライト / コールアウト / 表

スライド用（A-5, A-6, A-7, A-10）と同じマークアップが使える。表のみクラス名が `doc-table`。

```html
<table class="doc-table">…</table>
```

---

## C. 共通ルール

- 画像の使い回しは推奨（同じ画像の複数回使用は、いらすとや規約上 1 点とカウントされる）
- 1 スライド / 1 章に画像を詰め込みすぎない（スライドは 1〜4 枚、章は 1〜3 枚が目安）
- テキストは HTML エスケープを徹底（`<`, `>`, `&`, `"`, `'`）
- `<script>`・外部 CDN・インライン style 属性は使わない
- テンプレートの `<style>` 領域は改変しない
