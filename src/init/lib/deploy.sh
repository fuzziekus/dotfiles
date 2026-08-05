#!/usr/bin/env bash

# script: deploy.sh
# brief : $HOME へ dotfiles を安全にシンボリックリンクする。
#   - 既に正しいリンクなら何もしない (冪等)
#   - 既存の実ファイル/ディレクトリ/誤リンクは削除せずバックアップしてから張り替える
#   - unlink モードでは、当リポジトリを指すリンクのみ削除し実ファイルには触れない
# usage : DOTPATH=... HOME=... bash deploy.sh [deploy|unlink]

set -euo pipefail

: "${DOTPATH:?DOTPATH is required}"
: "${HOME:?HOME is required}"

# Makefile の EXCLUSIONS と揃える
EXCLUSIONS=(.DS_Store .git .gitmodules .travis.yml)
BACKUP_DIR="${DOTFILES_BACKUP_DIR:-$HOME/.dotfiles_backup/$(date +%Y%m%d_%H%M%S)}"

is_excluded() {
  local name=$1 ex
  for ex in "${EXCLUSIONS[@]}"; do
    [[ $name == "$ex" ]] && return 0
  done
  return 1
}

# src/ 直下のドットファイル (.??* = 先頭ドット + 2文字以上) を列挙する
candidates() {
  local path name
  shopt -s nullglob
  for path in "$DOTPATH"/src/.??*; do
    name=$(basename "$path")
    is_excluded "$name" && continue
    printf '%s\n' "$path"
  done
}

deploy() {
  local src name target backed_up=0
  while IFS= read -r src; do
    name=$(basename "$src")
    target="$HOME/$name"

    # 既に当リポジトリを指す正しいリンクなら何もしない (冪等)
    if [[ -L $target && $(readlink "$target") == "$src" ]]; then
      printf 'unchanged: %s\n' "$target"
      continue
    fi

    # 既存の実ファイル/ディレクトリ/誤ったリンクは削除せずバックアップする
    if [[ -e $target || -L $target ]]; then
      mkdir -p "$BACKUP_DIR"
      mv "$target" "$BACKUP_DIR/"
      printf 'backup:    %s -> %s/%s\n' "$target" "$BACKUP_DIR" "$name"
      backed_up=1
    fi

    ln -sfn "$src" "$target"
    printf 'link:      %s -> %s\n' "$target" "$src"
  done < <(candidates)

  if [[ $backed_up -eq 1 ]]; then
    printf '\nExisting files were backed up under: %s\n' "$BACKUP_DIR"
  fi
}

unlink_all() {
  local src name target
  while IFS= read -r src; do
    name=$(basename "$src")
    target="$HOME/$name"

    # 当リポジトリを指すリンクのみ削除する (実ファイルや他のリンクは触らない)
    if [[ -L $target && $(readlink "$target") == "$src" ]]; then
      rm -f "$target"
      printf 'unlink:    %s\n' "$target"
    else
      printf 'skip:      %s (not a link to this repo)\n' "$target"
    fi
  done < <(candidates)
}

main() {
  case "${1:-deploy}" in
    deploy) deploy ;;
    unlink) unlink_all ;;
    *)
      echo "usage: deploy.sh [deploy|unlink]" >&2
      exit 2
      ;;
  esac
}

main "$@"
