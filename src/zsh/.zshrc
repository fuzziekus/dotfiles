# zshrc

## 各種プラグインを読み込む前にtmuxを起動し、高速化を図る
if type tmux > /dev/null; then
    if [[ -z "$SSH_CONNECTION" && -z "$TMUX" && -z "$INSIDE_EMACS" && -z "$EMACS" && -z "$VIM" && -z "$VSCODE" && "$TERM" != dumb ]]; then
        if tmux has-session; then
            tmux a
        else
            tmux new-session
        fi
        exit
    fi
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

if [ -e /usr/local/share/zsh-completions ]; then
  fpath=(/usr/local/share/zsh-completions $fpath)
fi

if [[ -d /opt/homebrew ]]; then
  # Apple Silicon Mac
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -d /usr/local/Homebrew ]]; then
  # Intel Mac
  eval "$(/usr/local/bin/brew shellenv)"
fi

if type mise >/dev/null 2>&1; then
  eval "$(mise activate zsh)"
fi

on_demand_completion 'mise' 'mise completion zsh'

[[ -f ~/.zshrc.local ]] && . ~/.zshrc.local
