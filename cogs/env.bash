# Exports
GIT_PS1_SHOWDIRTYSTATE=1
GIT_PS1_SHOWUNPUSHED=1
JAVA_TOOL_OPTIONS="-Dfile.encoding=UTF-8"
export GOPATH="$HOME/opt/go"
export GOBIN="${GOPATH}/bin"

# Make less more awesome
LESS_TERMCAP_mb=$'\E[01;31m'    # begin blinking
LESS_TERMCAP_md=$'\E[0;34m'     # begin bold
LESS_TERMCAP_me=$'\E[0m'        # end bold
LESS_TERMCAP_so=$'\E[01;40;33m' # begin standout mode
LESS_TERMCAP_se=$'\E[0m'        # end standout mode
LESS_TERMCAP_us=$'\E[0;36m'     #begin underline
LESS_TERMCAP_ue=$'\E[0m'        # end underline

if [[ $COLORTERM == gnome-* && $TERM == xterm ]] && infocmp gnome-256color >/dev/null 2>&1; then
  export TERM='gnome-256color'
elif infocmp xterm-256color >/dev/null 2>&1; then
  export TERM='xterm-256color'
fi

shopt -s checkwinsize # Update window size after every command
shopt -s histappend   # Append to the history file, don't overwrite it
shopt -s cmdhist      # Save multi-line commands as one command

export HISTSIZE=500000         # Much history
export HISTFILESIZE=100000     # Such size of it
export HISTTIMEFORMAT='%F %T ' # Useful timestamp format
export HISTCONTROL=ignoreboth:erasedups
export PS4='+\t ' # Place timestamp before debug output

# Record each line as it gets issued
[[ $PROMPT_COMMAND =~ 'history -a;' ]] || PROMPT_COMMAND="history -a;$PROMPT_COMMAND"

export MANPAGER='less -X' # Don't clear the screen after quitting a manual page.
export EDITOR=nvim
export VISUAL=nvim

# Shell config
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8

[[ -d $HOME/bin ]] && PATH=$HOME/bin:$PATH
PATH=$PATH:$DOTFILES/bin
PATH=$PATH:/usr/local/sbin
PATH=$PATH:$GOPATH/bin

bind 'set completion-ignore-case on' # Case-insensitive autocompletion
shopt -s nocaseglob                  # Case-insensitive globbing (used in pathname expansion)
shopt -s cdspell                     # Autocorrect typos in path names when using `cd`

# Enable 1337 mode
set -o vi
bind -m vi-insert "\C-l":clear-screen
bind -m vi-insert "\C-a":beginning-of-line
bind -m vi-insert "\C-e":end-of-line
bind -m vi-insert "\C-w":delete-word
bind -m vi-insert "\C-p":history-search-backward
bind -m vi-insert "\C-n":history-search-next
bind '"\C-u":"b \C-m"'
bind '"\C-s":"s \C-m"'
#bind 'set show-mode-in-prompt on'
#bind 'set vi-cmd-mode-string "\1\e[38;5;4m\e[49m\2 ➜ \1\e[39m\e[00m\2"'
#bind 'set vi-ins-mode-string "\1\e[38;5;8m\e[49m\2 ➜ \1\e[39m\e[00m\2"'

alias path='tr ":" "\n" <<< "$PATH" | sort'
alias reload='exec $SHELL $([[ $- == *i* ]] && echo -l)' # Reload the shell

function try() { # Retry until successfull
  shopt -s expand_aliases
  while ! "${@}"; do
    echo "Failed, retrying in 3.."
    sleep 1
    echo "2.."
    sleep 1
    echo "1.."
  done
}

function _pvar() { # case-incensitive tab-completion for pvar
  local cur vars
  _get_comp_words_by_ref cur
  vars=$(compgen -A variable | grep -v '^_')

  if [[ -z $cur ]]; then
    COMPREPLY=($(compgen -W "$vars"))
  else
    COMPREPLY=($(grep -i ^"$cur" <(echo "${vars}")))
  fi
}
complete -F _pvar pvar

function pvar() { # echo shell variable with tab-completion
  local var="$1"
  echo "${!var}"
}
