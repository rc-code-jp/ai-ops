# AI OPS

AI エージェント向けの skill と、それらを配布しやすくする plugin 本体を管理するリポジトリです。
利用側プロジェクトでは APM を使って必要な plugin を宣言できます。

## プラグイン

- `agent-design-toolkit`: エージェント設計と skill 定義の改善
- `planning-facilitator`: 設計や要件の深掘り
- `git-ops-helper`: Git の commit / push 支援
- `ui-craft`: 見た目重視の UI 実装支援

plugin 本体は `plugins/` 配下で管理しています。一覧は `plugins/README.md` を参照してください。

## APM での利用

利用側プロジェクトでは、必要な plugin だけを `apm.yml` の `dependencies.apm` に追加して `apm install` を実行します。

詳しくは [APM での利用](docs/apm.md) を参照してください。

## ドキュメント

- [参考にしたドキュメント](docs/refs.md)
- [役立つ情報](docs/tips.md)
