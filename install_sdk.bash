#!/usr/bin/env bash
# Setup Baxter workspace with SDK

BAXTER_DIR=${HOME}/baxter
ROS_WS=ros_ws
BAXTER_WS=${BAXTER_DIR}/${ROS_WS}
echo "${BAXTER_WS}"

if [ ! -d "${BAXTER_WS}/src/baxter" ]; then

    printf '\nCreating ROS workspace and installing SDK "%s".\n' "${BAXTER_WS}";
    
    #
    # http://sdk.rethinkrobotics.com/wiki/Workstation_Setup
    #
 
	# Check for ros installation
	if [ ! -d "/opt/ros" ] || [ ! "$(ls -A /opt/ros)" ]; then
		echo "EXITING - No ROS installation found in /opt/ros."
		echo "Is ROS installed?"
		exit 1
	fi 
 
    # Install Baxter SDK Dependencies
    sudo apt-get update
    sudo apt-get -y install git python-argparse python-wstool python-vcstools python-rosdep \
                            ros-${ROS_DISTRO}-control-msgs ros-${ROS_DISTRO}-joystick-drivers
    
    # Create Baxter Development Workspace
    mkdir -p ${BAXTER_WS}/src
                            
    # Install Baxter Research Robot SDK
    cd ${BAXTER_WS}/src
    wstool init .
    wstool merge https://raw.githubusercontent.com/RethinkRobotics/baxter/master/baxter_sdk.rosinstall
    wstool update
            
    # Build all the packages
    cd ${BAXTER_WS}
    source /opt/ros/${ROS_DISTRO}/setup.bash
    catkin_make
    catkin_make install
    
    # Install Baxter environment setup script
    cd ${BAXTER_WS}
    wget https://raw.github.com/RethinkRobotics/baxter/master/baxter.sh
    chmod +x baxter.sh
fi


