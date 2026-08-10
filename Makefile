DOTPATH    := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))
CANDIDATES := $(wildcard src/.??*)
EXCLUSIONS := .DS_Store .git .gitmodules .travis.yml .gitconfig.local.example
DOTFILES   := $(filter-out $(EXCLUSIONS), $(CANDIDATES))
# このリポジトリのデフォルトブランチ (master/main どちらでも動くよう動的取得)
BRANCH     := $(shell git symbolic-ref --short HEAD 2>/dev/null || echo main)

.DEFAULT_GOAL := help
.PHONY : all list deploy init test update install clean help

all:

check:
	@echo $(DOTFILES)

list: ## Show dot files in this repo
	@$(foreach val, $(DOTFILES), /bin/ls -dF $(abspath $(val));)

deploy: ## Create symlinks into $HOME (backs up any existing files)
	@echo '==> Deploying dotfiles into $(HOME) (existing files are backed up, never overwritten)'
	@DOTPATH=$(DOTPATH) HOME=$(HOME) bash $(DOTPATH)/src/init/lib/deploy.sh deploy

init: ## Setup environment settings
	@DOTPATH=$(DOTPATH) bash $(DOTPATH)/src/init/init.sh

test: ## Test dotfiles and init scripts (shellcheck + zsh syntax)
	@echo '==> shellcheck (bootstrap/init scripts)'
	@if command -v shellcheck >/dev/null 2>&1; then \
		shellcheck -x -s bash --severity=error \
			$(DOTPATH)/src/init/install \
			$(DOTPATH)/src/init/init.sh \
			$(DOTPATH)/src/init/lib/util.sh \
			$(DOTPATH)/src/init/lib/deploy.sh \
			$(DOTPATH)/src/init/lib/macos.sh; \
	else \
		echo 'shellcheck not found; skipping'; \
	fi
	@echo '==> zsh -n (rc syntax check)'
	@if command -v zsh >/dev/null 2>&1; then \
		for f in $(DOTPATH)/src/zsh/rc/*.zsh $(DOTPATH)/src/zsh/rc/misc/*.zsh; do \
			zsh -n "$$f" && echo "OK: $$f" || exit 1; \
		done; \
	else \
		echo 'zsh not found; skipping'; \
	fi
	@echo '==> All tests passed'

update: ## Fetch changes for this repo
	git pull origin $(BRANCH)
	git submodule update --init --remote --recursive

install: update deploy init ## Run make update, deploy, init
	@exec $$SHELL

clean: ## Remove deployed symlinks (repo kept; use FORCE=1 to also delete the repo)
	@echo '==> Removing deployed dotfile symlinks (real files are left untouched)...'
	@DOTPATH=$(DOTPATH) HOME=$(HOME) bash $(DOTPATH)/src/init/lib/deploy.sh unlink
	@if [ "$(FORCE)" = "1" ]; then \
		echo '==> FORCE=1: removing repository at $(DOTPATH)'; \
		rm -rf "$(DOTPATH)"; \
	else \
		echo 'Repository kept. Re-run with FORCE=1 to also delete $(DOTPATH).'; \
	fi

help: ## Self-documented Makefile
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
	| sort \
	| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
