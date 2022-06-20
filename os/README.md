This makefile builds a centos image for the second partition on the ApolloSM SD card/emmc.

The base CentOS system is build following these instructions [CERN SystemOnChip TWiki](https://twiki.cern.ch/twiki/bin/view/SystemOnChip/CentOSForZynqMP)
For both normal and docker builds, the host system requires these changes
```
#aarch64
sudo vim /etc/binfmt.d/qemu-aarch64.conf
##clear the file and add the following line:
:qemu-aarch64:M::\x7fELF\x02\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\xb7\x00:\xff\xff\xff\xff\xff\xff\xff\x00\xff\xff\xff\xff\xff\xff\xff\xff\xfe\xff\xff\xff:/usr/local/bin/qemu-aarch64-static:

#armv7hl
sudo vim /etc/binfmt.d/qemu-arm.conf
##clear the file and add the following line:
:qemu-arm:M::\x7fELF\x01\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x28\x00:\xff\xff\xff\xff\xff\xff\xff\x00\xff\xff\xff\xff\xff\xff\xff\xff\xfe\xff\xff\xff:/usr/local/bin/qemu-arm-static:
```
The package list has been updated and the python script was changed to deal with some package issues. 


The `configs` folder holds additional files for the filesystem for each build type
The `mk` folder holds the makefiles used to download packages that need to be built from source for the filesystem
The `scripts` folder holds the scripts to be run in qemu to build the packages that were downloaded by the makefiles


The password and key files are not found on this repo for security reasons, but should be placed in the following directories. 
Here is a list of the directories and their contents. 
```
secure/:
total 20
-rw-rw-rw-. 1 1003 1003  527 Dec 19 20:27 group
-rw-rw-rw-. 1 1003 1003  433 Dec 19 20:29 gshadow
-rw-rw-rw-. 1 1003 1003 1185 Dec 19 20:26 passwd
-rw-rw-rw-. 1 1003 1003 1113 Dec 19 20:31 shadow
drwxr-xr-x. 2 1003 1003 4096 Jan  2 19:20 ssh

secure/ssh:
total 24
-rw-r-----. 1 0 997  227 Jan  1  1970 ssh_host_ecdsa_key
-rw-r--r--. 1 0   0  162 Jan  1  1970 ssh_host_ecdsa_key.pub
-rw-r-----. 1 0 997  387 Jan  1  1970 ssh_host_ed25519_key
-rw-r--r--. 1 0   0   82 Jan  1  1970 ssh_host_ed25519_key.pub
-rw-r-----. 1 0 997 1675 Jan  1  1970 ssh_host_rsa_key
-rw-r--r--. 1 0   0  382 Jan  1  1970 ssh_host_rsa_key.pub
```



To copy the image to a ApolloSM, do the following in the ./image folder
#sudo rsync -P -r -l -p -o -g -W -c --numeric-ids ./ root@host:/
sudo rsync -P -r -l -p -o -g -W -c --numeric-ids --exclude 'dev/null' ./ root@host:/



Building:

On an selinux machine (centos/redhad) just do make docker_BUILD

On non-selinux machines you must build direactly and install

debian:
  augeas-tools python3-augeas
