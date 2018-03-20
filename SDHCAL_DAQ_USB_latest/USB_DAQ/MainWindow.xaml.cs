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
        //SC Parameter


        public MainWindow()
        {
            InitializeComponent();
            //Adding event handles for device attachment and device removal
            MyUsbDevice1.usbDevices.DeviceAttached += new EventHandler(usbDevices_DeviceAttached);
            MyUsbDevice1.usbDevices.DeviceRemoved += new EventHandler(usbDevices_DeviceRemoved);
            RefreshDevice();
            Afg3252Refresh();
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
            bResult = MicrorocChain1.SetAsicNumber(AsicNumber, MyUsbDevice1);
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
                    DCCaliFileName = string.Format("D:\\ExperimentsData\\test\\DCCali{0}.txt", i);
                    SCTCaliFileName = string.Format("D:\\ExperimentsData\\test\\SCTCali{0}.txt", i);
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
                        MaskFileName = string.Format("D:\\ExperimentsData\\test\\{0}", FileName);
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
            bResult = MicrorocChain1.SetEndHoldTime(txtHoldTime.Text, MyUsbDevice1, out IllegalInput);
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
            bResult = MicrorocChain1.EnableHold(true, MyUsbDevice1);
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
            if (filepath == null || string.IsNullOrEmpty(filepath.Trim()))
            {
                MessageBox.Show("You should save the file first before Scurve start", //text
                                        "imformation", //caption
                                   MessageBoxButton.OK, //button
                                    MessageBoxImage.Error);//icon     
            }
            else //file is exsits
            {
                bool bResult;
                bool IllegalInput;
                #region Start Slow Acq
                if (!StateIndicator.SlowAcqStart)
                {
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
                    bResult = MicrorocChain1.StartAcquisition(MyUsbDevice1);
                    if (bResult)
                    {
                        StateIndicator.SlowAcqStart = true;
                        txtReport.AppendText("Slow data rate ACQ Start\n");
                        txtReport.AppendText("Slow data rate Acq Contunue\n");
                        btnSlowACQ.Content = "Stop";
                        await Task.Run(() => GetSlowDataRateResultCallBack(MyUsbDevice1));               
                        bResult = MicrorocChain1.StopAcquisition(MyUsbDevice1);
                        if(bResult)
                        {
                            btnSlowACQ.Content = "Slow ACQ";
                            StateIndicator.SlowAcqStart = false;
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
                bool bResult;
                bool IllegalInput;
                string report;
                #region Start and End DAC
                bResult = MicrorocChain1.SetSCTestStartAndStopDacCode(txtStartDac.Text, txtEndDac.Text, MyUsbDevice1, out IllegalInput);
                if (bResult)
                {
                    report = string.Format("Set StartDAC:{0}\n", txtStartDac.Text);
                    txtReport.AppendText(report);
                    report = string.Format("Set EndDAC:{0}\n", txtEndDac.Text);
                    txtReport.AppendText(report);
                }
                else if(IllegalInput)
                {
                    MessageBox.Show("Ilegal input the StartDAC and EndDAC. The StartDAC should less than EndDAC\n", "Ilegal Input", MessageBoxButton.OK, MessageBoxImage.Error);
                    return;
                }
                else
                {
                    MessageBox.Show("Set StartDAC failure. Please check the USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
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
                    else if(IllegalInput)
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
                    }
                    #endregion
                    #region Set Trigger Delay
                    bResult = MicrorocChain1.SetTriggerDelayTime(txtTriggerDelay.Text, MyUsbDevice1, out IllegalInput);
                    if(bResult)
                    {
                        report = string.Format("Set Trigger Delay {0}\n", txtTriggerDelay.Text);
                        txtReport.AppendText(report);
                    }
                    else if(IllegalInput)
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
                    if(bResult)
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
                        }
                        #endregion
                        #region Single Channel Mode
                        //--- Single Channel Test ---///
                        if (cbxSingleOrAuto.SelectedIndex == SingleChannel)
                        {
                            if (!StateIndicator.SlowAcqStart)
                            {
                                //*** Set Package Number
                                StateIndicator.SlowDataRatePackageNumber = HeaderLength + ChannelLength + ((EndDac - StartDac) / AdcInterval + 1) * OneDacDataLength + TailLength;
                                #region Clear USB FIFO
                                bResult = MicrorocChain1.ClearUsbFifo(MyUsbDevice1);
                                if (bResult)
                                    txtReport.AppendText("USB fifo cleared");
                                else
                                {
                                    txtReport.AppendText("fail to clear USB fifo");
                                    return;
                                }
                                #endregion
                                #region Data ACQ
                                bResult = MicrorocChain1.StartSCTest(MyUsbDevice1);
                                if (bResult)
                                {
                                    StateIndicator.SlowAcqStart = true;
                                    txtReport.AppendText("SCurve Test Start\n");
                                    txtReport.AppendText("SCurve Test Continue\n");
                                    btnSweepTestStart.Content = "SCurve Test Stop";
                                    await Task.Run(() => GetSlowDataRateResultCallBack(MyUsbDevice1));
                                    bResult = MicrorocChain1.StopSCTest(MyUsbDevice1);
                                    if (bResult)
                                    {
                                        StateIndicator.SlowAcqStart = false;
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
                                StateIndicator.SlowAcqStart = false;
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
                            }
                        }
                        #endregion
                        #region 64 Channel Mode
                        //--- 64 Channel Test ---//
                        else if (cbxSingleOrAuto.SelectedIndex == AllChannel)
                        {
                            if (!StateIndicator.SlowAcqStart)
                            {
                                //*** Set Package Number
                                StateIndicator.SlowDataRatePackageNumber = HeaderLength + (ChannelLength + ((EndDac - StartDac) / AdcInterval + 1)  * OneDacDataLength) * 64 + TailLength;
                                #region Clear USB FIFO
                                bResult = MicrorocChain1.ClearUsbFifo(MyUsbDevice1);
                                if (bResult)
                                    txtReport.AppendText("USB fifo cleared");
                                else
                                {
                                    txtReport.AppendText("fail to clear USB fifo");
                                    return;
                                }
                                #endregion
                                #region Data ACQ
                                bResult = MicrorocChain1.StartSCTest(MyUsbDevice1);
                                if (bResult)
                                {
                                    StateIndicator.SlowAcqStart = true;
                                    txtReport.AppendText("SCurve Test Start\n");
                                    txtReport.AppendText("SCurve Test Continue\n");
                                    btnSweepTestStart.Content = "SCurve Test Stop";
                                    await Task.Run(() => GetSlowDataRateResultCallBack(MyUsbDevice1));
                                    bResult = MicrorocChain1.StopSCTest(MyUsbDevice1);
                                    if (bResult)
                                    {
                                        StateIndicator.SlowAcqStart = false;
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
                                    txtReport.AppendText("SCurve Start Failure\n");
                                }
                                #endregion
                            }
                            else
                            {
                                StateIndicator.SlowAcqStart = false;
                                bResult = MicrorocChain1.StopSCTest(MyUsbDevice1);
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
                        }
                        else
                        {
                            MessageBox.Show("Set count time failure. Please check the ", //text
                                 "USB Error",   //caption
                                 MessageBoxButton.OK,//button
                                 MessageBoxImage.Error);//icon
                        }
                        #endregion
                        #region Single Channel Mode
                        if (cbxSingleOrAuto.SelectedIndex == SingleChannel)
                        {
                            if (!StateIndicator.SlowAcqStart)
                            {
                                //*** Set Package Number
                                StateIndicator.SlowDataRatePackageNumber = HeaderLength + ChannelLength + ((EndDac - StartDac) / AdcInterval + 1) * OneDacDataLength + TailLength;
                                #region Clear Usb FIFO
                                bResult = MicrorocChain1.ClearUsbFifo(MyUsbDevice1);
                                if (bResult)
                                    txtReport.AppendText("USB fifo cleared");
                                else
                                {
                                    txtReport.AppendText("fail to clear USB fifo");
                                    return;
                                }
                                #endregion
                                #region Data ACQ
                                bResult = MicrorocChain1.StartSCTest(MyUsbDevice1);
                                if (bResult)
                                {
                                    StateIndicator.SlowAcqStart = true;
                                    txtReport.AppendText("SCurve Test Start\n");
                                    txtReport.AppendText("SCurve Test Continue\n");
                                    btnSweepTestStart.Content = "SCurve Test Stop";
                                    await Task.Run(() => GetSlowDataRateResultCallBack(MyUsbDevice1));
                                    bResult = MicrorocChain1.StopSCTest(MyUsbDevice1);
                                    if (bResult)
                                    {
                                        StateIndicator.SlowAcqStart = false;
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
                                    txtReport.AppendText("SCurve Test start Failure\n");
                                }
                                #endregion
                            }
                            else
                            {
                                StateIndicator.SlowAcqStart = false;
                                bResult = MicrorocChain1.StopSCTest(MyUsbDevice1);
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
                            if (!StateIndicator.SlowAcqStart)
                            {
                                //*** Set Package Number
                                StateIndicator.SlowDataRatePackageNumber = HeaderLength + (ChannelLength + ((EndDac - StartDac) / AdcInterval + 1) * OneDacDataLength) * 64 + TailLength;
                                #region Clear USB FIFO
                                bResult = MicrorocChain1.ClearUsbFifo(MyUsbDevice1);
                                if (bResult)
                                    txtReport.AppendText("USB fifo cleared");
                                else
                                {
                                    txtReport.AppendText("fail to clear USB fifo");
                                    return;
                                }
                                #endregion
                                #region Data ACQ
                                bResult = MicrorocChain1.StartSCTest(MyUsbDevice1);
                                if (bResult)
                                {
                                    StateIndicator.SlowAcqStart = true;
                                    txtReport.AppendText("SCurve Test Start\n");
                                    btnSweepTestStart.Content = "Sweep Test Stop";
                                    txtReport.AppendText("SCurve Test Continue\n");
                                    await Task.Run(() => GetSlowDataRateResultCallBack(MyUsbDevice1));
                                    bResult = MicrorocChain1.StopSCTest(MyUsbDevice1);
                                    if (bResult)
                                    {
                                        StateIndicator.SlowAcqStart = false;
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
                                StateIndicator.SlowAcqStart = false;
                                bResult = MicrorocChain1.StopSCTest(MyUsbDevice1);
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
                else if (StateIndicator.OperationModeSelect == StateIndicator.OperationMode.SweepAcq)
                {
                    if (!StateIndicator.SlowAcqStart)
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
                        #region Clear USB FIFO
                        bResult = MicrorocChain1.ClearUsbFifo(MyUsbDevice1);
                        if (bResult)
                            txtReport.AppendText("USB fifo cleared");
                        else
                        {
                            txtReport.AppendText("fail to clear USB fifo");
                            return;
                        }
                        #endregion
                        #region Data ACQ
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
                                StateIndicator.SlowAcqStart = false;
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
                            txtReport.AppendText("Sweep Acq Start Failure\n");
                        }
                        #endregion
                    }
                    else
                    {
                        StateIndicator.SlowAcqStart = false;
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
                    }
                }
                #endregion
                #region Efficiency
                else if(StateIndicator.OperationModeSelect == StateIndicator.OperationMode.Efficiency)
                {
                    if(!StateIndicator.SlowAcqStart)
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
                        else if(IllegalInput)
                        {
                        }
                        else
                        {
                            MessageBox.Show("Set Trigger Delay failure. Please check the USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                            return;
                        }
                        #endregion
                        StateIndicator.SlowDataRatePackageNumber = 7 * 2;
                        #region Clear USB FIFO
                        bResult = MicrorocChain1.ClearUsbFifo(MyUsbDevice1);
                        if (bResult)
                            txtReport.AppendText("USB fifo cleared");
                        else
                        {
                            txtReport.AppendText("fail to clear USB fifo");
                        }
                        #endregion
                        #region Data ACQ
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
                        }
                        else
                        {
                            txtReport.AppendText("Sweep Acq Stop Failure\n");
                        }
                        #endregion
                    }
                    else
                    {
                        StateIndicator.SlowAcqStart = false;
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
                    else if(IllegalInput)
                    {
                        MessageBox.Show("Delay time is not correct, please retype:0-400 integer", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
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
                    if(bResult)
                    {
                        string report = string.Format("Set Adc Data Nmuber:{0}\n", txtAdcAcqTimes.Text);
                        txtReport.AppendText(report);
                    }
                    else if(IllegalInput)
                    {
                        MessageBox.Show("Adc data number incorrect. Please re-type:0-255 integer", "Illegal Input", MessageBoxButton.OK, MessageBoxImage.Error);
                    }
                    else
                    {
                        MessageBox.Show("Set ADC Data Times failure, please check the USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                        return;
                    }
                    #endregion
                    #region Set ADC Input
                    bResult = MicrorocChain1.SelectAdcMonitorHoldOrTemp(cbxAdcInput.SelectedIndex, MyUsbDevice1);
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
                        StateIndicator.AdcStart = false;
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
        private void GetSlowDataRateResultCallBack(MyCyUsb usbInterface)
        {
            bw = new BinaryWriter(File.Open(filepath, FileMode.Append));
            //private int SingleDataLength = 512;
            bool bResult = false;
            byte[] DataReceiveBytes = new byte[512];
            if (StateIndicator.OperationModeSelect == StateIndicator.OperationMode.Acq 
                || StateIndicator.OperationModeSelect == StateIndicator.OperationMode.SweepAcq 
                || StateIndicator.OperationModeSelect == StateIndicator.OperationMode.SCTest 
                || StateIndicator.OperationModeSelect == StateIndicator.OperationMode.Efficiency)
            {
                #region The Max Data Number is Set
                if (StateIndicator.SlowDataRatePackageNumber != 0)
                {
                    int PackageNumber = StateIndicator.SlowDataRatePackageNumber / 512;
                    int RemainPackageNum = StateIndicator.SlowDataRatePackageNumber % 512;
                    int PackageCount = 0;
                    while (PackageCount < PackageNumber & StateIndicator.SlowAcqStart)
                    {
                        bResult = usbInterface.DataRecieve(DataReceiveBytes, DataReceiveBytes.Length);
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
                        while (!usbInterface.DataRecieve(RemainByte, RemainByte.Length) & StateIndicator.SlowAcqStart) ;
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
                //IsSlowAcqStart = false;
            }
            else if (StateIndicator.OperationModeSelect == StateIndicator.OperationMode.ADC)
            {
                while (StateIndicator.AdcStart)
                {
                    bResult = usbInterface.DataRecieve(DataReceiveBytes, DataReceiveBytes.Length);
                    if (bResult)
                    {
                        bw.Write(DataReceiveBytes);
                    }
                }
            }
            byte[] EndFrame = new byte[512];
            for (int j = 0; j < 32; j++)
            {
                bResult = usbInterface.DataRecieve(EndFrame, EndFrame.Length);
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
            SetAfg3252FrequencyCopy();
            SetAfg3252Ch1Frequency();
            SetAfg3252Ch2Frequency();
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
            }
            else
            {
                MessageBox.Show("USB Connect Error", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private void tbiMicrorocAcq_MouseLeftButtonUp(object sender, System.Windows.Input.MouseButtonEventArgs e)
        {
            txtReport.Text = "";
        }

        private void tbiSCTest_MouseLeftButtonUp(object sender, System.Windows.Input.MouseButtonEventArgs e)
        {
            txtReport.Text = "";
            bool bResult = MicrorocChain1.SelectOperationMode(CommandHeader.SCurveTestModeIndex, MyUsbDevice1);
            if (bResult)
            {
                txtReport.AppendText("SCurve Test Mode\n");
                StateIndicator.OperationModeSelect = StateIndicator.OperationMode.SCTest;
                MicrorocPowerPulsingDisable();
                #region Select External Raz
                bResult = MicrorocChain1.SelectRazChannel(1, MyUsbDevice1);
                if(bResult)
                {
                    txtReport.AppendText("Select External RAZ\n");
                }
                else
                { }
                #endregion
            }
            else
            {
                MessageBox.Show("Select SCurve Test mode failure. Please check the USB cable and re-click SCTest", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private void tbiAD9220_MouseLeftButtonUp(object sender, System.Windows.Input.MouseButtonEventArgs e)
        {
            bool bResult = MicrorocChain1.SelectOperationMode(CommandHeader.AdcModeIndex, MyUsbDevice1);
            if(bResult)
            {
                txtReport.AppendText("ADC Mode\n");
                StateIndicator.OperationModeSelect = StateIndicator.OperationMode.ADC;
                MicrorocPowerPulsingDisable();
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
                    txtReport.AppendText("Set External RAZ time: 100ns\n");
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
            }
            else
            {
                MessageBox.Show("Select AD9220 test mode failure. Please check the USB cable and re-click the AD9220", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private void tbiSweepAcq_MouseRightButtonUp(object sender, System.Windows.Input.MouseButtonEventArgs e)
        {
            bool bResult = MicrorocChain1.SelectOperationMode(CommandHeader.SweepAcqModeIndex, MyUsbDevice1);
            if(bResult)
            {
                txtReport.AppendText("Sweep ACQ Mode Select\n");
                StateIndicator.OperationModeSelect = StateIndicator.OperationMode.SweepAcq;
            }
            else
            {
                MessageBox.Show("Select Sweep ACQ Test mode failure. Please check the USB cable and re-click Sweep ACQ", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private void tbmNormalAcq_MouseLeftButtonUp(object sender, System.Windows.Input.MouseButtonEventArgs e)
        {
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
                #region Select NOR64
                bResult = MicrorocChain1.SelectTrigOutNor64OrSingle(1, MyUsbDevice1);
                if(bResult)
                {
                    txtReport.AppendText("Select trigger out NOR64");
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

        /*private void cbxAdcStartMode_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            byte[] CommandBytes = new byte[2];
            bool bResult = false;
            int AdcStartModeValue = cbxAdcStartMode.SelectedIndex + 128;//0x80
            CommandBytes = ConstCommandByteArray(0xE8, (byte)AdcStartModeValue);
            bResult = CommandSend(CommandBytes, CommandBytes.Length);
            if(bResult)
            {
                string report = string.Format("Select ADC Start{0}\n", cbxAdcStartMode.Text);
                txtReport.AppendText(report);
            }
            else
            {
                MessageBox.Show("Set ADC Start Mode failure, please check USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }*/
    }
}
