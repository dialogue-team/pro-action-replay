#!/usr/bin/env bash
# 指定コミットのファイルをgit archiveで取り出し、rsyncで全ホストへ配る(サーバー側にgitは不要)
# 使い方: deploy.sh [ref]  (リース取得済みで呼ぶこと)
#   ISU_SYNC_DIRS のディレクトリをISU_REMOTE_DIR配下へ --delete 付きで同期する
#   conf/common と conf/<ホスト名> は / 配下へ配置する(後者が優先)
source "$(dirname "$0")/lib.sh"
SHA="$(resolve_ref "${1:-HEAD}")"
log "deploy $SHA -> $ISU_HOSTS"
STAGE="$(mktemp -d)"; trap 'rm -rf "$STAGE"' EXIT
git -C "$ISU_REPO" archive "$SHA" | tar -x -C "$STAGE"
RSH="ssh ${SSH_OPTS[*]}"
OWNER="${ISU_REMOTE_OWNER:-isucon}"

deploy_one() {
  local h="$1" prev changed=""
  prev="$(ssh_run "$h" 'cat /tmp/isu-deployed 2>/dev/null' || true)"
  if [ -n "$prev" ] && git -C "$ISU_REPO" cat-file -e "$prev^{commit}" 2>/dev/null; then
    changed="$(git -C "$ISU_REPO" diff --name-only "$prev" "$SHA")"
  else
    changed="conf/mysql conf/nginx"   # 初回は全部反映
  fi
  for d in $ISU_SYNC_DIRS; do
    [ -d "$STAGE/$d" ] || continue
    local ex=(); [ -z "${ISU_BUILD_ARTIFACT:-}" ] || ex=(--exclude "/$ISU_BUILD_ARTIFACT")
    rsync -rlpt --delete "${ex[@]}" -e "$RSH" --rsync-path="sudo -u $OWNER rsync" \
      "$STAGE/$d/" "$h:$ISU_REMOTE_DIR/$d/"
  done
  if [ -d "$STAGE/conf" ]; then
    rsync -rlpt --delete -e "$RSH" "$STAGE/conf/" "$h:/tmp/isu-conf/"
  fi
  ssh_bash "$h" "$h" "$ISU_REMOTE_DIR" "$OWNER" "$ISU_BUILD_CMD" "$ISU_APP_UNITS" "$changed" "${ISU_POST_BUILD_CMD:-}" <<'REMOTE'
set -euo pipefail
host="$1"; dir="$2"; owner="$3"; build="$4"; units="$5"; changed="$6"; post="${7:-}"
for d in common "$host"; do
  [ -d "/tmp/isu-conf/$d" ] && sudo rsync -rlpt "/tmp/isu-conf/$d"/ /
done
sudo -iu "$owner" bash -c "cd '$dir' && $build"
if [ -n "$post" ]; then sudo -iu "$owner" bash -c "cd '$dir' && $post"; fi
if echo "$changed" | grep -q 'mysql'; then sudo systemctl restart mysql; fi
if echo "$changed" | grep -q 'nginx'; then sudo nginx -t && sudo systemctl reload nginx; fi
for u in $units; do sudo systemctl restart "$u"; done
for u in $units; do systemctl is-active --quiet "$u" || { echo "$uが起動していません" >&2; exit 1; }; done
REMOTE
  ssh_run "$h" "echo $SHA > /tmp/isu-deployed"
}

pids=()
for h in $ISU_HOSTS; do deploy_one "$h" & pids+=($!); done
rc=0; for p in "${pids[@]}"; do wait "$p" || rc=1; done
[ "$rc" -eq 0 ] && log "deploy完了 $SHA" || { log "deploy失敗"; exit 1; }
echo "$SHA"
