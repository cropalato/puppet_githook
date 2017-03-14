#! /bin/bash
#
# yaml_syntax_check.sh
# Copyright (C) 2016 rmelo <ricardo@cropalato.com.br>
#
# Distributed under terms of the MIT license.
#

if ! command -v python2 > /dev/null 2>&1; then
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
python2 -m py_compile "${FILE_TARGET}" 2> $REDIRECTION
err_no="$?"
echo -ne "\e[39m"
if [[ -f "${FILE_TARGET}c" ]]; then
    /bin/rm -f "${FILE_TARGET}c"
fi

exit $err_no
