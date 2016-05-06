#!/bin/sh

SOCKFILE=/tmp/.ssh-pageant
PIDFILE=/tmp/.ssh-pageant.pid

TMPFILE=$(mktemp /tmp/.ssh-pageant.tmp.XXX)
TMPFILE2=$(mktemp /tmp/.ssh-pageant.tmp.XXX)

VERBOSE=1
[ "$1" = "-q" ] && VERBOSE=0

# If there are any temp files from previous runs, delete them before we get started
rm -f /tmp/.ssh-pageant.tmp.* 2> /dev/null

log() {
	[ $VERBOSE = 0 ] && return
	# All log output goes to stderr
	echo $@ 1>&2
}

start_agent() {
	# Send STDOUT through so .bash_profile can eval this
	/usr/bin/ssh-pageant -rqa $SOCKFILE > $TMPFILE
	r=$?

	# Write the output to STDOUT so .bash_profile can eval it
	cat $TMPFILE
	# also eval it ourselves so we can catch SSH_PAGEANT_PID
	eval $(cat $TMPFILE)

#	log "ssh-pageant exit code=$r"
}

check_pidfile() {

	local found_pid=0
	pid=0

	if [ -e $PIDFILE ]; then
		pid=$(cat $PIDFILE)
		log "Checking $PIDFILE for matching ssh-pageant process"

		ps auxgw > $TMPFILE2

		head -n 1 $TMPFILE2 > $TMPFILE
		egrep "^\s*$pid\s" < $TMPFILE2 >> $TMPFILE

		# If egrep exit=0 then it found at the line we're looking for
		[ $? = 0 ] && found_pid=1

		# In verbose mode, show the ps output to STDERR
		[ $VERBOSE = 1 ] && cat $TMPFILE 1>&2

		if [ $found_pid = 1 ]; then
			# We found a process, is it really an ssh-pageant?
			ps auxgw | egrep "^\s*$pid\s" | grep -i ssh-pageant > /dev/null
			if [ $? != 0 ]; then
				# grep confirmed this is NOT an ssh-pageant
				log "$PIDFILE contains invalid data; deleting it"
				found_pid=0
				# Remove the $PIDFILE, it contains invalid info
				rm -f $PIDFILE
			fi
		fi
	fi

	[ $found_pid = 1 ] || pid=0
}

cleanup_zombie() {

	check_pidfile

	if [ $pid != 0 ]; then

		# $PIDFILE mentions a running ssh-pageant, try to kill it
		kill -TERM $pid
		if [ $? = 0 ]; then
			log "Killed ssh-pageant zombie pid $pid"
		else
			log "Warning: Failed to kill ssh-pageant zombie pid $pid"
		fi

		# We've cleaned up what we can, remove the $PIDFILE now
		rm -f $PIDFILE
	fi

	# And finally, remove the socket file, we'll create a new one
	log "Removing socket file: $SOCKFILE"
	rm -f $SOCKFILE
}

detect_running_ssh_pageant() {

	ps auxgw > $TMPFILE2

	head -n 1 $TMPFILE2 > $TMPFILE
	grep ssh-pageant < $TMPFILE2 >> $TMPFILE

	rm -f $TMPFILE2

	# If egrep exit=0 then it found at the line we're looking for
	[ $? = 0 ] && found_pid=1

	# It's possible there are too many ssh-pageant running, especially if they
	# have been manually started for some reason.  Kill all but 1
	local n=$(($(wc -l $TMPFILE | awk '{print $1}')-1))
	log "Found $n running ssh-pageant processes"

	# In verbose mode, show the ps output to STDERR
	[ $VERBOSE = 1 ] && cat $TMPFILE 1>&2

	if [ $n = 0 ]; then
		log "Error: There are no running ssh-pageant processes"
	elif [ $n = 1 ]; then

		pid=$(tail -n 1 $TMPFILE | awk '{print $1}')

		# echo the export so calling evals will work
		echo export SSH_PAGEANT_PID=$pid
		# set SSH_PAGEANT_PID here for our own purposes
		SSH_PAGEANT_PID=$pid

		echo "$SSH_PAGEANT_PID" > $PIDFILE
	else
		log "Warning: There are too many running ssh-pageant processes"
		log "You probably want to kill them all and relogin"
	fi
}

start_agent

if [ $r = 0 -a ! -z "$SSH_PAGEANT_PID" ]; then

	log "ssh-pageant started, pid $SSH_PAGEANT_PID"

	echo "$SSH_PAGEANT_PID" > $PIDFILE

elif [ $r != 0 ]; then

	log "Notice: ssh-pageant failed to start"

	cleanup_zombie
	start_agent

	if [ $r != 0 ]; then
		log "Error: Still unable to start ssh-pageant"
		echo "echo 'ERROR: Cannot start ssh-pageant'"
		exit 1
	fi

elif [ -z "$SSH_PAGEANT_PID" ]; then

	# ssh-pageant started but it didn't tell us its pid
	# Look to see if there are any ssh-pageant processes running, and if so
	# then save their pid

	check_pidfile

	if [ $pid != 0 ]; then
		# Echo the export to eval will work
		echo export SSH_PAGEANT_PID=$pid
		# set SSH_PAGEANT_PID here for our own purposes
		SSH_PAGEANT_PID=$pid
		log "ssh-pageant reusing pid $SSH_PAGEANT_PID"
	else
		detect_running_ssh_pageant
	fi

fi

rm -f $TMPFILE $TMPFILE2
