# OS 別の設定
case ${OSTYPE} in
    darwin*)
        #Mac用の設定
        alias open='open'
        export CLICOLOR=1
        alias ls='ls'
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

alias ll='ls --almost-all -lF'
alias la='ls -A'
alias l='ls -CF'
alias cp='cp -v'
alias u='builtin cd ..'

alias rup='revealup serve'

alias zs="vim ~/.zshrc"
alias zr="exec $SHELL"

# git の最新コミットIDをクリップボードにコピーする
alias copy_commit_id="git log  --oneline | head -n 1 | cut -f1 -d " " | pbcopy "

# sudo の後のコマンドでエイリアスを有効にする
alias sudo='sudo '

# グローバルエイリアス
alias -g L='| less'
alias -g G='| grep'

# C で標準出力をクリップボードにコピーする
# mollifier delta blog : http://mollifier.hatenablog.com/entry/20100317/p1
if which pbcopy >/dev/null 2>&1 ; then
    # Mac
    alias -g C='| pbcopy'
elif which xsel >/dev/null 2>&1 ; then
    # Linux
    alias -g C='| xsel --input --clipboard'
elif which putclip >/dev/null 2>&1 ; then
    # Cygwin
    alias -g C='| putclip'
fi


