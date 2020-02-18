PengrixAI
=========

It's the RPA project for system testint and management.
It's based on RobotFramework.

Pre-requisite
---------------

Create a python3 virtual environtment and 
install robotframework, gabbi, and robotframework-gabbilibrary.::

   $ sudo apt update && sudo apt install -y python3-venv
   $ mkdir ~/.envs
   $ python -m venv ~/.envs/pengrixai
   $ source ~/.envs/pengrixai/bin/activate
   (pengrixai) $ python -m pip install wheel
   (pengrixai) $ python -m pip install gabbi robotframework
   (pengrixai) $ cd robotframework-gabbilibrary
   (pengrixai) $ python setup.py bdist_wheel
   (pengrixai) $ python -m pip install \
      dist/robotframework_gabbilibrary-0.1.1-py3-none-any.whl

Run robot
-----------

Go to taco directory and run the performace test robots.

Create and Start <n> VMs.::

   (pengrixai) $ robot \
      -d output/create-n-start-5-vms  \
      -v NUM_SERVERS:<n> \
      create_servers_with_port_volume.robot

Stop <n> VMs.::

   (pengrixai) $ robot \
      -d output/stop-5-vms  \
      -v NUM_SERVERS:<n> \
      stop_servers.robot

Start <n> VMs.::

   (pengrixai) $ robot \
      -d output/start-5-vms  \
      -v NUM_SERVERS:<n> \
      start_servers.robot


Delete <n> VMs.::

   (pengrixai) $ robot \
      -d output/delete-5-vms  \
      -v NUM_SERVERS:<n> \
      delete_servers.robot

Go to cloudpc directory and do the same performance tests.


