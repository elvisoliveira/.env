# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Import colorscheme from 'wal' asynchronously
# &   # Run the process in the background.
# ( ) # Hide shell job control messages.
(cat ~/.cache/wal/sequences &)

# Alternative (blocks terminal for 0-3ms)
cat ~/.cache/wal/sequences

# To add support for TTYs this line can be optionally added.
source ~/.cache/wal/colors-tty.sh

alias ls='ls -lah --color=auto'
alias vi='vim'

export GTK_THEME Adwaita-dark

export XDG_DATA_DIRS="$XDG_DATA_DIRS:$HOME/.local/bin"
export XDG_DATA_DIRS="$XDG_DATA_DIRS:$HOME/.local/share"
export XDG_DATA_DIRS="$XDG_DATA_DIRS:$HOME/.local/share/flatpak/exports/share"
export XDG_DATA_DIRS="$XDG_DATA_DIRS:/var/lib/flatpak/exports/bin"
export XDG_DATA_DIRS="$XDG_DATA_DIRS:/var/lib/flatpak/exports/share"
export XDG_DATA_DIRS="$XDG_DATA_DIRS:/var/lib/flatpak/exports/share/applications"

export PATH="$PATH:$XDG_DATA_DIRS"

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="/home/elvisoliveira/.sdkman"
[[ -s "/home/elvisoliveira/.sdkman/bin/sdkman-init.sh" ]] && source "/home/elvisoliveira/.sdkman/bin/sdkman-init.sh"
