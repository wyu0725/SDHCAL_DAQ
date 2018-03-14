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
        private string rx_Hex = @"\b[0-9a-fA-F]{1,8}\b";// Match 8 bytes Hex
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
        public bool CheckHexLegal(string HexInString)
        {
            Regex rxHex = new Regex(rx_Hex);
            return rxHex.IsMatch(HexInString);
        }
        public bool Check8BitHexLegal(string Hex8Bits)
        {
            Regex rxHex = new Regex(rx_Byte);
            return rxHex.IsMatch(Hex8Bits);
        }
        public bool CheckIntegerLegal(string IntegerInString)
        {
            Regex rxInt = new Regex(rx_Integer);
            return rxInt.IsMatch(IntegerInString);
        }
        public bool CheckDoubleLegal(string DoubleInString)
        {
            Regex rxDouble = new Regex(rx_Double);
            return rxDouble.IsMatch(DoubleInString);
        }
        /// <summary>
        /// Just convert Hex(in string format) to Int32
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
        public bool SetAsicNumber(int AsicNumber, MyCyUsb usbInterface)
        {
            int AsicNumberValue = HexToInt(CommandHeader.AsicNumberHeader) + AsicNumber;
            return usbInterface.CommandSend(usbInterface.ConstCommandByteArray(AsicNumberValue));
        }
        /// <summary>
        /// The lowest threshold of Microroc
        /// </summary>
        /// <param name="Dac0"> In decimal</param>
        /// <param name="usbInterface"></param>
        /// <param name="IllegalInput">True indicate the DAC0 is not correct</param>
        /// <returns>True stands for command issued correctly</returns>
        public bool Set10BitDac0(string Dac0, MyCyUsb usbInterface, out bool IllegalInput)
        {
            if(CheckIntegerLegal(Dac0))
            {

                int Dac0Value = int.Parse(Dac0) + HexToInt(CommandHeader.Dac0Header);
                byte[] CommandBytes = usbInterface.ConstCommandByteArray(Dac0Value);
                bool bResult = usbInterface.CommandSend(CommandBytes, CommandBytes.Length);
                if (bResult)
                {
                    IllegalInput = false;
                    return true;
                }
                else
                {
                    IllegalInput = false;
                    return false;
                }
            }
            else
            {
                IllegalInput = true;
                return false;
            }
        }
        public bool Set10BitDac1(string Dac1, MyCyUsb usbInterface, out bool IllegalInput)
        {
            if (CheckIntegerLegal(Dac1))
            {
                IllegalInput = false;
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
                IllegalInput = true;
                return false;
            }
        }
        public bool Set10BitDac2(string Dac2, MyCyUsb usbInterface, out bool IllegalInput)
        {
            if (CheckIntegerLegal(Dac2))
            {
                IllegalInput = false;
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
                IllegalInput = true;
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
        public bool SetCTestChannel(string CTestChannel, MyCyUsb usbInterface, out bool IllegalInput)
        {
            if (CheckIntegerLegal(CTestChannel) && int.Parse(CTestChannel) < 65)
            {
                IllegalInput = false;
                int CTestChannelValue = int.Parse(CTestChannel) + HexToInt(CommandHeader.CTestChannelHeader);
                byte[] CommandBytes = usbInterface.ConstCommandByteArray(CTestChannelValue);
                return usbInterface.CommandSend(CommandBytes, CommandBytes.Length);
            }
            else
            {
                IllegalInput = true;
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
        public bool SetReadRegChannel(string ReadRegChannel, MyCyUsb usbInterface, out bool IllegalInput)
        {
            if (CheckIntegerLegal(ReadRegChannel) && int.Parse(ReadRegChannel) < 65)
            {
                IllegalInput = false;
                int ReadRegChannelValue = int.Parse(ReadRegChannel) + HexToInt(CommandHeader.ReadRegChannelHeader);
                byte[] CommandBytes = usbInterface.ConstCommandByteArray(ReadRegChannelValue);
                return usbInterface.CommandSend(CommandBytes);
            }
            else
            {
                IllegalInput = true;
                return false;
            }
        }
        public bool PowerPulsingCheck(bool Enable, MyCyUsb usbInterface)
        {
            int PowerPulsingCheckValue = HexToInt(CommandHeader.PowerPulsingEnableHeader) + Convert.ToInt16(Enable);
            byte[] CommandBytes = usbInterface.ConstCommandByteArray(PowerPulsingCheckValue);
            return usbInterface.CommandSend(CommandBytes);
        }
        public bool ResetCounterB(MyCyUsb usbInterface)
        {
            int ResetCounterBValue = HexToInt(CommandHeader.ResetCounterBCommand);
            return usbInterface.CommandSend(usbInterface.ConstCommandByteArray(ResetCounterBValue));
        }
        public bool EnableExternalTrigger(bool Enable, MyCyUsb usbInterface)
        {
            int EnableExternalTriggerValue = Convert.ToInt16(Enable) + HexToInt(CommandHeader.EnableExternalTriggerHeader);
            return usbInterface.CommandSend(usbInterface.ConstCommandByteArray(EnableExternalTriggerValue));
        }
        public bool SetExternalRazWidth(int Width, MyCyUsb usbInterface)
        {
            int ExternalRazWidthValue = Width + HexToInt(CommandHeader.ExternalRazWidthHeader);
            return usbInterface.CommandSend(usbInterface.ConstCommandByteArray(ExternalRazWidthValue));
        }
        /// <summary>
        /// This command set delay time of the hold singal after trigger is enable. 
        /// </summary>
        /// <param name="HoldDelayTime">Max 800</param>
        /// <param name="usbInterface"></param>
        /// <returns></returns>
        public bool SetHoldDelayTime(string HoldDelayTime, MyCyUsb usbInterface, out bool IllegalInput)
        {
            if(CheckIntegerLegal(HoldDelayTime) && int.Parse(HoldDelayTime) < 800)
            {
                IllegalInput = false;
                int DelayTime = (int)(int.Parse(HoldDelayTime) / 6.25);
                int DelayTime1 = (byte)(DelayTime & 15) + HexToInt(CommandHeader.HoldHeader);//15 = 0xF
                int DelayTime2 = (byte)(((DelayTime >> 4) & 15) | 16) + HexToInt(CommandHeader.HoldHeader);//16 = 0x10
                bool bResult = usbInterface.CommandSend(usbInterface.ConstCommandByteArray(DelayTime1));
                if(!bResult)
                {
                    return false;
                }
                else
                {
                    return usbInterface.CommandSend(usbInterface.ConstCommandByteArray(DelayTime2));
                }
            }
            else
            {
                IllegalInput = true;
                return false;
            }
        }
        public bool SetTrigCoincidence(int TrigMode, MyCyUsb usbInterface)
        {
            int TrigCoincidenceValue = TrigMode + HexToInt(CommandHeader.TrigCoincidenceHeader);
            return usbInterface.CommandSend(usbInterface.ConstCommandByteArray(TrigCoincidenceValue));
        }
        /// <summary>
        /// 4Y:HoldTime[3:0]
        /// 5Y:HoldTime[7:4]
        /// 6Y:HoldTime[11:8]
        /// 7Y:HoldTime[15:12]
        /// </summary>
        /// <param name="HoldTime">Max:10000</param>
        /// <param name="usbInterface"></param>
        /// <returns></returns>
        public bool SetHoldTime(string HoldTime, MyCyUsb usbInterface, out bool IllegalInput)
        {
            if (CheckIntegerLegal(HoldTime) && int.Parse(HoldTime) < 10000)
            {
                IllegalInput = false;
                int HoldTimeValue = int.Parse(HoldTime) / 25;
                int HoldTime1 = (HoldTimeValue & 15) + 64 + HexToInt(CommandHeader.HoldHeader);//0x40
                int HoldTime2 = ((HoldTimeValue >> 4) & 15) + 80 + HexToInt(CommandHeader.HoldHeader);//0x50
                int HoldTime3 = ((HoldTimeValue >> 8) & 15) + 96 + HexToInt(CommandHeader.HoldHeader);//0x60
                int HoldTime4 = ((HoldTimeValue >> 12) & 15) + 112 + HexToInt(CommandHeader.HoldHeader);//0x70
                bool bResult = usbInterface.CommandSend(usbInterface.ConstCommandByteArray(HoldTime1));
                if(!bResult)
                {
                    return false;
                }
                bResult = usbInterface.CommandSend(usbInterface.ConstCommandByteArray(HoldTime2));
                if(!bResult)
                {
                    return false;
                }
                bResult = usbInterface.CommandSend(usbInterface.ConstCommandByteArray(HoldTime3));
                if(!bResult)
                {
                    return false;
                }
                return usbInterface.CommandSend(usbInterface.ConstCommandByteArray(HoldTime4));
            }
            else
            {
                IllegalInput = true;
                return false;
            }
        }
        public bool EnableHold(bool Enable, MyCyUsb usbInterface)
        {
            int HoldEnableValue = Convert.ToInt16(Enable) + HexToInt(CommandHeader.HoldEnableHeader);
            return usbInterface.CommandSend(usbInterface.ConstCommandByteArray(HoldEnableValue));
        }
        /// <summary>
        /// B2YY, B1XX YYXX is the acquisition time
        /// </summary>
        /// <param name="AcqTime"></param>
        /// <param name="usbInterface"></param>
        /// <returns></returns>
        public bool SetAcquisitionTime(string AcqTime, MyCyUsb usbInterface, out bool IllegalInput)
        {
            if(CheckIntegerLegal(AcqTime))
            {
                IllegalInput = false;
                int AcquisitionTime = int.Parse(AcqTime) / 25;
                int AcquisitionTime1 = (byte)AcquisitionTime + HexToInt(CommandHeader.AcquisitionTimeHeader_LowBits);
                int AcquisitionTime2 = (byte)(AcquisitionTime >> 8) + HexToInt(CommandHeader.AcquisitionTimeHeader_HighBits);
                if(!usbInterface.CommandSend(usbInterface.ConstCommandByteArray(AcquisitionTime1)))
                {
                    return false;
                }
                return usbInterface.CommandSend(usbInterface.ConstCommandByteArray(AcquisitionTime2));
            }
            else
            {
                IllegalInput = true;
                return false;
            }
        }
        public bool SelectHoldOutput(int AsicNumber, MyCyUsb usbInterface)
        {
            int HoldOutputValue = AsicNumber + HexToInt(CommandHeader.HoldOutputHeader);
            return usbInterface.CommandSend(usbInterface.ConstCommandByteArray(HoldOutputValue));
        }
        public bool SetExternalRazDelayTime(string ExternalRazDelayTime, MyCyUsb usbInterface, out bool IllegalInput)
        {
            if(CheckIntegerLegal(ExternalRazDelayTime) && int.Parse(ExternalRazDelayTime) < 400)
            {
                IllegalInput = false;
                int ExternalRazDelayValue = int.Parse(ExternalRazDelayTime) / 25 + HexToInt(CommandHeader.ExternalRazDelayTimeHeader);
                return usbInterface.CommandSend(usbInterface.ConstCommandByteArray(ExternalRazDelayValue));
            }
            else
            {
                IllegalInput = true;
                return false;
            }
        }
        public bool SelectTrigOrCounterMode(int TrigOrCounter, MyCyUsb usbInterface)
        {
            int TrigOrCounterValue = TrigOrCounter + HexToInt(CommandHeader.TrigOrCounterModeHeader);
            return usbInterface.CommandSend(usbInterface.ConstCommandByteArray(TrigOrCounterValue));
        }
        public bool SetEndHoldTime(string EndHoldTime, MyCyUsb usbInterface,out bool IllegalInput)
        {
            if(CheckIntegerLegal(EndHoldTime) && int.Parse(EndHoldTime) < 65536)
            {
                IllegalInput = false;
                int EndHoldTimeValue = int.Parse(EndHoldTime) / 25;
                int EndHoldTime1 = (EndHoldTimeValue & 15) + HexToInt(CommandHeader.EndHoldTimeHeader1);//0x40
                int EndHoldTime2 = ((EndHoldTimeValue >> 4) & 15) + HexToInt(CommandHeader.EndHoldTimeHeader2);//0x50
                int EndHoldTime3 = ((EndHoldTimeValue >> 8) & 15) + HexToInt(CommandHeader.EndHoldTimeHeader3);//0x60
                int EndHoldTime4 = ((EndHoldTimeValue >> 12) & 15) + HexToInt(CommandHeader.EndHoldTimeHeader4);//0x70
                bool bResult = usbInterface.CommandSend(usbInterface.ConstCommandByteArray(EndHoldTime1));
                if(!bResult)
                {
                    return false;
                }
                bResult = usbInterface.CommandSend(usbInterface.ConstCommandByteArray(EndHoldTime2));
                if(!bResult)
                {
                    return false;
                }
                bResult = usbInterface.CommandSend(usbInterface.ConstCommandByteArray(EndHoldTime3));
                if(!bResult)
                {
                    return false;
                }
                return usbInterface.CommandSend(usbInterface.ConstCommandByteArray(EndHoldTime4));
            }
            else
            {
                IllegalInput = true;
                return false;
            }
        }
        public bool ClearUsbFifo(MyCyUsb usbInterface)
        {
            int ClearUsbFifoValue = HexToInt(CommandHeader.ClearUsbFifoCommand);
            bool bResult =  usbInterface.CommandSend(usbInterface.ConstCommandByteArray(ClearUsbFifoValue));
            if(bResult)
            {
                byte[] ClearBytes = new byte[2048];
                bResult = usbInterface.DataRecieve(ClearBytes, ClearBytes.Length);
                return bResult;
            }
            else
            {
                return false;
            }
        }
        public bool ResetMicroroc(MyCyUsb usbInterface)
        {
            int ResetMicrorocValue = HexToInt(CommandHeader.ResetMicrorocCommand);
            return usbInterface.CommandSend(usbInterface.ConstCommandByteArray(ResetMicrorocValue));
        }
        public bool StartAcquisition(MyCyUsb usbInterface)
        {
            int StartAcquisitionValue = HexToInt(CommandHeader.StartAcquisitionCommand);
            return usbInterface.CommandSend(usbInterface.ConstCommandByteArray(StartAcquisitionValue));
        }
        public bool StopAcquisition(MyCyUsb usbInterface)
        {
            int StopAcquisitionValue = HexToInt(CommandHeader.StopAcquisitionCommand);
            return usbInterface.CommandSend(usbInterface.ConstCommandByteArray(StopAcquisitionValue));
        }
        public bool LightLed(string Led, MyCyUsb usbInterface, out bool IllegalInput)
        {
            if (CheckHexLegal(Led) && HexToInt(Led) < 16)
            {
                IllegalInput = false;
                int LedValue = HexToInt(CommandHeader.LedHeader) + HexToInt(Led);
                return usbInterface.CommandSend(usbInterface.ConstCommandByteArray(LedValue));
            }
            else
            {
                IllegalInput = true;
                return false;
            }
        }
        /// <summary>
        /// Control the 'select' pin, false for SC and true for ReadReg
        /// </summary>
        /// <param name="SCOrReadReg">True for ReadReg and false for SC</param>
        /// <param name="usbInterface"></param>
        /// <returns></returns>
        public bool SelectSlowControlOrReadRegister(bool ReadRegOrSC, MyCyUsb usbInterface)
        {
            int ReadRegOrSCValue = HexToInt(CommandHeader.SlowControlOrReadRegisterHeader) + Convert.ToInt16(ReadRegOrSC);
            return usbInterface.CommandSend(usbInterface.ConstCommandByteArray(ReadRegOrSCValue));
        }
    }
}
