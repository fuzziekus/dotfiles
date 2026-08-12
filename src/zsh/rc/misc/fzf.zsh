export FZF_DEFAULT_OPTS='--height 40% --reverse --border'

# tmux 内では fzf の結果を popup 表示にし、コンテキストスイッチを減らす。
# 【重要】fzf をグローバルに alias/ラップすると内部で fzf を呼ぶ fzf-tab を壊すため、
#         ここで定義した _fzf_ui を各カスタムウィジェット内でのみ使う。
#         fzf-tab および ^r (select-history) は対象外。
# tmux 3.2+ の popup が必要なため fzf-tmux の有無で判定し、無ければ通常の fzf。
_fzf_ui() {
  if [[ -n $TMUX ]] && (( ${+commands[fzf-tmux]} )); then
    fzf-tmux -p 80% "$@"
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
  if [ -n "$LBUFFER" ]; then
    insert-command-line "$LBUFFER$filepath"
  else
    if [ -d "$filepath" ]; then
      insert-command-line "cd $filepath"
    elif [ -f "$filepath" ]; then
      insert-command-line "open $filepath"
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
    insert-command-line "ssh $res"
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

function insert-command-line() {
  if zle; then
    BUFFER=$1
    CURSOR=$#BUFFER
  else
    print -z $1
  fi
}
