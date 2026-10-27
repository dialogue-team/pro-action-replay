.PHONY: help bootstrap try lease-status lease-release wt deploy audit hooks
REF ?= HEAD
LABEL ?= $(REF)

help:
	@echo "make bootstrap                 全台へ計測ツール導入"
	@echo "make try REF=.. LABEL=..       リース->デプロイ->ベンチ->集計->解放"
	@echo "make lease-status              検証環境の使用状況"
	@echo "make lease-release             自分のリースを解放"
	@echo "make wt NAME=..                作業用worktree作成"
	@echo "make audit                     公開前チェック"
	@echo "make hooks                     push前に自動でauditを実行"
bootstrap:
	scripts/bootstrap.sh
try:
	scripts/try.sh $(REF) $(LABEL)
lease-status:
	scripts/lease.sh status
lease-release:
	scripts/lease.sh release
wt:
	scripts/worktree.sh $(NAME) $(BASE)
audit:
	scripts/audit-public.sh
hooks:
	git config core.hooksPath .githooks
