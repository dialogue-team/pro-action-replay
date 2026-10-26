#!/usr/bin/env bash
# 指定refを全ホストへデプロイ。使い方: deploy.sh [ref]  (リース取得済みで呼ぶこと)
source "$(dirname "$0")/lib.sh"
SHA="$(resolve_ref "${1:-HEAD}")"
log "deploy $SHA -> $ISU_HOSTS"

deploy_one() {
  local h="$1"
  ssh_run "$h" bash -s -- "$ISU_REMOTE_DIR" "$SHA" "$h" "$ISU_BUILD_CMD" "$ISU_APP_UNITS" <<'REMOTE'
set -euo pipefail
dir="$1"; sha="$2"; host="$3"; build="$4"; units="$5"
cd "$dir"
prev="$(cat .deployed 2>/dev/null || git rev-parse HEAD)"
git fetch -q origin
git checkout -qf "$sha"
changed="$(git diff --name-only "$prev" "$sha" 2>/dev/null || true)"
# 設定配置: conf/common を先に、conf/<host> で上書き
for d in conf/common "conf/$host"; do
  [ -d "$d" ] && sudo rsync -rlpt "$d"/ /
done
bash -c "$build"
echo "$sha" > .deployed
if echo "$changed" | grep -q 'mysql'; then sudo systemctl restart mysql; fi
if echo "$changed" | grep -q 'nginx'; then sudo nginx -t && sudo systemctl reload nginx; fi
for u in $units; do sudo systemctl restart "$u"; done
for u in $units; do systemctl is-active --quiet "$u" || { echo "$uが起動していません" >&2; exit 1; }; done
REMOTE
}

pids=()
for h in $ISU_HOSTS; do deploy_one "$h" & pids+=($!); done
rc=0; for p in "${pids[@]}"; do wait "$p" || rc=1; done
[ "$rc" -eq 0 ] && log "deploy完了 $SHA" || { log "deploy失敗"; exit 1; }
echo "$SHA"
