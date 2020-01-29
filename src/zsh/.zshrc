# zshrc

## 各種プラグインを読み込む前にtmuxを起動し、高速化を図る
if [[ -z "$TMUX" && -z "$INSIDE_EMACS" && -z "$EMACS" && -z "$VIM" && -z "$VSCODE_PID"  &&  "$TERM" != dumb ]]; then
    HAS_SESSION="`tmux list-sessions`"
    export LC_ALL
    if [[ -z "$HAS_SESSION" ]];
        tmux new-session
    fi
    tmux a
    #exit
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
