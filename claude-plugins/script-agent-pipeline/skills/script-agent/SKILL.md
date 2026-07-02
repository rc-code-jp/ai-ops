---
name: script-agent
description: Python スクリプトで安定的にデータを取得し、サブエージェント(LLM)で分析・アクションする 2 フェーズのパイプライン型スキル。「script-agent で」「stale な issue を洗い出して」「3日以上更新されていない issue を見つけて」「停滞タスクにリマインドコメントして」など、登録済みタスクに合致する依頼で発動する。データ取得・投稿はスクリプト、判断はサブエージェントに分離することが目的。
---

# Script Agent Pipeline

このスキルは、**確定的な処理(データ取得・コメント投稿)を Python スクリプト** に、**判断が必要な処理(分析・分類・文面作成)をサブエージェント** に分離する 2 フェーズのパイプラインです。

```
[親 Claude]
 │ ① 依頼からタスクとパラメータを決定
 │ ② run_task.py <task> を実行 ──► 結果 JSON を一時ファイルへ出力
 │ ③ サマリ(stats)を確認
 │
 │ ──── フェーズ 1: 分析 ────
 │ ④ Agent ツールで起動 ──────► [サブエージェント 1 (general-purpose)]
 │    共通契約 + フェーズ1契約        │ ⑤ 結果 JSON を Read
 │    + 結果JSONパス + 分析指示       │ ⑥ 停滞タスクを分類
 │                                   │    (stall_type × genre)
 │ ⑧ 分析JSONパスとサマリを受領 ◄──── │ ⑦ 分析 JSON を実行フォルダ直下へ Write
 │ ⑨ ユーザーに内訳を報告し、
 │    フェーズ 2(コメント投稿)の実施を確認
 │
 │ ──── フェーズ 2: コメント投稿(承認後) ────
 │ ⑩ Agent ツールで起動 ──────► [サブエージェント 2 (general-purpose)]
 │    共通契約 + フェーズ2契約        │ ⑪ 分析 JSON を Read
 │    + 分析JSONパス + 投稿範囲       │ ⑫ 担当者宛コメント文面を作成 → comments.json
 │                                   │ ⑬ run_task.py post_comments で一括投稿
 │ ⑮ mdパスと投稿結果を受領 ◄──────── │ ⑭ md レポートを実行フォルダ直下へ Write
 │ ⑯ ユーザーに報告
```

分離する理由:

- **取得・投稿の安定性**: API のページングや一括投稿は LLM にやらせると漏れる。スクリプトなら毎回同じ結果になり、成否も記録される
- **コンテキスト保護**: 生データ(全 issue など)を親会話に読み込まない。サブエージェントだけが JSON 全文を読む
- **判断の質**: サブエージェントは契約で「JSON を唯一の事実ソースとする」よう拘束され、捏造や取りこぼしを防ぐ

## 1. 発動条件

- 「script-agent で〜」と明示されたとき
- 登録済みタスクに合致する依頼のとき(例: 「3日以上更新されていない issue を洗い出して」→ `stale_issues`)

登録済みタスクの一覧は `python3 {SCRIPTS_DIR}/run_task.py --list` で確認できます。合致するタスクが無い依頼には発動せず、通常の手順で対応するか、必要なら「6. 新しいタスクの追加」に従ってタスクを追加します。

フェーズ 2(コメント投稿)まで進むのは、ユーザーが「リマインドして」「コメントを残して」等を依頼した場合のみです。「洗い出して」だけの依頼はフェーズ 1 で止めます。

## 2. パス解決

SKILL.md 自身の絶対パスを基準に解決してください。環境変数 `CLAUDE_PLUGIN_ROOT` が定義されていれば `${CLAUDE_PLUGIN_ROOT}/skills/script-agent/...` を優先します。

| 記号 | 実体 |
|---|---|
| `{SCRIPTS_DIR}` | `<SKILL.md と同じディレクトリ>/scripts` |
| `{RUN_TASK_PATH}` | `{SCRIPTS_DIR}/run_task.py` |
| `{CONTRACT_COMMON}` | `<SKILL.md と同じディレクトリ>/references/agent-contract.md` |
| `{CONTRACT_PHASE1}` | `<SKILL.md と同じディレクトリ>/references/phase1-analysis-contract.md` |
| `{CONTRACT_PHASE2}` | `<SKILL.md と同じディレクトリ>/references/phase2-comment-contract.md` |
| `{TMP_DIR}` | セッションのスクラッチパッド配下(例: `<scratchpad>/script-agent/`) |
| `{DATA_JSON}` | `{TMP_DIR}/<task>-data-<timestamp>.json`(スクリプトの取得結果。**リポジトリ内に置かない**) |
| `{ANALYSIS_JSON}` | 実行フォルダ直下 `./<task>-analysis-YYYY-MM-DD.json`(フェーズ 1 の成果物) |
| `{REPORT_MD}` | 実行フォルダ直下 `./<task>-report-YYYY-MM-DD.md`(フェーズ 2 の成果物) |

生データ(`{DATA_JSON}`)と作業ファイル(comments.json 等)は一時領域、ユーザー向け成果物(`{ANALYSIS_JSON}` / `{REPORT_MD}`)は実行フォルダ(カレントディレクトリ)直下、という使い分けです。

## 3. フェーズ 1: 取得と分析

### 3.1 タスクとパラメータの決定

依頼文からタスク名と引数を決めます。不足していて推測できないパラメータ(対象リポジトリなど)だけユーザーに確認します。カレントリポジトリの issue の話であれば `git remote get-url origin` から `owner/repo` を導出して構いません。

### 3.2 スクリプト実行

```bash
python3 {RUN_TASK_PATH} <task> <タスク固有引数...> --output {DATA_JSON}
```

- stdout にはサマリ(`ok` / `stats` / 出力パス)だけが返ります。**親 Claude は JSON 本体を Read しないでください**
- `ok: false` またはコマンド失敗時は、サブエージェントを起動せず、エラー内容(gh 未認証・リポジトリ名誤りなど)をユーザーに報告します
- `stats` が空振り(例: 対象 0 件)なら、サブエージェントを起動せずその旨を報告して終了します

### 3.3 サブエージェント 1 の起動

`Agent` ツールで `general-purpose` サブエージェントを 1 つ起動します。

```
まず次の 2 ファイルを Read し、書かれている契約に従ってください:
- 共通契約: {CONTRACT_COMMON}
- フェーズ 1 契約(分析・分類・JSON 出力): {CONTRACT_PHASE1}

分析対象の結果 JSON(絶対パス):
{DATA_JSON}

分析 JSON の出力先(絶対パス):
{ANALYSIS_JSON}

## タスク固有の分析指示
{TASK_INSTRUCTIONS}
```

`{TASK_INSTRUCTIONS}` にはユーザーの依頼の文脈(何を知りたいか・どんな観点で分類・判断してほしいか)を反映します。`stale_issues` の場合の例:

```
- 各 issue をフェーズ 1 契約の 2 軸(stall_type × genre)で分類する
- 「担当者未設定」「マイルストーン期限が近い/過ぎている」ものは recommended_action で優先度を上げる
- comment_focus には、担当者に確認すべき具体的なポイントを書く
```

### 3.4 フェーズ 1 の報告と分岐

サブエージェント 1 から分析 JSON のパスと内訳サマリを受け取り、ユーザーに報告します(stall_type 別・genre 別の件数、深刻な上位数件)。

- ユーザーの依頼が分析までなら、ここで終了
- コメント投稿まで依頼されている場合でも、**投稿はリポジトリ上で外部に見える操作のため、フェーズ 2 の開始前に「対象件数と投稿範囲(全件か、特定の stall_type のみか)」を一度ユーザーに確認** します。最初の依頼で範囲まで明示されている場合(「全部にリマインドして」等)は確認を省略できます

## 4. フェーズ 2: コメント投稿と md レポート

### 4.1 サブエージェント 2 の起動

```
まず次の 2 ファイルを Read し、書かれている契約に従ってください:
- 共通契約: {CONTRACT_COMMON}
- フェーズ 2 契約(コメント投稿・md レポート): {CONTRACT_PHASE2}

フェーズ 1 の分析 JSON(絶対パス):
{ANALYSIS_JSON}

run_task.py(絶対パス):
{RUN_TASK_PATH}

作業ファイル用ディレクトリ:
{TMP_DIR}

md レポートの出力先(絶対パス):
{REPORT_MD}

## 投稿対象の範囲
{SCOPE}(例: 「issues 全件」「stall_type が never_started のもののみ」)

## 追加の指示
{TASK_INSTRUCTIONS}(コメントのトーンや強調点への要望があれば)
```

サブエージェント 2 は契約に従い、文面作成 → `run_task.py post_comments` で一括投稿 → md レポート出力までを行います。

### 4.2 フェーズ 2 の報告

サブエージェント 2 から md レポートのパスと投稿結果(成功/失敗件数)を受け取り、ユーザーに報告します。失敗があった issue は番号と原因を添えます。

## 5. 禁止事項

- 親 Claude が `{DATA_JSON}` / `{ANALYSIS_JSON}` を自分で Read して自分で分析すること(必ずサブエージェント経由)
- スクリプトを使わずに `gh` や API を親 Claude が直接叩いてデータ取得・コメント投稿をすること
- ユーザーがコメント投稿を依頼していないのにフェーズ 2 へ進むこと
- サブエージェントの戻り値に含まれない事実を親 Claude が付け足すこと
- `{DATA_JSON}` などの一時ファイルを作業リポジトリ内に書き出すこと(実行フォルダ直下に置くのは `{ANALYSIS_JSON}` と `{REPORT_MD}` だけ)

## 6. 新しいタスクの追加

`{SCRIPTS_DIR}/tasks/<task_name>.py` を追加するだけで `run_task.py` が自動認識します。モジュール契約:

```python
def add_arguments(parser):  # argparse にタスク固有引数を追加
    ...

def run(args) -> dict:  # {"params": dict, "stats": dict, "data": list|dict} を返す
    ...
```

設計ルール:

- **判断を入れない**: スクリプトは取得・機械的なフィルタ・集計・投稿まで。「重要か」「何を書くか」の判断はサブエージェントの領分
- **追加 pip 依存を持たない**: 標準ライブラリ + 認証済み CLI(`gh` など)の subprocess 呼び出しで完結させる
- **data はサブエージェントが読む前提で絞る**: 全フィールドを渡さず、判断材料になるものだけ含める。本文などの長文は先頭 N 文字に切る
- **全体像は stats に残す**: data を閾値でフィルタしても、母数(全件数)は stats に含めて報告の正確性を担保する
- **書き込み系タスクは 1 件の失敗で全体を止めない**: `post_comments` のように件ごとの成否を data に記録して返す

## 7. 登録済みタスク

| タスク | フェーズ | 用途 | 主な引数 |
|---|---|---|---|
| `stale_issues` | 1(取得) | GitHub の open issue から N 日以上未更新のものを抽出 | `--repo owner/repo`(必須)、`--days N`(既定 3) |
| `post_comments` | 2(投稿) | comments.json の内容を issue へ一括投稿(サブエージェント 2 が呼ぶ) | `--repo owner/repo`、`--comments-file path` |

---

### 例

良い例(フェーズ 2 まで):

> ユーザー: 「3 日以上止まってる issue を洗い出して、担当者にリマインドコメントして」
>
> アシスタント:
> 1. `run_task.py stale_issues --repo owner/repo --days 3 --output {DATA_JSON}` → `stats: {open_issues_total: 42, stale_issues: 7}`
> 2. サブエージェント 1 起動 → `./stale_issues-analysis-2026-07-02.json` に分類結果(未着手 3 / 途中停止 4)
> 3. 「7 件が停滞しています(未着手 3、途中停止 4)。7 件全件にリマインドコメントを投稿してよいですか?」と確認
> 4. 承認後、サブエージェント 2 起動 → 投稿 7 件成功 → `./stale_issues-report-2026-07-02.md`
> 5. 「7 件すべてにコメントしました。レポート: ./stale_issues-report-2026-07-02.md」と報告

悪い例(確認なしで投稿):

> アシスタント: (分析後、ユーザーに件数も範囲も確認せず 30 件の issue へ一斉にコメント投稿する)
>
> 問題: リポジトリの全員に見える通知が大量に飛ぶ。範囲確認は投稿前に必須。

悪い例(親が直接操作):

> アシスタント: (`gh issue comment` を親 Claude が 1 件ずつ実行し、投稿結果の記録を残さない)
>
> 問題: 途中失敗時にどこまで投稿したか分からなくなる。投稿は `post_comments` タスク経由が必須。
