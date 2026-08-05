
function existsCommand() {
  builtin command -v $1 > /dev/null 2>&1
}

function source-safe() { if [ -f "$1" ]; then source "$1"; fi }

if existsCommand direnv; then
  eval "$(direnv hook zsh)"
fi

if existsCommand pip; then
  # 新しい pip では `pip completion` が削除されているため失敗を無視する
  eval "$(pip completion --zsh 2>/dev/null)"
fi

if existsCommand pipenv; then
  # 新しい pipenv では `--completion` が削除されているため失敗を無視する
  eval "$(pipenv --completion 2>/dev/null)"
fi

if existsCommand fzf; then
  source-safe "$ZDOTDIR/rc/misc/fzf.zsh"
fi

