#include <configs/xilinx_zynqmp.h>

#define CONFIG_SERVERIP 192.168.30.2

#define CONFIG_EXTRA_ENV_SETTINGS \
    "arch=arm\0" \
    "arch=arm\0" \
    "baudrate=115200\0" \
    "board=zynqmp\0" \
    "board_name=zynqmp\0" \
    "boot_a_script=load ${devtype} ${devnum}:${distro_bootpart} ${scriptaddr} ${prefix}${scri}\0" \
    "boot_efi_binary=if fdt addr ${fdt_addr_r}; then bootefi bootmgr ${fdt_addr_r};else bootei\0" \
    "boot_extlinux=sysboot ${devtype} ${devnum}:${distro_bootpart} any ${scriptaddr} ${prefix}\0" \
    "boot_net_usb_start=usb start\0" \
    "boot_prefixes=/ /boot/\0" \
    "boot_script_dhcp=boot.scr.uimg\0" \
    "boot_scripts=boot.scr.uimg boot.scr\0" \
    "boot_syslinux_conf=extlinux/extlinux.conf\0" \
    "boot_targets=mmc1 jtag mmc0 mmc1 qspi0 nand0 usb0 usb1 scsi0 pxe dhcp\0" \
    "bootcmd=run distro_bootcmd\0" \
    "bootcmd_dhcp=run boot_net_usb_start; if dhcp ${scriptaddr} ${boot_script_dhcp}; then sou;\0" \
    "bootcmd_jtag=echo JTAG: Trying to boot script at ${scriptaddr} && source ${scriptaddr}; ;\0" \
    "bootcmd_mmc0=devnum=0; run mmc_boot\0" \
    "bootcmd_mmc1=devnum=1; run mmc_boot\0" \
    "bootcmd_nand0= nand info && nand read $scriptaddr $script_offset_f $script_size_f && ech;\0" \
    "bootcmd_pxe=run boot_net_usb_start; dhcp; if pxe get; then pxe boot; fi\0" \
    "bootcmd_qspi0=sf probe 0 0 0 && sf read $scriptaddr $script_offset_f $script_size_f && e;\0" \
    "bootcmd_scsi0=devnum=0; run scsi_boot\0" \
    "bootcmd_usb0=devnum=0; run usb_boot\0" \
    "bootcmd_usb1=devnum=1; run usb_boot\0" \
    "bootdelay=2\0" \
    "bootm_low=0\0" \
    "bootm_size=7ff00000\0" \
    "cpu=armv8\0" \
    "dfu_ram=run dfu_ram_info && dfu 0 ram 0\0" \
    "dfu_ram_info=setenv dfu_alt_info Image ram 80000 $kernel_size_r\\;system.dtb ram $fdt_adr\0" \
    "distro_bootcmd=scsi_need_init=; for target in ${boot_targets}; do run bootcmd_${target};e\0" \
    "efi_dtb_prefixes=/ /dtb/ /dtb/current/\0" \
    "fdt_addr_r=0x40000000\0" \
    "fdt_high=10000000\0" \
    "fdt_size_r=0x400000\0" \
    "fdtcontroladdr=7dd99548\0" \
    "fdtfile=xilinx/zynqmp.dtb\0" \
    "initrd_high=79000000\0" \
    "kernel_addr_r=0x18000000\0" \
    "kernel_size_r=0x10000000\0" \
    "load_efi_dtb=load ${devtype} ${devnum}:${distro_bootpart} ${fdt_addr_r} ${prefix}${efi_f}\0" \
    "mmc_boot=if mmc dev ${devnum}; then devtype=mmc; run scan_dev_for_boot_part; fi\0" \
    "modeboot=sdboot\0" \
    "pxefile_addr_r=0x10000000\0" \
    "ramdisk_addr_r=0x02100000\0" \
    "reset_reason=EXTERNAL\0" \
    "scan_dev_for_boot=echo Scanning ${devtype} ${devnum}:${distro_bootpart}...; for prefix i;\0" \
    "scan_dev_for_boot_part=part list ${devtype} ${devnum} -bootable devplist; env exists devt\0" \
    "scan_dev_for_efi=setenv efi_fdtfile ${fdtfile}; for prefix in ${efi_dtb_prefixes}; do ife\0" \
    "scan_dev_for_extlinux=if test -e ${devtype} ${devnum}:${distro_bootpart} ${prefix}${booti\0" \
    "scan_dev_for_scripts=for script in ${boot_scripts}; do if test -e ${devtype} ${devnum}:$e\0" \
    "script_offset_f=3e80000\0" \
    "script_size_f=0x80000\0" \
    "scriptaddr=0x20000000\0" \
    "scsi_boot=run scsi_init; if scsi dev ${devnum}; then devtype=scsi; run scan_dev_for_booti\0" \
    "scsi_init=if ${scsi_need_init}; then scsi_need_init=false; scsi scan; fi\0" \
    "serverip=192.168.30.2\0" \
    "soc=zynqmp\0" \
    "stderr=serial@ff000000\0" \
    "stdin=serial@ff000000\0" \
    "stdout=serial@ff000000\0" \
    "thor_ram=run dfu_ram_info && thordown 0 ram 0\0" \
    "ubifs_boot=env exists bootubipart || env set bootubipart UBI; env exists bootubivol || ei\0" \
    "usb_boot=usb start; if usb dev ${devnum}; then devtype=usb; run scan_dev_for_boot_part; i\0" \
    "vendor=xilinx\0" \
""