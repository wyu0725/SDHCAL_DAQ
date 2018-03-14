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
        /// <summary>
        /// Create an instance of CyUSB. Utilize PID and VID to 
        /// distinguish different cy devices
        /// </summary>
        /// <param name="pid"></param>
        /// <param name="vid"></param>
        public MyCyUsb(int pid, int vid)
        {
            PID = pid;
            VID = vid;
        }
        private int PID { get; set; }
        private int VID { get; set; }
        public USBDeviceList usbDevices = new USBDeviceList(CyConst.DEVICES_CYUSB);
        private CyUSBDevice myDevice;
        private CyBulkEndPoint BulkInEndPt;
        private CyBulkEndPoint BulkOutEndPt;
        /// <summary>
        /// Initial device when new usb device is attached or detached
        /// </summary>
        /// <returns>True for attached & false for detached</returns>
        public bool InitialDevice()
        {
            myDevice = usbDevices[VID, PID] as CyUSBDevice;
            if(myDevice != null)
            {
                BulkInEndPt = myDevice.EndPointOf(0x86) as CyBulkEndPoint;
                BulkInEndPt.XferSize = BulkInEndPt.MaxPktSize * 8;
                BulkInEndPt.TimeOut = 10;
                BulkOutEndPt = myDevice.EndPointOf(0x02) as CyBulkEndPoint;
                return true;
            }
            else
            {
                BulkInEndPt = null;
                BulkOutEndPt = null;
                return false;
            }            
        }
        public byte[] ConstCommandByteArray(params byte[] paramList)
        {
            byte[] buffer = new byte[paramList.Length];
            Array.Copy(paramList, buffer, paramList.Length);
            byte temp;
            for (int i = 0; i < buffer.Length; i += 2)
            {
                temp = buffer[i];
                buffer[i] = buffer[i + 1];
                buffer[i + 1] = temp;
            }
            return buffer;
        }
        public byte[] ConstCommandByteArray(int Command)
        {
            byte[] buffer = new byte[2];
            buffer[0] = (byte)Command;
            buffer[1] = (byte)(Command >> 8);
            return buffer;
        }
        public bool CommandSend(byte[] OutData, int xferLen)
        {
            bool bResult = false;
            if (BulkInEndPt == null)
            {
                bResult = false;
            }
            else
            {
                bResult = BulkOutEndPt.XferData(ref OutData, ref xferLen);
            }
            return bResult;
        }
        public bool CommandSend(byte[] OutData)
        {
            return CommandSend(OutData, OutData.Length);
        }
        public bool DataRecieve(byte[] InData, int xferLen)
        {
            bool bResult = false;
            if(myDevice != null)
            {
                bResult = BulkInEndPt.XferData(ref InData, ref xferLen, true);
            }
            else
            {
                bResult = false;
            }
            return bResult;
        }
    
    }
}
