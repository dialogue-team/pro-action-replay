#!/usr/bin/env bash
# 作業者ごとに独立したgit worktreeを作る。使い方: worktree.sh <名前> [基点ref]
source "$(dirname "$0")/lib.sh"
NAME="${1:?name}"; BASE="${2:-origin/main}"
git -C "$ISU_REPO" fetch -q origin
DIR="$KIT_ROOT/worktrees/$NAME"
git -C "$ISU_REPO" worktree add -b "work/$ISU_WHO/$NAME" "$DIR" "$BASE"
echo "$DIR"
