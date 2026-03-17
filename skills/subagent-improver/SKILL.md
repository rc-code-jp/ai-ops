---
name: subagent-improver
description: Claude Code と Codex のサブエージェント定義をレビューし、委譲条件、責務境界、指示本文、出力仕様、権限、モデル選定を改善する。Claude Code の Markdown 定義、Codex の TOML 定義、関連する補助資料を見直したいとき、ルーティングが弱いとき、役割が広すぎるとき、プロンプトが曖昧で運用が不安定なときに使う。通常の repo 用 AGENTS.md、一般的なコードレビュー、通常ドキュメントの校正には使わない。
---

# Subagent Improver

サブエージェント定義を、実運用で安定して委譲される専門エージェントへ改善する。

## 基本方針

- 役割の広さより、委譲の正確さを優先する
- 共通観点で設計品質を見たうえで、Codex 固有観点と Claude 固有観点を追加で確認する
- 定義ファイル単体で自己完結する状態を目指す
- スタイル改善より、ルーティング、出力品質、安全性、保守性を優先する
- 形式差よりも、役割、委譲、指示、出力、権限、モデル、保守性、subagent 化の妥当性を重視する

## 対象

- Claude Code のサブエージェント定義 Markdown
- Codex のサブエージェント定義 TOML
- `AGENTS.md` のうち、Codex エージェントの恒久指示として関連するもの
- サブエージェントの役割や指示を説明する設計メモ

## 手順

### 1. 対象と形式を特定する

- どのファイルが定義本体で、どのファイルが補助資料かを切り分ける
- Claude Code なら Markdown の frontmatter と本文を読む
- Codex なら TOML の `name`、`description`、`developer_instructions` を読む
- Codex では関連する `AGENTS.md` があれば併読し、恒久指示との整合も確認する
- 設計メモだけが渡された場合は、「実際の `SKILL.md` に落とすと何が必要か」を補って評価する

### 2. 現状の役割を要約する

- Claude Code では `description` が委譲条件、Markdown 本文が指示本体として機能しているかを要約する
- Codex では `description` が委譲条件、`developer_instructions` が指示本体として機能しているかを要約する
- どちらも 2〜4 文で「何を担当し、いつ呼ばれ、何を返すか」をまとめる
- 要約できない場合は、定義が曖昧だと判断する

### 3. 共通レビューを行う

- `references/review-checklist.md` の共通観点を使い、以下を確認する
- 役割の明確さ
- 委譲条件の明確さ
- 指示の自己完結性
- 出力仕様の具体性
- 権限設計の妥当性
- モデル選択の妥当性
- 保守性と可読性
- subagent 化の妥当性
- まず重大な欠陥を探す
- その後、発火精度や運用品質を下げる曖昧さを探す
- 最後に、冗長さや保守性の問題を拾う

### 4. Codex 固有レビューまたは Claude 固有レビューを行う

- Codex では TOML 定義の整理、`description` と `developer_instructions` の役割分担、`AGENTS.md` との整合、narrow and opinionated 性、並列化や文脈分離との相性を確認する
- Claude Code では frontmatter の妥当性、`description` の委譲条件品質、Markdown 本文の system prompt 品質、`tools` / `disallowedTools` / `model` の妥当性、Markdown 構造の保守性を確認する
- 形式固有の問題は、共通観点の問題と混ぜずに切り分けて記録する

### 5. 改善方針を決める

- 役割が広すぎる場合は分割を提案する
- `description` や委譲条件が弱い場合は、「何ができるか」ではなく「いつ使うか」に書き換える
- Claude Code の本文や Codex の `developer_instructions` が曖昧な場合は、優先順位、禁止事項、成功条件、返却形式を追加する
- 権限やモデルが過剰な場合は、必要最小限へ絞る
- Codex で `AGENTS.md` と衝突する場合は、エージェント側で再定義すべき事項と上位指示へ委ねる事項を切り分ける
- サブエージェント化自体の価値が薄い場合は、親エージェントへ戻す案も出す

### 6. 修正版を提示する

- findings を重大度順に列挙する
- 共通問題と形式固有問題を区別して示す
- 各 finding で、問題、影響、改善方針を短く示す
- 可能なら Claude Code では frontmatter と本文、Codex では TOML の各キーを直接差し替えられる形で提示する
- 変更後にどう改善されるかを 1 段落でまとめる

## 出力ルール

- findings を先に出す
- 軽微な文体指摘より、委譲失敗、責務衝突、出力不安定、安全性リスクを優先する
- 各 finding には、少なくとも「重大度」「問題」「影響」「改善案」を含める
- 修正案はそのまま定義へ反映できる粒度で書く
- 最後に「総評」を付け、変更後に期待できる改善と残るリスクをまとめる
- 問題がない場合も、残る運用リスクと検証不足を明示する

## 改善時の着眼点

- `description` は routing 文として読めるか
- Claude Code では本文、Codex では `developer_instructions` だけで、役割、優先順位、禁止事項、成功条件、返却形式が分かるか
- Codex では `description` と `developer_instructions` の役割分担が明確か
- Claude Code では frontmatter と本文の役割分担が明確か
- reviewer なのに編集権限を持つなど、役割と権限が食い違っていないか
- 深い推論が必要な役割に軽すぎるモデルを当てていないか
- Codex では `AGENTS.md` の恒久指示とエージェント定義が衝突していないか
- その役割は本当にサブエージェントとして分離する価値があるか

## 補足

- 詳細なレビュー観点、アンチパターン、改善テンプレートは `references/review-checklist.md` を参照する
- 元資料が設計メモだけなら、その内容から「実際の定義へ落とすと何が必要か」を補って提案する
