# package installer
CURRENT_DIR=$(dirname "${BASH_SOURCE[0]:-$0}")
source $CURRENT_DIR/lib/util.sh

# envs
: "${XDG_CONFIG_HOME:=${HOME}/.config}"
: "${XDG_DATA_HOME:=${HOME}/.local/share}"
: "${WORKSPACE_DIR:=${HOME}/src}"
: "${ZDOTDIR:=${XDG_CONFIG_HOME}/dotfiles/src/zsh}"
: "${GOPATH:=${HOME}/.local}"
: "${MISE_ROOT:=${XDG_DATA_HOME}/mise}"

declare -A ZINIT
ZINIT[HOME_DIR]="${XDG_DATA_HOME}/zinit"
ZINIT[BIN_DIR]="${ZINIT[HOME_DIR]}/zinit.git"
ZINIT[PLUGINS_DIR]="${ZINIT[HOME_DIR]}/plugins"

if command_exists "xdg-user-dirs-gtk-update"; then
  env LANGUAGE=C LC_MESSAGES=C xdg-user-dirs-gtk-update
fi

if [ "$(uname)" != "Darwin" ]; then
  # Linux: apt/yum 用に sudo 認証を維持する (mac の brew は sudo 不要)
  sudo -v
  while true; do
    sudo -n true
    sleep 60
    kill -0 "$$" || exit
  done 2>/dev/null &
fi

function install_package() {
  local distro
  distro=$(whichdistro)

  function install_docker() {
    log_echo "Install docker ..."
    if [[ $distro == "debian" ]]; then
      curl -fsSL https://get.docker.com -o get-docker.sh
      sudo sh get-docker.sh
      sudo usermod -aG docker $(whoami)
    fi
    log_pass "docker: installed successfully."
  }

  local asset="$CURRENT_DIR/asset/$distro"
  if [[ -n "$distro" && -f "$asset" ]]; then
    checkinstall $(cat "$asset")
  else
    log_warn "No package asset for distro='${distro:-unknown}'; skipping package install"
  fi

  if ! command_exists "docker"; then
    install_docker
    checkinstall docker-compose
  fi
}

function main() {
  install_package

  # macOS のみ: システム既定値 (defaults) を適用する
  if [ "$(uname)" = "Darwin" ]; then
    bash "$CURRENT_DIR/lib/macos.sh"
  fi
}

main

log_pass "finished Initiallize."
# log_notice "mise install node python go ..."
