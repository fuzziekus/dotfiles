## base configuration

# core
# コアダンプは既定で無効化 (ディスク圧迫・情報漏洩防止)。必要時のみ手動で緩和する。
ulimit -c 0

# ファイル作成時のデフォルトパーミッション
umask 022

# カレントディレクトリ中にサブディレクトリがない場合の cd の検索先
cdpath=("$HOME")

# autoload
autoload -Uz run-help
autoload -Uz add-zsh-hook
autoload -Uz colors && colors
autoload -Uz is-at-least

# 拡張子ごとのカラーリング
if [[ -f "$ZDOTDIR/dircolors" ]]; then
    type dircolors  > /dev/null 2>&1  && eval $(dircolors "$ZDOTDIR/dircolors")
    type gdircolors > /dev/null 2>&1  && eval $(gdircolors "$ZDOTDIR/dircolors")
fi

# _cache_eval: `starship init` 等、毎回バイナリを spawn する静的な初期化出力を
# キャッシュして source する。生成物が cwd 非依存のものだけに使うこと。
# .zshrc 冒頭の brew/mise キャッシュと同じ方針で、対象バイナリがキャッシュより
# 新しい (更新された) 場合のみ再生成する。
#   使い方: _cache_eval <名前> <コマンド...>
# キャッシュディレクトリ (700) は .zshrc 冒頭で作成済み。
_cache_eval() {
  local name=$1; shift
  local cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
  local cache="$cache_dir/${name}.zsh"
  local bin="${commands[$1]}"
  [[ -d $cache_dir ]] || mkdir -p -m 700 "$cache_dir"
  if [[ ! -s $cache || ( -n $bin && $bin -nt $cache ) ]]; then
    "$@" >| "$cache" 2>/dev/null
  fi
  source "$cache"
}
