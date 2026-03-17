# Agent Skills

公式に準拠：https://agentskills.io/home

## install

個別に直接インストールする場合:

```bash
npx skills add https://github.com/rc-code-jp/ai-ops/tree/main/skills/XXXX
```

このリポジトリを clone 済みなら、一覧から選んで次のように実行できます。

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
