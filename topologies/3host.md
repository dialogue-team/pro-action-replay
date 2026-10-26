# 3台構成

代表的な2パターン。

## A. アプリを2台、DBを1台
```
isu1: nginx + app (リバースプロキシとして isu2 のappにも振り分け)
isu2: app
isu3: mysql + memcached
```
nginxのupstreamに両ホストのappを並べる(configs/nginx/30-upstream-keepalive.conf)。

## B. アプリを3台、DBも分散
ユーザーIDなどでシャーディングする。複雑なので、アプリ追加で伸びなくなってから検討する。

## 共通の注意点

- アプリのインメモリキャッシュやグローバル変数は台ごとに別物になる。整合が必要なものはmemcachedやDBへ寄せる
- 画像などの書き出し先ファイルは台ごとに別になる。共有が必要なら、書き込みを1台に集めるか共有ストレージを使う
- デプロイは全台に同じコミットを配る。scripts/deploy.shは全台並列に配布する
