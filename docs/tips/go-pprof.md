# Goのpprof

初動で入れる。アプリの再起動だけで有効になり、ベンチへの影響は小さい。

## 組み込み
main.goに追加する。待ち受けはlocalhostのみにする。
```go
import (
	"net/http"
	_ "net/http/pprof"
)

func init() {
	go func() { _ = http.ListenAndServe("127.0.0.1:6060", nil) }()
}
```
フレームワークが独自のmuxを使っていても、これは別ポートのDefaultServeMuxで動く。

## 取得
ベンチを走らせている間に取る。
```
ssh <host> 'curl -s -o /tmp/cpu.pprof "http://127.0.0.1:6060/debug/pprof/profile?seconds=30"'
scp <host>:/tmp/cpu.pprof .
go tool pprof -http=:8080 cpu.pprof
```
- CPU: `/debug/pprof/profile?seconds=30`
- ヒープ: `/debug/pprof/heap`
- goroutine: `/debug/pprof/goroutine`

## 見方
- flameグラフ(`-http`のView)で、幅の広いところから見る
- DB待ちの時間はCPUプロファイルに出ない。alpとslow.txtを併用する

## 提出前
pprofの組み込みは外す。
