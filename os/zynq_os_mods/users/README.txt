The python script setup_users reads the file users.dat and creates the file petalinux-user-image.bbappend to setup users in the petalinux image. 

The files users.dat and petalinux-user-image.bbappend should NEVER be put on revision control since they have the bare passwords. 

Example users.dat:
---
root notroot
user password group1 group2
user2 password2 group2
---

This sets the root user's password to be "notroot"
It adds user "user" with password "password" and adds "user" to groups "group1" & "group2"
It finally adds user "user2" with password "password2" and adds "user2" to group "group2"

