#
# ~/.bashrc -- executed for ALL shells, login or not.
#

# Group-writable umask.  Override in per-OS config if you want.
#
umask 002


# don't put duplicate lines in the history. See bash(1) for more options
# don't overwrite GNU Midnight Commander's setting of `ignorespace'.
export HISTCONTROL=$HISTCONTROL${HISTCONTROL+,}ignoredups

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)


# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize


# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi


# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    *rxvt*|xterm-*color|msys|cygwin)
		enable_colors=yes ;;
	*)
		enable_colors=no ;;
esac

if [ "$enable_colors" = yes ]; then
    export PS1="${debian_chroot:+($debian_chroot)}\[\033[0;32m\]\u\[\033[0;36m\]@\[\033[0;32m\]\h\[\033[36m\]:\w\[\033[0m\]\$ "

    # Set up dircolors if there is a config
    [ -x /usr/bin/dircolors -a -e ~/.dircolors ] && eval $(dircolors --sh ~/.dircolors)
else
    export PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi


# If this is an xterm set the title of the window to user@host:dir
case "$TERM" in
	xterm*|*rxvt*)
	    export PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1" ;;
	*)
    	;;
esac


# Tell apps what editors I like, only if something else has not
# already customized this value.
#
[ -z "$EDITOR" ] && export EDITOR="vi"
[ -z "$VISUAL" ] && export VISUAL="$EDITOR"


# Set PAGER to 'less' if it exists, else 'more' if it exists
#
[ -x /usr/bin/more ] && export PAGER=more
[ -x /usr/bin/less ] && export PAGER=less


# OS-specific .bashrc if there is one
#
[ -f ~/.bashrc.$OS_NAME ] && . ~/.bashrc.$OS_NAME


# Get OS-specific aliases
#
[ -f ~/.bash_aliases ] && . ~/.bash_aliases
[ -f ~/.bash_aliases.$OS_NAME ] && . ~/.bash_aliases.$OS_NAME
