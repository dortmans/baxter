#!/usr/bin/env bash
# Setup Baxter workspace

BAXTER_DIR=${HOME}/baxter
ROS_WS=ros_ws

if [ -d "$ROS_WS" ]; then
    printf '\nROS workspace "%s" already setup.\n' "${ROS_WS}";
else
    printf '\nCreating ROS workspace "%s".\n' "${ROS_WS}";
    #
    # http://sdk.rethinkrobotics.com/wiki/Workstation_Setup
    # http://sdk.rethinkrobotics.com/wiki/Simulator_Installation
    #
 
    # Install Baxter SDK Dependencies
    sudo apt-get update
    sudo apt-get -y install git-core python-argparse python-wstool python-vcstools python-rosdep \
                            ros-${ROS_DISTRO}-control-msgs ros-${ROS_DISTRO}-joystick-drivers
    
    # Create Baxter Development Workspace
    mkdir -p ${BAXTER_DIR}/${ROS_WS}/src
                            
    # Install Baxter Research Robot SDK
    cd ${BAXTER_DIR}/${ROS_WS}/src
    wstool init .
    wstool merge https://raw.githubusercontent.com/RethinkRobotics/baxter/master/baxter_sdk.rosinstall
    wstool update
          
    # Simulator Installation
    cd ${BAXTER_DIR}/${ROS_WS}/src
    git clone https://github.com/RethinkRobotics/baxter_simulator.git
    cd ${BAXTER_DIR}/${ROS_WS}/src
    wstool merge baxter_simulator/baxter_simulator.rosinstall
    wstool update
    
    # Build all the packages
    cd ${BAXTER_DIR}/${ROS_WS}
    source /opt/ros/${ROS_DISTRO}/setup.bash
    catkin_make
    catkin_make install
    
    # Install Baxter environment setup script
    cd ${BAXTER_DIR}/${ROS_WS}
    wget https://raw.github.com/RethinkRobotics/baxter/master/baxter.sh
    chmod +x baxter.sh
fi
