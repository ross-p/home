
# Resolve a windows path
#
# In some cases Windows apps cannot correctly resolve paths, especially if
# they are relative and the Windows app is set to start in some other directory.
# Thus here we make a path absolute.
#
# Usage:
# path=$(resolve_windows_path "path")
#
resolve_windows_path() {
	path="$@"
	if echo "$path" | grep "^/" > /dev/null; then
		# This path is already absolute, return it as-is
		echo "$path"
	else
		# This path is relative to cwd, convert it to an absolute path
		# If it's "." or starts with "./" then remove those things
		path="$(echo "$path" | sed -e 's,^\.$,,' -e 's,^\./,,')"
		echo "$(pwd)/$path"
	fi
}
