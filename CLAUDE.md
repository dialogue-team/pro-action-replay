# pro-action-replay

ISUCONの高速化TIPS、すぐ使える設定集、複数人/複数エージェントで衝突しない検証の仕組み。

## 構成
- docs/: 初動、TIPS、同時作業ルール、参考資料
- configs/: nginx、mysql、sysctl、systemdの設定断片。conf/common配下へ転記して使う
- topologies/: 1台、2台、3台の構成手順
- scripts/: リース、デプロイ、ベンチ、集計。isu.env(未管理)で対象を指定する

## エージェント向けルール
- 検証は`make try REF=<ブランチ> LABEL=<目的>`のみで行う。検証環境へ直接sshして変更しない
- 作業は`make wt NAME=<名前>`で作るworktreeで行い、コミットしてpushしてから試す
- 着手前にdocs/claims.mdへ担当を追記する
- ISU_WHOは自分専用の名前を使う(他者と同じ名前を使わない)
- passがfalseなら直前の変更を戻す。スコア低下も同様
- 提出前に計測用の設定(スロークエリログ、デバッグ出力)を外す
