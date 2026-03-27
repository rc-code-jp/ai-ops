# Claude Skill Improver Best Practices

## 1. description は routing 文として書く

- 何ができるかの能力紹介ではなく、「いつ使うか」「いつ使わないか」を優先する
- 類似依頼で誤読込しやすいなら除外条件を書く
- 汎用語だけで終わらせず、対象物とタイミングを明示する

### 悪い例

```yaml
description: Improve documents
```

### 良い例

```yaml
description: Review a Claude Code skill definition and improve description, frontmatter, support-file layout, and invocation behavior. Use when optimizing SKILL.md for Claude Code or migrating a skill from another tool. Do not use for generic markdown proofreading or PR review.
```

## 2. frontmatter は少なく保つ

- `description` をまず整える
- `disable-model-invocation: true` は副作用を伴うワークフローや、Claude に自動実行させたくないスキルだけで使う
- `user-invocable: false` はユーザーが直接呼ぶ意味がない内部知識スキルだけで使う
- `allowed-tools` は必要最小限のホワイトリストにする
- `context: fork` と `agent` は、実行タスクが独立していて分離の利益がある場合だけ使う

## 3. slash command と自動読込を分けて考える

- `name` は `/skill-name` の体験に直結するため、短く自然な kebab-case にする
- slash command 専用にしたいなら `disable-model-invocation: true` を検討する
- 自動読込したいスキルは `description` に使用条件を具体化する

## 4. SKILL.md 本文は実行指示に寄せる

- 背景説明より、Claude が実際に取るべき行動を優先する
- ステップごとに入力と出力を明示する
- 「適切に」「必要なら」だけで進む曖昧な記述を減らす
- 期待する出力構成を明示する

## 5. 補助ファイルは SKILL.md から参照する

- `references/`、`examples/`、`scripts/` を置くだけでは不十分
- Claude が「いつ」「なぜ」そのファイルを読むかを `SKILL.md` に書く
- 長いチェックリストや例は本体に埋め込まず、補助ファイルへ逃がす

## 6. context: fork は強い機能として扱う

- 会話履歴が見えない前提で自己完結したタスクだけに使う
- ガイドライン共有や軽いレビューだけなら通常スキルで十分なことが多い
- `agent` を付けるなら、そのサブエージェント種別がなぜ合うかを説明できるようにする
