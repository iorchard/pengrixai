Ceph Performance test
=========================

Prerequisite
--------------

Open resources/ceph_resources.robot and edit Variables.

* @{CEPH_CLIENTS}: client machines to run fio against ceph storage
* ${CEPH_CLIENT_SSHPORT}: ssh port to connect
* ${UID}: user id to run fio on ceph client (have passwordless sudo privilege)
* ${SSHKEY}: ssh private key path

Copy kanif_ceph.conf.sample to kanif_ceph.conf and edit it appropriately.::

   $ cp monitor/kanif_ceph.conf.sample monitor/kanif_ceph.conf
   $ vi monitor/kanif_ceph.conf

Add kanif member machines to /etc/hosts.::

   $ sudo vi /etc/hosts

Create ssh key pair and copy the public key to each kanif member machine.::

   $ ssh-keygen
   ...
   $ ssh-copy-id ${UID}@<each_kanif_machine> 

Check kanif cluster.::

   $ kanif -f monitor/kanif_ceph.conf -l ${UID} -F -- 'hostname'

It should output all kanif member machines except the front node.

Create rbdbench pool.::

   (Ceph client)$ sudo ceph osd pool create rbdbench 128

Create <n> rbd images.(<n> is (CEPH_CLIENTS * max_jobs(5))-1)::

   (Ceph client)$ for i in {0..<n>}
   do
   s=$(printf "%03d" $i)
   sudo rbd create --pool rbdbench --image image-${s} --size 50G
   done


Run
----

Run ceph io robot.::

   $ robot -d output/<test-name> ceph-randread.robot 
   $ robot -d output/<test-name> ceph-randwrite.robot 
