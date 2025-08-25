# Dotfiles, for fun and non-profit

run ```bin/install_dotfiles.sh``` to get sauce.

### OSX
    - Install homebrew (http://brew.sh/)
    - And bash-completion (brew install bash-completion)

#### Noteworthy Features (imho)
##### halp
    - Lists custom sourced init files
    - Lists your custom sourced aliases
        - If they are defined as "^alias name='fancy stuff' # And a description"
    - Lists your custom sourced functions
        - If they are defined as "function name() { # And a description"
        - NB! Helper functions prepended with _ are ignored.

##### wat
    - Shows where a custom alias or function is defined
    - Pretty prints the function or alias with syntax sugar
    - Shows current completion

##### src
    - $SRC_DIR must be set in some sourced file
    - src will let you cd into $SRC_DIR with autocompletion

##### Powerline inspired prompt
    - Powerline fonts and BASH 4.2+ are both recomended [https://github.com/powerline/fonts](https://github.com/powerline/fonts)
    - If you're missing any of those, run 'prompt_toggle_powerline' to adapt.
    - Also, if you are on osx -> 'brew install bash' add "/usr/local/bin/bash" to /etc/shells and run 'chsh -s /usr/local/bin/bash'
    - Left and right side prompt.
    - PrettyPath, GitInfo, user+host, execution time of last command and current time.

![Screenshot of prompt](https://raw.github.com/brujoand/dotfiles/master/meta/prompt.png)

##### Git state in prompt
  - Shows current branch or short hash for HEAD
  - Shows the current state:
    - * for modified files
    - + for added files
    - ? for untracked files
    - - for deleted files
