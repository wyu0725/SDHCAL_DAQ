using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace USB_DAQ
{
    class StateIndicator
    {
        public static bool AcqStart = false;
        public static bool ExternalTriggerEnabled = false;
        public static bool SlowAcqStart = false;
        public static bool AdcStart = false;

        public static int SlowAcqDataNumber = 100;
        public static int SlowDataRatePackageNumber;

        public static bool FileSaved = false;

        public enum SCurveMode
        {
            Trig,
            Count
        }
        public static SCurveMode SCurveModeSelect = SCurveMode.Trig;

        public enum DataRateMode
        {
            Slow,
            Fast
        }
        public static DataRateMode DataRateModeSelect = DataRateMode.Slow;

        public enum DaqMode
        {
            AutoDaq,
            SlaveDaq
        }
        public static DaqMode DaqModeSelect = DaqMode.AutoDaq;

        public enum OperationMode
        {
            Acq,
            SCTest,
            SweepAcq,
            ADC,
            Efficiency,
            MicrorocCarier
        }
        public static OperationMode OperationModeSelect = OperationMode.Acq;

        public enum ChannelMode
        {
            SingleChannel = 0,
            AllChannel = 1
        }
        public static ChannelMode ChannelModeSelect = ChannelMode.SingleChannel;

        public enum NewDifParameterLoad
        {
            SlowControl = 0,
            ReadScope = 1
        }
        public static NewDifParameterLoad NewDifSlowControlOrReadScope = NewDifParameterLoad.SlowControl;
    }
}
