# setup zi
## Manual Install
if [ -z "$ZI_ROOT" ]; then
    ZI_ROOT="$XDG_DATA_HOME/zi"
fi

if ! test -d "$ZI_ROOT"; then
    \mkdir "$ZI_ROOT"
    \chmod g-rwX "$ZI_ROOT"
    \git clone https://github.com/z-shell/zi.git "$ZI_ROOT/bin"
fi

typeset -gAH ZI
ZI[HOME_DIR]="$ZI_ROOT"
source "$ZI_ROOT/bin/zi.zsh"
autoload -Uz _zi
(( ${+_comps} )) && _comps[zi]=_zi


## syntax highlighting / completion / autosuggestion
## compinit はこの for ブロック内 (zicompinit) で一度だけ実行し、
## 各プラグインを重複なく turbo モードで読み込む
zi wait lucid for \
 atinit"ZI[COMPINIT_OPTS]=-C; zicompinit; zicdreplay" \
   z-shell/F-Sy-H \
 blockf \
   zsh-users/zsh-completions \
 atload"!_zsh_autosuggest_start" \
   zsh-users/zsh-autosuggestions

## auto-pairing
zi ice wait'!0' lucid
zi light -b hlissner/zsh-autopair

# program
zi ice from"gh-r" as"program"
zi light -b junegunn/fzf-bin

zi ice pick"ghq*/ghq" from"gh-r" as"program"
zi light -b x-motemen/ghq 

zi ice pick"pet*/pet" from"gh-r" as"program"
zi light -b knqyf263/pet
