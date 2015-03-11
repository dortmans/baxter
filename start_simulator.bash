#!/usr/bin/env bash
# Start Baxter simulator

# where
BAXTER_DIR=$(basename $(readlink -f $(dirname ${BASH_SOURCE[0]})))
ROS_WS=ros_ws

# set launch command
if [ -n "${1}" ]; then
    LAUNCH_COMMAND=${1}
else
    LAUNCH_COMMAND="roslaunch baxter_gazebo baxter_world.launch"
fi

# now start it...
printf '\nStarting Baxter Simulator\n';

#-----------------------------------------------------------------------------#

# check for ros installation
if [ ! -d "/opt/ros" ] || [ ! "$(ls -A /opt/ros)" ]; then
	echo "EXITING - No ROS installation found in /opt/ros."
	echo "Is ROS installed?\n"
	exit 1
fi

# verify that the workspace has been compiled.
if [ ! -s ${BAXTER_DIR}/${ROS_WS}/devel/setup.bash ]; then
	echo -ne "EXITING - Workspace ${BAXTER_DIR}/${ROS_WS} is not build.\n"
	exit 1
fi

# source the catkin setup bash script
source ${BAXTER_DIR}/${ROS_WS}/devel/setup.bash

# execute launch command
${LAUNCH_COMMAND}

