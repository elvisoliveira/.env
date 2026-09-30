# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Import colorscheme from 'wal' asynchronously
# &   # Run the process in the background.
# ( ) # Hide shell job control messages.
# (cat ~/.cache/wal/sequences &)

# Alternative (blocks terminal for 0-3ms)
# cat ~/.cache/wal/sequences

PS1="[\[\033[32m\]\w]\[\033[0m\]\n\[\033[1;36m\]\h\[\033[1;33m\] >\[\033[0m\]"

# To add support for TTYs this line can be optionally added.
# source ~/.cache/wal/colors-tty.sh

# export TERM="xterm-256color"

# export XDG_DATA_DIRS="$XDG_DATA_DIRS:$HOME/.local/bin"
# export PATH="$PATH:$XDG_DATA_DIRS"
# Prepend (not append): ~/.local/bin must win over /usr/bin so a locally-built
# tmux (next-3.8, has `new-pane -B` for the git float) beats /usr/bin/tmux 3.7b.
# The official build lacks -B and its server dies when the float opens.
export PATH="/home/elvisoliveira/.local/bin:$PATH"

# If ~/.inputrc doesn't exist yet: First include the original /etc/inputrc
# so it won't get overriden
if [ ! -a ~/.inputrc ]; then echo '$include /etc/inputrc' > ~/.inputrc; fi

# Add shell-option to ~/.inputrc to enable case-insensitive tab completion
echo 'set completion-ignore-case On' >> ~/.inputrc

bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'

# Android Dev — dir lives in ~/tools (symlink-free)
export ANDROID_HOME=$HOME/tools/android/sdk
export ANDROID_SDK_ROOT=$HOME/tools/android/sdk

# Go
export GOPATH=$HOME/tools/go
export PATH=$GOPATH/bin:$PATH

export GRADLE_HOME=/home/elvisoliveira/.sdkman/candidates/gradle/current
export GRADLE_USER_HOME=$HOME/.gradle
export PATH=$GRADLE_HOME/bin:$PATH

export CLOUDSDK_PYTHON=$(pyenv which python 3.11)

export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export NVM_SYMLINK_CURRENT=true

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH=$BUN_INSTALL/bin:$PATH

export PATH=$PATH:$HOME/.maestro/bin

. "/home/elvisoliveira/.deno/env"
