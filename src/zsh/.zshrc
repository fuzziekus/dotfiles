# zshrc

## 各種プラグインを読み込む前にtmuxを起動し、高速化を図る
if [[ -z "$TMUX" && -z "$INSIDE_EMACS" && -z "$EMACS" && -z "$VIM" && -z "$VSCODE" && "$TERM" != dumb ]]; then
    if tmux has-session; then
        tmux a
    else
        tmux new-session
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

[[ -f ~/.zshrc.local ]] && . ~/.zshrc.local
