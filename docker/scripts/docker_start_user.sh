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
function _create_user_account() {
  local user_name="$1"
  local uid="$2"
  local group_name="$3"
  local gid="$4"
  addgroup --gid "${gid}" "${group_name}"

  adduser --disabled-password --force-badname --gecos '' \
    "${user_name}" --uid "${uid}" --gid "${gid}" # 2>/dev/null

  usermod -aG sudo "${user_name}"
}

function setup_user_bashrc() {
  local uid="$1"
  local gid="$2"
  local user_home="/home/$3"
  # Set user files ownership to current user, such as .bashrc, .profile, etc.
  chown -R "${uid}:${gid}" ${user_home}/.*
  echo '
  
if [ -e "/docker_environment/scripts/base.sh" ]; then
  source /docker_environment/scripts/base.sh
fi

ulimit -c unlimited
  ' >> "/home/${DOCKER_USER}/.bashrc"
}

function setup_user_account_if_not_exist() {
  local user_name="$1"
  local uid="$2"
  local group_name="$3"
  local gid="$4"
  if grep -q "^${user_name}:" /etc/passwd; then
    echo "User ${user_name} already exists. Skip setting user account."
    return
  fi
  _create_user_account "$@"
  setup_user_bashrc "${uid}" "${gid}" "${user_name}"
}

##===================== Main ==============================##
function main() {
  local user_name="$1"
  local uid="$2"
  local group_name="$3"
  local gid="$4"

  if [ "${uid}" != "${gid}" ]; then
    echo "Warning: uid(${uid}) != gid(${gid}) found."
  fi
  if [ "${user_name}" != "${group_name}" ]; then
    echo "Warning: user_name(${user_name}) != group_name(${group_name}) found."
  fi
  setup_user_account_if_not_exist "$@"
}

main "${DOCKER_USER}" "${DOCKER_USER_ID}" "${DOCKER_GRP}" "${DOCKER_GRP_ID}"
