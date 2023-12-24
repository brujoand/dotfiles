FROM ubuntu:23.10

RUN apt-get update && \
  apt-get install -y curl software-properties-common gnupg \
  language-pack-en apt-transport-https ca-certificates apt-utils \
  bash bash-completion jq curl coreutils git python3-pynvim python3-venv nodejs npm unzip && \
  usermod -l brujoand ubuntu && \
  groupmod -n brujoand ubuntu && \
  usermod -d /home/brujoand -m brujoand && \
  rm -f /bin/sh && \
  ln -s /usr/bin/bash /bin/sh

USER brujoand
WORKDIR /home/brujoand

COPY --chown=brujoand . /home/brujoand/dotfiles
RUN dotfiles/install_dotfiles.bash

CMD ["/bin/bash"]
