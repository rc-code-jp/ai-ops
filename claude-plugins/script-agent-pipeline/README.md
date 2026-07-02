# script-agent-pipeline (Claude 版)

Python スクリプトによる **安定したデータ取得・投稿** と、サブエージェント(LLM)による **判断・分析・文面作成** を組み合わせる 2 フェーズのパイプライン型スキルを提供するプラグインです。

## 動作の流れ

### フェーズ 1: 取得と分析

1. スキル発動 → 中央ディスパッチャ `run_task.py` がタスク(例: `stale_issues`)を実行し、結果を JSON エンベロープとして一時ファイルへ出力
2. 親 Claude は共通契約(`agent-contract.md`)+ フェーズ 1 契約(`phase1-analysis-contract.md`)と JSON のパスからサブエージェント 1 を起動
3. サブエージェント 1 は停滞タスクを **停滞タイプ(そもそも止まっている `never_started` / 途中で止まっている `stalled_in_progress` など)× ジャンル** の 2 軸で分類し、分析 JSON を実行フォルダ直下(`./<task>-analysis-YYYY-MM-DD.json`)へ出力

### フェーズ 2: 担当者宛コメントと md レポート(ユーザー承認後)

4. 親 Claude は分析 JSON のパスとフェーズ 2 契約(`phase2-comment-contract.md`)からサブエージェント 2 を起動
5. サブエージェント 2 は各タスクの担当者宛コメント文面を作成し、`run_task.py post_comments` で一括投稿(件ごとの成否とコメント URL を記録)
6. コメントしたタスクの一覧を md レポート(`./<task>-report-YYYY-MM-DD.md`)として実行フォルダ直下へ出力

取得・投稿の網羅性と記録はスクリプトが保証し、生データは親会話に載せず、判断はサブエージェントに閉じる、という役割分離が目的です。

## 収録タスク

| タスク | フェーズ | 用途 |
|---|---|---|
| `stale_issues` | 1(取得) | GitHub の open issue を全件取得し、N 日(既定 3 日)以上更新されていないものを抽出 |
| `post_comments` | 2(投稿) | サブエージェント 2 が作成した comments.json を issue へ一括投稿し、成否とコメント URL を返す |

## タスクの追加

`skills/script-agent/scripts/tasks/<task_name>.py` に `add_arguments(parser)` と `run(args) -> dict` を実装したモジュールを置くだけで、`run_task.py` が自動認識します。詳細は [SKILL.md](skills/script-agent/SKILL.md) の「新しいタスクの追加」を参照してください。

## 前提

- Python 3(標準ライブラリのみ、pip 依存なし)
- `stale_issues` / `post_comments` を使う場合: 認証済みの `gh` CLI(投稿にはコメント書き込み権限が必要)
