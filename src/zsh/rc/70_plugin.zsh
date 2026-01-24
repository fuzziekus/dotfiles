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
source "$ZINIT_HOME/bin/zi.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit


# ref: https://blog.katio.net/page/zplugin

## highlighting
zinit ice wait'!0' atinit'zpcompinit; zpcdreplay' lucid
zinit light zdharma/fast-syntax-highlighting

## completion
zinit ice wait'!0' lucid as"completion" blockf
zinit light 'zsh-users/zsh-completions'

## auto-pairing
zinit ice wait'!0' lucid
zinit light -b hlissner/zsh-autopair

## autosuggestion
zinit ice wait'!0' lucid atload"_zsh_autosuggest_start"
zinit light -b zsh-users/zsh-autosuggestions

# program
zinit ice from"gh-r" as"program"
zinit light -b junegunn/fzf-bin

zinit ice pick"ghq*/ghq" from"gh-r" as"program"
zinit light -b x-motemen/ghq 

zinit ice pick"pet*/pet" from"gh-r" as"program"
zinit light -b knqyf263/pet

## mise completion (delayed load after compinit)
if type mise >/dev/null 2>&1; then
  zinit ice wait'1' lucid
  zinit snippet <(eval "$(mise completion zsh)")
fi
