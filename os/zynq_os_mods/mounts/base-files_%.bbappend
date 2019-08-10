#base-files_%.bbappend content
  
dirs755 += "/fw"
dirs755 += "/work"
#dirs755 += "/fw"
#dirs777 += "/work"
  
do_install_append() {
#    mkdir ${D}/work
#    chmod a+rwx ${D}/work
#    mkdir ${D}/fw
#    chmod a+rx ${D}/fw
    echo "/dev/mmcblk0p1       /fw          auto       defaults,sync  0  0" >> ${D}${sysconfdir}/fstab
    echo "/dev/mmcblk0p2       /work        auto       defaults,sync  0  0" >> ${D}${sysconfdir}/fstab
}