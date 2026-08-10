# bindkey

# 端末設定
stty intr '^C'        # Ctrl+C に割り込み
stty susp '^Z'        # Ctrl+Z にサスペンド
stty stop undef

# zsh のキーバインド (EDITOR=vi かでも判断)
bindkey -e    # emacs 風

# ↑/↓ で「カーソル前に入力済みの文字列で始まる履歴」だけを辿る。
# 例: `git ` と入力して ↑ を押すと git で始まる履歴だけを遡れる。
# 入力が空のときは通常の履歴移動として振る舞う。
# NOTE: emacs キーマップへ明示登録 (この後に他所で bindkey -e されても維持)。
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey -M emacs '^[[A' up-line-or-beginning-search    # カーソルキー ↑ (normal)
bindkey -M emacs '^[[B' down-line-or-beginning-search  # カーソルキー ↓ (normal)
bindkey -M emacs '^[OA' up-line-or-beginning-search    # カーソルキー ↑ (application)
bindkey -M emacs '^[OB' down-line-or-beginning-search  # カーソルキー ↓ (application)
