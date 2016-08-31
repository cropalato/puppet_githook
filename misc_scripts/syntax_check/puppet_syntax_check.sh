#! /bin/bash
#
# yaml_syntax_check.sh
# Copyright (C) 2016 rmelo <ricardo@cropalato.com.br>
#
# Distributed under terms of the MIT license.
#

if ! command -v puppet > /dev/null 2>&1; then
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
puppet parser validate --color=false "${FILE_TARGET}" 2> $REDIRECTION
err_no="$?"
echo -ne "\e[39m"

exit $err_no
