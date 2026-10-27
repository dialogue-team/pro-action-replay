# 改善ループの進め方

計測、仮説、変更、検証を、`make try`の1周で回す。ISUCON13の練習環境での実施記録を例に書く。

## 準備(初回のみ)
1. 競技環境のアプリを、手元のgitリポジトリに取り込む(`ISU_REPO`)。バイナリは除外する
2. `isu.env`を作る([examples/isucon13/isu.env.example](../examples/isucon13/isu.env.example)が見本)
3. `make bootstrap`で全台にalpとpt-query-digestを入れる
4. 計測用の設定をリポジトリのconf/common配下に置く(`/`からの相対パスで置く)
   - nginxのログをLTSVにする。nginx.confのhttp{}に既存のaccess_logがあれば置き換える(足すと二重出力)
   - MySQLのスロークエリログを有効にする(configs/mysql/10-slowlog.cnfを`conf/common/etc/mysql/mysql.conf.d/`へ)

## 1周の手順
1. `make try REF=<ブランチ> LABEL=<目的>`を実行する。デプロイ、ベンチ、集計、記録までが行われる
2. `results/<日時>-<作業者>-<sha>/`を見る
   - `bench.log`: ベンチの全出力。`summary.tsv`にpassとスコア
   - `alp-<ホスト>.txt`: エンドポイントごとの合計時間。大きい順
   - `slow.txt`: pt-query-digestの結果。Response timeの大きい順
3. 一番時間を使っているものを1つだけ直す
4. 1つ直すごとに再度`make try`を実行し、`results/ledger.tsv`で前後を比べる
5. passがfalse、またはスコアが下がったら、直前の変更を戻す

## ボトルネックの読み方
- slow.txtのProfile表で、上位のクエリを見る。Callsが多くR/Callが小さければN+1、Rows examineが大きければインデックス不足
- 例(ISUCON13の初期状態): `SELECT * FROM livestream_tags WHERE livestream_id = ?`が5426回、1回あたり約1万行を走査し、全体の25%を占めた。インデックスが主キーしかなかった

## インデックスの管理
DDLを手で流さず、リポジトリで管理して、デプロイのたびに冪等に適用する。
1. `configs/mysql/apply_indexes.sh`をアプリリポジトリのsql/に置く
2. 同じ場所に`indexes.tsv`を置く(テーブル名、インデックス名、列をタブ区切り)
3. `isu.env`に`ISU_POST_BUILD_CMD="bash sql/apply_indexes.sh"`を設定する
4. 全台のMySQLに適用される。再実行しても重複しない

## 検証を終える
- 検証が終わったらインスタンスを停止する。停止するとパブリックIPが変わるので、ssh設定を更新する
- 本番では、計測用の設定(スロークエリログ、デバッグ出力)を外してから提出する

## ISUCON13での実施記録(練習環境、アプリは未改善の状態から)
| 変更 | pass | スコア |
|---|---|---|
| 初期状態(3回計測) | true | 3357〜3553 |
| スロークエリログの有効化のみ | true | 3392〜3459 |
| 主キー以外のインデックス10件を追加 | true | 8523 |

- インデックスだけで、スコアが約2.5倍になった
- 次の候補はslow.txtの上位: icons(画像のDB保存)、リクエストごとのN+1、アイコンのnginx配信
