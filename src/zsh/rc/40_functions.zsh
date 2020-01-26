# detect-os
detect-os() {
  if [[ "$(uname)" == 'Darwin' ]]; then
    OS='Mac'
  elif [[ "$(expr substr $(uname -s) 1 5)" == 'Linux' ]]; then
    OS='Linux'
  else
    echo "Your platform ($(uname -a)) is not supported."
    exit 1
  fi
  echo $OS
}

# ex - archive extractor
# usage: ex <file>
ex() {
  if [ -f $1 ] ; then
    case $1 in
      *.tar.bz2)   tar xjf $1   ;;
      *.tar.gz)    tar xzf $1   ;;
      *.bz2)       bunzip2 $1   ;;
      *.rar)       unrar x $1   ;;
      *.gz)        gunzip $1    ;;
      *.tar)       tar xf $1    ;;
      *.tbz2)      tar xjf $1   ;;
      *.tgz)       tar xzf $1   ;;
      *.zip)       unzip $1     ;;
      *.Z)         uncompress $1;;
      *.7z)        7z x $1      ;;
      *)           echo "'$1' cannot be extracted via ex()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}


# mkcd
# http://d.hatena.ne.jp/yarb/20110126/p1
mkcd() {
  if [ "$1" = "" ]; then
    echo "No arguments"
  elif [[ -d $1 ]]; then
    echo "It already exsits! Cd to the directory."
    cd $1
  else
    echo "Created the directory and cd to it."
    /bin/mkdir -p $1 && cd $1
  fi
}

# tmpspace - temporary working directory
# http://qiita.com/kawaz/items2b6ef25f63a4f5300e84
tmpspace() {
  (
    d=$(mktemp -d "${TMPDIR:-/tmp}/${1:-tmpspace}.XXXXXXXXXXX") && cd "$d" || exit 1
    "$SHELL"
    s=$?
    if [[ $s == 0 ]]; then
      /bin/rm -rf "$d"
    else
      echo "Directory '$d' still exeists." >&2
    fi
    exit $s
  )
}

# chpwd
chpwd() {
    ls_abbrev
}

ls_abbrev() {
  # -a : Do not ignore entries starting with ..
  # -C : Force multi-column output.
  # -F : Append indicator (one of */=>@|) to entries.
  local cmd_ls='ls'
  local -a opt_ls
  opt_ls=('-A' '-CF' '--color=always' )
  case "${OSTYPE}" in
    freebsd*|darwin*)
      if type gls > /dev/null 2>&1; then
        cmd_ls='gls'
      else
        # -G : Enable colorized output.
        opt_ls=('-aCFG')
      fi
      ;;
  esac

  local ls_result
  ls_result=$(CLICOLOR_FORCE=1 COLUMNS=$COLUMNS command $cmd_ls ${opt_ls[@]} | sed $'/^\e\[[0-9;]*m$/d')

  local ls_lines=$(echo "$ls_result" | wc -l | tr -d ' ')

  if [ $ls_lines -gt 10 ]; then
    echo "$ls_result" | head -n 5
    echo '...'
    echo "$ls_result" | tail -n 5
    echo "$(command ls -1 -A | wc -l | tr -d ' ') files exist"
  else
    echo "$ls_result"
  fi
}

git-root() {
  if git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    cd `pwd`/`git rev-parse --show-cdup`
  fi
}


