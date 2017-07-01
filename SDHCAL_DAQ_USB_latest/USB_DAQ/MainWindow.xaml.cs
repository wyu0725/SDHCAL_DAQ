using System;
using System.Text;
using System.Windows;
using System.Windows.Media;
using System.Linq;
using System.Windows.Controls;
using System.Text.RegularExpressions;//new add
using System.Threading;//new add20150809
using System.Windows.Threading;//new add 20150818
using System.Threading.Tasks;
using System.IO;//new add 20150810
using Microsoft.Win32;//new add for SaveFileDialog
using CyUSB;//new add
using Microsoft.Research.DynamicDataDisplay;//new add 20151023
using Microsoft.Research.DynamicDataDisplay.DataSources;//new add 20151023
using Microsoft.Research.DynamicDataDisplay.PointMarkers;//new add 20151024
using System.IO.Ports;
//using System.Collections.ObjectModel;//new add 20150823
//using Target7_NEWDAQ.DataModel;      //new add 20150823
namespace USB_DAQ
{
    /// <summary>
    /// MainWindow.xaml 的交互逻辑
    /// </summary>
    public partial class MainWindow : Window
    {
        private USBDeviceList usbDevices;
        private CyUSBDevice myDevice;
        private CyBulkEndPoint BulkInEndPt;
        private CyBulkEndPoint BulkOutEndPt;
        private const int VID = 0x04B4;
        private const int PID = 0x1004;
        private string rx_Command = @"\b[0-9a-fA-F]{4}\b";//match 16 bit Hex
        private string rx_Byte = @"\b[0-9a-fA-F]{2}\b";//match 8 bit Hex
        private string rx_Integer = @"^\d+$";   //匹配非负 整数
        //private string rx_Float = @"^\d+(\.\d{1,3})?$";//小数可有可无最多3位小数 
        private string filepath = null;//文件路径
        private static bool AcqStart = false; //采集标志
        private static bool Enabled_Ext_Trigger = false;
        //private static bool ScurveStart_En = false;
        // private static bool SPopen = false; //串口是否打开
        // private SerialPort mySerialPort = new SerialPort();//新建串口
        private static int Packetcnt;
        private BinaryWriter bw;
        private Sync_Thread_Buffer threadbuffer = new Sync_Thread_Buffer(16384 * 512);
        //private delegate void DisplayPacketNum(StringBuilder packetnum); //delegate
        private delegate void DisplayPacketNum(string packetnum); //delegate
        //private ObservableDataSource<Point> dataSource1 = new ObservableDataSource<Point>();
        //private ObservableDataSource<Point> dataSource2 = new ObservableDataSource<Point>();
        //private LineGraph Chn1 = new LineGraph();
        //private LineGraph Chn2 = new LineGraph();
        //private DispatcherTimer timer = new DispatcherTimer();
        //private int wave_cnt;
        private CancellationTokenSource data_acq_cts = new CancellationTokenSource();
        private CancellationTokenSource file_write_cts = new CancellationTokenSource();
        //private const int Single_SCurve_Data_Length = 7171 * 2;
        //private const int AllChn_SCurve_Data_Length = 458818 * 2;
        //private const int SCurve_Package_Length = 512;
        //private static int Scurve_Data_Pkg;
        //private static int Scurve_Data_Remain;
        //private NoSortHashtable hasht = new NoSortHashtable(); //排序之后的哈希表     
        //private NoSortHashtable[] CaliHashTable = new NoSortHashtable[4]{new NoSortHashtable(), new NoSortHashtable(), new NoSortHashtable(), new NoSortHashtable() };
        private int SlowACQDataNumber = 100;
        private int SlowDataRatePackageNumber;
        private const int Acq = 0;
        private const int SCTest = 1;
        private const int SweepAcq = 2;
        private const int Adc = 3;
        private int DataAcqMode = Acq;
        private const int AutoDaq = 0;
        private const int SlaveDaq = 1;
        private int DaqMode = AutoDaq;
        private const int Trig = 0;
        private const int Count = 1;
        private int SCurveMode = Trig;
        private const int SingleChannel = 0;
        private const int AllChannel = 1;
        private int ChannelMode = SingleChannel;
        private const int OneDacDataLength = 7*2;//7*16-bits == 14 bytes
        private const int HeaderLength = 1 * 2;//16-bits
        private const int ChannelLength = 1 * 2;//16-bits
        private const int TailLength = 1 * 2;//16-bits
        private static bool IsAdcStart = false;
        private static bool IsSlowAcqStart = false;

        private static bool IsTestStart = false;

        //SC Parameter
        
        
        public MainWindow()
        {
            //txtDAC0_VTH_ASIC[0].Margin = ""

            InitializeComponent();
            //Dynamic list of USB devices bound to CyUSB.sys
            usbDevices = new USBDeviceList(CyConst.DEVICES_CYUSB);
            //Adding event handles for device attachment and device removal
            usbDevices.DeviceAttached += new EventHandler(usbDevices_DeviceAttached);
            usbDevices.DeviceRemoved += new EventHandler(usbDevices_DeviceRemoved);
            RefreshDevice();
            //cbxAverage_Points.SelectedIndex = 0;
            //Initial_SerialPort();
        }
        private void usbDevices_DeviceAttached(object sender, EventArgs e)
        {
            USBEventArgs usbEvent = e as USBEventArgs;
            //StatusLabel.Text = usbEvent.Device.FriendlyName + " connected.";
            RefreshDevice();
        }
        private void usbDevices_DeviceRemoved(object sender, EventArgs e)
        {
            USBEventArgs usbEvent = e as USBEventArgs;
            //StatusLabel.Text = usbEvent.FriendlyName + " removed.";
            RefreshDevice();
        }
        private void RefreshDevice()
        {
            // Get the first device having VendorID == 0x04B4 and ProductID == 0x1004
            myDevice = usbDevices[VID,PID] as CyUSBDevice;
            if (myDevice != null)
            {
                usb_status.Content = "USB device connected";
                usb_status.Foreground = Brushes.Green;
                btnCommandSend.Background = Brushes.ForestGreen;
                btnCommandSend.IsEnabled = true;
                txtCommand.IsEnabled = true;
                //btnConfig.IsEnabled = true;
                btnAcqStart.IsEnabled = true;
                btnAcqStart.Background = Brushes.ForestGreen;
                //Instantiating the endpoints
                BulkOutEndPt = myDevice.EndPointOf(0x02) as CyBulkEndPoint; //EP2
                BulkInEndPt = myDevice.EndPointOf(0x86) as CyBulkEndPoint;  //EP6
                BulkInEndPt.XferSize = BulkInEndPt.MaxPktSize * 8;//4KB = 512bytes*8,4096
                BulkInEndPt.TimeOut = 100;

                btnSC_or_ReadReg.IsEnabled = true;
                btnReset_cntb.IsEnabled = true;
                btnTRIG_EXT_EN.IsEnabled = true;
                btnSet_Raz_Width.IsEnabled = true;
                btnSet_Hold.IsEnabled = true;
                //btnSetAcqTime.IsEnabled = true;
                btnOut_th_set.IsEnabled = true;
            }
            else
            {
                usb_status.Content = "USB device not connected";
                usb_status.Foreground = Brushes.DeepPink;
                btnCommandSend.IsEnabled = false;
                txtCommand.IsEnabled = false;
                //btnConfig.IsEnabled = false;
                btnAcqStart.IsEnabled = false;
                BulkOutEndPt = null;//clear
                BulkInEndPt = null;//clear

                btnSC_or_ReadReg.IsEnabled = false;
                btnReset_cntb.IsEnabled = false;
                btnTRIG_EXT_EN.IsEnabled = false;
                btnSet_Raz_Width.IsEnabled = false;
                btnSet_Hold.IsEnabled = false;
                //btnSetAcqTime.IsEnabled = false;
                btnOut_th_set.IsEnabled = false;
            }
        }
        private void Window_Closing(object sender, System.ComponentModel.CancelEventArgs e)
        {
            MessageBoxResult key = MessageBox.Show(
                "Are you sure you want to quit",
                "Confirm",
                MessageBoxButton.YesNo,
                MessageBoxImage.Question,
                MessageBoxResult.No);
            e.Cancel = (key == MessageBoxResult.No);
        }
        private void btnCommandSend_Click(object sender, RoutedEventArgs e)
        {          
            Regex rx = new Regex(rx_Command);
            if (rx.IsMatch(txtCommand.Text))//matched,convert string to byte
            {
                string report = String.Format("command: 0x{0} issued!\n", txtCommand.Text);
                bool bResult = false;
                byte[] bytes = ConstCommandByteArray(HexStringToByteArray(txtCommand.Text));//convert to byte 

                bResult = CommandSend(bytes,bytes.Length);
                if (bResult)
                {
                    txtReport.AppendText(report.ToString());
                    txtReport.ScrollToEnd();  
                }
                else
                    txtReport.AppendText("command issued faliure!\n");
            }
            else //not matched give a Message
            {
                MessageBox.Show("Only 4 hexadecimal numbers allowed!", //text
                                "Illegal input",   //caption
                                MessageBoxButton.OK,//button
                                MessageBoxImage.Error);//icon
            }
        }
        private void btnClearReport_Click(object sender, RoutedEventArgs e)
        {
            txtReport.Text = "";
        }
        //methods
        private static byte[] HexStringToByteArray(string s)
        {
            s.Replace(" ","");
            byte[] buffer = new byte[s.Length / 2];
            for (int i = 0; i < s.Length; i += 2)
                buffer[i / 2] = (byte)Convert.ToByte(s.Substring(i, 2), 16);
            /*
            byte temp;
            for (int i = 0; i < buffer.Length; i += 2)
            {
                temp = buffer[i];
                buffer[i] = buffer[i + 1];
                buffer[i + 1] = temp;
            }
            */
            return buffer;
        }

        //methods
        private static byte[] IntegerToByteArray(int a)
        {
            byte[] buffer = new byte[2];
            buffer[0] = (byte)(a>>8);
            buffer[1] = (byte)a;
            return buffer;
        }
        //methods
        private static byte[] ConstCommandByteArray(params byte[] paramList)
        {
            byte[] buffer = new byte[paramList.Length];
            Array.Copy(paramList,buffer,paramList.Length);
            byte temp;
            for (int i = 0; i < buffer.Length; i += 2)
            {
                temp = buffer[i];
                buffer[i] = buffer[i + 1];
                buffer[i + 1] = temp;
            }
            return buffer;
        }
        //Command send method
        private bool CommandSend(byte[] OutData, int xferLen)
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
        //data recieve method
        private bool DataRecieve(byte[] InData, int xferLen)
        {
            bool bResult;
            bResult = BulkInEndPt.XferData(ref InData, ref xferLen, true);
            return bResult;
        }
        //Create file directory
        private void btnDirCreate_Click(object sender, RoutedEventArgs e)
        {
            if (string.IsNullOrEmpty(txtFileDir.Text.Trim()))
            {
                MessageBox.Show("Please fill the file directory path first!", //text
                                "Created failure",   //caption
                                MessageBoxButton.OK,//button
                                MessageBoxImage.Error);//icon
            }
            else
            {               
                string FileDir = Path.Combine(txtFileDir.Text);
                if (!Directory.Exists(FileDir))//路径不存在
                {
                    string path = String.Format("File Directory {0} Created\n", txtFileDir.Text);
                    Directory.CreateDirectory(FileDir);
                    txtReport.AppendText(path);
                }
                else
                {
                    MessageBox.Show("The File Directory already exits", //text
                                    "Created failure",   //caption
                                    MessageBoxButton.OK,//button
                                    MessageBoxImage.Warning);//icon
                }                
            }
        }
        //Delete file directory
        private void btnDirDelete_Click(object sender, RoutedEventArgs e)
        {
            if (string.IsNullOrEmpty(txtFileDir.Text.Trim()))
            {
                MessageBox.Show("Please fill the file directory path first!", //text
                                "Delete failure",   //caption
                                MessageBoxButton.OK,//button
                                MessageBoxImage.Error);//icon
            }
            else
            {                
                string FileDir = Path.Combine(txtFileDir.Text);
                if (!Directory.Exists(FileDir))//路径不存在
                {
                    MessageBox.Show("The File Directory doesn't exits", //text
                                     "Delete failure",   //caption
                                     MessageBoxButton.OK,//button
                                     MessageBoxImage.Error);//icon
                }
                else
                {
                    string path = String.Format("File Directory {0} Deleted\n", txtFileDir.Text);
                    Directory.Delete(FileDir);
                    txtReport.AppendText(path);
                }                
            }
        }
        //save file
        private void btnFileSave_Click(object sender, RoutedEventArgs e)
        {
            if (string.IsNullOrEmpty(txtFileName.Text.Trim()))
            {
                MessageBox.Show("File name is missing", //text
                                        "save failure", //caption
                                   MessageBoxButton.OK, //button
                                    MessageBoxImage.Error);//icon
            }
            else
            {
                SaveFileDialog saveDialog = new SaveFileDialog();
                saveDialog.DefaultExt = "dat";
                saveDialog.AddExtension = true;
                saveDialog.FileName = txtFileName.Text;
                saveDialog.InitialDirectory = @txtFileDir.Text;
                saveDialog.OverwritePrompt = true;
                saveDialog.Title = "Save Data files";
                saveDialog.ValidateNames = true;
                filepath = Path.Combine(saveDialog.InitialDirectory, saveDialog.FileName);//文件路径
                if (saveDialog.ShowDialog().Value)
                {
                    FileStream fs = null;
                    if (!File.Exists(filepath))
                    {
                        fs = File.Create(filepath);                         
                        string report = String.Format("File:{0} Created\n",filepath);
                        txtReport.AppendText(report.ToString());
                        
                    }
                    else
                    {
                        MessageBox.Show("the file is already exist", //text
                                                "imformation", //caption
                                           MessageBoxButton.OK, //button
                                            MessageBoxImage.Warning);//icon                        
                    }
                    fs.Close();//close the file
                }
            }
        }
        //set average points
        /*
        private void btnAverage_Points_Click(object sender, RoutedEventArgs e)
        {
            string report;
            byte value = (byte)cbxAverage_Points.SelectedIndex;
            byte[] ave_points = ConstCommandByteArray(0xC0, value);
            bool bResult = CommandSend(ave_points, ave_points.Length);
            if (bResult)
            {
                report = string.Format("Select {0} averaging for each chn\n", cbxAverage_Points.Text.Trim());
            }
            else
            {
                report = string.Format("Fail to select average points\n");
            }
            txtReport.AppendText(report.ToString());
        }
        */
        //data acquisition start
        private void btnAcqStart_Click(object sender, RoutedEventArgs e)
        {            
            if (filepath == null || string.IsNullOrEmpty(filepath.Trim()))
            {
                MessageBox.Show("You should save the file first before acquisition start", //text
                                        "imformation", //caption
                                   MessageBoxButton.OK, //button
                                    MessageBoxImage.Error);//icon     
            }
            else //file is exsits
            {
                StringBuilder reports = new StringBuilder();
                if (!AcqStart) //Acquisition is not start then start acquisition
                {
                    bool bResult;
                    #region Set Start Acq Time
                    Regex rx_int = new Regex(rx_Integer);
                    bool Is_Time_legal = rx_int.IsMatch(txtStartAcqTime.Text);
                    if (Is_Time_legal)
                    {
                        int value = Int32.Parse(txtStartAcqTime.Text) / 25; //除以25ns 
                        byte[] CmdBytes = ConstCommandByteArray(0xB2, (byte)(value >> 8));
                        bResult = CommandSend(CmdBytes, CmdBytes.Length);
                        if (!bResult)
                        {
                            MessageBox.Show("Set StartAcq time failure, please check USB", //text
                                             "USB Error",   //caption
                                             MessageBoxButton.OK,//button
                                             MessageBoxImage.Error);//icon
                            return;
                        }
                        CmdBytes = ConstCommandByteArray(0xB1, (byte)(value));
                        bResult = CommandSend(CmdBytes, CmdBytes.Length);
                        if (bResult)
                        {
                            string report = string.Format("Set StartAcq time : {0}\n", txtStartAcqTime.Text);
                            txtReport.AppendText(report);
                        }
                        else
                        {
                            MessageBox.Show("Set StartAcq time failure, please check USB", //text
                                             "USB Error",   //caption
                                             MessageBoxButton.OK,//button
                                             MessageBoxImage.Error);//icon
                            return;
                        }
                    }
                    else
                    {
                        MessageBox.Show("Illegal StartAcq Time, please re-type(Integer:0--1638400,step:25ns)", //text
                                         "Illegal input",   //caption
                                         MessageBoxButton.OK,//button
                                         MessageBoxImage.Error);//icon
                        return;
                    }
                    #endregion
                    #region Set End Hold Time
                    if (DaqMode == SlaveDaq)
                    {
                        byte[] CommandBytes = new byte[2];
                        bool IsEndHoldTimeLegal = rx_int.IsMatch(txtEndHoldTime.Text) && (int.Parse(txtEndHoldTime.Text) < 65536);
                        if(IsEndHoldTimeLegal)
                        {
                            int EndHoldTime = int.Parse(txtEndHoldTime.Text);
                            int EndHoldTime1 = (EndHoldTime & 15) + 64;//0x40
                            int EndHoldTime2 = ((EndHoldTime >> 4) & 15) + 80;//0x50
                            int EndHoldTime3 = ((EndHoldTime >> 8) & 15) + 96;//0x60
                            int EndHoldTime4 = ((EndHoldTime >> 12) & 15) + 112;//0x70
                            CommandBytes = ConstCommandByteArray(0xE8, (byte)EndHoldTime1);
                            bResult = CommandSend(CommandBytes, CommandBytes.Length);
                            if(!bResult)
                            {
                                MessageBox.Show("Set End Hold Time Failure, please check USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                                return;
                            }
                            CommandBytes = ConstCommandByteArray(0xE8, (byte)EndHoldTime2);
                            bResult = CommandSend(CommandBytes, CommandBytes.Length);
                            if (!bResult)
                            {
                                MessageBox.Show("Set End Hold Time Failure, please check USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                                return;
                            }
                            CommandBytes = ConstCommandByteArray(0xE0, (byte)EndHoldTime3);
                            bResult = CommandSend(CommandBytes, CommandBytes.Length);
                            if (!bResult)
                            {
                                MessageBox.Show("Set End Hold Time Failure, please check USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                                return;
                            }
                            CommandBytes = ConstCommandByteArray(0xE0, (byte)EndHoldTime4);
                            bResult = CommandSend(CommandBytes, CommandBytes.Length);
                            if (bResult)
                            {
                                string report = string.Format("Set End Signal Time:{0}\n", EndHoldTime);
                                txtReport.AppendText(report);
                            }
                            else
                            {
                                MessageBox.Show("Set End Hold Time Failure, please check USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                                return;
                            }
                        }
                        else
                        {
                            MessageBox.Show("Illegal End Signal Hold Time, please re-type(Integer:0--1638400,step:25ns)", //text
                                         "Illegal input",   //caption
                                         MessageBoxButton.OK,//button
                                         MessageBoxImage.Error);//icon
                        }
                    }                    
                    #endregion
                    AcqStart = true;
                    btnAcqStart.Content = "AcqAbort";
                    btnAcqStart.Background = Brushes.DeepPink;
                    threadbuffer.Clear();
                    bResult = false;
                    byte[] cmd_ClrUSBFifo = ConstCommandByteArray(0xF0, 0xFA);
                    bResult = CommandSend(cmd_ClrUSBFifo, 2);//
                    if (bResult)
                        reports.AppendLine("USB fifo cleared");
                    else
                        reports.AppendLine("fail to clear USB fifo");
                    //string test = string.Format("MAXPktSize is {0}\n", BulkInEndPt.MaxPktSize);
                    //reports.AppendLine(test.ToString());
                    byte[] bytes = new byte[2048];
                    bResult = DataRecieve(bytes, bytes.Length);
                    /*Modefied for the Microroc DAQ
                    byte value = (byte)cbxChn_Select.SelectedIndex;
                    byte[] cmd_AcqStart = ConstCommandByteArray(0xF0, value);*/
                    byte[] CommandForceMicrorocReset = ConstCommandByteArray(0xF0,0xF2);
                    bResult = CommandSend(CommandForceMicrorocReset, CommandForceMicrorocReset.Length);
                    if(bResult)
                    {
                        reports.AppendLine("Microroc Reset");
                    }
                    else
                    {
                        MessageBox.Show("Reset Microroc Failure", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                        return;
                    }
                    Thread.Sleep(10);
                    byte[] cmd_AcqStart = ConstCommandByteArray(0xF0, 0xF0);
                    bResult = CommandSend(cmd_AcqStart, 2);
                    if (bResult)
                    {
                        reports.AppendLine("Data Acquisition Thread start");
                        data_acq_cts.Dispose(); //clean up old token source
                        file_write_cts.Dispose();//clean up old token source
                        data_acq_cts = new CancellationTokenSource(); //reset the token
                        file_write_cts = new CancellationTokenSource();//reset the token
                        Task data_acq = Task.Factory.StartNew(() => Async_AcquisitionThreadCallBack(data_acq_cts.Token), data_acq_cts.Token);
                        Task write_file = Task.Factory.StartNew(() => WriteFileCallBack(file_write_cts.Token), file_write_cts.Token);
                        //ThreadPool.QueueUserWorkItem(new WaitCallback(Async_AcquisitionThreadCallBack), cts_a.Token);//读取usb数据
                        //ThreadPool.QueueUserWorkItem(new WaitCallback(WriteFileCallBack),cts_b.Token);//写入文件
                    }
                    else
                        reports.AppendLine("Data Acquisition Start failure");
                    txtReport.AppendText(reports.ToString());
                }
                else //Acqsition is running then stop acquisition
                {
                    AcqStart = false;
                    btnAcqStart.Content = "AcqStart";
                    btnAcqStart.Background = Brushes.ForestGreen;
                    bool bResult = false;
                    byte[] cmd_AcqStop = ConstCommandByteArray(0xF0, 0xF1);
                    bResult = CommandSend(cmd_AcqStop, 2);
                    if (bResult)
                    {
                        //AcqStart = false;
                        reports.AppendLine("Data Acquisition Stoped");
                    }                       
                    else
                        reports.AppendLine("Data Acquisition Stoped failure");
                    data_acq_cts.Cancel(); //stop the thread
                    file_write_cts.Cancel();//stop the thread                             
                    txtReport.AppendText(reports.ToString());
                }
            }
        }
        //data aquisition thread
        private unsafe void Async_AcquisitionThreadCallBack(CancellationToken cancellationToken)
        {
            //CancellationToken token = (CancellationToken)StartOrNot;
            //StringBuilder sb = new StringBuilder();
            string report;
            // DisplayPacketNum dp = new DisplayPacketNum((StringBuilder s) => { ShowPacketNum(s); });
            DisplayPacketNum dp = new DisplayPacketNum((string s) => { ShowPacketNum(s); });
            Packetcnt = 0;
            int BufSz = BulkInEndPt.XferSize;
            //bool BeginDataXfer(ref byte[] singleXfer,ref byte[] buffer, ref int len, ref byte[] ov) 
            //If user set the XMODE to BUFFERED mode for particular endpoint then user need to allocate singleXfer
            //(the command buffer) with size of SINGLE_XFER_LEN and data buffer length. This buffer will be passed
            //to the singleXer the first parameter of BeginDataXfer. This is the requirement specific to the BUFFERED 
            //mode only. The below sample example shows the usage of it. 
            while (!cancellationToken.IsCancellationRequested)
            {
                byte[] cmdBufs = new byte[CyConst.SINGLE_XFER_LEN + ((BulkInEndPt.XferMode == XMODE.BUFFERED) ? BufSz : 0)];
                byte[] xferBufs = new byte[BufSz];
                byte[] ovLaps = new byte[CyConst.OverlapSignalAllocSize];
                fixed (byte* tmp0 = ovLaps)
                {
                    OVERLAPPED* ovLapStatus = (OVERLAPPED*)tmp0;
                    ovLapStatus->hEvent = PInvoke.CreateEvent(0, 0, 0, 0);
                }
                BulkInEndPt.BeginDataXfer(ref cmdBufs, ref xferBufs, ref BufSz, ref ovLaps);
                fixed (byte* tmp0 = ovLaps)
                {
                    OVERLAPPED* ovLapStatus = (OVERLAPPED*)tmp0;
                    if (!BulkInEndPt.WaitForXfer(ovLapStatus->hEvent, 500))
                    {
                        BulkInEndPt.Abort();
                        PInvoke.WaitForSingleObject(ovLapStatus->hEvent, CyConst.INFINITE);
                    }
                }
                if (BulkInEndPt.FinishDataXfer(ref cmdBufs, ref xferBufs, ref BufSz, ref ovLaps))
                {
                    //传输成功,写入缓存
                    threadbuffer.setBuffer(xferBufs);
                    Packetcnt++;
                }
                else
                {
                    //传输失败
                    report = string.Format("Get Data faliure .\n");
                    //delegate
                    Dispatcher.Invoke(dp, report);
                    // this.Dispatcher.Invoke(dp, sb);
                }
                if (Packetcnt % 100 == 0)
                {
                    report = string.Format("Aquired {0} packets\n", Packetcnt);
                    Dispatcher.Invoke(dp, report);
                    //this.Dispatcher.Invoke(dp, sb);
                }

            }
            report = string.Format("About {0} packets in total\n", Packetcnt);
            Dispatcher.Invoke(dp, report);
            //delegate
        }
        //wrting file thread
        private void WriteFileCallBack(CancellationToken cancellationToken)
        {
            //CancellationToken token = (CancellationToken)stateInfo;
            DisplayPacketNum dp2 = new DisplayPacketNum((string s) => { ShowPacketNum(s); });
            string report;
            bw = new BinaryWriter(File.Open(filepath, FileMode.Append));
            byte[] buffer = new byte[4096];
            while (!cancellationToken.IsCancellationRequested)
            {
                buffer = threadbuffer.getBuffer();
                bw.Write(buffer);
            }           
            bw.Flush();
            bw.Dispose();
            bw.Close();
            report = string.Format("data stored in {0}\n",filepath);
            Dispatcher.Invoke(dp2, report);
            
        }
        private void ShowPacketNum(object packetnum)
        {
            string report = (string)packetnum;
            txtReport.AppendText(report.ToString());
        }
        //----------Waveform show--------- //启动动态显示线程
        /*
        private void btnWaveformShow_Click(object sender, RoutedEventArgs e)
        {
            timer.Interval = TimeSpan.FromSeconds(0.1);
            timer.Tick += new EventHandler(AnimatedPlot);
            timer.IsEnabled = true;
            if (wave_cnt == 0)
            {
                Chn1 = plotter.AddLineGraph(dataSource1, Colors.Red, 2, "Chn1");
                Chn2 = plotter.AddLineGraph(dataSource2, Colors.Black, 2, "Chn2");       
            }
             plotter.Viewport.FitToView();
           // plotter.Viewport.SetBinding(Viewport2D.VisibilityProperty,);
        }
        private void AnimatedPlot(object sender, EventArgs e)
        {
            double x = wave_cnt;
            double y1 = Math.Sin(wave_cnt * 0.2);
            double y2 = 2 * Math.Sin(wave_cnt * 0.6);
            Point point1 = new Point(x, y1);
            Point point2 = new Point(x, y2);
            dataSource1.AppendAsync(base.Dispatcher, point1);
            dataSource2.AppendAsync(base.Dispatcher, point2);
            wave_cnt++;
        }
        private void btnWaveformStop_Click(object sender, RoutedEventArgs e)
        {
            timer.IsEnabled = false;
        }
        private void btnWaveformClear_Click(object sender, RoutedEventArgs e)
        {
            wave_cnt = 0;
            timer.IsEnabled = false;
            plotter.Children.Remove(Chn1);
            plotter.Children.Remove(Chn2);
            dataSource1 = new ObservableDataSource<Point>();
            dataSource2 = new ObservableDataSource<Point>();
        }
        */
        //-----------Serialport--------------
        private void SC_or_Read_Checked(object sender, RoutedEventArgs e)
        {
            //Get Radiobutton reference
            var button = sender as RadioButton;
            //Display button content as title
            bool bResult = false;
            #region Generate the Array of SC parameter
            // 10-bit DAC Code
            TextBox[] txtDAC0_VTH_ASIC = new TextBox[4] { txtDAC0_VTH_ASIC1, txtDAC0_VTH_ASIC2, txtDAC0_VTH_ASIC3, txtDAC0_VTH_ASIC4 };
            TextBox[] txtDAC1_VTH_ASIC = new TextBox[4] { txtDAC1_VTH_ASIC1, txtDAC1_VTH_ASIC2, txtDAC1_VTH_ASIC3, txtDAC1_VTH_ASIC4 };
            TextBox[] txtDAC2_VTH_ASIC = new TextBox[4] { txtDAC2_VTH_ASIC1, txtDAC2_VTH_ASIC2, txtDAC2_VTH_ASIC3, txtDAC2_VTH_ASIC4 };
            //Select Shaper Output
            ComboBox[] cbxOut_sh_ASIC = new ComboBox[4] { cbxOut_sh_ASIC1, cbxOut_sh_ASIC2, cbxOut_sh_ASIC3, cbxOut_sh_ASIC4 };
            //Shaper Output Enable
            ComboBox[] cbxShaper_Output_Enable_ASIC = new ComboBox[4] { cbxShaper_Output_Enable_ASIC1, cbxShaper_Output_Enable_ASIC2, cbxShaper_Output_Enable_ASIC3, cbxShaper_Output_Enable_ASIC4 };
            // CTest Channel
            TextBox[] txtCTest_ASIC = new TextBox[4] { txtCTest_ASIC1, txtCTest_ASIC2, txtCTest_ASIC3, txtCTest_ASIC4 };
            // sw hg
            ComboBox[] cbxsw_hg_ASIC = new ComboBox[4] { cbxsw_hg_ASIC1, cbxsw_hg_ASIC2, cbxsw_hg_ASIC3, cbxsw_hg_ASIC4 };
            // sw lg
            ComboBox[] cbxsw_lg_ASIC = new ComboBox[4] { cbxsw_lg_ASIC1, cbxsw_lg_ASIC2, cbxsw_lg_ASIC3, cbxsw_lg_ASIC4 };
            // Internal Raz time
            ComboBox[] cbxInternal_RAZ_Time_ASIC = new ComboBox[4] { cbxInternal_RAZ_Time_ASIC1, cbxInternal_RAZ_Time_ASIC2, cbxInternal_RAZ_Time_ASIC3, cbxInternal_RAZ_Time_ASIC4 };
            //Read Reg
            TextBox[] txtRead_reg_ASIC = new TextBox[4] { txtRead_reg_ASIC1, txtRead_reg_ASIC2, txtRead_reg_ASIC3, txtRead_reg_ASIC4 };
            // 4-bit DAC Cali
            //CheckBox[] chk_PedCali_ASIC = new CheckBox[4] { chk_PedCali_ASIC1, chk_PedCali_ASIC2, chk_PedCali_ASIC3, chk_PedCali_ASIC4 };
            ComboBox[] cbxPedCali_ASIC = new ComboBox[4] { cbxPedCali_ASIC1, cbxPedCali_ASIC2, cbxPedCali_ASIC3, cbxPedCali_ASIC4 };
            #endregion
            #region Select SC
            if (button.Content.ToString() == "SC")
            { 
                btnSC_or_ReadReg.Content = "Slow control";
                btnSC_or_ReadReg.Background = Brushes.GreenYellow;
                for(int i = 0;i <= cbxASIC_Number.SelectedIndex; i++)
                {
                    txtRead_reg_ASIC[i].IsEnabled = false;
                    txtDAC0_VTH_ASIC[i].IsEnabled = true;
                    txtDAC1_VTH_ASIC[i].IsEnabled = true;
                    txtDAC2_VTH_ASIC[i].IsEnabled = true;
                    txtCTest_ASIC[i].IsEnabled = true;
                    cbxShaper_Output_Enable_ASIC[i].IsEnabled = true;
                    cbxOut_sh_ASIC[i].IsEnabled = true;
                    cbxsw_hg_ASIC[i].IsEnabled = true;
                    cbxsw_lg_ASIC[i].IsEnabled = true;
                    cbxInternal_RAZ_Time_ASIC[i].IsEnabled = true;
                    cbxPedCali_ASIC[i].IsEnabled = true;   
                    //chk_PedCali_ASIC[i].IsEnabled = true;
                }
                for(int i = cbxASIC_Number.SelectedIndex + 1; i < 4; i++)
                {
                    txtRead_reg_ASIC[i].IsEnabled = false;
                    txtDAC0_VTH_ASIC[i].IsEnabled = false;
                    txtDAC1_VTH_ASIC[i].IsEnabled = false;
                    txtDAC2_VTH_ASIC[i].IsEnabled = false;
                    txtCTest_ASIC[i].IsEnabled = false;
                    cbxShaper_Output_Enable_ASIC[i].IsEnabled = false;
                    cbxOut_sh_ASIC[i].IsEnabled = false;
                    cbxsw_hg_ASIC[i].IsEnabled = false;
                    cbxsw_lg_ASIC[i].IsEnabled = false;
                    cbxInternal_RAZ_Time_ASIC[i].IsEnabled = false;
                    cbxPedCali_ASIC[i].IsEnabled = false;
                    //chk_PedCali_ASIC[i].IsEnabled = false;
                }
                txtHeader.IsEnabled = true;
                /*txtRead_reg.IsEnabled = false;
                txtDAC0_VTH.IsEnabled = true;
                txtDAC1_VTH.IsEnabled = true;
                txtDAC2_VTH.IsEnabled = true;
                txtHeader.IsEnabled = true;
                txtCTest.IsEnabled = true;*/

                //Raz_Chn_Select.IsEnabled = true;
                byte[] Slow_Control = ConstCommandByteArray(0xA0, 0xA0);
                //bResult = false;
                bResult = CommandSend(Slow_Control, Slow_Control.Length);
                if (bResult)
                {
                    txtReport.AppendText("you are choosing SC mode\n");
                }
                else
                {
                   // txtReport.AppendText("select failure, please check USB\n");
                    MessageBox.Show("select failure, please check USB", //text
                                     "USB Error",   //caption
                                     MessageBoxButton.OK,//button
                                     MessageBoxImage.Error);//icon
                }
            }
            #endregion
            #region Select ReadReg
            else if (button.Content.ToString() == "ReadReg")
            {             
                btnSC_or_ReadReg.Content = "Read Register";
                btnSC_or_ReadReg.Background = Brushes.Orange;
                for (int i = 0; i <= cbxASIC_Number.SelectedIndex; i++)
                {
                    txtRead_reg_ASIC[i].IsEnabled = true;
                    txtDAC0_VTH_ASIC[i].IsEnabled = false;
                    txtDAC1_VTH_ASIC[i].IsEnabled = false;
                    txtDAC2_VTH_ASIC[i].IsEnabled = false;
                    txtCTest_ASIC[i].IsEnabled = false;
                    cbxShaper_Output_Enable_ASIC[i].IsEnabled = false;
                    cbxOut_sh_ASIC[i].IsEnabled = false;
                    cbxsw_hg_ASIC[i].IsEnabled = false;
                    cbxsw_lg_ASIC[i].IsEnabled = false;
                    cbxInternal_RAZ_Time_ASIC[i].IsEnabled = false;
                    cbxPedCali_ASIC[i].IsEnabled = false;
                    //chk_PedCali_ASIC[i].IsEnabled = false;
                }
                for (int i = cbxASIC_Number.SelectedIndex + 1; i < 4; i++)
                {
                    txtRead_reg_ASIC[i].IsEnabled = false;
                    txtDAC0_VTH_ASIC[i].IsEnabled = false;
                    txtDAC1_VTH_ASIC[i].IsEnabled = false;
                    txtDAC2_VTH_ASIC[i].IsEnabled = false;
                    txtCTest_ASIC[i].IsEnabled = false;
                    cbxShaper_Output_Enable_ASIC[i].IsEnabled = false;
                    cbxOut_sh_ASIC[i].IsEnabled = false;
                    cbxsw_hg_ASIC[i].IsEnabled = false;
                    cbxsw_lg_ASIC[i].IsEnabled = false;
                    cbxInternal_RAZ_Time_ASIC[i].IsEnabled = false;
                    cbxPedCali_ASIC[i].IsEnabled = false;
                    //chk_PedCali_ASIC[i].IsEnabled = false;
                }
                txtHeader.IsEnabled = false;
                /*txtRead_reg.IsEnabled = true;
                txtDAC0_VTH.IsEnabled = false;
                txtDAC1_VTH.IsEnabled = false;
                txtDAC2_VTH.IsEnabled = false;
                txtHeader.IsEnabled = false;
                txtCTest.IsEnabled = false;*/
                //Raz_Chn_Select.IsEnabled = false;
                byte[] Read_Register = ConstCommandByteArray(0xA0, 0xA1);
                //bResult = false;
                bResult = CommandSend(Read_Register, Read_Register.Length);
                if (bResult)
                {
                    txtReport.AppendText("you are choosing ReadReg mode\n");
                }
                else
                {
                    //txtReport.AppendText("select failure, please check USB\n");
                    MessageBox.Show("select failure, please check USB", //text
                                     "USB Error",   //caption
                                     MessageBoxButton.OK,//button
                                     MessageBoxImage.Error);//icon
                }
            }
            #endregion
        }
        private void btnSC_or_ReadReg_Click(object sender, RoutedEventArgs e)
        {
            bool bResult = false;
            #region Set ASIC Number
            /*----------------ASIC number and start load---------------------*/
            int ASIC_Number = cbxASIC_Number.SelectedIndex;
            int value = ASIC_Number + 176 + 1;//0xB0
            byte[] com_bytes = new byte[2];
            com_bytes = ConstCommandByteArray(0xA0, (byte)(value));
            bResult = CommandSend(com_bytes, com_bytes.Length);
            if (bResult)
            {
                string report = string.Format("ASIC quantity : {0}\n", cbxASIC_Number.Text);
                txtReport.AppendText(report);
            }
            else
            {
                MessageBox.Show("Set ASIC quantity failure, please check USB", //text
                                 "USB Error",   //caption
                                 MessageBoxButton.OK,//button
                                 MessageBoxImage.Error);//icon
            }
            #endregion
            //if there is a slow control operation      
            #region Slow Control      
            if ((string)btnSC_or_ReadReg.Content == "Slow control")
            {
                #region Generate the Array of SC parameter
                // 10-bit DAC Code
                TextBox[] txtDAC0_VTH_ASIC = new TextBox[4] { txtDAC0_VTH_ASIC1, txtDAC0_VTH_ASIC2, txtDAC0_VTH_ASIC3, txtDAC0_VTH_ASIC4 };
                TextBox[] txtDAC1_VTH_ASIC = new TextBox[4] { txtDAC1_VTH_ASIC1, txtDAC1_VTH_ASIC2, txtDAC1_VTH_ASIC3, txtDAC1_VTH_ASIC4 };
                TextBox[] txtDAC2_VTH_ASIC = new TextBox[4] { txtDAC2_VTH_ASIC1, txtDAC2_VTH_ASIC2, txtDAC2_VTH_ASIC3, txtDAC2_VTH_ASIC4 };
                //Select Shaper Output
                ComboBox[] cbxOut_sh_ASIC = new ComboBox[4] { cbxOut_sh_ASIC1, cbxOut_sh_ASIC2, cbxOut_sh_ASIC3, cbxOut_sh_ASIC4 };
                //Shaper Output Enable
                ComboBox[] cbxShaper_Output_Enable_ASIC = new ComboBox[4] { cbxShaper_Output_Enable_ASIC1, cbxShaper_Output_Enable_ASIC2, cbxShaper_Output_Enable_ASIC3, cbxShaper_Output_Enable_ASIC4 };
                // CTest Channel
                TextBox[] txtCTest_ASIC = new TextBox[4] { txtCTest_ASIC1, txtCTest_ASIC2, txtCTest_ASIC3, txtCTest_ASIC4 };
                // sw hg
                ComboBox[] cbxsw_hg_ASIC = new ComboBox[4] { cbxsw_hg_ASIC1, cbxsw_hg_ASIC2, cbxsw_hg_ASIC3, cbxsw_hg_ASIC4 };
                // sw lg
                ComboBox[] cbxsw_lg_ASIC = new ComboBox[4] { cbxsw_lg_ASIC1, cbxsw_lg_ASIC2, cbxsw_lg_ASIC3, cbxsw_lg_ASIC4 };
                // Internal Raz time
                ComboBox[] cbxInternal_RAZ_Time_ASIC = new ComboBox[4] { cbxInternal_RAZ_Time_ASIC1, cbxInternal_RAZ_Time_ASIC2, cbxInternal_RAZ_Time_ASIC3, cbxInternal_RAZ_Time_ASIC4 };
                // 4-bit DAC Cali
                ComboBox[] cbxPedCali_ASIC = new ComboBox[4] { cbxPedCali_ASIC1, cbxPedCali_ASIC2, cbxPedCali_ASIC3, cbxPedCali_ASIC4 };
                #endregion
                Regex rx_int = new Regex(rx_Integer);
                Regex rx_b = new Regex(rx_Byte);
                #region Check Header Legal
                bool Is_Header_Legal = false;
                Is_Header_Legal = rx_b.IsMatch(txtHeader.Text);
                byte[] Header_Value = new byte[1];
                if (Is_Header_Legal)
                {
                    Header_Value = HexStringToByteArray(txtHeader.Text.Trim());
                }
                else
                {
                    MessageBox.Show("Header value is illegal. Please re-type (Eg:Hex:AA).\n Set header default value 0xA1", "Illega Input", MessageBoxButton.OK, MessageBoxImage.Error);
                    string header_default = "A1";
                    Header_Value = HexStringToByteArray(header_default);
                }
                #endregion                
                bool Is_DAC_Legal = false;
                int DAC0_Value, DAC1_Value, DAC2_Value;
                int ShaperOutput_Value;
                int ShaperOutputEnable_Value;
                bool IsCTestLegal = false;
                int CTest_Value;
                int SW_HG_Value, SW_LG_Value, SW_Value;
                int InternalRazTime_Value;
                byte[] CommandBytes = new byte[2];
                //byte[] PedCali_Param;
                //byte PedCali_Byte1,PedCali_Byte2;
                StringBuilder details = new StringBuilder();
                //NoSortHashtable TempHashTabel;
                Header_Value[0] += (byte)(ASIC_Number + 1);
                string DCCaliString, SCTCaliString;
                byte[] CaliData = new byte[64];
                //byte[] SCTCaliData = new byte[64];
                string[] Chn = new string[64];
                byte[] CommandHeader = new byte[64];
                byte CaliByte1, CaliByte2;
                // *** Generate channel mask header
                for (int i = 0; i < 64; i++)
                {
                    Chn[i] = string.Format("Chn{0}", i);
                    CommandHeader[i] = (byte)(0xC0 + i);
                }
                #region RAZ Select
                int RazSelect = cbxRazSelect.SelectedIndex + 160;//0xA0
                CommandBytes = ConstCommandByteArray(0xA8, (byte)RazSelect);
                bResult = CommandSend(CommandBytes, CommandBytes.Length);
                if(bResult)
                {
                    string report = string.Format("Set Raz Mode: {0}\n", cbxRazSelect.Text);
                    txtReport.AppendText(report);
                }
                else
                {
                    MessageBox.Show("Set Raz Mode failure, please check USB", //text
                                 "USB Error",   //caption
                                 MessageBoxButton.OK,//button
                                 MessageBoxImage.Error);//icon
                }
                #endregion
                #region Channel Select
                int ChannelSelect = cbxChannelSelect.SelectedIndex + 160;//A0
                CommandBytes = ConstCommandByteArray(0xA4, (byte)ChannelSelect);
                bResult = CommandSend(CommandBytes, CommandBytes.Length);
                if(bResult)
                {
                    string report = string.Format("Set ReadOut {0}\n", cbxChannelSelect.Text);
                    txtReport.AppendText(report);
                }
                else
                {
                    MessageBox.Show("Set Readout Channel failure, please check USB", //text
                                 "USB Error",   //caption
                                 MessageBoxButton.OK,//button
                                 MessageBoxImage.Error);//icon
                }
                #endregion
                #region RS Or Direct
                int RSOrDirect = cbxRSOrDirect.SelectedIndex + 160;//A0
                CommandBytes = ConstCommandByteArray(0xAC, (byte)RSOrDirect);
                bResult = CommandSend(CommandBytes, CommandBytes.Length);
                if (bResult)
                {
                    string report = string.Format("Set {0} as trigger\n", cbxRSOrDirect.Text);
                    txtReport.AppendText(report);
                }
                else
                {
                    MessageBox.Show("Set RS Or Direct failure, please check USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                }
                #endregion
                #region ReadReg Or NOR64
                int ReadRegOrNOR64 = cbxReadOrNOR64.SelectedIndex + 176;//0xB0
                CommandBytes = ConstCommandByteArray(0xAC, (byte)ReadRegOrNOR64);
                bResult = CommandSend(CommandBytes, CommandBytes.Length);
                if (bResult)
                {
                    string report = string.Format("Set trigger out by {0}\n", cbxReadOrNOR64.Text);
                    txtReport.AppendText(report);
                }
                else
                {
                    MessageBox.Show("Set Readreg or NOR64 failure, please check USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                }
                #endregion
                for (int i = ASIC_Number;i >= 0; i--)
                {
                    #region Header   
                    Header_Value[0] -= 1;
                    CommandBytes = ConstCommandByteArray(0xAB, Header_Value[0]);
                    bResult = CommandSend(CommandBytes, CommandBytes.Length);
                    if (bResult)
                    {
                        string report = string.Format("Setting header: 0x{0}\n", txtHeader.Text.Trim());
                        txtReport.AppendText(report);
                    }
                    else
                    {
                        MessageBox.Show("Set header failure. Please check USB", //text
                                         "USB Error",   //caption
                                         MessageBoxButton.OK,//button
                                         MessageBoxImage.Error);//icon
                    }
                    #endregion
                    #region 10-bit DAC
                    Is_DAC_Legal = rx_int.IsMatch(txtDAC0_VTH_ASIC[i].Text) && rx_int.IsMatch(txtDAC1_VTH_ASIC[i].Text) && rx_int.IsMatch(txtDAC2_VTH_ASIC[i].Text);
                    if(Is_DAC_Legal)
                    {
                        DAC0_Value = Int32.Parse(txtDAC0_VTH_ASIC[i].Text) + 49152;//0xC000
                        DAC1_Value = Int32.Parse(txtDAC1_VTH_ASIC[i].Text) + 50176;//0xC400
                        DAC2_Value = Int32.Parse(txtDAC2_VTH_ASIC[i].Text) + 51200;//0xC800
                        #region DAC0
                        CommandBytes = ConstCommandByteArray((byte)(DAC0_Value >> 8), (byte)DAC0_Value);
                        bResult = CommandSend(CommandBytes, CommandBytes.Length);
                        if (bResult)
                        {
                            string report = string.Format("Setting DAC0 VTH: {0}\n", txtDAC0_VTH_ASIC[i].Text);
                            txtReport.AppendText(report);
                        }
                        else
                        {
                            //txtReport.AppendText("set DAC0 failure, please check USB\n");
                            MessageBox.Show("Set DAC0 failure. Please check USB", //text
                                             "USB Error",   //caption
                                             MessageBoxButton.OK,//button
                                             MessageBoxImage.Error);//icon
                        }
                        #endregion
                        #region DAC1
                        CommandBytes = ConstCommandByteArray((byte)(DAC1_Value >> 8), (byte)DAC1_Value);
                        bResult = CommandSend(CommandBytes, CommandBytes.Length);
                        if (bResult)
                        {
                            string report = string.Format("Setting DAC1 VTH: {0}\n", txtDAC1_VTH_ASIC[i].Text);
                            txtReport.AppendText(report);
                        }
                        else
                        {
                            //txtReport.AppendText("set DAC0 failure, please check USB\n");
                            MessageBox.Show("Set DAC1 failure. Please check USB", //text
                                             "USB Error",   //caption
                                             MessageBoxButton.OK,//button
                                             MessageBoxImage.Error);//icon
                        }
                        #endregion
                        #region DAC2
                        CommandBytes = ConstCommandByteArray((byte)(DAC2_Value >> 8), (byte)DAC2_Value);
                        bResult = CommandSend(CommandBytes, CommandBytes.Length);
                        if (bResult)
                        {
                            string report = string.Format("Setting DAC2 VTH: {0}\n", txtDAC2_VTH_ASIC[i].Text);
                            txtReport.AppendText(report);
                        }
                        else
                        {
                            //txtReport.AppendText("set DAC0 failure, please check USB\n");
                            MessageBox.Show("Set DAC0 failure. Please check USB", //text
                                             "USB Error",   //caption
                                             MessageBoxButton.OK,//button
                                             MessageBoxImage.Error);//icon
                        }
                        #endregion
                    }
                    else
                    {
                        MessageBox.Show("DAC value is illegal,please re-type(Integer:0--1023)", //text
                    "Illegal input",   //caption
                    MessageBoxButton.OK,//button
                    MessageBoxImage.Error);//icon
                    }
                    #endregion
                    #region Shaper Output
                    ShaperOutput_Value = cbxOut_sh_ASIC[i].SelectedIndex + 192;//C0
                    CommandBytes = ConstCommandByteArray(0xA0, (byte)ShaperOutput_Value);
                    bResult = CommandSend(CommandBytes, CommandBytes.Length);
                    if (bResult)
                    {
                        string report = string.Format("Shape output: {0}\n", cbxOut_sh_ASIC[i].Text);
                        txtReport.AppendText(report);
                    }
                    else
                    {
                        MessageBox.Show("Set shape output failure. Please check USB", //text
                                         "USB Error",   //caption
                                         MessageBoxButton.OK,//button
                                         MessageBoxImage.Error);//icon
                    }
                    #endregion
                    #region Shaper Output Enable
                    ShaperOutputEnable_Value = cbxShaper_Output_Enable_ASIC[i].SelectedIndex + 208;//0xD0
                    CommandBytes = ConstCommandByteArray(0xA0, (byte)ShaperOutputEnable_Value);
                    bResult = CommandSend(CommandBytes, CommandBytes.Length);
                    if (bResult)
                    {
                        string report = string.Format("You have {0} the shaper output", cbxShaper_Output_Enable_ASIC[i].Text);
                        txtReport.AppendText(report);
                    }
                    else
                    {
                        MessageBox.Show("Set shaper state failure. Please check the USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                    }
                    #endregion
                    #region CTest Channel
                    IsCTestLegal = rx_int.IsMatch(txtCTest_ASIC[i].Text);
                    if(IsCTestLegal)
                    {
                        CTest_Value = Int32.Parse(txtCTest_ASIC[i].Text);//A1XX
                        CommandBytes = ConstCommandByteArray(0xA1, (byte)CTest_Value);
                        bResult = CommandSend(CommandBytes, CommandBytes.Length);
                        if (bResult)
                        {
                            string report = string.Format("Setting CTest channel: {0}\n", txtCTest_ASIC[i].Text);
                            txtReport.AppendText(report);
                        }
                        else
                        {
                            //txtReport.AppendText("set DAC0 failure, please check USB\n");
                            MessageBox.Show("Set Ctest failure. Please check USB", //text
                                             "USB Error",   //caption
                                             MessageBoxButton.OK,//button
                                             MessageBoxImage.Error);//icon
                        }
                    }
                    else
                    {
                        MessageBox.Show("Ctest value is illegal,please re-type(Integer:0--64,or 255)", //text
                  "Illegal input",   //caption
                  MessageBoxButton.OK,//button
                  MessageBoxImage.Error);//icon
                    }
                    #endregion
                    #region sw_hg sw_lg
                    SW_HG_Value = cbxsw_hg_ASIC[i].SelectedIndex * 16;
                    SW_LG_Value = cbxsw_lg_ASIC[i].SelectedIndex;
                    SW_Value = SW_HG_Value + SW_LG_Value;
                    CommandBytes = ConstCommandByteArray(0xB3, (byte)SW_Value);
                    bResult = CommandSend(CommandBytes, CommandBytes.Length);
                    if (bResult)
                    {
                        string report = string.Format("Set sw_hg: {0}; sw_lg: {1}\n", cbxsw_hg_ASIC[i].Text, cbxsw_lg_ASIC[i].Text);
                        txtReport.AppendText(report);
                    }
                    else
                    {
                        MessageBox.Show("Set sw_hg and sw_lg failure. Please check USB", //text
                                         "USB Error",   //caption
                                         MessageBoxButton.OK,//button
                                         MessageBoxImage.Error);//icon
                    }
                    #endregion
                    #region Internal RAZ Time
                    InternalRazTime_Value = cbxInternal_RAZ_Time_ASIC[i].SelectedIndex + 176;//0xB0
                    CommandBytes = ConstCommandByteArray(0xA8, (byte)InternalRazTime_Value);
                    bResult = CommandSend(CommandBytes, CommandBytes.Length);
                    if (bResult)
                    {
                        string report = string.Format("Internal RAZ Mode: {0} \n", cbxInternal_RAZ_Time_ASIC[i].Text);
                        txtReport.AppendText(report);
                    }
                    else
                    {
                        MessageBox.Show("Set Internal RAZ Mode failed. Please check USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                    }
                    #endregion
                    #region 4bitDAC Cali
                    string DCCaliFileName, SCTCaliFileName;
                    StreamReader DCCaliFile, SCTCaliFile;
                    DCCaliFileName = string.Format("D:\\ExperimentsData\\test\\DCCali{0}.txt", i);
                    SCTCaliFileName = string.Format("D:\\ExperimentsData\\test\\SCTCali{0}.txt", i);
                    DCCaliFile = File.OpenText(DCCaliFileName);
                    SCTCaliFile = File.OpenText(SCTCaliFileName);
                    switch(cbxPedCali_ASIC[i].SelectedIndex)
                    {
                        case 0:
                            for (int j = 0; j < 64; j++)
                            {
                                CaliData[j] = 0;
                            }
                            break;
                        case 1:
                            for (int j = 0; j < 64; j++)
                            {
                                DCCaliString = DCCaliFile.ReadLine();
                                CaliData[j] = byte.Parse(DCCaliString);
                            }                            
                            break;
                        case 2:
                            for (int j = 0; j < 64; j++)
                            {
                                SCTCaliString = SCTCaliFile.ReadLine();
                                CaliData[j] = byte.Parse(SCTCaliString);
                            }
                            break;
                        default:
                            for (int j = 0; j < 64; j++)
                            {
                                CaliData[j] = 0;
                            }
                            break;
                    }
                    for (int j = 0; j < 64; j++)
                    {
                        CaliByte1 = (byte)(CommandHeader[j] >> 4 + 0xC0);
                        CaliByte2 = (byte)(CommandHeader[j] << 4 + CaliData[j]);
                        CommandBytes = ConstCommandByteArray(CaliByte1, CaliByte2);
                        bResult = CommandSend(CommandBytes, CommandBytes.Length);
                        if(bResult)
                        {
                            details.AppendFormat("{0},4-bitDAC:{1}\n", Chn[j], CaliData[j]);
                        }
                        else
                        {
                            MessageBox.Show("4bit-DAC Cali faliure. Please check USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                        }
                        Thread.Sleep(10);
                    }
                    if (cbxPedCali_ASIC[i].SelectedIndex != 0)
                        txtReport.AppendText(details.ToString());
                    else
                        txtReport.AppendText("All channels without calibration\n");

                    /*TempHashTabel = CaliHashTable[i];
                    foreach(string str in TempHashTabel.Keys)
                    {
                        PedCali_Param = (byte[])TempHashTabel[str];
                        PedCali_Byte1 = (byte)(PedCali_Param[0] >> 4 + 0xC0);
                        PedCali_Byte2 = (byte)(PedCali_Param[0] << 4 + PedCali_Param[1]);
                        CommandBytes = ConstCommandByteArray(PedCali_Byte1, PedCali_Byte2);
                        bResult = CommandSend(CommandBytes, CommandBytes.Length);
                        if(bResult)
                        {
                            details.AppendFormat("{0}, 4-bitDAC: {1}\n", str, PedCali_Param[1]);
                        }
                        else
                        {
                            MessageBox.Show("4bit-DAC Cali faliure. Please check USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                        }
                        Thread.Sleep(10);
                    }
                    if(cbxPedCali_ASIC[i].SelectedIndex == 0)
                        txtReport.AppendText(details.ToString());
                    else
                        txtReport.AppendText("All channels without calibration\n");*/
                    #endregion
                    #region Start Load
                    CommandBytes = ConstCommandByteArray(0xD0, 0xA2);
                    bResult = CommandSend(CommandBytes, CommandBytes.Length);
                    if (bResult)
                    {
                        string report = string.Format("Load No.{0} ASIC parameter done!\n",i+1);
                        txtReport.AppendText(report);
                    }
                    else
                    {
                        MessageBox.Show("Load parameter failure, please check USB", //text
                                         "USB Error",   //caption
                                         MessageBoxButton.OK,//button
                                         MessageBoxImage.Error);//icon
                    }
                    #endregion
                    //Sleep 100ms to wait load done
                    Thread.Sleep(100);
                }
                #region Old Code
                /*bool Is_DAC_legal = rx_int.IsMatch(txtDAC0_VTH.Text) && rx_int.IsMatch(txtDAC1_VTH.Text) && rx_int.IsMatch(txtDAC2_VTH.Text);
                if (Is_DAC_legal)
                {
                    int value_DAC0 = Int32.Parse(txtDAC0_VTH.Text) + 49152; //header
                    int value_DAC1 = Int32.Parse(txtDAC1_VTH.Text) + 50176; //header
                    int value_DAC2 = Int32.Parse(txtDAC2_VTH.Text) + 51200; //header
                    //-------------------DAC0-----------------------------//
                    byte[] bytes = ConstCommandByteArray((byte)(value_DAC0 >> 8), (byte)(value_DAC0));
                    bResult = CommandSend(bytes, bytes.Length);
                    if (bResult)
                    {
                        string report = string.Format("setting DAC0 VTH: {0}\n", txtDAC0_VTH.Text);
                        txtReport.AppendText(report);
                    }
                    else
                    {
                        //txtReport.AppendText("set DAC0 failure, please check USB\n");
                        MessageBox.Show("set DAC0 failure, please check USB", //text
                                         "USB Error",   //caption
                                         MessageBoxButton.OK,//button
                                         MessageBoxImage.Error);//icon
                    }
                    //------------------DAC1-----------------------------------//
                    bytes = ConstCommandByteArray((byte)(value_DAC1 >> 8), (byte)(value_DAC1));
                    bResult = CommandSend(bytes, bytes.Length);
                    if (bResult)
                    {
                        string report = string.Format("setting DAC1 VTH: {0}\n", txtDAC1_VTH.Text);
                        txtReport.AppendText(report);
                    }
                    else
                    {
                        //txtReport.AppendText("set DAC1 failure, please check USB\n");
                        MessageBox.Show("set DAC1 failure, please check USB", //text
                                         "USB Error",   //caption
                                         MessageBoxButton.OK,//button
                                         MessageBoxImage.Error);//icon
                    }
                    //-----------------DAC2------------------------------------//
                    bytes = ConstCommandByteArray((byte)(value_DAC2 >> 8), (byte)(value_DAC2));
                    bResult = CommandSend(bytes, bytes.Length);
                    if (bResult)
                    {
                        string report = string.Format("setting DAC2 VTH: {0}\n", txtDAC2_VTH.Text);
                        txtReport.AppendText(report);
                    }
                    else
                    {
                        //txtReport.AppendText("set DAC2 failure, please check USB\n");
                        MessageBox.Show("set DAC0 failure, please check USB", //text
                                         "USB Error",   //caption
                                         MessageBoxButton.OK,//button
                                         MessageBoxImage.Error);//icon
                    }
                }
                else
                {
                    MessageBox.Show("DAC value is illegal,please re-type(Integer:0--1023)", //text
                    "Illegal input",   //caption
                    MessageBoxButton.OK,//button
                    MessageBoxImage.Error);//icon
                }*/
                //*************** Header**********************//
                /*Regex rx_b = new Regex(rx_Byte);
                bool Is_header_legal = rx_b.IsMatch(txtHeader.Text);
                if (Is_header_legal)
                {
                    byte[] Header_value = new byte[1];
                    Header_value = HexStringToByteArray(txtHeader.Text.Trim());
                    byte[] bytes = new byte[2];
                    bytes = ConstCommandByteArray(0xAB, Header_value[0]);
                    bResult = CommandSend(bytes, bytes.Length);
                    if (bResult)
                    {
                        string report = string.Format("setting Header: 0x{0}\n", txtHeader.Text.Trim());
                        txtReport.AppendText(report);
                    }
                    else
                    {
                        MessageBox.Show("set header failure, please check USB", //text
                                         "USB Error",   //caption
                                         MessageBoxButton.OK,//button
                                         MessageBoxImage.Error);//icon
                    }
                }
                else
                {
                    MessageBox.Show("header value is illegal,please re-type(Hex:AA(eg))", //text
                  "Illegal input",   //caption
                  MessageBoxButton.OK,//button
                  MessageBoxImage.Error);//icon                     
                }*/

                /*-------------CText--------------*/
                /*bool Is_Ctest_legal = rx_int.IsMatch(txtCTest.Text);
                if (Is_Ctest_legal)
                {
                    int value_Ctest = Int32.Parse(txtCTest.Text) + 41216; //header
                    byte[] bytes = ConstCommandByteArray((byte)(value_Ctest >> 8), (byte)(value_Ctest));
                    bResult = CommandSend(bytes, bytes.Length);
                    if (bResult)
                    {
                        string report = string.Format("setting CTest channel: {0}\n", txtCTest.Text);
                        txtReport.AppendText(report);
                    }
                    else
                    {
                        //txtReport.AppendText("set DAC0 failure, please check USB\n");
                        MessageBox.Show("set Ctest failure, please check USB", //text
                                         "USB Error",   //caption
                                         MessageBoxButton.OK,//button
                                         MessageBoxImage.Error);//icon
                    }
                }
                else
                {
                    MessageBox.Show("Ctest value is illegal,please re-type(Integer:0--64,or 255)", //text
                  "Illegal input",   //caption
                  MessageBoxButton.OK,//button
                  MessageBoxImage.Error);//icon  
                }*/
                //------------------sw_hg and sw_lg---------------------------//
                /*int value_hg = cbxsw_hg.SelectedIndex * 16;
                int value_lg = cbxsw_lg.SelectedIndex;
                int value_sw = value_hg + value_lg; //B3              
                byte[] sw_bytes = ConstCommandByteArray(0xB3, (byte)(value_sw));
                bResult = CommandSend(sw_bytes, sw_bytes.Length);
                if (bResult)
                {
                    string report = string.Format("set sw_hg: {0}; sw_lg: {1}\n", cbxsw_hg.Text,cbxsw_lg.Text);
                    txtReport.AppendText(report);
                }
                else
                {
                    MessageBox.Show("set sw_hg and sw_lg failure, please check USB", //text
                                     "USB Error",   //caption
                                     MessageBoxButton.OK,//button
                                     MessageBoxImage.Error);//icon
                }*/
                //-----------------Out_sh, high gain shaper or low gain shaper-----------//
                /*int value_out_sh = cbxOut_sh.SelectedIndex + 192; //要不要加1？
                byte [] bytes_sh = ConstCommandByteArray(0xA0, (byte)(value_out_sh));
                bResult = CommandSend(bytes_sh, bytes_sh.Length);
                if (bResult)
                {
                    string report = string.Format("shape output: {0}\n", cbxOut_sh.Text);
                    txtReport.AppendText(report);
                }
                else
                {
                    MessageBox.Show("set shape output failure, please check USB", //text
                                     "USB Error",   //caption
                                     MessageBoxButton.OK,//button
                                     MessageBoxImage.Error);//icon
                }*/
                //------------------Internal RAZ Mode Select ----------------------------//
                /*int value_Internal_RAZ_Time = cbxInternal_RAZ_Time.SelectedIndex + 176;//0xB0
                byte[] bytes_Internal_RAZ_Time = ConstCommandByteArray(0xA8, (byte)value_Internal_RAZ_Time);
                bResult = CommandSend(bytes_Internal_RAZ_Time, bytes_Internal_RAZ_Time.Length);
                if(bResult)
                {
                    string report = string.Format("Internal RAZ Mode: {0} \n", cbxInternal_RAZ_Time.Text);
                    txtReport.AppendText(report);
                }
                else
                {
                    MessageBox.Show("Set Internal RAZ Mode failed, please check USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                }*/
                //----------------------- Select shaper output enable --------------------//
                /*int value_Shaper_Output_Enable = cbxShaper_Output_Enable.SelectedIndex + 208;
                byte[] bytes_Shaper_Output_Enable = ConstCommandByteArray(0xA0, (byte)value_Shaper_Output_Enable);
                bResult = CommandSend(bytes_Shaper_Output_Enable, bytes_Shaper_Output_Enable.Length);
                if(bResult)
                {
                    string report = string.Format("You have {0} the shaper output", cbxShaper_Output_Enable.Text);
                    txtReport.AppendText(report);
                }
                else
                {
                    MessageBox.Show("Set shaper state failure. Please check the USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                }*/
                #endregion
            }
            #endregion
            #region Read Reg
            //-----if there is Read Register opertation
            else if ((string)btnSC_or_ReadReg.Content == "Read Register")
            {
                TextBox[] txtRead_reg_ASIC = new TextBox[4] { txtRead_reg_ASIC1, txtRead_reg_ASIC2, txtRead_reg_ASIC3, txtRead_reg_ASIC4 };
                Regex rx_int = new Regex(rx_Integer);
                bool Is_ReadReg_legal = false;
                int ReadReg_Value;
                byte[] Command_Bytes = new byte[2];
                for(int i = ASIC_Number;i>= 0; i--)
                {
                    #region Set ReadReg
                    Is_ReadReg_legal = rx_int.IsMatch(txtRead_reg_ASIC[i].Text);
                    if(Is_ReadReg_legal)
                    {
                        ReadReg_Value = Int32.Parse(txtRead_reg_ASIC[i].Text) + 41472;//0xA200
                        Command_Bytes = ConstCommandByteArray((byte)(ReadReg_Value >> 8), (byte)ReadReg_Value);
                        bResult = CommandSend(Command_Bytes, Command_Bytes.Length);
                        if (bResult)
                        {
                            string report = string.Format("Setting ReadReg channel: {0}\n", txtRead_reg_ASIC[i].Text);
                            txtReport.AppendText(report);
                        }
                        else
                        {
                            MessageBox.Show("Set ReadReg failure. Please check USB", //text
                                             "USB Error",   //caption
                                             MessageBoxButton.OK,//button
                                             MessageBoxImage.Error);//icon
                        }
                    }
                    else
                    {
                        MessageBox.Show("ReadReg value is illegal,please re-type(Integer:0--64)", //text
                  "Illegal input",   //caption
                  MessageBoxButton.OK,//button
                  MessageBoxImage.Error);//icon 
                    }
                    #endregion
                    #region Start Load
                    Command_Bytes = ConstCommandByteArray(0xD0, 0xA2);
                    bResult = CommandSend(Command_Bytes, Command_Bytes.Length);
                    if (bResult)
                    {
                        string report = string.Format("Load No.{0} ASIC parameter done!\n", i + 1);
                        txtReport.AppendText(report);
                    }
                    else
                    {
                        MessageBox.Show("Load parameter failure, please check USB", //text
                                         "USB Error",   //caption
                                         MessageBoxButton.OK,//button
                                         MessageBoxImage.Error);//icon
                    }
                    #endregion
                    //Sleep 100ms to wait load done
                    Thread.Sleep(100);
                }                
                #region Old Code
                /*if (Is_ReadReg_legal)
                {
                    int value_ReadReg = Int32.Parse(txtRead_reg.Text) + 41472; //header
                    byte[] bytes = ConstCommandByteArray((byte)(value_ReadReg >> 8), (byte)(value_ReadReg));
                    bResult = CommandSend(bytes, bytes.Length);
                    if (bResult)
                    {
                        string report = string.Format("setting ReadReg channel: {0}\n", txtRead_reg.Text);
                        txtReport.AppendText(report);
                    }
                    else
                    {
                        MessageBox.Show("set ReadReg failure, please check USB", //text
                                         "USB Error",   //caption
                                         MessageBoxButton.OK,//button
                                         MessageBoxImage.Error);//icon
                    }
                }
                else
                {
                    MessageBox.Show("ReadReg value is illegal,please re-type(Integer:0--64)", //text
                  "Illegal input",   //caption
                  MessageBoxButton.OK,//button
                  MessageBoxImage.Error);//icon  
                }*/
                #endregion
            }
            #endregion
            #region Old Code
            //---start load
            /*com_bytes = ConstCommandByteArray(0xD0, 0xA2);
                bResult = CommandSend(com_bytes, com_bytes.Length);
                if (bResult)
                {
                    txtReport.AppendText("Load parameter done!\n");
                }
                else
                {
                    MessageBox.Show("Load parameter failure, please check USB", //text
                                     "USB Error",   //caption
                                     MessageBoxButton.OK,//button
                                     MessageBoxImage.Error);//icon
                }*/
            #endregion
        }

        private void PowerPulsing_Checked(object sender, RoutedEventArgs e)
        {
            //Get Radiobutton reference
            var button = sender as RadioButton;
            //Display button content as title
            bool bResult = false;
            if (button.Content.ToString() == "Enable")
            {
                byte[] bytes = ConstCommandByteArray(0xA3, 0xA1);
                //bResult = false;
                bResult = CommandSend(bytes, bytes.Length);
                if (bResult)
                {
                    txtReport.AppendText("PowerPulsing Enabed\n");
                }
                else
                {
                    // txtReport.AppendText("select failure, please check USB\n");
                    MessageBox.Show("Powerpulsing set failed, please check USB", //text
                                     "USB Error",   //caption
                                     MessageBoxButton.OK,//button
                                     MessageBoxImage.Error);//icon
                }
            }
            else if (button.Content.ToString() == "Disable")
            {
                byte[] bytes = ConstCommandByteArray(0xA3, 0xA0);
                //bResult = false;
                bResult = CommandSend(bytes, bytes.Length);
                if (bResult)
                {
                    txtReport.AppendText("PowerPulsing Disabled\n");
                }
                else
                {
                    MessageBox.Show("Powerpulsing set failed, please check USB", //text
                                     "USB Error",   //caption
                                     MessageBoxButton.OK,//button
                                     MessageBoxImage.Error);//icon
                }
            }
        }
        //ChannelSelect_Checked
        private void ChannelSelect_Checked(object sender, RoutedEventArgs e)
        {
            //Get Radiobutton reference
            var button = sender as RadioButton;
            //Display button content as title
            bool bResult = false;
            if (button.Content.ToString() == "Channel1")
            {
                byte[] bytes = ConstCommandByteArray(0xA4, 0xA1);
                //bResult = false;
                bResult = CommandSend(bytes, bytes.Length);
                if (bResult)
                {
                    txtReport.AppendText("Channel1 Selected\n");
                }
                else
                {
                    // txtReport.AppendText("select failure, please check USB\n");
                    MessageBox.Show("Channel set failed, please check USB", //text
                                     "USB Error",   //caption
                                     MessageBoxButton.OK,//button
                                     MessageBoxImage.Error);//icon
                }
            }
            else if (button.Content.ToString() == "Channel2")
            {
                byte[] bytes = ConstCommandByteArray(0xA4, 0xA0);
                //bResult = false;
                bResult = CommandSend(bytes, bytes.Length);
                if (bResult)
                {
                    txtReport.AppendText("Channel2 Selected\n");
                }
                else
                {
                    //txtReport.AppendText("select failure, please check USB\n");
                    MessageBox.Show("Channel set failed, please check USB", //text
                                     "USB Error",   //caption
                                     MessageBoxButton.OK,//button
                                     MessageBoxImage.Error);//icon
                }
            }
        }
        //ExternalRAZ_Checked
        private void ExternalRAZ_Checked(object sender, RoutedEventArgs e)
        {
            //Get Radiobutton reference
            var button = sender as RadioButton;
            //Display button content as title
            bool bResult = false;
            if (button.Content.ToString() == "Enable")
            {
                byte[] bytes = ConstCommandByteArray(0xA8, 0xA1);
                //bResult = false;
                bResult = CommandSend(bytes, bytes.Length);
                if (bResult)
                {
                    txtReport.AppendText("External RAZ enabled\n");
                }
                else
                {
                    // txtReport.AppendText("select failure, please check USB\n");
                    MessageBox.Show("External RAZ set failed, please check USB", //text
                                     "USB Error",   //caption
                                     MessageBoxButton.OK,//button
                                     MessageBoxImage.Error);//icon
                }
            }
            else if (button.Content.ToString() == "Disable")
            {
                byte[] bytes = ConstCommandByteArray(0xA8, 0xA0);
                //bResult = false;
                bResult = CommandSend(bytes, bytes.Length);
                if (bResult)
                {
                    txtReport.AppendText("External RAZ Disabled\n");
                }
                else
                {
                    //txtReport.AppendText("select failure, please check USB\n");
                    MessageBox.Show("External RAZ set failed, please check USB", //text
                                     "USB Error",   //caption
                                     MessageBoxButton.OK,//button
                                     MessageBoxImage.Error);//icon
                }
            }
        }
        //Reset tntb
        private void btnReset_cntb_Click(object sender, RoutedEventArgs e)
        {
            byte[] bytes = ConstCommandByteArray(0xA7, 0xA1);
            bool bResult = CommandSend(bytes, bytes.Length);
            if (bResult)
            {
                txtReport.AppendText("Reset 24-bit cntb\n");
            }
            else
            {
                MessageBox.Show("Reset cntb failed, please check USB", //text
                                  "USB Error",   //caption
                                  MessageBoxButton.OK,//button
                                  MessageBoxImage.Error);//icon
            }
        }
        //external force trigger 
        private void btnTRIG_EXT_EN_Click(object sender, RoutedEventArgs e)
        {
            byte[] bytes = new byte[2];
            bool bResult = false;
            if (Enabled_Ext_Trigger == false) //open
            {
                Enabled_Ext_Trigger = true;
                btnTRIG_EXT_EN.Background = Brushes.DeepPink;
                bytes = ConstCommandByteArray(0xA9, 0xA1);
                bResult = CommandSend(bytes, bytes.Length);
                if (bResult)
                {
                    txtReport.AppendText("Enable force trigger\n");
                }
                else
                {
                    MessageBox.Show("Enable force trigger failed, please check USB", //text
                                      "USB Error",   //caption
                                      MessageBoxButton.OK,//button
                                      MessageBoxImage.Error);//icon
                }
            }
            else
            {
                Enabled_Ext_Trigger = false;
                btnTRIG_EXT_EN.Background = Brushes.Green;
                bytes = ConstCommandByteArray(0xA9, 0xA0);
                bResult = CommandSend(bytes, bytes.Length);
                if (bResult)
                {
                    txtReport.AppendText("Disable force trigger\n");
                }
                else
                {
                    MessageBox.Show("Disable force trigger failed, please check USB", //text
                                      "USB Error",   //caption
                                      MessageBoxButton.OK,//button
                                      MessageBoxImage.Error);//icon
                }
            }
        }
        //RAZ width
        private void btnSet_Raz_Width_Click(object sender, RoutedEventArgs e)
        {
            int value = cbxRaz_mode.SelectedIndex + 192;//0xC0
            byte[] bytes = new byte[2];
            bytes = ConstCommandByteArray(0xA8, (byte)(value));
            bool bResult = CommandSend(bytes, bytes.Length);
            if (bResult)
            {
                string report = string.Format("External RAZ Width : {0}\n", cbxRaz_mode.Text);
                txtReport.AppendText(report);
            }
            else
            {
                MessageBox.Show("set Raz width failure, please check USB", //text
                                 "USB Error",   //caption
                                 MessageBoxButton.OK,//button
                                 MessageBoxImage.Error);//icon
            }
        }
        //hold generation
        private void btnSet_Hold_Click(object sender, RoutedEventArgs e)
        {
            bool bResult;
            byte[] CommandBytes = new byte[2];
            Regex rx_int = new Regex(rx_Integer);
            #region Set Hold Delay
            bool Is_Hold_legal = rx_int.IsMatch(txtHold_delay.Text) && int.Parse(txtHold_delay.Text) < 800;
            if (Is_Hold_legal)
            {
                int DelayTime = (int)(int.Parse(txtHold_delay.Text)/6.25); //除以6.25ns
                byte DelayTime1 = (byte)(DelayTime & 15);//15 = 0xF
                byte DelayTime2 = (byte)(((DelayTime >> 4) & 15) | 16);//16 = 0x10
                CommandBytes = ConstCommandByteArray(0xA6, DelayTime1);
                bResult = CommandSend(CommandBytes, CommandBytes.Length);
                if (!bResult)
                {
                    MessageBox.Show("Set Hold delay failure, please check USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                    return;
                }
                CommandBytes = ConstCommandByteArray(0xA6, DelayTime2);
                bResult = CommandSend(CommandBytes, CommandBytes.Length);
                if(bResult)
                {
                    string report = string.Format("Set Hold Delay Time:{0}ns\n", DelayTime * 6.25);
                    txtReport.AppendText(report);
                }
                else
                {
                    MessageBox.Show("Set Hold delay failure, please check USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                    return;
                }                
            }
            else
            {
                MessageBox.Show("Illegal Hold delay, please re-type(Integer:0--650,step:2ns)","Illegal input",MessageBoxButton.OK,MessageBoxImage.Error);
                return;
            }
            #endregion
            #region Set Trig Coincide
            int TrigCoincid = cbxTrig_Coincid.SelectedIndex + 160;//160 = 0xA0
            CommandBytes = ConstCommandByteArray(0xA5, (byte)TrigCoincid);
            bResult = CommandSend(CommandBytes, CommandBytes.Length);
            if (bResult)
            {
                string report = string.Format("Set Trigger Coincidence : {0}\n", cbxTrig_Coincid.Text);
                txtReport.AppendText(report);
            }
            else
            {
                MessageBox.Show("Set Trigger Coincid failure, please check USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                return;
            }
            #endregion
            #region Set Hold Time
            /*
                + 4Y:HoldTime[3:0]
                + 5Y:HoldTime[7:4]
                + 6Y:HoldTime[11:8]
                + 7Y:HoldTime[15:12]
             */
            bool IsHoldTimeLegal = rx_int.IsMatch(txtHoldTime.Text) && int.Parse(txtHoldTime.Text) < 10000;
            if(IsHoldTimeLegal)
            {
                int HoldTime = int.Parse(txtHoldTime.Text) / 25;
                int HoldTime1 = (HoldTime & 15) + 64;//0x40
                int HoldTime2 = ((HoldTime >> 4) & 15) + 80;//0x50
                int HoldTime3 = ((HoldTime >> 8) & 15) + 96;
                int HoldTime4 = ((HoldTime >> 12) & 15) + 112;
                CommandBytes = ConstCommandByteArray(0xA6, (byte)HoldTime1);
                bResult = CommandSend(CommandBytes, CommandBytes.Length);
                if(!bResult)
                {
                    MessageBox.Show("Set Hold Time failure, please check USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                    return;
                }
                CommandBytes = ConstCommandByteArray(0xA6, (byte)HoldTime2);
                bResult = CommandSend(CommandBytes, CommandBytes.Length);
                if (!bResult)
                {
                    MessageBox.Show("Set Hold Time failure, please check USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                    return;
                }
                CommandBytes = ConstCommandByteArray(0xA6, (byte)HoldTime3);
                bResult = CommandSend(CommandBytes, CommandBytes.Length);
                if (!bResult)
                {
                    MessageBox.Show("Set Hold Time failure, please check USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                    return;
                }
                CommandBytes = ConstCommandByteArray(0xA6, (byte)HoldTime4);
                bResult = CommandSend(CommandBytes, CommandBytes.Length);
                if (bResult)
                {
                    string report = string.Format("Set Hold Time:{0}\n", HoldTime * 25);
                    txtReport.AppendText(report);
                }
                else
                {
                    MessageBox.Show("Set Hold Time failure, please check USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                    return;
                }
            }
            else
            {
                MessageBox.Show("Illegal Hold Time, please re-type(Integer:0--10000,step:2ns)", "Illegal input", MessageBoxButton.OK, MessageBoxImage.Error);
                return;
            }
            #endregion
            #region Hold Enable
            int HoldEnable = cbxHoldEnable.SelectedIndex + 176; // 176 = 0xB0
            CommandBytes = ConstCommandByteArray(0xA5, (byte)HoldEnable);
            bResult = CommandSend(CommandBytes, CommandBytes.Length);
            if(bResult)
            {
                string report = string.Format("Hold {0}\n", cbxHoldEnable.Text);
                txtReport.AppendText(report);
            }
            else
            {
                MessageBox.Show("Set Hold Time failure, please check USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                return;
            }
            #endregion
        }
        //Set StartAcq Time
        private void btnSetAcqTime_Click(object sender, RoutedEventArgs e)
        {
            Regex rx_int = new Regex(rx_Integer);
            bool Is_Time_legal = rx_int.IsMatch(txtStartAcqTime.Text);
            if (Is_Time_legal)
            {
                int value = Int32.Parse(txtStartAcqTime.Text) / 25; //除以25ns 
                byte[] bytes = ConstCommandByteArray(0xB2, (byte)(value >> 8));
                bool bResult = CommandSend(bytes, bytes.Length);
                if (!bResult)
                {
                    MessageBox.Show("Set StartAcq time failure, please check USB", //text
                                     "USB Error",   //caption
                                     MessageBoxButton.OK,//button
                                     MessageBoxImage.Error);//icon
                }
                bytes = ConstCommandByteArray(0xB1, (byte)(value));
                bResult = CommandSend(bytes, bytes.Length);
                if (bResult)
                {
                    string report = string.Format("Set StartAcq time : {0}\n", txtStartAcqTime.Text);
                    txtReport.AppendText(report);
                }
                else
                {
                    MessageBox.Show("Set StartAcq time failure, please check USB", //text
                                     "USB Error",   //caption
                                     MessageBoxButton.OK,//button
                                     MessageBoxImage.Error);//icon
                }
            }
            else
            {
                MessageBox.Show("Illegal StartAcq Time, please re-type(Integer:0--1638400,step:25ns)", //text
                                 "Illegal input",   //caption
                                 MessageBoxButton.OK,//button
                                 MessageBoxImage.Error);//icon
            }
        }
        //Set which ASIC OUT_T&H output
        private void btnOut_th_set_Click(object sender, RoutedEventArgs e)
        {
            int value = cbxOut_th.SelectedIndex + 176;
            byte[] bytes = new byte[2];
            bytes = ConstCommandByteArray(0xD1, (byte)(value));
            bool bResult = CommandSend(bytes, bytes.Length);
            if (bResult)
            {
                string report = string.Format("Select {0} Out_T&H\n", cbxOut_th.Text);
                txtReport.AppendText(report);
            }
            else
            {
                MessageBox.Show("Select Out_T&H faliure, please check USB", //text
                                 "USB Error",   //caption
                                 MessageBoxButton.OK,//button
                                 MessageBoxImage.Error);//icon
            }
        }
        //RAZ Channel Select
        private void RAZ_Chn_Select_Checked(object sender, RoutedEventArgs e)
        {
            //Get Radiobuttom reference
            var button = sender as RadioButton;
            //Display button content as title
            bool bResult = false;
            if(button.Content.ToString() == "Internal")
            {
                byte[] bytes = ConstCommandByteArray(0xA8,0xA0);
                bResult = CommandSend(bytes,bytes.Length);
                if (bResult)
                {
                    txtReport.AppendText("Internal RAZ Channel Enable \n");
                }
                else
                {
                    MessageBox.Show("Fail to set internal RAZ Channel, please check the USB \n","USB Error",MessageBoxButton.OK, MessageBoxImage.Error);
                }
            }
            else if(button.Content.ToString() == "External")
            {
                byte[] bytes = ConstCommandByteArray(0xA8, 0xA1);
                bResult = CommandSend(bytes, bytes.Length);
                if(bResult)
                {
                    txtReport.AppendText("External RAZ Channel Enable \n");
                }
                else
                {
                    MessageBox.Show("Fail to set external RAZ Channel, please check the USB \n", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                }
            }                    
        }
        //设定EXT_RAZ延迟A8XX
        private void btnSet_External_RAZ_Delay_Click(object sender, RoutedEventArgs e)
        {
            Regex rx_int = new Regex(rx_Integer);
            bool Is_Time_Legel = rx_int.IsMatch(txtExternal_RAZ_Delay.Text) && int.Parse(txtExternal_RAZ_Delay.Text) < 400;
            if(Is_Time_Legel)
            {
                int ExternalRazDelay = short.Parse(txtExternal_RAZ_Delay.Text) / 25 + 208;//208 = 0xD0
                byte[] CommandBytes = new byte[2];
                CommandBytes = ConstCommandByteArray(0xA8, (byte)ExternalRazDelay);
                bool bResult = CommandSend(CommandBytes, CommandBytes.Length);
                if(bResult)
                {
                    string report = string.Format("Set External RAZ Delay time:{0} ns\n", txtExternal_RAZ_Delay.Text);
                }
                else
                {
                    MessageBox.Show("select failure, please check USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                }
                
            }
            else
            {
                MessageBox.Show("Illegal External RAZ Delay Time, please re-type(Integer:0--400ns,step:25ns)", "Ilegal Input", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }
        
        // Select Trigger efficiency test or counter efficiency test
        private void Trig_or_Count_Checked(object sender, RoutedEventArgs e)
        {
            var button = sender as RadioButton;
            bool bResult = false;
            byte[] CommandBytes = new byte[2];
            if(button.Content.ToString() == "Trig")
            {
                cbxCPT_MAX.IsEnabled = true;
                txtCountTime.IsEnabled = false;
                CommandBytes = ConstCommandByteArray(0xE0, 0xD0);
                SCurveMode = Trig;
                bResult = CommandSend(CommandBytes, CommandBytes.Length);
                if (bResult)
                {
                    txtReport.AppendText("You are testing Trigger-Efficiency\n");
                }
                else
                {
                    // txtReport.AppendText("select failure, please check USB\n");
                    MessageBox.Show("select failure, please check USB", //text
                                     "USB Error",   //caption
                                     MessageBoxButton.OK,//button
                                     MessageBoxImage.Error);//icon
                }
            }
            else if(button.Content.ToString() == "Count")
            {
                txtCountTime.IsEnabled = true;
                cbxCPT_MAX.IsEnabled = false;
                CommandBytes = ConstCommandByteArray(0xE0, 0xD1);
                SCurveMode = Count;
                bResult = CommandSend(CommandBytes, CommandBytes.Length);
                if (bResult)
                {
                    txtReport.AppendText("You are testing Counter-Efficiency\n");
                }
                else
                {
                    // txtReport.AppendText("select failure, please check USB\n");
                    MessageBox.Show("select failure, please check USB", //text
                                     "USB Error",   //caption
                                     MessageBoxButton.OK,//button
                                     MessageBoxImage.Error);//icon
                }
            }
        }

        private void DataRateSelect_Checked(object sender, RoutedEventArgs e)
        {
            var button = sender as RadioButton;
            //bool bResult = false;
            //byte[] CommandBytes = new byte[2];
            if(button.Content.ToString() == "Fast")
            {
                btnAcqStart.IsEnabled = true;
                btnSlowACQ.IsEnabled = false;
                txtSlowACQDataNum.IsEnabled = false;
                txtReport.AppendText("Set fast data rate acq\n");              
            }
            else if(button.Content.ToString() == "Slow")
            {
                btnAcqStart.IsEnabled = false;
                btnSlowACQ.IsEnabled = true;
                txtSlowACQDataNum.IsEnabled = true;
                Regex rx_int = new Regex(rx_Integer);
                bool Is_DataNum_Legal = rx_int.IsMatch(txtSlowACQDataNum.Text);
                if(Is_DataNum_Legal)
                {
                    SlowACQDataNumber = Int16.Parse(txtSlowACQDataNum.Text);
                    string report = string.Format("Set slow data rate ACQ. Max data package: {0}\n", txtSlowACQDataNum.Text);
                    txtReport.AppendText(report);
                }
                else
                {
                    MessageBox.Show("Ilegal input the Data Package Num must be Int\n", "Ilegal Input", MessageBoxButton.OK, MessageBoxImage.Error);
                }                
            }
        }
        // Slow data rate ACQ
        private async void btnSlowACQ_Click(object sender, RoutedEventArgs e)
        {            
            if (filepath == null || string.IsNullOrEmpty(filepath.Trim()))
            {
                MessageBox.Show("You should save the file first before Scurve start", //text
                                        "imformation", //caption
                                   MessageBoxButton.OK, //button
                                    MessageBoxImage.Error);//icon     
            }
            else //file is exsits
            {
                #region Start Slow Acq
                if (!IsSlowAcqStart)
                {
                    bool bResult;
                    #region Set Start Acq Time
                    Regex rx_int = new Regex(rx_Integer);
                    bool Is_Time_legal = rx_int.IsMatch(txtStartAcqTime.Text);
                    if (Is_Time_legal)
                    {
                        int value = Int32.Parse(txtStartAcqTime.Text) / 25; //除以25ns 
                        byte[] CmdSetStartTimeBytes = ConstCommandByteArray(0xB2, (byte)(value >> 8));
                        bResult = CommandSend(CmdSetStartTimeBytes, CmdSetStartTimeBytes.Length);
                        if (!bResult)
                        {
                            MessageBox.Show("Set StartAcq time failure, please check USB", //text
                                             "USB Error",   //caption
                                             MessageBoxButton.OK,//button
                                             MessageBoxImage.Error);//icon
                            return;
                        }
                        CmdSetStartTimeBytes = ConstCommandByteArray(0xB1, (byte)(value));
                        bResult = CommandSend(CmdSetStartTimeBytes, CmdSetStartTimeBytes.Length);
                        if (bResult)
                        {
                            string report = string.Format("Set StartAcq time : {0}\n", txtStartAcqTime.Text);
                            txtReport.AppendText(report);
                        }
                        else
                        {
                            MessageBox.Show("Set StartAcq time failure, please check USB", //text
                                             "USB Error",   //caption
                                             MessageBoxButton.OK,//button
                                             MessageBoxImage.Error);//icon
                            return;
                        }
                    }
                    else
                    {
                        MessageBox.Show("Illegal StartAcq Time, please re-type(Integer:0--1638400,step:25ns)", //text
                                         "Illegal input",   //caption
                                         MessageBoxButton.OK,//button
                                         MessageBoxImage.Error);//icon
                        return;
                    }
                    #endregion
                    #region Set End Hold Time
                    if (DaqMode == SlaveDaq)
                    {
                        byte[] CommandBytes = new byte[2];
                        bool IsEndHoldTimeLegal = rx_int.IsMatch(txtEndHoldTime.Text) && (int.Parse(txtEndHoldTime.Text) < 65536);
                        if (IsEndHoldTimeLegal)
                        {
                            int EndHoldTime = int.Parse(txtEndHoldTime.Text);
                            int EndHoldTime1 = (EndHoldTime & 15) + 64;//0x40
                            int EndHoldTime2 = ((EndHoldTime >> 4) & 15) + 80;//0x50
                            int EndHoldTime3 = ((EndHoldTime >> 8) & 15) + 96;//0x60
                            int EndHoldTime4 = ((EndHoldTime >> 12) & 15) + 112;//0x70
                            CommandBytes = ConstCommandByteArray(0xE8, (byte)EndHoldTime1);
                            bResult = CommandSend(CommandBytes, CommandBytes.Length);
                            if (!bResult)
                            {
                                MessageBox.Show("Set End Hold Time Failure, please check USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                                return;
                            }
                            CommandBytes = ConstCommandByteArray(0xE8, (byte)EndHoldTime2);
                            bResult = CommandSend(CommandBytes, CommandBytes.Length);
                            if (!bResult)
                            {
                                MessageBox.Show("Set End Hold Time Failure, please check USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                                return;
                            }
                            CommandBytes = ConstCommandByteArray(0xE0, (byte)EndHoldTime3);
                            bResult = CommandSend(CommandBytes, CommandBytes.Length);
                            if (!bResult)
                            {
                                MessageBox.Show("Set End Hold Time Failure, please check USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                                return;
                            }
                            CommandBytes = ConstCommandByteArray(0xE0, (byte)EndHoldTime4);
                            bResult = CommandSend(CommandBytes, CommandBytes.Length);
                            if (bResult)
                            {
                                string report = string.Format("Set End Signal Time:{0}\n", EndHoldTime);
                                txtReport.AppendText(report);
                            }
                            else
                            {
                                MessageBox.Show("Set End Hold Time Failure, please check USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                                return;
                            }
                        }
                        else
                        {
                            MessageBox.Show("Illegal End Signal Hold Time, please re-type(Integer:0--1638400,step:25ns)", //text
                                         "Illegal input",   //caption
                                         MessageBoxButton.OK,//button
                                         MessageBoxImage.Error);//icon
                        }
                    }
                    #endregion
                    //Regex rx_int = new Regex(rx_Integer);
                    bool Is_DataNum_Legal = rx_int.IsMatch(txtSlowACQDataNum.Text);
                    
                    if (Is_DataNum_Legal)
                    {
                        SlowACQDataNumber = Int16.Parse(txtSlowACQDataNum.Text);

                    }
                    else
                    {
                        SlowACQDataNumber = 5120;
                    }
                    SlowDataRatePackageNumber = SlowACQDataNumber * 20;
                    #region Clear USB FIFO and Reset Microroc
                    //bool bResult = false;
                    byte[] cmd_ClrUSBFifo = ConstCommandByteArray(0xF0, 0xFA);
                    bResult = CommandSend(cmd_ClrUSBFifo, 2);//
                    if (bResult)
                        txtReport.AppendText("Usb Fifo clear \n");
                    else
                    {
                        MessageBox.Show("USB FIFO Clear Failure", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                        return;
                    }                        
                    byte[] bytes = new byte[2048];
                    bResult = DataRecieve(bytes, bytes.Length);//读空剩余在USB芯片里面的数据
                    byte[] CommandForceMicrorocReset = ConstCommandByteArray(0xF0, 0xF2);
                    bResult = CommandSend(CommandForceMicrorocReset, CommandForceMicrorocReset.Length);
                    if (bResult)
                    {
                        txtReport.AppendText("Microroc Reset");
                    }
                    else
                    {
                        MessageBox.Show("Reset Microroc Failure", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                        return;
                    }
                    #endregion
                    Thread.Sleep(10);
                    byte[] CmdSlowACQ = ConstCommandByteArray(0xF0, 0xF0);
                    bResult = CommandSend(CmdSlowACQ, CmdSlowACQ.Length);
                    if (bResult)
                    {
                        IsSlowAcqStart = true;
                        txtReport.AppendText("Slow data rate ACQ Start\n");
                        txtReport.AppendText("Slow data rate Acq Contunue\n");
                        btnSlowACQ.Content = "Stop";
                        //Task SlowDataRateACQ = new Task(() => GetSlowDataRateResultCallBack());
                        //SlowDataRateACQ.Start();
                        //SlowDataRateACQ.Wait();
                        await Task.Run(() => GetSlowDataRateResultCallBack());               
                        CmdSlowACQ = ConstCommandByteArray(0xF0, 0xF1);
                        bResult = CommandSend(CmdSlowACQ, CmdSlowACQ.Length);
                        if(bResult)
                        {
                            btnSlowACQ.Content = "Slow ACQ";
                            IsSlowAcqStart = false;
                            txtReport.AppendText("Slow data rate Acq Stop\n");
                        }
                        else
                        {
                            txtReport.AppendText("Slow data rate Acq Stop Failure\n");
                        }                                                
                    }
                    else
                    {
                        txtReport.AppendText("Slow data rate ACQ start failure\n");
                    }
                }
                #endregion
                else
                {
                    IsSlowAcqStart = false;
                    byte[] ACQStop = ConstCommandByteArray(0xF0, 0xF1);
                    if (CommandSend(ACQStop, ACQStop.Length))
                    {
                        btnSlowACQ.Content = "Slow ACQ";
                        txtReport.AppendText("Slow data rate ACQ Abort\n");
                    }
                    else
                    {
                        txtReport.AppendText("Slow data rate ACQ Stop failure\n");
                    }
                }
            }
        }

        //E0A0 选择 Normal Acq，E0A1选择SCurve，E0A2选择 Sweep ACQ
        private void ModeSelectChecked(object sender, RoutedEventArgs e)
        {
            var botton = sender as RadioButton;
            bool bResult = false;
            if (botton.Content.ToString() == "ACQ") //这里已经直接将通道都切换过去
            {
                gbxNormalAcq.IsEnabled = true;
                //btnScurve_start.IsEnabled = false;
                gbxSweepTest.IsEnabled = false;
                gbxAD9220.IsEnabled = false;
                DataAcqMode = Acq;
                byte[] bytes = ConstCommandByteArray(0xE0, 0xA0);
                bResult = CommandSend(bytes, bytes.Length);
                if (bResult)
                {
                    txtReport.AppendText("Select ACQ mode\n");
                }
                else
                {
                    MessageBox.Show("Set ACQ Mode Failure. Please check the USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                }
            }
            else if (botton.Content.ToString() == "SCTest")
            {
                //btnAcqStart.IsEnabled = false;
                //btnScurve_start.IsEnabled = true;
                gbxNormalAcq.IsEnabled = false;
                gbxSweepTest.IsEnabled = true;
                gbxSCurveTest.IsEnabled = true;
                gbxSweepAcq.IsEnabled = false;
                gbxAD9220.IsEnabled = false;
                DataAcqMode = SCTest;
                byte[] bytes = ConstCommandByteArray(0xE0, 0xA1);
                bResult = CommandSend(bytes, bytes.Length);
                if (bResult)
                {
                    txtReport.AppendText("Select S Curve Test Mode");
                }
                else
                {
                    MessageBox.Show("Set S Curve Test mode failure. Please check the USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                }
            }
            else if(botton.Content.ToString() == "SweepACQ")
            {
                gbxNormalAcq.IsEnabled = false;
                gbxSweepTest.IsEnabled = true;
                gbxSCurveTest.IsEnabled = false;
                gbxSweepAcq.IsEnabled = true;
                gbxAD9220.IsEnabled = false;
                DataAcqMode = SweepAcq;
                byte[] bytes = ConstCommandByteArray(0xE0, 0xA2);
                bResult = CommandSend(bytes, bytes.Length);
                if(bResult)
                {
                    txtReport.AppendText("Select Sweep Acq mode \n");
                }
                else
                {
                    MessageBox.Show("Set Sweep ACQ Test mode failure. Please check the USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                }
            }
            else if(botton.Content.ToString() == "AD9220")
            {
                gbxNormalAcq.IsEnabled = false;
                gbxSweepTest.IsEnabled = false;
                gbxAD9220.IsEnabled = true;
                DataAcqMode = Adc;
                byte[] CommandBytes = ConstCommandByteArray(0xE0, 0xA3);
                bResult = CommandSend(CommandBytes, CommandBytes.Length);
                if(bResult)
                {
                    txtReport.AppendText("Select AD9220\n");
                }
                else
                {
                    MessageBox.Show("Set AD9220 mode failure. Please check the USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                }
            }
        }

        private void btnSetMask_Click(object sender, RoutedEventArgs e)
        {
            bool bResult = false;
            byte[] CommandBytes = new byte[2];
            string report = null;
            int MaskChoise = cbxMaskOrUnMask.SelectedIndex + 16;
            #region Mask Channel
            Regex rxInt = new Regex(rx_Integer);
            bool IsChannelLegeal = rxInt.IsMatch(txtChannelMask.Text) && (int.Parse(txtChannelMask.Text) <= 64 && (int.Parse(txtChannelMask.Text)) >= 1);
            if(IsChannelLegeal)
            {
                int MaskChannel = short.Parse(txtChannelMask.Text) - 1;
                CommandBytes = ConstCommandByteArray(0xAD, (byte)MaskChannel);
                bResult = CommandSend(CommandBytes, CommandBytes.Length);
                if(bResult)
                {
                    if(MaskChoise != 16)
                    {
                        report = string.Format("Channel{0}", MaskChannel + 1);
                        txtReport.AppendText(report);
                    }                    
                    //txtReport.AppendText(report);
                }
                else
                {
                    MessageBox.Show("Set Mask Channel failure, please check the USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                    return;
                }
            }
            else
            {
                MessageBox.Show("Illegal Mask Channel, please re-type(Integer:1--64)", "Ilegal Input", MessageBoxButton.OK, MessageBoxImage.Error);
                return;
            }
            #endregion
            #region Discri Mask
            int DiscriMask = cbxDiscriMask.SelectedIndex;
            CommandBytes = ConstCommandByteArray(0xAE, (byte)DiscriMask);
            bResult = CommandSend(CommandBytes, CommandBytes.Length);
            if(bResult)
            {
                if(MaskChoise != 16)
                {
                    report = string.Format("{0} \n", cbxDiscriMask.Text);
                    txtReport.AppendText(report);
                }                
            }
            else
            {
                MessageBox.Show("Set Mask Discriminator failure, please check the USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
            #endregion
            #region Mask or not            
            CommandBytes = ConstCommandByteArray(0xAE, (byte)MaskChoise);
            bResult = CommandSend(CommandBytes, CommandBytes.Length);
            if (bResult)
            {
                report = string.Format("{0} ", cbxMaskOrUnMask.Text);
                txtReport.AppendText(report);
            }
            else
            {
                MessageBox.Show("Set Mask Channel failure, please check the USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
            #endregion
        }

        private async void btnSweepTestStart_Click(object sender, RoutedEventArgs e)
        {
            #region Check File Legal
            if (filepath == null || string.IsNullOrEmpty(filepath.Trim()))
            {
                MessageBox.Show("You should save the file first before Scurve start", //text
                                        "imformation", //caption
                                   MessageBoxButton.OK, //button
                                    MessageBoxImage.Error);//icon     
            }
            #endregion
            else
            {
                byte[] CommandBytes = new byte[2];
                bool bResult;
                string report;
                #region Start and End DAC
                Regex rxInt = new Regex(rx_Integer);
                bool IsDacLegal = rxInt.IsMatch(txtStartDac.Text) && rxInt.IsMatch(txtEndDac.Text) && (int.Parse(txtStartDac.Text) < 1023) && (int.Parse(txtEndDac.Text) <= 1023) && (int.Parse(txtStartDac.Text) <= int.Parse(txtEndDac.Text));
                if (IsDacLegal)
                {
                    #region Start DAC
                    uint StartDacValue = uint.Parse(txtStartDac.Text);
                    uint StartDacValue1 = StartDacValue & 15;
                    uint StartDacValue2 = ((StartDacValue >> 4) & 15) + 16;
                    uint StartDacValue3 = ((StartDacValue >> 8) & 3) + 32;
                    CommandBytes = ConstCommandByteArray(0xE5, (byte)StartDacValue1);
                    bResult = CommandSend(CommandBytes, CommandBytes.Length);
                    if (!bResult)
                    {
                        MessageBox.Show("Set StartDAC failure. Please check the USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                    }
                    CommandBytes = ConstCommandByteArray(0xE5, (byte)StartDacValue2);
                    bResult = CommandSend(CommandBytes, CommandBytes.Length);
                    if (!bResult)
                    {
                        MessageBox.Show("Set StartDAC failure. Please check the USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                    }
                    CommandBytes = ConstCommandByteArray(0xE5, (byte)StartDacValue3);
                    bResult = CommandSend(CommandBytes, CommandBytes.Length);
                    if (bResult)
                    {
                        report = string.Format("Set StartDAC:{0}\n", StartDacValue);
                        txtReport.AppendText(report);
                    }
                    else
                    {
                        MessageBox.Show("Set StartDAC failure. Please check the USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                    }
                    #endregion
                    #region EndDAC
                    uint EndDacValue = uint.Parse(txtEndDac.Text);
                    uint EndDacValue1 = (EndDacValue & 15) + 48;
                    uint EndDacValue2 = ((EndDacValue >> 4) & 15) + 64;
                    uint EndDacValue3 = ((EndDacValue >> 8) & 3) + 80;
                    CommandBytes = ConstCommandByteArray(0xE5, (byte)EndDacValue1);
                    bResult = CommandSend(CommandBytes, CommandBytes.Length);
                    if (!bResult)
                    {
                        MessageBox.Show("Set EndDAC failure. Please check the USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                    }
                    CommandBytes = ConstCommandByteArray(0xE5, (byte)EndDacValue2);
                    bResult = CommandSend(CommandBytes, CommandBytes.Length);
                    if (!bResult)
                    {
                        MessageBox.Show("Set EndDAC failure. Please check the USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                    }
                    CommandBytes = ConstCommandByteArray(0xE5, (byte)EndDacValue3);
                    bResult = CommandSend(CommandBytes, CommandBytes.Length);
                    if (bResult)
                    {
                        report = string.Format("Set EndDAC:{0}", EndDacValue);
                        txtReport.AppendText(report);
                    }
                    else
                    {
                        MessageBox.Show("Set EndDAC failure. Please check the USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                    }
                    #endregion
                }
                else
                {
                    MessageBox.Show("Ilegal input the StartDAC and EndDAC. The StartDAC should less than EndDAC\n", "Ilegal Input", MessageBoxButton.OK, MessageBoxImage.Error);
                    return;
                }
                #endregion
                int StartDac = int.Parse(txtStartDac.Text);
                int EndDac = int.Parse(txtEndDac.Text);
                #region SCurve
                if (DataAcqMode == SCTest)
                {
                    #region Set Single Test Channel
                    bool IsSCurveChannelLegal = rxInt.IsMatch(txtSingleTest_Chn.Text) && (int.Parse(txtSingleTest_Chn.Text) <= 64);
                    if (IsSCurveChannelLegal)
                    {
                        int SCurveChannelValue = int.Parse(txtSingleTest_Chn.Text) - 1;
                        CommandBytes = ConstCommandByteArray(0xE1, (byte)SCurveChannelValue);
                        bResult = CommandSend(CommandBytes, CommandBytes.Length);
                        if (bResult)
                        {
                            report = string.Format("Set single test channel:{0}", SCurveChannelValue + 1);
                            txtReport.AppendText(report);
                        }
                        else
                        {
                            MessageBox.Show("Set single test channel failure. Please check the USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                        }
                    }
                    else
                    {
                        MessageBox.Show("Ilegal input the channel must between 1 to 64\n", "Ilegal Input", MessageBoxButton.OK, MessageBoxImage.Error);
                    }
                    #endregion
                    #region Set Single or Auto
                    //E0B0:Single Channel
                    //E0B1:64 Channel
                    int SingleOrAutoValue = cbxSingleOrAuto.SelectedIndex + 176;//0xB0
                    CommandBytes = ConstCommandByteArray(0xE0, (byte)SingleOrAutoValue);
                    bResult = CommandSend(CommandBytes, CommandBytes.Length);
                    if (bResult)
                    {
                        report = string.Format("Choose {0} Mode\n", cbxSingleOrAuto.Text);
                        txtReport.AppendText(report);
                    }
                    else
                    {
                        MessageBox.Show("Set S Curve channel mode failure. Please check the USB\n", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                    }
                    #endregion
                    #region Set CTest or Input
                    // E0C0:Signal input from CTest pin
                    // E0C1:Signal input from input pin
                    int CTestOrInputValue = cbxCTestOrInput.SelectedIndex + 192;//0xC0
                    CommandBytes = ConstCommandByteArray(0xE0, (byte)CTestOrInputValue);
                    bResult = CommandSend(CommandBytes, CommandBytes.Length);
                    if (bResult)
                    {
                        report = string.Format("Choose {0} Mode\n", cbxCTestOrInput.Text);
                        txtReport.AppendText(report);
                    }
                    else
                    {
                        MessageBox.Show("Set charge inject method failure. Please check the USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                    }
                    #endregion
                    #region Trig Mode
                    //--- Trig Mode ---//
                    if (SCurveMode == Trig)
                    {
                        #region Set CPT_MAX
                        //*** Send CPT_MAX
                        int MaxCountValue = cbxCPT_MAX.SelectedIndex;
                        CommandBytes = ConstCommandByteArray(0xE2, (byte)MaxCountValue);
                        bResult = CommandSend(CommandBytes, CommandBytes.Length);
                        if (bResult)
                        {
                            report = string.Format("Set MAX count number {0}", cbxCPT_MAX.Text);
                            txtReport.AppendText(report);
                        }
                        else
                        {
                            MessageBox.Show("Set S Curve test max count failure. Please check the USB\n", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                        }
                        #endregion
                        #region Single Channel Mode
                        //--- Single Channel Test ---///
                        if (cbxSingleOrAuto.SelectedIndex == SingleChannel)
                        {
                            if (!IsSlowAcqStart)
                            {
                                //*** Set Package Number
                                SlowDataRatePackageNumber = HeaderLength + ChannelLength + (EndDac - StartDac + 1) * OneDacDataLength + TailLength;
                                #region Clear USB FIFO
                                //*** Clear USB FIFO
                                byte[] ClearUSBFifo = ConstCommandByteArray(0xF0, 0xFA);
                                bResult = CommandSend(ClearUSBFifo, ClearUSBFifo.Length);//
                                if (bResult)
                                    txtReport.AppendText("USB fifo cleared");
                                else
                                    txtReport.AppendText("fail to clear USB fifo");
                                byte[] RemainData = new byte[2048];
                                bResult = DataRecieve(RemainData, RemainData.Length);
                                #endregion
                                #region Data ACQ
                                CommandBytes = ConstCommandByteArray(0xE0, 0xF0);
                                bResult = CommandSend(CommandBytes, CommandBytes.Length);
                                if (bResult)
                                {
                                    IsSlowAcqStart = true;
                                    txtReport.AppendText("SCurve Test Start\n");
                                    txtReport.AppendText("SCurve Test Continue\n");
                                    btnSweepTestStart.Content = "SCurve Test Stop";
                                    await Task.Run(() => GetSlowDataRateResultCallBack());
                                    //Task SCurveDataAcq = new Task(() => GetSlowDataRateResultCallBack());
                                    //SCurveDataAcq.Start();
                                    //SCurveDataAcq.Wait();
                                    CommandBytes = ConstCommandByteArray(0xE0, 0xF1);
                                    bResult = CommandSend(CommandBytes, CommandBytes.Length);
                                    if (bResult)
                                    {
                                        IsSlowAcqStart = false;
                                        txtReport.AppendText("SCurve Test Done\n");
                                        btnSweepTestStart.Content = "SCurve Test Start";
                                    }
                                    else
                                    {
                                        txtReport.AppendText("SCurve Test Stop Failure\n");
                                    }
                                }
                                else
                                {
                                    txtReport.AppendText("SCurve Stop Failure\n");
                                }
                                #endregion
                            }
                            else
                            {
                                IsSlowAcqStart = false;
                                CommandBytes = ConstCommandByteArray(0xE0, 0xF1);
                                bResult = CommandSend(CommandBytes, CommandBytes.Length);
                                if (bResult)
                                {

                                    btnSweepTestStart.Content = "Sweep Test Start";
                                    txtReport.AppendText("SCurve Test Abort\n");
                                }
                                else
                                {
                                    txtReport.AppendText("SCurve Test Stop Failure\n");
                                }
                            }
                        }
                        #endregion
                        #region 64 Channel Mode
                        //--- 64 Channel Test ---//
                        else if (cbxSingleOrAuto.SelectedIndex == AllChannel)
                        {
                            if (!IsSlowAcqStart)
                            {
                                //*** Set Package Number
                                SlowDataRatePackageNumber = HeaderLength + (ChannelLength + (EndDac - StartDac + 1) * OneDacDataLength) * 64 + TailLength;
                                #region Clear USB FIFO
                                //*** Clear USB FIFO
                                byte[] ClearUSBFifo = ConstCommandByteArray(0xF0, 0xFA);
                                bResult = CommandSend(ClearUSBFifo, ClearUSBFifo.Length);//
                                if (bResult)
                                    txtReport.AppendText("USB fifo cleared");
                                else
                                    txtReport.AppendText("fail to clear USB fifo");
                                byte[] RemainData = new byte[2048];
                                bResult = DataRecieve(RemainData, RemainData.Length);
                                #endregion
                                #region Data ACQ
                                CommandBytes = ConstCommandByteArray(0xE0, 0xF0);
                                bResult = CommandSend(CommandBytes, CommandBytes.Length);
                                if (bResult)
                                {
                                    IsSlowAcqStart = true;
                                    txtReport.AppendText("SCurve Test Start\n");
                                    txtReport.AppendText("SCurve Test Continue\n");
                                    btnSweepTestStart.Content = "SCurve Test Stop";
                                    await Task.Run(() => GetSlowDataRateResultCallBack());
                                    //Task SCurveDataAcq = new Task(() => GetSlowDataRateResultCallBack());
                                    //SCurveDataAcq.Start();
                                    //SCurveDataAcq.Wait();
                                    CommandBytes = ConstCommandByteArray(0xE0, 0xF1);
                                    bResult = CommandSend(CommandBytes, CommandBytes.Length);
                                    if (bResult)
                                    {
                                        IsSlowAcqStart = false;
                                        btnSweepTestStart.Content = "Sweep Test Start";
                                        txtReport.AppendText("SCurve Test Stop\n");
                                    }
                                    else
                                    {
                                        txtReport.AppendText("SCurve Test Stop Failure\n");
                                    }
                                }
                                else
                                {
                                    txtReport.AppendText("SCurve Stop Failure\n");
                                }
                                #endregion
                            }
                            else
                            {
                                IsSlowAcqStart = false;
                                CommandBytes = ConstCommandByteArray(0xE0, 0xF1);
                                bResult = CommandSend(CommandBytes, CommandBytes.Length);
                                if (bResult)
                                {
                                    btnSweepTestStart.Content = "Sweep Test Start";
                                    txtReport.AppendText("SCurve Test Stop\n");
                                }
                                else
                                {
                                    txtReport.AppendText("SCurve Test Stop Failure\n");
                                }
                            }
                        }
                        #endregion
                    }
                    #endregion
                    #region Count Mode
                    else if (SCurveMode == Count)
                    {
                        #region Set Count Time
                        //*** Set Max Count Time
                        bool IsCounterMaxLegal = rxInt.IsMatch(txtCountTime.Text) && (int.Parse(txtCountTime.Text) < 65535);
                        if (IsCounterMaxLegal)
                        {
                            int CountTimeValue = int.Parse(txtCountTime.Text);
                            CommandBytes = ConstCommandByteArray(0xE3, (byte)CountTimeValue);
                            bResult = CommandSend(CommandBytes, CommandBytes.Length);
                            if (!bResult)
                            {
                                MessageBox.Show("Set count time failure. Please check the ", //text
                                     "USB Error",   //caption
                                     MessageBoxButton.OK,//button
                                     MessageBoxImage.Error);//icon
                            }
                            CommandBytes = ConstCommandByteArray(0xE4, (byte)(CountTimeValue >> 8));
                            bResult = CommandSend(CommandBytes, CommandBytes.Length);
                            if (bResult)
                            {
                                report = string.Format("Set count time:{0}", txtCountTime.Text);
                                txtReport.AppendText(report);
                            }
                            else
                            {
                                MessageBox.Show("Set count time failure. Please check the ", //text
                                     "USB Error",   //caption
                                     MessageBoxButton.OK,//button
                                     MessageBoxImage.Error);//icon
                            }
                        }
                        else
                        {
                            MessageBox.Show("Illegal count time, please re-type(Integer:0--65536)", //text
                                     "Illegal input",   //caption
                                     MessageBoxButton.OK,//button
                                     MessageBoxImage.Error);//icon
                        }
                        #endregion
                        #region Single Channel Mode
                        if (cbxSingleOrAuto.SelectedIndex == SingleChannel)
                        {
                            if (!IsSlowAcqStart)
                            {
                                //*** Set Package Number
                                SlowDataRatePackageNumber = HeaderLength + ChannelLength + (EndDac - StartDac + 1) * OneDacDataLength + TailLength;
                                #region Clear Usb FIFO
                                //*** Clear USB FIFO
                                byte[] ClearUSBFifo = ConstCommandByteArray(0xF0, 0xFA);
                                bResult = CommandSend(ClearUSBFifo, ClearUSBFifo.Length);//
                                if (bResult)
                                    txtReport.AppendText("USB fifo cleared");
                                else
                                    txtReport.AppendText("fail to clear USB fifo");
                                byte[] RemainData = new byte[2048];
                                bResult = DataRecieve(RemainData, RemainData.Length);
                                #endregion
                                #region Data ACQ
                                CommandBytes = ConstCommandByteArray(0xE0, 0xF0);
                                bResult = CommandSend(CommandBytes, CommandBytes.Length);
                                if (bResult)
                                {

                                    IsSlowAcqStart = true;
                                    txtReport.AppendText("SCurve Test Start\n");
                                    txtReport.AppendText("SCurve Test Continue\n");
                                    btnSweepTestStart.Content = "SCurve Test Stop";
                                    await Task.Run(() => GetSlowDataRateResultCallBack());
                                    //Task SCurveDataAcq = new Task(() => GetSlowDataRateResultCallBack());
                                    //SCurveDataAcq.Start();
                                    //SCurveDataAcq.Wait();
                                    CommandBytes = ConstCommandByteArray(0xE0, 0xF1);
                                    bResult = CommandSend(CommandBytes, CommandBytes.Length);
                                    if (bResult)
                                    {
                                        IsSlowAcqStart = false;
                                        btnSweepTestStart.Content = "Sweep Test Start";
                                        txtReport.AppendText("SCurve Test Stop\n");
                                    }
                                    else
                                    {
                                        txtReport.AppendText("SCurve Test Stop Failure\n");
                                    }
                                }
                                else
                                {
                                    txtReport.AppendText("SCurve Stop Failure\n");
                                }
                                #endregion
                            }
                            else
                            {
                                IsSlowAcqStart = false;
                                CommandBytes = ConstCommandByteArray(0xE0, 0xF1);
                                bResult = CommandSend(CommandBytes, CommandBytes.Length);
                                if (bResult)
                                {
                                    btnSweepTestStart.Content = "Sweep Test Start";
                                    txtReport.AppendText("SCurve Test Stop\n");
                                }
                                else
                                {
                                    txtReport.AppendText("SCurve Test Stop Failure\n");
                                }
                            }
                        }
                        #endregion
                        #region 64Channel Mode
                        else if (cbxSingleOrAuto.SelectedIndex == AllChannel)
                        {
                            if (!IsSlowAcqStart)
                            {
                                //*** Set Package Number
                                SlowDataRatePackageNumber = HeaderLength + (ChannelLength + (EndDac - StartDac + 1) * OneDacDataLength) * 64 + TailLength;
                                #region Clear USB FIFO
                                //*** Clear USB FIFO
                                byte[] ClearUSBFifo = ConstCommandByteArray(0xF0, 0xFA);
                                bResult = CommandSend(ClearUSBFifo, ClearUSBFifo.Length);//
                                if (bResult)
                                    txtReport.AppendText("USB fifo cleared");
                                else
                                    txtReport.AppendText("fail to clear USB fifo");
                                byte[] RemainData = new byte[2048];
                                bResult = DataRecieve(RemainData, RemainData.Length);
                                #endregion
                                #region Data ACQ
                                CommandBytes = ConstCommandByteArray(0xE0, 0xF0);
                                bResult = CommandSend(CommandBytes, CommandBytes.Length);
                                if (bResult)
                                {
                                    IsSlowAcqStart = true;
                                    txtReport.AppendText("SCurve Test Start\n");
                                    btnSweepTestStart.Content = "Sweep Test Stop";
                                    txtReport.AppendText("SCurve Test Continue\n");
                                    await Task.Run(() => GetSlowDataRateResultCallBack());
                                    //Task SCurveDataAcq = new Task(() => GetSlowDataRateResultCallBack());
                                    //SCurveDataAcq.Start();
                                    //SCurveDataAcq.Wait();
                                    CommandBytes = ConstCommandByteArray(0xE0, 0xF1);
                                    bResult = CommandSend(CommandBytes, CommandBytes.Length);
                                    if (bResult)
                                    {
                                        IsSlowAcqStart = false;
                                        txtReport.AppendText("SCurve Test Stop\n");
                                    }
                                    else
                                    {
                                        txtReport.AppendText("SCurve Test Stop Failure\n");
                                    }
                                }
                                else
                                {
                                    txtReport.AppendText("SCurve Stop Failure\n");
                                }
                                #endregion
                            }
                            else
                            {
                                IsSlowAcqStart = false;
                                CommandBytes = ConstCommandByteArray(0xE0, 0xF1);
                                bResult = CommandSend(CommandBytes, CommandBytes.Length);
                                if (bResult)
                                {
                                    txtReport.AppendText("SCurve Test Stop\n");
                                }
                                else
                                {
                                    txtReport.AppendText("SCurve Test Stop Failure\n");
                                }
                            }
                        }
                        #endregion
                    }
                    #endregion
                }
                #endregion
                #region Sweep Acq
                else if (DataAcqMode == SweepAcq)
                {
                    if (!IsSlowAcqStart)
                    {
                        #region Set Start Acq Time
                        Regex rx_int = new Regex(rx_Integer);
                        bool Is_Time_legal = rx_int.IsMatch(txtStartAcqTime.Text);
                        if (Is_Time_legal)
                        {
                            int value = Int32.Parse(txtStartAcqTime.Text) / 25; //除以25ns 
                            byte[] bytes = ConstCommandByteArray(0xB2, (byte)(value >> 8));
                            bResult = CommandSend(bytes, bytes.Length);
                            if (!bResult)
                            {
                                MessageBox.Show("Set StartAcq time failure, please check USB", //text
                                                 "USB Error",   //caption
                                                 MessageBoxButton.OK,//button
                                                 MessageBoxImage.Error);//icon
                                return;
                            }
                            bytes = ConstCommandByteArray(0xB1, (byte)(value));
                            bResult = CommandSend(bytes, bytes.Length);
                            if (bResult)
                            {
                                report = string.Format("Set StartAcq time : {0}\n", txtStartAcqTime.Text);
                                txtReport.AppendText(report);
                            }
                            else
                            {
                                MessageBox.Show("Set StartAcq time failure, please check USB", //text
                                                 "USB Error",   //caption
                                                 MessageBoxButton.OK,//button
                                                 MessageBoxImage.Error);//icon
                                return;
                            }
                        }
                        else
                        {
                            MessageBox.Show("Illegal StartAcq Time, please re-type(Integer:0--1638400,step:25ns)", //text
                                             "Illegal input",   //caption
                                             MessageBoxButton.OK,//button
                                             MessageBoxImage.Error);//icon
                            return;
                        }
                        #endregion
                        #region Set Package Number
                        bool IsPackageNumberLegal = rxInt.IsMatch(txtPackageNumber.Text) && (int.Parse(txtPackageNumber.Text) < 65535);
                        int PackageNumberValue;
                        if (IsPackageNumberLegal)
                        {
                            PackageNumberValue = int.Parse(txtPackageNumber.Text);
                        }
                        else
                        {
                            PackageNumberValue = 10000;
                        }
                        CommandBytes = ConstCommandByteArray(0xE6, (byte)PackageNumberValue);
                        bResult = CommandSend(CommandBytes, CommandBytes.Length);
                        if (!bResult)
                        {
                            MessageBox.Show("Set count time failure. Please check the USB ", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                        }
                        CommandBytes = ConstCommandByteArray(0xE7, (byte)(PackageNumberValue >> 8));
                        bResult = CommandSend(CommandBytes, CommandBytes.Length);
                        if (bResult)
                        {
                            report = string.Format("Set sweep acq package number:{0}\n", txtPackageNumber.Text);
                            txtReport.AppendText(report);
                        }
                        else
                        {
                            MessageBox.Show("Set count time failure. Please check the USB ", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                        }
                        #endregion
                        #region Set Sweep Dac
                        int SweepDacSelectValue = cbxDacSelect.SelectedIndex;
                        CommandBytes = ConstCommandByteArray(0xE0, (byte)(SweepDacSelectValue));
                        bResult = CommandSend(CommandBytes, CommandBytes.Length);
                        if (bResult)
                        {
                            report = string.Format("Set {0} as sweep DAC\n", cbxDacSelect.Text);
                            txtReport.AppendText(report);
                        }
                        else
                        {
                            MessageBox.Show("Set sweep DAC failure. Please check the ", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                        }
                        #endregion
                        #region Start Acq
                        //*** Set Package Number
                        SlowDataRatePackageNumber = HeaderLength + (2 + PackageNumberValue * 20) * (EndDac - StartDac + 1) + TailLength;
                        #region Clear USB FIFO
                        //*** Clear USB FIFO
                        byte[] ClearUSBFifo = ConstCommandByteArray(0xF0, 0xFA);
                        bResult = CommandSend(ClearUSBFifo, ClearUSBFifo.Length);//
                        if (bResult)
                            txtReport.AppendText("USB fifo cleared");
                        else
                            txtReport.AppendText("fail to clear USB fifo");
                        byte[] RemainData = new byte[2048];
                        bResult = DataRecieve(RemainData, RemainData.Length);
                        #endregion
                        #region Data ACQ
                        CommandBytes = ConstCommandByteArray(0xE0, 0xF0);
                        bResult = CommandSend(CommandBytes, CommandBytes.Length);
                        if (bResult)
                        {
                            txtReport.AppendText("Sweep Acq Test Start\n");
                            txtReport.AppendText("Sweep Acq Continue\n");
                            btnSweepTestStart.Content = "Sweep Test Stop";
                            await Task.Run(() => GetSlowDataRateResultCallBack());
                            btnSweepTestStart.Content = "Sweep Acq Start";
                            //Task SCurveDataAcq = new Task(() => GetSlowDataRateResultCallBack());
                            //SCurveDataAcq.Start();
                            //SCurveDataAcq.Wait();
                            CommandBytes = ConstCommandByteArray(0xE0, 0xF1);
                            bResult = CommandSend(CommandBytes, CommandBytes.Length);
                            if (bResult)
                            {
                                IsSlowAcqStart = false;
                                btnSweepTestStart.Content = "Sweep Test Start";
                                txtReport.AppendText("Sweep Acq Test Stop\n");
                            }
                            else
                            {
                                txtReport.AppendText("Sweep Acq Test Stop Failure\n");
                            }
                        }
                        else
                        {
                            txtReport.AppendText("Sweep Acq Stop Failure\n");
                        }
                        #endregion
                        #endregion
                    }
                    else
                    {
                        IsSlowAcqStart = false;
                        CommandBytes = ConstCommandByteArray(0xE0, 0xF1);
                        bResult = CommandSend(CommandBytes, CommandBytes.Length);
                        if (bResult)
                        {
                            btnSweepTestStart.Content = "Sweep Test Start";
                            txtReport.AppendText("Sweep Acq Test Stop\n");
                        }
                        else
                        {
                            txtReport.AppendText("Sweep Acq Test Stop Failure\n");
                        }
                    }
                }
                #endregion
            }
        }

        private async void btnStartAdc_Click(object sender, RoutedEventArgs e)
        {
            if (filepath == null || string.IsNullOrEmpty(filepath.Trim()))
            {
                MessageBox.Show("You should save the file first before Scurve start", "imformation", MessageBoxButton.OK, MessageBoxImage.Error);
            }
            else
            {
                if (!IsAdcStart)
                {
                    #region Set ADC Delay
                    Regex rxInt = new Regex(rx_Integer);
                    bool IsDelayLegeal = rxInt.IsMatch(txtStartDelay.Text) && (int.Parse(txtStartDelay.Text) < 400);
                    int AdcStartDelay;
                    if (IsDelayLegeal)
                    {
                        AdcStartDelay = int.Parse(txtStartDelay.Text) / 25;
                    }
                    else
                    {
                        AdcStartDelay = 2;
                    }
                    byte[] CommandBytes = ConstCommandByteArray(0xA8, (byte)AdcStartDelay);
                    bool bResult = CommandSend(CommandBytes, CommandBytes.Length);
                    if (bResult)
                    {
                        string report = string.Format("Set ADC start delay :{0}ns\n", AdcStartDelay * 25);
                        txtReport.AppendText(report);
                    }
                    else
                    {
                        MessageBox.Show("Set ADC start delay failure, please check the USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                        //return;
                    }
                    #endregion
                    #region Set Hold Parameter
                    Regex rx_int = new Regex(rx_Integer);
                    #region Set Hold Delay
                    bool Is_Hold_legal = rx_int.IsMatch(txtHold_delay.Text) && int.Parse(txtHold_delay.Text) < 800;
                    if (Is_Hold_legal)
                    {
                        int DelayTime = (int)(int.Parse(txtHold_delay.Text) / 6.25); //除以6.25ns
                        byte DelayTime1 = (byte)(DelayTime & 15);//15 = 0xF
                        byte DelayTime2 = (byte)(((DelayTime >> 4) & 15) | 16);//16 = 0x10
                        CommandBytes = ConstCommandByteArray(0xA6, DelayTime1);
                        bResult = CommandSend(CommandBytes, CommandBytes.Length);
                        if (!bResult)
                        {
                            MessageBox.Show("Set Hold delay failure, please check USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                            return;
                        }
                        CommandBytes = ConstCommandByteArray(0xA6, DelayTime2);
                        bResult = CommandSend(CommandBytes, CommandBytes.Length);
                        if (bResult)
                        {
                            string report = string.Format("Set Hold Delay Time:{0}ns\n", DelayTime * 6.25);
                            txtReport.AppendText(report);
                        }
                        else
                        {
                            MessageBox.Show("Set Hold delay failure, please check USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                            return;
                        }
                    }
                    else
                    {
                        MessageBox.Show("Illegal Hold delay, please re-type(Integer:0--650,step:2ns)", "Illegal input", MessageBoxButton.OK, MessageBoxImage.Error);
                        return;
                    }
                    #endregion
                    #region Set Trig Coincide
                    int TrigCoincid = cbxTrig_Coincid.SelectedIndex + 160;//160 = 0xA0
                    CommandBytes = ConstCommandByteArray(0xA5, (byte)TrigCoincid);
                    bResult = CommandSend(CommandBytes, CommandBytes.Length);
                    if (bResult)
                    {
                        string report = string.Format("Set Trigger Coincidence : {0}\n", cbxTrig_Coincid.Text);
                        txtReport.AppendText(report);
                    }
                    else
                    {
                        MessageBox.Show("Set Trigger Coincid failure, please check USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                        return;
                    }
                    #endregion
                    #region Set Hold Time
                    /*
                        + 4Y:HoldTime[3:0]
                        + 5Y:HoldTime[7:4]
                        + 6Y:HoldTime[11:8]
                        + 7Y:HoldTime[15:12]
                     */
                    bool IsHoldTimeLegal = rx_int.IsMatch(txtHoldTime.Text) && int.Parse(txtHoldTime.Text) < 10000;
                    if (IsHoldTimeLegal)
                    {
                        int HoldTime = int.Parse(txtHoldTime.Text) / 25;
                        int HoldTime1 = (HoldTime & 15) + 64;//0x40
                        int HoldTime2 = ((HoldTime >> 4) & 15) + 80;//0x50
                        int HoldTime3 = ((HoldTime >> 8) & 15) + 96;
                        int HoldTime4 = ((HoldTime >> 12) & 15) + 112;
                        CommandBytes = ConstCommandByteArray(0xA6, (byte)HoldTime1);
                        bResult = CommandSend(CommandBytes, CommandBytes.Length);
                        if (!bResult)
                        {
                            MessageBox.Show("Set Hold Time failure, please check USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                            return;
                        }
                        CommandBytes = ConstCommandByteArray(0xA6, (byte)HoldTime2);
                        bResult = CommandSend(CommandBytes, CommandBytes.Length);
                        if (!bResult)
                        {
                            MessageBox.Show("Set Hold Time failure, please check USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                            return;
                        }
                        CommandBytes = ConstCommandByteArray(0xA6, (byte)HoldTime3);
                        bResult = CommandSend(CommandBytes, CommandBytes.Length);
                        if (!bResult)
                        {
                            MessageBox.Show("Set Hold Time failure, please check USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                            return;
                        }
                        CommandBytes = ConstCommandByteArray(0xA6, (byte)HoldTime4);
                        bResult = CommandSend(CommandBytes, CommandBytes.Length);
                        if (bResult)
                        {
                            string report = string.Format("Set Hold Time:{0}\n", HoldTime * 25);
                            txtReport.AppendText(report);
                        }
                        else
                        {
                            MessageBox.Show("Set Hold Time failure, please check USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                            return;
                        }
                    }
                    else
                    {
                        MessageBox.Show("Illegal Hold Time, please re-type(Integer:0--10000,step:2ns)", "Illegal input", MessageBoxButton.OK, MessageBoxImage.Error);
                        return;
                    }
                    #endregion
                    #endregion
                    #region Set Adc Data Number
                    bool IsAdcDataNumberLegal = rxInt.IsMatch(txtAdcAcqTimes.Text) && int.Parse(txtAdcAcqTimes.Text) < 255;
                    int AdcDataNumber;
                    if(IsAdcDataNumberLegal)
                    {
                        AdcDataNumber = int.Parse(txtAdcAcqTimes.Text);
                    }
                    else
                    {
                        AdcDataNumber = 32;
                    }
                    int AdcDataNumber1 = (AdcDataNumber & 15) + 16;//0x10
                    int AdcDataNumber2 = ((AdcDataNumber >> 4) & 15) + 32;//0x20
                    CommandBytes = ConstCommandByteArray(0xE8, (byte)AdcDataNumber1);
                    bResult = CommandSend(CommandBytes, CommandBytes.Length);
                    if(!bResult)
                    {
                        MessageBox.Show("Set ADC Data Times failure, please check the USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                        return;
                    }
                    CommandBytes = ConstCommandByteArray(0xE8, (byte)AdcDataNumber2);
                    bResult = CommandSend(CommandBytes, CommandBytes.Length);
                    if(bResult)
                    {
                        string report = string.Format("Set Adc Data Nmuber:{0}\n", AdcDataNumber);
                        txtReport.AppendText(report);
                    }
                    else
                    {
                        MessageBox.Show("Set ADC Data Times failure, please check the USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                        return;
                    }
                    #endregion
                    #region Set ADC Input
                    int AdcInput = cbxAdcInput.SelectedIndex + 240;//240 = 0xF0
                    CommandBytes = ConstCommandByteArray(0xD2, (byte)AdcInput);
                    bResult = CommandSend(CommandBytes, CommandBytes.Length);
                    if(bResult)
                    {
                        string report = string.Format("Set ADC monitor {0}\n", cbxAdcInput.Text);
                        txtReport.AppendText(report);
                    }
                    else
                    {
                        MessageBox.Show("Set ADC Monitor failure, please check the USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                        return;
                    }
                    #endregion
                    #region Start Acq
                    CommandBytes = ConstCommandByteArray(0xE0, 0xF2);
                    bResult = CommandSend(CommandBytes, CommandBytes.Length);
                    bResult = true;
                    if (bResult)
                    {
                        btnStartAdc.Content = "ADC Stop";
                        btnStartAdc.Background = Brushes.Blue;
                        IsAdcStart = true;
                        await Task.Run(() => GetSlowDataRateResultCallBack());
                        CommandBytes = ConstCommandByteArray(0xE0, 0xF3);
                        bResult = CommandSend(CommandBytes, CommandBytes.Length);
                        if (bResult)
                        {
                            IsAdcStart = false;
                            btnAcqStart.Background = Brushes.Green;
                            btnAcqStart.Content = "ADC Start";
                            txtReport.AppendText("ADC Stopped\n");
                        }
                        {
                            MessageBox.Show("ADC Stop failure, please check USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                            return;
                        }
                        //Task SCurveDataAcq = new Task(() => GetSlowDataRateResultCallBack());
                        //SCurveDataAcq.Start();
                        //await GetSlowDataRateResultCallBack();                     
                    }
                    else
                    {
                        MessageBox.Show("ADC Start failure, please check USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                        return;
                    }
                    #endregion
                }
                else
                {
                    #region Stop Acq
                    //txtReport.AppendText("ADC Stopped\n");
                    byte[] CommandBytes = ConstCommandByteArray(0xE0, 0xF3);
                    bool bResult = CommandSend(CommandBytes, CommandBytes.Length);
                    if (bResult)
                    {
                        IsAdcStart = false;
                        btnStartAdc.Background = Brushes.Green;
                        btnStartAdc.Content = "ADC Start";
                        txtReport.AppendText("ADC Abort\n");
                    }
                    else
                    {
                        txtReport.AppendText("Stop ADC Failure 1st time \n");
                        return;
                    }
                    #endregion
                }
            }

        }
        // Slow data rate acquisition thread
        private void GetSlowDataRateResultCallBack()
        {
            bw = new BinaryWriter(File.Open(filepath, FileMode.Append));
            //private int SingleDataLength = 512;
            bool bResult = false;
            byte[] DataReceiveBytes = new byte[512];
            if (DataAcqMode == Acq || DataAcqMode == SweepAcq || DataAcqMode == SCTest)
            {
                #region The Max Data Number is Set
                if (SlowDataRatePackageNumber != 0)
                {
                    int PackageNumber = SlowDataRatePackageNumber / 512;
                    int RemainPackageNum = SlowDataRatePackageNumber % 512;
                    int PackageCount = 0;
                    while (PackageCount < PackageNumber & IsSlowAcqStart)
                    {
                        bResult = DataRecieve(DataReceiveBytes, DataReceiveBytes.Length);
                        if (bResult)
                        {
                            bw.Write(DataReceiveBytes);
                            PackageCount++;
                        }
                    }
                    if (RemainPackageNum != 0)
                    {
                        bResult = false;
                        byte[] RemainByte = new byte[2048];
                        while (!DataRecieve(RemainByte, RemainByte.Length) & IsSlowAcqStart) ;
                        byte[] RemainByteWrite = new byte[RemainPackageNum];
                        for (int i = 0; i < RemainPackageNum; i++)
                        {
                            RemainByteWrite[i] = RemainByte[i];
                        }
                        bw.Write(RemainByteWrite);
                    }
                }
                #endregion
                #region The Max Data Number is not set and work in consist mode
                else
                {
                    while (IsSlowAcqStart)
                    {
                        bResult = DataRecieve(DataReceiveBytes, DataReceiveBytes.Length);
                        if (bResult)
                        {
                            bw.Write(DataReceiveBytes);
                        }
                    }
                }
                #endregion
                //IsSlowAcqStart = false;
            }
            else if (DataAcqMode == Adc)
            {
                while (IsAdcStart)
                {
                    bResult = DataRecieve(DataReceiveBytes, DataReceiveBytes.Length);
                    if (bResult)
                    {
                        bw.Write(DataReceiveBytes);
                    }
                }
            }
            byte[] EndFrame = new byte[512];
            for (int j = 0; j < 16; j++)
            {
                bResult = DataRecieve(EndFrame, EndFrame.Length);
                if (bResult)
                {
                    bw.Write(EndFrame);
                }
            }
            bw.Flush();
            bw.Dispose();
            bw.Close();
        }



        private void DaqModeSelect_Checked(object sender, RoutedEventArgs e)
        {
            var button = sender as RadioButton;
            bool bResult = false;
            byte[] CommandBytes = new byte[2];
            if(button.Content.ToString() == "Auto")
            {
                DaqMode = AutoDaq;
                txtEndHoldTime.IsEnabled = false;
            }
            else if(button.Content.ToString() == "Slave")
            {
                DaqMode = SlaveDaq;
                txtEndHoldTime.IsEnabled = true;
            }
            CommandBytes = ConstCommandByteArray(0xE0, (byte)DaqMode);
            bResult = CommandSend(CommandBytes, CommandBytes.Length);
            if(bResult)
            {
                string report = string.Format("Set DAQ Mode: {0} DAQ\n", button.Content.ToString());
                txtReport.AppendText(report);
            }
            else
            {
                MessageBox.Show("Set DAQ Mode failure, please check USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }
        private async void btnTest_Click(object sender, RoutedEventArgs e)
        {
            if (!IsTestStart)
            {
                IsTestStart = true;
                btnTest.Content = "Test Stop";
                await Task.Run(() => TestCount());
                //BigCountTest.Start();
                //TestCount();
                txtReport.AppendText("Test Done\n");
                btnTest.Content = "TestSync";
            }
            else
            {
                IsTestStart = false;
                btnTest.Content = "TestSync";
                txtReport.AppendText("Test Abort\n");
            }
        }
        private void TestCount()
        {
            int BigCount = 0;
            int BigBigCount = 0;
            while (IsTestStart && BigBigCount < 10000)
            {
                BigCount = BigCount + 1;
                if (BigCount == 10000)
                {
                    //txtReport.AppendText("10000\n");
                }
                if (BigCount == 100000)
                {
                    BigCount = 0;
                    BigBigCount += 1;
                }
            }
            IsTestStart = false;
            string report = string.Format("Count :{0}", BigCount);
            //txtReport.AppendText(report);
            //return BigCount;
            //return Task.Run(() => txtReport.AppendText("TestDone"));
        }
    }
}
