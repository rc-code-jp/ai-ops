# japanese-style

Claude Code の出力を**日本語に固定し、文体・技術用語・表記のルールをチーム共通で揃える** output style を提供するプラグインです。

## 特徴

- **常時適用**: output style はセッション開始時にシステムプロンプトへ読み込まれ、すべての応答に効きます。必要時に発動する skill とは異なり、有効な間は常に作用します。
- **plugin 有効化で自動適用**: `force-for-plugin: true` を指定しているため、プラグインを有効にするだけでスタイルが適用されます。ユーザーが `/config` から手動選択する必要はありません。
- **コーディング挙動を維持**: `keep-coding-instructions: true` により、Claude Code 本来のコーディング用の振る舞い（簡潔さ・ツール利用・安全確認）を残したまま、言語・文体ルールだけを上乗せします。
- **コードは翻訳しない**: コード識別子・コマンド・パス・API 名は原文のまま。コード内コメントは既存ファイルの言語に合わせ、勝手に日本語化しません。

## 含まれる output style

- `Japanese Output`（`output-styles/japanese.md`） — 日本語・です／ます調・技術用語の原文維持・表記ルールを定義。

## 使い方

プラグインを有効化すると自動で適用されます。手動で切り替えたい場合は `/config` の **Output style** から `Japanese Output` を選択／解除できます。

そのターンだけ別の言語・文体にしたいときは、ユーザーが「英語で」「だ・である調で」のように明示的に指示してください。スタイルよりそのターンの明示指示が優先されます。

## ローカルテスト

```bash
claude --plugin-dir ./claude-plugins/japanese-style
```

## 構成

```
japanese-style/
├── .claude-plugin/plugin.json   # outputStyles フィールドで output-styles/ を指定
├── README.md
└── output-styles/
    └── japanese.md              # 言語・文体・表記ルール本体
```

## 補足

- output style は **Claude Code 固有**の機能です。Codex 側に同等機構はないため、Codex で同じ方針を適用したい場合は `AGENTS.md` 等で別途表現してください。
- 自分の環境だけに適用したい場合は、`output-styles/japanese.md` を `~/.claude/output-styles/` に置くだけでも動作します。チーム配布が目的のときは本プラグインとして配る形が適切です。

## ライセンス

MIT
