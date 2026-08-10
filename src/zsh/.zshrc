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

## 対話シェル向け設定 (.zshenv から移設: 非対話シェル/スクリプトでは不要)
# 履歴
export HISTFILE="$ZSH_CACHE_HOME/history"
export HISTSIZE=1000000
export SAVEHIST=1000000
export WORDCHARS='*?_-.[]~=&;!#$%^(){}<>|'
export CORRECT_IGNORE='_*'        # 補完定義ファイルをコマンド修正から除外
export CORRECT_IGNORE_FILE='.*'   # ドットで始まるファイルをコマンド修正から除外
export REPORTTIME=30              # 指定秒以上かかったコマンドの実行時間を表示

# GPG 署名 (gpgsign=true) 時に pinentry が正しい端末を使うため。
# $(tty) は制御端末を持つ対話シェルでのみ意味を持つので .zshenv ではなくここに置く。
export GPG_TTY=$(tty)

# 対話利用時のみ必要なディレクトリを用意 (ZSH_CACHE_HOME は上のブロックで作成済み)
[[ -d $ZSH_DATA_HOME ]] || mkdir -p "$ZSH_DATA_HOME"
[[ -d $LESS_CACHE_HOME ]] || mkdir -p "$LESS_CACHE_HOME"

# less: man ページ等の色付け
export LESS_TERMCAP_{mb,md,me,se,so,ue,us}
LESS_TERMCAP_mb=$'\e[1;31m'
LESS_TERMCAP_md=$'\e[1;38;05;75m'
LESS_TERMCAP_me=$'\e[0m'
LESS_TERMCAP_se=$'\e[0m'
LESS_TERMCAP_so=$'\e[1;44m'
LESS_TERMCAP_ue=$'\e[0m'
LESS_TERMCAP_us=$'\e[1;36m'

## 各種プラグインを読み込む前にtmuxを起動し、高速化を図る
if type tmux > /dev/null; then
    if [[ -z "$SSH_CONNECTION" && -z "$TMUX" && -z "$INSIDE_EMACS" && -z "$EMACS" && -z "$VIM" && -z "$VSCODE" && "$TERM" != dumb ]]; then
        # NOTE: continuum の @continuum-restore が有効な場合、コールドブート時は
        # サーバ起動 (new-session) を契機に保存済みセッションが自動復元される。
        # 空セッションが復元分と併存するようなら、実機で挙動を確認のこと。
        if tmux has-session 2> /dev/null; then
            exec tmux attach
        else
            exec tmux new-session
        fi
    fi
fi

## BASE
for rc in $ZDOTDIR/rc/*.zsh
do
    if [ -f "$rc" ]; then
        source "$rc"
    else
        continue
    fi
done


[[ -f ~/.zshrc.local ]] && . ~/.zshrc.local
