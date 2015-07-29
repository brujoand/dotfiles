# Dotfiles, for fun and non-profit

run ```bin/install_dotfiles.sh``` to get sauce.

### OSX 
	- Install homebrew (http://brew.sh/)
	- And bash-completion (brew install bash-completion)

#### Noteworthy functions (imho)
##### halp
	- Lists sourced init files
	- Lists all your sourced aliases
		- If they are defined as "^alias name='fancy stuff' # And a description"
	- Lists all your sourced functions
		- If they are defined as "function name() { # And a description"
		- NB! Helper functions prepended with _ are ignored.
	
##### src
	- $SRC_DIR must be set in some sourced file
	- src will let you cd into $SRC_DIR with autocompletion


