# AI OPS

Codex と Claude Code 向けの skill と、それらを配布しやすくする plugin 本体を管理するリポジトリです。

## プラグイン

| プラグイン | 機能 | Codex | Claude |
|---|---|:---:|:---:|
| `agent-design-toolkit` | エージェント設計と skill 定義の改善 | ✅ | ✅ |
| `planning-facilitator` | 計画・設計・実装着手の質向上（Codex: 深掘り対話 / Claude: 実装前ゲート） | ✅ | ✅ |
| `html-plan-renderer` | 実行プランを読みやすい HTML として `./plans/` に出力 | ✅ | ✅ |
| `html-doc-renderer` | 仕様書・計画資料などを PDF 印刷にも適した HTML として出力 | ✅ | ✅ |
| `git-ops-helper` | Git の commit / push 支援 | ✅ | — |
| `ui-craft` | 見た目重視の UI 実装支援 | ✅ | — |
| `japanese-style` | 日本語出力スタイル（output style） | — | ✅ |

plugin 本体は Codex 向けが `codex-plugins/`、Claude Code 向けが `claude-plugins/` 配下にあります。Codex 側の一覧は `codex-plugins/README.md` を参照してください。

## Codex plugin のインストール

このリポジトリは repo ローカル marketplace として `.agents/plugins/marketplace.json` を持っています。marketplace 名は `ai-ops`、Codex 上の表示名は `AI Ops` です。

インストール手順:

1. このリポジトリを Codex で開く。
2. Codex を再起動して、repo ローカル marketplace を読み込ませる。
3. CLI では `codex` を起動して `/plugins` を実行する。Codex app では Plugins を開く。
4. marketplace で `AI Ops` を選ぶ。
5. 使いたい plugin を開き、`Install plugin` を選ぶ。
6. 新しい thread を開始して、必要な plugin または skill を呼び出す。

## Claude Code plugin のインストール

Claude Code 向けには repo ローカル marketplace として `.claude-plugin/marketplace.json` を持っています。marketplace 名は `ai-ops`、plugin 本体は `claude-plugins/` 配下にあります。

1. marketplace を追加する。
   - Git 経由: `/plugin marketplace add rc-code-jp/ai-ops`
   - ローカルで試す場合: `/plugin marketplace add .`（リポジトリのルートパス）
2. plugin をインストールする。
   - 個人利用: `/plugin install japanese-style@ai-ops`
   - チーム配布（プロジェクトスコープ）: `claude plugin install japanese-style@ai-ops --scope project`
3. `/reload-plugins` で有効化する。

各 plugin の `source` には相対パスを使っているため、marketplace を Git 経由（GitHub 等）で追加したときに各 plugin が解決されます。`marketplace.json` への直接 URL 指定では解決されない点に注意してください。

## ドキュメント

- [参考にしたドキュメント](docs/refs.md)
- [役立つ情報](docs/tips.md)
