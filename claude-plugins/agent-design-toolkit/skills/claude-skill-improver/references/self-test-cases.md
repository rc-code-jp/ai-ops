# Claude Skill Improver Self Test Cases

## 目的

Claude Code 用スキル改善スキルの発火精度とレビュー品質を確認する。

## ケース 1: Claude 向けだが description が弱い

### 入力例

```yaml
---
name: review-skill
description: Improve skill
---
Review this skill.
```

### 期待

- `description` が曖昧で自動読込境界として弱いと指摘する
- 何を改善するスキルか、いつ使うか、何には使わないかを書き足す提案をする

## ケース 2: unsupported な前提を含む

### 入力例

```yaml
---
name: custom-review
description: Review custom skill
metadata:
  owner: team-a
---
Do the review.
```

### 期待

- Claude Code Skills の frontmatter として不要または unsupported な項目を明示する
- supported field に寄せるか、本文へ移す提案をする

## ケース 3: slash command 専用にすべき副作用スキル

### 入力例

```yaml
---
name: deploy-prod
description: Deploy the production environment
---
Deploy the app to production.
```

### 期待

- 副作用が強く、自動実行を避けるべきだと指摘する
- `disable-model-invocation: true` を提案する

## ケース 4: 補助ファイル構成があるが読ませ方がない

### 入力例

- `SKILL.md`
- `references/checklist.md`
- `scripts/validate.sh`

### 期待

- 補助ファイルの存在だけでなく、`SKILL.md` から読むタイミングや用途を明示するよう提案する

## ケース 5: Codex スキルの移植

### 入力例

- Codex 用スキルで `agents/openai.yaml` や Codex 固有用語が残っている

### 期待

- Claude Code では不要な構成や用語を指摘する
- `description`、frontmatter、support files を Claude Code に合わせて書き換える提案をする
