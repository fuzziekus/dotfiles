# log.sh

newline() {
  printf "\n"
}

print_format() {
  if [ "$#" -eq 0 -o "$#" -gt 3 ]; then
    echo "Usage: print_format <color> <text> <attr>"
    echo "Colors:"
    echo "  black, white, red, green, yellow, blue, purple, cyan "
    return 1
  fi
  
  local open="\033["
  local close="${open}0m"
  local black="30m"
  local red="31m"
  local green="32m"
  local yellow="33m"
  local blue="34m"
  local purple="35m"
  local cyan="36m"
  local white="37m"

  local default="0;"
  local bold="1;"
  local underline="4;"

  local text="$1"
  local color="$white"
  local attr=${3:-0;}

  if [ "$#" -ge 2 ]; then
    text="$2"
    case "$1" in
      black | red | green | yellow | blue | purple | cyan | gray | white)
      eval color="\$$1"
      ;;
    esac
    if [ "$#" -eq 3 ]; then
      case "$3" in
        default | bold | underline)
          eval attr="\$$3"
          ;;
        *)
          attr="0;"
          ;;
      esac
    fi
  fi

  printf "${open}${attr}${color}${text}${close}"
}

log() {
  if [ "$#" -eq 0 -o "$#" -gt 2 ]; then
    echo "Usage: log <fmt> <msg>"
    echo "Formatting Options:"
    echo " TITLE, ERROR, WARN, INFO, SUCCESS"
    return 1
  fi

  local color=
  local text="$2"

  case "$1" in
    DEBUG)
      color=cyan
      ;;
    TITLE)
      color=cyan
      ;;
    ERROR)
      color=red
      ;;
    WARN)
      color=yellow
      ;;
    INFO)
      color=blue
      ;;
    SUCCESS)
      color=green
      ;;
    NOTICE)
      color=purple
      ;;
    *)
      text="$1"
  esac

  timestamp() {
    print_format gray "\["
    print_format purple "$(date +%H:%M:%S)"
    print_format gray "\] "
  }

  timestamp; print_format "$color" "$text"; echo
}

log_pass() {
  log SUCCESS "$1"
}

log_fail() {
  log ERROR "$1" 1>&2
}

log_warn() {
  log WARN "$1"
}

log_info() {
  log INFO "$1"
}

log_echo() {
  log TITLE "$1"
}

log_debug() {
  if is_debug; then
    log_echo "$1"
  fi
}

log_notice() {
  log NOTICE "$1"
}

print_header() {
  print_format white "$*" bold
  newline
}

print_success() {
  print_format " ✔ $* ... "
  print_format green OK
  newline
}

function whichdistro() {
  #which yum > /dev/null && { echo redhat; return; }
  #which zypper > /dev/null && { echo opensuse; return; }
  #which apt-get > /dev/null && { echo debian; return; }
  if [ -f /etc/debian_version ]; then
    echo debian; return;
  elif [ -f /etc/fedora-release ] ;then
    # echo fedora; return;
    echo redhat; return;
  elif [ -f /etc/redhat-release ] ;then
    echo redhat; return;
  elif [ -f /etc/arch-release ] ;then
    echo arch; return;
  elif [ -f /etc/alpine-release ] ;then
    echo alpine; return;
  fi
}

function command_exists() {
    local command="$1"

    hash "$command" 2>/dev/null
}

function checkinstall() {
  local distro
  distro=$(whichdistro)
  if [[ $distro == "redhat" ]];then
    sudo yum clean all
    if ! cat /etc/redhat-release | grep -i "fedora" > /dev/null; then
      sudo yum install -y epel-release
    fi
  fi

  local pkgs="$@"
  if [[ $distro == "debian" ]];then
    sudo DEBIAN_FRONTEND=noninteractive apt install -y $pkgs
  elif [[ $distro == "redhat" ]];then
    sudo yum install -y $pkgs
  elif [[ $distro == "arch" ]];then
    :
  elif [[ $distro == "alpine" ]];then
    :
  else
    :
  fi
}

function git_clone_or_fetch() {
  local repo="$1"
  local dest="$2"
  local name
  name=$(basename "$repo")
  if [ ! -d "$dest/.git" ];then
    log_info "Installing $name..."
    log_info ""
    mkdir -p $dest
    git clone --depth 1 $repo $dest
  else
    log_info "Pulling $name..."
    (builtin cd $dest && git pull --depth 1 --rebase origin master || \
      log_notice "Exec in compatibility mode [git pull --rebase]" && \
      builtin cd $dest && git fetch --unshallow && git rebase origin/master)
  fi
}

function mkdir_not_exist() {
  if [ ! -d "$1" ];then
    mkdir -p "$1"
  fi
}