## Post Execution

# zoxide: frecency ベースのディレクトリジャンプ (z / zi)。
# バイナリは 70_plugin の zinit(gh-r) で導入済み。存在時のみ初期化する。
if (( ${+commands[zoxide]} )); then
  eval "$(zoxide init zsh)"
fi

# starship: プロンプトを管理する。バイナリ導入 (70_plugin) に失敗した場合は
# 素の zsh プロンプトになってしまうので、その旨を一度だけ警告する。
if (( ${+commands[starship]} )); then
  eval "$(starship init zsh)"
else
  print -u2 "starship: コマンドが見つかりません (導入に失敗した可能性があります)"
fi
