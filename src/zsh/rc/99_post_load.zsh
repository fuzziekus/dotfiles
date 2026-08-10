## Post Execution

# zoxide: frecency ベースのディレクトリジャンプ (z / zi)。
# バイナリは 70_plugin の zinit(gh-r) で導入済み。存在時のみ初期化する。
# 出力は cwd 非依存の静的コードなので _cache_eval でキャッシュする。
if (( ${+commands[zoxide]} )); then
  _cache_eval zoxide-init zoxide init zsh
fi

# starship: プロンプトを管理する。バイナリ導入 (70_plugin) に失敗した場合は
# 素の zsh プロンプトになってしまうので、その旨を一度だけ警告する。
# init 出力は静的なため _cache_eval でキャッシュ (spawn ~25ms を回避)。
if (( ${+commands[starship]} )); then
  _cache_eval starship-init starship init zsh
else
  print -u2 "starship: コマンドが見つかりません (導入に失敗した可能性があります)"
fi
