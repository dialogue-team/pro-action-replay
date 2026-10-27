#!/usr/bin/env bash
# ベンチ直後のログを集計して結果ディレクトリへ保存。使い方: analyze.sh <結果dir>
source "$(dirname "$0")/lib.sh"
OUT="${1:?result dir}"
GROUPS_RE="${ISU_ALP_GROUPS:-}"
for h in $ISU_HOSTS; do
  ssh_run "$h" "sudo alp ltsv --file $ISU_NGINX_LOG --sort sum -r ${GROUPS_RE:+-m '$GROUPS_RE'} -o count,method,uri,min,avg,p99,max,sum" \
    > "$OUT/alp-$h.txt" 2>"$OUT/alp-$h.err" || log "alp失敗($h): $OUT/alp-$h.err を確認"
done
ssh_run "$ISU_DB_HOST" "sudo pt-query-digest $ISU_SLOW_LOG" > "$OUT/slow.txt" 2>"$OUT/slow.err" || log "pt-query-digest失敗: $OUT/slow.err を確認"
log "集計保存: $OUT/alp-*.txt, slow.txt"
