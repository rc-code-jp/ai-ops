---
name: multi-agent-coordination
description: Claude の multi-agent coordination patterns に沿って、Codex で複数 agent の分担、検証ループ、agent teams、message bus、shared state のどれを使うべきか判断し、Codex での再現方法へ落とし込む。Codex の subagent 構成や複数 agent 運用を設計したいとき、Claude Code 利用者にも通じる5分類で説明したいときに使う。個別の SKILL.md 改善、custom agent TOML 単体レビュー、通常の PR レビューには使わない。
metadata:
  author: rc-code-jp
  version: 1.0.0
  category: agent-design
---

# Multi-Agent Coordination

Claude の記事で示された5つの coordination pattern を共通語彙として使い、Codex で実行可能な agent 運用へ変換する。

## 重要方針

- パターン名と説明の入口は記事の5分類に合わせる
- 実装説明は Codex の subagent / custom agent / workflow の制約に合わせる
- 単一 agent で十分なタスクを multi-agent 化しない
- `message bus` と `shared state` を Codex ネイティブ機能として断定しない
- coordination cost、競合、終了条件を先に確認する

## 対象

- Codex の subagent 分担設計
- custom agent を含む複数 agent の責務分割
- agent を使った検証ループ、並列調査、分割実装の運用案
- Claude Code 利用者にも説明しやすい coordination pattern の整理

## 手順

### 1. 単一 agent で足りるか判定する

入力: ユーザーのタスク、既存の agent / skill / repo 文脈
出力: multi-agent 化する理由

- まず単一 agent で完了できるか確認する
- multi-agent 化する場合は、理由を `品質保証`、`文脈分離`、`並列化`、`長時間の分割作業`、`イベント駆動`、`共有知識化` のどれかで説明する
- 理由が説明できない場合は、単一 agent または通常の skill / checklist で進める案を返す

### 2. 5パターンから選ぶ

入力: multi-agent 化する理由、タスク構造、依存関係
出力: 採用する coordination pattern

- 品質が重要で、評価基準を明文化できるなら `Generator-verifier` を選ぶ
- 親 agent が分解・委譲・統合でき、subtask が短く境界明確なら `Orchestrator-subagent` を選ぶ
- 独立 partition ごとに長めの作業を継続するなら `Agent teams` を選ぶ
- workflow が事前固定ではなく、event に応じて処理先が変わるなら `Message bus` を選ぶ
- 複数 agent が互いの発見を読み書きして知識を育てるなら `Shared state` を選ぶ

詳細な判断表は `references/pattern-decision-guide.md` を読む。

### 3. Codex での再現方法へ変換する

入力: 採用 pattern
出力: Codex で使う agent / state / external component の設計案

- `Generator-verifier`: 生成担当の `worker` と検証担当の `reviewer` / `verifier` を分け、親 Codex が最大反復回数、accept 条件、fallback を管理する
- `Orchestrator-subagent`: 親 Codex が計画と統合を担当し、`explorer`、`worker`、必要なら custom agent を明示的に spawn する
- `Agent teams`: 所有範囲を明確に分けた複数 `worker`、または CSV fan-out 相当の一括分散で再現する
- `Message bus`: 外部 queue、Issue、DB、webhook、状態ファイルなどを bus として設計し、Codex agent は producer / consumer / router として扱う
- `Shared state`: Markdown、JSON、SQLite、Issue、設計メモなどの共有ストアを決め、読み書きルール、lock / version、終了条件を明記する

### 4. 失敗条件を先に潰す

入力: Codex 向け設計案
出力: 実行前に必要な制約と注意点

- 同じファイルや同じ設定を複数 agent が編集しないように ownership を切る
- 子 agent へ渡す成果物と返却形式を明確にする
- `Message bus` では routing 失敗と追跡ログを設計する
- `Shared state` では反応ループ、重複作業、同時書き込み、終了条件を設計する
- `Agent teams` では完了検知と遅い worker の扱いを決める
- `Generator-verifier` では verifier の評価基準と最大反復回数を決める

### 5. 出力する

入力: 判断結果と制約
出力: 採用 pattern と Codex 実行案

- 先頭に採用 pattern を1つ示す
- 次に「記事の概念」「Codexでの再現」「必要な制約」「使わない理由」を短く分ける
- 複数 pattern の併用が必要な場合は、主 pattern と補助 pattern を分ける
- Codex で完全再現できない要素がある場合は、外部 component または疑似再現だと明記する

## 出力テンプレート

```md
## 採用パターン

- 主: Orchestrator-subagent
- 補助: Generator-verifier

## Codexでの再現

- 親 Codex が計画、委譲、統合を担当する
- `explorer` が読み取り調査、`worker` が実装、`reviewer` が検証を担当する

## 必須制約

- worker ごとに編集範囲を分ける
- verifier の評価基準と最大反復回数を先に決める

## 採用しないパターン

- Message bus: workflow が固定で、event-driven routing ではないため使わない
```

## 補足

- 5パターンの判断表と Codex での対応づけは `references/pattern-decision-guide.md` を参照する
- custom agent 定義そのものをレビューする場合は `codex-subagent-improver` を使う
- SKILL.md の発火境界や構成を改善する場合は `codex-skill-improver` を使う
