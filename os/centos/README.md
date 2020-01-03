This makefile builds a centos image for the second partition on the ApolloSM SD card.
The password and key files are not found on this repo for security reasons, but should be placed in the following directories. 
Here is a list of the directories and their contents. 

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
