# Baxter

This repository contains scripts to support the [Baxter Research Robot](http://www.rethinkrobotics.com/baxter-research-robot/).
The scripts are based on information provided on the [Baxter Research Robot Wiki](http://sdk.rethinkrobotics.com/wiki/Main_Page), in particular the following pages:

- [Workstation Setup](http://sdk.rethinkrobotics.com/wiki/Workstation_Setup)
- [Simulator Installation](http://sdk.rethinkrobotics.com/wiki/Simulator_Installation)

## Installation

Clone this repository:

    cd ~
    git clone https://github.com/dortmans/baxter.git

Then make the scripts executable:

    cd ~/baxter
    chmod +x *.bash

## Using your Real Baxter

Edit the `config` file to set the correct hostname/IPadres of your Baxter robot and of your Workstation.

Open a new terminal window and setup appropriate ROS environment variables:

    cd ~/baxter
    ./setup.bash

>NOTE: This script will automatically create a ROS workspace with the [Baxter SDK](https://github.com/RethinkRobotics/baxter).

Now you could test your setup using for instance the [Wobbler Example](http://sdk.rethinkrobotics.com/wiki/Wobbler_Example):

    rosrun baxter_examples joint_velocity_wobbler.py

More examples to test kan be found [here](http://sdk.rethinkrobotics.com/wiki/Examples#SDK_Examples) and [here](http://sdk.rethinkrobotics.com/wiki/Showcase).

## Using a Simulated Baxter

In case you want to use a Baxter Simulator (in Gazebo) open a new terminal window and enter following commands:

    cd ~/baxter
    ./start_simulator.bash

>NOTE: The first time you run this script it will automatically install the [Baxter Simulator](https://github.com/RethinkRobotics/baxter_simulator).

Then open a new terminal and start the setup script with an additional `sim` argument:

    cd ~/baxter
    ./setup.bash sim

Then you can run any example and see your simulated Baxter behave in the same way as your real robot would.



