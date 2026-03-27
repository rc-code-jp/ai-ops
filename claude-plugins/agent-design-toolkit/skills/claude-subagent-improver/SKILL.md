---
name: claude-subagent-improver
description: Claude Code の custom sub-agent 定義をレビューし、公式仕様に沿って description の委譲文、system prompt の自己完結性、サポート済み frontmatter、tools と disallowedTools、permissionMode、skills、mcpServers、hooks、memory、background、effort、isolation を改善する。Claude Code のサブエージェントを公式準拠で見直したいとき、description が委譲文として弱いとき、unsupported な前提や過剰設定を削りたいとき、built-in agent やメイン会話で十分かを再評価したいときに使う。通常の AGENTS.md レビュー、一般的なコードレビュー、単なる Markdown 校正には使わない。
---

# Claude Subagent Improver

Claude Code の custom sub-agent 定義を、Claude Code 公式仕様に忠実で、実運用で安定して委譲されるサブエージェントへ改善する。

## 重要方針

- Claude Code の公式ドキュメントに書かれている仕様を最優先にする
- 推測で frontmatter や挙動を補わず、明記されたフィールドと相互作用だけで評価する
- `description` を自動委譲の主要面として扱い、能力紹介より委譲条件を優先する
- 本文は独立した system prompt として扱い、親の完全な system prompt を前提にしない
- built-in agent やメイン会話で十分なら、無理に custom sub-agent 化しない

## 対象

- Claude Code の sub-agent Markdown 定義
- 関連する `AGENTS.md`
- サブエージェントの役割や分担を説明する設計メモ

## このスキルが特に重視する観点

- `description` が routing 文として読めるか
- 本文の system prompt だけで役割、優先順位、禁止事項、成功条件、返却形式が分かるか
- サポート済み frontmatter だけを使っているか
- `tools` と `disallowedTools` が職務に対して最小化されているか
- `permissionMode`、`model`、`effort`、`maxTurns` が過不足ないか
- `skills`、`mcpServers`、`memory`、`hooks`、`background`、`isolation` に過剰設定がないか
- custom sub-agent 化の理由を context isolation、制約強制、再利用、コスト制御のいずれかで説明できるか

## 手順

### 1. 対象と形式を特定する

- 定義本体と補助資料を切り分ける
- Claude Code なら YAML frontmatter の `name` と `description`、および本文の system prompt を必ず確認する
- Markdown ファイル定義なのか、`--agents` で渡す JSON 定義なのかを区別する
- 関連する `AGENTS.md` があれば併読し、上位指示との整合を確認する
- 設計メモだけが渡された場合は、実際の定義へ落とすために不足している項目を補って評価する

### 2. 現状の役割を 2〜4 文で要約する

- 何を担当するか
- いつ呼ばれるべきか
- 何を返すべきか
- 要約できない場合は、その時点で定義が曖昧だと判断する

### 3. まず重大な欠陥を探す

- 役割が広すぎて routing できない
- 親会話や他 agent と責務が衝突している
- 読み取り中心なのに編集や破壊的操作の権限を持つ
- system prompt が親の暗黙文脈に依存している
- 公式にない frontmatter や曖昧な独自ルールを前提にしている
- 出力要求が曖昧で返答品質が安定しない
- built-in agent やメイン会話で十分なのに custom 化している

### 4. 共通レビューを行う

- `references/review-checklist.md` の共通観点を使い、役割、委譲条件、自己完結性、出力仕様、権限、モデル、保守性、sub-agent 化の妥当性を確認する
- findings は重大度順に整理する
- 軽微な文体指摘より、委譲失敗、責務衝突、出力不安定、安全性リスクを優先する

### 5. Claude Code 固有レビューを追加する

- `description` を「いつ使うか」の routing 文として読めるか確認する
- `description` に必要なら `use proactively` のような自動委譲促進句を入れるべきか確認する
- 本文が system prompt として自己完結しているか確認する
- `name` が小文字とハイフンによる自然な識別子になっているか確認する
- frontmatter が `name`、`description`、`tools`、`disallowedTools`、`model`、`permissionMode`、`maxTurns`、`skills`、`mcpServers`、`hooks`、`memory`、`background`、`effort`、`isolation` の範囲に収まっているか確認する
- `tools` と `disallowedTools` が許可リストまたは拒否リストとして明快に使われているか確認する
- `tools` と `disallowedTools` を併用している場合、`disallowedTools` が先に適用される前提に矛盾がないか確認する
- `permissionMode` が親の権限継承と衝突しないか確認する
- 親が `bypassPermissions` または自動モードのときの上書き不能条件を前提にしているか確認する
- `model`、`effort`、`maxTurns` が役割に対して妥当か確認する
- `skills` が本当にプリロードすべき内容だけに絞られているか確認する
- `mcpServers`、`hooks`、`memory`、`background`、`isolation` が必要性を説明できるか確認する
- scope と優先順位が整理されているか確認する
- built-in agent や `/agents` による管理で十分ではないかを検討する
- Claude Code の sub-agent は他の sub-agent を生成できない前提で設計されているか確認する
- セッション開始時の読込、手動追加時の再起動または `/agents` での再読込前提に矛盾がないか確認する

### 6. 改善方針を決める

- 役割が広すぎる場合は分割を提案する
- `description` が能力紹介寄りなら、使用場面中心の routing 文へ書き換える
- unsupported な field や曖昧な独自用語は、正式 field または本文の明示指示へ置き換える
- system prompt が曖昧なら、優先順位、禁止事項、成功条件、返却形式を追加する
- 権限、モデル、努力量が過剰なら必要最小限へ絞る
- sub-agent 化の価値が薄い場合は、built-in agent またはメイン会話へ戻す案を出す
- Claude Code では「公式 field の範囲内」「自己完結した prompt」「最小権限」「分離実行の利益」の 4 点を満たす形へ寄せる

### 7. 修正版を提示する

- findings を先に出す
- 共通問題と Claude Code 固有問題を分けて示す
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

## Claude Code の公式仕様として前提に置くこと

- sub-agent 定義は YAML frontmatter を持つ Markdown ファイルである
- 必須項目は `name` と `description` である
- 本文は sub-agent の system prompt として扱われる
- sub-agent は親の完全な Claude Code system prompt を受け取らず、system prompt と基本的な環境詳細だけで動く
- `--agents` の CLI JSON 定義では system prompt に `prompt` を使う
- `tools` と `disallowedTools` で利用可能なツールを制御できる
- `disallowedTools` が先に適用され、その後 `tools` が残りのプールに対して解決される
- `model`、`permissionMode`、`maxTurns`、`skills`、`mcpServers`、`hooks`、`memory`、`background`、`effort`、`isolation` を frontmatter で設定できる
- `skills` は親会話から継承されず、指定したものだけが完全な内容で注入される
- built-in agent、project scope、user scope、CLI 定義の優先順位を踏まえて設計する
- `description` は自動委譲判断に使われ、必要なら `use proactively` のような句で積極委譲を促進できる
- `permissionMode` は親権限コンテキストを継承しつつ上書きできるが、親の `bypassPermissions` や自動モードが優先される場合がある
- sub-agent は他の sub-agent を生成できない
- sub-agent は、メイン会話で不要な詳細を隔離したいとき、特定のツール制限や権限を強制したいとき、自己完結した作業を任せたいときに向く
- サブエージェントファイルはセッション開始時に読み込まれ、手動追加時は再起動または `/agents` による再読込が必要である

## 改善時の着眼点

- `description` は routing 文か、それとも単なる能力紹介か
- `description` だけで、Claude がいつ委譲すべきか判断できるか
- system prompt だけで、役割、優先順位、禁止事項、成功条件、返却形式が分かるか
- frontmatter が公式にサポートされた field のみに収まっているか
- reviewer や researcher が不要な編集権限を持っていないか
- 深いレビューや設計判断に軽すぎるモデルを当てていないか
- `skills` のプリロードが肥大化していないか
- `mcpServers` や `memory` や `isolation` が目的化していないか
- built-in agent やメイン会話の方が自然な役割を、不要に custom 化していないか

## 補足

- 詳細なレビュー観点、アンチパターン、改善テンプレートは `references/review-checklist.md` を参照する
- 元資料が設計メモだけなら、実際の定義へ落とすときに不足する `description`、system prompt、権限、出力仕様まで補って提案する
