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



function get_iptables_file_name() {
    #based on ipset file name, detecty is exist an iptables and return.
    ipset_file_name="$(basename "${1}")"
    ipset_file_dir="$( cd "$( dirname "${1}" )" && pwd )"
    iptables_file_name=$(echo $ipset_file_name | sed 's/_ipset/_iptables/g')
    if [[ -f "${ipset_file_dir}/$iptables_file_name" ]]; then
        echo "${ipset_file_dir}/${iptables_file_name}"
    fi
}

# should we check iptable when ipset is changed?
CHECK_IPTABLES=0

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. ${DIR}/../utils.sh

[ $# -gt 1 ] && info "To be able to validate the syntax, this script will run some comands as root using sudo. If you disagree, I can do nothing for you."

iptables_file_related="$(get_iptables_file_name $1)"
if [[ $CHECK_IPTABLES -eq 0 && ! -z "$iptables_file_related" ]]; then
    ${DIR}/iptables_check.sh $iptables_file_related 
    exit_err=$?
    if [[ $exit_err -ne 0 ]]; then
        critical "Failed checking IPSet + IPTables."
        exit $exit_err
    fi
else
    ipset_temp_rules=$(mktemp)
    sudo ipset save > "$ipset_temp_rules"
    if [[ $? -ne 0 ]]; then
        critical "Failed to save ipset. We will not continue testing your syntax."
        exit 1
    fi
    sudo ipset destroy
    sudo ipset restore -f $1
    exit_err=$?
    
    sudo ipset destroy
    sudo ipset restore -f ${ipset_temp_rules}
    if [[ $? -ne 0 ]]; then
        critical "Failed to load ipset."
        exit 1
    fi
fi

info "Detected no problems in IPSet rules from $1."
exit 0
