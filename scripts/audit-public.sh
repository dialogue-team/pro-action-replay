#!/usr/bin/env bash
# 公開してよい内容か確認する。違反があれば非0で終了する
# 使い方: audit-public.sh   (git管理下のファイルと履歴のauthorを検査)
set -uo pipefail
cd "$(dirname "$0")/.."
rc=0
fail() { echo "NG: $*" >&2; rc=1; }

# 1. 追跡してはいけないファイル
for f in isu.env .env; do git ls-files --error-unmatch "$f" >/dev/null 2>&1 && fail "$fが追跡されています"; done
git ls-files | grep -E '(^local/|^results/.+|\.pem$|\.key$|worktrees/)' | grep -v '^local/README.md$' | grep -v '^results/.gitkeep$' | sed 's/^/NG: 追跡不可: /' && rc=1

# 2. 秘密情報らしき文字列
PAT='AKIA[0-9A-Z]{16}|ASIA[0-9A-Z]{16}|aws_secret_access_key|-----BEGIN [A-Z ]*PRIVATE KEY-----|ghp_[A-Za-z0-9]{30,}|github_pat_[A-Za-z0-9_]{30,}|xox[baprs]-[A-Za-z0-9-]{10,}|[?&]token=[A-Za-z0-9_:.-]{20,}'
git ls-files -z | xargs -0 grep -InE "$PAT" 2>/dev/null | sed 's/^/NG: 秘密情報の疑い: /' && rc=1

# 3. AWSアカウントID(12桁)、グローバルIPv4、個人パス、メールアドレス
git ls-files -z | grep -zv 'audit-public.sh' | xargs -0 grep -InE '\b[0-9]{12}\b' 2>/dev/null | sed 's/^/NG: 12桁の数値(アカウントID?): /' && rc=1
git ls-files -z | grep -zv 'audit-public.sh' | xargs -0 grep -InE '/Users/[a-z]+|/home/[a-z]+/\.ssh' 2>/dev/null | sed 's/^/NG: 個人パス: /' && rc=1
git ls-files -z | grep -zv 'audit-public.sh' | xargs -0 grep -InE '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[a-z]{2,}' 2>/dev/null | grep -v 'users.noreply.github.com' | sed 's/^/NG: メールアドレス: /' && rc=1
git ls-files -z | grep -zv 'audit-public.sh' | xargs -0 grep -InE '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b' 2>/dev/null \
  | grep -vE '\b(127\.0\.0\.1|0\.0\.0\.0|192\.168\.|10\.|172\.(1[6-9]|2[0-9]|3[01])\.)' | sed 's/^/NG: グローバルIPの疑い: /' && rc=1

# 4. コミットのauthor/committerが公開用のアドレスか(noreplyのみ許可)
bad="$(git log --format='%ae%n%ce' | sort -u | grep -v 'users.noreply.github.com' || true)"
[ -z "$bad" ] || { echo "NG: noreply以外のメールが履歴にあります:" >&2; echo "$bad" >&2; rc=1; }

[ "$rc" -eq 0 ] && echo "OK: 公開前チェックに問題はありません"
exit "$rc"
