
function existsCommand() {
  builtin command -v $1 > /dev/null 2>&1
}

function source-safe() { if [ -f "$1" ]; then source "$1"; fi }

if existsCommand direnv; then
  eval "$(direnv hook zsh)"
fi

if existsCommand pip; then
  # pip 補完は Python 起動が重い (~90ms) ため結果をキャッシュして source する。
  # (pip バイナリ更新時のみ再生成。compdef は zinit turbo 後に zicdreplay で反映)
  _pip_comp_cache="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/pip-completion.zsh"
  [[ -d ${_pip_comp_cache:h} ]] || mkdir -p "${_pip_comp_cache:h}"
  if [[ ! -s $_pip_comp_cache || ${commands[pip]} -nt $_pip_comp_cache ]]; then
    pip completion --zsh >| "$_pip_comp_cache" 2>/dev/null
  fi
  source-safe "$_pip_comp_cache"
  unset _pip_comp_cache
fi

# NOTE: `pipenv --completion` は新しい pipenv で廃止され空出力になるため呼ばない
#       (Python 起動コストだけが無駄にかかっていた)

if existsCommand fzf; then
  source-safe "$ZDOTDIR/rc/misc/fzf.zsh"
fi

