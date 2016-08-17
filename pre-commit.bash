#! /bin/bash
#
# pre-commit.bash
# Copyright (C) 2016 Ricardo Cropalato de Melo <ricardo@cropalato.com.br>
#
# Distributed under terms of the MIT license.
#

set -o errexit    # stop the script each time a command fails
set -o nounset    # stop if you attempt to use an undef variable

function bash_traceback() {
    local lasterr="$?"
    set +o xtrace
    local code="-1"
    local bash_command=${BASH_COMMAND}
    echo "Error in ${BASH_SOURCE[1]}:${BASH_LINENO[0]} ('$bash_command' exited with status $lasterr)"
    if [ ${#FUNCNAME[@]} -gt 2 ]; then
        # Print out the stack trace described by $function_stack
        echo "Traceback of ${BASH_SOURCE[1]} (most recent call last):"
        for ((i=0; i < ${#FUNCNAME[@]} - 1; i++)); do
            local funcname="${FUNCNAME[$i]}"
            [ "$i" -eq "0" ] && funcname=$bash_command
            echo -e "  $i: ${BASH_SOURCE[$i+1]}:${BASH_LINENO[$i]}\t$funcname"
        done
    fi
    echo "Exiting with status ${code}"
    exit "${code}"
}

# provide an error handler whenever a command exits nonzero
trap 'bash_traceback' ERR

# propagate ERR trap handler functions, expansions and subshells
set -o errtrace


LOCAL_PATH=$(pwd)
FULL_PATH_CMD=$(dirname "$(readlink -f $0)")


# Check if this is the initial commit
if git rev-parse --verify HEAD >/dev/null 2>&1
then
    echo "pre-commit: About to create a new commit..."
    against=HEAD
else
    echo "pre-commit: About to create the first commit..."
    against=4b825dc642cb6eb9a060e54bf8d69288fbee4904
fi

# Use git diff-index to check for whitespace errors
echo "pre-commit: Testing for whitespace errors..."
if ! git diff-index --check --cached $against
then
    echo "pre-commit: Aborting commit due to whitespace errors"
    exit 1
else
    echo "pre-commit: No whitespace errors :)"
    exit 0
fi
