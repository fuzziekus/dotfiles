# bindkey

# 端末設定
stty intr '^C'        # Ctrl+C に割り込み
stty susp '^Z'        # Ctrl+Z にサスペンド
stty stop undef

# zsh のキーバインド (EDITOR=vi かでも判断)
bindkey -e    # emacs 風
