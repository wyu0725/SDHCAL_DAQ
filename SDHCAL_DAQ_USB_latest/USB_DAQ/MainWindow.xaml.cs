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
using System.Runtime.InteropServices;
using System.Windows.Interop;
using System.Diagnostics;
using System.Collections;
//using System.Collections.ObjectModel;//new add 20150823
//using Target7_NEWDAQ.DataModel;      //new add 20150823
namespace USB_DAQ
{
    /// <summary>
    /// MainWindow.xaml 的交互逻辑
    /// </summary>
    public partial class MainWindow : Window
    {
        //private USBDeviceList usbDevices;
        //private CyUSBDevice myDevice;
        //private static CyBulkEndPoint BulkInEndPt;
        //private static CyBulkEndPoint BulkOutEndPt;
        private const int VID = 0x04B4;
        private const int PID = 0x1004;
        private MyCyUsb MyUsbDevice1 = new MyCyUsb(PID, VID);
        private const int AsicId = 0xA1;
        private const int NumberOfChip = 4;
        private MicrorocControl MicrorocChain1 = new MicrorocControl(AsicId, NumberOfChip);

        private MicrorocAsic[] MicrorocAsicChain = new MicrorocAsic[4] { new MicrorocAsic(4, 0), new MicrorocAsic(4, 1), new MicrorocAsic(4, 2), new MicrorocAsic(4, 3) };

        private string rx_Command = @"\b[0-9a-fA-F]{4}\b";//match 16 bit Hex
        private string rx_Byte = @"\b[0-9a-fA-F]{2}\b";//match 8 bit Hex
        private string rx_Integer = @"^\d+$";   //匹配非负 整数
        private string rx_Double = @"^-?\d+(\.\d{1,6})?$";//小数可有可无最多6位小数 
        private string filepath = null;//文件路径
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

        private const int SingleChannel = 0;
        private const int AllChannel = 1;
        private const int OneDacDataLength = 7*2;//7*16-bits == 14 bytes
        private const int HeaderLength = 1 * 2;//16-bits
        private const int ChannelLength = 1 * 2;//16-bits
        private const int TailLength = 1 * 2;//16-bits

        private static bool IsTestStart = false;

        //private const string AFG3252Descr = "USB[0-9]::0x0699::0x034E::C[0-9]+::INSTR";
        //private const string AFG3252VidPid = "VID_0699&PID_034E";

        private const string AFG3252Descr = "USB[0-9]::0x0699::0x0345::C[0-9]+::INSTR";
        private const string AFG3252VidPid = "VID_0699&PID_0345";
        private AFG3252 MyAFG3252 = new AFG3252(AFG3252Descr);
        private bool AFG3252Attach = false;
        private bool AmplitudeOrLevel = true;
        string CurrentPath = Environment.CurrentDirectory;
        //SC Parameter


        public MainWindow()
        {
            InitializeComponent();
            //Adding event handles for device attachment and device removal
            MyUsbDevice1.usbDevices.DeviceAttached += new EventHandler(usbDevices_DeviceAttached);
            MyUsbDevice1.usbDevices.DeviceRemoved += new EventHandler(usbDevices_DeviceRemoved);
            RefreshDevice();
            Afg3252Refresh();
            DisableNewDif();
            DisableSCurveTestNewDif();
            //Initial_SerialPort();
        }
        private void usbDevices_DeviceAttached(object sender, EventArgs e)
        {
            USBEventArgs usbEvent = e as USBEventArgs;
            RefreshDevice();
        }
        private void usbDevices_DeviceRemoved(object sender, EventArgs e)
        {
            USBEventArgs usbEvent = e as USBEventArgs;
            RefreshDevice();
        }
        private void RefreshDevice()
        {
            // Get the first device having VendorID == 0x04B4 and ProductID == 0x1004
            //myDevice = usbDevices[VID,PID] as CyUSBDevice;
            if (MyUsbDevice1.InitialDevice())
            {
                usb_status.Content = "USB device connected";
                usb_status.Foreground = Brushes.Green;
                btnCommandSend.Background = Brushes.ForestGreen;
                btnCommandSend.IsEnabled = true;
                txtCommand.IsEnabled = true;
                btnAcqStart.IsEnabled = true;
                btnAcqStart.Background = Brushes.ForestGreen;


                btnSC_or_ReadReg.IsEnabled = true;
                btnReset_cntb.IsEnabled = true;
                btnTRIG_EXT_EN.IsEnabled = true;
                btnSet_Raz_Width.IsEnabled = true;
                btnSet_Hold.IsEnabled = true;
                btnOut_th_set.IsEnabled = true;
            }
            else
            {
                usb_status.Content = "USB device not connected";
                usb_status.Foreground = Brushes.DeepPink;
                btnCommandSend.IsEnabled = false;
                txtCommand.IsEnabled = false;
                btnAcqStart.IsEnabled = false;
                btnSC_or_ReadReg.IsEnabled = false;
                btnReset_cntb.IsEnabled = false;
                btnTRIG_EXT_EN.IsEnabled = false;
                btnSet_Raz_Width.IsEnabled = false;
                btnSet_Hold.IsEnabled = false;
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
                byte[] CommandBytes = MyUsbDevice1.ConstCommandByteArray(HexStringToByteArray(txtCommand.Text));//convert to byte 
                bResult = MyUsbDevice1.CommandSend(CommandBytes);
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
        /*private static byte[] ConstCommandByteArray(params byte[] paramList)
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
        }*/
        //Command send method
        /*public static bool CommandSend(byte[] OutData, int xferLen)
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
        }*/
        //data recieve method
        /*private bool DataRecieve(byte[] InData, int xferLen)
        {
            bool bResult = false;
            if(myDevice != null)
            {
                bResult = BulkInEndPt.XferData(ref InData, ref xferLen, true);
            }
            else
            {
                MessageBox.Show("USB Error");//弹出还是不弹出错误信息？不弹出错误信息可能会丢包，弹出的话采集就会中断
            }
            try
            {
                bResult = BulkInEndPt.XferData(ref InData, ref xferLen, true);
            }
            catch(Exception exp)
            {
                MessageBox.Show(exp.Message);
            }
            return bResult;
        }*/
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
                        StateIndicator.FileSaved = true;
                        
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
        /// <summary>
        /// True for saved and false for not saved. If file is not saved, a select box will show.
        /// </summary>
        /// <returns></returns>
        private bool CheckFileSaved()
        {
            if((filepath != null) && (!string.IsNullOrEmpty(filepath.Trim())) && StateIndicator.FileSaved)
            {
                return true;
            }
            else
            {
                if (MessageBox.Show("File not saved. Use default name?", "Confirm Message", MessageBoxButton.YesNo, MessageBoxImage.Question) == MessageBoxResult.Yes)
                {
                    if (SaveFileDefault())
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
          
        }
        private bool SaveFileDefault()
        {
            string DefaultDicrectory = @txtFileDir.Text;
            string DefaultFileName = DateTime.Now.ToString();
            DefaultFileName = DefaultFileName.Replace("/", "_");
            DefaultFileName = DefaultFileName.Replace(":", "_");
            DefaultFileName = DefaultFileName.Replace(" ", "T");
            DefaultFileName += ".dat";
            filepath = Path.Combine(DefaultDicrectory, DefaultFileName);
            FileStream fs = null;
            if (!File.Exists(filepath))
            {
                fs = File.Create(filepath);
                string report = String.Format("File:{0} Created\n", filepath);
                txtReport.AppendText(report.ToString());
                StateIndicator.FileSaved = true;
                fs.Close();
                txtFileName.Text = DefaultFileName;
                return true;
            }
            else
            {
                MessageBox.Show("Save file failure. Please save the file manual", "File Save Error", MessageBoxButton.OK, MessageBoxImage.Error);
                return false;
            }
        }
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
                bool bResult;
                if (!StateIndicator.AcqStart) //Acquisition is not start then start acquisition
                {                    
                    bool IllegalInput;
                    #region Set Start Acq Time
                    bResult = MicrorocChain1.SetAcquisitionTime(txtStartAcqTime.Text, MyUsbDevice1, out IllegalInput);
                    if (bResult)
                    {
                        string report = string.Format("Set StartAcq time : {0}\n", txtStartAcqTime.Text);
                        txtReport.AppendText(report);
                    }
                    else if (IllegalInput)
                    {
                        MessageBox.Show("Illegal StartAcq Time, please re-type(Integer:0--1638400,step:25ns)", //text
                                         "Illegal Input",   //caption
                                         MessageBoxButton.OK,//button
                                         MessageBoxImage.Error);//icon
                        return;
                    }
                    else
                    {
                        MessageBox.Show("Set StartAcq time failure, please check USB", //text
                                         "USB Error",   //caption
                                         MessageBoxButton.OK,//button
                                         MessageBoxImage.Error);//icon
                        return;
                    } 
                    #endregion
                    #region Set End Hold Time
                    if (StateIndicator.DaqModeSelect == StateIndicator.DaqMode.SlaveDaq)
                    {
                        bResult = MicrorocChain1.SetEndHoldTime(txtEndHoldTime.Text, MyUsbDevice1, out IllegalInput);
                        if(bResult)
                        {
                            string report = string.Format("Set End Signal Time:{0}\n", txtEndHoldTime.Text);
                            txtReport.AppendText(report);
                        }

                        else if(IllegalInput)
                        {
                            MessageBox.Show("Illegal End Signal Hold Time, please re-type(Integer:0--1638400,step:25ns)", //text
                                         "Illegal input",   //caption
                                         MessageBoxButton.OK,//button
                                         MessageBoxImage.Error);//icon
                            return;
                            
                        }                        
                        else
                        {
                            MessageBox.Show("Set End Hold Time Failure, please check USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                            return;
                        }
                    }
                    #endregion
                    #region Clear USB FIFO
                    bResult = MicrorocChain1.ClearUsbFifo(MyUsbDevice1);
                    if (bResult)
                        reports.AppendLine("USB fifo cleared");
                    else
                    {
                        reports.AppendLine("fail to clear USB fifo");
                        return;
                    }
                    #endregion
                    //string test = string.Format("MAXPktSize is {0}\n", BulkInEndPt.MaxPktSize);
                    //reports.AppendLine(test.ToString());
                    /*Modefied for the Microroc DAQ
                    byte value = (byte)cbxChn_Select.SelectedIndex;
                    byte[] cmd_AcqStart = ConstCommandByteArray(0xF0, value);*/
                    #region Reset Microroc
                    bResult = MicrorocChain1.ResetMicroroc(MyUsbDevice1);
                    if(bResult)
                    {
                        reports.AppendLine("Microroc Reset");
                    }
                    else
                    {
                        MessageBox.Show("Reset Microroc Failure", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                        return;
                    }
                    #endregion
                    Thread.Sleep(10);
                    threadbuffer.Clear();
                    bResult = MicrorocChain1.StartAcquisition(MyUsbDevice1);
                    if (bResult)
                    {
                        StateIndicator.AcqStart = true;
                        btnAcqStart.Content = "AcqAbort";
                        btnAcqStart.Background = Brushes.DeepPink;
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
                    StateIndicator.AcqStart = false;
                    btnAcqStart.Content = "AcqStart";
                    btnAcqStart.Background = Brushes.ForestGreen;
                    bResult = MicrorocChain1.StopAcquisition(MyUsbDevice1);
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
            /*string report;
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
            */
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
                bResult = MicrorocChain1.SelectSlowControlOrReadRegister(false, MyUsbDevice1);
                if (bResult)
                {
                    txtReport.AppendText("You are choosing SC mode\n");
                }
                else
                {
                   // txtReport.AppendText("select failure, please check USB\n");
                    MessageBox.Show("select failure, please check USB", //text
                                     "USB Error",   //caption
                                     MessageBoxButton.OK,//button
                                     MessageBoxImage.Error);//icon
                    return;
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

                }
                txtHeader.IsEnabled = false;
                bResult = MicrorocChain1.SelectSlowControlOrReadRegister(true, MyUsbDevice1);
                if (bResult)
                {
                    txtReport.AppendText("you are choosing ReadReg mode\n");
                }
                else
                {
                    MessageBox.Show("select failure, please check USB", //text
                                     "USB Error",   //caption
                                     MessageBoxButton.OK,//button
                                     MessageBoxImage.Error);//icon
                    return;
                }
            }
            #endregion
        }
        private void btnSC_or_ReadReg_Click(object sender, RoutedEventArgs e)
        {
            MicrorocSetSlowControl();
        }
        private void MicrorocSetSlowControl()
        {
            bool bResult = false;
            bool IllegalInput;
            #region Set ASIC Number
            /*----------------ASIC number and start load---------------------*/
            int AsicNumber = cbxASIC_Number.SelectedIndex;
            bResult = MicrorocChain1.SetAsicNumber(AsicNumber + 1, MyUsbDevice1);
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
                return;
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
                TextBox[] txtMaskFile = new TextBox[4] { txtMaskFile_ASIC1, txtMaskFile_ASIC2, txtMaskFile_ASIC3, txtMaskFile_ASIC4 };
                #endregion
                #region Check Header Legal
                bool IsHeaderLegal = MicrorocChain1.Check8BitHexLegal(txtHeader.Text);
                byte HeaderValue;
                if (IsHeaderLegal)
                {
                    HeaderValue = Convert.ToByte(txtHeader.Text, 16);
                }
                else
                {
                    MessageBox.Show("Header value is illegal. Please re-type (Eg:Hex:AA).\n Set header default value 0xA1", "Illega Input", MessageBoxButton.OK, MessageBoxImage.Error);
                    HeaderValue = 0xA1;
                }
                #endregion                
                StringBuilder details = new StringBuilder();
                //NoSortHashtable TempHashTabel;
                HeaderValue += (byte)(AsicNumber + 1);
                string DCCaliString, SCTCaliString;
                byte[] CaliData = new byte[64];
                #region Readout channel select
                bResult = MicrorocChain1.SelectReadoutChannel(cbxChannelSelect.SelectedIndex, MyUsbDevice1);
                if (bResult)
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
                    return;
                }
                #endregion
                #region RS Or Direct
                bResult = MicrorocChain1.SelectCmpOutLatchedOrDirectOut(cbxRSOrDirect.SelectedIndex, MyUsbDevice1);
                if (bResult)
                {
                    string report = string.Format("Set {0} as trigger\n", cbxRSOrDirect.Text);
                    txtReport.AppendText(report);
                }
                else
                {
                    MessageBox.Show("Set RS Or Direct failure, please check USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                    return;
                }
                #endregion
                
                #region PowerPulsing Control
                #region PreAmp
                bResult = MicrorocChain1.SetPowerPulsing(cbxPreAmpPP.SelectedIndex, CommandHeader.PreAmpPowerPulsingIndex, MyUsbDevice1);
                if (bResult)
                {
                    string report = string.Format("Set Pre Amp PowerPulsing: {0}\n", cbxPreAmpPP.Text);
                    txtReport.AppendText(report);
                }
                else
                {
                    MessageBox.Show("Set PreAmp Power Pulsing failure, please check USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                    return;
                }
                #endregion
                #region Shaper
                bResult = MicrorocChain1.SetPowerPulsing(cbxShaperPP.SelectedIndex, CommandHeader.ShaperPowerPulsingIndex, MyUsbDevice1);
                if (bResult)
                {
                    string report = string.Format("Set Shaper PowerPulsing: {0}\n", cbxShaperPP.Text);
                    txtReport.AppendText(report);
                }
                else
                {
                    MessageBox.Show("Set Shaper Power Pulsing failure, please check USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                    return;
                }
                #endregion
                #region Wildar
                bResult = MicrorocChain1.SetPowerPulsing(cbxWidlarPP.SelectedIndex, CommandHeader.WildarPowerPulsingIndex, MyUsbDevice1);
                if (bResult)
                {
                    string report = string.Format("Set Widlar PowerPulsing: {0}\n", cbxWidlarPP.Text);
                    txtReport.AppendText(report);
                }
                else
                {
                    MessageBox.Show("Set Widlar PowerPulsing failure, please check USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                    return;
                }
                #endregion
                #region 4-bit DAC
                bResult = MicrorocChain1.SetPowerPulsing(cbxDac4BitPP.SelectedIndex, CommandHeader.Dac4BitPowerPulsingIndex, MyUsbDevice1);
                if (bResult)
                {
                    string report = string.Format("Set 4-bit DAC PowerPulsing: {0}\n", cbxDac4BitPP.Text);
                    txtReport.AppendText(report);
                }
                else
                {
                    MessageBox.Show("Set 4-bit DAC PowerPulsing failure, please check USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                    return;
                }
                #endregion
                #region OTAq
                bResult = MicrorocChain1.SetPowerPulsing(cbxOTAqPP.SelectedIndex, CommandHeader.OtaqPowerPulsingIndex, MyUsbDevice1);
                if (bResult)
                {
                    string report = string.Format("Set OTAq PowerPulsing: {0}\n", cbxOTAqPP.Text);
                    txtReport.AppendText(report);
                }
                else
                {
                    MessageBox.Show("Set OTAq PowerPulsing failure, please check USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                    return;
                }
                #endregion
                #region Discriminator
                bResult = MicrorocChain1.SetPowerPulsing(cbxDiscriPP.SelectedIndex, CommandHeader.DiscriminatorPowerPulsingIndex, MyUsbDevice1);
                if (bResult)
                {
                    string report = string.Format("Set Discriminator PowerPulsing: {0}\n", cbxDiscriPP.Text);
                    txtReport.AppendText(report);
                }
                else
                {
                    MessageBox.Show("Set Discriminator PowerPulsing failure, please check USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                    return;
                }
                #endregion
                #region V_bg
                bResult = MicrorocChain1.SetPowerPulsing(cbxVbgPP.SelectedIndex, CommandHeader.VbgPowerPulsingIndex, MyUsbDevice1);
                if (bResult)
                {
                    string report = string.Format("Set V_bg PowerPulsing: {0}\n", cbxVbgPP.Text);
                    txtReport.AppendText(report);
                }
                else
                {
                    MessageBox.Show("Set V_bg PowerPulsing failure, please check USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                    return;
                }
                #endregion
                #region 10bit DAC
                bResult = MicrorocChain1.SetPowerPulsing(cbxDac10BitPP.SelectedIndex, CommandHeader.Dac10BitPowerPulsingIndex, MyUsbDevice1);
                if (bResult)
                {
                    string report = string.Format("Set 10-bit DAC PowerPulsing: {0}\n", cbxDac10BitPP.Text);
                    txtReport.AppendText(report);
                }
                else
                {
                    MessageBox.Show("Set 10-bit DAC PowerPulsing failure, please check USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                    return;
                }
                #endregion
                #region LVDS
                bResult = MicrorocChain1.SetPowerPulsing(cbxLvdsPP.SelectedIndex, CommandHeader.LvdsPowerPulsingIndex, MyUsbDevice1);
                if (bResult)
                {
                    string report = string.Format("Set LVDS PowerPulsing: {0}\n", cbxLvdsPP.Text);
                    txtReport.AppendText(report);
                }
                else
                {
                    MessageBox.Show("Set LVDS PowerPulsing failure, please check USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                    return;
                }
                #endregion
                #endregion
                for (int i = AsicNumber; i >= 0; i--)
                {
                    #region Header   
                    HeaderValue -= 1;
                    bResult = MicrorocChain1.SetAsicHeader(HeaderValue, MyUsbDevice1);
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
                        return;
                    }
                    #endregion
                    #region 10-bit DAC
                    #region Dac0
                    bResult = MicrorocChain1.Set10BitDac0(txtDAC0_VTH_ASIC[i].Text, MyUsbDevice1, out IllegalInput);
                    if (bResult)
                    {

                        string report = string.Format("Setting DAC0 VTH: {0}\n", txtDAC0_VTH_ASIC[i].Text);
                        txtReport.AppendText(report);
                    }
                    else if (IllegalInput)
                    {
                        MessageBox.Show("DAC value is illegal,please re-type(Integer:0--1023)", "Illegal input", MessageBoxButton.OK, MessageBoxImage.Error);
                        return;
                    }
                    else
                    {
                        MessageBox.Show("Set DAC0 failure. Please check USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                        return;
                    }
                    #endregion
                    #region DAC1
                    bResult = MicrorocChain1.Set10BitDac1(txtDAC1_VTH_ASIC[i].Text, MyUsbDevice1, out IllegalInput);
                    if (bResult)
                    {
                        string report = string.Format("Setting DAC1 VTH: {0}\n", txtDAC1_VTH_ASIC[i].Text);
                        txtReport.AppendText(report);
                    }
                    else if (IllegalInput)
                    {
                        MessageBox.Show("DAC value is illegal,please re-type(Integer:0--1023)", "Illegal input", MessageBoxButton.OK, MessageBoxImage.Error);
                        return;
                    }
                    else
                    {
                        MessageBox.Show("Set DAC1 failure. Please check USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                        return;
                    }
                    #endregion
                    #region DAC2
                    bResult = MicrorocChain1.Set10BitDac2(txtDAC2_VTH_ASIC[i].Text, MyUsbDevice1, out IllegalInput);
                    if (bResult)
                    {
                        string report = string.Format("Setting DAC2 VTH: {0}\n", txtDAC2_VTH_ASIC[i].Text);
                        txtReport.AppendText(report);
                    }
                    else if (IllegalInput)
                    {
                        MessageBox.Show("DAC value is illegal,please re-type(Integer:0--1023)", "Illegal input", MessageBoxButton.OK, MessageBoxImage.Error);
                        return;
                    }
                    else
                    {
                        MessageBox.Show("Set DAC0 failure. Please check USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                        return;
                    }
                    #endregion
                    #endregion
                    #region Shaper Output
                    bResult = MicrorocChain1.SelectHighOrLowGainShaper(cbxOut_sh_ASIC[i].SelectedIndex, MyUsbDevice1);
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
                        return;
                    }
                    #endregion
                    #region Shaper Output Enable
                    bResult = MicrorocChain1.SetShaperOutEnable(cbxShaper_Output_Enable_ASIC[i].SelectedIndex, MyUsbDevice1);
                    if (bResult)
                    {
                        string report = string.Format("You have {0} the shaper output", cbxShaper_Output_Enable_ASIC[i].Text);
                        txtReport.AppendText(report);
                    }
                    else
                    {
                        MessageBox.Show("Set shaper state failure. Please check the USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                        return;
                    }
                    #endregion
                    #region CTest Channel
                    bResult = MicrorocChain1.SetCTestChannel(txtCTest_ASIC[i].Text, MyUsbDevice1, out IllegalInput);
                    if (bResult)
                    {
                        string report = string.Format("Setting CTest channel: {0}\n", txtCTest_ASIC[i].Text);
                        txtReport.AppendText(report);


                    }
                    else if (IllegalInput)
                    {
                        MessageBox.Show("Ctest value is illegal,please re-type(Integer:0--64,or 255)", "Illegal input", MessageBoxButton.OK, MessageBoxImage.Error);
                        return;
                    }
                    else
                    {
                        MessageBox.Show("Set Ctest failure. Please check USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                        return;
                    }
                    #endregion
                    #region sw_hg sw_lg
                    bResult = MicrorocChain1.SetSWHighGainAndLowGain(cbxsw_hg_ASIC[i].SelectedIndex, cbxsw_lg_ASIC[i].SelectedIndex, MyUsbDevice1);
                    if (bResult)
                    {
                        string report = string.Format("Set sw_hg: {0}; sw_lg: {1}\n", cbxsw_hg_ASIC[i].Text, cbxsw_lg_ASIC[i].Text);
                        txtReport.AppendText(report);
                    }
                    else
                    {
                        MessageBox.Show("Set sw_hg and sw_lg failure. Please check USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                        return;
                    }
                    #endregion
                    #region Internal RAZ Time
                    bResult = MicrorocChain1.SelectInternalRazTime(cbxInternal_RAZ_Time_ASIC[i].SelectedIndex, MyUsbDevice1);
                    if (bResult)
                    {
                        string report = string.Format("Internal RAZ Mode: {0} \n", cbxInternal_RAZ_Time_ASIC[i].Text);
                        txtReport.AppendText(report);
                    }
                    else
                    {
                        MessageBox.Show("Set Internal RAZ Mode failed. Please check USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                        return;
                    }
                    #endregion
                    #region 4bitDAC Cali
                    string DCCaliFileName, SCTCaliFileName;
                    StreamReader DCCaliFile, SCTCaliFile;
                    DCCaliFileName = string.Format("DCCali{0}.txt", i);
                    SCTCaliFileName = string.Format("SCTCali{0}.txt", i);
                    DCCaliFileName = Path.Combine(CurrentPath, DCCaliFileName);
                    SCTCaliFileName = Path.Combine(CurrentPath, SCTCaliFileName);
                    DCCaliFile = File.OpenText(DCCaliFileName);
                    SCTCaliFile = File.OpenText(SCTCaliFileName);
                    switch (cbxPedCali_ASIC[i].SelectedIndex)
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
                    bResult = MicrorocChain1.SetChannelCalibration(MyUsbDevice1, CaliData);
                    if (bResult)
                    {
                        details.AppendFormat("Set 4-bit Calibration Successful\n");
                    }
                    else
                    {
                        MessageBox.Show("4bit-DAC Cali faliure. Please check USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                        return;
                    }
                    Thread.Sleep(10);

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
                    #region Set ChannelMask
                    // Clear the forer mask information
                    bResult = MicrorocChain1.SelectMaskOrUnmask(0, MyUsbDevice1);
                    if (bResult)
                    {
                        txtReport.AppendText("Mask Clear\n");
                    }
                    else
                    {
                        MessageBox.Show("Set Mask Channel faliure. Please check USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                        return;
                    }
                    if (txtMaskFile[i].Text != "No")
                    {
                        string FileName = txtMaskFile[i].Text;
                        string MaskFileName;
                        string MaskChannelString;
                        StreamReader MaskFile;
                        MaskFileName = Path.Combine(CurrentPath, FileName);
                        if (File.Exists(MaskFileName))
                        {
                            MaskFile = File.OpenText(MaskFileName);
                            MaskChannelString = MaskFile.ReadLine();
                            while (MaskChannelString != null)
                            {
                                int MaskChannel = int.Parse(MaskChannelString) - 1;
                                bResult = MicrorocChain1.SetMaskChannel(MaskChannel, MyUsbDevice1);
                                if (!bResult)
                                {
                                    MessageBox.Show("Set Mask Channel faliure. Please check USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                                    return;
                                }
                                bResult = MicrorocChain1.SelectMaskDiscriminator(7, MyUsbDevice1);
                                if (!bResult)
                                {
                                    MessageBox.Show("Set Mask Channel faliure. Please check USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                                    return;
                                }
                                bResult = MicrorocChain1.SelectMaskOrUnmask(1, MyUsbDevice1);
                                if (bResult)
                                {
                                    string report = string.Format("Set ASIC{0} Mask Channel{1}\n", i, MaskChannel + 1);
                                    txtReport.AppendText(report);
                                }
                                else
                                {
                                    MessageBox.Show("Set Mask Channel faliure. Please check USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                                    return;
                                }
                                MaskChannelString = MaskFile.ReadLine();
                            }
                        }
                    }
                    #endregion
                    #region Start Load
                    bResult = MicrorocChain1.LoadSlowControlParameter(MyUsbDevice1);
                    if (bResult)
                    {
                        string report = string.Format("Load No.{0} ASIC parameter done!\n", i + 1);
                        txtReport.AppendText(report);
                    }
                    else
                    {
                        MessageBox.Show("Load parameter failure, please check USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                        return;
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
                for (int i = AsicNumber; i >= 0; i--)
                {
                    #region Set ReadReg
                    bResult = MicrorocChain1.SetReadRegChannel(txtRead_reg_ASIC[i].Text, MyUsbDevice1, out IllegalInput);
                    if (bResult)
                    {
                        string report = string.Format("Setting ReadReg channel: {0}\n", txtRead_reg_ASIC[i].Text);
                        txtReport.AppendText(report);
                    }
                    else if (IllegalInput)
                    {
                        MessageBox.Show("ReadReg value is illegal,please re-type(Integer:0--64)", "Illegal input", MessageBoxButton.OK, MessageBoxImage.Error);
                    }
                    else
                    {
                        MessageBox.Show("Set ReadReg failure. Please check USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                    }
                    #endregion
                    #region Start Load
                    bResult = MicrorocChain1.LoadSlowControlParameter(MyUsbDevice1);
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
        }

        private void PowerPulsing_Checked(object sender, RoutedEventArgs e)
        {
            //Get Radiobutton reference
            var button = sender as RadioButton;
            //Display button content as title
            if (button.Content.ToString() == "Enable")
            {
                MicrorocPowerPulsingEnable();
            }
            else if (button.Content.ToString() == "Disable")
            {
                MicrorocPowerPulsingDisable();
            }
        }
        private void MicrorocPowerPulsingEnable()
        {
            bool bResult = MicrorocChain1.PowerPulsingCheck(true, MyUsbDevice1);
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
        private void MicrorocPowerPulsingDisable()
        {
            bool bResult = MicrorocChain1.PowerPulsingCheck(false, MyUsbDevice1);
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
        //Reset tntb
        private void btnReset_cntb_Click(object sender, RoutedEventArgs e)
        {
            bool bResult = MicrorocChain1.ResetCounterB(MyUsbDevice1);
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
            bool bResult = false;
            if (StateIndicator.ExternalTriggerEnabled == false) //open
            {
                bResult = MicrorocChain1.EnableExternalTrigger(true, MyUsbDevice1);
                if (bResult)
                {
                    StateIndicator.ExternalTriggerEnabled = true;
                    btnTRIG_EXT_EN.Background = Brushes.DeepPink;
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
                
                bResult = MicrorocChain1.EnableExternalTrigger(false, MyUsbDevice1);
                if (bResult)
                {
                    StateIndicator.ExternalTriggerEnabled = false;
                    btnTRIG_EXT_EN.Background = Brushes.Green;
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
            bool bResult = MicrorocChain1.SetExternalRazWidth(cbxRaz_mode.SelectedIndex, MyUsbDevice1);
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
            bool IllegalInput;
            #region Set Hold Delay
            bResult = MicrorocChain1.SetHoldDelayTime(txtHold_delay.Text, MyUsbDevice1, out IllegalInput);
            if (bResult)
            {
                string report = string.Format("Set Hold Delay Time:{0}ns\n", txtHold_delay.Text);
                txtReport.AppendText(report);
            }
            else if(IllegalInput)
            {
                MessageBox.Show("Illegal Hold delay, please re-type(Integer:0--650,step:2ns)", "Illegal input", MessageBoxButton.OK, MessageBoxImage.Error);
                return;
            }
            else
            {
                MessageBox.Show("Set Hold delay failure, please check USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                return;
            }
            #endregion
            #region Set Trig Coincide
            bResult = MicrorocChain1.SetTrigCoincidence(cbxTrig_Coincid.SelectedIndex, MyUsbDevice1);
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
            bResult = MicrorocChain1.SetHoldTime(txtHoldTime.Text, MyUsbDevice1, out IllegalInput);
            if (bResult)
            {
                string report = string.Format("Set Hold Time:{0}\n", txtHoldTime.Text);
                txtReport.AppendText(report);


            }
            else if (IllegalInput)
            {
                MessageBox.Show("Illegal Hold Time, please re-type(Integer:0--10000,step:2ns)", "Illegal input", MessageBoxButton.OK, MessageBoxImage.Error);
                return;
            }
            else
            {
                MessageBox.Show("Set Hold Time failure, please check USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                return;
            }
            #endregion
            #region Hold Enable
            bResult = MicrorocChain1.EnableHold(cbxHoldEnable.SelectedIndex == 1, MyUsbDevice1);
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
            bool IllegalInput;
            bool bResult = MicrorocChain1.SetAcquisitionTime(txtStartAcqTime.Text, MyUsbDevice1, out IllegalInput);
            if (bResult)
            {
                string report = string.Format("Set StartAcq time : {0}\n", txtStartAcqTime.Text);
                txtReport.AppendText(report);
            }
            else if (IllegalInput)
            {
                MessageBox.Show("Illegal StartAcq Time, please re-type(Integer:0--1638400,step:25ns)", //text
                                 "Illegal input",   //caption
                                 MessageBoxButton.OK,//button
                                 MessageBoxImage.Error);//icon
            }
            else
            {
                MessageBox.Show("Set StartAcq time failure, please check USB", //text
                                 "USB Error",   //caption
                                 MessageBoxButton.OK,//button
                                 MessageBoxImage.Error);//icon
            }
        }
        //Set which ASIC OUT_T&H output
        private void btnOut_th_set_Click(object sender, RoutedEventArgs e)
        {
            bool bResult = MicrorocChain1.SelectHoldOutput(cbxOut_th.SelectedIndex, MyUsbDevice1);
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
        
        //设定EXT_RAZ延迟A8XX
        private void btnSet_External_RAZ_Delay_Click(object sender, RoutedEventArgs e)
        {
            bool IllegalInput;
            bool bResult = MicrorocChain1.SetExternalRazDelayTime(txtExternal_RAZ_Delay.Text, MyUsbDevice1, out IllegalInput);
            if (bResult)
            {
                string report = string.Format("Set External RAZ Delay time:{0} ns\n", txtExternal_RAZ_Delay.Text);
            }
            else if (IllegalInput)
            {
                MessageBox.Show("Illegal External RAZ Delay Time, please re-type(Integer:0--400ns,step:25ns)", "Ilegal Input", MessageBoxButton.OK, MessageBoxImage.Error);
            }
            else
            {
                MessageBox.Show("select failure, please check USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        // Select Trigger efficiency test or counter efficiency test
        private void Trig_or_Count_Checked(object sender, RoutedEventArgs e)
        {
            var button = sender as RadioButton;
            bool bResult = false;
            if(button.Content.ToString() == "Trig")
            {
                cbxCPT_MAX.IsEnabled = true;
                txtCountTime.IsEnabled = false;
                bResult = MicrorocChain1.SelectTrigOrCounterMode(0, MyUsbDevice1);
                if (bResult)
                {
                    StateIndicator.SCurveModeSelect = StateIndicator.SCurveMode.Trig;
                    txtReport.AppendText("You are testing Trigger-Efficiency\n");
                }
                else
                {
                    MessageBox.Show("select failure, please check USB", //text
                                     "USB Error",   //caption
                                     MessageBoxButton.OK,//button
                                     MessageBoxImage.Error);//icon
                    return;
                }
            }
            else if(button.Content.ToString() == "Count")
            {
                txtCountTime.IsEnabled = true;
                cbxCPT_MAX.IsEnabled = false;
                bResult = MicrorocChain1.SelectTrigOrCounterMode(1, MyUsbDevice1);
                if (bResult)
                {
                    StateIndicator.SCurveModeSelect = StateIndicator.SCurveMode.Count;
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
                StateIndicator.DataRateModeSelect = StateIndicator.DataRateMode.Fast;            
            }
            else if(button.Content.ToString() == "Slow")
            {
                btnAcqStart.IsEnabled = false;
                btnSlowACQ.IsEnabled = true;
                txtSlowACQDataNum.IsEnabled = true;
                Regex rx_int = new Regex(rx_Integer);
                StateIndicator.DataRateModeSelect = StateIndicator.DataRateMode.Slow;             
            }
        }
        // Slow data rate ACQ
        private async void btnSlowACQ_Click(object sender, RoutedEventArgs e)
        {
            if (!CheckFileSaved())
            {
                return;
            }
            bool bResult;
            bool IllegalInput;
            if (!StateIndicator.SlowAcqStart)
            {
                #region Start Slow Acq
                #region Set Start Acq Time
                bResult = MicrorocChain1.SetAcquisitionTime(txtStartAcqTime.Text, MyUsbDevice1, out IllegalInput);
                if (bResult)
                {
                    string report = string.Format("Set StartAcq time : {0}\n", txtStartAcqTime.Text);
                    txtReport.AppendText(report);
                }
                else if (IllegalInput)
                {
                    MessageBox.Show("Illegal StartAcq Time, please re-type(Integer:0--1638400,step:25ns)", //text
                                     "Illegal input",   //caption
                                     MessageBoxButton.OK,//button
                                     MessageBoxImage.Error);//icon
                    return;
                }
                else
                {
                    MessageBox.Show("Set StartAcq time failure, please check USB", //text
                                     "USB Error",   //caption
                                     MessageBoxButton.OK,//button
                                     MessageBoxImage.Error);//icon
                    return;
                }
                #endregion
                #region Set End Hold Time
                if (StateIndicator.DaqModeSelect == StateIndicator.DaqMode.SlaveDaq)
                {
                    bResult = MicrorocChain1.SetEndHoldTime(txtEndHoldTime.Text, MyUsbDevice1, out IllegalInput);
                    if (bResult)
                    {
                        string report = string.Format("Set End Signal Time:{0}\n", txtEndHoldTime.Text);
                        txtReport.AppendText(report);
                    }
                    else if (IllegalInput)
                    {
                        MessageBox.Show("Illegal End Signal Hold Time, please re-type(Integer:0--1638400,step:25ns)", //text
                                     "Illegal input",   //caption
                                     MessageBoxButton.OK,//button
                                     MessageBoxImage.Error);//icon
                        return;
                    }
                    else
                    {
                        MessageBox.Show("Set End Hold Time Failure, please check USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                        return;
                    }
                }
                #endregion
                #region Set Acquisition Data Number
                bool IsDataNumberLegal = MicrorocChain1.CheckIntegerLegal(txtSlowACQDataNum.Text);
                if (IsDataNumberLegal)
                {
                    StateIndicator.SlowAcqDataNumber = int.Parse(txtSlowACQDataNum.Text);

                }
                else
                {
                    StateIndicator.SlowAcqDataNumber = 5120;
                    txtSlowACQDataNum.Text = string.Format("{0}", 5120);
                }
                StateIndicator.SlowDataRatePackageNumber = StateIndicator.SlowAcqDataNumber * 20;
                #endregion
                #region Clear USB FIFO and Reset Microroc
                bResult = MicrorocChain1.ClearUsbFifo(MyUsbDevice1);
                if (bResult)
                    txtReport.AppendText("Usb Fifo clear \n");
                else
                {
                    MessageBox.Show("USB FIFO Clear Failure", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                    return;
                }
                bResult = MicrorocChain1.ResetMicroroc(MyUsbDevice1);
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
                #region DAQ
                bResult = MicrorocChain1.ResetCounterB(MyUsbDevice1);
                if(bResult)
                {
                    txtReport.AppendText("Reset grey counter successfully\n");
                }
                else
                {
                    MessageBox.Show("Please check the USB cable", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                }
                bResult = MicrorocChain1.StartAcquisition(MyUsbDevice1);
                //bResult = true;
                if (bResult)
                {
                    StateIndicator.SlowAcqStart = true;
                    txtReport.AppendText("Slow data rate ACQ Start\n");
                    txtReport.AppendText("Slow data rate Acq Contunue\n");
                    btnSlowACQ.Content = "Stop";
                    await Task.Run(() => GetSlowDataRateResultCallBack(MyUsbDevice1));
                    bResult = MicrorocChain1.StopAcquisition(MyUsbDevice1);
                    if (bResult)
                    {
                        btnSlowACQ.Content = "Slow ACQ";
                        StateIndicator.SlowAcqStart = false;
                        StateIndicator.FileSaved = false;
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
                #endregion
                #endregion
            }
            else
            {
                #region Stop ACQ
                StateIndicator.FileSaved = false;
                StateIndicator.SlowAcqStart = false;
                bResult = MicrorocChain1.StopAcquisition(MyUsbDevice1);
                if (bResult)
                {
                    btnSlowACQ.Content = "Slow ACQ";
                    txtReport.AppendText("Slow data rate ACQ Abort\n");
                }
                else
                {
                    StateIndicator.SlowAcqStart = true;
                    txtReport.AppendText("Slow data rate ACQ Stop failure\n");
                }
                #endregion
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
                gbxSweepTest.IsEnabled = false;
                gbxAD9220.IsEnabled = false;
                btnSC_or_ReadReg.IsEnabled = true;
                StateIndicator.OperationModeSelect = StateIndicator.OperationMode.Acq;
                bResult = MicrorocChain1.SelectOperationMode(CommandHeader.AcqModeIndex, MyUsbDevice1);
                if (bResult)
                {
                    txtReport.AppendText("Select ACQ mode\n");
                }
                else
                {
                    MessageBox.Show("Set ACQ Mode Failure. Please check the USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                    return;
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
                btnSC_or_ReadReg.IsEnabled = false;
                StateIndicator.OperationModeSelect = StateIndicator.OperationMode.SCTest;
                bResult = MicrorocChain1.SelectOperationMode(CommandHeader.SCurveTestModeIndex, MyUsbDevice1);
                if (bResult)
                {
                    txtReport.AppendText("Select S Curve Test Mode");
                }
                else
                {
                    MessageBox.Show("Set S Curve Test mode failure. Please check the USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                    return;
                }
                bResult = MicrorocChain1.SelectAcquisitionMode(false, MyUsbDevice1);
                if(bResult)
                {
                    txtReport.AppendText("External Raz Release \n");
                }
                else
                {
                    MessageBox.Show("Set S Curve Test mode failure. Please check the USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                    return;
                }
            }
            else if(botton.Content.ToString() == "SweepACQ")
            {
                gbxNormalAcq.IsEnabled = false;
                gbxSweepTest.IsEnabled = true;
                gbxSCurveTest.IsEnabled = false;
                gbxSweepAcq.IsEnabled = true;
                gbxAD9220.IsEnabled = false;
                btnSC_or_ReadReg.IsEnabled = false;
                StateIndicator.OperationModeSelect = StateIndicator.OperationMode.SweepAcq;
                bResult = MicrorocChain1.SelectOperationMode(CommandHeader.SweepAcqModeIndex, MyUsbDevice1);
                if(bResult)
                {
                    txtReport.AppendText("Select Sweep Acq mode \n");
                }
                else
                {
                    MessageBox.Show("Set Sweep ACQ Test mode failure. Please check the USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                    return;
                }
                bResult = MicrorocChain1.SelectAcquisitionMode(false, MyUsbDevice1);
                if (bResult)
                {
                    txtReport.AppendText("External Raz Release \n");
                }
                else
                {
                    MessageBox.Show("Set Sweep ACQ Test mode failure. Please check the USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                    return;
                }
            }
            else if(botton.Content.ToString() == "AD9220")
            {
                gbxNormalAcq.IsEnabled = false;
                gbxSweepTest.IsEnabled = false;
                gbxAD9220.IsEnabled = true;
                btnSC_or_ReadReg.IsEnabled = true;
                StateIndicator.OperationModeSelect = StateIndicator.OperationMode.ADC;
                bResult = MicrorocChain1.SelectOperationMode(CommandHeader.AdcModeIndex, MyUsbDevice1);
                if(bResult)
                {
                    txtReport.AppendText("Select AD9220\n");
                }
                else
                {
                    MessageBox.Show("Set AD9220 mode failure. Please check the USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                    return;
                }
                bResult = MicrorocChain1.SelectAcquisitionMode(false, MyUsbDevice1);
                if (bResult)
                {
                    txtReport.AppendText("External Raz Release \n");
                }
                else
                {
                    MessageBox.Show("Set AD9220 mode failure. Please check the USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                    return;
                }
            }
            else if(botton.Content.ToString() == "Efficiency")
            {
                gbxNormalAcq.IsEnabled = false;
                gbxSweepTest.IsEnabled = true;
                gbxSCurveTest.IsEnabled = true;
                gbxSweepAcq.IsEnabled = false;
                gbxAD9220.IsEnabled = false;
                btnSweepTestStart.IsEnabled = true;
                btnSC_or_ReadReg.IsEnabled = true;
                StateIndicator.OperationModeSelect = StateIndicator.OperationMode.Efficiency;
                bResult = MicrorocChain1.SelectOperationMode(CommandHeader.EfficiencyModeIndex, MyUsbDevice1);
                if (bResult)
                {
                    txtReport.AppendText("Select AD9220\n");
                }
                else
                {
                    MessageBox.Show("Set Efficiency mode failure. Please check the USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                    return;
                }
                bResult = MicrorocChain1.SelectAcquisitionMode(false, MyUsbDevice1);
                if (bResult)
                {
                    txtReport.AppendText("External Raz Release \n");
                }
                else
                {
                    MessageBox.Show("Set Efficiency mode failure. Please check the USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                }
            }
        }

        private async void btnSweepTestStart_Click(object sender, RoutedEventArgs e)
        {
            #region Check File Legal
            if (!CheckFileSaved())
            {
                return;
            }
            #endregion
            bool bResult;
            bool IllegalInput;
            string report;
            if (!StateIndicator.SlowAcqStart)
            {
                #region Start ACQ
                #region Start and End DAC
                bResult = MicrorocChain1.SetSCTestStartAndStopDacCode(txtStartDac.Text, txtEndDac.Text, MyUsbDevice1, out IllegalInput);
                if (bResult)
                {
                    report = string.Format("Set StartDAC:{0}\n", txtStartDac.Text);
                    txtReport.AppendText(report);
                    report = string.Format("Set EndDAC:{0}\n", txtEndDac.Text);
                    txtReport.AppendText(report);
                }
                else if (IllegalInput)
                {
                    MessageBox.Show("Ilegal input the StartDAC and EndDAC. The StartDAC should less than EndDAC\n", "Ilegal Input", MessageBoxButton.OK, MessageBoxImage.Error);
                    return;
                }
                else
                {
                    MessageBox.Show("Set StartDAC failure. Please check the USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                    return;
                }
                #endregion
                #region Set AdcInterval
                bResult = MicrorocChain1.SetSCTestDacInterval(txtAdcInterval.Text, MyUsbDevice1, out IllegalInput);
                if (bResult)
                {
                    report = string.Format("Set Adc Interval:{0}\n", txtAdcInterval.Text);
                    txtReport.AppendText(report);
                }
                else if (IllegalInput)
                {
                    MessageBox.Show("Ilegal input the ADC Interval. The StartDAC should less than EndDAC\n", "Ilegal Input", MessageBoxButton.OK, MessageBoxImage.Error);
                    return;
                }
                else
                {
                    MessageBox.Show("Set Adc Interval failure. Please check the USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                    return;
                }
                #endregion
                int StartDac = int.Parse(txtStartDac.Text);
                int EndDac = int.Parse(txtEndDac.Text);
                int AdcInterval = int.Parse(txtAdcInterval.Text);
                #region SCurve
                if (StateIndicator.OperationModeSelect == StateIndicator.OperationMode.SCTest)
                {
                    #region Set Single Test Channel
                    bResult = MicrorocChain1.SetSCTestSingleChannelNumber(txtSingleTest_Chn.Text, MyUsbDevice1, out IllegalInput);
                    if (bResult)
                    {
                        {
                            report = string.Format("Set single test channel:{0}", txtSingleTest_Chn.Text);
                            txtReport.AppendText(report);
                        }

                    }
                    else if (IllegalInput)
                    {
                        MessageBox.Show("Ilegal input the channel must between 1 to 64\n", "Ilegal Input", MessageBoxButton.OK, MessageBoxImage.Error);
                        return;
                    }
                    else
                    {
                        MessageBox.Show("Set single test channel failure. Please check the USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                        return;
                    }
                    #endregion
                    #region Set Single or Auto
                    bResult = MicrorocChain1.SelectSCTestSingleOrAllChannel(cbxSingleOrAuto.SelectedIndex, MyUsbDevice1);
                    if (bResult)
                    {
                        report = string.Format("Choose {0} Mode\n", cbxSingleOrAuto.Text);
                        txtReport.AppendText(report);
                    }
                    else
                    {
                        MessageBox.Show("Set S Curve channel mode failure. Please check the USB\n", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                        return;
                    }
                    #endregion
                    #region Set CTest or Input
                    bResult = MicrorocChain1.SelectSCTestSignalCTestOrInput(cbxCTestOrInput.SelectedIndex, MyUsbDevice1);
                    if (bResult)
                    {
                        report = string.Format("Choose {0} Mode\n", cbxCTestOrInput.Text);
                        txtReport.AppendText(report);
                    }
                    else
                    {
                        MessageBox.Show("Set charge inject method failure. Please check the USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                        return;
                    }
                    #endregion
                    #region Set Trigger Delay
                    bResult = MicrorocChain1.SetTriggerDelayTime(txtTriggerDelay.Text, MyUsbDevice1, out IllegalInput);
                    if (bResult)
                    {
                        report = string.Format("Set Trigger Delay {0}\n", txtTriggerDelay.Text);
                        txtReport.AppendText(report);
                    }
                    else if (IllegalInput)
                    {
                        MessageBox.Show("Illegal input. Retype TriggerDelay: 0~400", "Illegal Input", MessageBoxButton.OK, MessageBoxImage.Error);
                        return;
                    }
                    else
                    {
                        MessageBox.Show("Set Trigger Delay failure. Please check the USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                        return;
                    }
                    #endregion
                    #region Set Unmask
                    bResult = MicrorocChain1.SetSCTestChannelMaskMode(cbxUnmaskAllChannel.SelectedIndex, MyUsbDevice1);
                    if (bResult)
                    {
                        report = string.Format("Set All channel {0}\n", cbxUnmaskAllChannel.Text);
                        txtReport.AppendText(report);
                    }
                    else
                    {
                        MessageBox.Show("Set Trigger Delay failure. Please check the USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                        return;
                    }
                    #endregion
                    #region Trig Mode
                    //--- Trig Mode ---//
                    if (StateIndicator.SCurveModeSelect == StateIndicator.SCurveMode.Trig)
                    {
                        #region Set CPT_MAX
                        bResult = MicrorocChain1.SelectSCTestTrigMaxCount(cbxCPT_MAX.SelectedIndex, MyUsbDevice1);
                        if (bResult)
                        {
                            report = string.Format("Set MAX count number {0}", cbxCPT_MAX.Text);
                            txtReport.AppendText(report);
                        }
                        else
                        {
                            MessageBox.Show("Set SCurve test max count failure. Please check the USB\n", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                            return;
                        }
                        #endregion
                        #region Single Channel Mode
                        //--- Single Channel Test ---///
                        if (cbxSingleOrAuto.SelectedIndex == SingleChannel)
                        {
                            //*** Set Package Number
                            StateIndicator.SlowDataRatePackageNumber = HeaderLength + ChannelLength + ((EndDac - StartDac) / AdcInterval + 1) * OneDacDataLength + TailLength;
                        }
                        #endregion
                        #region 64 Channel Mode
                        //--- 64 Channel Test ---//
                        else if (cbxSingleOrAuto.SelectedIndex == AllChannel)
                        {
                            //*** Set Package Number
                            StateIndicator.SlowDataRatePackageNumber = HeaderLength + (ChannelLength + ((EndDac - StartDac) / AdcInterval + 1) * OneDacDataLength) * 64 + TailLength;
                        }
                        #endregion
                    }
                    #endregion
                    #region Count Mode
                    else if (StateIndicator.SCurveModeSelect == StateIndicator.SCurveMode.Count)
                    {
                        #region Set Count Time
                        //*** Set Max Count Time
                        bResult = MicrorocChain1.SetSCTestCountModeTime(txtCountTime.Text, MyUsbDevice1, out IllegalInput);
                        if (bResult)
                        {
                            report = string.Format("Set count time:{0}", txtCountTime.Text);
                            txtReport.AppendText(report);
                        }
                        else if (IllegalInput)
                        {
                            MessageBox.Show("Illegal count time, please re-type(Integer:0--65536)", //text
                                     "Illegal input",   //caption
                                     MessageBoxButton.OK,//button
                                     MessageBoxImage.Error);//icon
                            return;
                        }
                        else
                        {
                            MessageBox.Show("Set count time failure. Please check the ", //text
                                 "USB Error",   //caption
                                 MessageBoxButton.OK,//button
                                 MessageBoxImage.Error);//icon
                            return;
                        }
                        #endregion
                        #region Single Channel Mode
                        if (cbxSingleOrAuto.SelectedIndex == SingleChannel)
                        {
                            //*** Set Package Number
                            StateIndicator.SlowDataRatePackageNumber = HeaderLength + ChannelLength + ((EndDac - StartDac) / AdcInterval + 1) * OneDacDataLength + TailLength;
                        }
                        #endregion
                        #region 64Channel Mode
                        else if (cbxSingleOrAuto.SelectedIndex == AllChannel)
                        {
                            //*** Set Package Number
                            StateIndicator.SlowDataRatePackageNumber = HeaderLength + (ChannelLength + ((EndDac - StartDac) / AdcInterval + 1) * OneDacDataLength) * 64 + TailLength;
                        }
                        #endregion
                    }
                    #endregion
                }
                #endregion
                #region Sweep Acq
                else if (StateIndicator.OperationModeSelect == StateIndicator.OperationMode.SweepAcq)
                {
                    #region Set Start Acq Time
                    bResult = MicrorocChain1.SetAcquisitionTime(txtStartAcqTime.Text, MyUsbDevice1, out IllegalInput);
                    if (bResult)
                    {
                        report = string.Format("Set StartAcq time : {0}\n", txtStartAcqTime.Text);
                        txtReport.AppendText(report);
                    }
                    else if (IllegalInput)
                    {
                        MessageBox.Show("Illegal StartAcq Time, please re-type(Integer:0--1638400,step:25ns)", //text
                                         "Illegal input",   //caption
                                         MessageBoxButton.OK,//button
                                         MessageBoxImage.Error);//icon
                        return;
                    }
                    else
                    {
                        MessageBox.Show("Set StartAcq time failure, please check USB", //text
                                         "USB Error",   //caption
                                         MessageBoxButton.OK,//button
                                         MessageBoxImage.Error);//icon
                        return;
                    }
                    #endregion
                    #region Set Package Number
                    int PackageNumberValue;
                    bResult = MicrorocChain1.SetSweepAcqMaxCount(txtPackageNumber.Text, MyUsbDevice1, out IllegalInput);
                    if (bResult)
                    {
                        report = string.Format("Set sweep acq package number:{0}\n", txtPackageNumber.Text);
                        txtReport.AppendText(report);
                        PackageNumberValue = int.Parse(txtPackageNumber.Text);
                    }
                    else if (IllegalInput)
                    {
                        MessageBox.Show("Illegal Package Number. Please retype: Integer", "Illegal Input", MessageBoxButton.OK, MessageBoxImage.Error);
                        return;
                    }
                    else
                    {
                        MessageBox.Show("Set count time failure. Please check the USB ", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                        return;
                    }
                    #endregion
                    #region Set Sweep DAC
                    bResult = MicrorocChain1.SelectSweepAcqDac(cbxDacSelect.SelectedIndex, MyUsbDevice1);

                    if (bResult)
                    {
                        report = string.Format("Set {0} as sweep DAC\n", cbxDacSelect.Text);
                        txtReport.AppendText(report);
                    }
                    else
                    {
                        MessageBox.Show("Set Sweep DAC failure. Please check the USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                        return;
                    }
                    #endregion
                    //*** Set Package Number
                    StateIndicator.SlowDataRatePackageNumber = HeaderLength + (2 + PackageNumberValue * 20) * ((EndDac - StartDac) / AdcInterval + 1) + TailLength;
                }
                #endregion
                #region Efficiency
                else if (StateIndicator.OperationModeSelect == StateIndicator.OperationMode.Efficiency)
                {
                    #region Set CPT_MAX
                    bResult = MicrorocChain1.SelectSCTestTrigMaxCount(cbxCPT_MAX.SelectedIndex, MyUsbDevice1);
                    if (bResult)
                    {
                        report = string.Format("Set MAX count number {0}", cbxCPT_MAX.Text);
                        txtReport.AppendText(report);
                    }
                    else
                    {
                        MessageBox.Show("Set S Curve test max count failure. Please check the USB\n", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                        return;
                    }
                    #endregion
                    #region Set Trigger Delay
                    bResult = MicrorocChain1.SetTriggerDelayTime(txtTriggerDelay.Text, MyUsbDevice1, out IllegalInput);
                    if (bResult)
                    {
                        report = string.Format("Set Trigger Delay {0}\n", txtTriggerDelay.Text);
                        txtReport.AppendText(report);
                    }
                    else if (IllegalInput)
                    {
                    }
                    else
                    {
                        MessageBox.Show("Set Trigger Delay failure. Please check the USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                        return;
                    }
                    #endregion
                    StateIndicator.SlowDataRatePackageNumber = 7 * 2;
                }
                #endregion
                #region Clear USB FIFO
                bResult = MicrorocChain1.ClearUsbFifo(MyUsbDevice1);
                if (bResult)
                    txtReport.AppendText("USB fifo cleared");
                else
                {
                    MessageBox.Show("Please chek the USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                    return;

                }
                #endregion
                #region Data ACQ
                Thread.Sleep(100);
                bResult = MicrorocChain1.StartSCTest(MyUsbDevice1);
                if (bResult)
                {
                    StateIndicator.SlowAcqStart = true;
                    txtReport.AppendText("Sweep Acq Test Start\n");
                    txtReport.AppendText("Sweep Acq Continue\n");
                    btnSweepTestStart.Content = "Sweep Test Stop";
                    await Task.Run(() => GetSlowDataRateResultCallBack(MyUsbDevice1));
                    btnSweepTestStart.Content = "Sweep Acq Start";
                    bResult = MicrorocChain1.StopSCTest(MyUsbDevice1);
                    if (bResult)
                    {
                        btnSweepTestStart.Content = "Sweep Test Start";
                        txtReport.AppendText("Sweep Acq Test Stop\n");
                    }
                    else
                    {
                        txtReport.AppendText("Sweep Acq Test Stop Failure\n");
                    }
                    Thread.Sleep(10);
                    StateIndicator.SlowAcqStart = false;
                    StateIndicator.FileSaved = false;
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
                #region Stop ACQ
                StateIndicator.SlowAcqStart = false;
                StateIndicator.FileSaved = false;
                bResult = MicrorocChain1.StopSCTest(MyUsbDevice1);
                if (bResult)
                {

                    btnSweepTestStart.Content = "Sweep Test Start";
                    txtReport.AppendText("SCurve Test Abort\n");
                }
                else
                {
                    txtReport.AppendText("SCurve Test Stop Failure\n");
                }
                #endregion
            }
        }

        private async void btnStartAdc_Click(object sender, RoutedEventArgs e)
        {
            if (!CheckFileSaved())
            {
                return;
            }
            if (!StateIndicator.AdcStart)
            {
                #region Set ADC Delay
                bool IllegalInput;
                bool bResult = MicrorocChain1.SetAdcStartDelayTime(txtStartDelay.Text, MyUsbDevice1, out IllegalInput);
                if (bResult)
                {
                    string report = string.Format("Set ADC start delay :{0}ns\n", txtStartDelay.Text);
                    txtReport.AppendText(report);
                }
                else if (IllegalInput)
                {
                    MessageBox.Show("Delay time is not correct, please retype:0-400 integer", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                    return;
                }
                else
                {
                    MessageBox.Show("Set ADC start delay failure, please check the USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                    return;
                }
                #endregion
                #region Set Hold Parameter
                #region Set Hold Delay
                bResult = MicrorocChain1.SetHoldDelayTime(txtHold_delay.Text, MyUsbDevice1, out IllegalInput);
                if (bResult)
                {
                    string report = string.Format("Set Hold Delay Time:{0}ns\n", txtHold_delay.Text);
                    txtReport.AppendText(report);
                }
                else if (IllegalInput)
                {
                    MessageBox.Show("Illegal Hold delay, please re-type(Integer:0--650,step:2ns)", "Illegal input", MessageBoxButton.OK, MessageBoxImage.Error);
                    return;
                }
                else
                {
                    MessageBox.Show("Set Hold delay failure, please check USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                    return;
                }
                #endregion
                #region Set Trig Coincide
                bResult = MicrorocChain1.SetTrigCoincidence(cbxTrig_Coincid.SelectedIndex, MyUsbDevice1);
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
                bResult = MicrorocChain1.SetHoldTime(txtHoldTime.Text, MyUsbDevice1, out IllegalInput);
                if (bResult)
                {
                    string report = string.Format("Set Hold Time:{0}\n", txtHoldTime.Text);
                    txtReport.AppendText(report);
                }
                else if (IllegalInput)
                {
                    MessageBox.Show("Illegal Hold Time, please re-type(Integer:0--10000,step:2ns)", "Illegal input", MessageBoxButton.OK, MessageBoxImage.Error);
                    return;
                }
                else
                {
                    MessageBox.Show("Set Hold Time failure, please check USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                    return;
                }
                #endregion
                #endregion
                #region Set Adc Data Number
                bResult = MicrorocChain1.SetAdcDataNumberPerHit(txtAdcAcqTimes.Text, MyUsbDevice1, out IllegalInput);
                if (bResult)
                {
                    string report = string.Format("Set Adc Data Nmuber:{0}\n", txtAdcAcqTimes.Text);
                    txtReport.AppendText(report);
                }
                else if (IllegalInput)
                {
                    MessageBox.Show("Adc data number incorrect. Please re-type:0-255 integer", "Illegal Input", MessageBoxButton.OK, MessageBoxImage.Error);
                    return;
                }
                else
                {
                    MessageBox.Show("Set ADC Data Times failure, please check the USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                    return;
                }
                #endregion
                #region Set ADC Input
                bResult = MicrorocChain1.SelectAdcMonitorHoldOrTemp(cbxAdcInput.SelectedIndex, MyUsbDevice1);
                if (bResult)
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
                #region Set Adc Start Mode
                /*int AdcStartModeValue = cbxAdcStartMode.SelectedIndex + 128;//0x80
                CommandBytes = ConstCommandByteArray(0xE8, (byte)AdcStartModeValue);
                bResult = CommandSend(CommandBytes, CommandBytes.Length);
                if (bResult)
                {
                    string report = string.Format("Select ADC Start{0}\n", cbxAdcStartMode.Text);
                    txtReport.AppendText(report);
                }
                else
                {
                    MessageBox.Show("Set ADC Start Mode failure, please check USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                }
                */
                #endregion
                #region Start Acq
                bResult = MicrorocChain1.ClearUsbFifo(MyUsbDevice1);
                if(bResult)
                {
                    txtReport.AppendText("Clear USB FIFO\n");
                }
                else
                {
                    MessageBox.Show("Please check the USB cable", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                }
                bResult = MicrorocChain1.StartAdc(MyUsbDevice1);
                if (bResult)
                {
                    btnStartAdc.Content = "ADC Stop";
                    btnStartAdc.Background = Brushes.Blue;
                    StateIndicator.AdcStart = true;
                    await Task.Run(() => GetSlowDataRateResultCallBack(MyUsbDevice1));
                    bResult = MicrorocChain1.StopAdc(MyUsbDevice1);
                    if (bResult)
                    {
                        StateIndicator.AdcStart = false;
                        btnAcqStart.Background = Brushes.Green;
                        btnAcqStart.Content = "ADC Start";
                        txtReport.AppendText("ADC Stopped\n");
                    }
                    else
                    {
                        MessageBox.Show("ADC Stop failure, please check USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                        return;
                    }
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
                bool bResult = MicrorocChain1.StopAdc(MyUsbDevice1);
                if (bResult)
                {
                    StateIndicator.FileSaved = false;
                    StateIndicator.AdcStart = false;
                    btnStartAdc.Background = Brushes.Green;
                    btnStartAdc.Content = "ADC Start";
                    txtReport.AppendText("ADC Abort\n");
                }
                else
                {
                    txtReport.AppendText("Stop ADC Failure \n");
                    return;
                }
                #endregion
            }


        }
        // Slow data rate acquisition thread
        private void GetSlowDataRateResultCallBack(MyCyUsb usbInterface)
        {
            bw = new BinaryWriter(File.Open(filepath, FileMode.Append));
            //private int SingleDataLength = 512;
            bool bResult = false;
            byte[] DataReceiveBytes = new byte[512];
            #region The Max Data Number is Set
            if (StateIndicator.SlowDataRatePackageNumber != 0)
            {
                int PackageNumber = StateIndicator.SlowDataRatePackageNumber / 512;
                int RemainPackageNum = StateIndicator.SlowDataRatePackageNumber % 512;
                int TotalPackageNumber = RemainPackageNum == 0 ? PackageNumber : (PackageNumber + 1);
                int PackageCount = 0;
                while (PackageCount < TotalPackageNumber & StateIndicator.SlowAcqStart)
                {
                    //Stopwatch sw = new Stopwatch();
                    //sw.Start();
                    bResult = usbInterface.DataRecieve(DataReceiveBytes, DataReceiveBytes.Length);
                    //sw.Stop();

                    if (bResult)
                    {
                        bw.Write(DataReceiveBytes);
                        PackageCount++;
                    }
                }
                /*if (RemainPackageNum != 0)
                {
                    bResult = false;
                    byte[] RemainByte = new byte[2048];
                    while (!usbInterface.DataRecieve(RemainByte, RemainByte.Length) & StateIndicator.SlowAcqStart) ;
                    byte[] RemainByteWrite = new byte[RemainPackageNum];
                    for (int i = 0; i < RemainPackageNum; i++)
                    {
                        RemainByteWrite[i] = RemainByte[i];
                    }
                    bw.Write(RemainByteWrite);
                }*/
            }
            #endregion
            #region The Max Data Number is not set and work in consist mode
            else
            {
                while (StateIndicator.SlowAcqStart)
                {
                    bResult = usbInterface.DataRecieve(DataReceiveBytes, DataReceiveBytes.Length);
                    if (bResult)
                    {
                        bw.Write(DataReceiveBytes);
                    }
                }
            }
            #endregion
            bw.Flush();
            bw.Dispose();
            bw.Close();
        }

        private void DaqModeSelect_Checked(object sender, RoutedEventArgs e)
        {
            var button = sender as RadioButton;
            bool bResult = false;
            if(button.Content.ToString() == "Auto")
            {
                StateIndicator.DaqModeSelect = StateIndicator.DaqMode.AutoDaq;
                txtEndHoldTime.IsEnabled = false;
                btnSlowACQ.Content = "SlowACQ";
                btnSC_or_ReadReg.IsEnabled = true;
                #region Set Internal RAZ
                bResult = MicrorocChain1.SelectRazChannel(0, MyUsbDevice1);
                if (bResult)
                {
                    txtReport.AppendText("Set Raz Mode: Internal\n");
                }
                else
                {
                    MessageBox.Show("Set Raz Mode failure, please check USB", //text
                                 "USB Error",   //caption
                                 MessageBoxButton.OK,//button
                                 MessageBoxImage.Error);//icon
                    return;
                }
                #endregion
                bResult = MicrorocChain1.SelectAcquisitionMode(false, MyUsbDevice1);
                if (bResult)
                {
                    string report = string.Format("Set DAQ Mode: {0} DAQ\n", button.Content.ToString());
                    txtReport.AppendText(report);
                }
                else
                {
                    MessageBox.Show("Set DAQ Mode failure, please check USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                }
            }
            else if(button.Content.ToString() == "Slave")
            {
                StateIndicator.DaqModeSelect = StateIndicator.DaqMode.SlaveDaq;
                txtSlowACQDataNum.Text = "0";
                bool IllegalInput;
                btnSlowACQ.Content = "Cosmic Ray Test";
                txtEndHoldTime.IsEnabled = true;
                btnSC_or_ReadReg.IsEnabled = false;
                #region DAC VTH
                bResult = MicrorocChain1.Set10BitDac0(txtDAC0_VTH_ASIC1.Text, MyUsbDevice1, out IllegalInput);
                if (bResult)
                {
                    string report = string.Format("Setting DAC0 VTH: {0}\n", txtDAC0_VTH_ASIC1.Text);
                    txtReport.AppendText(report);
                }
                else if(IllegalInput)
                {
                    MessageBox.Show("DAC value is illegal,please re-type(Integer:0--1023)", "Illegal input", MessageBoxButton.OK, MessageBoxImage.Error);
                    return;
                }
                else
                {
                    MessageBox.Show("Set DAC0 failure. Please check USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                    return;
                }
                bResult = MicrorocChain1.Set10BitDac1(txtDAC1_VTH_ASIC1.Text, MyUsbDevice1, out IllegalInput);
                if (bResult)
                {
                    string report = string.Format("Setting DAC1 VTH: {0}\n", txtDAC1_VTH_ASIC1.Text);
                    txtReport.AppendText(report);
                }
                else if (IllegalInput)
                {
                    MessageBox.Show("DAC value is illegal,please re-type(Integer:0--1023)", "Illegal input", MessageBoxButton.OK, MessageBoxImage.Error);
                    return;
                }
                else
                {
                    MessageBox.Show("Set DAC1 failure. Please check USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                    return;
                }
                bResult = MicrorocChain1.Set10BitDac2(txtDAC2_VTH_ASIC1.Text, MyUsbDevice1, out IllegalInput);
                if (bResult)
                {
                    string report = string.Format("Setting DAC2 VTH: {0}\n", txtDAC2_VTH_ASIC1.Text);
                    txtReport.AppendText(report);
                }
                else if (IllegalInput)
                {
                    MessageBox.Show("DAC value is illegal,please re-type(Integer:0--1023)", "Illegal input", MessageBoxButton.OK, MessageBoxImage.Error);
                    return;
                }
                else
                {
                    MessageBox.Show("Set DAC2 failure. Please check USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                    return;
                }
                #endregion
                #region Set Start Acq Time
                txtStartAcqTime.Text = "1500";
                bResult = MicrorocChain1.SetAcquisitionTime(txtStartAcqTime.Text, MyUsbDevice1, out IllegalInput);
                if (bResult)
                {
                    string report = string.Format("Set StartAcq time : {0}\n", txtStartAcqTime.Text);
                    txtReport.AppendText(report);
                }
                else if (IllegalInput)
                {
                    MessageBox.Show("Illegal StartAcq Time, please re-type(Integer:0--1638400,step:25ns)", //text
                                     "Illegal input",   //caption
                                     MessageBoxButton.OK,//button
                                     MessageBoxImage.Error);//icon
                    return;
                }
                else
                {
                    MessageBox.Show("Set StartAcq time failure, please check USB", //text
                                     "USB Error",   //caption
                                     MessageBoxButton.OK,//button
                                     MessageBoxImage.Error);//icon
                    return;
                }
                #endregion
                #region Set External RAZ
                bResult = MicrorocChain1.SelectRazChannel(1, MyUsbDevice1);
                if (bResult)
                {
                    txtReport.AppendText("Set Raz Mode:External");
                }
                else
                {
                    MessageBox.Show("Set Raz Mode failure, please check USB", //text
                                 "USB Error",   //caption
                                 MessageBoxButton.OK,//button
                                 MessageBoxImage.Error);//icon
                    return;
                }
                #endregion
                #region Set External RAZ Delay
                bResult = MicrorocChain1.SetExternalRazDelayTime(txtExternal_RAZ_Delay.Text, MyUsbDevice1, out IllegalInput);
                if (bResult)
                {
                        string report = string.Format("Set External RAZ Delay time:{0} ns\n", txtExternal_RAZ_Delay.Text);
                }
                else if(IllegalInput)
                {
                    MessageBox.Show("Illegal External RAZ Delay Time, please re-type(Integer:0--400ns,step:25ns)", "Ilegal Input", MessageBoxButton.OK, MessageBoxImage.Error);
                    return;
                }
                else
                {
                    MessageBox.Show("select failure, please check USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                    return;
                }
                #endregion
                #region Set External RAZ Time
                bResult = MicrorocChain1.SetExternalRazWidth(cbxRaz_mode.SelectedIndex, MyUsbDevice1);
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
                    return;
                }
                #endregion
                MicrorocPowerPulsingDisable();
                #region Start Load
                bResult = MicrorocChain1.SelectSlowControlOrReadRegister(false, MyUsbDevice1);
                if(bResult)
                {
                    txtReport.AppendText("Start load slow control parameters\n");
                }
                else
                {
                    MessageBox.Show("Please check the USB cable","USB Error",MessageBoxButton.OK,MessageBoxImage.Error);
                }
                bResult = MicrorocChain1.LoadSlowControlParameter(MyUsbDevice1);
                if (bResult)
                {
                    txtReport.AppendText("Load ASIC parameter done!\n");
                }
                else
                {
                    MessageBox.Show("Load parameter failure, please check USB", //text
                                     "USB Error",   //caption
                                     MessageBoxButton.OK,//button
                                     MessageBoxImage.Error);//icon
                }
                #endregion
                #region Select Daq Mode
                bResult = MicrorocChain1.SelectAcquisitionMode(true, MyUsbDevice1);
                if (bResult)
                {
                    string report = string.Format("Set DAQ Mode: {0} DAQ\n", button.Content.ToString());
                    txtReport.AppendText(report);
                }
                else
                {
                    MessageBox.Show("Set DAQ Mode failure, please check USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                }
                #endregion

            }
        }

        private void btnAFG3252Command_Click(object sender, RoutedEventArgs e)
        {
            try
            {
                MyAFG3252.Write(tbxAFG3252Command.Text);
            }
            catch (Exception exp)
            {
                MessageBox.Show(exp.Message);
            }
        }

        private void Afg3252Refresh()
        {
            if(MyAFG3252.session == null)
            {
                if (MyAFG3252.Initial())
                {
                    lblAFG3252Status.Content = "AFG3252 connected";
                    lblAFG3252Status.Foreground = Brushes.Green;
                    btnAFG3252Command.Background = Brushes.ForestGreen;
                    btnAFG3252Command.IsEnabled = true;
                    tbxAFG3252Command.IsEnabled = true;
                    txtReport.AppendText("AFG3252 connect successfully \n");
                }
                else
                {
                    lblAFG3252Status.Content = "AFG3252 not connected";
                    lblAFG3252Status.Foreground = Brushes.DeepPink;
                    btnAFG3252Command.Background = Brushes.LightGray;
                    btnAFG3252Command.IsEnabled = false;
                    tbxAFG3252Command.IsEnabled = false;
                }
            }
        }
        private void Afg3252Attach()
        {
            if (MyAFG3252.Initial())
            {
                lblAFG3252Status.Content = "AFG3252 connected";
                lblAFG3252Status.Foreground = Brushes.Green;
                btnAFG3252Command.Background = Brushes.ForestGreen;
                btnAFG3252Command.IsEnabled = true;
                tbxAFG3252Command.IsEnabled = true;
                txtReport.AppendText("AFG3252 connect successfully \n");
            }
            else
            {
                lblAFG3252Status.Content = "AFG3252 not connected";
                lblAFG3252Status.Foreground = Brushes.DeepPink;
                btnAFG3252Command.Background = Brushes.LightGray;
                btnAFG3252Command.IsEnabled = false;
                tbxAFG3252Command.IsEnabled = false;
            }
        }
        private void Afg3252Detach()
        {
            if (MyAFG3252.session != null)
            {
                MyAFG3252.Close();
                lblAFG3252Status.Content = "AFG3252 not connected";
                lblAFG3252Status.Foreground = Brushes.DeepPink;
                btnAFG3252Command.Background = Brushes.LightGray;
                btnAFG3252Command.IsEnabled = false;
                tbxAFG3252Command.IsEnabled = false;
            }
        }
        protected override void OnSourceInitialized(EventArgs e)
        {
            base.OnSourceInitialized(e);

            // Adds the windows message processing hook and registers USB device add/removal notification.
            HwndSource source = HwndSource.FromHwnd(new WindowInteropHelper(this).Handle);
            if (source != null)
            {
                IntPtr windowHandle = source.Handle;
                source.AddHook(HwndHandler);
                UsbNotification.RegisterUsbDeviceNotification(windowHandle);
            }
        }

        private IntPtr HwndHandler(IntPtr hwnd, int msg, IntPtr wparam, IntPtr lparam, ref bool handled)
        {
            
            if (msg == UsbNotification.WmDevicechange)
            {
                //UsbName ppp = new UsbName();
                //IntPtr pnt = Marshal.AllocHGlobal(Marshal.SizeOf(ppp));
                //Marshal.StructureToPtr(ppp, lparam, false);
                UsbName UsbDevice = new UsbName();
                string DeviceName;
                switch ((int)wparam)
                {
                    case UsbNotification.DbtDeviceremovecomplete:
                        {
                            UsbDevice = (UsbName)Marshal.PtrToStructure(lparam, typeof(UsbName));
                            DeviceName = UsbDevice.dbcc_name;
                            string[] DeviceNameInternal = DeviceName.Split('#');
                            if(DeviceNameInternal.Length >= 2 && DeviceNameInternal[1] == AFG3252VidPid)
                            {
                                Afg3252Detach();
                            }                            
                        }
                        //Usb_DeviceRemoved(); // this is where you do your magic
                        break;
                    case UsbNotification.DbtDevicearrival:
                        {
                            UsbDevice = (UsbName)Marshal.PtrToStructure(lparam, typeof(UsbName));
                            DeviceName = UsbDevice.dbcc_name;
                            string[] DeviceNameInternal = DeviceName.Split('#');
                            if (DeviceNameInternal.Length >= 2 && DeviceNameInternal[1] == AFG3252VidPid)
                            {
                                Afg3252Attach();
                            }
                        }
                        //Usb_DeviceAdded(); // this is where you do your magic
                        break;
                }
            }

            handled = false;
            //Thread.Sleep(1000);
            return IntPtr.Zero;
        }
        [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
        public struct UsbName
        {
            public int dbcc_size;
            public int dbcc_devicetype;
            public int dbcc_reserved;
            public Guid dbcc_classguid;
            [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 255)]
            public string dbcc_name;
        }

        private void cbxAFG3252FunctionSetCh1_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            if(MyAFG3252.session != null)
            {
                SetAfg3252Channel1FunctionShape();
            }
        }

        private void cbxAFG3252FunctionSetCh2_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            if(MyAFG3252.session != null)
            {
                SetAfg3252Channel2FunctionShape();
            }
        }

        private void SetAfg3252Channel1FunctionShape()
        {
            switch (cbxAFG3252FunctionSetCh1.SelectedIndex)
            {
                case 0: //sine
                    {
                        gbxAFG3252PulseParameters.IsEnabled = false;
                        bool bResult = MyAFG3252.FunctionShapeSet(1, AFG3252.ShapeSinusoid);
                        if (bResult)
                        {
                            string report;
                            report = string.Format("Set AFG3252 channel1 shape:{0}\n", AFG3252.ShapeSinusoid);
                            txtReport.AppendText(report);
                        }
                        else
                        {
                            MessageBox.Show("Set AFG3252 Function shape fail.", "AFG3252 Error", MessageBoxButton.OK, MessageBoxImage.Error);
                        }
                        break;
                    }
                case 1: //Square
                    {
                        gbxAFG3252PulseParameters.IsEnabled = false;
                        bool bResult = MyAFG3252.FunctionShapeSet(1, AFG3252.ShapeSQUare);
                        if (bResult)
                        {
                            string report;
                            report = string.Format("Set AFG3252 channel1 shape:{0}\n", AFG3252.ShapeSQUare);
                            txtReport.AppendText(report);
                        }
                        else
                        {
                            MessageBox.Show("Set AFG3252 Function shape fail.", "AFG3252 Error", MessageBoxButton.OK, MessageBoxImage.Error);
                        }
                        break;
                    }
                case 2: //Ramp
                    {
                        gbxAFG3252PulseParameters.IsEnabled = false;
                        bool bResult = MyAFG3252.FunctionShapeSet(1, AFG3252.ShapeRamp);
                        if (bResult)
                        {
                            string report;
                            report = string.Format("Set AFG3252 channel1 shape:{0}\n", AFG3252.ShapeRamp);
                            txtReport.AppendText(report);
                        }
                        else
                        {
                            MessageBox.Show("Set AFG3252 Function shape fail.", "AFG3252 Error", MessageBoxButton.OK, MessageBoxImage.Error);
                        }
                        break;
                    }
                case 3: //Pulse
                    {
                        gbxAFG3252PulseParameters.IsEnabled = true;
                        bool bResult = MyAFG3252.FunctionShapeSet(1, AFG3252.ShapePulse);
                        if (bResult)
                        {
                            string report;
                            report = string.Format("Set AFG3252 channel1 shape:{0}\n", AFG3252.ShapePulse);
                            txtReport.AppendText(report);
                        }
                        else
                        {
                            MessageBox.Show("Set AFG3252 Function shape fail.", "AFG3252 Error", MessageBoxButton.OK, MessageBoxImage.Error);
                        }
                        break;
                    }
                default:
                    {
                        gbxAFG3252PulseParameters.IsEnabled = false;
                        txtReport.AppendText("Function wait to be developed\n");
                        break;
                    }
            }
        }
        private void SetAfg3252Channel2FunctionShape()
        {
            switch (cbxAFG3252FunctionSetCh2.SelectedIndex)
            {
                case 0: //sine
                    {
                        gbxAFG3252PulseParameters.IsEnabled = false;
                        bool bResult = MyAFG3252.FunctionShapeSet(2, AFG3252.ShapeSinusoid);
                        if (bResult)
                        {
                            string report;
                            report = string.Format("Set AFG3252 channel2 shape:{0}\n", AFG3252.ShapeSinusoid);
                            txtReport.AppendText(report);
                        }
                        else
                        {
                            MessageBox.Show("Set AFG3252 Function shape fail.", "AFG3252 Error", MessageBoxButton.OK, MessageBoxImage.Error);
                        }
                        break;
                    }
                case 1: //Square
                    {
                        gbxAFG3252PulseParameters.IsEnabled = false;
                        bool bResult = MyAFG3252.FunctionShapeSet(2, AFG3252.ShapeSQUare);
                        if (bResult)
                        {
                            string report;
                            report = string.Format("Set AFG3252 channel2 shape:{0}\n", AFG3252.ShapeSQUare);
                            txtReport.AppendText(report);
                        }
                        else
                        {
                            MessageBox.Show("Set AFG3252 Function shape fail.", "AFG3252 Error", MessageBoxButton.OK, MessageBoxImage.Error);
                        }
                        break;
                    }
                case 2: //Ramp
                    {
                        gbxAFG3252PulseParameters.IsEnabled = false;
                        bool bResult = MyAFG3252.FunctionShapeSet(2, AFG3252.ShapeRamp);
                        if (bResult)
                        {
                            string report;
                            report = string.Format("Set AFG3252 channel2 shape:{0}\n", AFG3252.ShapeRamp);
                            txtReport.AppendText(report);
                        }
                        else
                        {
                            MessageBox.Show("Set AFG3252 Function shape fail.", "AFG3252 Error", MessageBoxButton.OK, MessageBoxImage.Error);
                        }
                        break;
                    }
                case 3: //Pulse
                    {
                        gbxAFG3252PulseParameters.IsEnabled = true;
                        bool bResult = MyAFG3252.FunctionShapeSet(2, AFG3252.ShapePulse);
                        if (bResult)
                        {
                            string report;
                            report = string.Format("Set AFG3252 channel2 shape:{0}\n", AFG3252.ShapePulse);
                            txtReport.AppendText(report);
                        }
                        else
                        {
                            MessageBox.Show("Set AFG3252 Function shape fail.", "AFG3252 Error", MessageBoxButton.OK, MessageBoxImage.Error);
                        }
                        break;
                    }
                default:
                    {
                        gbxAFG3252PulseParameters.IsEnabled = false;
                        txtReport.AppendText("Function wait to be developed\n");
                        break;
                    }
            }
        }
        private void cbxAFG3252FrequencyCopy_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            if(MyAFG3252.session !=null)
            {
                SetAfg3252FrequencyCopy();
            }
        }
        private void SetAfg3252FrequencyCopy()
        {
            switch (cbxAFG3252FrequencyCopy.SelectedIndex)
            {
                case 0: //off
                    {
                        bool bResult = MyAFG3252.SetFrequencyCopy(1, "OFF");
                        if (bResult)
                        {
                            txtReport.AppendText("Disable AFG3252 Frequency channel1 = channel2\n");
                        }
                        break;
                    }
                case 1: //on
                    {
                        bool bResult = MyAFG3252.SetFrequencyCopy(1, "ON");
                        if (bResult)
                        {
                            txtReport.AppendText("Set AFG3252 Frequency channel1 = channel2\n");
                        }
                        break;
                    }
            }
        }
        private void tbiAFG3252Amplitude_MouseLeftButtonUp(object sender, System.Windows.Input.MouseButtonEventArgs e)
        {
            AmplitudeOrLevel = true;
            Regex rx_double = new Regex(rx_Double);
            bool IsLevelLegeal = rx_double.IsMatch(tbxAFG3252HighLevelCh1.Text)
                                && rx_double.IsMatch(tbxAFG3252HighLevelCh2.Text)
                                && rx_double.IsMatch(tbxAFG3252LowLevelCh1.Text)
                                && rx_double.IsMatch(tbxAFG3252LowLevelCh2.Text);
            if(IsLevelLegeal)
            {
                double Ch1HighLevel = int.Parse(tbxAFG3252HighLevelCh1.Text);
                double Ch2HighLevel = int.Parse(tbxAFG3252HighLevelCh2.Text);
                double Ch1LowLevel = int.Parse(tbxAFG3252LowLevelCh1.Text);
                double Ch2LowLevel = int.Parse(tbxAFG3252LowLevelCh2.Text);
                double Ch1Amplitude = Ch1HighLevel - Ch1LowLevel;
                double Ch1Offset = (Ch1HighLevel + Ch1LowLevel) / 2.0;
                double Ch2Amplitude = Ch2HighLevel - Ch2LowLevel;
                double Ch2Offset = (Ch2HighLevel + Ch2LowLevel) / 2.0;
                tbxAFG3252AmplitudeCh1.Text = Ch1Amplitude.ToString();
                tbxAFG3252OffsetCh1.Text = Ch1Offset.ToString();
                tbxAFG3252AmplitudeCh2.Text = Ch2Amplitude.ToString();
                tbxAFG3252OffsetCh2.Text = Ch2Offset.ToString();
            }
        }
        private void tbiAFG3252Level_MouseLeftButtonUp(object sender, System.Windows.Input.MouseButtonEventArgs e)
        {
            AmplitudeOrLevel = false;
            Regex rx_double = new Regex(rx_Double);
            bool IsLevelLegeal = rx_double.IsMatch(tbxAFG3252AmplitudeCh1.Text)
                                && rx_double.IsMatch(tbxAFG3252AmplitudeCh2.Text)
                                && rx_double.IsMatch(tbxAFG3252OffsetCh1.Text)
                                && rx_double.IsMatch(tbxAFG3252OffsetCh2.Text);
            if (IsLevelLegeal)
            {
                double Ch1Amplitude = int.Parse(tbxAFG3252AmplitudeCh1.Text);
                double Ch2Amplitude = int.Parse(tbxAFG3252AmplitudeCh2.Text);
                double Ch1Offset = int.Parse(tbxAFG3252OffsetCh1.Text);
                double Ch2Offset = int.Parse(tbxAFG3252OffsetCh2.Text);
                double Ch1HighLevel = Ch1Offset + (Ch1Amplitude / 2.0);
                double Ch1LowLevel = Ch1Offset - (Ch1Amplitude / 2.0);
                double Ch2HighLevel = Ch2Offset + (Ch2Amplitude / 2.0);
                double Ch2LowLevel = Ch2Offset - (Ch2Amplitude / 2.0);
                tbxAFG3252HighLevelCh1.Text = Ch1HighLevel.ToString();
                tbxAFG3252HighLevelCh2.Text = Ch2HighLevel.ToString();
                tbxAFG3252LowLevelCh1.Text = Ch1LowLevel.ToString();
                tbxAFG3252LowLevelCh2.Text = Ch2LowLevel.ToString();
            }
        }
        private void SetAfg3252VoltageAmplitude()
        {
            Regex rx_double = new Regex(rx_Double);
            bool IsAmplitudeLegeal = rx_double.IsMatch(tbxAFG3252AmplitudeCh1.Text)
                                && rx_double.IsMatch(tbxAFG3252AmplitudeCh2.Text)
                                && rx_double.IsMatch(tbxAFG3252OffsetCh1.Text)
                                && rx_double.IsMatch(tbxAFG3252OffsetCh2.Text);
            if (IsAmplitudeLegeal)
            {
                double Ch1Amplitude = double.Parse(tbxAFG3252AmplitudeCh1.Text);
                double Ch1Offset = double.Parse(tbxAFG3252OffsetCh1.Text);
                double Ch2Amplitude = double.Parse(tbxAFG3252AmplitudeCh2.Text);
                double Ch2Offset = double.Parse(tbxAFG3252OffsetCh2.Text);
                string AmplitudeUnit;
                switch(cbxAFG3252VoltageUnitSet.SelectedIndex)
                {
                    case 0:
                        {
                            AmplitudeUnit = AFG3252.VoltageUnitMV;
                            Ch1Amplitude = Ch1Amplitude / 1000.0;
                            Ch2Amplitude = Ch2Amplitude / 1000.0;
                            break;
                        }
                    case 1:
                        {
                            AmplitudeUnit = AFG3252.VoltageUnitV;
                            break;
                        }
                    default:
                        {
                            AmplitudeUnit = AFG3252.VoltageUnitMV;
                            Ch1Amplitude = Ch1Amplitude / 1000.0;
                            Ch2Amplitude = Ch2Amplitude / 1000.0;
                            break;
                        }
                }
                
                bool bResult;
                bResult = MyAFG3252.SetVoltageAmplitude(1, Ch1Amplitude, AFG3252.VoltageUnitVpp);
                if(!bResult)
                {
                    MessageBox.Show("Set Voltage Error", "AFG3252 Error", MessageBoxButton.OK, MessageBoxImage.Error);
                }
                bResult = MyAFG3252.SetVoltageAmplitude(2, Ch2Amplitude, AFG3252.VoltageUnitVpp);
                if (!bResult)
                {
                    MessageBox.Show("Set Voltage Error", "AFG3252 Error", MessageBoxButton.OK, MessageBoxImage.Error);
                }
                bResult = MyAFG3252.SetVoltageOffset(1, Ch1Offset, AmplitudeUnit);
                if (!bResult)
                {
                    MessageBox.Show("Set Offset Error", "AFG3252 Error", MessageBoxButton.OK, MessageBoxImage.Error);
                }
                bResult = MyAFG3252.SetVoltageOffset(2, Ch2Offset, AmplitudeUnit);
                if(bResult)
                {
                    string report = string.Format("Set Channel1: Amplitude:{0}{2} Offset{1}{2}\n", Ch1Amplitude, Ch1Offset, AmplitudeUnit);
                    txtReport.AppendText(report);
                    report = string.Format("Set Channel2: Amplitude:{0}{2} Offset{1}{2}\n", Ch2Amplitude, Ch2Offset, AmplitudeUnit);
                    txtReport.AppendText(report);
                }
                else
                {
                    MessageBox.Show("Set Offset Error", "AFG3252 Error", MessageBoxButton.OK, MessageBoxImage.Error);
                }
            }
            else
            {
                MessageBox.Show("Illegal Voltage", "Illegal Input", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }
        private void SetAfg3252VoltageLevel()
        {
            Regex rx_double = new Regex(rx_Double);
            bool IsLevelLegeal = rx_double.IsMatch(tbxAFG3252HighLevelCh1.Text)
                                && rx_double.IsMatch(tbxAFG3252HighLevelCh2.Text)
                                && rx_double.IsMatch(tbxAFG3252LowLevelCh1.Text)
                                && rx_double.IsMatch(tbxAFG3252LowLevelCh2.Text);
            if(IsLevelLegeal)
            {
                string AmplitudeUnit;
                switch (cbxAFG3252VoltageUnitSet.SelectedIndex)
                {
                    case 0:
                        {
                            AmplitudeUnit = AFG3252.VoltageUnitMV;
                            break;
                        }
                    case 1:
                        {
                            AmplitudeUnit = AFG3252.VoltageUnitV;
                            break;
                        }
                    default:
                        {
                            AmplitudeUnit = AFG3252.VoltageUnitMV;
                            break;
                        }
                }
                double Ch1HighLevel = double.Parse(tbxAFG3252HighLevelCh1.Text);
                double Ch2HighLevel = double.Parse(tbxAFG3252HighLevelCh2.Text);
                double Ch1LowLevel = double.Parse(tbxAFG3252LowLevelCh1.Text);
                double Ch2LowLevel = double.Parse(tbxAFG3252LowLevelCh2.Text);
                bool bResult;
                bResult = MyAFG3252.SetVoltageHigh(1, Ch1HighLevel, AmplitudeUnit);
                if(!bResult)
                {
                    MessageBox.Show("Set Channel1 High Level Error", "AFG3252 Error", MessageBoxButton.OK, MessageBoxImage.Error);
                }
                bResult = MyAFG3252.SetVoltageHigh(2, Ch2HighLevel, AmplitudeUnit);
                if (!bResult)
                {
                    MessageBox.Show("Set Channel2 High Level Error", "AFG3252 Error", MessageBoxButton.OK, MessageBoxImage.Error);
                }
                bResult = MyAFG3252.SetVoltageLow(1, Ch1LowLevel, AmplitudeUnit);
                if (!bResult)
                {
                    MessageBox.Show("Set Channel1 Low Level Error", "AFG3252 Error", MessageBoxButton.OK, MessageBoxImage.Error);
                }
                bResult = MyAFG3252.SetVoltageLow(2, Ch2LowLevel, AmplitudeUnit);
                if(bResult)
                {
                    string report = string.Format("Set channel1 high level:{0}{2}, low level:{1}{2}", Ch1HighLevel, Ch1LowLevel, AmplitudeUnit);
                    txtReport.AppendText(report);
                    report = string.Format("Set channel2 high level:{0}{2}, low level:{1}{2}", Ch2HighLevel, Ch2LowLevel, AmplitudeUnit);
                }
                else
                {
                    MessageBox.Show("Set Channel2 Low Level Error", "AFG3252 Error", MessageBoxButton.OK, MessageBoxImage.Error);
                }
            }
            else
            {
                MessageBox.Show("Illegal Voltage", "Illegal Input", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }
        private void btnAFG3252Ch1OnOrOff_Click(object sender, RoutedEventArgs e)
        {
            if(btnAFG3252Ch1OnOrOff.Content.ToString() == "Off")
            {
                btnAFG3252Ch1OnOrOff.Background = Brushes.Green;
                btnAFG3252Ch1OnOrOff.Content = "On";
                MyAFG3252.OpenOutput(1);
                txtReport.AppendText("AFG3252 Channel1 On\n");
            }
            else if(btnAFG3252Ch1OnOrOff.Content.ToString() == "On")
            {
                btnAFG3252Ch1OnOrOff.Background = Brushes.Gray;
                btnAFG3252Ch1OnOrOff.Content = "Off";
                MyAFG3252.CloseOutput(1);
                txtReport.AppendText("AFG3252 Channel1 Off\n");
            }            
        }
        private void btnAFG3252Ch2OnOrOff_Click(object sender, RoutedEventArgs e)
        {
            if (btnAFG3252Ch2OnOrOff.Content.ToString() == "Off")
            {
                btnAFG3252Ch2OnOrOff.Background = Brushes.Green;
                btnAFG3252Ch2OnOrOff.Content = "On";
                MyAFG3252.OpenOutput(2);
                txtReport.AppendText("AFG3252 Channel2 On\n");
            }
            else if (btnAFG3252Ch2OnOrOff.Content.ToString() == "On")
            {
                btnAFG3252Ch2OnOrOff.Background = Brushes.Gray;
                btnAFG3252Ch2OnOrOff.Content = "Off";
                MyAFG3252.CloseOutput(2);
                txtReport.AppendText("AFG3252 Channel2 Off\n");
            }
        }
        private void SetAfg3252Ch1Frequency()
        {
            Regex rx_double = new Regex(rx_Double);
            bool IsFrequencyLegal = rx_double.IsMatch(tbxAFG3252FrequencySetCh1.Text);
            if (IsFrequencyLegal)
            {
                double Frequency = double.Parse(tbxAFG3252FrequencySetCh1.Text);
                string FrequencyUnit;
                switch (cbxAFG3252FrequencyUnitSet.SelectedIndex)
                {
                    case 0:
                        {
                            FrequencyUnit = AFG3252.FrequencyUnitHz;
                            break;
                        }
                    case 1:
                        {
                            FrequencyUnit = AFG3252.FrequencyUnitKHz;
                            break;
                        }
                    case 2:
                        {
                            FrequencyUnit = AFG3252.FrequencyUnitMHz;
                            break;
                        }
                    default:
                        {
                            FrequencyUnit = AFG3252.FrequencyUnitKHz;
                            break;
                        }
                }
                bool bResult = MyAFG3252.SetFrequencyFixed(1, Frequency, FrequencyUnit);
                if (bResult)
                {
                    string report = string.Format("Set Channel1 frequency: {0}{1}\n", Frequency, FrequencyUnit);
                    txtReport.AppendText(report);
                }
                else
                {
                    MessageBox.Show("Set Channel1 Frequency failed", "AFG3252 Error", MessageBoxButton.OK, MessageBoxImage.Error);
                }
            }
            else
            {
                MessageBox.Show("Illegal frequency","Illegal Input",MessageBoxButton.OK,MessageBoxImage.Error);
            }
            
        }
        private void SetAfg3252Ch2Frequency()
        {
            Regex rx_double = new Regex(rx_Double);
            bool IsFrequencyLegal = rx_double.IsMatch(tbxAFG3252FrequencySetCh2.Text);
            if (IsFrequencyLegal)
            {
                double Frequency = double.Parse(tbxAFG3252FrequencySetCh2.Text);
                string FrequencyUnit;
                switch (cbxAFG3252FrequencyUnitSet.SelectedIndex)
                {
                    case 0:
                        {
                            FrequencyUnit = AFG3252.FrequencyUnitHz;
                            break;
                        }
                    case 1:
                        {
                            FrequencyUnit = AFG3252.FrequencyUnitKHz;
                            break;
                        }
                    case 2:
                        {
                            FrequencyUnit = AFG3252.FrequencyUnitMHz;
                            break;
                        }
                    default:
                        {
                            FrequencyUnit = AFG3252.FrequencyUnitKHz;
                            break;
                        }
                }
                bool bResult = MyAFG3252.SetFrequencyFixed(2, Frequency, FrequencyUnit);
                if (bResult)
                {
                    string report = string.Format("Set Channel2 frequency: {0}{1}\n", Frequency, FrequencyUnit);
                    txtReport.AppendText(report);
                }
                else
                {
                    MessageBox.Show("Set Channel2 Frequency failed", "AFG3252 Error", MessageBoxButton.OK, MessageBoxImage.Error);
                }
            }
            else
            {
                MessageBox.Show("Illegal frequency", "Illegal Input", MessageBoxButton.OK, MessageBoxImage.Error);
            }

        }
        private void SetAfg3252PulseParameter()
        {
            Regex rx_double = new Regex(rx_Double);
            #region Leading
            bool IsPulseParameterLegal = rx_double.IsMatch(tbxAFG3252PulseLeadingCh1.Text) && rx_double.IsMatch(tbxAFG3252PulseLeadingCh2.Text);
            if (IsPulseParameterLegal)
            {
                string Unit;
                switch (cbxAFG3252LeadingUnitSet.SelectedIndex)
                {
                    case 0:
                        {
                            Unit = "ns";
                            break;
                        }
                    case 1:
                        {
                            Unit = "us";
                            break;
                        }
                    case 2:
                        {
                            Unit = "ms";
                            break;
                        }
                    case 3:
                        {
                            Unit = "s";
                            break;
                        }
                    default:
                        {
                            Unit = "us";
                            break;
                        }
                }
                double Ch1Leading = double.Parse(tbxAFG3252PulseLeadingCh1.Text);
                double Ch2Leading = double.Parse(tbxAFG3252PulseLeadingCh2.Text);
                bool bResult = MyAFG3252.SetPulseLeading(1, Ch1Leading, Unit);
                if(!bResult)
                {
                    MessageBox.Show("Set Channel1 Leading failing", "AFG3252 Error", MessageBoxButton.OK, MessageBoxImage.Error);
                    return;
                }
                bResult = MyAFG3252.SetPulseLeading(2, Ch2Leading, Unit);
                if (!bResult)
                {
                    MessageBox.Show("Set Channel2 Leading failing", "AFG3252 Error", MessageBoxButton.OK, MessageBoxImage.Error);
                    return;
                }
            }
            else
            {
                MessageBox.Show("Illegal Input, the pulse parameter should be double", "Illegal Input", MessageBoxButton.OK, MessageBoxImage.Error);
                return;
            }
            #endregion
            #region Trailing
            IsPulseParameterLegal = rx_double.IsMatch(tbxAFG3252PulseTrailingCh1.Text) && rx_double.IsMatch(tbxAFG3252PulseTrailingCh2.Text);
            if(IsPulseParameterLegal)
            {
                string Unit;
                switch (cbxAFG3252TrailingUnitSet.SelectedIndex)
                {
                    case 0:
                        {
                            Unit = "ns";
                            break;
                        }
                    case 1:
                        {
                            Unit = "us";
                            break;
                        }
                    case 2:
                        {
                            Unit = "ms";
                            break;
                        }
                    case 3:
                        {
                            Unit = "s";
                            break;
                        }
                    default:
                        {
                            Unit = "ns";
                            break;
                        }
                }
                double Ch1Trailing = double.Parse(tbxAFG3252PulseTrailingCh1.Text);
                double Ch2Trailing = double.Parse(tbxAFG3252PulseTrailingCh2.Text);
                bool bResult = MyAFG3252.SetPulseTrailing(1, Ch1Trailing, Unit);
                if (!bResult)
                {
                    MessageBox.Show("Set Channel1 Trailing failing", "AFG3252 Error", MessageBoxButton.OK, MessageBoxImage.Error);
                    return;
                }
                bResult = MyAFG3252.SetPulseTrailing(2, Ch2Trailing, Unit);
                if (!bResult)
                {
                    MessageBox.Show("Set Channel2 Trailing failing", "AFG3252 Error", MessageBoxButton.OK, MessageBoxImage.Error);
                    return;
                }
            }
            else
            {
                MessageBox.Show("Illegal Input, the pulse parameter should be double", "Illegal Input", MessageBoxButton.OK, MessageBoxImage.Error);
                return;
            }
            #endregion
            #region Delay
            IsPulseParameterLegal = rx_double.IsMatch(tbxAFG3252PulseDelayCh1.Text) && rx_double.IsMatch(tbxAFG3252PulseDelayCh2.Text);
            if(IsPulseParameterLegal)
            {
                string Unit;
                switch (cbxAFG3252DelayTimeUnitSet.SelectedIndex)
                {
                    case 0:
                        {
                            Unit = "ns";
                            break;
                        }
                    case 1:
                        {
                            Unit = "us";
                            break;
                        }
                    case 2:
                        {
                            Unit = "ms";
                            break;
                        }
                    case 3:
                        {
                            Unit = "s";
                            break;
                        }
                    default:
                        {
                            Unit = "us";
                            break;
                        }
                }
                double Ch1Delay = double.Parse(tbxAFG3252PulseDelayCh1.Text);
                double Ch2Delay = double.Parse(tbxAFG3252PulseDelayCh2.Text);
                bool bResult = MyAFG3252.SetPulseDelay(1, Ch1Delay, Unit);
                if(!bResult)
                {
                    MessageBox.Show("Set Channel1 Delay failing", "AFG3252 Error", MessageBoxButton.OK, MessageBoxImage.Error);
                    return;
                }
                bResult = MyAFG3252.SetPulseDelay(2, Ch2Delay, Unit);
                if (bResult)
                {
                    txtReport.AppendText("Set Pulse Parameter successfully");
                }
                else
                {
                    MessageBox.Show("Set Channel2 Delay failing", "AFG3252 Error", MessageBoxButton.OK, MessageBoxImage.Error);
                    return;
                }
            }
            else
            {
                MessageBox.Show("Illegal Input, the pulse parameter should be double", "Illegal Input", MessageBoxButton.OK, MessageBoxImage.Error);
                return;
            }
            #endregion
        }
        private void btnAFG3252Config_Click(object sender, RoutedEventArgs e)
        {
            #region On or Off
            if(btnAFG3252Ch1OnOrOff.Content.ToString() == "Off")
            {
                MyAFG3252.CloseOutput(1);
                txtReport.AppendText("AFG3252 Channel1 Off\n");
            }
            if (btnAFG3252Ch1OnOrOff.Content.ToString() == "On")
            {
                MyAFG3252.OpenOutput(1);
                txtReport.AppendText("AFG3252 Channel1 On\n");
            }
            if (btnAFG3252Ch2OnOrOff.Content.ToString() == "Off")
            {
                MyAFG3252.CloseOutput(2);
                txtReport.AppendText("AFG3252 Channel2 Off\n");
            }
            if (btnAFG3252Ch2OnOrOff.Content.ToString() == "On")
            {
                MyAFG3252.OpenOutput(2);
                txtReport.AppendText("AFG3252 Channel2 On\n");
            }
            #endregion
            #region Set Function shape
            SetAfg3252Channel1FunctionShape();
            SetAfg3252Channel1FunctionShape();
            #endregion
            #region Set Frequency
            SetAfg3252Ch1Frequency();
            SetAfg3252Ch2Frequency();
            SetAfg3252FrequencyCopy();
            #endregion
            #region Voltage Level
            if (AmplitudeOrLevel)
            {
                SetAfg3252VoltageAmplitude();
            }
            else
            {
                SetAfg3252VoltageLevel();
            }
            #endregion
            #region Pulse Parameter
            if(cbxAFG3252FunctionSetCh1.SelectedIndex == 3)
            {
                SetAfg3252PulseParameter();
            }
            #endregion
        }

        private void TestLed_Click(object sender, RoutedEventArgs e)
        {
            bool IllegalInput;
            bool bResult = MicrorocChain1.LightLed(txtTestLed.Text, MyUsbDevice1, out IllegalInput);
            if(bResult)
            {
                txtReport.AppendText("Light LED\n");
            }
            else if(IllegalInput)
            {
                MessageBox.Show("Illegal Input: Single Hex", "Illegal Input", MessageBoxButton.OK, MessageBoxImage.Error);
                return;
            }
            else
            {
                MessageBox.Show("USB Connect Error", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                return;
            }
        }

        private void tbiMicrorocAcq_MouseLeftButtonUp(object sender, System.Windows.Input.MouseButtonEventArgs e)
        {
            txtReport.AppendText("Microroc ACQ\n\n");
        }

        private void tbiSCTest_MouseLeftButtonUp(object sender, System.Windows.Input.MouseButtonEventArgs e)
        {
            txtReport.Text = "";
            btnAutoCalibrationStart.IsEnabled = false;
            btnAutoCalibrationInitial.Background = Brushes.AliceBlue;
            SetSCurveTestParameter();    
        }
        private void SetSCurveTestParameter()
        {
            bool bResult;
            MicrorocPowerPulsingDisable();
            #region Select External Raz
            bResult = MicrorocChain1.SelectRazChannel(1, MyUsbDevice1);
            if (bResult)
            {
                txtReport.AppendText("Select External RAZ\n");
            }
            else
            {
                MessageBox.Show("Select Internal RAZ failure. Please check the USB cable", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                return;
            }
            #endregion
            #region Select trigger out NOR64
            bResult = MicrorocChain1.SelectTrigOutNor64OrSingle(1, MyUsbDevice1);
            if (bResult)
            {
                txtReport.AppendText("Select trigger out NOR64\n");
            }
            else
            {
                MessageBox.Show("Set trigger out failure. Olease check USB cable", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                return;
            }
            #endregion
            #region Set external RAZ Delay
            bool IllegalInput;
            bResult = MicrorocChain1.SetExternalRazDelayTime("200", MyUsbDevice1, out IllegalInput);
            if (bResult)
            {
                txtReport.AppendText("Set External RAZ delay time: 200ns\n");
            }
            else
            {
                MessageBox.Show("Set External RAZ delay time failure. Please check the USB cable", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                return;
            }
            #endregion
            #region Set External RAZ Time
            bResult = MicrorocChain1.SetExternalRazWidth(3, MyUsbDevice1);
            if (bResult)
            {
                txtReport.AppendText("Set External RAZ time: 1000ns\n");
            }
            else
            {
                MessageBox.Show("Set external RAZ time failure. Please check the USB cable", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                return;
            }
            #endregion
            #region Slow Control Load
            bResult = MicrorocChain1.LoadSlowControlParameter(MyUsbDevice1);
            if (bResult)
            {
                txtReport.AppendText("Load Slow Control successful\n");
            }
            else
            {
                MessageBox.Show("Load SC parameter failure. Olease check the USB cable", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                return;
            }
            #endregion
            #region Release External RAZ
            bResult = MicrorocChain1.SelectAcquisitionMode(false, MyUsbDevice1);
            if (bResult)
            {
                txtReport.AppendText("Release External RAZ\n");
            }
            else
            {
                MessageBox.Show("Release External RAZ failure. Please check USB cable", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                return;
            }
            #endregion
            bResult = MicrorocChain1.SelectOperationMode(CommandHeader.SCurveTestModeIndex, MyUsbDevice1);
            if (bResult)
            {
                txtReport.AppendText("SCurve Test Mode\n");
                StateIndicator.OperationModeSelect = StateIndicator.OperationMode.SCTest;
            }
            else
            {
                MessageBox.Show("Select SCurve Test mode failure. Please check the USB cable and re-click SCTest", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }
        private void tbiAD9220_MouseLeftButtonUp(object sender, System.Windows.Input.MouseButtonEventArgs e)
        {
            txtReport.Text = "";
            bool bResult = MicrorocChain1.SelectOperationMode(CommandHeader.AdcModeIndex, MyUsbDevice1);
            if(bResult)
            {
                txtReport.AppendText("ADC Mode\n");
                StateIndicator.OperationModeSelect = StateIndicator.OperationMode.ADC;
                MicrorocPowerPulsingDisable();
                #region Select External Raz
                bResult = MicrorocChain1.SelectRazChannel(1, MyUsbDevice1);
                if (bResult)
                {
                    txtReport.AppendText("Select External RAZ\n");
                }
                else
                {
                    MessageBox.Show("Select Internal RAZ failure. Please check the USB cable", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                    return;
                }
                #endregion
                #region Set trigger out Read
                bResult = MicrorocChain1.SelectTrigOutNor64OrSingle(0, MyUsbDevice1);
                if(bResult)
                {
                    txtReport.AppendText("Set trigger out: Read register\n");
                }
                else
                {
                    MessageBox.Show("Set trigger out failure. Please check the USB cable", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                    return;
                }
                #endregion
                #region Set external RAZ Delay
                bool IllegalInput;
                bResult = MicrorocChain1.SetExternalRazDelayTime("200", MyUsbDevice1, out IllegalInput);
                if(bResult)
                {
                    txtReport.AppendText("Set External RAZ delay time: 200ns\n");
                }
                else
                {
                    MessageBox.Show("Set External RAZ delay time failure. Please check the USB cable", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                    return;
                }
                #endregion
                #region Set External RAZ Time
                bResult = MicrorocChain1.SetExternalRazWidth(3, MyUsbDevice1);
                if(bResult)
                {
                    txtReport.AppendText("Set External RAZ time: 1000ns\n");
                }
                else
                {
                    MessageBox.Show("Set external RAZ time failure. Please check the USB cable", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                    return;
                }
                #endregion
                #region Slow Control Load
                bResult = MicrorocChain1.SelectSlowControlOrReadRegister(false, MyUsbDevice1);
                if(bResult)
                {
                    txtReport.AppendText("Start load slow control parameter\n");
                }
                else
                {
                    MessageBox.Show("Please check the USB cable", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                }
                bResult = MicrorocChain1.LoadSlowControlParameter(MyUsbDevice1);
                if (bResult)
                {
                    txtReport.AppendText("Load Slow Control successful\n");
                }
                else
                {
                    MessageBox.Show("Load SC parameter failure. Olease check the USB cable", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                    return;
                }
                #endregion
            }
            else
            {
                MessageBox.Show("Select AD9220 test mode failure. Please check the USB cable and re-click the AD9220", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                return;
            }
        }

        private void tbiSweepAcq_MouseRightButtonUp(object sender, System.Windows.Input.MouseButtonEventArgs e)
        {
            txtReport.Text = "";
            bool bResult = MicrorocChain1.SelectOperationMode(CommandHeader.SweepAcqModeIndex, MyUsbDevice1);
            if(bResult)
            {
                txtReport.AppendText("Sweep ACQ Mode Select\n");
                StateIndicator.OperationModeSelect = StateIndicator.OperationMode.SweepAcq;
            }
            else
            {
                MessageBox.Show("Select Sweep ACQ Test mode failure. Please check the USB cable and re-click Sweep ACQ", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                return;
            }
        }

        private void tbmNormalAcq_MouseLeftButtonUp(object sender, System.Windows.Input.MouseButtonEventArgs e)
        {
            txtReport.Text = "";
            bool bResult = MicrorocChain1.SelectOperationMode(CommandHeader.AcqModeIndex, MyUsbDevice1);
            if (bResult)
            {
                txtReport.AppendText("Normal ACQ\n");
                StateIndicator.OperationModeSelect = StateIndicator.OperationMode.SCTest;
                MicrorocPowerPulsingEnable();
                #region Select Internal RAZ
                bResult = MicrorocChain1.SelectRazChannel(0, MyUsbDevice1);
                if(bResult)
                {
                    txtReport.AppendText("Internal RAZ\n");
                }
                else
                {
                    MessageBox.Show("Set internal RAZ failure. Please check the USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                    return;
                }
                #endregion
                #region Select trigger out NOR64
                bResult = MicrorocChain1.SelectTrigOutNor64OrSingle(1, MyUsbDevice1);
                if(bResult)
                {
                    txtReport.AppendText("Select trigger out NOR64\n");
                }
                else
                {
                    MessageBox.Show("Set trigger out failure. Olease check USB cable", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                    return;
                }
                #endregion
                #region Slow Control Load
                bResult = MicrorocChain1.LoadSlowControlParameter(MyUsbDevice1);
                if(bResult)
                {
                    txtReport.AppendText("Load Slow Control successful\n");
                }
                else
                {
                    MessageBox.Show("Load SC parameter failure. Olease check the USB cable", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                    return;
                }
                #endregion
            }
            else
            {
                MessageBox.Show("Select Normal ACQ mode failure. Please check the USB cable and re-click Normal ACQ", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private void btnTestSlowControlSend_Click(object sender, RoutedEventArgs e)
        {
            bool bResult;
            #region RAZ Select
            bResult = MicrorocChain1.SelectRazChannel(cbxRazSelect.SelectedIndex, MyUsbDevice1);
            if (bResult)
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
                return;
            }
            #endregion
            #region ReadReg Or NOR64
            bResult = MicrorocChain1.SelectTrigOutNor64OrSingle(cbxReadOrNOR64.SelectedIndex, MyUsbDevice1);
            if (bResult)
            {
                string report = string.Format("Set trigger out by {0}\n", cbxReadOrNOR64.Text);
                txtReport.AppendText(report);
            }
            else
            {
                MessageBox.Show("Set Readreg or NOR64 failure, please check USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                return;
            }
            #endregion
        }

        private void btnShowCurrentPath_Click(object sender, RoutedEventArgs e)
        {
            
            txtReport.AppendText(CurrentPath);
            string DefaultDicrectory = @txtFileDir.Text;
            string DefaultFileName = DateTime.Now.ToString();
            DefaultFileName = DefaultFileName.Replace("/", "_");
            DefaultFileName = DefaultFileName.Replace(":", "_");
            DefaultFileName = DefaultFileName.Replace(" ", "T");
            DefaultFileName += ".dat";
            filepath = Path.Combine(DefaultDicrectory, DefaultFileName);
            tbxCurrentPath.Text = filepath;
            FileStream fs = null;
            if (!File.Exists(filepath))
            {
                fs = File.Create(filepath);
                string report = String.Format("File:{0} Created\n", filepath);
                txtReport.AppendText(report.ToString());
                StateIndicator.FileSaved = true;
                fs.Close();
            }
            else
            {
                MessageBox.Show("Save file failure. Please save the file manual", "File Save Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }
        private void CalibrationInitial()
        {
            bool bResult;
            string report;
            #region Set frequency 100kHz
            bResult = AutoCalibration.SetTestFrequency(MyAFG3252, out report);
            if (bResult)
            {
                txtReport.AppendText(report);
            }
            else
            {
                MessageBox.Show("Set test frequency failure. Please check the USB", "AFG3252 Error", MessageBoxButton.OK, MessageBoxImage.Error);
                return;
            }
            #endregion
            #region Set test shape: Pulse
            bResult = AutoCalibration.SetTestShape(MyAFG3252, out report);
            if (bResult)
            {
                txtReport.AppendText(report);
            }
            else
            {
                MessageBox.Show("Set test shape failure. Please check the USB", "AFG3252 Error", MessageBoxButton.OK, MessageBoxImage.Error);
                return;
            }
            #endregion
            #region Set channel2 voltage level LVCMOS
            bResult = AutoCalibration.SetChannel2Voltage(MyAFG3252, out report);
            if (bResult)
            {
                txtReport.AppendText(report);
            }
            else
            {
                MessageBox.Show("Set EXT_CLK failure. Please check the USB", "AFG3252 Error", MessageBoxButton.OK, MessageBoxImage.Error);
                return;
            }
            #endregion
            #region Set channel1 low level at 0V
            bResult = MyAFG3252.SetVoltageLow(1, 0, AFG3252.VoltageUnitV);
            if(!bResult)
            {
                MessageBox.Show("Initial AFG3252 failure. Please check the USB cable", "AFG3252 Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
            #endregion
            #region Set output on
            bResult = MyAFG3252.OpenOutput();
            if(bResult)
            {
                txtReport.AppendText("AFG3252 ON\n");
            }
            else
            {
                MessageBox.Show("Set output on failure. Please check the USB cable", "AFG3252 Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
            #endregion
            #region Create test path
            CreateSCTestFolder();
            #endregion
        }

        private bool CreateSCTestFolder()
        {
            string DefaultPath = @"D:\ExperimentsData\test";
            string DefaultSubPath = DateTime.Now.ToString();
            DefaultSubPath = DefaultSubPath.Replace("/", "_");
            DefaultSubPath = DefaultSubPath.Replace(":", "_");
            DefaultSubPath = DefaultSubPath.Replace(" ", "_");
            string TestFolder = Path.Combine(DefaultPath, "SCurveTest", DefaultSubPath);
            if (!Directory.Exists(TestFolder))//路径不存在
            {
                string path = String.Format("File Directory {0} Created\n", TestFolder);
                Directory.CreateDirectory(TestFolder);
                txtReport.AppendText(path);
                txtFileDir.Text = TestFolder;
                return true;
            }
            else
            {
                MessageBox.Show("The File Directory already exits", //text
                                "Created failure",   //caption
                                MessageBoxButton.OK,//button
                                MessageBoxImage.Warning);//icon
                return false;
            }
        }
        private bool SaveSCTestFile(int TestCharge, string AsicID, int HighGainOrLowGain)
        {
            string TestFileName = string.Format("ASIC{0}SCTest{1}fC{2}.dat", AsicID, TestCharge, ((HighGainOrLowGain == 1) ? "HighGain" : "LowGain"));
            filepath = Path.Combine(txtFileDir.Text, TestFileName);
            FileStream fs = null;
            if (!File.Exists(filepath))
            {
                fs = File.Create(filepath);
                string report = String.Format("File:{0} Created\n", filepath);
                txtReport.AppendText(report.ToString());
                StateIndicator.FileSaved = true;
                fs.Close();
                txtFileName.Text = TestFileName;
                return true;
            }
            else
            {
                MessageBox.Show("Save file failure. Please save the file manual", "File Save Error", MessageBoxButton.OK, MessageBoxImage.Error);
                return false;
            }
        }


        private async void btnAutoCalibrationStart_Click(object sender, RoutedEventArgs e)
        {
            bool bResult;
            if (!StateIndicator.AutoCalibrationStart)
            {
                #region Set Common SCurve Parameter
                if (!SetSCurveTestCommomParameter())
                {
                    return;
                }
                #endregion
                #region Caculate Start and end Charge
                if (!CheckStringLegal.CheckIntegerLegal(tbxACStartCharge.Text))
                {
                    ShowIllegalInput("Start Charge should be Integer");
                    return;
                }
                if(!CheckStringLegal.CheckIntegerLegal(tbxACEndCharge.Text))
                {
                    ShowIllegalInput("End Charge should be Integer");
                    return;
                }
                if((int.Parse(tbxACEndCharge.Text) < int.Parse(tbxACStartCharge.Text)))
                {
                    ShowIllegalInput("Start Charge should lower than End Charge");
                    return;
                }
                if (!CheckStringLegal.CheckIntegerLegal(tbxACChargeStep.Text))
                {
                    ShowIllegalInput("Charge Step should be interger");
                    return;
                }
                int StartCharge = int.Parse(tbxACStartCharge.Text);
                int EndCharge = int.Parse(tbxACEndCharge.Text);
                int ChargeStep = int.Parse(tbxACChargeStep.Text);
                #endregion
                #region Check test capacitor
                if (!CheckStringLegal.CheckDoubleLegal(tbxACCTestCapacitor.Text))
                {
                    ShowIllegalInput("Test capacitor should be double");
                    return;
                }
                double TestCapacitor = double.Parse(tbxACCTestCapacitor.Text);
                #endregion
                bool AttenuatorOrNot = cbxACAttenuator.SelectedIndex == 0;
                for (int TestCharge = StartCharge; TestCharge <= EndCharge; TestCharge += ChargeStep)
                {
                    #region Set AFG3252 Voltage
                    double DeltaV = TestCharge / TestCapacitor;
                    double TestVoltage;
                    #region Check attenuator
                    if (DeltaV < 50 & !AttenuatorOrNot)
                    {
                        if(MessageBox.Show("AFG3252 voltage < 50mV. Add Attenuator?", "Confirm Message", MessageBoxButton.YesNo, MessageBoxImage.Question) == MessageBoxResult.Yes)
                        {
                            AttenuatorOrNot = true;
                        }
                        else
                        {
                            return;
                        }
                    }
                    else if(DeltaV > 50 & AttenuatorOrNot)
                    {
                        if (MessageBox.Show("AFG3252 voltage > 5V. Remove Attenuator?", "Confirm Message", MessageBoxButton.YesNo, MessageBoxImage.Question) == MessageBoxResult.Yes)
                        {
                            AttenuatorOrNot = false;
                        }
                        else
                        {
                            return;
                        }
                    }
                    #endregion
                    if (AttenuatorOrNot)
                    {
                        TestVoltage = DeltaV * 100;
                    }
                    else
                    {
                        TestVoltage = DeltaV;
                    }
                    bResult = MyAFG3252.SetVoltageHigh(1, TestVoltage, AFG3252.VoltageUnitMV);
                    if(!bResult)
                    {
                        ShowUsbError("Set AFG3252");
                        return;
                    }
                    #endregion
                    #region Set Start and End DAC
                    int TestDac;
                    if (cbxACHighGainOrLowGain.SelectedIndex == 1)
                    {
                        TestDac = 600 - 4 * TestCharge;
                    }
                    else
                    {
                        TestDac = 600 - TestCharge;
                    }
                    int StartDac = (TestDac >= 50) ? (TestDac - 50) : 0;
                    if(StartDac > 923)
                    {
                        MessageBox.Show("Start DAC Caculate wrong. Please run debug", "System Error", MessageBoxButton.OK, MessageBoxImage.Error);
                        return;
                    }
                    int EndDac = StartDac + 100;
                    if (!SetStartDac(StartDac.ToString()))
                    {
                        return;
                    }
                    if (!SetEndDac(EndDac.ToString()))
                    {
                        return;
                    }
                    if (!SetDacStep(tbcDacStepNewDif.Text))
                    {
                        return;
                    }
                    int DacStep = int.Parse(tbcDacStepNewDif.Text);
                    #endregion
                    #region Data number
                    if (cbxSingleOrAutoNewDif.SelectedIndex == 1)
                    {
                        StateIndicator.SlowDataRatePackageNumber = HeaderLength + ChannelLength + ((EndDac - StartDac) / DacStep + 1) * OneDacDataLength + TailLength;
                    }
                    //--- 64 Channel Test ---//
                    else
                    {
                        StateIndicator.SlowDataRatePackageNumber = HeaderLength + (ChannelLength + ((EndDac - StartDac) / DacStep + 1) * OneDacDataLength) * 64 + TailLength;
                    }
                    #endregion
                    #region SaveFile
                    if(!SaveSCTestFile(TestCharge, tbxACAsicID.Text,cbxACHighGainOrLowGain.SelectedIndex))
                    {
                        MessageBox.Show("Save file failure", "File Error", MessageBoxButton.OK, MessageBoxImage.Error);
                        return;
                    }
                    #endregion
                    #region Reset test
                    if (!ResetSCurveTest())
                    {
                        return;
                    }
                    if(!ClearUsbFifo())
                    {
                        return;
                    }
                    #endregion
                    tbxACStatus.Text = string.Format("{0}fC", TestCharge);
                    #region Single charge SCurve
                    bResult = SCurveTestStart();
                    if(bResult)
                    {
                        StateIndicator.FileSaved = false;
                        StateIndicator.SlowAcqStart = true;
                        StateIndicator.AutoCalibrationStart = true;
                        btnAutoCalibrationStart.Content = "Calibration Stop";
                        btnAutoCalibrationStart.Background = Brushes.Red;
                        btnSCurveTestStartNewDif.Content = "SCurve Test Stop";
                        btnSCurveTestStartNewDif.Background = Brushes.Red;
                        await Task.Run(() => GetSlowDataRateResultCallBack(MyUsbDevice1));
                        SCurveTestStop();
                        ResetSCurveTest();
                        StateIndicator.SlowAcqStart = false;
                        btnSCurveTestStartNewDif.Content = "SCurve Test Start";
                        btnSCurveTestStartNewDif.Background = Brushes.Green;
                    }
                    else
                    {
                        return;
                    }
                    #endregion
                }
                StateIndicator.AutoCalibrationStart = false;
                btnAutoCalibrationStart.Content = "Calibration Start";
                btnAutoCalibrationStart.Background = Brushes.Green;
            }
            else
            {
                bResult = SCurveTestStop();
                if(!bResult)
                {
                    return;
                }
                bResult = ResetSCurveTest();
                if(!bResult)
                {
                    return;
                }
                StateIndicator.SlowAcqStart = false;
                btnSCurveTestStartNewDif.Content = "SCurve Test Start";
                btnSCurveTestStartNewDif.Background = Brushes.Green;
                StateIndicator.AutoCalibrationStart = false;
                btnAutoCalibrationStart.Content = "Calibration Start";
                btnAutoCalibrationStart.Background = Brushes.Green;
            }
            MediaPlayer TestDonePlayer = new MediaPlayer();
            TestDonePlayer.Open(new Uri("TestDone.wav", UriKind.Relative));
            TestDonePlayer.Play();
        }

        private void btnAutoCalibrationInitial_Click(object sender, RoutedEventArgs e)
        {
            CalibrationInitial();
            btnAutoCalibrationStart.IsEnabled = true;
            btnAutoCalibrationStart.Background = Brushes.Green;
            btnAutoCalibrationStart.Content = "Calibration Start";
        }

        private void btnHelp_Click(object sender, RoutedEventArgs e)
        {
            Process.Start(AppDomain.CurrentDomain.BaseDirectory + "Help/Help.html");
        }

        private bool PowerPulsingPinEnable()
        {
            if(MicrorocAsic.PowerPulsingPinEnableSet(1, MyUsbDevice1))
            {
                txtReport.AppendText("Power Pulsing Pin Enable\n");
                return true;
            }
            else
            {
                MessageBox.Show("Set power pulsing pin enable failure. Please check USB", "USB ERROR", MessageBoxButton.OK, MessageBoxImage.Error);
                return false;
            }
        }

        private bool PowerPulsingPinDisable()
        {
            if (MicrorocAsic.PowerPulsingPinEnableSet(0, MyUsbDevice1))
            {
                txtReport.AppendText("Power Pulsing Pin Disable\n");
                return true;
            }
            else
            {
                MessageBox.Show("Set power pulsing pin disable failure. Please check USB", "USB ERROR", MessageBoxButton.OK, MessageBoxImage.Error);
                return false;
            }
        }

        private void rdbPowerPulsingEnableNewDif_Checked(object sender, RoutedEventArgs e)
        {
            PowerPulsingPinEnable();
        }

        private void rdbPowerPulsingDisableNewDif_Checked(object sender, RoutedEventArgs e)
        {
            PowerPulsingPinDisable();
        }

        private bool SelectSlowControl()
        {
            if(MicrorocAsic.SlowControlOrReadScopeSelect(0, MyUsbDevice1))
            {
                txtReport.AppendText("Select Slow Control\n");
                StateIndicator.NewDifSlowControlOrReadScope = StateIndicator.NewDifParameterLoad.SlowControl;
                return true;
            }
            else
            {
                MessageBox.Show("Select Slow Control failure. Please check USB", "USB ERROR", MessageBoxButton.OK, MessageBoxImage.Error);
                return false;
            }
        }
        private bool SelectReadScope()
        {
            if (MicrorocAsic.SlowControlOrReadScopeSelect(1, MyUsbDevice1))
            {
                txtReport.AppendText("Select Read Scope\n");
                StateIndicator.NewDifSlowControlOrReadScope = StateIndicator.NewDifParameterLoad.ReadScope;
                return true;
            }
            else
            {
                MessageBox.Show("Select Read Scope failure. Please check USB", "USB ERROR", MessageBoxButton.OK, MessageBoxImage.Error);
                return false;
            }
        }

        private void rdbSlowControlSet_Checked(object sender, RoutedEventArgs e)
        {
            btnConfigurationParameterLoad.Content = "Slow Control";
            SelectSlowControl();
        }

        private void rdbReadScopeSet_Checked(object sender, RoutedEventArgs e)
        {
            btnConfigurationParameterLoad.Content = "Read Scope";
            SelectReadScope();
        }

        private async void btnStartCarrierUsb_Click(object sender, RoutedEventArgs e)
        {
            #region Check File Legal
            if (!CheckFileSaved())
            {
                return;
            }
            #endregion
            if (StateIndicator.SlowAcqStart == false)
            {
                StateIndicator.SlowAcqStart = true;
                txtReport.AppendText("Microroc Carier USB Stop\n");
                btnStartCarrierUsb.Content = "2. Data Stop";
                await Task.Run(() => GetSlowDataRateResultCallBack(MyUsbDevice1));
                
                Thread.Sleep(10);
                StateIndicator.SlowAcqStart = false;
                StateIndicator.FileSaved = false;
            }
            else
            {
                btnStartCarrierUsb.Content = "2. Data Start";
                Thread.Sleep(10);
                StateIndicator.SlowAcqStart = false;
                StateIndicator.FileSaved = false;
            }
        }

        private void btnSelectCarrier_Click(object sender, RoutedEventArgs e)
        {
            StateIndicator.OperationModeSelect = StateIndicator.OperationMode.MicrorocCarier;
            StateIndicator.SlowDataRatePackageNumber = 0;
            txtReport.AppendText("Select Microroc Carier board\n");
        }

        private void btnConfigurationParameterLoad_Click(object sender, RoutedEventArgs e)
        {
            #region Generate parameter array
            #region Header
            TextBox[] tbxHeaderChain = new TextBox[4] { tbxHeaderChain1, tbxHeaderChain2, tbxHeaderChain3, tbxHeaderChain4 };
            #endregion
            #region Enabled
            int[] ChainEnable = new int[4] { cbxEnableChain1.SelectedIndex, cbxEnableChain2.SelectedIndex, cbxEnableChain3.SelectedIndex, cbxEnableChain4.SelectedIndex };
            #endregion
            #region Vth0~2
            TextBox[,] tbxVth0Asic = new TextBox[4, 4] {
                {tbxVth0Asic11, tbxVth0Asic12, tbxVth0Asic13, tbxVth0Asic14},
                {tbxVth0Asic21, tbxVth0Asic22, tbxVth0Asic23, tbxVth0Asic24 },
                {tbxVth0Asic31, tbxVth0Asic32, tbxVth0Asic33, tbxVth0Asic34 },
                {tbxVth0Asic41, tbxVth0Asic42, tbxVth0Asic43, tbxVth0Asic44 }
            };
            TextBox[,] tbxVth1Asic = new TextBox[4, 4] {
                {tbxVth1Asic11, tbxVth1Asic12, tbxVth1Asic13, tbxVth1Asic14},
                {tbxVth1Asic21, tbxVth1Asic22, tbxVth1Asic23, tbxVth1Asic24 },
                {tbxVth1Asic31, tbxVth1Asic32, tbxVth1Asic33, tbxVth1Asic34 },
                {tbxVth1Asic41, tbxVth1Asic42, tbxVth1Asic43, tbxVth1Asic44 }
            };
            TextBox[,] tbxVth2Asic = new TextBox[4, 4] {
                {tbxVth2Asic11, tbxVth2Asic12, tbxVth2Asic13, tbxVth2Asic14},
                {tbxVth2Asic21, tbxVth2Asic22, tbxVth2Asic23, tbxVth2Asic24 },
                {tbxVth2Asic31, tbxVth2Asic32, tbxVth2Asic33, tbxVth2Asic34 },
                {tbxVth2Asic41, tbxVth2Asic42, tbxVth2Asic43, tbxVth2Asic44 }
            };
            #endregion
            #region Shaper out
            ComboBox[,] cbxShaperHighOrLowGainChain = new ComboBox[4, 4] {
                {cbxShaperAsic11, cbxShaperAsic12, cbxShaperAsic13, cbxShaperAsic14} ,
                {cbxShaperAsic21, cbxShaperAsic22, cbxShaperAsic23, cbxShaperAsic24 },
                {cbxShaperAsic31, cbxShaperAsic32, cbxShaperAsic33, cbxShaperAsic34 },
                {cbxShaperAsic41, cbxShaperAsic42, cbxShaperAsic43, cbxShaperAsic44 }
            };
            #endregion
            #region CTest Channel
            TextBox[,] tbxCTestChannelAsic = new TextBox[4, 4]
            {
                {tbxCTestChannelAsic11, tbxCTestChannelAsic12, tbxCTestChannelAsic13, tbxCTestChannelAsic14 },
                {tbxCTestChannelAsic21, tbxCTestChannelAsic22, tbxCTestChannelAsic23, tbxCTestChannelAsic24 },
                {tbxCTestChannelAsic31, tbxCTestChannelAsic32, tbxCTestChannelAsic33, tbxCTestChannelAsic34 },
                {tbxCTestChannelAsic41, tbxCTestChannelAsic42, tbxCTestChannelAsic43, tbxCTestChannelAsic44 }
            };
            #endregion
            #region Calibration File
            TextBox[,] tbxCalibrationAsic = new TextBox[4, 4]
            {
                {tbxCalibrationAsic11, tbxCalibrationAsic12, tbxCalibrationAsic13, tbxCalibrationAsic14 },
                {tbxCalibrationAsic21, tbxCalibrationAsic22, tbxCalibrationAsic23, tbxCalibrationAsic24 },
                {tbxCalibrationAsic31, tbxCalibrationAsic32, tbxCalibrationAsic33, tbxCalibrationAsic34 },
                {tbxCalibrationAsic41, tbxCalibrationAsic42, tbxCalibrationAsic43, tbxCalibrationAsic44 }
            };
            #endregion
            #region Read Scope
            TextBox[,] tbxReadScopeAsic = new TextBox[4, 4]
            {
                {tbxReadScopeAsic11, tbxReadScopeAsic12, tbxReadScopeAsic13, tbxReadScopeAsic14 },
                {tbxReadScopeAsic21, tbxReadScopeAsic22, tbxReadScopeAsic23, tbxReadScopeAsic24 },
                {tbxReadScopeAsic31, tbxReadScopeAsic32, tbxReadScopeAsic33, tbxReadScopeAsic34 },
                {tbxReadScopeAsic41, tbxReadScopeAsic42, tbxReadScopeAsic43, tbxReadScopeAsic44 }
            };
            #endregion
            #region Sw hg
            ComboBox[,] cbxHighGainFeedbackAsic = new ComboBox[4, 4]
            {
                {cbxHighGainFeedbackAsic11, cbxHighGainFeedbackAsic12, cbxHighGainFeedbackAsic13, cbxHighGainFeedbackAsic14 },
                {cbxHighGainFeedbackAsic21, cbxHighGainFeedbackAsic22, cbxHighGainFeedbackAsic23, cbxHighGainFeedbackAsic24 },
                {cbxHighGainFeedbackAsic31, cbxHighGainFeedbackAsic32, cbxHighGainFeedbackAsic33, cbxHighGainFeedbackAsic34 },
                {cbxHighGainFeedbackAsic41, cbxHighGainFeedbackAsic42, cbxHighGainFeedbackAsic43, cbxHighGainFeedbackAsic44 }
            };
            #endregion
            #region Sw lg
            ComboBox[,] cbxLowGainShaperFeedbackAsic = new ComboBox[4, 4]
            {
                {cbxLowGainFeedbackAsic11, cbxLowGainFeedbackAsic12, cbxLowGainFeedbackAsic13, cbxLowGainFeedbackAsic14 },
                {cbxLowGainFeedbackAsic21, cbxLowGainFeedbackAsic22, cbxLowGainFeedbackAsic23, cbxLowGainFeedbackAsic24 },
                {cbxLowGainFeedbackAsic31, cbxLowGainFeedbackAsic32, cbxLowGainFeedbackAsic33, cbxLowGainFeedbackAsic34 },
                {cbxLowGainFeedbackAsic41, cbxLowGainFeedbackAsic42, cbxLowGainFeedbackAsic43, cbxLowGainFeedbackAsic44 }
            };
            #endregion
            #region Mask Select
            ComboBox[,] cbxMaskSelectAsic = new ComboBox[4, 4]
            {
                {cbxMaskSelectAsic11, cbxMaskSelectAsic12, cbxMaskSelectAsic13, cbxMaskSelectAsic14 },
                {cbxMaskSelectAsic21, cbxMaskSelectAsic22, cbxMaskSelectAsic23, cbxMaskSelectAsic24 },
                {cbxMaskSelectAsic31, cbxMaskSelectAsic32, cbxMaskSelectAsic33, cbxMaskSelectAsic34 },
                {cbxMaskSelectAsic41, cbxMaskSelectAsic42, cbxMaskSelectAsic43, cbxMaskSelectAsic44 }
            };
            #endregion
            #region Mask File
            TextBox[,] tbxMaskFileAsic = new TextBox[4, 4]
            {
                {tbxMaskFileAsic11, tbxMaskFileAsic12, tbxMaskFileAsic13, tbxMaskFileAsic14 },
                {tbxMaskFileAsic21, tbxMaskFileAsic22, tbxMaskFileAsic23, tbxMaskFileAsic24 },
                {tbxMaskFileAsic31, tbxMaskFileAsic32, tbxMaskFileAsic33, tbxMaskFileAsic34 },
                {tbxMaskFileAsic41, tbxMaskFileAsic42, tbxMaskFileAsic43, tbxMaskFileAsic44 }
            };
            #endregion
            #region DiscriminatorSelect
            ComboBox[,] cbxMaskDiscriminatorAsic = new ComboBox[4, 4]
            {
                {cbxMaskDiscriminatorAsic11, cbxMaskDiscriminatorAsic12, cbxMaskDiscriminatorAsic13, cbxMaskDiscriminatorAsic14 },
                {cbxMaskDiscriminatorAsic21, cbxMaskDiscriminatorAsic22, cbxMaskDiscriminatorAsic23, cbxMaskDiscriminatorAsic24 },
                {cbxMaskDiscriminatorAsic31, cbxMaskDiscriminatorAsic32, cbxMaskDiscriminatorAsic33, cbxMaskDiscriminatorAsic34 },
                {cbxMaskDiscriminatorAsic41, cbxMaskDiscriminatorAsic42, cbxMaskDiscriminatorAsic43, cbxMaskDiscriminatorAsic44 }
            };
            #endregion        
            #endregion

            #region EndReadoutParameter
            int EndReadoutParameter = ChainEnable[0] + ChainEnable[1] * 2 + ChainEnable[2] * 4 + ChainEnable[3] * 8;
            bool bResult = MicrorocAsic.EndReadoutParameterSet(EndReadoutParameter, MyUsbDevice1);
            string report;
            if(bResult)
            {
                report = string.Format("Set EndReadoutParameter: {0}{1}{2}{3}\n", ChainEnable[0], ChainEnable[1], ChainEnable[2], ChainEnable[3]);
                txtReport.AppendText(report);
            }
            else
            {
                ShowUsbError("EndReadoutParameter");
            }
            #endregion
            #region RAZ Channel
            bResult = SelectRazChannel(cbxRazSelectNewDif.SelectedIndex);
            if(!bResult)
            {
                return;
            }
            bResult = SetInternalRazTime(cbxInternalRazTimeNewDif.SelectedIndex);
            if(!bResult)
            {
                return;
            }
            bResult = SetExternalRazTime(cbxExternalRazTimeNewDif.SelectedIndex);
            if(!bResult)
            {
                return;
            }
            bResult = SetExternalRazDelay("200");
            if (!bResult)
            {
                return;
            }
            #endregion
            for (int i = 0; i<4; i++)
            {
                if(ChainEnable[i] == 0)
                {
                    continue;
                }
                #region Select ASIC chain
                bResult = SelectAsicChain(MicrorocAsicChain[i]);
                if(!bResult)
                {
                    return;
                }
                #endregion
                for (int j = 3; j>=0; j--)
                {
                    #region SlowControl
                    if(StateIndicator.NewDifSlowControlOrReadScope == StateIndicator.NewDifParameterLoad.SlowControl)
                    {
                        #region Set Header
                        bResult = SetAsicHeader(tbxHeaderChain[i].Text, MicrorocAsicChain[i], j);
                        if (!bResult)
                        {
                            return;
                        }
                        #endregion
                        #region Set VTH
                        bResult = SetDac0Vth(tbxVth0Asic[i, j].Text, MicrorocAsicChain[i], j);
                        if(!bResult)
                        {
                            return;
                        }
                        bResult = SetDac1Vth(tbxVth1Asic[i, j].Text, MicrorocAsicChain[i], j);
                        if (!bResult)
                        {
                            return;
                        }
                        bResult = SetDac2Vth(tbxVth2Asic[i, j].Text, MicrorocAsicChain[i], j);
                        if (!bResult)
                        {
                            return;
                        }
                        #endregion
                        #region Shaper Out
                        bResult = SetShaperHighOrLowGain(cbxShaperHighOrLowGainChain[i, j].SelectedIndex, MicrorocAsicChain[i], j);
                        if(!bResult)
                        {
                            return;
                        }
                        #endregion
                        #region Set CTest channel
                        bResult = SetCTestChannel(tbxCTestChannelAsic[i, j].Text, MicrorocAsicChain[i], j);
                        if(!bResult)
                        {
                            return;
                        }
                        #endregion
                        #region Calibration
                        string CalibrationFileName;
                        StreamReader CalibrationFile;
                        CalibrationFileName = Path.Combine(CurrentPath, tbxCalibrationAsic[i, j].Text);
                        if (File.Exists(CalibrationFileName))
                        {
                            byte[] CalibrationData = new byte[64];
                            CalibrationFile = File.OpenText(CalibrationFileName);
                            string CalibrationDataString;
                            for (int m = 0; m < 64; m++)
                            {
                                CalibrationDataString = CalibrationFile.ReadLine();
                                if(CalibrationDataString != null)
                                {
                                    CalibrationData[m] = byte.Parse(CalibrationDataString);
                                }
                                else
                                {
                                    CalibrationData[m] = 0;
                                }
                            }
                            bResult = SetCalibrationData(MicrorocAsicChain[i], j, CalibrationData);
                            if(!bResult)
                            {
                                return;
                            }
                        }
                        else
                        {
                            MessageBox.Show("Do not found Calibration File. Skip the calibration", "FILE NOT FOUND", MessageBoxButton.OK, MessageBoxImage.Information);
                        }
                        #endregion
                        #region Sw hg
                        bResult = SetHighGainFeedbackParameter(cbxHighGainFeedbackAsic[i, j].SelectedIndex, MicrorocAsicChain[i], j);
                        if(!bResult)
                        {
                            return;
                        }
                        #endregion
                        #region SW lg
                        bResult = SetLowGainFeedbackParameter(cbxLowGainShaperFeedbackAsic[i, j].SelectedIndex, MicrorocAsicChain[i], j);
                        if(!bResult)
                        {
                            return;
                        }
                        #endregion
                        #region Discriminator Mask
                        string MaskFileName;
                        StreamReader MaskFile;
                        MaskFileName = Path.Combine(CurrentPath, tbxMaskFileAsic[i, j].Text);
                        ArrayList MaskChannel = new ArrayList();
                        if (File.Exists(MaskFileName))
                        {
                            string MaskChannelTemp;
                            MaskFile = File.OpenText(MaskFileName);
                            MaskChannelTemp = MaskFile.ReadLine();
                            while(MaskChannelTemp != null)
                            {
                                MaskChannel.Add(MaskChannelTemp);
                                MaskChannelTemp = MaskFile.ReadLine();
                            }
                            string[] Channel = (string[])MaskChannel.ToArray(typeof(string));
                            bResult = SetChannelMask(cbxMaskSelectAsic[i, j].SelectedIndex, cbxMaskDiscriminatorAsic[i, j].SelectedIndex, j, MicrorocAsicChain[i], Channel);
                            if(!bResult)
                            {
                                return;
                            }
                        }
                        else
                        {
                            MessageBox.Show("Mask file not found. Skip the set.", "FILE NOT FOUND", MessageBoxButton.OK, MessageBoxImage.Information);
                        }
                        #endregion
                    }
                    #endregion
                    #region ReadScope
                    else
                    {
                        bResult = SetReadScopeChannel(tbxReadScopeAsic[i, j].Text, MicrorocAsicChain[i], j);
                        if(!bResult)
                        {
                            return;
                        }
                    }
                    #endregion
                    #region Parameter Load
                    bResult = ConfigurationParameterLoad(MicrorocAsicChain[j]);
                    if(!bResult)
                    {
                        return;
                    }
                    #endregion
                }
            }
        }

        private bool SelectAsicChain(MicrorocAsic MyMicroroc)
        {
            bool bResult = MyMicroroc.SelectAsicChain(MyUsbDevice1);
            if (bResult)
            {
                string report = string.Format("Select Chain{0}\n", MyMicroroc.ChainID);
                txtReport.AppendText(report);
                return true;
            }
            else
            {
                ShowUsbError("Chain Select");
                return false;
            }
        }

        private bool ConfigurationParameterLoad(MicrorocAsic MyMicroroc)
        {
            bool bResult = MyMicroroc.ParameterLoadStart(MyUsbDevice1);
            if(bResult)
            {
                return true;
            }
            else
            {
                ShowUsbError("Load Parameter");
                return false;
            }
        }

        private bool SetDac0Vth(string Dac0Vth, MicrorocAsic MyMicroroc, int AsicLocation)
        {
            bool IllegalInput;
            bool bResult = MyMicroroc.Dac0VthSet(Dac0Vth, MyUsbDevice1, out IllegalInput);
            if(IllegalInput)
            {
                MessageBox.Show("Illegal Input value. The Vth0 should be 0-1023", "Illegal Input ERROR", MessageBoxButton.OK, MessageBoxImage.Error);
                return false;
            }
            if(bResult)
            {
                string report = string.Format("Set ASIC{0}{1} VTH0:{2}\n", MyMicroroc.ChainID + 1, AsicLocation + 1, Dac0Vth);
                txtReport.AppendText(report);
                return true;
            }
            else
            {
                MessageBox.Show("Set VTH0 failure. Please check USB", "USB ERROR", MessageBoxButton.OK, MessageBoxImage.Error);
                return false;
            }
        }
        private bool SetDac1Vth(string Dac1Vth, MicrorocAsic MyMicroroc, int AsicLocation)
        {
            bool IllegalInput;
            bool bResult = MyMicroroc.Dac1VthSet(Dac1Vth, MyUsbDevice1, out IllegalInput);
            if (IllegalInput)
            {
                MessageBox.Show("Illegal Input value. The Vth1 should be 0-1023", "Illegal Input ERROR", MessageBoxButton.OK, MessageBoxImage.Error);
                return false;
            }
            if (bResult)
            {
                string report = string.Format("Set ASIC{0}{1} VTH1:{2}\n", MyMicroroc.ChainID + 1, AsicLocation + 1, Dac1Vth);
                txtReport.AppendText(report);
                return true;
            }
            else
            {
                MessageBox.Show("Set VTH1 failure. Please check USB", "USB ERROR", MessageBoxButton.OK, MessageBoxImage.Error);
                return false;
            }
        }
        private bool SetDac2Vth(string Dac2Vth, MicrorocAsic MyMicroroc, int AsicLocation)
        {
            bool IllegalInput;
            bool bResult = MyMicroroc.Dac2VthSet(Dac2Vth, MyUsbDevice1, out IllegalInput);
            if (IllegalInput)
            {
                MessageBox.Show("Illegal Input value. The Vth2 should be 0-1023", "Illegal Input ERROR", MessageBoxButton.OK, MessageBoxImage.Error);
                return false;
            }
            if (bResult)
            {
                string report = string.Format("Set ASIC{0}{1} VTH2:{2}\n", MyMicroroc.ChainID + 1, AsicLocation + 1, Dac2Vth);
                txtReport.AppendText(report);
                return true;
            }
            else
            {
                MessageBox.Show("Set VTH2 failure. Please check USB", "USB ERROR", MessageBoxButton.OK, MessageBoxImage.Error);
                return false;
            }
        }

        private bool SetAsicHeader(string Header,  MicrorocAsic myMicroroc, int AsicLocation)
        {
            bool IllegalInput;
            bool bResult = myMicroroc.SetChipID(Header, AsicLocation, MyUsbDevice1, out IllegalInput);
            if(IllegalInput)
            {
                ShowIllegalInput("The header value should be 00-FF");
                return false;
            }
            if(bResult)
            {
                int AsicHeader = Convert.ToInt32(Header, 16) + AsicLocation;
                string report = string.Format("Set ASIC{0}{1} Header:{2}\n", myMicroroc.ChainID + 1, AsicLocation + 1, AsicHeader.ToString("X"));
                txtReport.AppendText(report);
                return true;
            }
            else
            {
                ShowUsbError("Header");
                return false;
            }
        }

        private bool SetShaperHighOrLowGain(int HighOrLow, MicrorocAsic MyMicroroc, int AsicLocation)
        {
            bool bResult = MyMicroroc.ShaperOutLowGainOrHighGainSelect(HighOrLow, MyUsbDevice1);
            if(bResult)
            {
                string report = string.Format("Set ASIC{0}{1} Shaper output {2} gain\n", MyMicroroc.ChainID + 1, AsicLocation + 1, ((HighOrLow == 1) ? "High" : "Low"));
                txtReport.AppendText(report);
                return true;
            }
            else
            {
                ShowUsbError("Shaper output");
                return false;
            }
        }

        private bool SetCTestChannel(string CTestChannel, MicrorocAsic MyMicroroc, int AsicLocation)
        {
            bool IllegalInput;
            bool bResult = MyMicroroc.CTestChannelSet(CTestChannel, MyUsbDevice1, out IllegalInput);
            if(IllegalInput)
            {
                ShowIllegalInput("CTest Channel should be 1-64");
                return false;
            }
            if(bResult)
            {
                string report = string.Format("Set ASIC{0}{1} CTest channel: {2}\n", MyMicroroc.ChainID + 1, AsicLocation + 1, CTestChannel);
                txtReport.AppendText(report);
                return true;
            }
            else
            {
                ShowUsbError("CTest Channel");
                return false;
            }
        }
        private bool SetReadScopeChannel(string ReadScopeChannel, MicrorocAsic MyMicroroc, int AsicLocation)
        {
            bool IllegalInput;
            bool bResult = MyMicroroc.ReadScopeChannelSet(ReadScopeChannel, MyUsbDevice1, out IllegalInput);
            if(IllegalInput)
            {
                ShowIllegalInput("Read scope channel should be: 1-64");
                return false;
            }
            if(bResult)
            {
                string report = string.Format("Set ASIC{0}{1} ReadScope channel: {2}\n", MyMicroroc.ChainID + 1, AsicLocation, ReadScopeChannel);
                txtReport.AppendText(report);
                return true;
            }
            else
            {
                ShowUsbError("ReadScope Channel");
                return false;
            }
        }

        private bool SetCalibrationData(MicrorocAsic MyMicroroc, int AsicLocation, params byte[] CalibrationData)
        {
            if(CalibrationData.Length != 64)
            {
                MessageBox.Show("Calibration data is not 64 byte. Skip the calibration", "FILE ERROR", MessageBoxButton.OK, MessageBoxImage.Error);
                return false;
            }
            if(MyMicroroc.SetChannelCalibration(MyUsbDevice1, CalibrationData))
            {
                string report = string.Format("Set ASIC{0}{1} Calibration successful\n", MyMicroroc.ChainID + 1, AsicLocation + 1);
                txtReport.AppendText(report);
                return true;
            }
            else
            {
                ShowUsbError("Calibration");
                return false;
            }
        }

        private bool SetHighGainFeedbackParameter(int HighGainFeedback, MicrorocAsic MyMicroroc, int AsicLocation)
        {
            if (MyMicroroc.HighGainShaperFeedbackSelect(HighGainFeedback, MyUsbDevice1))
            {
                string report = string.Format("Set ASIC{0}{1} Sw_hg: {2}\n", MyMicroroc.ChainID + 1, AsicLocation + 1, HighGainFeedback);
                txtReport.AppendText(report);
                return true;
            }
            else
            {
                ShowUsbError("Sw_hg");
                return false;
            }
        }
        private bool SetLowGainFeedbackParameter(int LowGainFeedback, MicrorocAsic MyMicroroc, int AsicLocation)
        {
            if (MyMicroroc.LowGainShaperFeedbackSelect(LowGainFeedback, MyUsbDevice1))
            {
                string report = string.Format("Set ASIC{0}{1} Sw_lg: {2}\n", MyMicroroc.ChainID + 1, AsicLocation + 1, LowGainFeedback);
                txtReport.AppendText(report);
                return true;
            }
            else
            {
                ShowUsbError("Sw_lg");
                return false;
            }
        }

        private bool SetChannelMask(int MaskMode, int MaskDisCriminator, int AsicLocation, MicrorocAsic MyMicroroc, params string[] MaskChannel)
        {
            bool bResult = MyMicroroc.DiscriminatorMaskSet(MaskDisCriminator, MyUsbDevice1);
            if(!bResult)
            {
                return false;
            }
            bool IllegalInput;
            foreach(string Channel in MaskChannel)
            {
                bResult = MyMicroroc.MaskChannelSet(Channel, MyUsbDevice1, out IllegalInput);
                if(IllegalInput)
                {
                    ShowIllegalInput("The Channel mask should be 0-63");
                    return false;
                }
                if(!bResult)
                {
                    ShowUsbError("Mask Channel");
                    return false;
                }
                bResult = MyMicroroc.MaskModeSet(MaskMode, MyUsbDevice1);
                if(!bResult)
                {
                    return false;
                }
            }
            string report = string.Format("Set ASIC[0][1] Mask Successful", MyMicroroc.ChainID + 1, AsicLocation + 1);
            txtReport.AppendText(report);
            return true;
        }

        private bool SelectRazChannel(int RazChannel)
        {
            bool bResult = MicrorocAsic.ExternalRazOrInternalRazSelect(RazChannel, MyUsbDevice1);
            if(bResult)
            {
                string report = string.Format("Set {0} RAZ\n", (RazChannel == 1 ? "External" : "Internal"));
                txtReport.AppendText(report);
                return true;
            }
            else
            {
                ShowUsbError("Select RAZ Channel");
                return false;
            }
        }
        private bool SetInternalRazTime(int InternalRazTime)
        {
            string RazTime;
            switch (InternalRazTime)
            {
                case 0: RazTime = "75ns"; break;
                case 1: RazTime = "250ns"; break;
                case 2: RazTime = "500ns"; break;
                case 3: RazTime = "1000ns"; break;
                default: RazTime = "1000ns"; break;
            }
            bool bResult = MicrorocAsic.InternalRazSignalLengthSelect(InternalRazTime, MyUsbDevice1);
            if(bResult)
            {
                string report = string.Format("Set Internal RAZ Time: {0}\n", RazTime);
                txtReport.AppendText(report);
                return true;
            }
            else
            {
                ShowUsbError("Set Internal RAZ");
                return false;
            }
        }

        private bool SetExternalRazTime(int ExternalRazTime)
        {
            string RazTime;
            switch(ExternalRazTime)
            {
                case 0: RazTime = "75ns";break;
                case 1: RazTime = "250ns";break;
                case 2: RazTime = "500ns";break;
                case 3: RazTime = "1000ns";break;
                default: RazTime = "1000ns";break;
            }
            bool bResult = MicrorocAsic.ExternalRazModeSelect(ExternalRazTime, MyUsbDevice1);
            if(bResult)
            {
                string report = string.Format("Set External RAZ Time:{0}\n", RazTime);
                txtReport.AppendText(report);
                return true;
            }
            else
            {
                ShowUsbError("Set External RAZ");
                return false;
            }
        }
        private bool SetExternalRazDelay(string ExternalRazDelayTime)
        {
            bool IllegalInput;
            bool bResult = MicrorocAsic.ExternalRazDelayTimeSet(ExternalRazDelayTime, MyUsbDevice1, out IllegalInput);
            if(IllegalInput)
            {
                ShowIllegalInput("The External RAZ Delay Time should be 0-375");
                return false;
            }
            if(bResult)
            {
                string report = string.Format("Set External RAZ Delay Time {0}ns\n", ExternalRazDelayTime);
                txtReport.AppendText(report);
                return true;
            }
            else
            {
                ShowUsbError("Set Extenal RAZ Delay");
                return false;
            }
        }

        private void ShowIllegalInput(string SetItem)
        {
            string ErrorMessage = string.Format("Illegal Input Value. {0}", SetItem);
            MessageBox.Show(ErrorMessage, "Illegal Input ERROR", MessageBoxButton.OK, MessageBoxImage.Error);
        }
        private void ShowUsbError(string SetItem)
        {
            string ErrorMessage = string.Format("Set {0} failure. Pease check USB", SetItem);
            MessageBox.Show(ErrorMessage, "USB ERROR", MessageBoxButton.OK, MessageBoxImage.Error);
        }

        private void btnSendSerialData_Click(object sender, RoutedEventArgs e)
        {
            int TranmitData = Convert.ToInt32(tbxSerialData.Text, 16);
            int TransmitData1 = (TranmitData & 15) + Convert.ToInt32("A0B0", 16);
            int TransmitData2 = ((TranmitData >> 4) & 15) + Convert.ToInt32("A0C0", 16);
            MyUsbDevice1.CommandSend(MyUsbDevice1.ConstCommandByteArray(TransmitData1));
            MyUsbDevice1.CommandSend(MyUsbDevice1.ConstCommandByteArray(TransmitData2));
            Thread.Sleep(100);
            MyUsbDevice1.CommandSend(MyUsbDevice1.ConstCommandByteArray(Convert.ToInt32("A0A1", 16)));
            string report = string.Format("Send serial data: {0}", tbxSerialData.Text);
            txtReport.AppendText(report);
        }
        bool MicrorocCarrierUsbStart = false;
        private void btnMicrorocCarierUsbStart_Click(object sender, RoutedEventArgs e)
        {
            if(MicrorocCarrierUsbStart == false)
            {
                MicrorocCarrierUsbStart = true;
                btnMicrorocCarierUsbStart.Content = "3. USB Stop";
                MyUsbDevice1.CommandSend(MyUsbDevice1.ConstCommandByteArray(HexStringToByteArray("A0D1")));
                txtReport.AppendText("USB Start\n");
            }
            else
            {
                MicrorocCarrierUsbStart = false;
                btnMicrorocCarierUsbStart.Content = "3. USB Start";
                MyUsbDevice1.CommandSend(MyUsbDevice1.ConstCommandByteArray(HexStringToByteArray("A0D0")));
                txtReport.AppendText("USB Stop\n");
            }
        }

        private void tbiSCTestNewDif_MouseLeftButtonUp(object sender, System.Windows.Input.MouseButtonEventArgs e)
        {
            bool bResult = MicrorocAsic.RunningModeSelect(1, MyUsbDevice1);
            if(bResult)
            {
                txtReport.AppendText("Select SCurveTest\n");
                DisableNewDif();
            }
            else
            {
                ShowUsbError("Select SCurve Test");
            }
        }

        private void rdbAcquisitionNewDif_Checked(object sender, RoutedEventArgs e)
        {
            bool bResult = MicrorocAsic.RunningModeSelect(0, MyUsbDevice1);
            if(bResult)
            {
                txtReport.AppendText("Select Acquisition\n");
                SelectAcuqisitionNewDif();
                DisableSCurveTestNewDif();
                btnNewDifAcquisitionStartNewDif.Background = Brushes.Green;
            }
            else
            {
                ShowUsbError("Select Acquisition");
                rdbAcquisitionNewDif.IsChecked = false;
            }
        }

        private void rdbAD9220NewDif_Checked(object sender, RoutedEventArgs e)
        {
            bool bResult = MicrorocAsic.RunningModeSelect(2, MyUsbDevice1);
            if (bResult)
            {
                txtReport.AppendText("Select ADC\n");
                SelectAd9220NewDif();
                DisableSCurveTestNewDif();
            }
            else
            {
                ShowUsbError("Select ADC");
                rdbAD9220NewDif.IsChecked = false;
            }
        }

        private void DisableNewDif()
        {
            gbxIndependentControl.IsEnabled = false;
            tbcNewDifAcquisition.IsEnabled = false;
            stpAcquisitionModeSelectNewDif.IsEnabled = true;
            rdbAcquisitionNewDif.IsChecked = false;
            rdbAD9220NewDif.IsChecked = false;
            rdbPowerPulsingDisableNewDif.IsChecked = false;
            rdbPowerPulsingEnableNewDif.IsChecked = false;
            rdbReadScopeSet.IsChecked = false;
            rdbSlowControlSet.IsChecked = false;
            btnConfigurationParameterLoad.IsEnabled = false;
            stpPowerPulsingNewDif.IsEnabled = false;
            stpSlowControlOrReadScopeNewDif.IsEnabled = false;
            rdbAutoDaqNewDif.IsChecked = false;
            rdbSlaveDaqNewDif.IsChecked = false;
        }
        private void SelectAcuqisitionNewDif()
        {
            gbxIndependentControl.IsEnabled = true;
            tbcNewDifAcquisition.IsEnabled = true;
            tbcNewDifAcquisition.SelectedIndex = 0;
            btnConfigurationParameterLoad.IsEnabled = true;
            stpPowerPulsingNewDif.IsEnabled = true;
            stpSlowControlOrReadScopeNewDif.IsEnabled = true;
            tbmAdcControlNewDif.IsEnabled = false;
            tbmNewDifAcquisition.IsEnabled = false;
            HoldDisable();
        }
        private void SelectAd9220NewDif()
        {
            gbxIndependentControl.IsEnabled = true;
            tbcNewDifAcquisition.IsEnabled = true;
            tbcNewDifAcquisition.SelectedIndex = 1;
            btnConfigurationParameterLoad.IsEnabled = true;
            stpPowerPulsingNewDif.IsEnabled = true;
            stpSlowControlOrReadScopeNewDif.IsEnabled = true;
            rdbAutoDaqNewDif.IsChecked = false;
            rdbSlaveDaqNewDif.IsChecked = false;
            btnNewDifAcquisitionStartNewDif.IsEnabled = false;
            tbmNewDifAcquisition.IsEnabled = false;
            tbmAdcControlNewDif.IsEnabled = true;
            btnStartAdcNewDif.IsEnabled = false;
            btnStartAdcNewDif.Background = Brushes.Green;
            HoldEnable();
            bool bResult = PowerPulsingPinDisable();
            if(bResult)
            {
                rdbPowerPulsingDisableNewDif.IsChecked = true;
                rdbPowerPulsingEnableNewDif.IsChecked = false;
            }
            else
            {
                return;
            }
        }

        private void DisableSCurveTestNewDif()
        {
            rdbTriggerEfficiencyNewDif.IsChecked = false;
            rdbCountEfficiencyNewDif.IsChecked = false;
            cbxSingleOrAutoNewDif.IsEnabled = false;
            cbxCTestOrInputNewDif.IsEnabled = false;
            cbxCPT_MAX_NewDif.IsEnabled = false;
            tbcCountTimeNewDif.IsEnabled = false;
            tbcSingleTestChannelNewDif.IsEnabled = false;
            tbcStartDacNewDif.IsEnabled = false;
            tbcDacStepNewDif.IsEnabled = false;
            tbcEndDacNewDif.IsEnabled = false;
            cbxUnmaskAllChannelNewDif.IsEnabled = false;
            cbxSCurveTestAsicNewDif.IsEnabled = false;
            btnSCurveTestStartNewDif.IsEnabled = false;
            gbxExternalRazParameterNewDif.IsEnabled = false;
            rdbTriggerEfficiencyNewDif.IsChecked = false;
            rdbCountEfficiencyNewDif.IsChecked = false;
            btnNewDifAcquisitionStartNewDif.IsEnabled = false;
        }

        private void SelectSCurveTriggerMode()
        {
            bool bResult = MicrorocAsic.SCurveTestTriggerOrCountModeSelect(1, MyUsbDevice1);
            if (bResult)
            {
                txtReport.AppendText("Select Trigger Mode\n");
            }
            else
            {
                ShowUsbError("Select Trigger Mode");
                rdbTriggerEfficiencyNewDif.IsChecked = false;
                return;
            }
            cbxSingleOrAutoNewDif.IsEnabled = true;
            cbxCTestOrInputNewDif.IsEnabled = true;
            cbxCPT_MAX_NewDif.IsEnabled = true;
            tbcCountTimeNewDif.IsEnabled = false;
            tbcSingleTestChannelNewDif.IsEnabled = true;
            tbcStartDacNewDif.IsEnabled = true;
            tbcDacStepNewDif.IsEnabled = true;
            tbcEndDacNewDif.IsEnabled = true;
            cbxUnmaskAllChannelNewDif.IsEnabled = true;
            cbxSCurveTestAsicNewDif.IsEnabled = true;
            btnSCurveTestStartNewDif.IsEnabled = true;
            btnSCurveTestStartNewDif.Background = Brushes.Green;
            gbxExternalRazParameterNewDif.IsEnabled = true;
            HoldDisable();
            bResult = PowerPulsingPinDisable();
            if (bResult)
            {
                rdbPowerPulsingDisable.IsChecked = true;
                rdbPowerPulsingEnable.IsChecked = false;
            }
            else
            {
                return;
            }
        }
        private void SelectSCurveCountMode()
        {
            bool bResult = MicrorocAsic.SCurveTestTriggerOrCountModeSelect(0, MyUsbDevice1);
            if(bResult)
            {
                txtReport.AppendText("Select Count Mode\n");
            }
            else
            {
                ShowUsbError("Select Count Mode");
                rdbCountEfficiencyNewDif.IsChecked = false;
                return;
            }
            cbxSingleOrAutoNewDif.IsEnabled = true;
            cbxCTestOrInputNewDif.IsEnabled = true;
            cbxCPT_MAX_NewDif.IsEnabled = false;
            tbcCountTimeNewDif.IsEnabled = true;
            tbcSingleTestChannelNewDif.IsEnabled = true;
            tbcStartDacNewDif.IsEnabled = true;
            tbcDacStepNewDif.IsEnabled = true;
            tbcEndDacNewDif.IsEnabled = true;
            cbxUnmaskAllChannelNewDif.IsEnabled = true;
            cbxSCurveTestAsicNewDif.IsEnabled = true;
            btnSCurveTestStartNewDif.IsEnabled = true;
            btnSCurveTestStartNewDif.Background = Brushes.Green;
            gbxExternalRazParameterNewDif.IsEnabled = true;
            HoldDisable();
            bResult = PowerPulsingPinDisable();
            if (bResult)
            {
                rdbPowerPulsingDisable.IsChecked = true;
                rdbPowerPulsingEnable.IsChecked = false;
            }
            else
            {
                return;
            }
        }



        private void rdbTriggerEfficiencyNewDif_Checked(object sender, RoutedEventArgs e)
        {
            SelectSCurveTriggerMode();
        }

        private void rdbCountEfficiencyNewDif_Checked(object sender, RoutedEventArgs e)
        {
            SelectSCurveCountMode();
        }

        private void rdbAutoDaqNewDif_Checked(object sender, RoutedEventArgs e)
        {
            

            bool bResult = false;
            
            bResult = SelectSlowControl();
            if(!bResult)
            {
                return;
            }
            else
            {
                rdbSlowControlSet.IsChecked = true;
                rdbReadScopeSet.IsChecked = false;
            }
            StateIndicator.DaqModeSelect = StateIndicator.DaqMode.AutoDaq;
            #region Enabled
            int[] ChainEnable = new int[4] { cbxEnableChain1.SelectedIndex, cbxEnableChain2.SelectedIndex, cbxEnableChain3.SelectedIndex, cbxEnableChain4.SelectedIndex };
            #endregion
            #region Vth0~2
            TextBox[,] tbxVth0Asic = new TextBox[4, 4] {
                {tbxVth0Asic11, tbxVth0Asic12, tbxVth0Asic13, tbxVth0Asic14},
                {tbxVth0Asic21, tbxVth0Asic22, tbxVth0Asic23, tbxVth0Asic24 },
                {tbxVth0Asic31, tbxVth0Asic32, tbxVth0Asic33, tbxVth0Asic34 },
                {tbxVth0Asic41, tbxVth0Asic42, tbxVth0Asic43, tbxVth0Asic44 }
            };
            TextBox[,] tbxVth1Asic = new TextBox[4, 4] {
                {tbxVth1Asic11, tbxVth1Asic12, tbxVth1Asic13, tbxVth1Asic14},
                {tbxVth1Asic21, tbxVth1Asic22, tbxVth1Asic23, tbxVth1Asic24 },
                {tbxVth1Asic31, tbxVth1Asic32, tbxVth1Asic33, tbxVth1Asic34 },
                {tbxVth1Asic41, tbxVth1Asic42, tbxVth1Asic43, tbxVth1Asic44 }
            };
            TextBox[,] tbxVth2Asic = new TextBox[4, 4] {
                {tbxVth2Asic11, tbxVth2Asic12, tbxVth2Asic13, tbxVth2Asic14},
                {tbxVth2Asic21, tbxVth2Asic22, tbxVth2Asic23, tbxVth2Asic24 },
                {tbxVth2Asic31, tbxVth2Asic32, tbxVth2Asic33, tbxVth2Asic34 },
                {tbxVth2Asic41, tbxVth2Asic42, tbxVth2Asic43, tbxVth2Asic44 }
            };
            #endregion
            #region EndReadoutParameter
            int EndReadoutParameter = ChainEnable[0] + ChainEnable[1] * 2 + ChainEnable[2] * 4 + ChainEnable[3] * 8;
            bResult = MicrorocAsic.EndReadoutParameterSet(EndReadoutParameter, MyUsbDevice1);
            string report;
            if (bResult)
            {
                report = string.Format("Set EndReadoutParameter: {0}{1}{2}{3}\n", ChainEnable[0], ChainEnable[1], ChainEnable[2], ChainEnable[3]);
                txtReport.AppendText(report);
            }
            else
            {
                ShowUsbError("EndReadoutParameter");
            }
            #endregion
            for (int i = 0; i < 4; i++)
            {
                #region Select Chain
                bResult = SelectAsicChain(MicrorocAsicChain[i]);
                if(!bResult)
                {
                    return;
                }
                #endregion
                if (ChainEnable[i] == 0)
                {
                    continue;
                }
                for(int j = 3; j >= 0; j--)
                {
                    #region DAC0-2Vth
                    bResult = SetDac0Vth(tbxVth0Asic[i, j].Text, MicrorocAsicChain[i], j);
                    if(!bResult)
                    {
                        return;
                    }
                    bResult = SetDac1Vth(tbxVth1Asic[i, j].Text, MicrorocAsicChain[i], j);
                    if(!bResult)
                    {
                        return;
                    }
                    bResult = SetDac2Vth(tbxVth2Asic[i, j].Text, MicrorocAsicChain[i], j);
                    if(!bResult)
                    {
                        return;
                    }
                    #endregion
                    bResult = ConfigurationParameterLoad(MicrorocAsicChain[j]);
                    if(!bResult)
                    {
                        return;
                    }
                }
            }
            tbxStartAcquisitionTimeNewDif.Text = "40000";
            bResult = MicrorocAsic.DaqModeSelect(1, MyUsbDevice1);
            if(bResult)
            {
                tbxAcquisitionHoldTimeNewDif.IsEnabled = false;
                txtReport.AppendText("Select auto DAQ mode\n");
                btnNewDifAcquisitionStartNewDif.IsEnabled = true;
            }
            else
            {
                ShowUsbError("Select DAQ mode");
                rdbAutoDaqNewDif.IsChecked = false;
            }
        }

        private void rdbSlaveDaqNewDif_Checked(object sender, RoutedEventArgs e)
        {
            bool bResult = false;
            rdbSlowControlSet.IsChecked = true;
            rdbReadScopeSet.IsChecked = false;
            bResult = SelectSlowControl();
            if (!bResult)
            {
                return;
            }
            StateIndicator.DaqModeSelect = StateIndicator.DaqMode.SlaveDaq;
            #region Enabled
            int[] ChainEnable = new int[4] { cbxEnableChain1.SelectedIndex, cbxEnableChain2.SelectedIndex, cbxEnableChain3.SelectedIndex, cbxEnableChain4.SelectedIndex };
            #endregion
            #region Vth0~2
            TextBox[,] tbxVth0Asic = new TextBox[4, 4] {
                {tbxVth0Asic11, tbxVth0Asic12, tbxVth0Asic13, tbxVth0Asic14},
                {tbxVth0Asic21, tbxVth0Asic22, tbxVth0Asic23, tbxVth0Asic24 },
                {tbxVth0Asic31, tbxVth0Asic32, tbxVth0Asic33, tbxVth0Asic34 },
                {tbxVth0Asic41, tbxVth0Asic42, tbxVth0Asic43, tbxVth0Asic44 }
            };
            TextBox[,] tbxVth1Asic = new TextBox[4, 4] {
                {tbxVth1Asic11, tbxVth1Asic12, tbxVth1Asic13, tbxVth1Asic14},
                {tbxVth1Asic21, tbxVth1Asic22, tbxVth1Asic23, tbxVth1Asic24 },
                {tbxVth1Asic31, tbxVth1Asic32, tbxVth1Asic33, tbxVth1Asic34 },
                {tbxVth1Asic41, tbxVth1Asic42, tbxVth1Asic43, tbxVth1Asic44 }
            };
            TextBox[,] tbxVth2Asic = new TextBox[4, 4] {
                {tbxVth2Asic11, tbxVth2Asic12, tbxVth2Asic13, tbxVth2Asic14},
                {tbxVth2Asic21, tbxVth2Asic22, tbxVth2Asic23, tbxVth2Asic24 },
                {tbxVth2Asic31, tbxVth2Asic32, tbxVth2Asic33, tbxVth2Asic34 },
                {tbxVth2Asic41, tbxVth2Asic42, tbxVth2Asic43, tbxVth2Asic44 }
            };
            #endregion
            #region EndReadoutParameter
            int EndReadoutParameter = ChainEnable[0] + ChainEnable[1] * 2 + ChainEnable[2] * 4 + ChainEnable[3] * 8;
            bResult = MicrorocAsic.EndReadoutParameterSet(EndReadoutParameter, MyUsbDevice1);
            string report;
            if (bResult)
            {
                report = string.Format("Set EndReadoutParameter: {0}{1}{2}{3}\n", ChainEnable[0], ChainEnable[1], ChainEnable[2], ChainEnable[3]);
                txtReport.AppendText(report);
            }
            else
            {
                ShowUsbError("EndReadoutParameter");
            }
            #endregion
            #region SelectExternalRAZ
            bResult = SelectRazChannel(1);
            if (!bResult)
            {
                return;
            }
            bResult = SetExternalRazDelay("200");
            if (!bResult)
            {
                return;
            }
            bResult = SetExternalRazTime(cbxExternalRazTimeNewDif.SelectedIndex);
            if(!bResult)
            {
                return;
            }
            #endregion
            for (int i = 0; i < 4; i++)
            {
                if(ChainEnable[i] == 0)
                {
                    continue;
                }
                for(int j = 3; j >= 0; j--)
                {
                    #region DAC0~2
                    bResult = SetDac0Vth(tbxVth0Asic[i, j].Text, MicrorocAsicChain[i], j);
                    if (!bResult)
                    {
                        return;
                    }
                    bResult = SetDac1Vth(tbxVth1Asic[i, j].Text, MicrorocAsicChain[i], j);
                    if (!bResult)
                    {
                        return;
                    }
                    bResult = SetDac2Vth(tbxVth2Asic[i, j].Text, MicrorocAsicChain[i], j);
                    if (!bResult)
                    {
                        return;
                    }
                    #endregion
                    bResult = ConfigurationParameterLoad(MicrorocAsicChain[j]);
                    if (!bResult)
                    {
                        return;
                    }
                }
            }
            bResult = SetExternalRazDelay("200");
            if(!bResult)
            {
                return;
            }
            bResult = SetExternalRazTime(cbxExternalRazTimeNewDif.SelectedIndex);
            if(!bResult)
            {
                return;
            }
            tbxStartAcquisitionTimeNewDif.Text = "1500";
            bResult = PowerPulsingPinDisable();
            if (!bResult)
            {
                return;
            }
            else
            {
                rdbPowerPulsingDisableNewDif.IsChecked = true;
                rdbPowerPulsingEnableNewDif.IsChecked = false;
            }
            bResult = MicrorocAsic.DaqModeSelect(0, MyUsbDevice1);
            if(bResult)
            {
                txtReport.AppendText("Select slave DAQ\n");
                tbxAcquisitionHoldTimeNewDif.IsEnabled = true;
                btnNewDifAcquisitionStartNewDif.IsEnabled = true;
            }
            else
            {
                ShowUsbError("Select DAQ mode");
                rdbSlaveDaqNewDif.IsChecked = false;
            }
        }

        private async void btnNewDifAcquisitionStartNewDif_Click(object sender, RoutedEventArgs e)
        {
            
            bool bResult;
            if(!StateIndicator.SlowAcqStart)
            {
                if (!CheckFileSaved())
                {
                    return;
                }
                #region Set StartAcquisitionTime
                bResult = SetStartAcquisitionTime(tbxStartAcquisitionTimeNewDif.Text);
                if(!bResult)
                {
                    return;
                }
                #endregion
                #region EndHoldTime
                bResult = SetEndHoldTime(tbxAcquisitionHoldTimeNewDif.Text);
                if(!bResult)
                {
                    return;
                }
                #endregion
                #region Acquisition Data Number
                if (CheckStringLegal.CheckIntegerLegal(tbxAcquisitionDataNumberNewDif.Text))
                {
                    StateIndicator.SlowDataRatePackageNumber = int.Parse(tbxAcquisitionDataNumberNewDif.Text);
                }
                else
                {
                    MessageBox.Show("Data Number Illegal. Set to dafault 5120", "IllegalInput", MessageBoxButton.OK, MessageBoxImage.Error);
                    tbxAcquisitionDataNumberNewDif.Text = "5120";
                    StateIndicator.SlowDataRatePackageNumber = int.Parse(tbxAcquisitionDataNumberNewDif.Text);
                }
                string report = string.Format("Set Start Acquisition Time{0}\n", tbxAcquisitionDataNumberNewDif.Text);
                txtReport.AppendText(report);
                #endregion
                #region Reset
                bResult = ClearUsbFifo();
                if(!bResult)
                {
                    return;
                }
                bResult = ResetMicrorocTimeStamp();
                if(!bResult)
                {
                    return;
                }
                bResult = ResetMicrorocAcquisition();
                if(!bResult)
                {
                    return;
                }
                #endregion
                int Start = cbxEnableChain1.SelectedIndex * 1 + cbxEnableChain2.SelectedIndex * 2 + cbxEnableChain3.SelectedIndex * 4 + cbxEnableChain4.SelectedIndex * 8;
                bResult = MicrorocAsic.MicrorocAcquisitionStart(Start, MyUsbDevice1);
                if(bResult)
                {
                    StateIndicator.SlowAcqStart = true;
                    btnNewDifAcquisitionStartNewDif.Background = Brushes.Red;
                    btnNewDifAcquisitionStartNewDif.Content = "Slow ACQ Stop";
                    await Task.Run(() => GetSlowDataRateResultCallBack(MyUsbDevice1));
                    bResult = MicrorocAsic.MicrorocAcquisitionStop(MyUsbDevice1);
                    if (bResult)
                    {
                        StateIndicator.FileSaved = false;
                        btnNewDifAcquisitionStartNewDif.Background = Brushes.Green;
                        btnNewDifAcquisitionStartNewDif.Content = "Slow ACQ Start";
                        StateIndicator.SlowAcqStart = false;
                    }
                    else
                    {
                        ShowUsbError("Stop Acquisition");
                    }
                }
                else
                {
                    ShowUsbError("Start Acquisition");
                }
            }
            else
            {
                bResult = MicrorocAsic.MicrorocAcquisitionStop(MyUsbDevice1);
                if (bResult)
                {
                    StateIndicator.SlowAcqStart = false;
                }
                else
                {
                    ShowUsbError("Stop Acquisition");
                }
            }
        }

        private bool SetStartAcquisitionTime(string StartAcquisitionTime)
        {
            bool IllegalInput;
            bool bResult = MicrorocAsic.MicrorocStartAcquisitionTimeSet(StartAcquisitionTime, MyUsbDevice1, out IllegalInput);
            if(IllegalInput)
            {
                ShowIllegalInput("Start Acquisition Time should be 0-1638400");
                return false;
            }
            if(bResult)
            {
                string report = string.Format("Set Start Acquisition Time: {0}\n", StartAcquisitionTime);
                txtReport.AppendText(report);
                return true;
            }
            else
            {
                ShowUsbError("Set Start Acquisition Time");
                return false;
            }
        }
        private bool SetEndHoldTime(string EndHoldTime)
        {
            bool IllegalInput;
            bool bResult = MicrorocAsic.EndHoldTimeSet(EndHoldTime, MyUsbDevice1, out IllegalInput);
            if(IllegalInput)
            {
                ShowIllegalInput("EndHoldTime should be 0-1638400");
                return false;
            }
            if(bResult)
            {
                string report = string.Format("Set EndHoldTime: {0}ns\n", EndHoldTime);
                txtReport.AppendText(report);
                return true;
            }
            else
            {
                ShowUsbError("Set EndHoldTime");
                return false;
            }
        }

        private bool ClearUsbFifo()
        {
            bool bResult = MicrorocAsic.ResetDataFifo(MyUsbDevice1);
            if(bResult)
            {
                txtReport.AppendText("Clear USB data FIFO\n");
                return true;
            }
            else
            {
                ShowUsbError("Clear USB FIFO");
                return false;
            }
        }
        private bool ResetMicrorocTimeStamp()
        {
            if(MicrorocAsic.ResetTimeStamp(MyUsbDevice1))
            {
                txtReport.AppendText("Reset Microroc time stamp\n");
                return true;
            }
            else
            {
                ShowUsbError("Reset Microroc time stamp");
                return false;
            }
        }
        private bool ResetMicrorocAcquisition()
        {
            if (MicrorocAsic.ResetMicrorocAcquisition(MyUsbDevice1))
            {
                txtReport.AppendText("Microroc Reset\n");
                return true;
            }
            else
            {
                ShowUsbError("Microroc Reset");
                return false;
            }
        }

        private void btnSetHoldNewDif_Click(object sender, RoutedEventArgs e)
        {
            #region Select hold
            bool bResult = SelectTrigger(cbxHoldSelectNewDif.SelectedIndex);
            if(!bResult)
            {
                return;
            }
            #endregion
            #region Hold Delay
            bResult = SetHoldDelay(tbcHoldDelayNewDif.Text);
            if(!bResult)
            {
                return;
            }
            #endregion
            #region HoldTime
            bResult = SetHoldTime(tbcHoldTimeNewDif.Text);
            if(!bResult)
            {
                return;
            }
            #endregion
            #region Hold Enable
            if(cbxHoldEnableNewDif.SelectedIndex == 1)
            {
                HoldEnable();
            }
            else
            {
                HoldDisable();
            }
            #endregion
            btnStartAdcNewDif.IsEnabled = true;
        }

        private bool SelectTrigger(int Trigger)
        {
            int TriggerValue;
            switch(Trigger)
            {
                case 0: TriggerValue = 0;break;
                case 1: TriggerValue = 1;break;
                case 2: TriggerValue = 2;break;
                case 3: TriggerValue = 8;break;
                default: TriggerValue = 0;break;
            }
            bool bResult = MicrorocAsic.TriggerCoincidenceSet(TriggerValue, MyUsbDevice1);
            if(bResult)
            {
                txtReport.AppendText("Trigger select successfully\n");
                return true;
            }
            else
            {
                ShowUsbError("Select trigger");
                return false;
            }
        }
        private bool HoldEnable()
        {
            bool bResult = MicrorocAsic.HoldEnable(MyUsbDevice1);
            if(bResult)
            {
                txtReport.AppendText("Hold Enable\n");
                return true;
            }
            else
            {
                ShowUsbError("Hold enable");
                return false;
            }
        }
        private bool HoldDisable()
        {
            bool bResult = MicrorocAsic.HoldDisable(MyUsbDevice1);
            if(bResult)
            {
                txtReport.AppendText("Hold disable\n");
                return true;
            }
            else
            {
                ShowUsbError("Hold disable");
                return false;
            }
        }
        private bool SetHoldDelay(string HoldDelay)
        {
            bool IllegalInput;
            bool bResult = MicrorocAsic.HoldDelaySet(HoldDelay, MyUsbDevice1, out IllegalInput);
            if(IllegalInput)
            {
                ShowIllegalInput("Hold delay should be 2550");
                return false;
            }
            if(bResult)
            {
                string report = string.Format("Set hold delay {0}ns\n", HoldDelay);
                txtReport.AppendText(report);
                return true;
            }
            else
            {
                ShowUsbError("Set Hold Delay");
                return false;
            }
        }
        private bool SetHoldTime(string HoldTime)
        {
            bool IllegalInput;
            bool bResult = MicrorocAsic.HoldTimeSet(HoldTime, MyUsbDevice1, out IllegalInput);
            if(IllegalInput)
            {
                ShowIllegalInput("Hold Time should be 0-1638400");
                return false;
            }
            if(bResult)
            {
                string report = string.Format("Set hold time: {0}\n", HoldTime);
                txtReport.AppendText(report);
                return true;
            }
            else
            {
                ShowUsbError("Set HoldTime");
                return false;
            }
        }

        private async void btnStartAdcNewDif_Click(object sender, RoutedEventArgs e)
        {
            if (!CheckFileSaved())
            {
                return;
            }
            bool bResult;
            if(!StateIndicator.SlowAcqStart)
            {
                bResult = SetAdcStartDelay(tbcStartDelayNewDif.Text);
                if(!bResult)
                {
                    return;
                }
                bResult = SetAdcSamplingTimes(txtAdcAcqTimes.Text);
                if(!bResult)
                {
                    return;
                }
                bResult = SelectTestAsic(cbxAdcTestAsicNewDif.SelectedIndex);
                if(!bResult)
                {
                    return;
                }
                StateIndicator.SlowDataRatePackageNumber = 0;
                bResult = MicrorocAsic.ExternalAdcStart(MyUsbDevice1);
                if(bResult)
                {
                    btnStartAdcNewDif.Content = "ADC Stop";
                    btnStartAdcNewDif.Background = Brushes.Red;
                    StateIndicator.SlowAcqStart = true;
                    txtReport.AppendText("ADC Start\n");
                    await Task.Run(() => GetSlowDataRateResultCallBack(MyUsbDevice1));
                }
                else
                {
                    MessageBox.Show("Start ADC failure. Please Check USB", "USB ERROR", MessageBoxButton.OK, MessageBoxImage.Error);
                }
            }
            else
            {
                bResult = MicrorocAsic.ExternalAdcStop(MyUsbDevice1);
                if(bResult)
                {
                    StateIndicator.SlowAcqStart = false;
                    btnStartAdcNewDif.Content = "ADC Start";
                    btnStartAdcNewDif.Background = Brushes.Green;
                    txtReport.AppendText("ADC Stop\n");
                }
                else
                {
                    MessageBox.Show("Stop ADC failure. Please Check USB", "USB ERROR", MessageBoxButton.OK, MessageBoxImage.Error);
                }
            }
        }

        private bool SetAdcStartDelay(string AdcStartDelay)
        {
            bool IllegalInput;
            bool bResult = MicrorocAsic.AdcStartDelayTimeSet(AdcStartDelay, MyUsbDevice1, out IllegalInput);
            if(IllegalInput)
            {
                ShowIllegalInput("Adc Start Delay Time should be 0-400");
                return false;
            }
            if (bResult)
            {
                string report = string.Format("Set ADC start delay time: {0}", AdcStartDelay);
                txtReport.AppendText(report);
                return true;
            }
            else
            {
                ShowUsbError("Set ADC Start DelayTime");
                return false;
            }
        }
        private bool SetAdcSamplingTimes(string AdcSamplingTimes)
        {
            bool IllegalInput;
            bool bResult = MicrorocAsic.AdcDataNumberSet(AdcSamplingTimes, MyUsbDevice1, out IllegalInput);
            if(IllegalInput)
            {
                ShowIllegalInput("ADC sampling times should be 0-255");
                return false;
            }
            if (bResult)
            {
                string report = string.Format("Set ADC sampling {0} times\n", AdcSamplingTimes);
                txtReport.AppendText(report);
                return true;
            }
            else
            {
                ShowUsbError("Set ADC sampling times");
                return false;
            }
        }

        private bool SelectTestAsic(int AsicIndex)
        {
            int Row, Column;
            Row = AsicIndex / 4;
            Column = AsicIndex % 4;
            bool bResult = MicrorocAsic.TestSignalRowSelect(Row, MyUsbDevice1);
            if(!bResult)
            {
                ShowUsbError("Set Row");
                return false;
            }
            bResult = MicrorocAsic.TestSignalColumnSelect(Column, MyUsbDevice1);
            if(bResult)
            {
                string report = string.Format("Select ASIC{0}{1}\n", Row + 1, Column + 1);
                txtReport.AppendText(report);
                return true;
            }
            else
            {
                ShowUsbError("Set Column");
                return false;
            }
        }


        private bool SetSCurveTestCommomParameter()
        {
            bool bResult;
            #region Select Single or Auto
            bResult = SelectSCurveTestSingleChannelOrAuto(cbxSingleOrAutoNewDif.SelectedIndex);
            if (!bResult)
            {
                return false;
            }
            #endregion
            #region CTest Or Input
            bResult = SelectSCurveSignalCTestOrInput(cbxCTestOrInputNewDif.SelectedIndex);
            if (!bResult)
            {
                return false;
            }
            #endregion
            #region Max Trigger Count
            bResult = SetMaxTriggerCount(cbxCPT_MAX_NewDif.Text);
            if (!bResult)
            {
                return false;
            }
            #endregion
            #region Count Time
            bResult = SetCountTime(tbcCountTimeNewDif.Text);
            if (!bResult)
            {
                return false;
            }
            #endregion
            #region Single Channel
            bResult = SetSingleTestChannel(tbcSingleTestChannelNewDif.Text);
            if (!bResult)
            {
                return false;
            }
            #endregion
            #region Set mask choise
            if (!SetMaskChoise(cbxUnmaskAllChannelNewDif.SelectedIndex))
            {
                return false;
            }
            #endregion
            #region Set Trigger Delay
            if (!SetTriggerDelay(tbcTriggerDelayNewDif.Text))
            {
                return false;
            }
            #endregion
            #region RAZ 
            #region Select External RAZ
            bResult = SelectRazChannel(1);
            if (!bResult)
            {
                return false;
            }
            #endregion
            #region RAZ delay and time
            if (!SetExternalRazDelay(tbcExternalRazDelayNewDif.Text))
            {
                return false;
            }
            if (!SetExternalRazTime(cbxExternalRazModeNewDifSCurve.SelectedIndex))
            {
                return false;
            }
            #endregion
            #endregion
            
            return true;
        }

        private async void btnSCurveTestStartNewDif_Click(object sender, RoutedEventArgs e)
        {
            
            bool bResult;
            if (!StateIndicator.SlowAcqStart)
            {
                if (!CheckFileSaved())
                {
                    return;
                }

                #region DAC
                bResult = SetStartDac(tbcStartDacNewDif.Text);
                if(!bResult)
                {
                    return;
                }
                int StartDac = int.Parse(tbcStartDacNewDif.Text);
                bResult = SetEndDac(tbcEndDacNewDif.Text);
                if(!bResult)
                {
                    return;
                }
                int EndDac = int.Parse(tbcEndDacNewDif.Text);
                bResult = SetDacStep(tbcDacStepNewDif.Text);
                if(!bResult)
                {
                    return;
                }
                int AdcInterval = int.Parse(tbcDacStepNewDif.Text);
                #endregion
                #region Data number
                if (cbxSingleOrAutoNewDif.SelectedIndex == 1)
                {
                    //*** Set Package Number
                    StateIndicator.SlowDataRatePackageNumber = HeaderLength + ChannelLength + ((EndDac - StartDac) / AdcInterval + 1) * OneDacDataLength + TailLength;
                }
                //--- 64 Channel Test ---//
                else
                {
                    //*** Set Package Number
                    StateIndicator.SlowDataRatePackageNumber = HeaderLength + (ChannelLength + ((EndDac - StartDac) / AdcInterval + 1) * OneDacDataLength) * 64 + TailLength;
                }
                #endregion
                if (!SetSCurveTestCommomParameter())
                {
                    return;
                }
                #region Set test row and column
                if (!SetSCurveTestAsic(cbxSCurveTestAsicNewDif.SelectedIndex))
                {
                    return;
                }
                #endregion
                if (!ResetSCurveTest())
                {
                    return;
                }
                
                #region Clear USB FIFO
                if (!ClearUsbFifo())
                {
                    return;
                }
                #endregion
                bResult = SCurveTestStart();
                if (bResult)
                {
                    StateIndicator.FileSaved = false;
                    StateIndicator.SlowAcqStart = true;
                    btnSCurveTestStartNewDif.Content = "SCurve Test Stop";
                    btnSCurveTestStartNewDif.Background = Brushes.Red;
                    await Task.Run(() => GetSlowDataRateResultCallBack(MyUsbDevice1));
                    SCurveTestStop();
                    ResetSCurveTest();
                    StateIndicator.SlowAcqStart = false;
                    btnSCurveTestStartNewDif.Content = "SCurve Test Start";
                    btnSCurveTestStartNewDif.Background = Brushes.Green;
                }
                else
                {
                    return;
                }
            }
            else
            {
                bResult = SCurveTestStop();
                if(bResult)
                {
                    StateIndicator.SlowAcqStart = false;
                    btnSCurveTestStartNewDif.Content = "SCurve Test Start";
                    btnSCurveTestStartNewDif.Background = Brushes.Green;
                    ResetSCurveTest();
                }
                else
                {
                    return;
                }
            }
        }

        private bool SelectSCurveTestSingleChannelOrAuto(int SingleChannelOrAuto)
        {
            bool bResult = MicrorocAsic.SCurveTestSingleOr64ChannelSelect(SingleChannelOrAuto, MyUsbDevice1);
            if(bResult)
            {
                string report = string.Format("Select {0} Test\n", (SingleChannelOrAuto == 1 ? "Single Channel" : "64 Channel"));
                txtReport.AppendText(report);
                return true;
            }
            else
            {
                ShowUsbError("Select test channel mode");
                return false;
            }
        }
        private bool SelectSCurveSignalCTestOrInput(int CTestOrInput)
        {
            bool bResult = MicrorocAsic.SCurveTestCTestOrInputSelect(CTestOrInput, MyUsbDevice1);
            if(bResult)
            {
                string report = string.Format("Select {0}\n", (CTestOrInput == 1 ? "CTest" : "Input"));
                txtReport.AppendText(report);
                return true;
            }
            else
            {
                ShowUsbError("Select CTest Or Input");
                return false;
            }
        }
        private bool SetMaxTriggerCount(string TriggerCount)
        {
            bool IllegalInput;
            bool bResult = MicrorocAsic.SCurveTestTriggerCountMaxSet(TriggerCount, MyUsbDevice1, out IllegalInput);
            if(IllegalInput)
            {
                ShowIllegalInput("Max count should be 0-65536");
                return false;
            }
            if(bResult)
            {
                string report = string.Format("Set Max count {0}\n", TriggerCount);
                txtReport.AppendText(report);
                return true;
            }
            else
            {
                ShowUsbError("Set Max count");
                return false;
            }
        }
        private bool SetCountTime(string CountTime)
        {
            bool IllegalInput;
            bool bResult = MicrorocAsic.CounterModeMaxValueSet(CountTime, MyUsbDevice1, out IllegalInput);
            if(IllegalInput)
            {
                ShowIllegalInput("Count Time should be 0-65.355");
                return false;
            }
            if(bResult)
            {
                string report = string.Format("Set Count Time {0}s\n", CountTime);
                txtReport.AppendText(report);
                return true;
            }
            else
            {
                ShowUsbError("Set Count Time");
                return false;
            }
        }
        private bool SetSingleTestChannel(string SingleTestChannel)
        {
            bool IllegalInput;
            bool bResult = MicrorocAsic.SingleTestChannelSet(SingleTestChannel, MyUsbDevice1, out IllegalInput);
            if(IllegalInput)
            {
                ShowIllegalInput("Single Test Channel should be 0-63");
                return false;
            }
            if(bResult)
            {
                string report = string.Format("Set Single Test Channel {0}\n", SingleTestChannel);
                txtReport.AppendText(report);
                return true;
            }
            else
            {
                ShowUsbError("Set Single Channel");
                return false;
            }
        }
        private bool SetStartDac(string StartDac)
        {
            bool IllegalInput;
            bool bResult = MicrorocAsic.SCurveTestStartDacSet(StartDac, MyUsbDevice1, out IllegalInput);
            if(IllegalInput)
            {
                ShowIllegalInput("Start DAC Value should be 0-1203");
                return false;
            }
            if (bResult)
            {
                string report = string.Format("Set Start DAC {0}\n", StartDac);
                txtReport.AppendText(report);
                return true;
            }
            else
            {
                ShowUsbError("Set Start DAC");
                return false;
            }
        }
        private bool SetEndDac(string EndDac)
        {
            bool IllegalInput;
            bool bResult = MicrorocAsic.SCurveTestEndDacSet(EndDac, MyUsbDevice1, out IllegalInput);
            if(IllegalInput)
            {
                ShowIllegalInput("End DAC should be 0-1023");
                return false;
            }
            if(bResult)
            {
                string report = string.Format("Set End DAC {0}\n", EndDac);
                txtReport.AppendText(report);
                return true;
            }
            else
            {
                ShowUsbError("Set End DAC");
                return false;
            }
        }
        private bool SetDacStep(string DacStep)
        {
            bool IllegalInput;
            bool bResult = MicrorocAsic.SCurveTestDacStepSet(DacStep, MyUsbDevice1, out IllegalInput);
            if (IllegalInput)
            {
                ShowIllegalInput("DAC Step should be 1-1022");
                return false;
            }
            if (bResult)
            {
                string report = string.Format("Set DAC step {0}\n", DacStep);
                txtReport.AppendText(report);
                return true;
            }
            else
            {
                ShowUsbError("Set DAC Step");
                return false;
            }
        }
        private bool SetMaskChoise(int MaskChoise)
        {
            bool bResult = MicrorocAsic.SCurveTestUnmaskAllChannel(MaskChoise, MyUsbDevice1);
            if(bResult)
            {
                string report = string.Format("Set {0}\n", (MaskChoise == 1 ? "Mask" : "Unmask"));
                txtReport.AppendText(report);
                return true;
            }
            else
            {
                ShowUsbError("Set MaskChoise");
                return false;
            }
        }
        private bool SetTriggerDelay(string TriggerDelay)
        {
            bool IllegalInput;
            bool bResult = MicrorocAsic.SCurveTestTriggerDelaySet(TriggerDelay, MyUsbDevice1, out IllegalInput);
            if(IllegalInput)
            {
                ShowIllegalInput("Trigger Delay should be 0-400");
                return false;
            }
            if (bResult)
            {
                string report = string.Format("Set Trigger Delay {0}\n", TriggerDelay);
                txtReport.AppendText(report);
                return true;
            }
            else
            {
                ShowUsbError("Set Trigger Delay");
                return false;
            }
        }
        private bool SetTotalAsicNumber(int AsicNumber, MicrorocAsic MyMicroroc)
        {
            if (MyMicroroc.AsicNumberSet(AsicNumber, MyUsbDevice1)) 
            {
                string report = string.Format("Set Chain{0} ASIC number {1}\n", MyMicroroc.ChainID + 1, AsicNumber + 1);
                txtReport.AppendText(report);
                return true;
            }
            else
            {
                ShowUsbError("Set ASIC number");
                return false;
            }
        }
        private bool SetSCurveTestAsic(int AsicIndex)
        {
            int TestAsic = AsicIndex % 4;
            int TestRow = AsicIndex / 4;
            #region Select Row
            // There is an error in the PCB design that the row and column is swithced. The column does not connect as 1, 2, 3
            int ColumnSetValue;
            switch(TestRow)
            {
                case 0: ColumnSetValue = 0;break;
                case 1: ColumnSetValue = 4;break;
                case 2: ColumnSetValue = 2;break;
                case 3: ColumnSetValue = 6;break;
                default: ColumnSetValue = 0;break;
            }
            bool bResult = MicrorocAsic.TestSignalColumnSelect(ColumnSetValue, MyUsbDevice1);
            if(bResult)
            {
                string report = string.Format("Set Test ASIC chain{0}\n", TestRow + 1);
                txtReport.AppendText(report);
            }
            else
            {
                ShowUsbError("Set Test Column");
                return false;
            }
            #endregion
            bResult = SetTotalAsicNumber(4, MicrorocAsicChain[TestRow]);
            if(!bResult)
            {
                return false;
            }
            bResult = MicrorocAsic.SCurveTestAsicSelect(TestAsic, MyUsbDevice1);
            if(bResult)
            {
                string report = string.Format("Select ASIC{0}{1}\n", TestRow + 1, TestAsic + 1);
                txtReport.AppendText(report);
                return MicrorocAsicChain[TestRow].SelectAsicChain(MyUsbDevice1);
            }
            else
            {
                ShowUsbError("Set Test ASIC");
                return false;
            }
        }
        private bool SCurveTestStart()
        {
            bool bResult = MicrorocAsic.SweepTestStart(MyUsbDevice1);
            if(bResult)
            {
                txtReport.AppendText("SCurve Test Start\n");
                return true;
            }
            else
            {
                ShowUsbError("Start SCurve Test");
                return false;
            }
        }
        private bool SCurveTestStop()
        {
            bool bResult = MicrorocAsic.SweepTestStop(MyUsbDevice1);
            if (bResult)
            {
                txtReport.AppendText("SCurve Test Stop\n");
                return true;
            }
            else
            {
                ShowUsbError("Stop SCurve Test");
                return false;
            }
        }
        private bool ResetSCurveTest()
        {
            bool bResult = MicrorocAsic.SCurveTestReset(MyUsbDevice1);
            if(bResult)
            {
                txtReport.AppendText("SCurve Test reset\n");
                return true;
            }
            else
            {
                ShowUsbError("Reset SCurve");
                return false;
            }
        }

        private void btnSetExternalRazParameterSlowControl_Click(object sender, RoutedEventArgs e)
        {
            bool bResult = SetExternalRazDelay(tbcExternalRazDelaySlowControl.Text);
            if(!bResult)
            {
                return;
            }
            bResult = SetExternalRazTime(cbxExternalRazTimeNewDif.SelectedIndex);
            if (!bResult)
            {
                return;
            }
        }

        private async void btnSCurveTestPedestal_Click(object sender, RoutedEventArgs e)
        {
            bool bResult;
            if (!StateIndicator.PedestalTestStart)
            {
                #region Create Folder
                bResult = CreatePedestalTestFolder();
                if (!bResult)
                {
                    return;
                }
                #endregion
                for (int i = 0; i < 4; i++)
                {
                    for (int j = 0; j < 4; j++)
                    {
                        #region SaveFile
                        bResult = SavePedestalTestFile(i, j);
                        if (!bResult)
                        {
                            return;
                        }
                        #endregion
                        #region DAC
                        bResult = SetStartDac(tbcStartDacNewDif.Text);
                        if (!bResult)
                        {
                            return;
                        }
                        int StartDac = int.Parse(tbcStartDacNewDif.Text);
                        bResult = SetEndDac(tbcEndDacNewDif.Text);
                        if (!bResult)
                        {
                            return;
                        }
                        int EndDac = int.Parse(tbcEndDacNewDif.Text);
                        bResult = SetDacStep(tbcDacStepNewDif.Text);
                        if (!bResult)
                        {
                            return;
                        }
                        int AdcInterval = int.Parse(tbcDacStepNewDif.Text);
                        #endregion
                        #region Data number
                        if (cbxSingleOrAutoNewDif.SelectedIndex == 1)
                        {
                            //*** Set Package Number
                            StateIndicator.SlowDataRatePackageNumber = HeaderLength + ChannelLength + ((EndDac - StartDac) / AdcInterval + 1) * OneDacDataLength + TailLength;
                        }
                        //--- 64 Channel Test ---//
                        else
                        {
                            //*** Set Package Number
                            StateIndicator.SlowDataRatePackageNumber = HeaderLength + (ChannelLength + ((EndDac - StartDac) / AdcInterval + 1) * OneDacDataLength) * 64 + TailLength;
                        }
                        #endregion
                        #region Set Common Parameter
                        if (!SetSCurveTestCommomParameter())
                        {
                            return;
                        }
                        #endregion
                        #region Set test row and column
                        int TestAsicIndex = i * 4 + j;
                        if (!SetSCurveTestAsic(TestAsicIndex))
                        {
                            return;
                        }
                        #endregion
                        #region Reset SCurve Test
                        if (!ResetSCurveTest())
                        {
                            return;
                        }
                        #endregion
                        #region Clear USB FIFO
                        if (!ClearUsbFifo())
                        {
                            return;
                        }
                        #endregion
                        tbxPedestalAsic.Text = string.Format("ASIC{0}{1}", i, j);
                        bResult = SCurveTestStart();
                        if (bResult)
                        {
                            StateIndicator.FileSaved = false;
                            StateIndicator.SlowAcqStart = true;
                            StateIndicator.PedestalTestStart = true;
                            btnSCurveTestStartNewDif.Content = "SCurve Test Stop";
                            btnSCurveTestStartNewDif.Background = Brushes.Red;
                            btnSCurveTestPedestal.Content = "PedestalTestStop";
                            btnSCurveTestPedestal.Background = Brushes.Red;
                            await Task.Run(() => GetSlowDataRateResultCallBack(MyUsbDevice1));
                            SCurveTestStop();
                            ResetSCurveTest();
                            StateIndicator.SlowAcqStart = false;
                            btnSCurveTestStartNewDif.Content = "SCurve Test Start";
                            btnSCurveTestStartNewDif.Background = Brushes.Green;
                        }// if
                        else
                        {
                            return;
                        }// else
                        if(!StateIndicator.PedestalTestStart)
                        {
                            break;
                        }
                    }// for j
                    if (!StateIndicator.PedestalTestStart)
                    {
                        break;
                    }
                }// for i
                StateIndicator.PedestalTestStart = false;
                btnSCurveTestPedestal.Content = "Pedestal Test Start";
                btnSCurveTestPedestal.Background = Brushes.Green;
            }//if
            else
            {
                bResult = SCurveTestStop();
                if (!bResult)
                {
                    return;
                }
                bResult = ResetSCurveTest();
                if (!bResult)
                {
                    return;
                }
                StateIndicator.SlowAcqStart = false;
                btnSCurveTestStartNewDif.Content = "SCurve Test Start";
                btnSCurveTestStartNewDif.Background = Brushes.Green;
                StateIndicator.PedestalTestStart = false;
                btnSCurveTestPedestal.Content = "Pedestal Test Start";
                btnSCurveTestPedestal.Background = Brushes.Green;
            }// else
            MediaPlayer TestDonePlayer = new MediaPlayer();
            TestDonePlayer.Open(new Uri("TestDone.wav", UriKind.Relative));
            TestDonePlayer.Play();
        }

        private bool CreatePedestalTestFolder()
        {
            string DefaultPath = @"D:\ExperimentsData\test";
            string DefaultSubPath = DateTime.Now.ToString();
            DefaultSubPath = DefaultSubPath.Replace("/", "_");
            DefaultSubPath = DefaultSubPath.Replace(":", "_");
            DefaultSubPath = DefaultSubPath.Replace(" ", "_");
            string TestFolder = Path.Combine(DefaultPath, "Pedestal", DefaultSubPath);
            if (!Directory.Exists(TestFolder))//路径不存在
            {
                string path = String.Format("File Directory {0} Created\n", TestFolder);
                Directory.CreateDirectory(TestFolder);
                txtReport.AppendText(path);
                txtFileDir.Text = TestFolder;
                return true;
            }
            else
            {
                MessageBox.Show("The File Directory already exits", //text
                                "Created failure",   //caption
                                MessageBoxButton.OK,//button
                                MessageBoxImage.Warning);//icon
                return false;
            }
        }
        private bool SavePedestalTestFile(int i, int j)
        {
            string TestFileName = string.Format("ASIC{0}{1}.dat", i, j);
            filepath = Path.Combine(txtFileDir.Text, TestFileName);
            FileStream fs = null;
            if (!File.Exists(filepath))
            {
                fs = File.Create(filepath);
                string report = String.Format("File:{0} Created\n", filepath);
                txtReport.AppendText(report.ToString());
                StateIndicator.FileSaved = true;
                fs.Close();
                txtFileName.Text = TestFileName;
                return true;
            }
            else
            {
                MessageBox.Show("Save file failure. Please save the file manual", "File Save Error", MessageBoxButton.OK, MessageBoxImage.Error);
                return false;
            }
        }
    }
    
}
