using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;

namespace USB_DAQ
{
    class MicrorocControl
    {
        private string rx_Command = @"\b[0-9a-fA-F]{4}\b";// Match 16 bit Hex
        private string rx_Byte = @"\b[0-9a-fA-F]{2}\b";// Match 8 bit Hex
        private string rx_Integer = @"^\d+$";   // Match positive integer
        private string rx_Double = @"^-?\d+(\.\d{1,6})?$";// Match double with 6 decimal
        /// <summary>
        /// To determine an ASIC chain, ASIC ID and chip number in a chain is necessary
        /// </summary>
        /// <param name="asicID"></param>
        /// <param name="chipNumberInChain"></param>
        public MicrorocControl( int asicID, int chipNumberInChain)
        {
            _AsicID = asicID;
            _ChipNumberInChain = chipNumberInChain;
        }
        public int AsicID
        {
            get {return _AsicID; }
        }
        public int ChipNumberInChain
        {
            get { return _ChipNumberInChain; }
        }
        private int _AsicID;
        private int _ChipNumberInChain;
        private bool CheckHexLegal(string HexInString)
        {
            Regex rxHex = new Regex(rx_Byte);
            return rxHex.IsMatch(HexInString);
        }
        private bool CheckIntegerLegal(string IntegerInString)
        {
            Regex rxInt = new Regex(rx_Integer);
            return rxInt.IsMatch(IntegerInString);
        }
        private bool CheckDoubleLegal(string DoubleInString)
        {
            Regex rxDouble = new Regex(rx_Double);
            return rxDouble.IsMatch(DoubleInString);
        }
        /// <summary>
        /// Just convert Hex to Int32
        /// </summary>
        /// <param name="Hex"></param>
        /// <returns></returns>
        private static int HexToInt(string Hex)
        {
            return Convert.ToInt32(Hex, 16);
        }
        public bool SetAsicHeader(int AsicHeader, MyCyUsb usbInterface)
        {
            int HeaderValue = HexToInt(CommandHeader.AsicHeader) + AsicHeader;
            byte[] CommandBytes = usbInterface.ConstCommandByteArray(AsicHeader);
            bool bResult = usbInterface.CommandSend(CommandBytes, CommandBytes.Length);
            return bResult;
        }
        public bool Set10BitDac0(string Dac0, MyCyUsb usbInterface)
        {
            if(CheckIntegerLegal(Dac0))
            {

                int Dac0Value = int.Parse(Dac0) + HexToInt(CommandHeader.Dac0Header);
                byte[] CommandBytes = usbInterface.ConstCommandByteArray(Dac0Value);
                bool bResult = usbInterface.CommandSend(CommandBytes, CommandBytes.Length);
                if (bResult)
                {
                    return true;
                }
                else
                {
                    return false;
                }
            }
            else
            {
                return false;
            }
        }
        public bool Set10BitDac1(string Dac1, MyCyUsb usbInterface)
        {
            if (CheckIntegerLegal(Dac1))
            {

                int Dac1Value = int.Parse(Dac1) + HexToInt(CommandHeader.Dac1Header);
                byte[] CommandBytes = usbInterface.ConstCommandByteArray(Dac1Value);
                bool bResult = usbInterface.CommandSend(CommandBytes, CommandBytes.Length);
                if (bResult)
                {
                    return true;
                }
                else
                {
                    return false;
                }
            }
            else
            {
                return false;
            }
        }
        public bool Set10BitDac2(string Dac2, MyCyUsb usbInterface)
        {
            if (CheckIntegerLegal(Dac2))
            {

                int Dac2Value = int.Parse(Dac2) + HexToInt(CommandHeader.Dac2Header);
                byte[] CommandBytes = usbInterface.ConstCommandByteArray(Dac2Value);
                bool bResult = usbInterface.CommandSend(CommandBytes, CommandBytes.Length);
                if (bResult)
                {
                    return true;
                }
                else
                {
                    return false;
                }
            }
            else
            {
                return false;
            }
        }
        /// <summary>
        /// 0 is RAZ internal channel and 1 stands for external RAZ cahnnel
        /// </summary>
        /// <param name="RazChannelSelected"></param>
        /// <param name="usbInterface"></param>
        /// <returns></returns>
        public bool SelectRazChannel(int RazChannelSelected, MyCyUsb usbInterface)
        {
            int RazChannelValue = RazChannelSelected + HexToInt(CommandHeader.RazChannelSelectHeader);
            byte[] CommandBytes = usbInterface.ConstCommandByteArray(RazChannelValue);
            bool bResult = usbInterface.CommandSend(CommandBytes, CommandBytes.Length);
            return bResult;
        }
        public bool SelectReadoutChannel(int ReadoutChannel, MyCyUsb usbInterface)
        {
            int ReadoutChannelValue = ReadoutChannel + HexToInt(CommandHeader.ReadoutChannelHeader);
            byte[] CommandBytes = usbInterface.ConstCommandByteArray(ReadoutChannelValue);
            return usbInterface.CommandSend(CommandBytes);
        }
        public bool SelectCmpOutLatchedOrDirectOut(int LatchedOrDirect, MyCyUsb usbInterface)
        {
            int LatchedOrDirectedValue = HexToInt(CommandHeader.LatchedOrDirectHeader) + LatchedOrDirect;
            byte[] CommandBytes = usbInterface.ConstCommandByteArray(LatchedOrDirectedValue);
            return usbInterface.CommandSend(CommandBytes, CommandBytes.Length);
        }
        public bool SelectTrigOutNor64OrSingle(int Nor64OrSingle, MyCyUsb usbInterface)
        {
            int Nor64OrSingleValue = HexToInt(CommandHeader.Nor64OrSingleHeader) + Nor64OrSingle;
            byte[] CommandBytes = usbInterface.ConstCommandByteArray(Nor64OrSingleValue);
            return usbInterface.CommandSend(CommandBytes, CommandBytes.Length);
        }
        public bool SetPowerPulsing(int PowerPulsing, int PowerPulsingIndex, MyCyUsb usbInterface)
        {
            int PowerPulsingValue = HexToInt(CommandHeader.PowerPulsiungHeader) + PowerPulsingIndex + PowerPulsing;
            byte[] CommandBytes = usbInterface.ConstCommandByteArray(PowerPulsingValue);
            return usbInterface.CommandSend(CommandBytes, CommandBytes.Length);
        }
        public bool SelectHighOrLowGainShaper(int HighGainOrLowGain, MyCyUsb usbInterface)
        {
            int HighGainOrLowGainShaperValue = HighGainOrLowGain + HexToInt(CommandHeader.HighGainOrLowGainShaperHeader);
            byte[] CommandBytes = usbInterface.ConstCommandByteArray(HighGainOrLowGainShaperValue);
            return usbInterface.CommandSend(CommandBytes, CommandBytes.Length);
        }
        public bool SetShaperOutEnable(int ShaperEnable, MyCyUsb usbInterface)
        {
            int ShaperEnableValue = ShaperEnable + HexToInt(CommandHeader.ShaperEnableHeader);
            byte[] CommandBytes = usbInterface.ConstCommandByteArray(ShaperEnableValue);
            return usbInterface.CommandSend(CommandBytes, CommandBytes.Length);
        }
        public bool SetCTestChannel(string CTestChannel, MyCyUsb usbInterface)
        {
            if (CheckIntegerLegal(CTestChannel) && int.Parse(CTestChannel) < 65)
            {
                int CTestChannelValue = int.Parse(CTestChannel) + HexToInt(CommandHeader.CTestChannelHeader);
                byte[] CommandBytes = usbInterface.ConstCommandByteArray(CTestChannelValue);
                return usbInterface.CommandSend(CommandBytes, CommandBytes.Length);
            }
            else
            {
                return false;
            }
        }
        public bool SetSWHighGainAndLowGain(int SWHighGain, int SWLowGain, MyCyUsb usbInterface)
        {
            int SWValue = SWHighGain * 16 + SWLowGain + HexToInt(CommandHeader.SWHighGainAndLowGainHeader);
            byte[] CommandBytes = usbInterface.ConstCommandByteArray(SWValue);
            return usbInterface.CommandSend(CommandBytes, CommandBytes.Length);
        }
        public bool SelectInternalRazTime(int InternalRazTime, MyCyUsb usbInterface)
        {
            int InternalRazTimeValue = InternalRazTime + HexToInt(CommandHeader.InternalRazTimeHeader);
            byte[] CommandBytes = usbInterface.ConstCommandByteArray(InternalRazTimeValue);
            return usbInterface.CommandSend(CommandBytes);
        }
        public bool LoadSlowControlParameter(MyCyUsb usbInterface)
        {
            byte[] CommandBytes = usbInterface.ConstCommandByteArray(HexToInt(CommandHeader.LoadSlowControlParameter));
            return usbInterface.CommandSend(CommandBytes);
        }
        public bool SetReadRegChannel(string ReadRegChannel, MyCyUsb usbInterface)
        {
            if (CheckIntegerLegal(ReadRegChannel) && int.Parse(ReadRegChannel) < 65)
            {
                int ReadRegChannelValue = int.Parse(ReadRegChannel) + HexToInt(CommandHeader.ReadRegChannelHeader);
                byte[] CommandBytes = usbInterface.ConstCommandByteArray(ReadRegChannelValue);
                return usbInterface.CommandSend(CommandBytes);
            }
            else
            {
                return false;
            }
        }
        public bool PowerPulsingCheck(bool Enable, MyCyUsb usbInterface)
        {
            int PowerPulsingCheckValue = HexToInt(CommandHeader.PowerPulsingEnableHeader) + Convert.ToInt16(Enable);
            byte[] CommandBytes = usbInterface.ConstCommandByteArray(PowerPulsingCheckValue);
            return usbInterface.CommandSend(CommandBytes);
        }
    }
}
