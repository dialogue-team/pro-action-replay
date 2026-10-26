# 1台構成

nginx、アプリ、MySQL、memcachedが同居する。最初に行うこと。

1. ベンチを回して初期スコアを記録する
2. configs/nginx/00-ltsv-log.confとconfigs/mysql/10-slowlog.cnfを反映して計測する
3. スロークエリ上位から順にインデックスとN+1を潰す
4. 静的ファイルとDBに入っている画像をnginx配信に変える
5. アプリのワーカー数をCPUコア数に合わせる(Unicornのworker、GoならGOMAXPROCSは既定で足りる)

## 判断の目安

- topでmysqldが上位でアプリが下位: DB側の改善(インデックス、クエリ数削減)が先
- アプリが上位でmysqldが少ない: アプリのCPU処理、外部コマンド呼び出し、ハッシュ計算、JSON処理を疑う
- 両方が頭打ち: 2台構成へ
