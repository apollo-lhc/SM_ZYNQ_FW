/******************************************************************************
*
* Copyright (C) 2012 - 2014 Xilinx, Inc.  All rights reserved.
* 
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal 
* in the Software without restriction, including without limitation the rights 
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell  
* copies of the Software, and to permit persons to whom the Software is 
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in 
* all copies or substantial portions of the Software.
*
* Use of the Software is limited solely to applications: 
* (a) running on a Xilinx device, or 
* (b) that interact with a Xilinx device through a bus or interconnect.  
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
* XILINX  BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF 
* OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE 
* SOFTWARE.
*
* Except as contained in this notice, the name of the Xilinx shall not be used
* in advertising or otherwise to promote the sale, use or other dealings in 
* this Software without prior written authorization from Xilinx.
*
******************************************************************************/

/*****************************************************************************
*
* @file fsbl_hooks.c
*
* This file provides functions that serve as user hooks.  The user can add the
* additional functionality required into these routines.  This would help retain
* the normal FSBL flow unchanged.
*
* <pre>
* MODIFICATION HISTORY:
*
* Ver   Who  Date        Changes
* ----- ---- -------- -------------------------------------------------------
* 3.00a np   08/03/12 Initial release
* </pre>
*
* @note
*
******************************************************************************/


#include "fsbl.h"
#include "xstatus.h"
#include "fsbl_hooks.h"
#include <sleep.h>
/************************** Variable Definitions *****************************/


/************************** Function Prototypes ******************************/


/******************************************************************************
* This function is the hook which will be called  before the bitstream download.
* The user can add all the customized code required to be executed before the
* bitstream download to this routine.
*
* @param None
*
* @return
*		- XST_SUCCESS to indicate success
*		- XST_FAILURE.to indicate failure
*
****************************************************************************/
u32 FsblHookBeforeBitstreamDload(void)
{
	u32 Status;

	Status = XST_SUCCESS;

	/*
	 * User logic to be added here. Errors to be stored in the status variable
	 * and returned
	 */
	fsbl_printf(DEBUG_INFO,"In FsblHookBeforeBitstreamDload function \r\n");

	return (Status);
}

/******************************************************************************
* This function is the hook which will be called  after the bitstream download.
* The user can add all the customized code required to be executed after the
* bitstream download to this routine.
*
* @param None
*
* @return
*		- XST_SUCCESS to indicate success
*		- XST_FAILURE.to indicate failure
*
****************************************************************************/
u32 FsblHookAfterBitstreamDload(void)
{
	u32 Status;

	Status = XST_SUCCESS;

	/*
	 * User logic to be added here.
	 * Errors to be stored in the status variable and returned
	 */
	fsbl_printf(DEBUG_INFO, "In FsblHookAfterBitstreamDload function \r\n");

	return (Status);
}

u16 ConfigData[] = {
  0x010B, //0xb
  0x24C0, 0x2500,
  0x0105, //0x5
  0x4001,
  0x0100, //0x0
  0x0600, 0x0700, 0x0800, 0x0B68, 0x1602, 0x17DC, 0x18EE, 0x19DD,
  0x1ADF, 0x2B02, 0x2C01, 0x2D01, 0x2E38, 0x2F00, 0x3000, 0x3100,
  0x3200, 0x3300, 0x3400, 0x3500, 0x3638, 0x3700, 0x3800, 0x3900,
  0x3A00, 0x3B00, 0x3C00, 0x3D00, 0x3F11, 0x4004, 0x410D, 0x4200,
  0x4300, 0x4400, 0x450C, 0x4632, 0x4700, 0x4800, 0x4900, 0x4A32,
  0x4B00, 0x4C00, 0x4D00, 0x4E05, 0x4F00, 0x500F, 0x5103, 0x5200,
  0x5300, 0x5400, 0x5503, 0x5600, 0x5700, 0x5800, 0x5901, 0x5AAA,
  0x5BAA, 0x5C0A, 0x5D01, 0x5E00, 0x5F00, 0x6000, 0x6100, 0x6200,
  0x6300, 0x6400, 0x6500, 0x6600, 0x6700, 0x6800, 0x6900, 0x9202,
  0x93A0, 0x9500, 0x9680, 0x9860, 0x9A02, 0x9B60, 0x9D08, 0x9E40,
  0xA020, 0xA200, 0xA9A7, 0xAA61, 0xAB00, 0xAC00, 0xE521, 0xEA0A,
  0xEB60, 0xEC00, 0xED00,
  0x0101, //0x1
  0x0201, 0x1202, 0x1309, 0x1433, 0x1508, 0x1702, 0x1809, 0x1933,
  0x1A08, 0x2602, 0x2709, 0x2833, 0x2909, 0x2B02, 0x2C09, 0x2D33,
  0x2E0A, 0x3F00, 0x4000, 0x4140, 0x42FF,
  0x0102, //0x2
  0x0600, 0x0832, 0x0900, 0x0A00, 0x0B00, 0x0C00, 0x0D00, 0x0E01,
  0x0F00, 0x1000, 0x1100, 0x1200, 0x1300, 0x1400, 0x1500, 0x1600,
  0x1700, 0x1800, 0x1900, 0x1A00, 0x1B00, 0x1C00, 0x1D00, 0x1E00,
  0x1F00, 0x2000, 0x2100, 0x2200, 0x2300, 0x2400, 0x2500, 0x2600,
  0x2700, 0x2800, 0x2900, 0x2A00, 0x2B00, 0x2C00, 0x2D00, 0x2E00,
  0x2F00, 0x310B, 0x320B, 0x330B, 0x340B, 0x3500, 0x3600, 0x3700,
  0x38C0, 0x39DA, 0x3A00, 0x3B00, 0x3C00, 0x3D00, 0x3EC0, 0x5003,
  0x5100, 0x5200, 0x5304, 0x5400, 0x5500, 0x5C02, 0x5D00, 0x5E00,
  0x5F02, 0x6000, 0x6100, 0x6B41, 0x6C50, 0x6D4F, 0x6E4C, 0x6F4C,
  0x704F, 0x7153, 0x724D, 0x8A00, 0x8B00, 0x8C00, 0x8D00, 0x8E00,
  0x8F00, 0x9000, 0x9100, 0x94B0, 0x9602, 0x9702, 0x9902, 0x9DFA,
  0x9E01, 0x9F00, 0xA9CC, 0xAA04, 0xAB00, 0xB7FF, 0x0103, 0x0200,
  0x0300, 0x0400, 0x0500, 0x0607, 0x0700, 0x0800, 0x0900, 0x0A00,
  0x0B80, 0x0C00, 0x0D00, 0x0E00, 0x0FEC, 0x1060, 0x1121, 0x1200,
  0x1300, 0x14B8, 0x15C6, 0x1692, 0x1700, 0x1800, 0x19C0, 0x1A49,
  0x1B6E, 0x1C0A, 0x1D00, 0x1E00, 0x1F8B, 0x2077, 0x21B7, 0x2200,
  0x2300, 0x2400, 0x2500, 0x2600, 0x2700, 0x2800, 0x2900, 0x2A00,
  0x2B00, 0x2C00, 0x2D00, 0x3800, 0x391F, 0x3B00, 0x3C00, 0x3D00,
  0x3E00, 0x3F00, 0x4000, 0x4100, 0x4200, 0x4300, 0x4400, 0x4500,
  0x4600, 0x4700, 0x4800, 0x4900, 0x4A00, 0x4B00, 0x4C00, 0x4D00,
  0x4E00, 0x4F00, 0x5000, 0x5100, 0x5200, 0x5900, 0x5A00, 0x5B00,
  0x5C00, 0x5D00, 0x5E00, 0x5F00, 0x6000,
  0x0104, //0x4
  0x8700,
  0x0105, //0x5
  0x0813, 0x0922, 0x0A0C, 0x0B0B, 0x0C07, 0x0D3F, 0x0E16, 0x0F2A, 
  0x1009, 0x1108, 0x1207, 0x133F, 0x1500, 0x1600, 0x1700, 0x1800,
  0x19BC, 0x1A02, 0x1B00, 0x1C00, 0x1D00, 0x1E00, 0x1F80, 0x212B,
  0x2A01, 0x2B01, 0x2C87, 0x2D03, 0x2E19, 0x2F19, 0x3100, 0x3242,
  0x3303, 0x3400, 0x3500, 0x3604, 0x3700, 0x3800, 0x3900, 0x3A02,
  0x3B03, 0x3C00, 0x3D11, 0x3E06, 0x890D, 0x8A00, 0x9BFA, 0x9D13,
  0x9E24, 0x9F0C, 0xA00B, 0xA107, 0xA23F, 0xA603,
  0x0108, //0x8
  0x0235, 0x0305, 0x0400, 0x0500, 0x0600, 0x0700, 0x0800, 0x0900,
  0x0A00, 0x0B00, 0x0C00, 0x0D00, 0x0E00, 0x0F00, 0x1000, 0x1100,
  0x1200, 0x1300, 0x1400, 0x1500, 0x1600, 0x1700, 0x1800, 0x1900,
  0x1A00, 0x1B00, 0x1C00, 0x1D00, 0x1E00, 0x1F00, 0x2000, 0x2100,
  0x2200, 0x2300, 0x2400, 0x2500, 0x2600, 0x2700, 0x2800, 0x2900,
  0x2A00, 0x2B00, 0x2C00, 0x2D00, 0x2E00, 0x2F00, 0x3000, 0x3100,
  0x3200, 0x3300, 0x3400, 0x3500, 0x3600, 0x3700, 0x3800, 0x3900,
  0x3A00, 0x3B00, 0x3C00, 0x3D00, 0x3E00, 0x3F00, 0x4000, 0x4100,
  0x4200, 0x4300, 0x4400, 0x4500, 0x4600, 0x4700, 0x4800, 0x4900,
  0x4A00, 0x4B00, 0x4C00, 0x4D00, 0x4E00, 0x4F00, 0x5000, 0x5100,
  0x5200, 0x5300, 0x5400, 0x5500, 0x5600, 0x5700, 0x5800, 0x5900,
  0x5A00, 0x5B00, 0x5C00, 0x5D00, 0x5E00, 0x5F00, 0x6000, 0x6100,
  0x0109, //0x9
  0x0E02, 0x4300, 0x4901, 0x4A01, 0x4E49, 0x4F02, 0x5E00,
  0x010A, //0xA
  0x0200, 0x0307, 0x0401, 0x0507, 0x1400, 0x1A00, 0x2000, 0x2600,
  0x010B, //0xb
  0x442F, 0x4600, 0x470E, 0x480E, 0x4A08, 0x570E, 0x5801,
  0x0105, //0x5
  0x1401,
  0x0100, //0x0
  0x1C01,
  0x0105, //0x5
  0x4000,
  0x010B, //0xb
  0x24C3, 0x2502};

#define SI_I2C_ADDRESS   0xD0
#define SI_I2C_BASE_ADDR 0x41600000
#define I2C_RX_FIFO_PIRQ (SI_I2C_BASE_ADDR + (sizeof(u32)*0x46))
#define I2C_CONTROL      (SI_I2C_BASE_ADDR + (sizeof(u32)*0x40))
#define I2C_STATUS       (SI_I2C_BASE_ADDR + (sizeof(u32)*0x41))
#define I2C_RX_FIFO      (SI_I2C_BASE_ADDR + (sizeof(u32)*0x43))
#define I2C_TX_FIFO      (SI_I2C_BASE_ADDR + (sizeof(u32)*0x42))
#define I2C_RESET        (SI_I2C_BASE_ADDR + (sizeof(u32)*0x10))

void SiI2cWrite(u8 address,u8 data){
  Xil_Out32(I2C_RESET    , 0xA);
  Xil_Out32(I2C_CONTROL  , 0x2);
  Xil_Out32(I2C_CONTROL  , 0xC);
  Xil_Out32(I2C_TX_FIFO  , 0x100 | ((u32)SI_I2C_ADDRESS));
  Xil_Out32(I2C_TX_FIFO  , (u32) address);
  Xil_Out32(I2C_TX_FIFO  , 0x200 | ((u32)data));
  Xil_Out32(I2C_CONTROL  , 0xD);
  u16 tries = 20000;
  //Time out of something isn't working
  //  while(!(Xil_In32(I2C_STATUS) & 0x80)){
  while((Xil_In32(I2C_STATUS) & 0x4)){
    tries--;
    if(!tries){
      fsbl_printf(DEBUG_GENERAL,"Timeout on 0x%02X @ 0x%02X\r\n",data,address);
      break;
    }
  }
  //  usleep(50);
  Xil_Out32(I2C_CONTROL, 0x0);

  //  fsbl_printf(DEBUG_GENERAL,"I2C Write: 0x%02X @ 0x%02X\r\n",data,address);
}
#define SI_CONFIG_BASE_ADDR 0x43C20000
#define SGMII_BASE_ADDR 0x43C20030

/******************************************************************************
* This function is the hook which will be called  before the FSBL does a handoff
* to the application. The user can add all the customized code required to be
* executed before the handoff to this routine.
*
* @param None
*
* @return
*		- XST_SUCCESS to indicate success
*		- XST_FAILURE.to indicate failure
*
****************************************************************************/
u32 FsblHookBeforeHandoff(void)
{
	u32 Status;

	/*https://www.beyond-circuits.com/wordpress/2018/05/updating-the-first-stage-bootloader-in-petalinux-v2017-4/*/
	fsbl_printf(DEBUG_GENERAL,"\r\n\r\n\r\n\r\n\r\n");
	fsbl_printf(DEBUG_GENERAL,"========================================\r\n");
	fsbl_printf(DEBUG_GENERAL,"Programming Si-5344 \r\n");

	Xil_Out32(SI_CONFIG_BASE_ADDR,0x2);
	u16 iWrite=0;
	for(; iWrite < 5 ;iWrite++){
	  SiI2cWrite((u8)((ConfigData[iWrite] >> 8) & 0xFF)  ,
		     (u8)((ConfigData[iWrite]     ) & 0xFF));
	}
	usleep(400000);
	for(; iWrite < (sizeof(ConfigData)/sizeof(u16));iWrite++){
	  SiI2cWrite((u8)((ConfigData[iWrite] >> 8) & 0xFF)  ,
		     (u8)((ConfigData[iWrite]     ) & 0xFF));
	}
	fsbl_printf(DEBUG_GENERAL,"Waiting for lock\r\n");

	Xil_Out32(SI_CONFIG_BASE_ADDR,0x3);
	usleep(1000000); //wait 1s

	u16 tries = 20000;
	//Waitinf for lock
	while((Xil_In32(SI_CONFIG_BASE_ADDR) & 0x60)){
	  usleep(1000);
	  tries--;
	  if(!tries){
	    fsbl_printf(DEBUG_GENERAL,"Warning: Timeout waiting for Si lock\r\n");
	    break;
	  }
	}

	fsbl_printf(DEBUG_GENERAL,"Si status:    0x%08X\r\n",Xil_In32(SI_CONFIG_BASE_ADDR));
	fsbl_printf(DEBUG_GENERAL,"SGMII status: 0x%08X\r\n",Xil_In32(SGMII_BASE_ADDR));
	fsbl_printf(DEBUG_GENERAL,"========================================\r\n");
	fsbl_printf(DEBUG_GENERAL,"\r\n\r\n\r\n\r\n\r\n");

	Status = XST_SUCCESS;

	/*
	 * User logic to be added here.
	 * Errors to be stored in the status variable and returned
	 */
	fsbl_printf(DEBUG_INFO,"In FsblHookBeforeHandoff function \r\n");

	return (Status);
}


/******************************************************************************
* This function is the hook which will be called in case FSBL fall back
*
* @param None
*
* @return None
*
****************************************************************************/
void FsblHookFallback(void)
{
	/*
	 * User logic to be added here.
	 * Errors to be stored in the status variable and returned
	 */
	fsbl_printf(DEBUG_INFO,"In FsblHookFallback function \r\n");
	while(1);
}


