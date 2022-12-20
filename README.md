# turtlebot-ros2
Turtlebot3 ROS2 course monorepo

## Cloning monorepo

git clone --recurse-submodules https://github.com/Robotics010/turtlebot-ros2.git

or

git clone https://github.com/Robotics010/turtlebot-ros2.git
git submodule init
git submodule update

## Entering docker

`~/turtlebot-ros2$ ./docker/scripts/dev_start.sh`

`~/turtlebot-ros2$ ./docker/scripts/dev_into.sh`

## Testing ROS2

`source /opt/ros/humble/setup.bash`

`robo@in-dev-docker:/workspace$ ros2 run demo_nodes_cpp talker`

`robo@in-dev-docker:/workspace$ ros2 run demo_nodes_cpp listener`

## Building

$ source /opt/ros/humble/setup.bash
cd /workspace/nav2/
/workspace/nav2$ colcon build --symlink-install

## Demo

$ source /workspace/nav2/install/local_setup.bash

demo