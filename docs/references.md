# 参考資料

「確認済み」は本文を取得して内容を確かめたもの。「未確認」は検索で存在を確認しただけのもの。

## private-isuを題材にしたもの
- [達人が教えるWebパフォーマンスチューニングに挑戦した記録(howtelevision)](https://zenn.dev/howtelevision/articles/74a33ec0e327c0)(確認済み): Ruby実装で26万点まで。インデックス、worker数、静的配信、画像の静的ファイル化、JOIN、プリペアドステートメント無効化、memcached、get_multi、MySQL設定、YJITの順に段階ごとのスコアが載っている
- [ISUCON13参加記(nanana78)](https://zenn.dev/nanana78/articles/e381e16129f2c6)(確認済み): アイコンのnginx静的配信とファイル参照への切り替えの具体的なnginx設定
- [ISUCON13参加記(pharmax)](https://zenn.dev/pharmax/articles/123ada69ad7635)(確認済み): private-isuを約30万点まで進めた経験と、本番での時系列、Goのビルド反映漏れの失敗談
- [ISUCON参加記(kuno)](https://zenn.dev/kuno/articles/369a4754758791)(確認済み): インデックスを1つずつデプロイして検証した話、N+1の3つの解消パターン
- [ISUCON11予選の振り返り(catatsuy)](https://zenn.dev/catatsuy/articles/6265ca623545ed)(確認済み): 複合インデックス、ログ無効化、DB分離の効果の限界
- [private-isu 2度目の練習記(mkizka)](https://scrapbox.io/mkizka/isucon%E7%B7%B4%E7%BF%92%E8%A8%98_private-isu_2%E5%BA%A6%E7%9B%AE)(未確認)

## 初動、道具
- [ISUCON当日最初にやること2022(mkizka)](https://scrapbox.io/mkizka/ISUCON%E5%BD%93%E6%97%A5%E6%9C%80%E5%88%9D%E3%81%AB%E3%82%84%E3%82%8B%E3%81%93%E3%81%A82022)(確認済み): ベンチ、nginxログ形式、Makefile、kataribeの順
- [alp](https://github.com/tkuchiki/alp)(確認済み): ltsv、jsonの集計、-mでURIをまとめる、--sortの値一覧
- [pprotein](https://github.com/kaz/pprotein)(README本文は取得できず、概要のみ確認): alp、スロークエリ、pprofを収集して画面で見るツール。導入手順は本家のREADMEで確認する
- [達人が教えるWebパフォーマンスチューニング(技術評論社)](https://gihyo.jp/dp/ebook/2022/978-4-297-12847-0)(未確認): private-isuの解説書
