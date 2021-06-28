services : 
	#add webserver
	sudo ln -s /usr/lib/systemd/system/lighttpd.service ${ETC_PATH}/systemd/system/multi-user.target.wants/lighttpd.service
	sudo sed -i -e "s/server.use-ipv6 = \"enable\"/server.use-ipv6 = \"disable\"/g" ${ETC_PATH}/lighttpd/lighttpd.conf 
	#add ntpd
	sudo ln -s /usr/lib/systemd/system/ntpd.service      ${ETC_PATH}/systemd/system/multi-user.target.wants/ntpd.service
	#this is annoying
	sudo rm ${ETC_PATH}/systemd/system/multi-user.target.wants/auditd.service
