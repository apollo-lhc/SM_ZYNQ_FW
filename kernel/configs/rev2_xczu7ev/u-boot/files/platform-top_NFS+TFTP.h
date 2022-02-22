#include <configs/xilinx_zynqmp.h>

#define pushCEES _Pragma("push_macro(\"CONFIG_EXTRA_ENV_SETTINGS\")")
#define popCEES _Pragma("pop_macro(\"CONFIG_EXTRA_ENV_SETTINGS\")")

pushCEES
#undef CONFIG_EXTRA_ENV_SETTINGS
#define CONFIG_EXTRA_ENV_SETTINGS popCEES CONFIG_EXTRA_ENV_SETTINGS \
	"bootargs=console=ttyPS0,115200 earlycon clk_ignore_unused rootwait root=/dev/nfs rw ip=dhcp nfsroot=192.168.30.2:/export/CentOS,nfsvers=3,tcp\0" \
	"autoload=no\0" \
	"netstart=0x04000000\0" \
	"kernel_img=image.ub\0" \
	"netboot=dhcp && setenv serverip 192.168.30.2 && tftpboot ${netstart} ${kernel_img} && bootm ${netstart}\0" \
	"bootcmd=run netboot\0" \
""
