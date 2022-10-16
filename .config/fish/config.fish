# Remove greeding
set -U fish_greeting

# Add vim key bind
fish_vi_key_bindings

set -Ux PYENV_ROOT $HOME/.pyenv
# set -Ux fish_user_paths $PYENV_ROOT/bin $fish_user_paths

set -Ux EDITOR nvim
set -Ux XAUTHORITY $HOME/.xauthority
set -Ux CM_LAUNCHER rofi

set -gx TERM xterm-256color

# set -Ux GSETTINGS_SCHEMA_DIR /usr/share/glib-2.0/schemas

# set -gx XDG_DATA_DIRS "$XDG_DATA_DIRS:$HOME/.local/bin"
# set -gx XDG_DATA_DIRS "$XDG_DATA_DIRS:$HOME/.local/share"

# set -gx PATH "$PATH:$XDG_DATA_DIRS"

# set -gx GTK_THEME "gnome"

alias ls="ls --color=always"
alias vi="nvim"

# xhost +
alias fireworks="docker run --rm -it \
                 --name=fireworks \
                 --ipc=host \
                 -e DISPLAY=$DISPLAY \
                 -v /tmp/.X11-unix:/tmp/.X11-unix:ro \
                 -v /home/elvisoliveira/:/root/home/ \
                 fireworks"

alias notepadpp="docker run --rm -it \
                 --name=notepadpp \
                 --ipc=host \
                 -e DISPLAY=$DISPLAY \
                 -v /tmp/.X11-unix:/tmp/.X11-unix:ro \
                 -v /home/elvisoliveira/downloads/:/root/home/ \
                 notepadpp"

alias sen="docker run --rm -it \
           -v /var/run/docker.sock:/run/docker.sock \
           -e TERM \
           tomastomecek/sen"

alias soapui="docker run --rm -it \
              --name=soapui \
              --ipc=host \
              -e DISPLAY=$DISPLAY \
              -v /tmp/.X11-unix:/tmp/.X11-unix:ro \
              soapui"

function c
    cat $argv ^/dev/null | tr -d '\n' | read -l input
    set -ql input; or set -l input $argv
    for i in "--primary" "--secondary" "--clipboard"
        echo $input | xsel --input $i
    end
end

# function ls -l pattern
#     ls -lhagG --color=always | sed -re 's/^[^ ]* //'
# end

function fish_prompt
	if set -q VIRTUAL_ENV
		echo -n -s (set_color -b blue white) "(" (basename "$VIRTUAL_ENV") ")" (set_color normal) " "
	end

	set_color normal
	echo -n (whoami)'@'(hostname)':'

	set_color $fish_color_cwd
	echo -n (prompt_pwd)

	# https://stackoverflow.com/questions/24581793/ps1-prompt-in-fish-friendly-interactive-shell-show-git-branch
	set -l GIT_BRANCH (git branch 2>/dev/null | sed -n '/\* /s///p')
	if test -n "$GIT_BRANCH"
		set_color normal
		echo -n '['
		set_color purple
		echo -n "$GIT_BRANCH"
		set_color normal
		echo -n ']'
	end

	set_color normal
	echo -n ' $ '
end

if [ -f ~/.phpbrew/phpbrew.fish ]
    source ~/.phpbrew/phpbrew.fish
end

if [ -f ~/.cache/wal/colors.fish ]
    source ~/.cache/wal/colors.fish
end

# if command -v pyenv 1>/dev/null 2>&1
#     pyenv init - | source
# end

# neofetch

vf activate python3
