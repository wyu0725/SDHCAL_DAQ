using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using CyUSB;

namespace USB_DAQ
{
    class MyCyUsb
    {
        public MyCyUsb(int pid, int vid)
        {
            PID = pid;
            VID = vid;
        }
        private int PID { get; set; }
        private int VID { get; set; }
        private USBDeviceList usbDevices = new USBDeviceList(CyConst.DEVICES_CYUSB);
        private CyUSBDevice myDevice;
        private CyBulkEndPoint BulkInEndPt;
        private CyBulkEndPoint BulkOutEndPt;
        public bool InitialDevice()
        {
            myDevice = usbDevices[VID, PID] as CyUSBDevice;
            if(myDevice == )
        }

        
        
    }
}
