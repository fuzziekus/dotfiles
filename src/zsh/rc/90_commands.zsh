
function existsCommand() {
  builtin command -v $1 > /dev/null 2>&1
}

function source-safe() { if [ -f "$1" ]; then source "$1"; fi }

if existsCommand direnv; then
  eval "$(direnv hook zsh)"
fi

# NOTE: pip 補完は zsh-users/zsh-completions プラグインが `_pip` を提供するため
#       ここで `pip completion --zsh` を source する必要はない。
#       (同期 compdef は非同期 zicompinit に上書きされ実質デッドだった)

# NOTE: `pipenv --completion` は新しい pipenv で廃止され空出力になるため呼ばない
#       (Python 起動コストだけが無駄にかかっていた)

if existsCommand fzf; then
  source-safe "$ZDOTDIR/rc/misc/fzf.zsh"
fi

