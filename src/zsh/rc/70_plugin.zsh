# setup zinit

### original
### Added by Zinit's installer
#if [[ ! -f $HOME/.config/dotfiles/zsh/.zinit/bin/zinit.zsh ]]; then
#    print -P "%F{33}▓▒░ %F{220}Installing DHARMA Initiative Plugin Manager (zdharma/zinit)…%f"
#    command mkdir -p "$HOME/.config/dotfiles/zsh/.zinit" && command chmod g-rwX "$HOME/.config/dotfiles/zsh/.zinit"
#    command git clone https://github.com/zdharma/zinit "$HOME/.config/dotfiles/zsh/.zinit/bin" && \
#        print -P "%F{33}▓▒░ %F{34}Installation successful.%f" || \
#        print -P "%F{160}▓▒░ The clone has failed.%f"
#fi
#source "$HOME/.config/dotfiles/zsh/.zinit/bin/zinit.zsh"
#autoload -Uz _zinit
#(( ${+_comps} )) && _comps[zinit]=_zinit
### End of Zinit installer's chunk


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

## completion
zplugin ice wait'!0' lucid as"completion" atload"source $ZHOMEDIR/rc/pluginconfig/zsh-completions_atload.zsh"
zplugin light 'zsh-users/zsh-completions'

## highlighting
zinit ice wait'0' atinit'zpcompinit; zpcdreplay' lucid
zinit light zdharma/fast-syntax-highlighting

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
