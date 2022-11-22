#!/bin/bash

user_info_file=/tmp/user_info.txt
while IFS= read -r line
do 
    info_array=($line)

    info_array_size=${#info_array[@]}
    if [ ${info_array_size} -ne 2 ]
    then
	echo "$info_array is invalid"
	exit 1
    fi

    username=${info_array[0]}
    password_hash=${info_array[1]}

    echo "Setting up user: $username"

    if [ $username != "root" ]
    then
	useradd -m $username
    fi
    usermod -p $password_hash $username
    usermod -a -G dialout $username

done < "$user_info_file"
