#! /bin/bash
#
# iptables_check.sh
# Copyright (C) 2016 Ricardo Melo <rmelo@ludia.com>
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


for i in ipset iptables; do
    if ! which $i 2> /dev/null > /dev/null ; then
        echo "Unable to check $1 file. Missing $i."
        exit 1
    fi
done

PWD=$(dirname "$(readlink -f $0)")
source "$PWD"/../utils.sh

[ $# -gt 1 ] && info "To be able to validate the syntax, this script will run some comands as root using sudo. If you disagree, I can do nothing for you."

ipset_file=$(basename $1 | sed 's/iptables/ipset/g')
ipset_dir=$(dirname $1)
ipset_rules_tmp=$(mktemp)
sudo ipset save -f $ipset_rules_tmp
sudo ipset destroy
if [[ -f "${ipset_dir}/${ipset_file}" ]]; then
    info "Loading ${ipset_file} to test firewall rules."
    sudo ipset restore -f "${ipset_dir}/${ipset_file}"
fi
sudo iptables-restore -t $1
exit_code=$?

sudo ipset destroy
sudo ipset restore -f $ipset_rules_tmp
if [[ $exit_code -ne 0 ]]; then
    critical "Failed parsing $1."
    exit 1
fi
info "We detected no error in $1."
exit 0
