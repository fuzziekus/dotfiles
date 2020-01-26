
function existsCommand() {
  builtin command -v $1 > /dev/null 2>&1
}

function source-safe() { if [ -f "$1" ]; then source "$1"; fi }

if existsCommand direnv; then
  eval "$(direnv hook zsh)"
fi

if existsCommand pip; then
  eval "$(pip completion --zsh)"
fi

if existsCommand pipenv; then
  eval "$(pipenv --completion)"
fi

if existsCommand fzf; then
  source-safe "$ZDOTDIR/rc/misc/fzf.zsh"
fi

