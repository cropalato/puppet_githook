#! /bin/bash
#
# utils.sh
# Copyright (C) 2016 rmelo <ricardo@cropalato.com.br>
#
# Distributed under terms of the MIT license.
#

function info() {
    echo -e "\e[32m[Info] ${1}\e[39m"
}
function warning() {
    echo -e "\e[33m[Warning] ${1}\e[39m"
}
function critical() {
    echo -e "\e[31m[Critical] ${1}\e[39m"
}


