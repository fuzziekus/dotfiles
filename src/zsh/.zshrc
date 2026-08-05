# zshrc

## Homebrew / mise は毎回のプロセス起動が重い (brew shellenv ~18ms, mise activate ~17ms)。
## 初期化結果をキャッシュして source し、バイナリ更新時のみ再生成する。
() {
  local cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
  # source される生成物 (brew/mise shellenv) を置くため、
  # 他ユーザが書き込めないよう 700 で作成しパーミッションを固定する。
  [[ -d $cache_dir ]] || mkdir -p -m 700 "$cache_dir"
  chmod 700 "$cache_dir" 2>/dev/null

  local brew_bin
  if [[ -x /opt/homebrew/bin/brew ]]; then
    brew_bin=/opt/homebrew/bin/brew    # Apple Silicon Mac
  elif [[ -x /usr/local/bin/brew ]]; then
    brew_bin=/usr/local/bin/brew       # Intel Mac
  fi
  if [[ -n $brew_bin ]]; then
    local brew_cache="$cache_dir/brew-shellenv.zsh"
    if [[ ! -s $brew_cache || $brew_bin -nt $brew_cache ]]; then
      "$brew_bin" shellenv >| "$brew_cache"
    fi
    source "$brew_cache"
  fi

  if (( ${+commands[mise]} )); then
    local mise_cache="$cache_dir/mise-activate.zsh"
    if [[ ! -s $mise_cache || ${commands[mise]} -nt $mise_cache ]]; then
      mise activate zsh >| "$mise_cache"
    fi
    source "$mise_cache"
  fi
}

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


[[ -f ~/.zshrc.local ]] && . ~/.zshrc.local
