

ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/../.." && pwd -P )"
source "${ROOT_DIR}/scripts/base.sh"

REPO="robotics010/turtlebot-ros2"
VERSION="0.1.0"
CONTAINER="turtlebot_container_${USER}"
IMAGE_NAME="${REPO}:dev-${VERSION}"
DEV_INSIDE="in-dev-docker"

DOCKER_RUN="docker run"
USE_GPU_HOST=0
SHM_SIZE="2G"

DOCKER_VOLUMES=

function parse_arguments() {
    local custom_version=""
    local shm_size=""
    while [ $# -gt 0 ] ; do
        local opt="$1"; shift
        case "${opt}" in
        -h|--help)
            show_usage
            exit 1
            ;;

       stop)
            local force="$1" 
            if [ $force=="-f" ] || [ $force=="--force"]; then
                shift
                stop_containers "${force}"
            else
                stop_containers
            fi
            exit 0
            ;;
        *)
            warning "Unknown option: ${opt}"
            exit 2
            ;;
        esac
    done # End while loop

    [ -n "${shm_size}" ] && SHM_SIZE="${shm_size}"
}

function show_usage() {
cat <<EOF
Usage: $0 [options] ...
OPTIONS:
    -h, --help             Display this help and exit.
    --shm-size <bytes>     Size of /dev/shm . Passed directly to "docker run"
    stop [-f|--force]      Stop all running Data Collection containers.
EOF
}

function stop_containers() {
    local force="$1"
    local running_containers
    running_containers="$(docker ps -a --format '{{.Names}}')"
    for container in ${running_containers[*]} ; do
        if [[ "${container}" =~ turtlebot_container_.*_${USER} ]] ; then
            info "Now stop container ${container} ..."
            if docker stop "${container}" >/dev/null; then
                if [[ "${force}" == "-f" || "${force}" == "--force" ]]; then
                    docker rm -f "${container}" >/dev/null
                fi
                info "Done."
            else
                warning "Failed."
            fi
        fi
    done
    if [[ "${force}" == "-f" || "${force}" == "--force" ]]; then
        info "OK. Done stop and removal"
    else
        info "OK. Done stop."
    fi
}

function remove_existing_dev_container() {
    if docker ps -a --format '{{.Names}}' | grep -q "${CONTAINER}"; then
        docker stop "${CONTAINER}" >/dev/null
        docker rm -v -f "${CONTAINER}" >/dev/null
    fi
}

function mount_local_volumes() {
    local uid="$(id -u)"
    local volumes="-v $ROOT_DIR:/workspace \
                    -v /dev:/dev \
                    -v /media:/media \
                    -v /tmp/.X11-unix:/tmp/.X11-unix:rw \
                    -v /etc/localtime:/etc/localtime:ro \
                    -v /usr/src:/usr/src \
                    -v /lib/modules:/lib/modules \
                    -v /dev/log:/dev/log"
    volumes="$(tr -s " " <<< "${volumes}")"
    eval $1=\$volumes
}

function post_run_setup() {
    if [ "${USER}" != "root" ]; then
        docker exec -u root "${CONTAINER}" bash -c 'bash /workspace/docker/scripts/docker_start_user.sh'
        if [ $? -ne 0 ]; then
            error "Failed to launch .sh script"
            exit 1
        fi
    fi
}

function main() {

  parse_arguments "$@"

  info "Check and remove existing dev container ..."
  remove_existing_dev_container

  local local_volumes=
  mount_local_volumes local_volumes

  info "Starting docker container \"${CONTAINER}\" ..."

  local local_host="$(hostname)"
  local display="${DISPLAY:-:0}"
  local user="${USER}"
  local uid="$(id -u)"
  local group="$(id -g -n)"
  local gid="$(id -g)"

  set -x

  ${DOCKER_RUN} -itd  \
    --privileged    \
    --name "${CONTAINER}"  \
    --restart always            \
    -e DISPLAY="${display}"     \
    -e DOCKER_USER="${user}"    \
    -e USER="${user}"           \
    -e DOCKER_USER_ID="${uid}"  \
    -e DOCKER_GRP="${group}"    \
    -e DOCKER_GRP_ID="${gid}"   \
    -e DOCKER_IMG="${IMAGE_NAME}" \
    ${local_volumes} \
    --net host \
    -w /workspace \
    --add-host "${DEV_INSIDE}:127.0.0.1" \
    --add-host "${local_host}:127.0.0.1" \
    --hostname "${DEV_INSIDE}" \
    --shm-size "${SHM_SIZE}"   \
    --pid=host      \
    "${IMAGE_NAME}" \
    /bin/bash
  
  if [ $? -ne 0 ];then
    error "Failed to start docker container \"${CONTAINER}\" based on image: ${IMAGE_NAME}"
    exit 1
  fi
  
  set +x

  post_run_setup

  ok "Congratulations! You have successfully finished setting up Dev Environment."
  info "To login into the newly created ${CONTAINER} container, please run the following command:"
  echo -e "\tbash ${ROOT_DIR}/docker/scripts/dev_into.sh"

}

main "$@"