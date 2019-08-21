#!/usr/bin/env bash

# export all variables
set -a

taps=(
  'caskroom/cask'
  'caskroom/versions'
  'homebrew/versions'
  'homebrew/binary'
  'neovim/neovim'
)

packages=(
  ack
  autoconf
  automake
  bash
  bash-completion@2
  bat
  coreutils
  cowsay
  curl
  dateutils
  docker
  fd
  findutils
  fzf
  gettext
  git
  gnupg
  gnutls
  go
  gradle
  httpie
  jq
  lua
  moreutils
  neovim
  nmap
  node
  openssh
  openssl
  perl
  python
  ruby
  sbt
  shellcheck
  shfmt
  socat
  sox
  speedtest-cli
  sqlite
  ssh-copy-id
  telnet
  terminal-notifier
  thefuck
  tldr
  tmux
  tree
  unrar
  vim
  wget
  wtf
  xz
  yarn
  youtube-dl
  z
)

casks=(
  1password
  alfred
  bartender
  caffeine
  dash
  dropbox
  gimp
  hammerspoon
  iterm2
  java
  karabiner-elements
  little-snitch
  qbserve
  rescuetime
  slack
  spotify
  ubersicht
  virtualbox
)

set +a
