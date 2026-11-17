# If not running interactively, don't do anything
[[ $- != *i* ]] && return

PS1="[\[\033[32m\]\w]\[\033[0m\]\n\[\033[1;36m\]\h\[\033[1;33m\] >\[\033[0m\]"

# Prepend (not append): ~/.local/bin must win over /usr/bin so a locally-built
# tmux (next-3.8, has `new-pane -B` for the git float) beats /usr/bin/tmux 3.7b.
# The official build lacks -B and its server dies when the float opens.
export PATH="/home/elvisoliveira/.local/bin:$PATH"

# readline config kept out of ~ (includes /etc/inputrc + completion-ignore-case)
export INPUTRC=$HOME/.config/readline/inputrc

bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'

# Machine-specific paths (toolchain homes, caches): single source shared with
# fish and systemd --user. Plain KEY=VALUE lines, exported via set -a.
set -a
for f in "$HOME"/.config/environment.d/*.conf; do [ -r "$f" ] && . "$f"; done
set +a

export PATH=$GOPATH/bin:$PATH

[[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"

export GRADLE_HOME=$SDKMAN_DIR/candidates/gradle/current
export PATH=$GRADLE_HOME/bin:$PATH

export CLOUDSDK_PYTHON=$(pyenv which python 3.11)

export PATH=$RBENV_ROOT/shims:$RBENV_ROOT/bin:$PATH

[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export NVM_SYMLINK_CURRENT=true

# rust (rustup proxies in /usr/bin read CARGO_HOME/RUSTUP_HOME)
export PATH=$CARGO_HOME/bin:$PATH

export NPM_CONFIG_USERCONFIG=$HOME/.config/npm/npmrc   # was ~/.npmrc
export GNUPGHOME=$HOME/documents/secrets/gnupg      # was ~/.gnupg (pass, gpg)

# Dotfiles pushed out of ~ into XDG dirs (2026-10-28). git reads ~/.config/git/config natively.
export HISTFILE=$HOME/.local/state/bash/history
export WGETRC=$HOME/.config/wgetrc                 # sets hsts-file -> ~/.local/state/wget/hsts
export W3M_DIR=$HOME/.config/w3m
export PASSWORD_STORE_DIR=$HOME/.local/share/password-store
export TMUX_PLUGIN_MANAGER_PATH=$HOME/.local/share/tmux/plugins   # tpack/tpm (also set in .tmux.conf)
export XAUTHORITY=$XDG_RUNTIME_DIR/Xauthority      # sway's Xwayland needs no cookie; keeps ssh -X / xauth out of ~

. "$DENO_INSTALL/env"

# phpbrew: the PHPs were compiled with ~/.phpbrew baked in as ini path/scan dir; bash
# does not init phpbrew, so for a direct call export
#   PHPRC=$PHPBREW_ROOT/php/<ver>/etc[/cli]/php.ini PHP_INI_SCAN_DIR=$PHPBREW_ROOT/php/<ver>/var/db

# sudo without a tty: password popup on the active tmux client (see .tmux.conf/bin/askpass/README.md)
export SUDO_ASKPASS="$HOME/.env/.tmux.conf/bin/askpass/askpass-tmux"
