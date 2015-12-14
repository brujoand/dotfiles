# Navigation

ls --color > /dev/null 2>&1 || colorflag="-G" # osx ls
[[ -z $colorflag ]] && colorflag="--color" # gnu ls

alias l='ls -lF $colorflag' # list
alias la='ls -laF $colorflag' # list all
alias ldr='ls -lF | grep --color=never "^d"' # list only dirs
alias lh='ls -ld $colorflag .*' # list only hidden files
alias ls='command ls $colorflag' # force ls with colors
alias dirstat='find . -type f -not -path ".git/*" | sed "s/.*\.\(.*\)/\1/p" | grep -v "/" | sort | uniq -c | sort' # Show most common files in dir
alias top15='cut -d " " -f 1 ~/.bash_history | sort | uniq -c | sort -n |  sed "s/^ *[0-9]* //" | tail -n 15' # Show your top 15 bash commands

# Textmanipulation
alias json_pp='python -mjson.tool' # PrettyPrint json
alias xml_pp='xmllint --format -' # PrettyPrint xml
alias strip='tr -d "\040\011\012\015"' # Remove spaces, newlines and tabs

# Common applications autocomplete from complete -p <application>
alias g='git' # Git
complete -o nospace -F __git_wrap__git_main git g
alias c='curl' # Curl
complete -o nospace -F _longopt c
alias v='nvim' # Vim
complete -o bashdefault -o default -F _fzf_file_completion v
alias vim='nvim'

# Application specific
alias gwho='git log | sed -n "s/Author: \(.*\) <.*/\1/p" | sort | uniq -c | sort -nr | head' # Show most active commiters
alias gpb='git push origin $(git symbolic-ref HEAD | sed -e "s,.*/\(.*\),\1,")' # Push changes to current branch
alias vc='vim ~/.vimrc'

alias colors='printf "\e[%dm%d dark\e[0m  \e[%d;1m%d bold\e[0m\n" {30..37}{,,,}' # Show possible shell colors

# Helpers
alias ip='dig +short myip.opendns.com @resolver1.opendns.com' # Whats my ip?
alias localip='ifconfig | sed -En "s/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p"' # Whats my local ip?
alias urlencode='python -c "import sys, urllib as ul; print ul.quote_plus(sys.argv[1]);"' # Urlencode a string
alias reload='exec $SHELL $([[ $- == *i* ]] && echo -l)' # Reload the shell
alias halp='echo -e "Sourced files:\n$(sourced_files | sed "s#$HOME/#~/#")\n # \nFunctions:\n$(list_functions)\n # \nAliases:\n\n$(list_aliases)" | column -t -s "#"' # Show all custom aliases and functions

# Moron
alias :q='exit'
