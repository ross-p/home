#
# ~/.bash_aliases -- sourced by ~/.bash_profile for interactive shells.
# Set up handy aliases so I don't have to type so much.
#

# Enable ssh-agent forwarding
#
alias ssh='ssh -A'
alias sshr='ssh -l root'

if [ "$enable_colors" = yes ]; then
	if [ x$OS_NAME != xDarwin ]; then
		alias ls='ls --color'
	fi
fi

# Directory listings
#
alias ll='ls -l'
alias lla='ll -a'
alias dir='ls -l'
alias dira='dir -a'
alias dirg='dir | grep'
alias dirm='dir | less'

alias lsd='find . -maxdepth 1 -type d \! -name \.\* -print | sed -e 's,^\./,,''
alias dird='dir | grep ^d'

alias lsad='find . -maxdepth 1 -type d -print | sed -e 's,^\./,,''
alias dirad='dira | grep ^d'

# Other useful things
#
alias h='history'
alias j='jobs'
