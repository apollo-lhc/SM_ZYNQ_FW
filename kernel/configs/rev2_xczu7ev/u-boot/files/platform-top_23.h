#include <configs/xilinx_zynqmp.h>

#define CONFIG_SERVERIP	192.168.30.2

#define CONFIG_EXTRA_ENV_SETTINGS \
    "boot_targets=mmc1 jtag mmc0 mmc1 qspi0 nand0 usb0 usb1 scsi0 pxe dhcp\0" \
    "distro_bootcmd=scsi_need_init=; for target in ${boot_targets}; do run bootcmd_${target}; done\0" \
    "bootargs=console=ttyPS0,115200 earlycon clk_ignore_unused rootwait root=/dev/nfs rw ip=dhcp nfsroot=192.168.30.2:/export/CentOS,nfsvers=3,tcp\0" \
    "bootcmd_mmc0=devnum=0; run mmc_boot\0" \
    "bootcmd_mmc1=devnum=1; run mmc_boot\0" \
    "bootcmd_jtag=echo JTAG: Trying to boot script at ${scriptaddr} && source ${scriptaddr}; echo JTAG: SCRIPT FAILED: continuing...;\0" \
    "bootcmd_qspi0=sf probe 0 0 0 && sf read $scriptaddr $script_offset_f $script_size_f && echo QSPI: Trying to boot script at ${scriptaddr} && source ${scriptaddr}; echo QSPI: SCRIPT FAILED: continuing...;\0" \
    "bootcmd_nand0= nand info && nand read $scriptaddr $script_offset_f $script_size_f && echo NAND: Trying to boot script at ${scriptaddr} && source ${scriptaddr}; echo NAND: SCRIPT FAILED: continuing...;\0" \
    "bootcmd_usb0=devnum=0; run usb_boot\0" \
    "bootcmd_usb1=devnum=1; run usb_boot\0" \
    "bootcmd_scsi0=devnum=0; run scsi_boot\0" \
    "bootcmd_pxe=run boot_net_usb_start; dhcp; if pxe get; then pxe boot; fi\0" \
    "bootcmd_dhcp=run boot_net_usb_start; if dhcp ${scriptaddr} ${boot_script_dhcp}; then source ${scriptaddr}; fi;setenv efi_fdtfile ${fdtfile}; setenv efi_old_vci ${bootp_vci};setenv efi_old_arch ${bootp_arch};setenv bootp_vci PXEClient:Arch:00011:UNDI:003000;setenv bootp_arch 0xb;if dhcp ${kernel_addr_r}; then tftpboot ${fdt_addr_r} dtb/${efi_fdtfile};if fdt addr ${fdt_addr_r}; then bootefi ${kernel_addr_r} ${fdt_addr_r}; else bootefi ${kernel_addr_r} ${fdtcontroladdr};fi;fi;setenv bootp_vci ${efi_old_vci};setenv bootp_arch ${efi_old_arch};setenv efi_fdtfile;setenv efi_old_arch;setenv efi_old_vci;\0" \
    "boot_script_dhcp=boot.scr.uimg\0" \
    "mmc_boot=if mmc dev ${devnum}; then devtype=mmc; run scan_dev_for_boot_part; fi\0" \
    "scan_dev_for_boot_part=part list ${devtype} ${devnum} -bootable devplist; env exists devplist || setenv devplist 1; for distro_bootpart in ${devplist}; do if fstype ${devtype} ${devnum}:${distro_bootpart} bootfstype; then run scan_dev_for_boot; fi; done; setenv devplist\0" \
    "scan_dev_for_boot=echo Scanning ${devtype} ${devnum}:${distro_bootpart}...; for prefix in ${boot_prefixes}; do run scan_dev_for_extlinux; run scan_dev_for_scripts; done;run scan_dev_for_efi;\0" \
    "scan_dev_for_extlinux=if test -e ${devtype} ${devnum}:${distro_bootpart} ${prefix}${boot_syslinux_conf}; then echo Found ${prefix}${boot_syslinux_conf}; run boot_extlinux; echo SCRIPT FAILED: continuing...; fi\0" \
    "scan_dev_for_scripts=for script in ${boot_scripts}; do if test -e ${devtype} ${devnum}:${distro_bootpart} ${prefix}${script}; then echo Found U-Boot script ${prefix}${script}; run boot_a_script; echo SCRIPT FAILED: continuing...; fi; done\0" \
    "boot_a_script=load ${devtype} ${devnum}:${distro_bootpart} ${scriptaddr} ${prefix}${script}; source ${scriptaddr}\0" \
    "scsi_boot=run scsi_init; if scsi dev ${devnum}; then devtype=scsi; run scan_dev_for_boot_part; fi\0" \
    "scsi_init=if ${scsi_need_init}; then scsi_need_init=false; scsi scan; fi\0" \
    "scan_dev_for_efi=setenv efi_fdtfile ${fdtfile}; for prefix in ${efi_dtb_prefixes}; do if test -e ${devtype} ${devnum}:${distro_bootpart} ${prefix}${efi_fdtfile}; then run load_efi_dtb; fi;done;if test -e ${devtype} ${devnum}:${distro_bootpart} efi/boot/bootaa64.efi; then echo Found EFI removable media binary efi/boot/bootaa64.efi; run boot_efi_binary; echo EFI LOAD FAILED: continuing...; fi; setenv efi_fdtfile\0" \
    "usb_boot=usb start; if usb dev ${devnum}; then devtype=usb; run scan_dev_for_boot_part; fi\0" \
    "scriptaddr=0x20000000\0" \
    "script_size_f=0x80000\0" \
    "boot_efi_binary=if fdt addr ${fdt_addr_r}; then bootefi bootmgr ${fdt_addr_r};else bootefi bootmgr ${fdtcontroladdr};fi;load ${devtype} ${devnum}:${distro_bootpart} ${kernel_addr_r} efi/boot/bootaa64.efi; if fdt addr ${fdt_addr_r}; then bootefi ${kernel_addr_r} ${fdt_addr_r};else bootefi ${kernel_addr_r} ${fdtcontroladdr};fi\0" \
    "boot_extlinux=sysboot ${devtype} ${devnum}:${distro_bootpart} any ${scriptaddr} ${prefix}${boot_syslinux_conf}\0" \
    "boot_net_usb_start=usb start\0" \
    "boot_prefixes=/ /boot/\0" \
    "boot_scripts=boot.scr.uimg boot.scr\0" \
    "boot_syslinux_conf=extlinux/extlinux.conf\0" \
    "dfu_ram=run dfu_ram_info && dfu 0 ram 0\0" \
    "dfu_ram_info=setenv dfu_alt_info Image ram 80000 $kernel_size_r\\;system.dtb ram $fdt_addr_r $fdt_size_r\0" \
    "efi_dtb_prefixes=/ /dtb/ /dtb/current/\0" \
    "fdt_addr_r=0x40000000\0" \
    "fdt_high=10000000\0" \
    "fdt_size_r=0x400000\0" \
    "kernel_addr_r=0x18000000\0" \
    "kernel_size_r=0x10000000\0" \
    "load_efi_dtb=load ${devtype} ${devnum}:${distro_bootpart} ${fdt_addr_r} ${prefix}${efi_fdtfile}\0" \
    "ubifs_boot=env exists bootubipart || env set bootubipart UBI; env exists bootubivol || env set bootubivol boot; if ubi part ${bootubipart} && ubifsmount ubi${devnum}:${bootubivol}; then devtype=ubi; run scan_dev_for_boot; fi\0" \
""

