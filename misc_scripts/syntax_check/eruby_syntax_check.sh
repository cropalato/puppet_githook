#! /bin/bash
#
# yaml_syntax_check.sh
# Copyright (C) 2016 rmelo <ricardo@cropalato.com.br>
#
# Distributed under terms of the MIT license.
#

if ! command -v erb > /dev/null 2>&1; then
    echo "It is not possible to validate the syntax."
    exit 1
fi
if ! command -v ruby > /dev/null 2>&1; then
    echo "It is not possible to validate the syntax."
    exit 1
fi


err_no=0

FILE_TARGET="$1"
REDIRECTION="/dev/null"

if [ "$#" -eq "2" ] && [ "$2" == "-v" ]; then
    REDIRECTION="/dev/stdout"
fi

echo -ne "\e[35m"
erb -x -T '-' "${FILE_TARGET}" | ruby -c | grep -v "Syntax OK" 2> $REDIRECTION
err_no="${PIPESTATUS[1]}"
echo -ne "\e[39m"

exit $err_no
