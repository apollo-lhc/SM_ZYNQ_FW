#include <configs/xilinx_zynqmp.h>

#define CONFIG_SERVERIP	192.168.30.2

#define CONFIG_EXTRA_ENV_SETTINGS \
	"nc=setenv stdout nc;setenv stdin nc;\0" \
	"ethaddr=\0" \
	"sdboot=echo boot Petalinux; mmcinfo && fatload mmc 0 ${netstart} ${kernel_img} && bootm \0" \
	"autoload=no\0" \
	"clobstart=0x04000000\0" \
	"netstart=0x04000000\0" \
	"dtbnetstart=0x05800000\0" \
	"loadaddr=0x04000000\0" \
	"boot_img=BOOT.BIN\0" \
	"bootargs=console=ttyPS0,115200 earlycon clk_ignore_unused rootwait root=/dev/nfs rw ip=dhcp nfsroot=192.168.30.2:/export/CentOS,nfsvers=3,tcp\0" \
	"serverip=192.168.30.2\0" \
	"load_boot=tftpboot ${clobstart} ${boot_img}\0" \
	"update_boot=setenv img boot; setenv psize ${bootsize}; setenv installcmd \"install_boot\"; run load_boot ${installcmd}; setenv img; setenv psize; setenv installcmd\0" \
	"install_boot=mmcinfo && fatwrite mmc 0 ${clobstart} ${boot_img} ${filesize}\0" \
	"bootenvsize=0x20000\0" \
	"bootenvstart=0x500000\0" \
	"eraseenv=sf probe 0 && sf erase ${bootenvstart} ${bootenvsize}\0" \
	"jffs2_img=rootfs.jffs2\0" \
	"load_jffs2=tftpboot ${clobstart} ${jffs2_img}\0" \
	"update_jffs2=setenv img jffs2; setenv psize ${jffs2size}; setenv installcmd \"install_jffs2\"; run load_jffs2 test_img; setenv img; setenv psize; setenv installcmd\0" \
	"sd_update_jffs2=echo Updating jffs2 from SD; mmcinfo && fatload mmc 0:1 ${clobstart} ${jffs2_img} && run install_jffs2\0" \
	"install_jffs2=sf probe 0 && sf erase ${jffs2start} ${jffs2size} && " \
		"sf write ${clobstart} ${jffs2start} ${filesize}\0" \
	"kernel_img=image.ub\0" \
	"load_kernel=tftpboot ${clobstart} ${kernel_img}\0" \
	"update_kernel=setenv img kernel; setenv psize ${kernelsize}; setenv installcmd \"install_kernel\"; run load_kernel ${installcmd}; setenv img; setenv psize; setenv installcmd\0" \
	"install_kernel=mmcinfo && fatwrite mmc 0 ${clobstart} ${kernel_img} ${filesize}\0" \
	"cp_kernel2ram=mmcinfo && fatload mmc 0 ${netstart} ${kernel_img}\0" \
	"dtb_img=system.dtb\0" \
	"load_dtb=tftpboot ${clobstart} ${dtb_img}\0" \
	"update_dtb=setenv img dtb; setenv psize ${dtbsize}; setenv installcmd \"install_dtb\"; run load_dtb test_img; setenv img; setenv psize; setenv installcmd\0" \
	"sd_update_dtb=echo Updating dtb from SD; mmcinfo && fatload mmc 0:1 ${clobstart} ${dtb_img} && run install_dtb\0" \
	"fault=echo ${img} image size is greater than allocated place - partition ${img} is NOT UPDATED\0" \
	"test_crc=if imi ${clobstart}; then run test_img; else echo ${img} Bad CRC - ${img} is NOT UPDATED; fi\0" \
	"test_img=setenv var \"if test ${filesize} -gt ${psize}\\; then run fault\\; else run ${installcmd}\\; fi\"; run var; setenv var\0" \
	"netboot=tftpboot ${netstart} ${kernel_img} && bootm\0" \
	"default_bootcmd=run cp_kernel2ram && bootm ${netstart}\0" \
""

