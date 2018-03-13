using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace USB_DAQ
{
    class CommandHeader
    {     
        public const string RazChannelSelectHeader = "A8A0";
        public const string LatchedOrDirectHeader = "ACA0";
        public const string Nor64OrSingleHeader = "ACB0";
        public const string HighGainOrLowGainShaperHeader = "A0C0";
        public const string ShaperEnableHeader = "A0D0";
        public const string PowerPulsiungHeader = "A0E0";
        public const string CTestChannelHeader = "A100";
        public const string ReadRegChannelHeader = "A200";
        public const string PowerPulsingEnableHeader = "A3A0";
        public const string ReadoutChannelHeader = "A4A0";
        public const string InternalRazTimeHeader = "A8B0";
        public const string AsicHeader = "AB00";
        public const string SWHighGainAndLowGainHeader = "B300";
        public const string Dac0Header = "C000";
        public const string Dac1Header = "C400";
        public const string Dac2Header = "C800";
        public const string LoadSlowControlParameter = "D0A2";
        public const int PreAmpPowerPulsingIndex = 0;
        public const int ShaperPowerPulsingIndex = 2;
        public const int WildarPowerPulsingIndex = 4;
        public const int Dac4BitPowerPulsingIndex = 6;
        public const int OtaqPowerPulsingIndex = 8;
        public const int DiscriminatorPowerPulsingIndex = 10;
        public const int VbgPowerPulsingIndex = 12;
        public const int Dac10BitPowerPulsingIndex = 14;
        public const int LvdsPowerPulsingIndex = 16;
    }
}
