#include <configs/xilinx_zynqmp.h>

#define CONFIG_SERVERIP	192.168.30.2

#define CONFIG_BOOTARGS "console=ttyPe0,115200 earlycon clk_ignore_unused rootwait root=/dev/nfs rw ip=dhcp nfsroot=192.168.30.2:/export/CentOS,nfsvers=3,tcp"
