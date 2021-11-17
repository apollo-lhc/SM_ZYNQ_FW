#!/bin/bash

if [ -z $DTSI_PATH ] ; then
    echo ERROR: DTSI_PATH not defined
    exit 1
fi

#filename=test.dtsi
filename=/dev/stdout

#Collect all the dtsi chunk files that go in the root /{ namespace
chunks=$(find $DTSI_PATH -name "*dtsi_chunk")
#collect all the dtsi post chunks that go oustide of the /{ namespace
post_chunks=$(find $DTSI_PATH -name "*dtsi_post_chunk")

#output updated dtsi fle
echo "/include/ \"system-conf.dtsi\"" > $filename
echo "#include <dt-bindings/gpio/gpio.h>" >> $filename
echo "#include <dt-bindings/pinctrl/pinctrl-zynqmp.h>" >> $filename
echo "#include <dt-bindings/phy/phy.h>" >> $filename
echo "/{"                             >> $filename
echo "  chosen {"                     >> $filename
#update bootargs to include uio
echo "        bootargs = \"console=ttyPS0,115200 earlycon clk_ignore_unused rootwait root=/dev/nfs rw ip=dhcp nfsroot=192.168.30.2:/export/CentOS,nfsvers=3,tcp\";" >> $filename
echo "        };"                     >> $filename
##add lines for amba_pl in case there are no xilinx IPs to add them
#echo "	amba_pl: amba_pl {"           >> $filename
#echo "		#address-cells = <2>;" >> $filename
#echo "		#size-cells = <2>;" >> $filename
#echo "		compatible = \"simple-bus\";" >> $filename
#echo "		ranges ;" >> $filename
#echo "  };" >> $filename
#add the dtsi chunk files here
for chunk in $chunks
do 
    cat $chunk >> $filename
done
echo "};"                             >> $filename

#add the post chunk files here
for chunk in $post_chunks
do 
    cat $chunk >> $filename
done



