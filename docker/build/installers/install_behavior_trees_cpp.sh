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

apt_get_update_and_install libzmq3-dev libboost-coroutine-dev libncurses5-dev libncursesw5-dev
mkdir -p /tmp/bt_cpp/
cd /tmp/

git clone https://github.com/BehaviorTree/BehaviorTree.CPP.git --branch 3.8.0 bt_cpp
cd /tmp/bt_cpp/
mkdir build; cd build
cmake ..
make
make install

rm -rf /tmp/bt_cpp/
