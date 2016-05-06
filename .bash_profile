#
# ~/.bash_profile -- executed only for interactive (login) shells
#
# Depending on the system this typically isn't run when you just open a new terminal
# window or fire up a new shell script or whatever.  Only when you login.
#

# Set language to UTF-8.
#
export LANG="en_US.UTF-8"

# For Perl tell it our locale
#
export LC_ALL=C


# Determine what OS we're running on
#
OS_NAME=`uname -s`

# Cygwin will have `uname -s` output looking like this:
#   CYGWIN_NT-6.3-WOW64  (Cygwin on Windows 8.1 64-bit)
#   CYGWIN_NT-6.1        (Cygwin on Windows 7)
# We don't care about the host OS, we just care that it's Cygwin
echo $OS_NAME | grep "^CYGWIN" > /dev/null && OS_NAME="CYGWIN"

# MinGW will have `uname -s` output looking like this:
#	MINGW32_NT-6.2		(MinGW-W64 on Win 8.1 64-bit)
# We don't care about the host OS, we just care that it's MinGW
echo $OS_NAME | grep "^MINGW" > /dev/null && OS_NAME="MinGW"

export OS_NAME

# Figure out our user id
# `id` output is like this
# Cygwin: uid=1001(ross) gid=513(None) groups=513(None),545(Users),1002(HomeUsers)
# MinGW: uid=500(Ross) gid=544(Administrators) groups=544(Administrators)
#
export USER_ID=`id | sed -e 's,^uid=,,' -e 's,[^[:digit:]].*,,'`


# Set up PATH. For root DO NOT use ~/bin as it is a security hole.
#
if [ "x$USER_ID" != x0 ]; then
  export PATH="$HOME/bin:$PATH"
fi


# Get OS-specific profile
#
[ -f ~/.bash_profile.$OS_NAME ] && . ~/.bash_profile.$OS_NAME


# Get other bash configs as necessary
#
[ -f ~/.bashrc ] && . ~/.bashrc
