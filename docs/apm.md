# APM での利用

このリポジトリは、AI エージェント向けの便利ツールを APM から利用できるようにします。

## 方針

- このリポジトリには `apm.yml` を置かず、利用側プロジェクトの APM manifest から必要な plugin を参照します。
- 利用側プロジェクトでは、必要な plugin だけを `dependencies.apm` に追加します。
- 既存の repo ローカル marketplace には依存せず、APM を配布と再現性のための入口として使います。
- `apm.lock.yaml` は利用側プロジェクトで生成し、設定の再現性を担保します。

## 利用側プロジェクトの例

Codex 向けの全 plugin を使う場合:

```yaml
name: your-project
version: 1.0.0
target: codex

dependencies:
  apm:
    - rc-code-jp/ai-ops/plugins/agent-design-toolkit#main
    - rc-code-jp/ai-ops/plugins/planning-facilitator#main
    - rc-code-jp/ai-ops/plugins/git-ops-helper#main
    - rc-code-jp/ai-ops/plugins/ui-craft#main
```

Claude Code 向けに Agent Design Toolkit だけを使う場合:

```yaml
name: your-project
version: 1.0.0
target: claude

dependencies:
  apm:
    - rc-code-jp/ai-ops/plugins/agent-design-toolkit#main
```

Codex と Claude Code の両方で使う場合:

```yaml
name: your-project
version: 1.0.0
target:
  - codex
  - claude

dependencies:
  apm:
    - rc-code-jp/ai-ops/plugins/agent-design-toolkit#main
    - rc-code-jp/ai-ops/plugins/planning-facilitator#main
    - rc-code-jp/ai-ops/plugins/git-ops-helper#main
    - rc-code-jp/ai-ops/plugins/ui-craft#main
```

追加後に利用側プロジェクトで実行します。

```bash
apm install
```

## 確認

利用側プロジェクトで `apm install` を実行し、必要に応じて `apm audit` で依存内容を確認します。
`apm.lock.yaml` は利用側プロジェクトでコミットします。

## 今後の統合対象

- APM は plugin 配下の skills を利用側の target に合わせて配置します。
- ツール固有の挙動に依存する skill は、説明内で対象環境を明確にします。
- `config/` 配下の手動コピー手順は、APM で管理できる instructions や MCP 設定へ段階的に寄せます。
