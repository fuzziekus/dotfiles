# setup zinit
## Manual Install
if [ -z "$ZINIT_HOME" ]; then
    ZINIT_HOME="$XDG_DATA_HOME/zinit"
fi

if ! test -d "$ZINIT_HOME"; then
    \mkdir "$ZINIT_HOME"
    \chmod g-rwX "$ZINIT_HOME"
    \git clone https://github.com/zdharma/zinit.git "$ZINIT_HOME/bin"
fi

typeset -gAH ZINIT
ZINIT[HOME_DIR]="$ZINIT_HOME"
source "$ZINIT_HOME/bin/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

## highlighting
zinit ice wait'0' atinit'zpcompinit; zpcdreplay' lucid
zinit light zdharma/fast-syntax-highlighting

## completion
zplugin ice wait'!0' lucid as"completion"
zplugin light 'zsh-users/zsh-completions'

## auto-pairing
zinit ice wait'0' lucid
zinit light -b hlissner/zsh-autopair

## autosuggestion
zinit ice wait'0' lucid
zinit light -b zsh-users/zsh-autosuggestions

# program
zinit ice from"gh-r" as"program"
zinit light -b junegunn/fzf-bin

zinit ice pick"ghq*/ghq" from"gh-r" as"program"
zinit light -b x-motemen/ghq 
