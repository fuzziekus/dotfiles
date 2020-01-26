# zshrc

## 各種プラグインを読み込む前にtmuxを起動し、高速化を図る
if [[ -z "$TMUX" && -z "$INSIDE_EMACS" && -z "$EMACS" && -z "$VIM" && "$TERM" != dumb ]]; then
    export LC_ALL
    tmux new-session
    exit
fi

## BASE
source-safe() { if [ -f "$1" ]; then source "$1"; fi }

for rc in $ZDOTDIR/rc/*.zsh
do
    if [ -f "$rc" ]; then
        source "$rc"
    else
        continue
    fi
done
