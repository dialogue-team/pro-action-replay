#!/usr/bin/env bash
# 共通関数。各スクリプトからsourceする
set -euo pipefail
KIT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
[ -f "$KIT_ROOT/isu.env" ] || { echo "isu.envがありません。isu.env.exampleをコピーしてください" >&2; exit 1; }
# shellcheck disable=SC1091
source "$KIT_ROOT/isu.env"
SSH_OPTS=(-o ServerAliveInterval=30 -o ConnectTimeout=10)
ssh_run() { local h="$1"; shift; ssh "${SSH_OPTS[@]}" "$h" "$@"; }
log() { printf '[%s] %s\n' "$(date +%H:%M:%S)" "$*" >&2; }
# 実行するrefをコミットSHAに解決する。origin/にpush済みであることを要求する
resolve_ref() {
  local ref="${1:-HEAD}" sha
  sha="$(git -C "$ISU_REPO" rev-parse --verify "$ref^{commit}")"
  git -C "$ISU_REPO" fetch -q origin
  if ! git -C "$ISU_REPO" branch -r --contains "$sha" | grep -q .; then
    echo "コミット$shaはoriginにpushされていません。先にpushしてください" >&2
    return 1
  fi
  echo "$sha"
}
