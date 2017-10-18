#pragma NOIV               // Do not generate interrupt vectors
//-----------------------------------------------------------------------------
//   File:      bulksrc.c
//   Contents:   Hooks required to implement USB peripheral function.
//
// $Archive: /USB/Examples/FX2LP/bulksrc/bulksrc.c $
// $Date: 3/23/05 2:56p $
// $Revision: 3 $
//
//   Copyright (c) 2000 Cypress Semiconductor All rights reserved
//-----------------------------------------------------------------------------
#include "fx2.h"
#include "fx2regs.h"
#include "syncdly.h"            // SYNCDELAY macro

extern BOOL GotSUD;             // Received setup data flag
extern BOOL Sleep;
extern BOOL Rwuen;
extern BOOL Selfpwr;

BYTE Configuration;             // Current configuration
BYTE AlternateSetting;          // Alternate settings

//BYTE xdata myBuffer[512];
//WORD myBufferCount;
WORD packetSize;

//-----------------------------------------------------------------------------
// Task Dispatcher hooks
//   The following hooks are called by the task dispatcher.
//-----------------------------------------------------------------------------

void TD_Init(void)              // Called once at startup
{
/*  old code
   CPUCS = 0x10; // 48MHZ
   IFCONFIG |= bm3048MHZ+bmIFCFG1+bmIFCFG0;
  // CPUCS = bmCLKSPD1 + bmCLKOE;//48MHz CLKOUT enable
  // CPUCS = 0x12;
   SYNCDELAY;
   REVCTL = 0x03;
   SYNCDELAY;
   PINFLAGSAB = 0xEA; //set FLAGB=EP6 full flag,FLAGA=EP6 empty flag
   SYNCDELAY;
   PINFLAGSCD = 0xC8; //set FLAGD=EP2 full flag,FLAGC=EP2 empty flag
   SYNCDELAY;
   PORTACFG =0x40 ;//when in slavefifo mode set PA7 pin as the slave FIFO chip select
   SYNCDELAY;
   FIFOPINPOLAR=0x03;
   SYNCDELAY;
// IFCONFIG |= bm3048MHZ+bmIFCLKOE+bmASYNC+bmIFCFG1+bmIFCFG0;//internal clock48MHZ,IFCLK pin output,Slavefifo operate aynchronously,modified by junbin 20140219
//   IFCONFIG = 0x03;	   //external IFCLK, Synchronous Slavefifo mode
//   IFCONFIG = 0x43;	
//   IFCONFIG |= bm3048MHZ+bmIFCFG1+bmIFCFG0;
   SYNCDELAY;  
   EP2CFG=0xA0;  //out,512bytes,4*,bulk
   SYNCDELAY;
   EP6CFG=0xE0;  //IN,512bytes,4*,bulk
   SYNCDELAY;
   //EP4 and EP8 are not used.
   EP4CFG=0x7f;  //clear valid bit disable EP4
   SYNCDELAY;
   EP8CFG=0x7f;  //clear valid bit disable EP6
   SYNCDELAY;

//   EP2FIFOPFH=0x00;//add 20140219
//   EP2FIFOPFL=0x3d;//缓存数据小于0x3d时EP2PF有效

   SYNCDELAY;
   FIFORESET = 0x80; //activate NAK-ALL to avoid race conditions
   SYNCDELAY;
   FIFORESET = 0x02; //reset,FIFO2
   SYNCDELAY;
   FIFORESET = 0x04; //reset,FIFO4
   SYNCDELAY;
   FIFORESET = 0x06; //reset FIFO6
   SYNCDELAY;
   FIFORESET = 0x08; //reset FIFO8
   SYNCDELAY;
   FIFORESET = 0x00; //deactivate NAK-ALL
   //handle the case where we were already in AUTO mode
   SYNCDELAY;
   EP2FIFOCFG = 0x00;
   SYNCDELAY;
   // core needs to see AUTOOUT=0 to AUTOOUT=1 switch to arm endpoints
   OUTPKTEND = 0x82;
   SYNCDELAY;
   OUTPKTEND = 0x82;
   SYNCDELAY;
   OUTPKTEND = 0x82;
   SYNCDELAY;
   OUTPKTEND = 0x82;
   SYNCDELAY;  
   EP2FIFOCFG = 0x11;  //AUTOOUT=1,WORDWIDE=1
   SYNCDELAY;
   EP6FIFOCFG = 0x0D;  //AUTOIN=1,ZEROLENIN=1,WORDWIDE=1
   SYNCDELAY;
   IFCONFIG = 0x43;	
   */
   /*new EP2 and EP6*/
   
   CPUCS = 0x12; //48M CLKOUT ENABLE
   IFCONFIG |= bm3048MHZ+bmIFCFG1+bmIFCFG0;
  // IFCONFIG = 0x43;//使用外部时钟，IFCLK输入不反向
  // REVCTL = 0x03;
   SYNCDELAY;
   EP2CFG=0xA0;  //out,512bytes,4*,bulk
   SYNCDELAY;
   EP6CFG=0xE0;  //IN,512bytes,4*,bulk
   SYNCDELAY;
   //EP4 and EP8 are not used.
   EP4CFG=0x00;  //clear valid bit disable EP4
   SYNCDELAY;
   EP8CFG=0x00;  //clear valid bit disable EP6

   SYNCDELAY;
   FIFORESET = 0x80; //activate NAK-ALL to avoid race conditions
   SYNCDELAY;
   FIFORESET = 0x02; //reset,FIFO2
   SYNCDELAY;
   FIFORESET = 0x04; //reset,FIFO4
   SYNCDELAY;
   FIFORESET = 0x06; //reset FIFO6
   SYNCDELAY;
   FIFORESET = 0x08; //reset FIFO8
   SYNCDELAY;
   FIFORESET = 0x00; //deactivate NAK-ALL

   SYNCDELAY;
   PINFLAGSAB = 0xEA; //set FLAGB=EP6 full flag,FLAGA=EP6 empty flag
   SYNCDELAY;
   PINFLAGSCD = 0xf8; //set FLAGD reserved flag,FLAGC=EP2 empty flag
   SYNCDELAY;
   PORTACFG |= 0x00; //0x40//when in slavefifo mode set PA7 pin as the slave FIFO chip select
   SYNCDELAY;
   FIFOPINPOLAR=0x03;
   SYNCDELAY;
   //小于64字节有效
   EP6FIFOPFH = 0x00;
   EP6FIFOPFL = 0x40;
   //handle the case where we were already in AUTO mode
   EP2FIFOCFG = 0x01; //AUTOOUT = 0, WORDWIDE =1;
   SYNCDELAY;
   EP2FIFOCFG = 0x11; //AUTOOUT =1 ,WORDWIDE =1;
   SYNCDELAY;
   EP6FIFOCFG = 0x09; //AUTOIN=1,ZEROLENIN =0 ,WORDWIDE =1;
   SYNCDELAY;
   IFCONFIG = 0x53;	 //反向时钟缩小延迟果然成功了
   //IFCONFIG = 0x43;//不反向
   
   /*new EP2 IN and EP8 out*/
   /*
   CPUCS = 0x12; //48M CLKOUT ENABLE
   IFCONFIG |= bm3048MHZ+bmIFCFG1+bmIFCFG0;
  // IFCONFIG = 0x43;//使用外部时钟，IFCLK输入不反向
   //REVCTL = 0x03;
   SYNCDELAY;
   EP2CFG = 0xEB;  //EP2, valid IN, 1024bytes, 3* bulk modified 2015/10/24
   SYNCDELAY;
   EP8CFG = 0xA0; //EP8, valid OUT 512bytes,2*,bulk 
   SYNCDELAY;
   //EP4 and EP6 are not used.
   EP4CFG=0x00;  //clear valid bit disable EP4
   SYNCDELAY;
   EP6CFG=0x00;  //clear valid bit disable EP6

   SYNCDELAY;
   FIFORESET = 0x80; //activate NAK-ALL to avoid race conditions
   SYNCDELAY;
   FIFORESET = 0x02; //reset,FIFO2
   SYNCDELAY;
   FIFORESET = 0x04; //reset,FIFO4
   SYNCDELAY;
   FIFORESET = 0x06; //reset FIFO6
   SYNCDELAY;
   FIFORESET = 0x08; //reset FIFO8
   SYNCDELAY;
   FIFORESET = 0x00; //deactivate NAK-ALL

   SYNCDELAY;
   PINFLAGSAB = 0xC8;  //set FLAGB = EP2 full flag, FLAGA = EP2 empty flag
   SYNCDELAY;
   PINFLAGSCD = 0x3B;  //set FLAGD reserved flag, FLAGC = EP8 empty flag
   SYNCDELAY;
   PORTACFG |= 0x00; //0x40//when in slavefifo mode set PA7 FLAGD pin as the slave FIFO chip select
   SYNCDELAY;
   FIFOPINPOLAR=0x03;
   SYNCDELAY;
   EP2AUTOINLENH = 0x03; //set EP2 can have maximum size of 1024 bytes;
   SYNCDELAY;
   EP2AUTOINLENL = 0x00; //EP8 can have maximum sizes of 512 bytes.

   EP2FIFOPFH = 0x00;	//先放这里
   EP2FIFOPFL = 0x40;	//这个寄存器是用来设置可编程标志位，这里并不需要
   //handle the case where we were already in AUTO mode
   SYNCDELAY;
   EP8FIFOCFG = 0x01; //AUTOOUT = 0, WORDWIDE =1;
   SYNCDELAY;
   EP8FIFOCFG = 0x11; //AUTOOUT = 1, WORDWIDE = 1
   SYNCDELAY;
   EP2FIFOCFG = 0x09; //AUTOIN = 1, WORDWIDE = 1
   SYNCDELAY;
   IFCONFIG = 0x53;	 //反向时钟缩小延迟果然成功了
   //IFCONFIG = 0x43;//不反向
   */
}

void TD_Poll(void)              // Called repeatedly while the device is idle
{
  //nothing to do...slave fifo's are in AUTO mode
  //IFCONFIG = 0x03;	   //external IFCLK, Synchronous Slavefifo mode
}

BOOL TD_Suspend(void)          // Called before the device goes into suspend mode
{
   return(TRUE);
}

BOOL TD_Resume(void)          // Called after the device resumes
{
   return(TRUE);
}

//-----------------------------------------------------------------------------
// Device Request hooks
//   The following hooks are called by the end point 0 device request parser.
//-----------------------------------------------------------------------------

BOOL DR_GetDescriptor(void)
{
   return(TRUE);
}

BOOL DR_SetConfiguration(void)   // Called when a Set Configuration command is received
{
   /*****modified by Junbin**********/

   if(EZUSB_HIGHSPEED())  //in highspeed mode
   {
    EP6AUTOINLENH = 0x02;	//参考FX2 Slave FIFO
    SYNCDELAY;
    EP8AUTOINLENH = 0x02;   // set core AUTO commit len = 512 bytes
    SYNCDELAY;
    EP6AUTOINLENL = 0x00;
    SYNCDELAY;
    EP8AUTOINLENL = 0x00;		  	
   }
   else
   {
     // ...FX2 in full speed mode
    EP6AUTOINLENH = 0x00;
    SYNCDELAY;
    EP8AUTOINLENH = 0x00;   // set core AUTO commit len = 64 bytes
    SYNCDELAY;
    EP6AUTOINLENL = 0x40;
    SYNCDELAY;
    EP8AUTOINLENL = 0x40;
	}

   /*******************************/
   Configuration = SETUPDAT[2];
   return(TRUE);            // Handled by user code
}

BOOL DR_GetConfiguration(void)   // Called when a Get Configuration command is received
{
   EP0BUF[0] = Configuration;
   EP0BCH = 0;
   EP0BCL = 1;
   return(TRUE);            // Handled by user code
}

BOOL DR_SetInterface(void)       // Called when a Set Interface command is received
{
   AlternateSetting = SETUPDAT[2];
   return(TRUE);            // Handled by user code
}

BOOL DR_GetInterface(void)       // Called when a Set Interface command is received
{
   EP0BUF[0] = AlternateSetting;
   EP0BCH = 0;
   EP0BCL = 1;
   return(TRUE);            // Handled by user code
}

BOOL DR_GetStatus(void)
{
   return(TRUE);
}

BOOL DR_ClearFeature(void)
{
   return(TRUE);
}

BOOL DR_SetFeature(void)
{
   return(TRUE);
}
/*********modified by junbin************/
#define VX_C3 0xC3         
BOOL DR_VendorCmnd(void)     //examine EP6
{
	switch(SETUPDAT[1])
     {
       case VX_C3:
       {
       EP0BUF[0]=EP6FIFOBCH;
       EP0BUF[1]=EP6FIFOBCL;
       EP0BUF[2]=VX_C3;
       EP0BUF[3]=EP6FIFOFLGS;
         EP0BCH=0;
         EP0BCL=4;
       break;
       }
	default: return(TRUE);	
     }

     return(FALSE);
//	 return(TRUE);
}

//-----------------------------------------------------------------------------
// USB Interrupt Handlers
//   The following functions are called by the USB interrupt jump table.
//-----------------------------------------------------------------------------

// Setup Data Available Interrupt Handler
void ISR_Sudav(void) interrupt 0
{
   GotSUD = TRUE;            // Set flag
   EZUSB_IRQ_CLEAR();
   USBIRQ = bmSUDAV;         // Clear SUDAV IRQ
}

// Setup Token Interrupt Handler
void ISR_Sutok(void) interrupt 0
{
   EZUSB_IRQ_CLEAR();
   USBIRQ = bmSUTOK;         // Clear SUTOK IRQ
}

void ISR_Sof(void) interrupt 0
{
   EZUSB_IRQ_CLEAR();
   USBIRQ = bmSOF;            // Clear SOF IRQ
}

void ISR_Ures(void) interrupt 0
{
   if (EZUSB_HIGHSPEED())
   {
      pConfigDscr = pHighSpeedConfigDscr;
      pOtherConfigDscr = pFullSpeedConfigDscr;
      packetSize = 512;

   }
   else
   {
      pConfigDscr = pFullSpeedConfigDscr;
      pOtherConfigDscr = pHighSpeedConfigDscr;
      packetSize = 64;
   }
   
   EZUSB_IRQ_CLEAR();
   USBIRQ = bmURES;         // Clear URES IRQ
}

void ISR_Susp(void) interrupt 0
{
   Sleep = TRUE;
   EZUSB_IRQ_CLEAR();
   USBIRQ = bmSUSP;
}

void ISR_Highspeed(void) interrupt 0
{
   if (EZUSB_HIGHSPEED())
   {
      pConfigDscr = pHighSpeedConfigDscr;
      pOtherConfigDscr = pFullSpeedConfigDscr;
      packetSize = 512;

   }
   else
   {
      pConfigDscr = pFullSpeedConfigDscr;
      pOtherConfigDscr = pHighSpeedConfigDscr;
      packetSize = 64;
   }

   EZUSB_IRQ_CLEAR();
   USBIRQ = bmHSGRANT;
}
void ISR_Ep0ack(void) interrupt 0
{
}
void ISR_Stub(void) interrupt 0
{
}
void ISR_Ep0in(void) interrupt 0
{
}
void ISR_Ep0out(void) interrupt 0
{
}
void ISR_Ep1in(void) interrupt 0
{
}
void ISR_Ep1out(void) interrupt 0
{
}
void ISR_Ep2inout(void) interrupt 0
{
}
void ISR_Ep4inout(void) interrupt 0
{
}
void ISR_Ep6inout(void) interrupt 0
{
}
void ISR_Ep8inout(void) interrupt 0
{
}
void ISR_Ibn(void) interrupt 0
{
}
void ISR_Ep0pingnak(void) interrupt 0
{
}
void ISR_Ep1pingnak(void) interrupt 0
{
}
void ISR_Ep2pingnak(void) interrupt 0
{
}
void ISR_Ep4pingnak(void) interrupt 0
{
}
void ISR_Ep6pingnak(void) interrupt 0
{
}
void ISR_Ep8pingnak(void) interrupt 0
{
}
void ISR_Errorlimit(void) interrupt 0
{
}
void ISR_Ep2piderror(void) interrupt 0
{
}
void ISR_Ep4piderror(void) interrupt 0
{
}
void ISR_Ep6piderror(void) interrupt 0
{
}
void ISR_Ep8piderror(void) interrupt 0
{
}
void ISR_Ep2pflag(void) interrupt 0
{
}
void ISR_Ep4pflag(void) interrupt 0
{
}
void ISR_Ep6pflag(void) interrupt 0
{
}
void ISR_Ep8pflag(void) interrupt 0
{
}
void ISR_Ep2eflag(void) interrupt 0
{
}
void ISR_Ep4eflag(void) interrupt 0
{
}
void ISR_Ep6eflag(void) interrupt 0
{
}
void ISR_Ep8eflag(void) interrupt 0
{
}
void ISR_Ep2fflag(void) interrupt 0
{
}
void ISR_Ep4fflag(void) interrupt 0
{
}
void ISR_Ep6fflag(void) interrupt 0
{
}
void ISR_Ep8fflag(void) interrupt 0
{
}
void ISR_GpifComplete(void) interrupt 0
{
}
void ISR_GpifWaveform(void) interrupt 0
{
}

