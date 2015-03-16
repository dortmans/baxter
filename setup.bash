#!/usr/bin/env bash
# Setup Baxter workspace

BAXTER_DIR=${HOME}/baxter
ROS_WS=ros_ws

if [ -d "${BAXTER_DIR}/${ROS_WS}/src/baxter" ]; then
    printf '\nROS workspace "%s" already setup.\n' "${BAXTER_DIR}/${ROS_WS}";
else
    printf '\nCreating ROS workspace "%s".\n' "${BAXTER_DIR}/${ROS_WS}";
    #
    # http://sdk.rethinkrobotics.com/wiki/Workstation_Setup
    # http://sdk.rethinkrobotics.com/wiki/Simulator_Installation
    #
 
	# Check for ros installation
	if [ ! -d "/opt/ros" ] || [ ! "$(ls -A /opt/ros)" ]; then
		echo "EXITING - No ROS installation found in /opt/ros."
		echo "Is ROS installed?"
		exit 1
	fi 
 
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

if [ -n "${1}" ] && [ "${1}" == "sim" ] \
        && [ ! -d "${BAXTER_DIR}/${ROS_WS}/src/baxter_simulator" ]; then
	printf '\nInstall Simulator.\n'
	
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
fi

printf '\nSetup Baxter environment.\n';

# read Baxter config data
. ${BAXTER_DIR}/config

#-----------------------------------------------------------------------------#
#
# Following code copied and adapted from 'baxter.sh' script
# Copyright (c) 2013-2015, Rethink Robotics
# 
#-----------------------------------------------------------------------------#

tf=$(tempfile)
trap "rm -f -- '${tf}'" EXIT

# If 'config' file specifies an ip address or hostname - unset any previously set
# ROS_IP and/or ROS_HOSTNAME.
# If 'config' file does not specify an ip address or hostname - use the
# previously specified ROS_IP/ROS_HOSTNAME environment variables.
if [ -n "${your_ip}" ] || [ -n "${your_hostname}" ]; then
	unset ROS_IP && unset ROS_HOSTNAME
else
	your_ip="${ROS_IP}" && your_hostname="${ROS_HOSTNAME}"
fi

# If argument provided, set baxter_hostname to argument
# If argument is sim or local, set baxter_hostname to localhost
if [ -n "${1}" ]; then
	if [[ "${1}" == "sim" ]] || [[ "${1}" == "local" ]]; then
		baxter_hostname="localhost"
		if [[ -z ${your_ip} || "${your_ip}" == "192.168.XXX.XXX" ]] && \
		[[ -z ${your_hostname} || "${your_hostname}" == "my_computer.local" ]]; then
			your_hostname="localhost"
			your_ip=""
		fi
	else
		baxter_hostname="${1}"
	fi
fi

topdir=$(basename $(readlink -f $(dirname ${BASH_SOURCE[0]})))

cat <<-EOF > ${tf}
	[ -s "\${HOME}"/.bashrc ] && source "\${HOME}"/.bashrc
	[ -s "\${HOME}"/.bash_profile ] && source "\${HOME}"/.bash_profile

	# if set, verify user has modified the baxter_hostname
	if [ -n ${baxter_hostname} ] && \
	[[ "${baxter_hostname}" == "baxter_hostname.local" ]]; then
		echo -ne "EXITING - Please edit 'config' file, modifying the \
'baxter_hostname' variable to reflect Baxter's current hostname.\n"
		exit 1
	fi

	# if set, verify user has modified their ip address (your_ip)
	if [ -n ${your_ip} ] && [[ "${your_ip}" == "192.168.XXX.XXX" ]]; then
		echo -ne "EXITING - Please edit 'config' file, modifying the 'your_ip' \
variable to reflect your current IP address.\n"
		exit 1
	fi

	# if set, verify user has modified their computer hostname (your_hostname)
	if [ -n ${your_hostname} ] && \
	[[ "${your_hostname}" == "my_computer.local" ]]; then
		echo -ne "EXITING - Please edit 'config' file, modifying the \
'your_hostname' variable to reflect your current PC hostname.\n"
		exit 1
	fi

	# verify user does not have both their ip *and* hostname set
	if [ -n "${your_ip}" ] && [ -n "${your_hostname}" ]; then
		echo -ne "EXITING - Please edit 'config' file, modifying to specify \
*EITHER* your_ip or your_hostname.\n"
		exit 1
	fi

	# verify that one of your_ip, your_hostname, ROS_IP, or ROS_HOSTNAME is set
	if [ -z "${your_ip}" ] && [ -z "${your_hostname}" ]; then
		echo -ne "EXITING - Please edit 'config' file, modifying to specify \
your_ip or your_hostname.\n"
		exit 1	
	fi

	[ -n "${your_ip}" ] && export ROS_IP="${your_ip}"
	[ -n "${your_hostname}" ] && export ROS_HOSTNAME="${your_hostname}"
	[ -n "${baxter_hostname}" ] && \
		export ROS_MASTER_URI="http://${baxter_hostname}:11311"


    # verify that the workspace has been compiled.
    if [ ! -s ${BAXTER_DIR}/${ROS_WS}/devel/setup.bash ]; then
	    echo -ne "EXITING - Workspace ${BAXTER_DIR}/${ROS_WS} is not build.\n"
	    exit 1
    fi

    # source the catkin setup bash script
    source ${BAXTER_DIR}/${ROS_WS}/devel/setup.bash

	# setup the bash prompt
	export __ROS_PROMPT=\${__ROS_PROMPT:-0}
	[ \${__ROS_PROMPT} -eq 0 -a -n "\${PROMPT_COMMAND}" ] && \
		export __ORIG_PROMPT_COMMAND=\${PROMPT_COMMAND}

	__ros_prompt () {
		if [ -n "\${__ORIG_PROMPT_COMMAND}" ]; then
			eval \${__ORIG_PROMPT_COMMAND}
		fi
		if ! echo \${PS1} | grep '\[baxter' &>/dev/null; then
			export PS1="\[\033[00;33m\][baxter - \
\${ROS_MASTER_URI}]\[\033[00m\] \${PS1}"
		fi
	}

	if [ "\${TERM}" != "dumb" ]; then
		export PROMPT_COMMAND=__ros_prompt
		__ROS_PROMPT=1
	elif ! echo \${PS1} | grep '\[baxter' &>/dev/null; then
		export PS1="[baxter - \${ROS_MASTER_URI}] \${PS1}"
	fi

EOF

${SHELL} --rcfile ${tf}

rm -f -- "${tf}"
trap - EXIT
