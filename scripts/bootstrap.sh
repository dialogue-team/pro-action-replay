#!/usr/bin/env bash
# 各サーバーへ計測ツールを導入する(Ubuntu想定)。使い方: bootstrap.sh
source "$(dirname "$0")/lib.sh"
ALP_VER="${ALP_VER:-1.0.21}"
for h in $ISU_HOSTS; do
  log "bootstrap $h"
  ssh_run "$h" bash -s -- "$ALP_VER" <<'REMOTE'
set -euo pipefail
sudo apt-get update -qq
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq percona-toolkit git rsync jq htop dstat unzip
if ! command -v alp >/dev/null; then
  cd /tmp
  curl -fsSL -o alp.zip "https://github.com/tkuchiki/alp/releases/download/v$1/alp_linux_amd64.zip"
  unzip -oq alp.zip && sudo install -m 0755 alp /usr/local/bin/alp
fi
REMOTE
done
