# MySQL設定

configs/mysql/10-slowlog.cnfで計測し、configs/mysql/20-tuning.cnfで調整する。

## 主な項目
- `innodb_flush_log_at_trx_commit = 2`: コミットごとのfsyncをやめて約1秒ごとにする。書き込みが多い題材で効く。クラッシュ時に最大1秒分を失うため、レギュレーションを確認する
- `skip-log-bin`: バイナリログの無効化
- `innodb_buffer_pool_size`: データが載り切る大きさに。他プロセスのメモリを残す
- `innodb_flush_method = O_DIRECT`
- `max_connections`: アプリの接続数の合計より多く
- スロークエリログとgeneral logは提出前に必ず無効化する(long_query_time=0は常に負荷になる)

## アプリ側
- プリペアドステートメントを使わない設定にする(Goならドライバのinterpolateパラメータ(interpolateParams=true)を使う。他の言語はドライバの設定を確認する)。private-isuの記録では大きく伸びた
- コネクションプールの上限を設定する
- 読み取りだけの処理にトランザクションを使わない
- INSERTを1件ずつ呼んでいる箇所はバルクインサートにする

## 構成面
- DBを別台に分離する(topologies/2host-db-split.md)。ただしDBのCPUが限界ならアプリを増やしても伸びない
