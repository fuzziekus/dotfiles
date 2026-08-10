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

# starship の設定ファイルはリポジトリ内 ($ZDOTDIR/starship.toml) を参照する。
# deploy.sh は $HOME 直下の dotfile しか symlink しないため、~/.config へ配置
# する代わりに STARSHIP_CONFIG で直接指し示す。
export STARSHIP_CONFIG="$ZDOTDIR/starship.toml"
