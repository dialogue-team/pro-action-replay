#!/usr/bin/env bash
# 検証環境の排他リース。1つの環境を同時に使えるのは1人だけにする
# 使い方: lease.sh acquire <目的> | release | status | steal <目的>
source "$(dirname "$0")/lib.sh"
LOCK_DIR="/tmp/isu-lease"
cmd="${1:-status}"; purpose="${2:-bench}"

remote() { ssh_bash "$ISU_BENCH_HOST" "$@"; }

case "$cmd" in
  acquire)
    waited=0
    while :; do
      if out="$(remote "$LOCK_DIR" "$ISU_WHO" "$purpose" "$ISU_LEASE_TTL" <<'REMOTE'
d="$1"; who="$2"; purpose="$3"; ttl="$4"
if mkdir "$d" 2>/dev/null; then
  echo "$who|$(date +%s)|$purpose" > "$d/owner"; echo ACQUIRED; exit 0
fi
IFS='|' read -r ow ts pp < "$d/owner" 2>/dev/null || { ow="?"; ts=0; pp="?"; }
age=$(( $(date +%s) - ts ))
if [ "$ow" = "$who" ]; then echo "$who|$(date +%s)|$purpose" > "$d/owner"; echo ACQUIRED; exit 0; fi
echo "BUSY $ow $pp ${age}s"
REMOTE
)"; then :; fi
      case "$out" in
        ACQUIRED) log "リース取得: $ISU_WHO ($purpose)"; exit 0 ;;
        BUSY*)
          age="${out##* }"; age="${age%s}"
          if [ "$age" -gt "$ISU_LEASE_TTL" ] 2>/dev/null; then
            log "TTL超過のリースを奪取します: $out"; exec "$0" steal "$purpose"
          fi
          log "待機中: $out"; sleep 10; waited=$((waited+10))
          [ "$waited" -lt 1800 ] || { log "30分待っても取得できませんでした"; exit 1; } ;;
        *) log "予期しない応答: $out"; exit 1 ;;
      esac
    done ;;
  steal)
    remote "$LOCK_DIR" "$ISU_WHO" "$purpose" <<'REMOTE'
d="$1"; rm -rf "$d"; mkdir "$d"; echo "$2|$(date +%s)|$3" > "$d/owner"
REMOTE
    log "リース奪取: $ISU_WHO" ;;
  release)
    remote "$LOCK_DIR" "$ISU_WHO" <<'REMOTE'
d="$1"; who="$2"
IFS='|' read -r ow ts pp < "$d/owner" 2>/dev/null || exit 0
if [ "$ow" = "$who" ]; then rm -rf "$d"; fi
exit 0
REMOTE
    log "リース解放: $ISU_WHO" ;;
  status)
    remote "$LOCK_DIR" <<'REMOTE'
d="$1"
if [ -f "$d/owner" ]; then IFS='|' read -r ow ts pp < "$d/owner"; echo "使用中: $ow ($pp) $(( $(date +%s) - ts ))秒経過"; else echo "空き"; fi
REMOTE
    ;;
  *) echo "usage: $0 acquire|release|status|steal" >&2; exit 2 ;;
esac
