#include <configs/xilinx_zynqmp.h>

#define CONFIG_SERVERIP	192.168.30.2

/* Don't define BOOTARGS, we get it from the DTB chosen fragment */
#define CONFIG_EXTRA_ENV_SETTINGS \
	"distro_bootcmd=scsi_need_init=; for target in ${boot_targets}; do run bootcmd_${target};e\0" \
	"bootargs=console=ttyPS0,115200 earlycon clk_ignore_unused rootwait root=/dev/nfs rw ip=dhcp nfsroot=192.168.30.2:/export/CentOS,nfsvers=3,tcp\0" \
""

