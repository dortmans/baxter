#!/usr/bin/env bash
# Start Baxter simulator

# where
BAXTER_DIR=${HOME}/baxter
ROS_WS=ros_ws
BAXTER_WS=${BAXTER_DIR}/${ROS_WS}

# set launch command
if [ -n "${1}" ]; then
    LAUNCH_COMMAND=${1}
else
    LAUNCH_COMMAND="roslaunch baxter_gazebo baxter_world.launch"
fi

# install simulator if necessary
. install_simulator.bash

# check for ros installation
if [ ! -d "/opt/ros" ] || [ ! "$(ls -A /opt/ros)" ]; then
	echo "EXITING - No ROS installation found in /opt/ros."
	echo "Is ROS installed?\n"
	exit 1
fi

# verify that the workspace has been compiled.
if [ ! -s ${BAXTER_WS}/devel/setup.bash ]; then
	echo -ne "EXITING - Workspace ${BAXTER_WS} is not build.\n"
	exit 1
fi

# now start it...
printf '\nStarting Baxter Simulator\n';

#-----------------------------------------------------------------------------#

# source the catkin setup bash script
source ${BAXTER_WS}/devel/setup.bash

# execute launch command
${LAUNCH_COMMAND}

