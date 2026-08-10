## Post Execution

# zoxide: frecency ベースのディレクトリジャンプ (z / zi)。
# バイナリは 70_plugin の zinit(gh-r) で導入済み。存在時のみ初期化する。
if (( ${+commands[zoxide]} )); then
  eval "$(zoxide init zsh)"
fi

# starship: STARSHIP=1 のときのみ有効化する切り替え式プロンプト。
# 30_prompt.zsh は STARSHIP 設定時に従来プロンプトを読み込まずに return して
# いるため、ここで starship を初期化する。バイナリ導入 (70_plugin) に失敗した
# 場合は素の zsh プロンプトになってしまうので、その旨を一度だけ警告する。
if [[ -n ${STARSHIP:-} ]]; then
  if (( ${+commands[starship]} )); then
    eval "$(starship init zsh)"
  else
    print -u2 "starship: STARSHIP=1 ですが starship コマンドが見つかりません (導入に失敗した可能性があります)"
  fi
fi
