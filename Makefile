.PHONY: help bootstrap try lease-status lease-release wt deploy
REF ?= HEAD
LABEL ?= $(REF)

help:
	@echo "make bootstrap                 全台へ計測ツール導入"
	@echo "make try REF=.. LABEL=..       リース->デプロイ->ベンチ->集計->解放"
	@echo "make lease-status              検証環境の使用状況"
	@echo "make lease-release             自分のリースを解放"
	@echo "make wt NAME=..                作業用worktree作成"
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
