# OS 別の設定
case ${OSTYPE} in
    darwin*)
        #Mac用の設定
        export CLICOLOR=1
        ;;
    linux*)
        #Linux用の設定
        alias open='xdg-open'
        alias ls='ls -A -F'
        alias update='sudo apt update && sudo apt upgrade -y'
        ;;
esac


# common
if [ -x /usr/bin/dircolors ]; then
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

alias dot="cd $DOTDIR"
alias h="history -n 1"

alias ll='ls -lAF'
alias la='ls -A'
alias l='ls -CF'
alias cp='cp -v'
alias u='builtin cd ..'

alias rup='revealup serve'

alias zs="vim ~/.zshrc"
alias zr="exec $SHELL"

# sudo の後のコマンドでエイリアスを有効にする
alias sudo='sudo '

# グローバルエイリアス
alias -g L='| less'
alias -g G='| grep'

# クリップボードコピー用ヘルパ (OS 差異を吸収)
# mollifier delta blog : http://mollifier.hatenablog.com/entry/20100317/p1
if which pbcopy >/dev/null 2>&1 ; then
    # Mac
    _clipcopy() { pbcopy }
elif which xsel >/dev/null 2>&1 ; then
    # Linux
    _clipcopy() { xsel --input --clipboard }
elif which putclip >/dev/null 2>&1 ; then
    # Cygwin
    _clipcopy() { putclip }
else
    _clipcopy() { cat }
fi

# C で標準出力をクリップボードにコピーする
alias -g C='| _clipcopy'

# git の最新コミットIDをクリップボードにコピーする
copy_commit_id() { git rev-parse HEAD | tr -d '\n' | _clipcopy }


