FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive
LABEL maintainer="Robotics010"

COPY installers /tmp/installers
RUN bash /tmp/installers/install_minimal_environment.sh
RUN bash /tmp/installers/install_ros2.sh
RUN bash /tmp/installers/install_nav2.sh
RUN bash /tmp/installers/post_base_install.sh

WORKDIR /workspace
