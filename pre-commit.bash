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

function info() {
    echo -e "\e[32m[Info] ${1}\e[39m"
}
function warning() {
    echo -e "\e[33m[Warning] ${1}\e[39m"
}
function critical() {
    echo -e "\e[31m[Critical] ${1}\e[39m"
}

LOCAL_PATH=$(pwd)
FULL_PATH_CMD=$(dirname "$(readlink -f $0)")
info "$FULL_PATH_CMD"


# Check if this is the initial commit
if git rev-parse --verify HEAD >/dev/null 2>&1
then
    echo "pre-commit: About to create a new commit..."
    against=HEAD
else
    echo "pre-commit: About to create the first commit..."
    against=4b825dc642cb6eb9a060e54bf8d69288fbee4904
fi

## Use git diff-index to check for whitespace errors
#echo "pre-commit: Testing for whitespace errors..."
#if ! git diff-index --check --cached $against
#then
#    echo "pre-commit: Aborting commit due to whitespace errors"
#    exit 1
#else
#    echo "pre-commit: No whitespace errors :)"
#    exit 0
#fi

# list the files
failure=0
all_files=()

# get the files
files=()
file_added=0
for file in $(git diff-index --cached --name-only --diff-filter=ACMR HEAD); do
    if ! [ -e "$file" ]; then
        echo "[IGNORED] $file"
        continue
    fi

    files+=($file)
    all_files+=($file)
    file_added=1
done

files_deleted=()
file_deleted=0
for file in $(git diff-index --cached --name-only --diff-filter=D HEAD); do
    files_deleted+=($file)
    all_files+=($file)
    file_deleted=1
done


# SYNTAX CHECK
if [ "$file_added" -eq "1" ] && [ "$failure" -eq "0" ]; then
    echo
    info "[CHECK] Checking the Syntax"
    for file in "${files[@]}"; do
        "$FULL_PATH_CMD/misc_scripts/file_syntax.sh" "$file" "$(pwd)" || failure=1

        if [ "$failure" -eq 1 ]; then
            break
        fi
    done

    if [ "$failure" -eq "0" ]; then
        info "[SUCESSS] The syntax check was successful"
    fi
fi

# run our hooks
if [ "$failure" -eq "1" ]; then
    critical "[ERROR] Fix the errors below. The pre-commit hook has failed."
    exit "$failure"
fi

exit 0

