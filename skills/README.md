# Agent Skills

公式に準拠：https://agentskills.io/home

## install

推奨: リポジトリを clone していない環境でも、次のコマンドで一覧から選び、番号入力でインストールできます。

```bash
bash <(curl -sL https://raw.githubusercontent.com/rc-code-jp/ai-ops/main/skills/install_skill.sh)
```

この方法は `raw.githubusercontent.com` 上のスクリプトと一覧ファイルだけを使い、GitHub API には依存しません。

このリポジトリを clone 済みなら、次のようにローカルから実行できます。

```bash
bash skills/install_skill.sh
```

個別に直接インストールする場合:

```bash
npx skills add https://github.com/rc-code-jp/ai-ops/tree/main/skills/XXXX
```
