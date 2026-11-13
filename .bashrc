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

# readline config kept out of ~ (includes /etc/inputrc + completion-ignore-case)
export INPUTRC=$HOME/.config/readline/inputrc

bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'

# Toolchains live in /files/tools (own partition). Every manager finds its dir
# through the env var set here — resolve paths via these vars, not by guessing.
export ANDROID_HOME=/files/tools/android/sdk
export ANDROID_SDK_ROOT=/files/tools/android/sdk

export GOPATH=/files/tools/go
export PATH=$GOPATH/bin:$PATH
# arduino-cli: DATA also relocates inventory.yaml (otherwise ~/.arduino15)
export ARDUINO_DIRECTORIES_DATA=/files/tools/arduino/data
export ARDUINO_DIRECTORIES_USER=/files/tools/arduino/user
export ARDUINO_DIRECTORIES_DOWNLOADS=/files/tools/arduino/dl

export SDKMAN_DIR=/files/tools/sdkman
[[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"

export GRADLE_HOME=$SDKMAN_DIR/candidates/gradle/current
export GRADLE_USER_HOME=/files/tools/gradle
export PATH=$GRADLE_HOME/bin:$PATH

export PYENV_ROOT=/files/tools/pyenv
export WORKON_HOME=/files/tools/virtualenvs
export CLOUDSDK_PYTHON=$(pyenv which python 3.11)

export RBENV_ROOT=/files/tools/rbenv
export PATH=$RBENV_ROOT/shims:$RBENV_ROOT/bin:$PATH

export NVM_DIR=/files/tools/nvm
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export NVM_SYMLINK_CURRENT=true

# rust (rustup proxies in /usr/bin read these)
export CARGO_HOME=/files/tools/cargo
export RUSTUP_HOME=/files/tools/rustup
export PATH=$CARGO_HOME/bin:$PATH

export PATH=$PATH:/files/tools/maestro/bin

export CODEX_HOME=/files/tools/codex

# Caches live on /files too (XDG_CACHE_HOME covers pip, composer, huggingface, fish,
# wezterm, browsers…; npm reads ~/.npmrc `cache=`; kubectl reads KUBECACHEDIR).
export XDG_CACHE_HOME=/files/cache
export HF_HOME=/files/cache/huggingface      # hf-hub (Rust, Handy ≥0.10) ignores XDG and only reads HF_HOME; python huggingface_hub lands here via XDG anyway
export KUBECACHEDIR=/files/cache/kube
export SUPABASE_HOME=/files/cache/supabase     # CLI telemetry/traces (was ~/.supabase)
export NPM_CONFIG_USERCONFIG=$HOME/.config/npm/npmrc   # was ~/.npmrc
export CLAUDE_CONFIG_DIR=/files/tools/claude          # was ~/.claude + ~/.claude.json
export GNUPGHOME=$HOME/documents/secrets/gnupg      # was ~/.gnupg (pass, gpg)
export YARN_GLOBAL_FOLDER=/files/cache/yarn   # yarn berry global cache (was ~/.yarn/berry)

# Dotfiles pushed out of ~ into XDG dirs (2026-10-28). git reads ~/.config/git/config natively.
export HISTFILE=$HOME/.local/state/bash/history
export WGETRC=$HOME/.config/wgetrc                 # sets hsts-file -> ~/.local/state/wget/hsts
export W3M_DIR=$HOME/.config/w3m
export RANDFILE=$XDG_CACHE_HOME/openssl.rnd        # openssl 1.1 tools' ~/.rnd
export PASSWORD_STORE_DIR=$HOME/.local/share/password-store
export TMUX_PLUGIN_MANAGER_PATH=$HOME/.local/share/tmux/plugins   # tpack/tpm (also set in .tmux.conf)
export XAUTHORITY=$XDG_RUNTIME_DIR/Xauthority      # sway's Xwayland needs no cookie; keeps ssh -X / xauth out of ~

export DENO_INSTALL=/files/tools/deno
. "$DENO_INSTALL/env"

# phpbrew: the PHPs were compiled with ~/.phpbrew baked in as ini path/scan dir; bash
# does not init phpbrew, so for a direct call export
#   PHPRC=$PHPBREW_ROOT/php/<ver>/etc[/cli]/php.ini PHP_INI_SCAN_DIR=$PHPBREW_ROOT/php/<ver>/var/db
export PHPBREW_ROOT=/files/tools/phpbrew
export PHPBREW_HOME=/files/tools/phpbrew

# sudo without a tty: password popup on the active tmux client (see .tmux.conf/bin/askpass/README.md)
export SUDO_ASKPASS="$HOME/.env/.tmux.conf/bin/askpass/askpass-tmux"
