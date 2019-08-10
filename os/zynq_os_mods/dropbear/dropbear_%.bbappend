#dropbear-core_%.bbappend content
  
  
do_install_append() {
    ln -s /fw/dropbear_rsa_host_key ${D}${sysconfdir}/dropbear/dropbear_rsa_host_key
}