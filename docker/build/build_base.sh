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

# Usage:
# ./build_base.sh Dockerfile 

DOCKERFILE=$1
CONTEXT="$(dirname "${BASH_SOURCE[0]}")"

REPO=robotics010/turtlebot-ros2
VERSION="0.1.0"

TAG="${REPO}:dev-${VERSION}"
CONTAINER="turtlebot_container"

# Fail on the first error
set -e

docker build --network=host -t ${TAG} -f ${DOCKERFILE} ${CONTEXT}

# Flattening image to one layer
docker run --name ${CONTAINER} ${TAG}
docker export ${CONTAINER} | docker import - ${TAG}
docker rm ${CONTAINER}

echo "Built and flattened new image ${TAG}"
