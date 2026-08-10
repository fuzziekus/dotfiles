## Completion

if [ -e /usr/local/share/zsh-completions ]; then
  fpath=(/usr/local/share/zsh-completions $fpath)
fi

setopt prompt_subst          # プロンプトに escape sequence (環境変数) を通す

# オプション補完で解説部分を表示
zstyle ':completion:*' verbose yes
# 補完方法の設定。指定した順番に実行する。
## _oldlist 前回の補完結果を再利用する。
## _complete: 普通の補完関数
## _ignored: 補完候補にださないと指定したものも補完候補とする。
## _match: *などのグロブによってコマンドを補完できる
## _prefix: カーソル以降を無視してカーソル位置までで補完する。
## _approximate: 似ている補完候補も補完候補とする。
## _expand: グロブや変数の展開を行う。もともとあった展開と比べて、細かい制御が可能
## _history: 履歴から補完を行う。_history_complete_wordから使われる
## _correct: ミススペルを訂正した上で補完を行う。
zstyle ':completion:*' completer _oldlist _complete _ignored
zstyle ':completion:*:messages' format '%F{yellow}%d'
zstyle ':completion:*:warnings' format '%B%F{red}No matches for:''%F{white}%d%b'
zstyle ':completion:*:descriptions' format '%B%F{white}--- %d ---%f%b'
zstyle ':completion::corrections' format ' %F{green}%d (errors: %e) %f'
zstyle ':completion:*:options' description 'yes'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' keep-prefix
zstyle ':completion:*' recent-dirs-insert both
# 補完候補を色分け (GNU ls の色定義を流用)
zstyle ':completion:*' list-colors "${LS_COLORS}"
zstyle ':completion:*' special-dirs true
# 補完の時に大文字小文字を区別しない (但し、大文字を打った場合は小文字に変換しない)
#zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' matcher-list '' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' '+l:|=* r:|=*'
# 一部のコマンドライン定義は、展開時に時間のかかる処理を行う -- apt-get, dpkg (Debian), rpm (Redhat), urpmi (Mandrake), perlの-Mオプション, bogofilter (zsh 4.2.1以降), fink, mac_apps (MacOS X)(zsh 4.2.2以降)
zstyle ':completion:*' use-cache true
# 補完候補を ←↓↑→ で選択 (補完候補が色分け表示される)
# zstyle show completion menu if 1 or more items to select
zstyle ':completion:*:default' menu select=1
# カレントディレクトリに候補がない場合のみ cdpath 上のディレクトリを候補
zstyle ':completion:*:cd:*' tag-order local-directories path-directories
# 補完リストの順番指定
zstyle ':completion:*:cd:*' group-order local-directories path-directories
# psコマンドを補完する
zstyle ':completion:*:processes' command 'ps x -o pid,s,args'
# sudoコマンドを補完する
zstyle ':completion:*:sudo:*' command-path /usr/local/sbin /usr/local/bin /usr/sbin /usr/bin /sbin /bin
# 変数の添字を補完する
zstyle ':completion:*:*:-subscript-:*' tag-order indexes parameters
# manの補完をセクション番号別に表示させる
zstyle ':completion:*:manuals' separate-sections true
# 更新日順に表示する
zstyle ':completion:*' file-sort 'modification'

# --- fzf-tab: Tab 補完メニューを fzf でファジー選択する (70_plugin で読込) ---
# zstyle は補完実行時に参照されるため、プラグイン読込より前のここで定義してよい。
# FZF_DEFAULT_OPTS を継承する
zstyle ':fzf-tab:*' use-fzf-default-opts yes
# 補完メニューの高さを適切に保つ。
# fzf-tab は内部で候補数から --height を動的計算し、その値を FZF_TMUX_HEIGHT へ
# `:=` で代入・キャッシュする (lib/-ftb-fzf)。このため最初に候補が少ない補完を
# すると小さい高さが固定され、以降 vim <TAB> 等で「1 件ずつしか見えない」状態に
# なる。fzf-flags は fzf コマンド末尾に付き最後の --height が優先されるため、
# ここでアダプティブ高さ (~60%) を指定してキャッシュ値を上書きする。
# `~` により候補が少なければ小さく、多ければ画面の最大 60% まで自動調整される。
# (history/Ctrl-R 側の FZF_DEFAULT_OPTS 高さには影響しない)
zstyle ':fzf-tab:*' fzf-flags '--height=~60%'
# 候補グループ間を , / . で移動する
zstyle ':fzf-tab:*' switch-group ',' '.'
# cd / zoxide のディレクトリ補完は中身を eza でプレビュー (未導入環境は ls)
zstyle ':fzf-tab:complete:cd:*' fzf-preview \
  'eza -1 --color=always --group-directories-first "$realpath" 2>/dev/null || ls -1 "$realpath"'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview \
  'eza -1 --color=always --group-directories-first "$realpath" 2>/dev/null || ls -1 "$realpath"'

# 補完システムの初期化 (compinit) は 70_plugin.zsh の turbo ブロック
# (zicompinit) で一度だけ行う。ここで同期 compinit を走らせても、直後の
# turbo 実行 (プラグインで拡張された fpath を含む) に上書きされるだけで
# 二重コストになるため実行しない。zstyle は補完実行時に参照されるので、
# compinit の前後どちらで定義しても問題ない。
