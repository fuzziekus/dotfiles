# note : ここを変更するときは注意
export DOTDIR=$HOME/.config/dotfiles
export ZDOTDIR=$DOTDIR/src/zsh

export XDG_CONFIG_HOME="${HOME}/.config"
export XDG_CACHE_HOME="${HOME}/.cache"
export XDG_DATA_HOME="${HOME}/.local/share"

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
typeset -U fpath FPATH   # fpath の重複を排除 (compaudit/compinit の走査対象を削減)
## (N-/): 存在しないディレクトリは登録しない。
##    パス(...): ...という条件にマッチするパスのみ残す。
##            N: NULL_GLOBオプションを設定。
##               globがマッチしなかったり存在しないパスを無視する。
##            -: シンボリックリンク先のパスを評価。
##            /: ディレクトリのみ残す。
path=(
  # ユーザー領域（優先度高）
  $HOME/.local/bin(N-)
  $HOME/bin(N-)
  $HOME/local/bin(N-)
  $XDG_DATA_HOME/go/bin(N-)

  # システム領域
  /usr/local/bin(N-/)
  /usr/local/sbin(N-/)
  /usr/bin(N-/)
  /usr/sbin(N-/)
  /bin(N-/)
  /sbin(N-/)

  # ゲーム（優先度低）
  /usr/local/games(N-/)
  /usr/games(N-/)

  # 既存のPATHから安全なもののみ追加
  ${path}(N-/^W)
)


# mise
if [[ -d $XDG_DATA_HOME/mise ]] ; then
  export MISE_ROOT="$XDG_DATA_HOME/mise"
fi
# mise のグローバル設定 (既定は ~/.config/mise/config.toml)。deploy.sh は $HOME
# 直下の dotfile しか symlink しないため、~/.config へ配置する代わりに
# MISE_GLOBAL_CONFIG_FILE でリポジトリ内のファイルを直接指し示す (starship と同方針)。
# 名前を config.toml/mise.toml にすると project 設定として誤検出されるため mise-config.toml とする。
export MISE_GLOBAL_CONFIG_FILE="$DOTDIR/src/mise-config.toml"

if type "vim" >/dev/null 2>&1; then
  export EDITOR=vim
fi

# Less (man 等の色付けは対話向けのため .zshrc へ移設)
export LESS='-ciMR'
export LESS_CACHE_HOME=$XDG_CACHE_HOME/less
export LESSHISTFILE="$LESS_CACHE_HOME/history"
export PAGER=less

# go
export GOPATH="$XDG_DATA_HOME/go"
export GOENV_DISABLE_GOPATH=1
# docker CLI 設定を XDG 配下へ ($HOME/.docker 汚染を回避)。
# 認証情報や context を持つため既存環境では docker login のやり直しが要る場合がある。
export DOCKER_CONFIG="$XDG_CONFIG_HOME/docker"
# GnuPG のホームを XDG 配下へ ($HOME/.gnupg 汚染を回避)。
# 既存 ~/.gnupg からの移行は init.sh (migrate_gnupg) が冪等に実施する。
export GNUPGHOME="$XDG_DATA_HOME/gnupg"
# zsh (履歴・WORDCHARS 等の対話向け設定は .zshrc へ移設)
export ZSH_CACHE_HOME=$XDG_CACHE_HOME/zsh
export ZSH_DATA_HOME=$XDG_DATA_HOME/zsh
# starship の設定ファイルはリポジトリ内 ($ZDOTDIR/starship.toml) を参照する。
# deploy.sh は $HOME 直下の dotfile しか symlink しないため、~/.config へ配置
# する代わりに STARSHIP_CONFIG で直接指し示す。
export STARSHIP_CONFIG="$ZDOTDIR/starship.toml"

# local
[[ -f ~/.zshenv.local ]] && . ~/.zshenv.local
