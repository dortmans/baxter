#!/usr/bin/env bash
# Setup Baxter workspace

ROS_WS=ros_ws

if [ -d "$ROS_WS" ]; then
  printf '\nROS workspace "%s" already setup.\n\n' "${ROS_WS}";
else
  printf '\nCreating ROS workspace "%s".\n\n' "${ROS_WS}";
fi
