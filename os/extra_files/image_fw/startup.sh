echo Startup script!
ethtool -s eth0 speed 100 duplex full autoneg off

RUNTIME_PATH=/tmp/bin
mkdir -p ${RUNTIME_PATH} 
cp /work/bin/* ${RUNTIME_PATH}
cp /work/connections.xml ${RUNTIME_PATH}
cp -r /work/modules ${RUNTIME_PATH}
cp /work/address_apollo.xml ${RUNTIME_PATH}

echo Starting XVC1
su xvc -c "screen -d -m -S XVC1"
su xvc -c "screen -S XVC1 -p 0 -X stuff $'while(true) do cd ${RUNTIME_PATH}; ./xvcServer -p 2542 -v XVC1; sleep 3;done\n'"
su xvc -c "screen -d -m -S XVCLocal"
su xvc -c "screen -S XVCLocal -p 0 -X stuff $'while(true) do cd ${RUNTIME_PATH}; ./xvcServer -p 2544 -v XVC_LOCAL;sleep 3; done\n'"

#http server
mkdir -p /srv/www
chown http:http /srv/www
httpd -u http -h /srv/www
su http -c "screen -d -m -S status"
su http -c "screen -S status -p 0 -X stuff $'while(true) do cd ${RUNTIME_PATH}; ./htmlStatus -c ./connections.xml -l 1 -f /srv/www/index.html; sleep 30 ; done\n'"



#Http dial-home tunnel
su http -c "mkdir /home/http/.ssh/"
su http -c "cp /fw/http.id_rsa /home/http/.ssh/id_rsa"
su http -c "cp /fw/http.known_hosts /home/http/.ssh/known_hosts"
su http -c "chmod 600 /home/http/.ssh/known_hosts"
su http -c "chmod 600 /home/http/.ssh/id_rsa"
su http -c "chmod 700 /home/http/.ssh"
#su http -c "screen -d -m -S tunnel"
#su http -c "screen -S tunnel -p 0 -X stuff $'while(true) do ssh -N apollo_tunnel@cmssun1.bu.edu -i /home/http/.ssh/id_rsa -R 8896:localhost:80 ; sleep 30 ; done\n'"

#find and make shortcuts to IPBUS transactor UIOs
/work/bin/findUIO IPBUS_KINTEX | grep "is at" | awk '{print "ln -s "$4" /dev/uio"$1}' | bash
/work/bin/findUIO IPBUS_VIRTEX | grep "is at" | awk '{print "ln -s "$4" /dev/uio"$1}' | bash

