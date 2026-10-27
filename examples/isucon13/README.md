# ISUCON13の練習環境で使う

公式AMI(`ami-041289d910c114864`、ap-northeast-1)を使う。2023年のスナップショットのため、起動しただけではベンチが通らない。

1. DNSのゾーンがサーバーのパブリックIPを返す。ベンチ専用ホストから届かないため、isu1のゾーンをプライベートIPにする
   - `/home/isucon/env.sh`の`ISUCON13_POWERDNS_SUBDOMAIN_ADDRESS`をisu1のプライベートIPにする
   - `sudo bash /home/isucon/webapp/pdns/init_zone.sh`を実行し、`sudo systemctl restart isupipe-go`でアプリを再起動する
2. `*.u.isucon.dev`の証明書が2024年1月に期限切れ。自己署名証明書(SANは`*.u.isucon.dev`と`u.isucon.dev`)を全台の`/etc/nginx/tls/_.u.isucon.dev.{crt,key}`に置き、nginxを再読込する。ベンチ専用ホストの`/usr/local/share/ca-certificates/`にも置き、`update-ca-certificates`を実行する
3. ベンチは成功時にJSONを出さず、ログに`スコア: N`と`最終チェックが成功しました`を出す。isu-kitは両方を読む

セキュリティグループは、22と443を自分のIPだけに許可し、グループ内の通信(DNSのUDP/53を含む)は全許可にする。
