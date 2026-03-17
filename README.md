# AI OPS

## ドキュメント

- [参考にしたドキュメント](docs/refs.md)
- [役立つ情報](docs/tips.md)

## スキルインストール

スクリプトを実行すると、このリポジトリ内のスキル一覧が表示されます。上下キーで選択し、Enter で決定すると、実行する `npx skills add ...` のコマンドを表示してからインストールを開始します。

```bash
bash scripts/install_skill.sh
```

リポジトリを clone していない環境からは、次のように直接実行できます。

```bash
bash <(curl -sL https://raw.githubusercontent.com/rc-code-jp/ai-ops/main/scripts/install_skill.sh)
```

ドライラン:

```bash
bash scripts/install_skill.sh --dry-run
```

リモート実行時のドライラン:

```bash
bash <(curl -sL https://raw.githubusercontent.com/rc-code-jp/ai-ops/main/scripts/install_skill.sh) --dry-run
```
