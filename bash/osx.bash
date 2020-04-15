# osx specific stuff
if [[ "$(uname)" == "Darwin" ]]; then
  if [ -f "$(brew --prefix)/share/bash-completion/bash_completion" ]; then
    # shellcheck source=/dev/null
    . "$(brew --prefix)/share/bash-completion/bash_completion"
  fi

  alias bump='brew upgrade && brew cask upgrade'

  function _complete_ssh_hosts() { # ssh tab-completion sux on osx.
      COMPREPLY=()
      cur="${COMP_WORDS[COMP_CWORD]}"
      known=$(cut -d ' ' -f 1 ~/.ssh/known_hosts | sed -e s/,.*//g | sed 's/\[\(.*\)\].*/\1/' | sort -u)
      defined=$( [[ -f $HOME/.ssh/config ]] && sed -n 's/^Host \(.*\)/\1/p' ~/.ssh/config)
      comp_ssh_hosts="$defined\n$known"
      COMPREPLY=( $(compgen -W "${comp_ssh_hosts}" -- "$cur"))
  }

  function status(){
    # Display brew information
    brew_upgrade=$HOME/.brew_upgrade
    weather_upgrade=$HOME/.weather_update

    if [[ -s "$brew_upgrade" ]]; then
      printf '%s\n\n' "$(tput setaf 1)The following packages are out of date"
      cat "$brew_upgrade"
    else
      printf '%s%s\n' "$(tput sgr 2)" 'System packages are up to date!'
    fi

    printf '%s\n' "$(tput sgr 0)"

    if [[ -f "$weather_upgrade" ]]; then
      cat "$weather_upgrade"
    fi

    echo

    cal
  }

 status

fi
