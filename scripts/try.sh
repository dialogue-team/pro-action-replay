#!/usr/bin/env bash
# 試行の一括実行: リース取得 -> デプロイ -> ベンチ -> 集計 -> 解放
# 使い方: try.sh [ref] [ラベル]
source "$(dirname "$0")/lib.sh"
REF="${1:-HEAD}"; LABEL="${2:-$REF}"
SHA="$(resolve_ref "$REF")"
"$KIT_ROOT/scripts/lease.sh" acquire "try:${LABEL}"
trap '"$KIT_ROOT/scripts/lease.sh" release' EXIT
"$KIT_ROOT/scripts/deploy.sh" "$SHA" >/dev/null
OUT="$("$KIT_ROOT/scripts/bench.sh" "$SHA" "$LABEL")"
"$KIT_ROOT/scripts/analyze.sh" "$OUT"
cat "$OUT/summary.tsv" >> "$KIT_ROOT/results/ledger.tsv"
echo "$OUT"
