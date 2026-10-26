# 最初の30分

役割を分けて並行で進める。全員が同じファイルを触らないことが最優先。

## 全員(最初の10分)
1. 初期スコアを1回だけ記録する(`make try REF=origin/main LABEL=baseline`)
2. アプリをgit管理下に置き、originへpushする(コードと設定をどちらも)
3. `scripts/lease.sh status`で環境が空いているか確認する習慣をつける

## 担当A: 計測基盤
1. `make bootstrap`でalpとpt-query-digestを全台へ導入
2. configs/nginx/00-ltsv-log.confとconfigs/mysql/10-slowlog.cnfをconf/commonへ入れてコミット
3. 再デプロイしてベンチを回し、alp/slow.txtが出ることを確認する

## 担当B: アプリ把握
1. ルーティング一覧とSQLを洗い出す(どのエンドポイントがどのテーブルを触るか)
2. 外部コマンド呼び出し、ハッシュ計算、画像のDB保存を探す
3. 初期化処理(/initializeなど)がDBを作り直すか確認する。インデックスは初期化後も残るようDDLを置く場所を決める

## 担当C: 構成確認
1. 台数、CPU、メモリ、ディスクを確認する(`nproc; free -m; lsblk`)
2. 各ホストの起動ユニットと待ち受けポートを確認する(`systemctl list-units --type=service --state=running; ss -ltnp`)
3. 競技レギュレーションで許される設定変更の範囲を確認する

## 最初の改善の選び方
1. slow.txtの合計時間が大きいクエリから、インデックスを付ける
2. alpの合計時間が大きいエンドポイントから、N+1とクエリ数を減らす
3. 静的ファイルと画像をnginx配信にする
4. 以降は[tips](tips/)を参照する
