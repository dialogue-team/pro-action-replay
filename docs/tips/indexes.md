# インデックス

多くの参加記で最初の大きな伸びになる。private-isuを解いた記録でも、commentsのpost_idへのインデックスが最初の施策だった。

## 手順
1. slow.txtでRows_examinedが大きい、または回数の多いクエリを選ぶ
2. `EXPLAIN`でtype=ALLやusing filesortを確認する
3. WHEREの等価条件の列を先頭、範囲条件やORDER BYの列を後ろにした複合インデックスにする
4. 1つ入れるごとにベンチを回して効果を確認する(まとめて入れると効果が見えず、逆効果に気づけない)

## 例(private-isu)
```sql
ALTER TABLE comments ADD INDEX idx_post_id_created_at (post_id, created_at);
ALTER TABLE comments ADD INDEX idx_user_id (user_id);
ALTER TABLE posts ADD INDEX idx_created_at (created_at);
```
posts一覧がuser_idで絞りcreated_atで並べる場合は(user_id, created_at)の複合インデックスが効く。オプティマイザが選ばない場合に限って`FORCE INDEX`を使う。

## 落とし穴
- 複数台構成では、DBが載っている台にだけ入れる。参加記では3台のうち1台にしか入っていなかった例がある
- 初期化処理がテーブルを作り直すなら、インデックスもそのDDLに入れる
- レコード数が少ない表へのインデックスは効果がない(ISUCON11の記録)
- INSERTが多い表に入れすぎると書き込みが遅くなる
