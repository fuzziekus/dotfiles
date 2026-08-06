## Post Execution

# zoxide: frecency ベースのディレクトリジャンプ (z / zi)。
# バイナリは 70_plugin の zinit(gh-r) で導入済み。存在時のみ初期化する。
if (( ${+commands[zoxide]} )); then
  eval "$(zoxide init zsh)"
fi
