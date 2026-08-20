HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=10000

bindkey -e
zstyle :compinstall filename '/home/jimbob/.zshrc'

autoload -Uz compinit
compinit

PROMPT="%n@%m %~ %# "

# Aliases
alias la="ls -lah"

# Plugins
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
