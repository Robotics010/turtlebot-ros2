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

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
IN_DOCKER=false

# If inside docker container
if [ -f /.dockerenv ]; then
  IN_DOCKER=true
  ROOT_DIR="/workspace"
fi

export ROOT_DIR="${ROOT_DIR}"
export IN_DOCKER="${IN_DOCKER}"
export PS1="\[\e[31m\][\[\e[m\]\[\e[32m\]\u\[\e[m\]\[\e[33m\]@\[\e[m\]\[\e[35m\]\h\[\e[m\]:\[\e[36m\]\w\[\e[m\]\[\e[31m\]]\[\e[m\]\[\e[1;32m\]\\$\[\e[m\] "

BOLD='\033[1m'
RED='\033[0;31m'
GREEN='\033[32m'
BLUE='\033[34m'
YELLOW='\033[33m'
NO_COLOR='\033[0m'

function info() {
  (>&2 echo -e "[${BLUE}${BOLD}INFO${NO_COLOR}] $*")
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

function print_delim() {
  echo '============================'
}

function get_now() {
  date +%s
}

function time_elapsed_s() {
  local start="${1:-$(get_now)}"
  local end="$(get_now)"
  echo "$end - $start" | bc -l
}

function success() {
  print_delim
  ok "$1"
  print_delim
}

function fail() {
  print_delim
  error "$1"
  print_delim
  exit 1
}

## Prevent multiple entries of my_bin_path in PATH
function add_to_path() {
  if [ -z "$1" ]; then
    return
  fi
  local my_bin_path="$1"
  if [ -n "${PATH##*${my_bin_path}}" ] && [ -n "${PATH##*${my_bin_path}:*}" ]; then
    export PATH=$PATH:${my_bin_path}
  fi
}

## Prevent multiple entries of my_libdir in LD_LIBRARY_PATH
function add_to_ld_library_path() {
  if [ -z "$1" ]; then
    return
  fi
  local my_libdir="$1"
  local result="${LD_LIBRARY_PATH}"
  if [ -z "${result}" ]; then
    result="${my_libdir}"
  elif [ -n "${result##*${my_libdir}}" ] && [ -n "${result##*${my_libdir}:*}" ]; then
    result="${result}:${my_libdir}"
  fi
  export LD_LIBRARY_PATH="${result}"
}

function set_cuda_path() {
  if [ -e /usr/local/cuda/ ]; then
    add_to_path "/usr/local/cuda/bin"
  fi
}

function set_waf_path() {
  if [ -e /usr/local/waf/ ]; then
    add_to_path "/usr/local/waf"
  fi
}

function set_julia_path() {
  if [ -e /usr/local/julia/ ]; then
    add_to_path "/usr/local/julia/bin"
  fi
}

function set_nvm_env() {
  if [ -e /usr/local/nvm ]; then
    export NVM_DIR="/usr/local/nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
  fi
}

function set_gst_plugin_path() {
  if [ -e /usr/local/lib/gstreamer-1.0/ ]; then
    export GST_PLUGIN_PATH="/usr/local/lib/gstreamer-1.0"
  fi
}

# TODO(dburakov): Uncomment if needed
# set_cuda_path
# set_waf_path
# set_julia_path

# set_nvm_env
# set_gst_plugin_path

add_to_ld_library_path "/usr/lib"
add_to_ld_library_path "/usr/local/lib"
