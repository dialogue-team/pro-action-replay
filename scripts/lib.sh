#!/usr/bin/env bash
# 共通関数。各スクリプトからsourceする
set -euo pipefail
KIT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
[ -f "$KIT_ROOT/isu.env" ] || { echo "isu.envがありません。isu.env.exampleをコピーしてください" >&2; exit 1; }
# shellcheck disable=SC1091
source "$KIT_ROOT/isu.env"
SSH_OPTS=(-o ServerAliveInterval=30 -o ConnectTimeout=10)
[ -z "${ISU_SSH_CONFIG:-}" ] || SSH_OPTS+=(-F "$ISU_SSH_CONFIG")
ssh_run() { local h="$1"; shift; ssh "${SSH_OPTS[@]}" "$h" "$@"; }
# 標準入力のスクリプトをリモートのbash -sで実行する。引数は空白を含んでも安全に渡る
ssh_bash() { local h="$1"; shift; ssh "${SSH_OPTS[@]}" "$h" "bash -s -- $(printf '%q ' "$@")"; }
log() { printf '[%s] %s\n' "$(date +%H:%M:%S)" "$*" >&2; }
# 実行するrefをコミットSHAに解決する。ISU_REQUIRE_PUSHED=1(既定)ならorigin/にpush済みであることを要求する
resolve_ref() {
  local ref="${1:-HEAD}" sha
  sha="$(git -C "$ISU_REPO" rev-parse --verify "$ref^{commit}")"
  if [ "${ISU_REQUIRE_PUSHED:-1}" = "1" ]; then
    git -C "$ISU_REPO" fetch -q origin
    if ! git -C "$ISU_REPO" branch -r --contains "$sha" | grep -q .; then
      echo "コミット$shaはoriginにpushされていません。先にpushしてください" >&2
      return 1
    fi
  fi
  echo "$sha"
}
