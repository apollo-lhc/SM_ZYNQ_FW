#!/bin/bash

#if [ -z $DTSI_PATH ] ; then
#    echo ERROR: DTSI_PATH not defined
#    exit 1
#fi

DTSI_PATH=$@

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
echo "        bootargs = \"earlycon clk_ignore_unused earlyprintk uio_pdrv_genirq.of_id=generic-uio  root=/dev/mmcblk0p2 rw rootwait\";" >> $filename
echo "        };"                     >> $filename
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



