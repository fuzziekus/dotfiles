# note : ここを変更するときは注意
export DOTDIR=$HOME/.config/dotfiles
export ZDOTDIR=$DOTDIR/src/zsh

if [[ -f ~/.xprofile ]]; then 
    source ~/.xprofile
else
    export XDG_CONFIG_HOME="${HOME}/.config"
    export XDG_CACHE_HOME="${HOME}/.cache"
    export XDG_DATA_HOME="${HOME}/.local/share"
fi

# Language
if [ ${EUID:-$UID} -eq 0 ]; then
  export LANGUAGE=C
  export LC_ALL=C
  export LANG=C
else
  export LC_COLLATE=ja_JP.UTF-8
  export LC_CTYPE=ja_JP.UTF-8
  export LC_MESSAGES=en_US.UTF-8
  export LC_MONETARY=ja_JP.UTF-8
  export LC_NUMERIC=ja_JP.UTF-8
  export LC_TELEPHONE=ja_JP.UTF-8
  export LC_TIME=en_US.UTF-8
  export LANG=ja_JP.UTF-8
fi

typeset -U path PATH
## (N-/): 存在しないディレクトリは登録しない。
##    パス(...): ...という条件にマッチするパスのみ残す。
##            N: NULL_GLOBオプションを設定。
##               globがマッチしなかったり存在しないパスを無視する。
##            -: シンボリックリンク先のパスを評価。
##            /: ディレクトリのみ残す。
path=(
  /bin(N-)
  $HOME/bin(N-)
  $HOME/local/bin(N-)
  $HOME/.local/bin(N-)
  /usr/local/bin(N-/)
  /usr/bin(N-/)
  /usr/games(N-/)
  /usr/local/sbin(N-)
  /usr/local/bin(N-)
  /usr/sbin(N-)
  /sbin(N-)
  /usr/bin(N-)
  /usr/games(N-)
  /usr/local/games(N-)
  ${^path}(N-/^W)
)


# anyenv
if [[ -d $XDG_DATA_HOME/anyenv ]] ; then
  export ANYENV_ROOT="$XDG_DATA_HOME/anyenv"
  path=(
    $ANYENV_ROOT/bin
    $path
  )
  eval "$(anyenv init - zsh)"
fi

if type "vim" >/dev/null 2>&1; then
  export EDITOR=vim
fi

# Less
export LESS='-ciMR' LESS_TERMCAP_{mb,md,me,se,so,ue,us}
LESS_TERMCAP_mb=$'\e[1;31m'
LESS_TERMCAP_md=$'\e[1;38;05;75m'
LESS_TERMCAP_me=$'\e[0m'
LESS_TERMCAP_se=$'\e[0m'
LESS_TERMCAP_so=$'\e[1;44m'
LESS_TERMCAP_ue=$'\e[0m'
LESS_TERMCAP_us=$'\e[1;36m'
export LESS_CACHE_HOME=$XDG_CACHE_HOME/less
[[ ! -d $LESS_CACHE_HOME ]] && \mkdir $LESS_CACHE_HOME
export LESSHISTFILE="$LESS_CACHE_HOME/history"
export PAGER=less

# go
export GOPATH="$HOME/.local"

# zsh
export ZSH_CACHE_HOME=$XDG_CACHE_HOME/zsh
[[ ! -d $ZSH_CACHE_HOME ]] && \mkdir $ZSH_CACHE_HOME
export ZSH_DATA_HOME=$XDG_DATA_HOME/zsh
[[ ! -d $ZSH_DATA_HOME ]] && \mkdir $ZSH_DATA_HOME
export HISTFILE="$ZSH_CACHE_HOME/history"
export HISTSIZE=1000000
export SAVEHIST=1000000
export WORDCHARS='*?_-.[]~=&;!#$%^(){}<>|'
export CORRECT_IGNORE='_*' #補完定義ファイルをコマンド修正から除外
export CORRECT_IGNORE_FILE='.*' #ドットで始まるファイルをコマンド修正から除外
export REPORTTIME=30 #指定時間(秒)以上かかったコマンドの実行時間などを表示

# local
[[ -f ~/.zshenv.local ]] && . ~/.zshenv.local
