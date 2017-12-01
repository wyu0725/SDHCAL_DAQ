using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace USB_DAQ
{
    class MicrorocParameter
    {
        public static void SetDacCode(int Dac0,int Dac1,int Dac2)
        {
            int Dac0Value = Dac0 + 49152; //0xC000
            int Dac1Value = Dac1 + 50176; //0xC400
            int Dac2Value = Dac2 + 51200; //0xC800
            byte[] CommandBytes = new byte[2];
            //CommandBytes =
        }
    }
}
