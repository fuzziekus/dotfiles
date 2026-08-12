# package installer
set -euo pipefail
CURRENT_DIR=$(dirname "${BASH_SOURCE[0]:-$0}")
source "$CURRENT_DIR/lib/util.sh"

# envs
: "${XDG_CONFIG_HOME:=${HOME}/.config}"
: "${XDG_DATA_HOME:=${HOME}/.local/share}"
: "${WORKSPACE_DIR:=${HOME}/src}"
: "${ZDOTDIR:=${XDG_CONFIG_HOME}/dotfiles/src/zsh}"
: "${GOPATH:=${HOME}/.local}"
: "${MISE_ROOT:=${XDG_DATA_HOME}/mise}"

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
  # スクリプト終了時にキープアライブのバックグラウンドジョブを確実に停止する
  _sudo_keepalive_pid=$!
  trap 'kill "$_sudo_keepalive_pid" 2>/dev/null || true' EXIT
fi

function install_package() {
  local distro
  distro=$(whichdistro)

  function install_docker() {
    log_echo "Install docker ..."
    if [[ $distro == "debian" ]]; then
      curl -fsSL https://get.docker.com -o get-docker.sh
      sudo sh get-docker.sh
      sudo usermod -aG docker "$(whoami)"
      rm -f get-docker.sh
      log_pass "docker: installed successfully."
    else
      log_warn "docker: automatic install supported on debian only; install Docker Desktop manually"
    fi
  }

  local asset="$CURRENT_DIR/asset/$distro"
  if [[ -n "$distro" && -f "$asset" ]]; then
    checkinstall $(cat "$asset")
  else
    log_warn "No package asset for distro='${distro:-unknown}'; skipping package install"
  fi

  if ! command_exists "docker"; then
    install_docker
  fi
}

# mise (開発ツールのバージョン管理) を導入する。mise.toml がこれに依存するため、
# 新規マシンでも `mise install` が通るようにブートストラップで確実に入れる。
function ensure_mise() {
  if command_exists "mise"; then
    log_pass "mise: already installed."
    return
  fi

  if [ "$(uname)" = "Darwin" ] && command_exists "brew"; then
    log_echo "Install mise (brew) ..."
    brew install mise
  else
    log_echo "Install mise (mise.run) ..."
    # NOTE: 供給網リスク — 公式インストーラを curl|sh で実行する。実行前に
    #       https://mise.jdx.dev/getting-started.html の手順と一致することを確認する。
    curl -fsSL https://mise.run | sh
  fi

  if command_exists "mise"; then
    log_pass "mise: installed successfully."
  else
    log_warn "mise: install did not complete; run 'mise install' manually after opening a new shell."
  fi
}

function main() {
  install_package
  ensure_mise

  # macOS のみ: システム既定値 (defaults) を適用する
  if [ "$(uname)" = "Darwin" ]; then
    bash "$CURRENT_DIR/lib/macos.sh"
  fi
}

main

log_pass "finished Initiallize."
# log_notice "mise install node python go ..."
