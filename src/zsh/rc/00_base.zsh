## base configuration

# core
ulimit -c unlimited

# ファイル作成時のデフォルトパーミッション
umask 022

# カレントディレクトリ中にサブディレクトリがない場合の cd の検索先
cdpath=("$HOME")

# autoload
autoload -Uz run-help
autoload -Uz add-zsh-hook
autoload -Uz colors && colors
autoload -Uz is-at-least

# 拡張子ごとのカラーリング
[ -f "$ZDOTDIR/dircolors" ] && eval $(dircolors "$ZDOTDIR/dircolors")
