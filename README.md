# pro-action-replay

ISUCON向けの、TIPS集、すぐ使える構成集、複数人で衝突しない検証の仕組み。

## 使い方
1. `cp isu.env.example isu.env`して、対象のホストやコマンドを埋める
2. `make bootstrap`で計測ツールを導入する
3. [docs/first-30min.md](docs/first-30min.md)に沿って初動を行う。改善の1周の回し方は[docs/improvement-loop.md](docs/improvement-loop.md)
4. 改善は[docs/tips/](docs/tips/)と[configs/](configs/)、[topologies/](topologies/)から選ぶ
5. 検証は必ず`make try REF=<ブランチ> LABEL=<目的>`で行う。仕組みは[docs/workflow.md](docs/workflow.md)

## 構成
| ディレクトリ | 内容 |
|---|---|
| docs/ | 初動チェックリスト、TIPS、同時作業ルール、参考資料 |
| configs/ | nginx、MySQL、sysctl、systemd、alpの設定断片 |
| topologies/ | 1台、2台、3台構成の手順 |
| examples/ | 題材別の設定例(ISUCON13の練習環境) |
| scripts/ | リース、デプロイ、ベンチ、集計、worktree作成 |
| results/ | 試行ごとの結果(git管理外。ledger.tsvに履歴) |
| local/ | チーム非公開のメモ(git管理外) |

## 公開前
`make audit`で秘密情報や個人情報の混入を確認する。`make hooks`でpush前に自動実行する。

## 検証済みの範囲
- ISUCON13の公式AMIによる練習環境(競技用3台、ベンチ専用1台)で、`make bootstrap`と`make try`を実機で通した
  - リース、`git archive`+rsyncでの全台デプロイ、ベンチ、alpとpt-query-digestの集計、結果の記録まで
  - 2人が同時に`make try`した場合に、片方が待機して順番に実行されることを確認した
- 未検証: 実際のISUCON本番環境、`make wt`、複数台構成(isu2、isu3を使った負荷分散)
- 設定値は一般的な値の見本。レギュレーションと搭載メモリに合わせて調整する
