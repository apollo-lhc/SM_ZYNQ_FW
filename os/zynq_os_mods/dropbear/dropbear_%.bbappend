#dropbear-core_%.bbappend content
  
  
do_install_append() {
    #use a symbolic link to connect the dropbearkey to the one in /fw
    ln -s /fw/dropbear_rsa_host_key ${D}${sysconfdir}/dropbear/dropbear_rsa_host_key
}