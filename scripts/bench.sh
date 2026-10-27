#!/usr/bin/env bash
# ベンチ実行と結果の記録(リース取得済みで呼ぶこと)。使い方: bench.sh <sha> <ラベル>
source "$(dirname "$0")/lib.sh"
SHA="${1:?sha}"; LABEL="${2:-nolabel}"
RUN="$(date +%Y%m%d-%H%M%S)-${ISU_WHO}-${SHA:0:7}"
OUT="$KIT_ROOT/results/$RUN"; mkdir -p "$OUT"
# ベンチ前に前回ログを退避して初期化
for h in $ISU_HOSTS; do
  ssh_run "$h" "sudo truncate -c -s 0 $ISU_NGINX_LOG 2>/dev/null || true" &
done
ssh_run "$ISU_DB_HOST" "sudo truncate -c -s 0 $ISU_SLOW_LOG 2>/dev/null || true" || true
wait
ssh_run "$ISU_BENCH_HOST" "$ISU_BENCH_CMD" 2>&1 | tee "$OUT/bench.log" >&2 || true
# 結果の取り出し: JSONの行があればそれを使い、なければログ行から取る
json="$(grep -E '^\{' "$OUT/bench.log" | tail -1 || true)"
if [ -n "$json" ] && echo "$json" | jq -e . >/dev/null 2>&1; then
  score="$(echo "$json" | jq -r "$ISU_SCORE_JQ")"; pass="$(echo "$json" | jq -r '.pass')"
else
  score="$(grep -oE "${ISU_SCORE_REGEX:-スコア: [0-9]+}" "$OUT/bench.log" | tail -1 | grep -oE '[0-9]+' || echo '?')"
  if grep -q "${ISU_PASS_GREP:-最終チェックが成功しました}" "$OUT/bench.log"; then pass=true; else pass=false; fi
fi
printf '%s\t%s\t%s\t%s\t%s\t%s\n' "$RUN" "$ISU_WHO" "$SHA" "$pass" "$score" "$LABEL" > "$OUT/summary.tsv"
log "結果: pass=$pass score=$score ($RUN)"
echo "$OUT"
