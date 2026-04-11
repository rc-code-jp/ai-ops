# AI OPS

Codex 向けの skill と、それらを配布しやすくする plugin 本体を管理するリポジトリです。

## プラグイン

- `agent-design-toolkit`: エージェント設計と skill 定義の改善
- `multi-agent-coordination`: 複数 agent 運用の coordination pattern 設計
- `planning-facilitator`: 設計や要件の深掘り
- `git-ops-helper`: Git の commit / push 支援
- `ui-craft`: 見た目重視の UI 実装支援

Codex 向け plugin 本体は `codex-plugins/` 配下で管理しています。一覧は `codex-plugins/README.md` を参照してください。

## 友人向けインストール

```bash
git clone git@github.com:rc-code-jp/ai-ops.git ~/src/ai-ops
cd ~/src/ai-ops
bash scripts/install-agent-design-toolkit.sh
bash scripts/install-multi-agent-coordination.sh
bash scripts/install-planning-facilitator.sh
bash scripts/install-git-ops-helper.sh
bash scripts/install-ui-craft.sh
```

各スクリプトは `~/plugins/<plugin-name>` に symlink を作成し、`~/.agents/plugins/marketplace.json` に必要な entry を追加します。

## ドキュメント

- [参考にしたドキュメント](docs/refs.md)
- [役立つ情報](docs/tips.md)
