using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Text.RegularExpressions;

namespace USB_DAQ
{
    class CheckStringLegal
    {
        private const string rx_Hex = @"\b[0-9a-fA-F]{1,8}\b";// Match 8 bytes Hex
        private const string rx_Byte = @"\b[0-9a-fA-F]{2}\b";// Match 8 bit Hex
        private const string rx_Integer = @"^\d+$";   // Match positive integer
        private const string rx_Double = @"^-?\d+(\.\d+)?$";// Match double
        public static bool CheckHexLegal(string HexInString)
        {
            Regex rxHex = new Regex(rx_Hex);
            return rxHex.IsMatch(HexInString);
        }
        public static bool Check8BitHexLegal(string Hex8Bits)
        {
            Regex rxHex = new Regex(rx_Byte);
            return rxHex.IsMatch(Hex8Bits);
        }
        public static bool CheckIntegerLegal(string IntegerInString)
        {
            Regex rxInt = new Regex(rx_Integer);
            return rxInt.IsMatch(IntegerInString);
        }
        public static bool CheckDoubleLegal(string DoubleInString)
        {
            Regex rxDouble = new Regex(rx_Double);
            return rxDouble.IsMatch(DoubleInString);
        }
    }
}
