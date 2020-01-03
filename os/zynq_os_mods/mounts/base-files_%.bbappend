#base-files_%.bbappend content
  
dirs755 += "/fw"
#dirs755 += "/work"
dirs1777 += "/work" 
 
do_install_append() {
    echo "/dev/mmcblk0p1       /fw          auto       defaults,sync  0  0" >> ${D}${sysconfdir}/fstab
    echo "/dev/mmcblk0p2       /work        auto       defaults,sync  0  0" >> ${D}${sysconfdir}/fstab
}