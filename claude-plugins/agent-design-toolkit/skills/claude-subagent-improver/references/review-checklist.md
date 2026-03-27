# Claude Subagent Improver Review Checklist

## 1. 役割と routing

- `description` が「何が得意か」ではなく「いつ委譲すべきか」を示しているか
- 類似する他 agent やメイン会話との責務衝突がないか
- 一文で役割境界を説明できるか

## 2. system prompt の自己完結性

- 本文だけで役割、優先順位、禁止事項、成功条件、返却形式が分かるか
- 親会話の暗黙了解やメイン agent の振る舞いに依存していないか
- 「必要に応じて」だけで判断を丸投げしていないか

## 3. frontmatter の適法性

- `name` と `description` があるか
- 使っている field が Claude Code でサポートされている範囲か
- 独自メタデータを unsupported な frontmatter として持ち込んでいないか

## 4. 権限とツール

- `tools` と `disallowedTools` が職務に対して最小化されているか
- 読み取り専用の役割なのに編集系ツールが許可されていないか
- `permissionMode` が親の安全方針と衝突していないか

## 5. モデルと effort

- 役割の難易度に対して `model` と `effort` が過不足ないか
- 単純な抽出係に重すぎる設定を使っていないか
- 深いレビューに軽すぎる設定を当てていないか

## 6. 追加機能の妥当性

- `skills` のプリロードに本当に意味があるか
- `mcpServers`、`hooks`、`memory`、`background`、`isolation` の必要性を説明できるか
- 設定が目的化して複雑性だけ増やしていないか

## 7. custom sub-agent 化の妥当性

- built-in agent やメイン会話で代替できない理由があるか
- 文脈隔離、権限制御、再利用性、コスト制御のどれで価値を説明できるか
- sub-agent がさらに別 sub-agent を必要とする前提になっていないか
