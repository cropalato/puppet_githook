#! /bin/bash
#
# file_syntax.sh
# Copyright (C) 2016 rmelo <ricardo@cropalato.com.br>
#
# Distributed under terms of the MIT license.
#

VERBOSE="-v"
#VERBOSE=""

PWD=$(dirname "$(readlink -f $0)")
source "$PWD"/utils.sh

if [ "$#" -ne "2" ]; then
    critical "$0 require 2 parameters."
    exit 1
fi

FILE_NAME="$1"
FILE_PATH="$2"


FILE_TARGET="${FILE_PATH}/${FILE_NAME}"

VALID_SYNTAX=0

shopt -s extglob
# You can define an environment variable to indicate which files should be tested as IPTABLE file. ex: IPTABLE_FILES="file1|files2"
IPSET_FILES="+(${IPSET_FILES:-'ipset'})"
IPTABLE_FILES="+(${IPTABLE_FILES:-'iptables'})"

# Skip test for spec folder
if [[ $FILE_TARGET =~ ^.*modules/[^/]*/spec/.*$ ]]; then
    warning "Skiping $FILE_TARGET (We will now validate files inside spec folder)."
    exit 0
fi

case "$FILE_NAME" in
    $IPSET_FILES )
        if ! ${PWD}/syntax_check/ipset_check.sh $FILE_TARGET $VERBOSE; then
            VALID_SYNTAX=1
            critical "[Syntax] We found syntax error[s] in $FILE_TARGET"
        fi
        ;;
    $IPTABLE_FILES )
        if ! ${PWD}/syntax_check/iptables_check.sh $FILE_TARGET $VERBOSE; then
            VALID_SYNTAX=1
            critical "[Syntax] We found syntax error[s] in $FILE_TARGET"
        fi
        ;;
    *\.yaml| *\.eyaml )
        if ! command -v ruby > /dev/null 2>&1;  then
            warning "Skiping syntax check (missing tool) for $FILE_TARGET."
        else
            if ! ${PWD}/syntax_check/yaml_syntax_check.sh $FILE_TARGET $VERBOSE; then
                VALID_SYNTAX=1
                critical "[Syntax] We found syntax error[s] in $FILE_TARGET"
            fi
        fi
        ;;
    *\.pp )
        if ! command -v ruby > /dev/null 2>&1;  then
            warning "Skiping syntax check (missing tool) for $FILE_TARGET."
        else
            if ! ${PWD}/syntax_check/puppet_syntax_check.sh $FILE_TARGET $VERBOSE; then
                VALID_SYNTAX=1
                critical "[Syntax] We found syntax error[s] in $FILE_TARGET"
            fi
        fi
        ;;
    *\.erb )
        if ! command -v ruby > /dev/null 2>&1;  then
            warning "Skiping syntax check (missing tool) for $FILE_TARGET."
        else
            if ! ${PWD}/syntax_check/eruby_syntax_check.sh $FILE_TARGET $VERBOSE; then
                VALID_SYNTAX=1
                critical "[Syntax] We found syntax error[s] in $FILE_TARGET"
            fi
        fi
        ;;
    *\.rb )
        if ! command -v ruby > /dev/null 2>&1;  then
            warning "Skiping syntax check (missing tool) for $FILE_TARGET."
        else
            if ! ${PWD}/syntax_check/ruby_syntax_check.sh $FILE_TARGET $VERBOSE; then
                VALID_SYNTAX=1
                critical "[Syntax] We found syntax error[s] in $FILE_TARGET"
            fi
        fi
        ;;
    *\.py )
        if ! command -v ruby > /dev/null 2>&1;  then
            warning "Skiping syntax check (missing tool) for $FILE_TARGET."
        else
            if ! ${PWD}/syntax_check/python_syntax_check.sh $FILE_TARGET $VERBOSE; then
                VALID_SYNTAX=1
                critical "[Syntax] We found syntax error[s] in $FILE_TARGET"
            fi
        fi
        ;;
    * )
        info "No syntax check available for that file."
        ;;
esac

exit $VALID_SYNTAX
