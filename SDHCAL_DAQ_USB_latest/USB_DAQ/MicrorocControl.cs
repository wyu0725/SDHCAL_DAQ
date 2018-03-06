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
        private string rx_Command = @"\b[0-9a-fA-F]{4}\b";//match 16 bit Hex
        private string rx_Byte = @"\b[0-9a-fA-F]{2}\b";//match 8 bit Hex
        private string rx_Integer = @"^\d+$";   //匹配非负 整数
        private string rx_Double = @"^-?\d+(\.\d{1,6})?$";//小数可有可无最多6位小数 
        public MicrorocControl( int asicID)
        {
            AsicID = asicID;
        }
        public int AsicID { set; get; }
        private bool CheckHexLegeal(string HexInString)
        {
            Regex rxHex = new Regex(rx_Byte);
            return rxHex.IsMatch(HexInString);
        }
        private bool CheckIntegerLegeal(string IntegerInString)
        {
            Regex rxInt = new Regex(rx_Integer);
            return rxInt.IsMatch(IntegerInString);
        }
        private bool CheckDoubleLegeal(string DoubleInString)
        {
            Regex rxDouble = new Regex(rx_Double);
            return rxDouble.IsMatch(DoubleInString);
        }
        public bool Set10BitDac0(string Dac0, MyCyUsb usbInterface)
        {
            if(CheckIntegerLegeal(Dac0))
            {
                
                int Dac0Value = Int32.Parse(Dac0) + ;
            }
            else
            {
                return false;
            }
        }
    }
}
