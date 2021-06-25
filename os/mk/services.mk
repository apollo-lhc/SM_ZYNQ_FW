services : 
	sudo ln -s /usr/lib/systemd/system/lighttpd.service ${ETC_PATH}/systemd/system/multi-user.target.wants/lighttpd.service
	sudo install -m 755 ${CONFIG_PATH}/common/etc/udev/rules.d/uio.rules ${ETC_PATH}/udev/rules.d/
	sudo sed -i -e "s/server.use-ipv6 = \"enable\"/server.use-ipv6 = \"disable\"/g" ${ETC_PATH}/lighttpd/lighttpd.conf 
	sudo ln -s /usr/lib/systemd/system/ntpd.service      ${ETC_PATH}/systemd/system/multi-user.target.wants/ntpd.service
