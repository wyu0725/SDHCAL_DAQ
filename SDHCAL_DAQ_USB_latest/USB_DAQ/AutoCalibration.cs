using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace USB_DAQ
{
    class AutoCalibration
    {
        private struct LinearParameter
        {
            public double Slop;
            public double Intercept;
            public LinearParameter(double slop, double intercept)
            {
                Slop = slop;
                Intercept = intercept;
            }
        }
        
        public static bool SetTestFrequency(AFG3252 afgInterface, out string txtReport)
        {
            #region Set Channel1 Frequency
            bool bResult = afgInterface.SetFrequencyFixed(1, 100, AFG3252.FrequencyUnitKHz);
            if (bResult)
            {
                txtReport = "Set AFG3252 Channel1: 100kHz\n";
            }
            else
            {
                txtReport = null;
                return false;
            }
            #endregion
            #region Set Channel2 Frequrency
            bResult = afgInterface.SetFrequencyFixed(2, 100, AFG3252.FrequencyUnitKHz);
            if (bResult)
            {
                txtReport += "Set AFG3252 Channel2: 100kHz\n";
            }
            else
            {
                txtReport = null;
                return false;
            }
            #endregion
            #region Set frequency equal
            bResult = afgInterface.SetFrequencyCopy(1, "ON");
            if (bResult)
            {
                txtReport += "Set AFG3252 Frequency Channel1 = Channel\n";
                return true;
            }
            else
            {
                txtReport = null;
                return false;
            }
            #endregion
        }
        public static bool SetTestShape(AFG3252 afgInterface, out string txtReport)
        {
            bool bResult = afgInterface.FunctionShapeSet(1, AFG3252.ShapePulse);
            if(!bResult)
            {
                txtReport = null;
                return false;
            }
            bResult = afgInterface.FunctionShapeSet(1, AFG3252.ShapePulse);
            if(!bResult)
            {
                txtReport = null;
                return false;
            }
            bResult = afgInterface.SetPulseLeading(1, 6.25, "us");
            if(!bResult)
            {
                txtReport = null;
                return false;
            }
            bResult = afgInterface.SetPulseDelay(2, 8.90625, "us");
            if(!bResult)
            {
                txtReport = null;
                return false;
            }
            txtReport = "Set test pulse function successfully\n";
            return true;
        }
        public static bool SetChannel2Voltage(AFG3252 afgInterface, out string txtReport)
        {
            bool bResult;
            bResult = afgInterface.SetVoltageHigh(2, 3.3, AFG3252.VoltageUnitV);
            if(!bResult)
            {
                txtReport = null;
                return false;
            }
            bResult = afgInterface.SetVoltageLow(2, 0, AFG3252.VoltageUnitV);
            if(!bResult)
            {
                txtReport = null;
                return false;
            }
            txtReport = "Set Channel2 LVCMOS\n";
            return true;
        }
        public static bool SetChannel1Voltage(double Voltage, AFG3252 afgInterface)
        {
            bool bResult = afgInterface.SetVoltageHigh(1, Voltage, AFG3252.VoltageUnitMV);
            if(bResult)
            {
                return true;
            }
            else
            {
                return false;
            }
        }
        /// <summary>
        /// sw: ASIC paremeter, DacMode: true-2.43mV/Dac false-1.37mV/Dac, HighFainOeLowGain: true-High false-Low
        /// </summary>
        /// <param name="InitialCharge"></param>
        /// <param name="FinalCharge"></param>
        /// <param name="ChargeStep"></param>
        /// <param name="sw"></param>
        /// <param name="DacMode"></param>
        /// <param name="HighGainOrLowGain"></param>
        /// <returns></returns>
        public static int CalculateCentralDac(int Charge, int sw, bool DacMode, bool HighGainOrLowGain)
        {
            LinearParameter[] HighGain = { new LinearParameter(7.65, 0), new LinearParameter(9.60, 0), new LinearParameter(10.23, 0), new LinearParameter(10.52, 0) };
            LinearParameter[] LowGain = { new LinearParameter(1.23, 0), new LinearParameter(2.10, 0), new LinearParameter(2.27, 0), new LinearParameter(2.34, 0) };
            LinearParameter DacHigh = new LinearParameter(2.16, 0.83);
            LinearParameter DacLow = new LinearParameter(1.41, 0.93);
            double ShaperSloe = HighGainOrLowGain ? HighGain[sw].Slop : LowGain[sw].Slop;
            double ShaperIntercept = HighGainOrLowGain ? HighGain[sw].Intercept : LowGain[sw].Intercept;
            double DacSlop = DacMode ? DacHigh.Slop : DacLow.Slop;
            double DacIntercept = DacMode ? DacHigh.Intercept : DacLow.Intercept;
            return (int)((ShaperSloe * Charge + ShaperIntercept - DacIntercept) / DacSlop);
            
        }
    }
}
