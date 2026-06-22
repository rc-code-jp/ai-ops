---
name: codex-subagent-improver
description: Codex の custom agent TOML をレビューし、委譲条件、責務境界、developer_instructions、出力仕様、権限、モデル設定を改善する。Codex の subagent 定義を見直したいとき、description が routing 文として弱いとき、役割が広すぎるとき、subagent 化の妥当性を再評価したいときに使う。通常の repo 用 AGENTS.md、一般的なコードレビュー、通常ドキュメントの校正には使わない。
metadata:
  author: rc-code-jp
  version: 0.1.0
  category: development-tooling
---

# Codex Subagent Improver

Codex の custom agent 定義を、実運用で安定して委譲される狭く明確な専門エージェントへ改善する。

## 重要方針

- 役割の広さより、委譲の正確さを優先する
- 「何ができるか」より「いつ呼ぶべきか」を明確にする
- スタイル改善より、routing、責務境界、出力安定性、安全性を優先する
- custom agent は `narrow and opinionated` に保つ
- subagent 化が本当に必要かを毎回検証する

## 対象

- Codex の custom agent TOML
- 関連する `AGENTS.md`
- サブエージェントの役割や分担を説明する設計メモ

## このスキルが特に重視する観点

- `description` が routing 文として読めるか
- `developer_instructions` だけで役割、優先順位、禁止事項、成功条件、返却形式が分かるか
- 役割に対して権限が最小化されているか
- タスク難易度に対してモデル設定が妥当か
- 親 agent が直接処理するより、文脈分離や並列化の利益があるか

## 手順

### 1. 対象と形式を特定する

- 定義本体と補助資料を切り分ける
- Codex なら `name`、`description`、`developer_instructions` を必ず確認する
- 関連する `AGENTS.md` があれば併読し、上位指示との整合を確認する
- 設計メモだけが渡された場合は、実際の定義へ落とすために不足している項目を補って評価する

### 2. 現状の役割を 2〜4 文で要約する

- 何を担当するか
- いつ呼ばれるべきか
- 何を返すべきか
- 要約できない場合は、その時点で定義が曖昧だと判断する

### 3. まず重大な欠陥を探す

- 役割が広すぎて routing できない
- 親 agent や他 agent と責務が衝突している
- 読み取り専門なのに編集権限を持つ
- 軽量モデルでは厳しい深いレビューを期待している
- 出力要求が曖昧で、返答品質が安定しない
- subagent 化の理由が説明できない

### 4. 共通レビューを行う

- `references/review-checklist.md` の共通観点を使い、役割、委譲条件、自己完結性、出力仕様、権限、モデル、保守性、subagent 化の妥当性を確認する
- findings は重大度順に整理する
- 軽微な文体指摘より、委譲失敗、責務衝突、出力不安定、安全性リスクを優先する

### 5. Codex 固有レビューを追加する

- `description` を「いつ使うか」の human-facing routing 文として読めるか確認する
- `developer_instructions` が行動指針、優先順位、禁止事項、返却形式を自己完結で持っているか確認する
- 必須項目は `name`、`description`、`developer_instructions` の3つとして扱う
- 任意設定は親セッションから継承される前提で、不要な `model`、`sandbox_mode`、`mcp_servers`、`skills.config` を増やしていないか確認する
- built-in agent の `default`、`worker`、`explorer` で十分ではないかを検討する
- `sandbox_mode` は職務に対して最小化されているか確認する
- `agents.max_depth` や過剰な再帰委譲を前提にした設計になっていないか確認する
- write-heavy で競合しやすい役割を無理に切り出していないか確認する

### 6. 改善方針を決める

- 役割が広すぎる場合は分割を提案する
- `description` が能力紹介寄りなら、使用場面中心の routing 文へ書き換える
- `developer_instructions` が曖昧なら、優先順位、禁止事項、成功条件、返却形式を追加する
- 権限やモデルが過剰なら必要最小限へ絞る
- subagent 化の価値が薄い場合は、親 agent へ戻す案を出す
- Codex では「狭い職務」「合った tool surface」「隣接業務へ drift しない指示」の3点を満たす形へ寄せる

### 7. 修正版を提示する

- findings を先に出す
- 共通問題と Codex 固有問題を分けて示す
- 各 finding で「重大度」「問題」「影響」「改善案」を短く示す
- 可能ならそのまま差し替えられる形で修正版を提示する
- 最後に、変更後にどう改善されるかと残るリスクを 1 段落でまとめる

## 出力ルール

- 先頭は必ず `## Findings` にする
- findings は重大度順に並べる
- 各 finding には少なくとも以下を含める
  - 重大度
  - 問題
  - 影響
  - 改善案
- 修正版はそのまま定義へ反映できる粒度で書く
- 問題がない場合も、残る運用リスクと検証不足を明示する

## Codex の最新公式仕様として前提に置くこと

- Codex は subagent を明示的に依頼されたときだけ spawn する
- subagent は親の sandbox と approval の設定を継承する
- custom agent ファイルは `~/.codex/agents/` または `.codex/agents/` に置く
- custom agent の必須項目は `name`、`description`、`developer_instructions`
- 任意項目を省略した場合は親セッションから継承される
- global 設定は `[agents]` にあり、`max_threads` と `max_depth` の既定値前提で設計する
- 深い再帰委譲は token、latency、predictability の悪化要因として扱う

## 改善時の着眼点

- `description` は routing 文か、それとも単なる能力紹介か
- `developer_instructions` だけで、役割、優先順位、禁止事項、成功条件、返却形式が分かるか
- reviewer や researcher が不要な編集権限を持っていないか
- 深いレビューや設計判断に軽すぎるモデルを当てていないか
- 親 agent と subagent の責務境界が一文で言えるか
- subagent 化の理由が文脈分離か並列化かで説明できるか
- built-in agent で十分な役割を、不要に custom 化していないか

## 補足

- 詳細なレビュー観点、アンチパターン、改善テンプレートは `references/review-checklist.md` を参照する
- 元資料が設計メモだけなら、実際の定義へ落とすときに不足する `description`、`developer_instructions`、権限、出力仕様まで補って提案する
