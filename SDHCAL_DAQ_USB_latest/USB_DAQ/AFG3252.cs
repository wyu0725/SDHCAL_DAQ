using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using NationalInstruments.VisaNS;

namespace USB_DAQ
{
    class AFG3252
    {
        public AFG3252(string ResourceName)
        {
            AfgDescr = ResourceName;
        }
        private string AfgDescr { get; set; }
        // Shape Const
        public const string ShapeSinusoid = "SINusoid";
        public const string ShapeSQUare = "SQUare";
        public const string ShapeRamp = "RAMP";
        public const string ShapePulse = "PULSe";
        // Voltage Unit Const
        public const string VoltageUnitMV = "mV";
        public const string VoltageUnitV = "V";
        public const string VoltageUnitVpp = "VPP";
        public const string VoltageUnitVrms = "VRMS";
        // Frequency Unit Const
        public const string FrequencyUnitHz = "Hz";
        public const string FrequencyUnitKHz = "kHz";
        public const string FrequencyUnitMHz = "MHz";
        // Pulse Const
        public const string TimeUnitNs = "ns";
        public const string TimeUnitUs = "us";
        public const string TimeUnitMs = "ms";
        public const string TimeUnitS = "s";
        public MessageBasedSession session;
        // Find the AFG3252 device
        public bool Initial()
        {
            try
            {
                var rsrc = ResourceManager.GetLocalManager().FindResources(AfgDescr);
                if (rsrc != null)
                {
                    session = (MessageBasedSession)ResourceManager.GetLocalManager().Open(rsrc[0]);
                }

            }
            catch (InvalidCastException)
            {
                MessageBox.Show("Resource selected must be a message-based session");
            }
            catch (Exception exp)
            {
                //MessageBox.Show(exp.Message);
            }

            return (session != null);
        }

        public void Close()
        {
            if(session != null)
            {
                session.Dispose();
            }            
        }

        /*public bool isConnected()
        {
            return (session != null);
        }*/
        #region Function Shape
        public bool FunctionShapeSet(int Channel, string FunctionShape)
        {
            string FunctionCmd;
            FunctionCmd = string.Format("SOURce{0}:FUNCtion:SHAPe {1}", Channel, FunctionShape);
            return Write(FunctionCmd);
        }
        #endregion
        #region Output status
        public bool OpenOutput()
        {
            return Write("OUTPut1:STATe ON") && Write("OUTPut2:STATe ON");
        }
        public bool OpenOutput(int Channel)
        {
            string OutputCommand;
            OutputCommand = string.Format("OUTPut{0}:STATe ON", Channel);
            return Write(OutputCommand);
        }

        public bool CloseOutput()
        {
            return Write("OUTPut1:STATe OFF") && Write("OUTPut2:STATe OFF");
        }
        public bool CloseOutput(int Channel)
        {
            string OutputCommand;
            OutputCommand = string.Format("OUTPut{0}:STATe OFF", Channel);
            return Write(OutputCommand);
        }
        #endregion
        #region Set Voltage
        public bool SetVoltageHigh(int Channel, double Voltage, string Unit)
        {
            string VoltageCommand;
            VoltageCommand = string.Format("SOURce{0}:VOLTage:LEVel:IMMediate:HIGH {1}{2}", Channel, Voltage, Unit);
            return Write(VoltageCommand);
        }
        public bool SetVoltageLow(int Channel, double Voltage, string Unit)
        {
            string VoltageCommand;
            VoltageCommand = string.Format("SOURce{0}:VOLTage:LEVel:IMMediate:LOW {1}{2}", Channel, Voltage, Unit);
            return Write(VoltageCommand);
        }
        public bool SetVoltageOffset(int Channel, double Voltage, string Unit)
        {
            string VoltageCommand;
            VoltageCommand = string.Format("SOURce{0}:VOLTage:LEVel:IMMediate:OFFSet {1}{2}", Channel, Voltage, Unit);
            return Write(VoltageCommand);
        }
        public bool SetVoltageUnit(int Channel, string Unit)
        {
            string VoltageCommand;
            VoltageCommand = string.Format("SOURce{0}:VOLTage:UNIT {1}", Channel, Unit);
            return Write(VoltageCommand);
        }
        public bool SetVoltageAmplitude(int Channel, double Voltage, string Unit, string UnitMode)
        {
            if (SetVoltageUnit(Channel, UnitMode))
            {
                string VoltageCommand;
                VoltageCommand = string.Format("SOURce{0}:VOLTage:LEVel:IMMediate:AMPL {1}{2}", Channel, Voltage, Unit);
                return Write(VoltageCommand);
            }
            else
            {
                return false;
            }            
        }
        #endregion
        #region Set Time
        public bool SetFrequencyFixed(int Channel, double Frequency, string Unit)
        {
            string FrequencyCommand;
            FrequencyCommand = string.Format("SOURce{0}:FREQuency:FIXed {1}{2}", Channel, Frequency, Unit);
            return Write(FrequencyCommand);
        }
        public bool SetFrequencyCopy(int Channel, string Status)
        {
            string FrequencyCommand;
            FrequencyCommand = string.Format("SOURce{1}:FREQuency:CONCurrent:STATe {2}", Channel, Status);
            return Write(FrequencyCommand);
        }
        #endregion
        #region Pulse parameter
        public bool SetPulseDutyCycle(int Channel, double DutyCycle)
        {
            if(FunctionShapeSet(Channel,ShapePulse))
            {
                string PulseCommand;
                PulseCommand = string.Format("SOURce{0}:PULSe:DCYCle {1}", Channel, DutyCycle);
                return Write(PulseCommand);
            }
            else
            {
                return false;
            }            
        }
        public bool SetPulseDelay(int Channel, double Delay, string Unit)
        {
            if (FunctionShapeSet(Channel, ShapePulse))
            {
                string PulseCommand;
                PulseCommand = string.Format("SOURce{0}:PULSe:DELay {1}{2}", Channel, Delay, Unit);
                return Write(PulseCommand);
            }
            else
            {
                return false;
            }
        }
        public bool SetPulsePeriod(int Channel, double Period, string Unit)
        {
            string PulseCommand;
            PulseCommand = string.Format("SOURce{0}:PULSe:PERiod {1}{2}", Channel, Period, Unit);
            return Write(PulseCommand);
        }
        public bool SetPulseLeading(int Channel, double Leading, string Unit)
        {
            string PulseCommand;
            PulseCommand = string.Format("SOURce{0}:PULSe:TRAMsition:LEADing {1}{2}", Channel, Leading, Unit);
            return Write(PulseCommand);
        }
        public bool SetPulseTrailing(int Channel, double Trailing, string Unit)
        {
            string PulseCommand;
            PulseCommand = string.Format("SOURce{0}:PULSe:TRAMsition:TRAiling {1}{2}", Channel, Trailing, Unit);
            return Write(PulseCommand);
        }
        #endregion


        /*public void DelaySet(int channel, int value)
        {
            string DelayCmd;
            try
            {
                DelayCmd = string.Format("SOURce{0}:BURSt:TDELay {1}ns", channel, value);
                session.Write(DelayCmd);
            }
            catch (Exception exp)
            {
                MessageBox.Show(exp.Message);
            }
        }*/

        // core operation
        public bool Write(string cmd)
        {
            try
            {
                session.Write(cmd);
                return true;
            }
            catch (InvalidOperationException)
            {
                MessageBox.Show("Operation parameter is incorrect", "AFG3252 Error", MessageBoxButton.OK, MessageBoxImage.Error);
                return false;
            }
            catch (EntryPointNotFoundException)
            {
                MessageBox.Show("Operation not found", "AFG3252 Error", MessageBoxButton.OK, MessageBoxImage.Error);
                return false;
            }
            catch (DllNotFoundException)
            {
                MessageBox.Show("NI-VISA driver not found", "AFG3252 Error", MessageBoxButton.OK, MessageBoxImage.Error);
                return false;
            }
            catch (VisaException)
            {
                MessageBox.Show("NI VISA Error","AFG3252 Error",MessageBoxButton.OK,MessageBoxImage.Error);
                return false;
            }
            catch(Exception exp)
            {
                MessageBox.Show(exp.Message);
                return false;
            }
            
            
            
            /*catch(ObjectDisposedException)
            {
                MessageBox.Show("The AFG3252 is removed", "AFG3252 Error", MessageBoxButton.OK, MessageBoxImage.Error);
                return false;
            }*/            
        }
    }
}
