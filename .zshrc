HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=10000

bindkey -e
zstyle :compinstall filename '~/.zshrc'

autoload -Uz compinit
compinit

PROMPT="%n@%m %~ %# "

# Aliases
alias la="ls -lah"
alias lsblk="lsblk -o NAME,SIZE,MODEL,MOUNTPOINTS"

# Plugins
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
