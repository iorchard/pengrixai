CloudPC
=========

It's the RPA for SKB CloudPC.
It's based on RobotFramework.

Pre-requisite
---------------

All TACO machines should have dstat command. If it is not installed,
install it first.::

   $ sudo yum install -y dstat

The test machine should be able to login via ssh to all TACO machines
without password prompt.
If it cannot, create a ssh key pair and copy the public key to all TACO 
machines.

Kanif is used as a cluster management tool.::

   $ sudo apt install kanif

python3 virtual environment: Create a python3 virtual environment and 
install robotframework, gabbi, and robotframework-gabbilibrary.::

   $ sudo apt update && sudo apt install -y python3-venv
   $ mkdir ~/.envs
   $ python3 -m venv ~/.envs/pengrixai
   $ source ~/.envs/pengrixai/bin/activate
   (pengrixai) $ python -m pip install wheel
   (pengrixai) $ python -m pip install gabbi robotframework
   (pengrixai) $ cd robotframework-gabbilibrary
   (pengrixai) $ python setup.py bdist_wheel
   (pengrixai) $ python -m pip install \
      dist/robotframework_gabbilibrary-0.1.1-py3-none-any.whl

Configure
----------

Go to cloudpc/resources, copy cloudpc_settings.robot.sample and
edit cloudpc_settings.robot.::

   (pengrixai) $ cd cloudpc/resources
   (pengrixai) $ cp cloudpc_settings.robot.sample cloudpc_settings.robot
   (pengrixai) $ vi cloudpc_settings.robot
   ...
   @{HOSTS}            <host1>   <host2>   <host3>

@{HOSTS} is an array variable for OpenStack compute hosts.

Go to monitor/,  copy kanif.conf.sample to kanif.conf and edit it.::

   (pengrixai) $ cd monitor
   (pengrixai) $ cp kanif.conf.sample kanif.conf
   (pengrixai) $ vi kanif.conf
   

Run robot
-----------

Go to taco robot directory.::

   (pengrixai) $ cd taco/robot

Create and Start <n> VMs.::

   (pengrixai) $ robot \
      -d output/create-n-start-<n>-vms  \
      -v NUM_SERVERS:<n> \
      create_servers.robot

Stop <n> VMs.::

   (pengrixai) $ robot \
      -d output/stop-<n>-vms  \
      -v NUM_SERVERS:<n> \
      stop_servers.robot

Start <n> VMs.::

   (pengrixai) $ robot \
      -d output/start-<n>-vms  \
      -v NUM_SERVERS:<n> \
      start_servers.robot


Delete <n> VMs.::

   (pengrixai) $ robot \
      -d output/delete-<n>-vms  \
      -v NUM_SERVERS:<n> \
      delete_servers.robot

Output
-------

All robot output files are in output directory as you specify in robot command
(-d option).

All dstat log output files are in monitor/output directory.

If you want to display dstat log output to web page, use dstat_graph
(https://github.com/Dabz/dstat_graph.git).
