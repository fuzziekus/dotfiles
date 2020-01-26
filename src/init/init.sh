# package installer
CURRENT_DIR=$(dirname "${BASH_SOURCE[0]:-$0}")
source $CURRENT_DIR/lib/util.sh

# envs
: "${XDG_CONFIG_HOME:=${HOME}/.config}"
: "${XDG_DATA_HOME:=${HOME}/.local/share}"
: "${WORKSPACE_DIR:=${HOME}/src}"
: "${ZDOTDIR:=${XDG_CONFIG_HOME}/dotfiles/src/zsh}"
: "${GOPATH:=${HOME}/.local}"
: "${ANYENV_ROOT:=${XDG_DATA_HOME}/anyenv}"

declare -A ZINIT
ZINIT[HOME_DIR]="${XDG_DATA_HOME}/zinit"
ZINIT[BIN_DIR]="${ZINIT[HOME_DIR]}/bin"
ZINIT[PLUGINS_DIR]="${ZINIT[HOME_DIR]}/plugins"

if command_exists "xdg-user-dirs-gtk-update"; then
    env LANGUAGE=C LC_MESSAGES=C xdg-user-dirs-gtk-update;
fi

sudo -v
while true; do
    sudo -n true
    sleep 60
    kill -0 "$$" || exit
done 2>/dev/null &

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

    checkinstall $(cat $CURRENT_DIR/asset/$distro)
    
    if ! command_exists "docker"; then
        install_docker
        checkinstall docker-compose
    fi
}

function install_anyenv() {
    log_echo "Install anyenv ..."
    local repo
    repo="https://github.com/riywo/anyenv"
    if [[ -d "$ANYENV_ROOT" ]]; then
        log_echo "anyenv already installed?"
    else
        git_clone_or_fetch $repo $ANYENV_ROOT
    fi
    log_pass "anyenv: installed successfully."
}

function main() {
    install_package
    install_anyenv
}

main

log_pass "finished Initiallize."
# log_notice "anyenv install plenv nodenv goenv pyenv"
