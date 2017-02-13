#! /bin/bash
#
# ipset_check.sh
# Copyright (C) 2017 Ricardo Melo <rmelo@ludia.com>
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

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. ${DIR}/../utils.sh

ipset_temp_rules=$(mktemp)
sudo ipset save > "$ipset_temp_rules"
if [[ $? -ne 0 ]]; then
    critical "Failed to save ipset. We will not continue testing your syntax."
    exit 1
fi
sudo ipset destroy
sudo ipset restore -f $1
if [[ $? -ne 0 ]]; then
    critical "Failed to load ipset."
    exit 1
fi

sudo ipset destroy
sudo ipset restore -f ${ipset_temp_rules}
info "Detected no problems in IPSet rules from $1."
exit 0
