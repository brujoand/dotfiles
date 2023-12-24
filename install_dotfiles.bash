#! /usr/bin/env bash

set -e

DOTFILES=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
SRC_DIR=$(cd "$DOTFILES/.." && pwd)
BASHRC=$HOME/.bashrc
CONFIG_FOLDER="$HOME"/.config
BIN_FOLDER="$HOME"/bin
PRIVATE_BASHRC="$HOME"/.bash_private

function catch_error {
  echo "oh no we died"
}

trap 'catch_error' ERR

function fetch_from_git {
  local repo_name=$1
  echo "Fetching ${repo_name}"
  local repo_location="${SRC_DIR}/${repo_name}"
  if [[ -d "$repo_location" ]]; then
    echo "${repo_location} already exists"
  else
    git clone "https://github.com/brujoand/${repo_name}.git" "$repo_location"
    "${repo_location}/bin/install"
  fi
}

function ensure_symlink_from_to {
  local source target current_link
  source="$1"
  target="$2"

  current_link="$(readlink "$target" || true)"

  if [[ "$current_link" == "$source" ]]; then
    echo "Symlink from ${target} to ${source} already exists, skipping.."
  else
    if [[ -n "$current_link" ]]; then
      echo "Current symlink at ${target} is broken, removing"
      rm "$target"
    fi
    echo "Creating symlink from $target to $source"
    ln -sfn "$source" "$target"
  fi
}

function link_source_to_target {
  local source="${DOTFILES}/${1}"
  local target=$2

  if [[ ! -d "$target" ]]; then
    echo "${target} does not exist, creating it.."
    mkdir -p "$target"
  fi

  if [[ ! -d "$source" ]]; then
    echo "${source} doesn't exist, nothing to do"
    return 1
  fi

  for file in "$source"/*; do
    link="$target${file##*/}"
    ensure_symlink_from_to "$file" "$link"
  done
}

function create_bashrc {
  local timestamp backuprc
  if [[ -n "$BASHRC_LOADED" ]]; then
    echo "dotfiles already loaded"
    return 0
  fi

  if [[ -f "$BASHRC" ]]; then
    timestamp="$(date +%s)"
    backuprc="${BASHRC}${timestamp}"
    mv "$BASHRC" "$backuprc"
    echo "Moved your old ${BASHRC} to ${backuprc}"
  fi

  printf '%s\n' "# Added by install_dotfiles.sh - ${timestamp}" > "$BASHRC"
  printf '%s\n' "source ${BASHRC}" >> "$HOME"/.bash_profile

}

function create_private_bashrc {
  echo "creating bashrc"
  if [[ ! -f "$PRIVATE_BASHRC" ]]; then
    echo "Creating $PRIVATE_BASHRC for all your personal needs."
  else
    echo "$PRIVATE_BASHRC already exists, skipping.."
    return 0
  fi

  printf '%s\n' "SRC_DIR=${SRC_DIR}" > "$PRIVATE_BASHRC"
  printf '%s\n' "DOTFILES=${DOTFILES}" >> "$BASHRC"
  printf '%s\n' "source ${PRIVATE_BASHRC}" >> "$BASHRC"

}
function install_vim_plug {
  echo "installing vim plug"
  local plug_dir="${HOME}/.local/share/nvim/site/autoload/plug.vim"
  local plug_url="https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"

  if [[ -d "$plug_dir" ]]; then
    echo "${plug_dir} already exists"
  else
    curl -sfLo "$plug_dir" --create-dirs "$plug_url"
  fi
}

function install_neovim {
  echo "installing neovim"
  local url="https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz"
  curl -s -L "$url" | tar xz -C "${HOME}/opt/"
  chmod +x "${HOME}/opt/nvim-linux64/bin/nvim"
  ln -s "${HOME}/opt/nvim-linux64/bin/nvim" "${HOME}/bin/nvim"
}

function install_dependencies {
  install_neovim
  install_vim_plug
  git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
  ~/.fzf/install
  git clone https://github.com/pyenv/pyenv.git ~/.pyenv
  ./.pyenv/bin/pyenv init 2>&1 | grep -v '#' | grep -v '^$'
  nvim +PlugInstall +qall
}

mkdir "${HOME}/bin"
mkdir "${HOME}/opt"

link_source_to_target 'config' "${CONFIG_FOLDER}/"
link_source_to_target 'dotfiles' "${HOME}/."
link_source_to_target 'bin' "${BIN_FOLDER}/"

create_bashrc
create_private_bashrc
install_dependencies

fetch_from_git sbc
fetch_from_git sbp

echo -e "\nReload the shell for changes to take effect"
