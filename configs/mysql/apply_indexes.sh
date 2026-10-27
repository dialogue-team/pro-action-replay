#!/usr/bin/env bash
# 冪等にインデックスを作る。同じ階層のindexes.tsvを読む
# 書式(タブ区切り): テーブル名 インデックス名 列(カンマ区切り)
# 環境変数: ISU_DB_NAME(既定 isupipe) ISU_DB_USER ISU_DB_PASSWORD(既定はisucon)
set -euo pipefail
cd "$(dirname "$0")"
DB="${ISU_DB_NAME:-isupipe}"; U="${ISU_DB_USER:-isucon}"; P="${ISU_DB_PASSWORD:-isucon}"
q() { mysql -u"$U" -p"$P" "$DB" -N -B -e "$1" 2>/dev/null; }
while IFS=$'\t' read -r table name cols; do
  [ -n "${table:-}" ] && [ "${table:0:1}" != "#" ] || continue
  exists="$(q "SELECT COUNT(*) FROM information_schema.statistics WHERE table_schema='$DB' AND table_name='$table' AND index_name='$name'")"
  if [ "$exists" = "0" ]; then
    echo "add index $table.$name($cols)"
    q "ALTER TABLE \`$table\` ADD INDEX \`$name\` ($cols)"
  fi
done < indexes.tsv
