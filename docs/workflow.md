# 同時作業の仕組み

人間もエージェントも、同じ検証環境に同時にデプロイしてベンチを回すと結果が壊れる。次の4つで衝突を防ぐ。

## 1. 作業コピーを分ける(git worktree)
```
make wt NAME=index-comments      # work/<自分>/index-comments ブランチと専用ディレクトリを作る
```
- 1つの作業コピーを複数人で共有しない
- 作業したらコミットする。複数人で共有するなら、originへpushする(ISU_REQUIRE_PUSHED=1の既定では未pushのコミットはデプロイを拒否される)

## 2. 担当領域を宣言する(ファイル単位の衝突回避)
- 着手前にdocs/claims.mdへ「誰が・どのファイル/エンドポイント/テーブルを触るか」を1行追記してpushする
- 同じファイルを触る必要があるときは、先に宣言した人のブランチをマージしてから始める
- 設定ファイル(conf/)は1ブランチ1テーマにする(例: nginxとmysqlを別ブランチ)

## 3. 検証環境をリースで直列化する
```
make try REF=work/alice/index-comments LABEL=comments-index
```
一連の処理が1コマンドで行われる。
1. リース取得(他人が使用中なら待機。最大30分)
2. 指定コミットを`git archive`で取り出し、rsyncで全台へ配る(サーバー側にgitは不要)。ビルド、設定反映、再起動まで行う
3. ベンチ実行
4. alpとpt-query-digestの集計を保存
5. リース解放(異常終了でも解放される)

- 状態確認: `make lease-status`
- 保持者が応答なしなら、TTL(既定15分)を超えた時点で奪取できる
- 検証環境へ直接sshして設定を手で変えない。変更はすべてコミットして`make try`で反映する

## 4. 結果は追記専用で共有する
- results/<日時>-<作業者>-<sha>/にbench.json、summary.tsv、alp-*.txt、slow.txtが保存される
- results/ledger.tsvは1行ずつ追記される。試行の履歴はここで確認する
- 結果ディレクトリは試行ごとに別名のため、gitで衝突しない

## mainへの統合
- スコアが上がり、passがtrueだった変更だけをPull Requestでmainへ入れる
- マージ後に`make try REF=origin/main LABEL=main-after-<名前>`で、統合後のスコアを再計測する
- ベンチのスコアが下がった統合は、その場で戻す

## エージェント(Claude Codeなど)に作業を任せる場合
- 1エージェントにつき1つのISU_WHOとworktreeを割り当てる(例: ISU_WHO=agent-index)
- エージェントには`make try`だけを実行させ、検証環境への直接ssh操作は禁止する
- CLAUDE.mdに同じルールを書いてある
