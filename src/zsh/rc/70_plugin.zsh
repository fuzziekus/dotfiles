# setup zinit (zdharma-continuum)
## Manual Install
if [ -z "$ZINIT_HOME" ]; then
    ZINIT_HOME="$XDG_DATA_HOME/zinit/zinit.git"
fi

# 旧 zi 環境から export された ZPFX/ZINIT[HOME_DIR] を継承すると
# ~/.local/share/zi 側にファイルが作られ fpath も汚染されるため、
# zinit の各ディレクトリを zinit 配下へ明示的に固定する。
typeset -gA ZINIT
ZINIT[HOME_DIR]="$XDG_DATA_HOME/zinit"
ZINIT[BIN_DIR]="${ZINIT[HOME_DIR]}/zinit.git"
export ZPFX="${ZINIT[HOME_DIR]}/polaris"

if ! test -d "$ZINIT_HOME"; then
    \mkdir -p "$(dirname "$ZINIT_HOME")"
    \chmod g-rwX "$(dirname "$ZINIT_HOME")"
    \git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

source "$ZINIT_HOME/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit


## syntax highlighting / completion / autosuggestion
## compinit はこの for ブロック内 (zicompinit) で一度だけ実行し、
## 各プラグインを重複なく turbo モードで読み込む
##
## ロード順の注意:
##   fzf-tab は「compinit の後」かつ「widget をラップするプラグイン
##   (fast-syntax-highlighting / autosuggestions) より前」に読む必要がある。
##   そのため compinit を行う atinit を fzf-tab に付け、先頭でロードする。
zinit wait lucid for \
 atinit"ZINIT[COMPINIT_OPTS]=-C; zicompinit; zicdreplay; _register_on_demand_completions" \
   Aloxaf/fzf-tab \
   zdharma-continuum/fast-syntax-highlighting \
 blockf \
   zsh-users/zsh-completions \
 atload"!_zsh_autosuggest_start" \
   zsh-users/zsh-autosuggestions

## auto-pairing
zinit ice wait'!0' lucid
zinit light -b hlissner/zsh-autopair

# program
zinit ice from"gh-r" as"program"
zinit light -b junegunn/fzf

zinit ice pick"ghq*/ghq" from"gh-r" as"program"
zinit light -b x-motemen/ghq

zinit ice pick"pet*/pet" from"gh-r" as"program"
zinit light -b knqyf263/pet

zinit ice from"gh-r" as"program" pick"zoxide"
zinit light -b ajeetdsouza/zoxide

# starship: STARSHIP=1 のときのみ導入する (未設定なら従来プロンプトのまま)。
# 初期化は 99_post_load.zsh、設定は $ZDOTDIR/starship.toml を参照する。
if [[ -n ${STARSHIP:-} ]]; then
  zinit ice from"gh-r" as"program" pick"starship"
  zinit light -b starship/starship
fi
