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
if [[ -f "$ZDOTDIR/dircolors" ]]; then
    type dircolors  > /dev/null 2>&1  && eval $(dircolors "$ZDOTDIR/dircolors")
    type gdircolors > /dev/null 2>&1  && eval $(gdircolors "$ZDOTDIR/dircolors")
fi 
