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

# turbo の zicompinit が使う zcompdump を XDG キャッシュへ固定する。
# 未指定だと ${ZDOTDIR}/.zcompdump (= repo 内 src/zsh/.zcompdump) が生成される。
ZINIT[ZCOMPDUMP_PATH]="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump"

# compinit は下の turbo ブロック (zicompinit) で「一度だけ」実行する。
# 以前は 20_completion.zsh でも同期 compinit を走らせていたが、その出力は
# 直後の turbo 実行 (プラグインで拡張された fpath を含む) に上書きされるだけで
# ユーザーには見えず、~7ms を二重に消費していたため撤去した。
# dump が 24h 以内なら -C で fpath 監査/再走査をスキップして高速化し、
# 古い/未生成なら full compinit (COMPINIT_OPTS 空) で再構築する。
[[ -d ${ZINIT[ZCOMPDUMP_PATH]:h} ]] || mkdir -p "${ZINIT[ZCOMPDUMP_PATH]:h}"
if [[ -n ${ZINIT[ZCOMPDUMP_PATH]}(#qN.mh-24) ]]; then
  ZINIT[COMPINIT_OPTS]=-C
fi

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
##
## autosuggestions のチューニング (プラグイン起動前に定義する必要がある):
##   STRATEGY=(history completion): 履歴に無くても補完システムから候補を出す。
##   MANUAL_REBIND: precmd/preexec での自動 rebind を止め、起動をわずかに高速化。
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_MANUAL_REBIND=1
zinit wait lucid for \
 atinit"zicompinit; zicdreplay; _register_on_demand_completions" \
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

# starship: プロンプトを管理する。初期化は 99_post_load.zsh、設定は
# $ZDOTDIR/starship.toml を参照する。
zinit ice from"gh-r" as"program" pick"starship"
zinit light -b starship/starship
