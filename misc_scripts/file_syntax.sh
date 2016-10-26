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

# You can define an environment variable to indicate which files should be tested as IPTABLE file. ex: IPTABLE_FILES="file1|files2"
IPTABLE_FILES="+(${IPTABLE_FILES:-'IdontCare'})" 

case "$FILE_NAME" in
    $IPTABLE_FILES )
        warning "Skiping iptable syntax check (the script is not available) for $FILE_TARGET."
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
