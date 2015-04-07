#!/usr/bin/env bash
# Install Baxter simulator

# where
BAXTER_DIR=${HOME}/baxter
ROS_WS=ros_ws
BAXTER_WS=${BAXTER_DIR}/${ROS_WS}

# check if simulator package has been installed
if [ ! -d "${BAXTER_WS}/src/baxter_simulator" ]; then

    printf '\nInstalling Baxter Simulator.\n'

    # check for ros installation
    if [ ! -d "/opt/ros" ] || [ ! "$(ls -A /opt/ros)" ]; then
	    echo "EXITING - No ROS installation found in /opt/ros."
	    echo "Is ROS installed?\n"
	    exit 1
    fi

    # install Baxter SDK if necessary
    . install_sdk.bash

	#
	# http://sdk.rethinkrobotics.com/wiki/Simulator_Installation
	#
	
    # Install Gazebo and ros_control
    sudo sh -c 'echo "deb http://packages.osrfoundation.org/gazebo/ubuntu \
     trusty main" > /etc/apt/sources.list.d/gazebo-latest.list'
    wget http://packages.osrfoundation.org/gazebo.key -O - | sudo apt-key add -
    sudo apt-get update
    sudo apt-get -y install gazebo2 ros-${ROS_DISTRO}-qt-build \
    ros-${ROS_DISTRO}-driver-common \
    ros-${ROS_DISTRO}-gazebo-ros-control ros-${ROS_DISTRO}-gazebo-ros-pkgs \
    ros-${ROS_DISTRO}-ros-control ros-${ROS_DISTRO}-control-toolbox \
    ros-${ROS_DISTRO}-realtime-tools \
    ros-${ROS_DISTRO}-ros-controllers ros-${ROS_DISTRO}-xacro

	# Install Baxter SDK Dependencies
    sudo apt-get -y install git python-argparse python-wstool python-vcstools \
    python-rosdep ros-${ROS_DISTRO}-control-msgs \
    ros-${ROS_DISTRO}-joystick-drivers
        	
    # Baxter Simulator Installation
    cd ${BAXTER_WS}/src
    git clone https://github.com/RethinkRobotics/baxter_simulator.git
    cd ${BAXTER_WS}/src
    wstool merge baxter_simulator/baxter_simulator.rosinstall
    wstool update
    
    # Build all the packages
    cd ${BAXTER_WS}
    source /opt/ros/${ROS_DISTRO}/setup.bash
    catkin_make
    catkin_make install
    
fi

