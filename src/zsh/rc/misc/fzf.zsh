export FZF_DEFAULT_OPTS='--height 40% --reverse --border'

# tmux 内では fzf の結果を popup 表示し、コンテキストスイッチを減らす。
# 【重要】fzf をグローバルに alias/ラップすると内部で fzf を呼ぶ fzf-tab を壊すため、
#         ここで定義した _fzf_ui を各カスタムウィジェット内でのみ使う。
#         fzf-tab および ^r (select-history) は対象外。
# fzf 0.53+ は popup 表示用の --tmux フラグを内蔵する。本 repo は fzf を gh-r
# バイナリで導入し外部 fzf-tmux スクリプトは同梱されないため、この内蔵フラグを使う。
# フラグ対応可否は起動時に一度だけ判定してキャッシュする。
typeset -g _FZF_HAS_TMUX_FLAG=0
if fzf --help 2>/dev/null | grep -q -- '--tmux'; then
  _FZF_HAS_TMUX_FLAG=1
fi
_fzf_ui() {
  if [[ -n $TMUX ]] && (( _FZF_HAS_TMUX_FLAG )); then
    fzf --tmux center,80% "$@"
  else
    fzf "$@"
  fi
}


# fd があれば fzf の探索コマンドに使う (find より高速・.gitignore 尊重)
if (( ${+commands[fd]} )); then
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
elif (( ${+commands[fdfind]} )); then
  export FZF_DEFAULT_COMMAND='fdfind --type f --hidden --exclude .git'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
fi

function select-history() {
  # 改行を含むコマンド (複数行の curl リクエスト等) をそのまま扱うため、
  # zsh の $history 連想配列を「新しい順」に NUL 区切りで fzf へ渡し、
  # --read0 で 1 エントリ = 1 コマンドとして選択できるようにする。
  # (history -n だと埋め込み改行がエスケープ/分割され、コピペ実行できない)
  local selected
  selected=$(
    for k in "${(@Onk)history}"; do
      print -rNC1 -- "$history[$k]"
    done | fzf --read0 -e --no-sort +m --query "$LBUFFER" --prompt="[History] > " \
               --height='50%' \
               --preview 'printf "%s\n" {}' \
               --preview-window='right:55%:wrap' \
               --bind 'shift-up:preview-up,shift-down:preview-down,pgup:preview-page-up,pgdn:preview-page-down'
  )
  if [[ -n $selected ]]; then
    BUFFER=$selected
    CURSOR=$#BUFFER
  fi
  zle reset-prompt
}
zle -N select-history
bindkey '^r' select-history

function fzf-kill() {
  for pid in $(ps aux | _fzf_ui | awk '{print $2}'); do
    kill "$pid"
    echo "Killed ${pid}"
  done
  zle reset-prompt
}

function fzf-filename-search() {
  local filepath
  if (( ${+commands[fd]} )); then
    filepath=$(fd --hidden --exclude .git "$1" 2>/dev/null | _fzf_ui --prompt "[PATH] >" )
  elif (( ${+commands[fdfind]} )); then
    filepath=$(fdfind --hidden --exclude .git "$1" 2>/dev/null | _fzf_ui --prompt "[PATH] >" )
  else
    filepath=$(command find . -name "*${1}*" 2>/dev/null | command grep -v '/\.' | _fzf_ui --prompt "[PATH] >" )
  fi
  zle reset-prompt
  [ -z "$filepath" ] && return
  # 空白等を含むパスでもコマンドが壊れないよう ${(q)} でシェルエスケープする。
  if [ -n "$LBUFFER" ]; then
    insert-command-line "$LBUFFER${(q)filepath}"
  else
    if [ -d "$filepath" ]; then
      insert-command-line "cd ${(q)filepath}"
    elif [ -f "$filepath" ]; then
      insert-command-line "open ${(q)filepath}"
    fi
  fi
}
zle -N fzf-filename-search
bindkey '^g' fzf-filename-search

function fzf-git-checkout() {
  local res
  local branches branch
  branches=$(git branch --all | grep -v HEAD) &&
  branch=$(echo "$branches" |
    _fzf_ui --prompt "[BRANCH]>" --query "$LBUFFER" -d $(( 2 + $(wc -l <<< "$branches") )) +m |
    sed "s/.* //" | sed "s#remotes/[^/]*/##")
  zle reset-prompt
  if [ -n "$branch" ]; then
    res="git checkout '${branch}'"
  fi
  insert-command-line $res
}
zle -N fzf-git-checkout
bindkey '^b' fzf-git-checkout

function fzf-ghq() {
  local selected_dir=$(ghq list | _fzf_ui --prompt "[SRC]>" --query "$LBUFFER")
  zle reset-prompt
  if [ -n "$selected_dir" ]; then
    insert-command-line "cd $(ghq root)/$selected_dir"
  fi
}
zle -N fzf-ghq
bindkey '^s' fzf-ghq

# ghq-link - create a symlink to a ghq-managed repo in the current directory
# usage: ghq-link [link-name]
#   interactively select a repo with fzf and symlink it into $PWD.
#   link-name defaults to the repo's basename.
ghq-link() {
  local selected_dir
  selected_dir=$(ghq list | _fzf_ui --prompt "[LINK]>")
  if [ -z "$selected_dir" ]; then
    return 1
  fi
  local target="$(ghq root)/$selected_dir"
  local link_name="${1:-${selected_dir:t}}"
  if [ -e "$link_name" ]; then
    echo "'$link_name' already exists in $PWD" >&2
    return 1
  fi
  ln -s "$target" "$link_name" && echo "Linked $link_name -> $target"
}
function ghq-link-widget() {
  ghq-link
  zle reset-prompt
}
zle -N ghq-link-widget
bindkey '^o' ghq-link-widget

function fzf-ssh() {
  local res
  # ~/.ssh/config と conf.d/* から Host 定義を抽出する。
  # コメント行 (#Host) とワイルドカードホスト (*) は除外し、
  # "Host " 以降 (ホスト名・別名・末尾コメント) をそのまま候補として表示する。
  if (( ${+commands[rg]} )); then
    res=$(rg --no-filename '^\s*Host\s+[^*]+$' ~/.ssh/config ~/.ssh/conf.d/*(N) 2>/dev/null \
      | sed -E 's/^[[:space:]]*Host[[:space:]]+//' \
      | _fzf_ui --prompt "[Host] > " --query "$LBUFFER")
  else
    res=$(command grep -h -E '^[[:space:]]*Host[[:space:]]+[^*]+$' ~/.ssh/config ~/.ssh/conf.d/*(N) 2>/dev/null \
      | sed -E 's/^[[:space:]]*Host[[:space:]]+//' \
      | _fzf_ui --prompt "[Host] > " --query "$LBUFFER")
  fi
  zle reset-prompt
  if [ -n "$res" ]; then
    # "Host dev-server dev" のように別名や末尾コメントを併記していても、
    # 実際に接続するのは先頭の識別子のみ。先頭トークンだけを ssh に渡す。
    insert-command-line "ssh ${res%%[[:space:]]*}"
  fi
}
zle -N fzf-ssh
bindkey '^\' fzf-ssh

function fzf-kubelog() {
  local pod_container=$(kubectl get pods -o jsonpath='{range .items[*]}{@.metadata.name} {@.spec.containers[*].name}{"\n"}{end}' | while read line; do
    local pod_name=$(echo "$line" | awk '{print $1}')
    echo "$line" | awk '{$1=""; print}' | sed 's/^ //g' | sed 's/ /\n/g' | while read container_name; do
      echo "$pod_name $container_name"
    done
  done | _fzf_ui --prompt "[pod] > " --query "$LBUFFER")
  zle reset-prompt
  if [ -n "$pod_container" ]; then
    local pod=$(echo $pod_container | awk '{print $1}')
    local container=$(echo $pod_container | awk '{print $2}')
    insert-command-line  "kubectl logs -f ${pod} -c ${container}"
  fi
}
zle -N fzf-kubelog
bindkey '^l' fzf-kubelog

function fzf-kubexec() {
  local pod_container=$(kubectl get pods -o jsonpath='{range .items[*]}{@.metadata.name} {@.spec.containers[*].name}{"\n"}{end}' | while read line; do
    local pod_name=$(echo "$line" | awk '{print $1}')
    echo "$line" | awk '{$1=""; print}' | sed 's/^ //g' | sed 's/ /\n/g' | while read container_name; do
      echo "$pod_name $container_name"
    done
  done | _fzf_ui --prompt "[pod] > " --query "$LBUFFER")
  zle reset-prompt
  if [ -n "$pod_container" ]; then
    local pod=$(echo $pod_container | awk '{print $1}')
    local container=$(echo $pod_container | awk '{print $2}')
    insert-command-line  "kubectl exec -it ${pod} -c ${container} -- /bin/bash"
  fi
}
zle -N fzf-kubexec
bindkey '^k' fzf-kubexec

function fzf-bw() {
  if ! command -v jq >/dev/null 2>&1 || ! command -v bw >/dev/null 2>&1; then
    echo "bw and jq are required." >&2
    return 1
  fi
  zle -I

  local tmp_dir="${TMPDIR:-/tmp}/bw_cache_${USER}"
  local cache_file="${tmp_dir}/items.tsv"
  [[ -d "$tmp_dir" ]] || mkdir -p -m 700 "$tmp_dir"

  # 1. アンロック確認
  if [[ -z "$BW_SESSION" ]]; then
    echo "Bitwarden is locked. Please enter your Master Password:"
    export BW_SESSION=$(bw unlock --raw < /dev/tty)
    [[ -z "$BW_SESSION" ]] && { zle reset-prompt; return 1; }
    rm -f "$cache_file"
  fi

  # 2. キャッシュ生成 (初回のみ ~3秒)
  if [[ ! -s "$cache_file" ]]; then
    echo "Fetching vault metadata (first time ~3s)..."
    bw list items --session "$BW_SESSION" 2>/dev/null \
      | jq -r '.[] | select(.type == 1) | "\(.name)\t\(.id)"' >| "$cache_file"
    chmod 600 "$cache_file"
  fi

  # 3. fzf 起動 (テキスト直読みで爆速)
  local fzf_lines
  fzf_lines=("${(@f)$(_fzf_ui \
    --delimiter="\t" \
    --with-nth=1 \
    --prompt="[bw (Enter:Pass, ^u:User, ^t:TOTP, ^r:Refresh)] > " \
    --expect="ctrl-u,ctrl-t,ctrl-r" < "$cache_file")}")

  local key="${fzf_lines[1]}"
  local selected="${fzf_lines[2]}"

  [[ -z "$selected" ]] && { zle reset-prompt; return 0; }

  # Ctrl-R でリフレッシュ
  if [[ "$key" == "ctrl-r" ]]; then
    rm -f "$cache_file"
    fzf-bw
    return
  fi

  local item_id display_name
  display_name=$(echo "$selected" | cut -d$'\t' -f1)
  item_id=$(echo "$selected" | cut -d$'\t' -f2)

  echo "Fetching $display_name from Bitwarden..."

  # 4. bw get で取得
  local secret=""
  if [[ "$key" == "ctrl-u" ]]; then
    secret=$(bw get username "$item_id" --session "$BW_SESSION" 2>/dev/null)
    echo -n "$secret" | _clipcopy
    echo "Copied Username for: $display_name"
  elif [[ "$key" == "ctrl-t" ]]; then
    secret=$(bw get totp "$item_id" --session "$BW_SESSION" 2>/dev/null)
    echo -n "$secret" | _clipcopy
    echo "Copied TOTP for: $display_name"
  else
    secret=$(bw get password "$item_id" --session "$BW_SESSION" 2>/dev/null)
    echo -n "$secret" | _clipcopy
    echo "Copied Password for: $display_name"
  fi

  zle reset-prompt
}

zle -N fzf-bw
bindkey '^p' fzf-bw

function insert-command-line() {
  if zle; then
    BUFFER=$1
    CURSOR=$#BUFFER
  else
    print -z $1
  fi
}
