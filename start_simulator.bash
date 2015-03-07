#!/usr/bin/env bash
# Start Baxter simulator

BAXTER_DIR=${HOME}/baxter
ROS_WS=ros_ws

if [ -n "${1}" ]; then
    COMMAND=${1}
else
    COMMAND="roslaunch baxter_gazebo baxter_world.launch"
fi

cd ${BAXTER_DIR}/${ROS_WS}

printf '\nStarting Baxter Simulator\n';

# Clear any previously set your_ip/your_hostname
unset your_ip
unset your_hostname
#-----------------------------------------------------------------------------#
#                 USER CONFIGURABLE ROS ENVIRONMENT VARIABLES                 #
#-----------------------------------------------------------------------------#
# Note: If ROS_MASTER_URI, ROS_IP, or ROS_HOSTNAME environment variables were
# previously set (typically in your .bashrc or .bash_profile), those settings
# will be overwritten by any variables set here.

# Specify Baxter's hostname
baxter_hostname="baxter_hostname.local"

# Set *Either* your computers ip address or hostname. Please note if using
# your_hostname that this must be resolvable to Baxter.
your_ip="192.168.XXX.XXX"
#your_hostname="my_computer.local"

# Specify ROS distribution (e.g. indigo, hydro, etc.)
ros_version="indigo"
#-----------------------------------------------------------------------------#

tf=$(tempfile)
trap "rm -f -- '${tf}'" EXIT

# If this file specifies an ip address or hostname - unset any previously set
# ROS_IP and/or ROS_HOSTNAME.
# If this file does not specify an ip address or hostname - use the
# previously specified ROS_IP/ROS_HOSTNAME environment variables.
if [ -n "${your_ip}" ] || [ -n "${your_hostname}" ]; then
	unset ROS_IP && unset ROS_HOSTNAME
else
	your_ip="${ROS_IP}" && your_hostname="${ROS_HOSTNAME}"
fi

# If argument is sim or local, set baxter_hostname to localhost
		baxter_hostname="localhost"
		if [[ -z ${your_ip} || "${your_ip}" == "192.168.XXX.XXX" ]] && \
		[[ -z ${your_hostname} || "${your_hostname}" == "my_computer.local" ]]; then
			your_hostname="localhost"
			your_ip=""
		fi

topdir=$(basename $(readlink -f $(dirname ${BASH_SOURCE[0]})))

cat <<-EOF > ${tf}
	[ -s "\${HOME}"/.bashrc ] && source "\${HOME}"/.bashrc
	[ -s "\${HOME}"/.bash_profile ] && source "\${HOME}"/.bash_profile

	# verify ros_version lowercase
	ros_version="$(tr [A-Z] [a-z] <<< "${ros_version}")"

	# check for ros installation
	if [ ! -d "/opt/ros" ] || [ ! "$(ls -A /opt/ros)" ]; then
		echo "EXITING - No ROS installation found in /opt/ros."
		echo "Is ROS installed?"
		exit 1
	fi

	# verify specified ros version is installed
	ros_setup="/opt/ros/\${ros_version}"
	if [ ! -d "\${ros_setup}" ]; then
		echo -ne "EXITING - Failed to find ROS \${ros_version} installation \
in \${ros_setup}.\n"
		exit 1
	fi

	# verify the ros setup.sh file exists
	if [ ! -s "\${ros_setup}"/setup.sh ]; then
		echo -ne "EXITING - Failed to find the ROS environment script: \
"\${ros_setup}"/setup.sh.\n"
		exit 1
	fi

	# verify the user is running this script in the root of the catkin
	# workspace and that the workspace has been compiled.
	if [ ! -s "devel/setup.bash" ]; then
		echo -ne "EXITING - \n1) Please verify that this script is being run \
in the root of your catkin workspace.\n2) Please verify that your workspace \
has been built (source /opt/ros/\${ros_version}/setup.sh; catkin_make).\n\
3) Run this script again upon completion of your workspace build.\n"
		exit 1
	fi

	[ -n "${your_ip}" ] && export ROS_IP="${your_ip}"
	[ -n "${your_hostname}" ] && export ROS_HOSTNAME="${your_hostname}"
	[ -n "${baxter_hostname}" ] && \
		export ROS_MASTER_URI="http://${baxter_hostname}:11311"

	# source the catkin setup bash script
	source devel/setup.bash

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

${COMMAND}

EOF

${SHELL} --rcfile ${tf}

rm -f -- "${tf}"
trap - EXIT
