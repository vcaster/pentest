#!/bin/bash -e

function getRepoSHA1List {

	pushd "$1" >/dev/null
	git rev-list --all
	popd >/dev/null
}

function exportCommits {

	local commitSHA1

	local IFS=$'\n'
	for commitSHA1 in $(getRepoSHA1List "$1"); do
		# build export directory for commit and create
		local exportDir="${2%%/}/$commitSHA1"
		echo "Export $commitSHA1 -> $exportDir"

		mkdir --parents "$exportDir"

		# create archive from commit then unpack to export directory
		git \
			--git-dir "$1/.git" \
			archive \
			--format tar \
			"$commitSHA1" | \
				tar \
					--directory "$exportDir" \
					--extract
	done
}


# verify arguments
if [[ (! -d $1) || (! -d $2) ]]; then
	echo "Usage: $(basename "$0") GIT_DIR OUTPUT_DIR"
	exit
fi

if [[ ! -d "$1/.git" ]]; then
	echo "Error: it seems [$1] is not a Git repository?" >&2
	exit 1
fi

# execute
exportCommits "$1" "$2"
