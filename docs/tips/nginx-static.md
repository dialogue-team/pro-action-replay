# nginxと静的ファイル

## 基本
- アクセスログをLTSVにする(configs/nginx/00-ltsv-log.conf)
- css、js、画像、faviconをnginxから直接返す(configs/nginx/20-static-and-image.conf)
- アプリへのupstreamにkeepaliveを付ける(configs/nginx/30-upstream-keepalive.conf)
- 設定ファイルが複数ある場合は、実際に有効な方を確認する(sites-enabledとconf.dの優先関係で、効いていないファイルを編集した例がある)

## DBに入っている画像を静的ファイル化する
流れは次のとおり。
1. nginxがファイルを探す
2. なければアプリへproxyする
3. アプリがDBから画像を取り出してファイルに書き出し、レスポンスを返す
4. 以降はnginxが直接返す

private-isuでは、これで画像取得の平均が0.040秒から0.003秒になった記録がある。アイコンの投稿時にもファイルを更新する実装を忘れない。

```nginx
# アイコンの例。パスと拡張子は題材に合わせて変える
location ~ ^/icon/([a-z0-9_-]+)$ {
  root /home/isucon/app/public;
  try_files /icons/$1.jpeg @app;
}
location @app {
  proxy_set_header Host $host;
  proxy_pass http://app;
}
```

## 落とし穴
- 「静的ファイルが正しくありません」のような整合性チェックの失敗は、書き出し先ディレクトリの権限(nginxのユーザーが読めるか、アプリが書けるか)を疑う
- ブラウザキャッシュを効かせるとベンチの整合性チェックに引っかかる題材がある。expiresを付けて失敗したら外す
- 複数台構成では、画像を書いた台以外には存在しない
