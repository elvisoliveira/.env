# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Import colorscheme from 'wal' asynchronously
# &   # Run the process in the background.
# ( ) # Hide shell job control messages.
(cat ~/.cache/wal/sequences &)

# Alternative (blocks terminal for 0-3ms)
cat ~/.cache/wal/sequences

PS1="[\[\033[32m\]\w]\[\033[0m\]\n\[\033[1;36m\]\u\[\033[1;33m\] \[\033[0m\]"

# To add support for TTYs this line can be optionally added.
source ~/.cache/wal/colors-tty.sh

alias vi='vim'
alias ls='ls --color=auto'

export TERM="xterm-256color"
export XAUTHORITY="$HOME/.xauthority"

export GTK_THEME="Adwaita-dark"
# export GTK_THEME="Adwaita"

# export XDG_DATA_DIRS="$XDG_DATA_DIRS:$HOME/.local/bin"
# export PATH="$PATH:$XDG_DATA_DIRS"

# If ~/.inputrc doesn't exist yet: First include the original /etc/inputrc
# so it won't get overriden
if [ ! -a ~/.inputrc ]; then echo '$include /etc/inputrc' > ~/.inputrc; fi

# Add shell-option to ~/.inputrc to enable case-insensitive tab completion
echo 'set completion-ignore-case On' >> ~/.inputrc

# THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="/home/elvisoliveira/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

neofetch
