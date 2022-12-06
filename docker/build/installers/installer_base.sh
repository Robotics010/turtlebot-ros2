#!/usr/bin/env bash

###############################################################################
# Copyright 2022 Kirill Mitkovskii. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
###############################################################################

BOLD='\033[1m'
RED='\033[0;31m'
GREEN='\033[32m'
WHITE='\033[34m'
YELLOW='\033[33m'
NO_COLOR='\033[0m'

function info() {
    (>&2 echo -e "[${WHITE}${BOLD}INFO${NO_COLOR}] $*")
}

function error() {
    (>&2 echo -e "[${RED}ERROR${NO_COLOR}] $*")
}

function warning() {
    (>&2 echo -e "${YELLOW}[WARNING] $*${NO_COLOR}")
}

function ok() {
    (>&2 echo -e "[${GREEN}${BOLD} OK ${NO_COLOR}] $*")
}

export SYSROOT_DIR="/usr/local"

function py3_version() {
    local version
    version="$(python3 --version | awk '{print $2}')"
    echo "${version%.*}"
}

function pip3_install() {
    python3 -m pip install --upgrade pip
    python3 -m pip install --no-cache-dir $@
}

function apt_get_update_and_install() {
    apt-get -y update && \
        apt-get -y install --no-install-recommends --no-install-suggests "$@"
}

function apt_get_remove() {
    apt-get -y purge --autoremove "$@"
}

function apt_get_clean() {
    apt-get clean && \
        rm -rf /var/lib/apt/lists/*
}
