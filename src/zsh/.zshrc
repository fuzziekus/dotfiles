# zshrc

## 各種プラグインを読み込む前にtmuxを起動し、高速化を図る
if [[ -z "$TMUX" && -z "$INSIDE_EMACS" && -z "$EMACS" && -z "$VIM" && -z "$VSCODE" && "$TERM" != dumb ]]; then
#if [[ -z "$TMUX" ]] && [[ "$VSCODE" == "" ]]; then
    HAS_SESSION="`tmux list-sessions`"
    export LC_ALL
    if [[ -z "$HAS_SESSION" ]]; then
        tmux new-session
    else
        tmux a
    fi
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
