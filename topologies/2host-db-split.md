# 2台構成(アプリ+nginxとDBを分離)

```
isu1: nginx + app
isu2: mysql (+ memcached)
```

## 手順

1. isu2でMySQLの設定を反映する(configs/mysql/20-tuning.cnfのbind-addressを有効化)
2. DBユーザーを外部接続可にする
   ```sql
   CREATE USER IF NOT EXISTS 'isucon'@'192.168.%' IDENTIFIED BY '<強いパスワードに置き換える>';
   GRANT ALL ON *.* TO 'isucon'@'192.168.%';
   ```
3. isu1のアプリのDB接続先を環境変数で切り替える(ISUCON_DB_HOSTなど、題材ごとの名前に合わせる)
4. 初期データはisu2にだけ存在すればよい。isu1のMySQLは停止して無効化する
5. セキュリティグループで3306をVPC内の相互通信だけ許可する

## 注意

- ネットワーク往復が増えるので、N+1が残っていると逆に遅くなる。先に解消しておく
- DBのコネクションプールを調整する(SetMaxOpenConns、SetMaxIdleConns)
