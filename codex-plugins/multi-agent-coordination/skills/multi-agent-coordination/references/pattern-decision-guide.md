# Multi-Agent Coordination Pattern Decision Guide

Claude の記事に合わせた5分類を、Codex での再現方法として使うための判断表。

## 判断表

| パターン | 使う場面 | Codexでの再現 | 実現度 |
|---|---|---|---|
| `Generator-verifier` | 品質が重要で、評価基準を明文化できる | 生成担当 `worker` と検証担当 `reviewer` / `verifier` を分け、親 Codex が反復と fallback を管理する | 高 |
| `Orchestrator-subagent` | 分解しやすい短い subtask を親 agent が統合する | 親 Codex が計画・委譲・統合し、`explorer` / `worker` / custom agent を明示 spawn する | 高 |
| `Agent teams` | 独立 partition ごとに長めの作業を並列に進める | 所有範囲を分けた複数 `worker`、または CSV fan-out 相当で再現する | 中〜高 |
| `Message bus` | event に応じて処理先が変わり、agent の種類が増えそう | 外部 queue、Issue、DB、webhook、状態ファイルを bus として使う | 中 |
| `Shared state` | agent が互いの発見を読み書きして知識を育てる | Markdown、JSON、SQLite、Issue、設計メモを共有ストアにする | 中 |

## Pattern 1: Generator-verifier

### 記事の概念

生成役が出力を作り、検証役が明示的な基準で評価する。失敗したら検証 feedback を生成役へ戻し、上限回数まで繰り返す。

### Codexでの再現

- `worker` または custom generator が実装、文書、回答案を作る
- `reviewer`、`verifier`、または読み取り専用 custom agent が評価する
- 親 Codex が `accept 条件`、`最大反復回数`、`fallback` を管理する

### 必須制約

- verifier の評価基準を先に書く
- feedback は修正可能な粒度で返す
- 最大反復回数を決める
- 収束しない場合の扱いを決める

### 避ける場面

- 評価基準が主観的で、検証が生成と同じくらい難しい
- 追加の検証 token / latency に見合う品質リスクがない

## Pattern 2: Orchestrator-subagent

### 記事の概念

親 agent がタスクを分解し、subagent に委譲し、返却結果を統合する。

### Codexでの再現

- 親 Codex が全体目的、計画、統合、最終判断を担当する
- `explorer` は読み取り調査、`worker` は実装、custom agent は専門的な検証や調査を担当する
- subagent は短く境界明確な task を処理し、結果を要約して返す

### 必須制約

- subagent に渡す task は自己完結にする
- 返却形式と evidence を指定する
- 並列化できる task だけ並列にする
- 親 Codex が情報の bottleneck になることを前提に、重要な発見は明示的に統合する

### 避ける場面

- subagent 間で頻繁な中間共有が必要
- 役割分割より context handoff の損失が大きい
- 単一 agent で十分に完了できる

## Pattern 3: Agent teams

### 記事の概念

複数 worker が独立 process として長めに作業し、各 worker が domain context を持続的に蓄積する。

### Codexでの再現

- repository、service、package、file group などで ownership を分ける
- 各 `worker` に編集範囲と完了条件を渡す
- 多数の類似 task なら CSV fan-out 相当の一括分散として扱う
- coordinator は統合作業と全体検証を担当する

### 必須制約

- worker ごとの write scope を重複させない
- 共通ファイル、schema、lockfile など競合しやすい領域を親 Codex が管理する
- 完了検知と遅い worker の扱いを決める
- 統合テストを最後に実行する

### 避ける場面

- partition 間の依存が強い
- 複数 worker が同じファイルを編集する
- 中間発見を頻繁に共有しないと破綻する

## Pattern 4: Message bus

### 記事の概念

agent が topic に publish / subscribe し、router が event を適切な agent へ配送する。

### Codexでの再現

Codex 単体のネイティブ機能として扱わない。外部 component を bus として設計する。

- queue、Issue、DB、webhook、状態ファイルを message bus として使う
- agent は producer、consumer、router、enricher、responder などの役割を持つ
- event schema、topic、correlation id、retry、dead-letter 相当を設計する

### 必須制約

- routing の根拠とログを残す
- event drop や誤分類の扱いを決める
- replay と idempotency を検討する
- Codex agent が処理する範囲と外部 system が処理する範囲を分ける

### 避ける場面

- workflow が固定で、親 Codex が順番に委譲すれば足りる
- event の種類が少なく、router を持つほど拡張性が必要ない
- 追跡性や再実行性を設計できない

## Pattern 5: Shared state

### 記事の概念

中央 coordinator ではなく、複数 agent が共有ストアを直接読み書きして協調する。

### Codexでの再現

- Markdown、JSON、SQLite、Issue、設計メモなどを共有ストアにする
- 各 agent は担当観点の発見、根拠、未解決事項、次の探索候補を書き込む
- 親 Codex または designated agent が終了条件を判定する

### 必須制約

- lock、version、ownership、merge rule を決める
- 同じ調査の重複を避けるため task claim を設ける
- 反応ループを防ぐため、時間予算、cycle 上限、収束条件を決める
- 共有ストアに書く schema を簡潔に固定する

### 避ける場面

- agent が互いの発見を読む必要がない
- 共有ストアの競合解決を設計できない
- 終了条件を決められない

## 推奨順

迷った場合は次の順で検討する。

1. 単一 agent で足りるか
2. `Orchestrator-subagent` で足りるか
3. 品質保証が主目的なら `Generator-verifier` を足す
4. 独立 partition が多いなら `Agent teams` に寄せる
5. event-driven なら `Message bus` を外部 component として設計する
6. 発見を蓄積し相互参照するなら `Shared state` を共有ストアとして設計する

## 参考資料

- Claude Blog: https://claude.com/blog/multi-agent-coordination-patterns
- Codex Skills: https://developers.openai.com/codex/skills
- Codex Subagents: https://developers.openai.com/codex/subagents
