# isu-kit

ISUCON向けの、TIPS集、すぐ使える構成集、複数人で衝突しない検証の仕組み。

## 使い方
1. `cp isu.env.example isu.env`して、対象のホストやコマンドを埋める
2. `make bootstrap`で計測ツールを導入する
3. [docs/first-30min.md](docs/first-30min.md)に沿って初動を行う
4. 改善は[docs/tips/](docs/tips/)と[configs/](configs/)、[topologies/](topologies/)から選ぶ
5. 検証は必ず`make try REF=<ブランチ> LABEL=<目的>`で行う。仕組みは[docs/workflow.md](docs/workflow.md)

## 構成
| ディレクトリ | 内容 |
|---|---|
| docs/ | 初動チェックリスト、TIPS、同時作業ルール、参考資料 |
| configs/ | nginx、MySQL、sysctl、systemd、alpの設定断片 |
| topologies/ | 1台、2台、3台構成の手順 |
| scripts/ | リース、デプロイ、ベンチ、集計、worktree作成 |
| results/ | 試行ごとの結果(git管理外。ledger.tsvに履歴) |

## 検証済みの範囲
- scripts/lease.shは、ssh代替を使ったローカル模擬で、排他、TTL超過の奪取、所有者以外の解放の無視、解放を確認した
- deploy.sh、bench.sh、analyze.sh、bootstrap.sh、try.shは構文確認のみ。実機のISUCON環境ではまだ動かしていない。初回は1台で試してから使う
- 設定値は一般的な値の見本。レギュレーションと搭載メモリに合わせて調整する
