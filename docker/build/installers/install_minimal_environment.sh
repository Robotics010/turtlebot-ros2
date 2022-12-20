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

# Fail on first error.
set -e

cd "$(dirname "${BASH_SOURCE[0]}")"
. ./installer_base.sh

apt_get_update_and_install apt-utils

apt_get_update_and_install git \
    software-properties-common \
    cmake   \
    make    \
    gcc-10   \
    g++-10   \
    sed         \
    sudo    \
    nano     \
    wget    \
    unzip   \
    zip     \
    curl

##----------------##
##    SUDO        ##
##----------------##
sed -i /etc/sudoers -re 's/^%sudo.*/%sudo ALL=(ALL:ALL) NOPASSWD: ALL/g'

##----------------##
## default shell  ##
##----------------##
chsh -s /bin/bash
ln -s /bin/bash /bin/sh -f

# link libraries
ln -sf /usr/bin/gcc-10 /usr/bin/gcc
ln -sf /usr/bin/g++-10 /usr/bin/g++
ln -sf /usr/bin/cython3 /usr/bin/cython

# Clean up cache to reduce layer size.
apt_get_clean
