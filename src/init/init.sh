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
: "${GNUPGHOME:=${XDG_DATA_HOME}/gnupg}"

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

# GnuPG のホームを $HOME/.gnupg から $GNUPGHOME (XDG 配下) へ冪等に移行する。
# 秘密鍵を含むため、以下の安全策を取る:
#   - 移行先が既に存在する場合は何もしない (再実行安全)
#   - 旧ディレクトリが実ディレクトリ (シンボリックリンクでない) の時だけ移動
#   - 移動後は GnuPG が要求する 700 パーミッションを付与
function migrate_gnupg() {
  local old="$HOME/.gnupg"
  local new="$GNUPGHOME"

  if [ -e "$new" ]; then
    return
  fi
  if [ -L "$old" ] || [ ! -d "$old" ]; then
    # 旧ディレクトリが無い/リンクなら移行不要。新ホームだけ 700 で用意する。
    mkdir -p "$new" && chmod 700 "$new"
    return
  fi

  log_echo "Migrate GnuPG home: $old -> $new"
  mkdir -p "$(dirname "$new")"
  if mv "$old" "$new"; then
    chmod 700 "$new"
    log_pass "gnupg: migrated to $new"
  else
    log_warn "gnupg: migration failed; keeping $old"
  fi
}

# Docker Desktop は DOCKER_CONFIG を無視して常に $HOME/.docker を管理し、CLI
# プラグイン (buildx/compose/scout ...) も $HOME/.docker/cli-plugins へ置く。
# 一方 .zshenv で DOCKER_CONFIG を XDG 配下 ($XDG_CONFIG_HOME/docker) に向けて
# いるため、そのままでは CLI が Desktop のプラグインを見つけられず `docker
# buildx` 等が "unknown command" になる。XDG 側の cli-plugins を Desktop 側へ
# シンボリックリンクして全プラグインを追従させる。
#   - リンク先が未作成 (Docker Desktop 未インストール) でも先に張る。dangling
#     symlink は Desktop 導入時に自動解決されるため、再 init は不要。
#   - 既存の実ディレクトリ/ファイルは退けてから張り直す (再実行安全)。
function link_docker_cli_plugins() {
  local target="$HOME/.docker/cli-plugins"
  local link="${XDG_CONFIG_HOME}/docker/cli-plugins"

  mkdir -p "${XDG_CONFIG_HOME}/docker"
  # 既に目的の symlink なら何もしない。
  if [ -L "$link" ] && [ "$(readlink "$link")" = "$target" ]; then
    return
  fi
  # symlink でない実体 (実ディレクトリ/ファイル) が居座っていれば除去する。
  if [ -e "$link" ] && [ ! -L "$link" ]; then
    rm -rf "$link"
  fi
  ln -snf "$target" "$link"
  log_pass "docker: linked cli-plugins -> $target"
}

function main() {
  install_package
  ensure_mise
  migrate_gnupg
  link_docker_cli_plugins

  # macOS のみ: システム既定値 (defaults) を適用する
  if [ "$(uname)" = "Darwin" ]; then
    bash "$CURRENT_DIR/lib/macos.sh"
  fi
}

main

log_pass "finished Initiallize."
# log_notice "mise install node python go ..."
