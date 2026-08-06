# OS 別の設定 (真に OS 依存な項目のみ)
case ${OSTYPE} in
    darwin*)
        #Mac用の設定
        export CLICOLOR=1
        ;;
    linux*)
        #Linux用の設定
        alias open='xdg-open'
        alias update='sudo apt update && sudo apt upgrade -y'
        ;;
esac


# --- モダン CLI ツールで OS 差異を吸収 (未導入は従来コマンドにフォールバック) ---
# Debian/Ubuntu ではバイナリ名が bat->batcat, fd->fdfind になるため正規化する
typeset bat_cmd fd_cmd
(( ${+commands[batcat]} )) && bat_cmd=batcat
(( ${+commands[bat]}    )) && bat_cmd=bat
(( ${+commands[fdfind]} )) && fd_cmd=fdfind
(( ${+commands[fd]}     )) && fd_cmd=fd

# ls -> eza
if (( ${+commands[eza]} )); then
    alias ls='eza --group-directories-first'
    alias ll='eza -l  --group-directories-first --git'
    alias la='eza -la --group-directories-first --git'
    alias l='eza --group-directories-first'
    alias lt='eza --tree --level=2 --group-directories-first'
else
    if ls --color=auto >/dev/null 2>&1; then
        alias ls='ls --color=auto'   # GNU coreutils (Linux)
    else
        alias ls='ls -G'             # BSD ls (macOS)
    fi
    alias ll='ls -lAF'
    alias la='ls -A'
    alias l='ls -CF'
fi

# grep -> ripgrep
# grep 互換の薄いラッパ。rg は既定で「再帰」かつ「拡張正規表現」なので、
# grep 固有で rg が誤解/拒否するフラグ (-r/-R 再帰, -E/-G 正規表現方言) を吸収する。
# ※ スクリプト内など非対話シェルは rc を読まないため本ラッパの影響を受けない。
if (( ${+commands[rg]} )); then
    grep() {
        emulate -L zsh
        local -a out argv_local
        local a rest
        integer i=1 n=$#
        argv_local=("$@")
        while (( i <= n )); do
            a="${argv_local[i]}"
            case "$a" in
                --recursive|--extended-regexp|--basic-regexp)
                    ;;                              # rg では不要なので捨てる
                # GNU grep のファイル絞り込みを rg の -g グロブへ翻訳
                --include=*)      out+=(-g "${a#--include=}") ;;
                --exclude=*)      out+=(-g "!${a#--exclude=}") ;;
                --exclude-dir=*)  out+=(-g "!${a#--exclude-dir=}") ;;
                --include)        (( i++ )); out+=(-g "${argv_local[i]}") ;;
                --exclude)        (( i++ )); out+=(-g "!${argv_local[i]}") ;;
                --exclude-dir)    (( i++ )); out+=(-g "!${argv_local[i]}") ;;
                -[!-]*)
                    # 連結短オプションから r/R/E/G を除去 (例: -rn -> -n, -rE -> 破棄)
                    rest="${a#-}"
                    rest="${rest//[rREG]/}"
                    [[ -n "$rest" ]] && out+=("-$rest")
                    ;;
                *)
                    out+=("$a")                     # パターン・パス・その他はそのまま
                    ;;
            esac
            (( i++ ))
        done
        command rg "${out[@]}"
    }
else
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# cat/less -> bat
if [[ -n "$bat_cmd" ]]; then
    alias cat="$bat_cmd --paging=never"
    alias less="$bat_cmd"
    export PAGER="$bat_cmd"
    export MANPAGER="sh -c 'col -bx | $bat_cmd -l man -p'"
fi

# find -> fd
if [[ -n "$fd_cmd" ]]; then
    alias find="$fd_cmd"
fi

alias dot="cd $DOTDIR"
alias h="history -n 1"

alias cp='cp -v'
alias u='builtin cd ..'

alias rup='revealup serve'

alias zs='vim $ZDOTDIR/.zshrc'
alias zr="exec $SHELL"

# sudo の後のコマンドでエイリアスを有効にする
alias sudo='sudo '

# グローバルエイリアス
alias -g L='| less'
alias -g G='| grep'

# クリップボードコピー用ヘルパ (OS 差異を吸収)
# mollifier delta blog : http://mollifier.hatenablog.com/entry/20100317/p1
if (( ${+commands[pbcopy]} )); then
    # Mac
    _clipcopy() { pbcopy }
elif (( ${+commands[xsel]} )); then
    # Linux
    _clipcopy() { xsel --input --clipboard }
elif (( ${+commands[putclip]} )); then
    # Cygwin
    _clipcopy() { putclip }
else
    _clipcopy() { cat }
fi

# C で標準出力をクリップボードにコピーする
alias -g C='| _clipcopy'

# git の最新コミットIDをクリップボードにコピーする
copy_commit_id() { git rev-parse HEAD | tr -d '\n' | _clipcopy }
