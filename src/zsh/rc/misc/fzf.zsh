export FZF_DEFAULT_OPTS='--height 40% --reverse --border'

function select-history() {
  BUFFER=$(history -n -r 1 | fzf -e --no-sort +m --query "$LBUFFER" --prompt="[History] > ")
  zle reset-prompt
  CURSOR=$#BUFFER
}
zle -N select-history
bindkey '^r' select-history

function fzf-kill() {
  for pid in `ps aux | fzf | awk '{print $2}'`; do
    kill $pid
    echo "Killed ${pid}"
  done
  zle reset-prompt
}

function fzf-filename-search() {
  local filepath
  filepath=$(find . -name "*${1}*" | grep -v '/\.' | fzf --prompt "[PATH] >" )
  zle reset-prompt
  [ -z "$filepath" ] && return
  if [ -n "$LBUFFER" ]; then
    insert-command-line "$LBUFFER$filepath"
  else
    if [ -d "$filepath" ]; then
      insert-command-line "cd $filepath"
    elif [ -f "$filepath" ]; then
      insert-command-line "xdg-open $filepath"
    fi
  fi
}
zle -N fzf-filename-search
bindkey '^g' fzf-filename-search

function fzf-git-checkout() {
  local res
  local branch=$(git branch -a | fzf --prompt "[BRANCH]>" --query "$LBUFFER" | tr -d ' ')
  zle reset-prompt
  if [ -n "$branch" ]; then
    if [[ "$branch" =~ "remotes/" ]]; then
      local b=$(echo $branch | awk -F'/' '{print $3}')
      res="git checkout -b '${b}' '${branch}'"
    else
      res="git checkout '${branch}'"
    fi
  fi
  insert-command-line $res
}
zle -N fzf-git-checkout
bindkey '^b' fzf-git-checkout

function fzf-ghq() {
  local selected_dir=$(ghq list | fzf --prompt "[SRC]>" --query "$LBUFFER")
  zle reset-prompt
  if [ -n "$selected_dir" ]; then
    insert-command-line "cd $(ghq root)/$selected_dir"
  fi
}
zle -N fzf-ghq
bindkey '^s' fzf-ghq

function fzf-ssh() {
  local res
  res=$(grep "Host " ~/.ssh/config | grep -v '*' | cut -b 6- | fzf --prompt "[Host] > " --query "$LBUFFER")
  zle reset-prompt
  if [ -n "$res" ]; then
    insert-command-line "ssh $res"
  fi
}
zle -N fzf-ssh
bindkey '^\' fzf-ssh

function insert-command-line() {
  if zle; then
    BUFFER=$1
    CURSOR=$#BUFFER
  else
    print -z $1
  fi
}

