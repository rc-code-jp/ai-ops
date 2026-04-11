# AI OPS

Codex 向けの skill と、それらを配布しやすくする plugin 本体を管理するリポジトリです。

## プラグイン

- `agent-design-toolkit`: エージェント設計と skill 定義の改善
- `planning-facilitator`: 設計や要件の深掘り
- `git-ops-helper`: Git の commit / push 支援
- `ui-craft`: 見た目重視の UI 実装支援

Codex 向け plugin 本体は `codex-plugins/` 配下で管理しています。一覧は `codex-plugins/README.md` を参照してください。

## Codex plugin のインストール

このリポジトリは repo ローカル marketplace として `.agents/plugins/marketplace.json` を持っています。marketplace 名は `ai-ops`、Codex 上の表示名は `AI Ops` です。

インストール手順:

1. このリポジトリを Codex で開く。
2. Codex を再起動して、repo ローカル marketplace を読み込ませる。
3. CLI では `codex` を起動して `/plugins` を実行する。Codex app では Plugins を開く。
4. marketplace で `AI Ops` を選ぶ。
5. 使いたい plugin を開き、`Install plugin` を選ぶ。
6. 新しい thread を開始して、必要な plugin または skill を呼び出す。

## ドキュメント

- [参考にしたドキュメント](docs/refs.md)
- [役立つ情報](docs/tips.md)
