#!/bin/sh
#
# Fix the paths in the git submodule configs to be relative instead of absolute.
#
# This is vital in Cygwin, where the absolute paths in Cygwin do NOT match those
# in Windows, so git doesn't play nicely with SourceTree.
#
# Run this from your root git repo like
# git-submodule-path-fix.sh -e
#

doit=0
arg=${1:-""}
[ "$arg" = "-e" ] && doit=1

# Make sure there is a .git dir here so we know we're in the parent of the repo
if [ ! -d .git ]; then
	echo "Error: You must run this from your parent Git repository directory" 1>&2
	exit 1
fi

# List all submodules by finding .git files under this tree
submodules=$(find . -type f -name .git | sed -e 's,^\./,,' | xargs -n 1 dirname)

TEMPFILE=$(mktemp /tmp/gitsubmodulepathfix.XXX)

for module in $submodules; do

	# Make sure there are no paths like relative/path//multiple///slashes
	module=$(echo "$module" | sed -e 's,//*,/,g')

	# Find out how many sub-dirs deep this submodule is
	depth=$(( 1 + $(echo -n "$module" | sed -e 's,[^/],,g' | wc -c) ))

	# Compute relative back path like ../../ that goes the appropriate depth
	relativeBackPath=""
	n=$depth
	while [ $n != 0 ]; do
		relativeBackPath="../$relativeBackPath"
		n=$(( $n - 1 ))
	done

	# Whatever the gitdir currently is in the submodule, it may be relative or it
	# may be absolute, we don't care
	gitDir=$(cat "$module/.git" | sed -e 's,^gitdir:\s*,,')

	# Compute the back path to the gitdir based on the submodule depth
	backPathGitDir=$(echo "$gitDir" | sed -e "s,.*/\.git/,${relativeBackPath}.git/,")

	# Compute the relative path to the gitdir
	relativeGitDir=$(echo "$gitDir" | sed -e 's,.*/\.git/,.git/,')

	# Figure out the depth of the relativeGitDir
	gitDepth=$(( 1 + $(echo -n "$relativeGitDir" | sed -e 's,[^/],,g' | wc -c) ))

	# Compute relative back path like ../.. that goes from the relativeGitDir back to the module
	gitRelativeBackPath=""
	n=$gitDepth
	while [ $n != 0 ]; do
		gitRelativeBackPath="../$gitRelativeBackPath"
		n=$(( $n - 1 ))
	done

	# Figure out the worktree path of this submodule
	worktreePath=$(cat $relativeGitDir/config | grep worktree | sed -e 's,^\s*worktree\s*=\s*,,')
	gitBackPathWorktreePath="${gitRelativeBackPath}${module}"

	echo
	echo "Submodule: $module (depth: $depth; backpath=$relativeBackPath)"

	echo "  * $module/.git changes:"
	printf "\t- $gitDir\n"
	printf "\t+ $backPathGitDir\n"

	echo "  * $relativeGitDir/config changes:"
	printf "\t-\tworktree = $worktreePath\n"
	printf "\t+\tworktree = $gitBackPathWorktreePath\n"

	if [ $doit = 1 ]; then

		# Overwrite $module/.git with the new relative path to the gitdir
		echo "gitdir: $backPathGitDir" > "$module/.git"

		# Rewrite $relativeGitDir/config
		cat "$relativeGitDir/config" | sed -e "s,\(\s*worktree\s*=\s*\).*,\1$gitBackPathWorktreePath," > $TEMPFILE
		mv $TEMPFILE "$relativeGitDir/config"
	fi

done

if [ $doit != 1 ]; then

	echo
	echo "#"
	echo "# DID NOT ACTUALLY CHANGE ANYTHING. This just showed you what we would have done."
	echo "# To make these changes, run:"
	echo "#"
	echo "# $0 -e"
	echo "#"
	echo
fi

rm -f $TEMPFILE
