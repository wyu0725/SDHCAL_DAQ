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
        private int DataAcqMode = Acq;
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
                btnSetAcqTime.IsEnabled = true;
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
                btnSetAcqTime.IsEnabled = false;
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
            if (string.IsNullOrEmpty(filepath.Trim()))
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
                    AcqStart = true;
                    btnAcqStart.Content = "AcqAbort";
                    btnAcqStart.Background = Brushes.DeepPink;
                    threadbuffer.Clear();
                    bool bResult = false;
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
        /*----------Waveform show---------*/ //启动动态显示线程
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
        /*-----------Serialport--------------*/
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
            int value = ASIC_Number + 176 + 1;
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
                Header_Value[0] += (byte)ASIC_Number;
                string DCCaliString, SCTCaliString;
                byte[] CaliData = new byte[64];
                //byte[] SCTCaliData = new byte[64];
                string[] Chn = new string[64];
                byte[] CommandHeader = new byte[64];
                byte CaliByte1, CaliByte2;
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
                    if (cbxPedCali_ASIC[i].SelectedIndex == 0)
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
            Regex rx_int = new Regex(rx_Integer);
            bool Is_Hold_legal = rx_int.IsMatch(txtHold_delay.Text);
            if (Is_Hold_legal)
            {
                int value = Int32.Parse(txtHold_delay.Text)/25 + 42496; //除以25ns
                byte[] bytes = ConstCommandByteArray((byte)(value >> 8), (byte)(value));
                bool bResult = CommandSend(bytes, bytes.Length);
                if (bResult)
                {
                    string report = string.Format("set Hold delay : {0}\n", txtHold_delay.Text);
                    txtReport.AppendText(report);
                }
                else
                {
                    MessageBox.Show("set Hold delay failure, please check USB", //text
                                     "USB Error",   //caption
                                     MessageBoxButton.OK,//button
                                     MessageBoxImage.Error);//icon
                }
                value = cbxTrig_Coincid.SelectedIndex + 42400; //这里不需要加1
                bytes = ConstCommandByteArray((byte)(value >> 8), (byte)(value));
                bResult = CommandSend(bytes, bytes.Length);
                if (bResult)
                {
                    string report = string.Format("set Trigger Coincidence : {0}\n", cbxTrig_Coincid.Text);
                    txtReport.AppendText(report);
                }
                else
                {
                    MessageBox.Show("set Trigger Coincid failure, please check USB", //text
                                     "USB Error",   //caption
                                     MessageBoxButton.OK,//button
                                     MessageBoxImage.Error);//icon
                }

            }
            else
            {
                MessageBox.Show("Illegal Hold delay, please re-type(Integer:0--650,step:25ns)", //text
                                 "Illegal input",   //caption
                                 MessageBoxButton.OK,//button
                                 MessageBoxImage.Error);//icon
            }
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
            bool Is_Time_Legel = rx_int.IsMatch(txtExternal_RAZ_Delay.Text);
            if(Is_Time_Legel)
            {
                int value = Int16.Parse(txtExternal_RAZ_Delay.Text) / 25 + 208;//0xD0
                byte[] bytes = ConstCommandByteArray(0xA8, (byte)value);
                bool bResult = CommandSend(bytes, bytes.Length);
                if(bResult)
                {
                    string report = string.Format("Set External RAZ Delay Time {0}ns \n", txtExternal_RAZ_Delay.Text);
                    txtReport.AppendText(report);
                }
                else
                {
                    MessageBox.Show("Set External RAZ Delay Time failure, please check the USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                }
            }
            else
            {
                MessageBox.Show("Illegal External RAZ Delay Time, please re-type(Integer:0--6375,step:25ns)", "Ilegal Input", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }
        //E0A0选择ACQ，E0A1选择Scurve
        /*private void ACQ_or_SCTest_Checked(object sender, RoutedEventArgs e)
        {
            var botton = sender as RadioButton;
            bool bResult = false;
            if(botton.Content.ToString() == "ACQ") //这里已经直接将通道都切换过去
            {
                btnAcqStart.IsEnabled = true;
                btnScurve_start.IsEnabled = false;
                byte[] bytes = ConstCommandByteArray(0xE0, 0xA0);
                bResult = CommandSend(bytes, bytes.Length);
                if(bResult)
                {
                    txtReport.AppendText("Select ACQ mode\n");
                }
                else
                {
                    MessageBox.Show("Set ACQ Mode Failure. Please check the USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                }
            }
            else if(botton.Content.ToString() == "SCTest")
            {
                btnAcqStart.IsEnabled = false;
                btnScurve_start.IsEnabled = true;
                byte[] bytes = ConstCommandByteArray(0xE0, 0xA1);
                bResult = CommandSend(bytes, bytes.Length);
                if(bResult)
                {
                    txtReport.AppendText("Select S Curve Test Mode");
                }
                else
                {
                    MessageBox.Show("Set S Curve Test mode failure. Please check the USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                }
            }
        }*/
        //E0B0选择单通道测试，E0B1选择64通道测试
        /*private void Single_or_64Chn_Checked(object sender, RoutedEventArgs e)
        {
            var botton = sender as RadioButton;
            bool bResult = false;
            if (botton.Content.ToString() == "Single")
            {
                ChannelMode = SingleChannel;
                byte[] bytes = ConstCommandByteArray(0xE0, 0xB0);
                bResult = CommandSend(bytes, bytes.Length);
                if (bResult)
                {
                    txtReport.AppendText("Set S Curve in single test mode \n");
                }
                else
                {
                    MessageBox.Show("Set S Curve single test mode failure. Please check the USB\n", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                }
                //Scurve_data_length = 7171 * 2;//单通道产生这多字节的数据
                //Scurve_Data_Pkg = Single_SCurve_Data_Length / SCurve_Package_Length;
                //Scurve_Data_Remain = Single_SCurve_Data_Length % SCurve_Package_Length;
            }
            else if (botton.Content.ToString() == "Auto")
            {
                ChannelMode = AllChannel;
                byte[] bytes = ConstCommandByteArray(0xE0, 0xB1);
                bResult = CommandSend(bytes, bytes.Length);
                if(bResult)
                {
                    txtReport.AppendText("Set S Curve test in 64 channel mode \n");
                }
                else
                {
                    MessageBox.Show("Set S Curve test in 64 channel mode failure. Please check the USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                }
                //Scurve_data_length = 458818 * 2;//64通道产生这么多字节的数据
                //Scurve_Data_Pkg = AllChn_SCurve_Data_Length / SCurve_Package_Length;
                //Scurve_Data_Remain = AllChn_SCurve_Data_Length % SCurve_Package_Length;
            }
        }*/
        //E0C0:单通道测试时从CTest管脚输入,E0C1单通道测试从direct input输入
        /*private void CTest_or_Input_Checked(object sender, RoutedEventArgs e)
        {
            var button = sender as RadioButton;
            bool bResult = false;
            if(button.Content.ToString() == "CTest")
            {
                byte[] bytes = ConstCommandByteArray(0xE0, 0xC0);
                bResult = CommandSend(bytes, bytes.Length);
                if(bResult)
                {
                    txtReport.AppendText("The charge is input in CTest Pin\n");
                }
                else
                {
                    MessageBox.Show("Set charge inject method failure. Please check the USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                }
            }
            else if(button.Content.ToString() == "Input")
            {
                byte[] bytes = ConstCommandByteArray(0xE0, 0xC1);
                bResult = CommandSend(bytes, bytes.Length);
                if(bResult)
                {
                    txtReport.AppendText("The charge is injected in Input Pin\n");
                }
                else
                {
                    MessageBox.Show("Set charge inject method failure.Please check the USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                }
            }
        }*/

        /*private void btnSet_SCT_Param_Click(object sender, RoutedEventArgs e)
        {
            //***-------------- Set the single test channel -------------------
            Regex rx_int = new Regex(rx_Integer);
            bool Is_Single_Test_Chn_Legal = rx_int.IsMatch(txtSingleTest_Chn.Text) && (short.Parse(txtSingleTest_Chn.Text) <= 64);
            byte[] bytes = new byte[2];
            bool bResult = false;
            if(Is_Single_Test_Chn_Legal)
            {
                int value_SingleTestChn = Int16.Parse(txtSingleTest_Chn.Text) - 1;
                bytes = ConstCommandByteArray(0xE1, (byte)value_SingleTestChn);
                bResult = CommandSend(bytes, bytes.Length);
                if(bResult)
                {
                    string report = string.Format("Set the single test channel to {0}\n", value_SingleTestChn + 1);
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
            //***---------------------- Set the max counter
            int value_CPTMAX = cbxCPT_MAX.SelectedIndex;
            bytes = ConstCommandByteArray(0xE2, (byte)value_CPTMAX);
            bResult = CommandSend(bytes, bytes.Length);
            if (bResult)
            {
                string report = string.Format("Set the S Curve test max count to {0}\n", cbxCPT_MAX.Text);
                txtReport.AppendText(report);
            }
            else
            {
                MessageBox.Show("Set S Curve test max count failure. Please check the USB\n", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
            // Set Counter Time
            int value_CounterTime = txtCountTime.SelectedIndex;
            bytes = ConstCommandByteArray(0xE3, (byte)value_CounterTime);
            bResult = CommandSend(bytes, bytes.Length);
            if (bResult)
            {
                string report = string.Format("Set the S Curve test max time to {0}\n", txtCountTime.Text);
                txtReport.AppendText(report);
            }
            else
            {
                MessageBox.Show("Set S Curve test max count failure. Please check the USB\n", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }*/
        //--Scurve测试开始E0F0,Scurve测试结束E0F1--//
        /*private void btnScurve_start_Click(object sender, RoutedEventArgs e)
        {
            if (string.IsNullOrEmpty(filepath.Trim()))
            {
                MessageBox.Show("You should save the file first before Scurve start", //text
                                        "imformation", //caption
                                   MessageBoxButton.OK, //button
                                    MessageBoxImage.Error);//icon     
            }
            else //file is exsits
            {
                StringBuilder reports = new StringBuilder();                
                bool bResult = false;
                byte[] cmd_ClrUSBFifo = ConstCommandByteArray(0xF0, 0xFA);
                bResult = CommandSend(cmd_ClrUSBFifo, 2);//
                if (bResult)
                    reports.AppendLine("USB fifo cleared");
                else
                    reports.AppendLine("fail to clear USB fifo");
                byte[] bytes = new byte[2048];
                bResult = DataRecieve(bytes, bytes.Length);//读空剩余在USB芯片里面的数据
                byte[] cmd_ScurveStart = ConstCommandByteArray(0xE0, 0xF0);
                bResult = CommandSend(cmd_ScurveStart, 2);
                if (bResult)
                {
                    reports.AppendLine("Scurve Test Thread start");
                    Task Scurve_test = new Task(() => Get_ScurveResultCallBack());
                    //Start the task
                    Scurve_test.Start();
                    //wait for task ending
                    Scurve_test.Wait();
                    byte [] cmd_ScurveEnd = ConstCommandByteArray(0xE0, 0xF1);//这里需要添加取消操作吗？
                    if (CommandSend(cmd_ScurveEnd, 2))
                    {
                        reports.AppendLine("Scurve Test Thread End");
                    }
                    else
                    {
                        reports.AppendLine("Scurve Test End failure");
                    }
                }
                else
                    reports.AppendLine("Scurve Start failure");
                txtReport.AppendText(reports.ToString());                               
            }
        }*/
        /*private void Get_ScurveResultCallBack()
        {
            //DisplayPacketNum dp2 = new DisplayPacketNum((string s) => { ShowPacketNum(s); });
            //string report;
            bw = new BinaryWriter(File.Open(filepath, FileMode.Append));
            bool bResult = false;
            byte[] bytes = new byte[SCurve_Package_Length];//应分片，不让太大了一次性弄不完
            int Package_Count = 0;
            while (Package_Count <= Scurve_Data_Pkg)//这里应该用<=而不是<最后一个包虽然不够512个，但是USB还是提交了这么多，要是少抓一个可能出现超时最后一个包收不到的情况
            {
                bResult = DataRecieve(bytes, bytes.Length);
                if (bResult)
                {
                    bw.Write(bytes); //接收成功写入文件,写文件很慢，没事可以等
                    Package_Count++;
                }
            }
            /for (int i = 0; i < Scurve_data_pkg; i++)
            {
                bResult = DataRecieve(bytes, bytes.Length);
                if (bResult)
                {
                    bw.Write(bytes); //接收成功写入文件,写文件很慢，没事可以等
                }
            }
            byte[] test = new byte[512];
            bResult = DataRecieve(test, test.Length);
            if (bResult)
            {
                bw.Write(test); //接收成功写入文件
            }
            byte[] re_bytes = new byte[Scurve_Data_Remain];
            bResult = DataRecieve(re_bytes, re_bytes.Length);
            if (bResult)
            {
                 bw.Write(re_bytes); //接收成功写入文件
            }
            //---------------------------------------//
            //bw.Flush();
            bw.Dispose();
            bw.Close();
            //report = string.Format("data stored in {0}\n", filepath);
            //Dispatcher.Invoke(dp2, report);
        }*/

        /*private void btnChnCali_Click(object sender, RoutedEventArgs e)
        {
            ComboBox[] cbxPedCali_ASIC = new ComboBox[4] { cbxPedCali_ASIC1, cbxPedCali_ASIC2, cbxPedCali_ASIC3, cbxPedCali_ASIC4 };
            string[] Chn = new string[64];
            byte[] Command_Header = new byte[64];
            for(int i = 0; i < 64; i++)
            {
                Chn[i] = string.Format("Chn{0}", i);
                Command_Header[i] = (byte)(0xC0 + i);
            }
            byte[] DCCaliDataTemp = new byte[64];
            byte[] SCTCaliDataTemp = new byte[64];
            byte[,] DCCali = new byte[4, 64];
            byte[,] SCTCali = new byte[4, 64];
            StreamReader DCCaliFile, SCTCaliFile;
            
            string DCCaliFileName,SCTCaliFileName;
            for(int i = 0; i < 4; i++)
            {
                DCCaliFileName = string.Format("D:\\ExperimentsData\\test\\DCCali{0}.txt", i);
                SCTCaliFileName = string.Format("D:\\ExperimentsData\\test\\SCTCali{0}.txt", i);
                DCCaliFile = File.OpenText(DCCaliFileName);
                SCTCaliFile = File.OpenText(SCTCaliFileName);
                string DCCaliString, SCTCaliString;
                
                for (int j = 0; j < 64; j++)
                {
                    DCCaliString = DCCaliFile.ReadLine();
                    SCTCaliString = SCTCaliFile.ReadLine();
                    DCCali[i, j] = byte.Parse(DCCaliString);
                    SCTCali[i, j] = byte.Parse(SCTCaliString);

                }              
            }
            int ASIC_Number = cbxASIC_Number.SelectedIndex + 1;
            for(int i = 0; i < ASIC_Number; i++)
            {
                CaliHashTable[i].Clear();
                switch(cbxPedCali_ASIC[i].SelectedIndex)
                {
                    case 0:
                        for (int j = 0; j < 64; j++)
                        {
                            CaliHashTable[i].Add(Chn[j], new byte[] { Command_Header[j], 0x00 });
                        }
                        #region Without Cali

                        CaliHashTable[i].Add("Chn0", new byte[] { 0xC0, 0x00 });//chn0
                        CaliHashTable[i].Add("Chn1", new byte[] { 0xC1, 0x00 });//chn1
                        CaliHashTable[i].Add("Chn2", new byte[] { 0xC2, 0x00 });//chn2
                        CaliHashTable[i].Add("Chn3", new byte[] { 0xC3, 0x00 });//chn3
                        CaliHashTable[i].Add("Chn4", new byte[] { 0xC4, 0x00 });//chn4
                        CaliHashTable[i].Add("Chn5", new byte[] { 0xC5, 0x00 });//chn5
                        CaliHashTable[i].Add("Chn6", new byte[] { 0xC6, 0x00 });//chn6
                        CaliHashTable[i].Add("Chn7", new byte[] { 0xC7, 0x00 });//chn7
                        CaliHashTable[i].Add("Chn8", new byte[] { 0xC8, 0x00 });//chn8
                        CaliHashTable[i].Add("Chn9", new byte[] { 0xC9, 0x00 });//chn9
                        CaliHashTable[i].Add("Chn10", new byte[] { 0xCA, 0x00 });//chn10
                        CaliHashTable[i].Add("Chn11", new byte[] { 0xCB, 0x00 });//chn11
                        CaliHashTable[i].Add("Chn12", new byte[] { 0xCC, 0x00 });//chn12
                        CaliHashTable[i].Add("Chn13", new byte[] { 0xCD, 0x00 });//chn13
                        CaliHashTable[i].Add("Chn14", new byte[] { 0xCE, 0x00 });//chn14
                        CaliHashTable[i].Add("Chn15", new byte[] { 0xCF, 0x00 });//chn15
                        CaliHashTable[i].Add("Chn16", new byte[] { 0xD0, 0x00 });//chn16
                        CaliHashTable[i].Add("Chn17", new byte[] { 0xD1, 0x00 });//chn17
                        CaliHashTable[i].Add("Chn18", new byte[] { 0xD2, 0x00 });//chn18
                        CaliHashTable[i].Add("Chn19", new byte[] { 0xD3, 0x00 });//chn19
                        CaliHashTable[i].Add("Chn20", new byte[] { 0xD4, 0x00 });//chn20
                        CaliHashTable[i].Add("Chn21", new byte[] { 0xD5, 0x00 });//chn21
                        CaliHashTable[i].Add("Chn22", new byte[] { 0xD6, 0x00 });//chn22
                        CaliHashTable[i].Add("Chn23", new byte[] { 0xD7, 0x00 });//chn23
                        CaliHashTable[i].Add("Chn24", new byte[] { 0xD8, 0x00 });//chn24
                        CaliHashTable[i].Add("Chn25", new byte[] { 0xD9, 0x00 });//chn25
                        CaliHashTable[i].Add("Chn26", new byte[] { 0xDA, 0x00 });//chn26
                        CaliHashTable[i].Add("Chn27", new byte[] { 0xDB, 0x00 });//chn27
                        CaliHashTable[i].Add("Chn28", new byte[] { 0xDC, 0x00 });//chn28
                        CaliHashTable[i].Add("Chn29", new byte[] { 0xDD, 0x00 });//chn29
                        CaliHashTable[i].Add("Chn30", new byte[] { 0xDE, 0x00 });//chn30
                        CaliHashTable[i].Add("Chn31", new byte[] { 0xDF, 0x00 });//chn31
                        CaliHashTable[i].Add("Chn32", new byte[] { 0xE0, 0x00 });//chn32
                        CaliHashTable[i].Add("Chn33", new byte[] { 0xE1, 0x00 });//chn33
                        CaliHashTable[i].Add("Chn34", new byte[] { 0xE2, 0x00 });//chn34
                        CaliHashTable[i].Add("Chn35", new byte[] { 0xE3, 0x00 });//chn35
                        CaliHashTable[i].Add("Chn36", new byte[] { 0xE4, 0x00 });//chn36
                        CaliHashTable[i].Add("Chn37", new byte[] { 0xE5, 0x00 });//chn37
                        CaliHashTable[i].Add("Chn38", new byte[] { 0xE6, 0x00 });//chn38
                        CaliHashTable[i].Add("Chn39", new byte[] { 0xE7, 0x00 });//chn39
                        CaliHashTable[i].Add("Chn40", new byte[] { 0xE8, 0x00 });//chn40
                        CaliHashTable[i].Add("Chn41", new byte[] { 0xE9, 0x00 });//chn41
                        CaliHashTable[i].Add("Chn42", new byte[] { 0xEA, 0x00 });//chn42
                        CaliHashTable[i].Add("Chn43", new byte[] { 0xEB, 0x00 });//chn43
                        CaliHashTable[i].Add("Chn44", new byte[] { 0xEC, 0x00 });//chn44
                        CaliHashTable[i].Add("Chn45", new byte[] { 0xED, 0x00 });//chn45
                        CaliHashTable[i].Add("Chn46", new byte[] { 0xEE, 0x00 });//chn46
                        CaliHashTable[i].Add("Chn47", new byte[] { 0xEF, 0x00 });//chn47
                        CaliHashTable[i].Add("Chn48", new byte[] { 0xF0, 0x00 });//chn48
                        CaliHashTable[i].Add("Chn49", new byte[] { 0xF1, 0x00 });//chn49
                        CaliHashTable[i].Add("Chn50", new byte[] { 0xF2, 0x00 });//chn50
                        CaliHashTable[i].Add("Chn51", new byte[] { 0xF3, 0x00 });//chn51
                        CaliHashTable[i].Add("Chn52", new byte[] { 0xF4, 0x00 });//chn52
                        CaliHashTable[i].Add("Chn53", new byte[] { 0xF5, 0x00 });//chn53
                        CaliHashTable[i].Add("Chn54", new byte[] { 0xF6, 0x00 });//chn54
                        CaliHashTable[i].Add("Chn55", new byte[] { 0xF7, 0x00 });//chn55
                        CaliHashTable[i].Add("Chn56", new byte[] { 0xF8, 0x00 });//chn56
                        CaliHashTable[i].Add("Chn57", new byte[] { 0xF9, 0x00 });//chn57
                        CaliHashTable[i].Add("Chn58", new byte[] { 0xFA, 0x00 });//chn58
                        CaliHashTable[i].Add("Chn59", new byte[] { 0xFB, 0x00 });//chn59
                        CaliHashTable[i].Add("Chn60", new byte[] { 0xFC, 0x00 });//chn60
                        CaliHashTable[i].Add("Chn61", new byte[] { 0xFD, 0x00 });//chn61
                        CaliHashTable[i].Add("Chn62", new byte[] { 0xFE, 0x00 });//chn62
                        CaliHashTable[i].Add("Chn63", new byte[] { 0xFF, 0x00 });//chn63
                        #endregion
                        break;
                    case 1:
                        for(int j = 0;j<64;j++)
                        {
                            CaliHashTable[i].Add(Chn[j], new byte[] { Command_Header[j], DCCali[i,j] });
                        }
                        break;
                    case 2:
                        for (int j = 0; j < 64; j++)
                        {
                            CaliHashTable[i].Add(Chn[j], new byte[] { Command_Header[j], DCCali[i, j] });
                        }
                        break;
                    default:                    
                        for (int j = 0; j < 64; j++)
                        {
                            CaliHashTable[i].Add(Chn[j], new byte[] { Command_Header[j], 0x00 });
                        }
                        break;                        

                }
            }
        }*/

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
        private void btnSlowACQ_Click(object sender, RoutedEventArgs e)
        {
            if (string.IsNullOrEmpty(filepath.Trim()))
            {
                MessageBox.Show("You should save the file first before Scurve start", //text
                                        "imformation", //caption
                                   MessageBoxButton.OK, //button
                                    MessageBoxImage.Error);//icon     
            }
            else //file is exsits
            {
                StringBuilder reports = new StringBuilder();
                Regex rx_int = new Regex(rx_Integer);
                bool Is_DataNum_Legal = rx_int.IsMatch(txtSlowACQDataNum.Text);
                if (Is_DataNum_Legal)
                {
                    SlowACQDataNumber = Int16.Parse(txtSlowACQDataNum.Text);
                    
                }
                else
                {
                    SlowACQDataNumber = 5120;
                }
                SlowDataRatePackageNumber = SlowACQDataNumber*20;
                bool bResult = false;
                byte[] cmd_ClrUSBFifo = ConstCommandByteArray(0xF0, 0xFA);
                bResult = CommandSend(cmd_ClrUSBFifo, 2);//
                if (bResult)
                    reports.AppendLine("USB fifo cleared");
                else
                    reports.AppendLine("fail to clear USB fifo");
                byte[] bytes = new byte[2048];
                bResult = DataRecieve(bytes, bytes.Length);//读空剩余在USB芯片里面的数据
                byte[] CmdSlowACQ = ConstCommandByteArray(0xF0, 0xF0);
                bResult = CommandSend(CmdSlowACQ, CmdSlowACQ.Length);
                if(bResult)
                {
                    reports.AppendLine("Slow data rate ACQ Start\n");
                    Task SlowDataRateACQ = new Task(() => GetSlowDataRateResultCallBack());
                    SlowDataRateACQ.Start();
                    SlowDataRateACQ.Wait();
                    byte[] ACQStop = ConstCommandByteArray(0xF0, 0xF1);
                    if (CommandSend(ACQStop, ACQStop.Length)) 
                    {
                        reports.AppendLine("Slow data rate ACQ Stop\n");
                    }
                    else
                    {
                        reports.AppendLine("Slow data rate ACQ Stop failure\n");
                    }
                }
                else
                {
                    reports.AppendLine("Slow data rate ACQ start failure\n");
                }
                txtReport.AppendText(reports.ToString());
            }
        }
        // Slow data rate acquisition thread
        private void GetSlowDataRateResultCallBack()
        {            
            bw = new BinaryWriter(File.Open(filepath, FileMode.Append));
            //private int SingleDataLength = 512;
            bool bResult = false;
            byte[] bytes = new byte[512];
            int PackageNumber = SlowDataRatePackageNumber / 512;
            int RemainPackageNum = SlowDataRatePackageNumber % 512;
            int PackageCount = 0;
            while(PackageCount < PackageNumber)
            {
                bResult = DataRecieve(bytes, bytes.Length);
                if (bResult)
                {
                    bw.Write(bytes);
                    PackageCount++;
                }                
            }
            byte[] RemainByte = new byte[RemainPackageNum];
            do
            {
                bResult = DataRecieve(RemainByte, RemainByte.Length);
            } while (!bResult);
            bw.Flush();
            bw.Dispose();
            bw.Close();
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
                DataAcqMode = SweepAcq;
                byte[] bytes = ConstCommandByteArray(0xE0, 0xA1);
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
        }

        private void btnSetMask_Click(object sender, RoutedEventArgs e)
        {
            bool bResult = false;
            byte[] CommandBytes = new byte[2];
            string report = null;
            #region Mask or not
            int MaskChoise = cbxMaskOrUnMask.SelectedIndex + 16;
            CommandBytes = ConstCommandByteArray(0xAE, (byte)MaskChoise);
            bResult = CommandSend(CommandBytes, CommandBytes.Length);
            if (bResult)
            {
                report = string.Format("{0}", cbxMaskOrUnMask.Text);
            }
            else
            {
                MessageBox.Show("Set Mask Channel failure, please check the USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
            #endregion
            #region Mask Channel
            Regex rxInt = new Regex(rx_Integer);
            bool IsChannelLegeal = rxInt.IsMatch(txtChannelMask.Text) && (int.Parse(txtChannelMask.Text) <= 64);
            if(IsChannelLegeal)
            {
                int MaskChannel = short.Parse(txtChannelMask.Text) - 1;
                CommandBytes = ConstCommandByteArray(0xAD, (byte)MaskChannel);
                bResult = CommandSend(CommandBytes, CommandBytes.Length);
                if(bResult)
                {
                    if(MaskChoise != 16)
                    {
                        report = report + string.Format("Channel:{0}", MaskChannel + 1);
                    }                    
                    //txtReport.AppendText(report);
                }
                else
                {
                    MessageBox.Show("Set Mask Channel failure, please check the USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                }
            }
            else
            {
                MessageBox.Show("Illegal Mask Channel, please re-type(Integer:0--64)", "Ilegal Input", MessageBoxButton.OK, MessageBoxImage.Error);
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
                    report = string.Format("{0}", cbxDiscriMask.Text);
                }                
                //txtReport.AppendText(report);
            }
            else
            {
                MessageBox.Show("Set Mask Discriminator failure, please check the USB", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
            #endregion
            if(report != null)
            {
                txtReport.AppendText(report);
            }
        }

        private void btnSweepTestStart_Click(object sender, RoutedEventArgs e)
        {
            byte[] CommandBytes = new byte[2];
            bool bResult;
            string report;
            #region Start and End DAC
            Regex rxInt = new Regex(rx_Integer);
            bool IsDacLegal = rxInt.IsMatch(txtStartDac.Text) && rxInt.IsMatch(txtEndDac.Text) && (int.Parse(txtStartDac.Text) < 1023) && (int.Parse(txtEndDac.Text) <= 1023);
            if(IsDacLegal)
            {
                #region Start DAC
                uint StartDacValue = uint.Parse(txtStartDac.Text);                
                uint StartDacValue1 = StartDacValue & 15;
                uint StartDacValue2 = ((StartDacValue >> 4) & 15) + 16;
                uint StartDacValue3 = ((StartDacValue >> 8) & 3) + 32;
                CommandBytes = ConstCommandByteArray(0xE5, (byte)StartDacValue1);
                bResult = CommandSend(CommandBytes, CommandBytes.Length);
                if(!bResult)
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
                if(bResult)
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
                if(bResult)
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
                #region Single Test Channel
                bool IsSCurveChannelLegal = rxInt.IsMatch(txtSingleTest_Chn.Text) && (int.Parse(txtSingleTest_Chn.Text) <= 64);
                if(IsSCurveChannelLegal)
                {
                    int SCurveChannelValue = int.Parse(txtSingleTest_Chn.Text) - 1;
                    CommandBytes = ConstCommandByteArray(0xE1, (byte)SCurveChannelValue);
                    bResult = CommandSend(CommandBytes, CommandBytes.Length);
                    if(bResult)
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
                #region Single or Auto
                //E0B0:Single Channel
                //E0B1:64 Channel
                int SingleOrAutoValue = cbxSingleOrAuto.SelectedIndex + 176;//0xB0
                CommandBytes = ConstCommandByteArray(0xE0, (byte)SingleOrAutoValue);
                bResult = CommandSend(CommandBytes, CommandBytes.Length);
                if(bResult)
                {
                    report = string.Format("Choose {0} Mode\n", cbxSingleOrAuto.Text);
                    txtReport.AppendText(report);
                }
                else
                {
                    MessageBox.Show("Set S Curve channel mode failure. Please check the USB\n", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                }
                #endregion
                #region CTest or Input
                // E0C0:Signal input from CTest pin
                // E0C1:Signal input from input pin
                int CTestOrInputValue = cbxCTestOrInput.SelectedIndex + 192;//0xC0
                CommandBytes = ConstCommandByteArray(0xE0, (byte)CTestOrInputValue);
                bResult = CommandSend(CommandBytes, CommandBytes.Length);
                if(bResult)
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
                    if(bResult)
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
                        //*** Set Package Number
                        SlowDataRatePackageNumber = HeaderLength + ChannelLength + (EndDac - StartDac + 1) * OneDacDataLength + TailLength;
                        //*** Clear USB FIFO
                        byte[] ClearUSBFifo = ConstCommandByteArray(0xF0, 0xFA);
                        bResult = CommandSend(ClearUSBFifo, ClearUSBFifo.Length);//
                        if (bResult)
                            txtReport.AppendText("USB fifo cleared");
                        else
                            txtReport.AppendText("fail to clear USB fifo");
                        byte[] RemainData = new byte[64];
                        bResult = DataRecieve(RemainData, RemainData.Length);
                        #region Data ACQ
                        CommandBytes = ConstCommandByteArray(0xE0, 0xF0);
                        bResult = CommandSend(CommandBytes, CommandBytes.Length);
                        if(bResult)
                        {
                            txtReport.AppendText("SCurve Test Start\n");
                            Task SCurveDataAcq = new Task(() => GetSlowDataRateResultCallBack());
                            SCurveDataAcq.Start();
                            SCurveDataAcq.Wait();
                            CommandBytes = ConstCommandByteArray(0xE0, 0xF1);
                            bResult = CommandSend(CommandBytes, CommandBytes.Length);
                            if(bResult)
                            {
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
                    #endregion
                    #region 64 Channel Mode
                    //--- 64 Channel Test ---//
                    else if (cbxSingleOrAuto.SelectedIndex == AllChannel)
                    {
                        //*** Set Package Number
                        SlowDataRatePackageNumber = HeaderLength + (ChannelLength + (EndDac - StartDac + 1) * OneDacDataLength) * 64 + TailLength;
                        //*** Clear USB FIFO
                        byte[] ClearUSBFifo = ConstCommandByteArray(0xF0, 0xFA);
                        bResult = CommandSend(ClearUSBFifo, ClearUSBFifo.Length);//
                        if (bResult)
                            txtReport.AppendText("USB fifo cleared");
                        else
                            txtReport.AppendText("fail to clear USB fifo");
                        byte[] RemainData = new byte[64];
                        bResult = DataRecieve(RemainData, RemainData.Length);
                        #region Data ACQ
                        CommandBytes = ConstCommandByteArray(0xE0, 0xF0);
                        bResult = CommandSend(CommandBytes, CommandBytes.Length);
                        if (bResult)
                        {
                            txtReport.AppendText("SCurve Test Start\n");
                            Task SCurveDataAcq = new Task(() => GetSlowDataRateResultCallBack());
                            SCurveDataAcq.Start();
                            SCurveDataAcq.Wait();
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
                        else
                        {
                            txtReport.AppendText("SCurve Stop Failure\n");
                        }
                        #endregion
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
                    if(IsCounterMaxLegal)
                    {
                        int CountTimeValue = int.Parse(txtCountTime.Text);
                        CommandBytes = ConstCommandByteArray(0xE3, (byte)CountTimeValue);
                        bResult = CommandSend(CommandBytes, CommandBytes.Length);
                        if(!bResult)
                        {
                            MessageBox.Show("Set count time failure. Please check the ", //text
                                 "USB Error",   //caption
                                 MessageBoxButton.OK,//button
                                 MessageBoxImage.Error);//icon
                        }
                        CommandBytes = ConstCommandByteArray(0xE4, (byte)(CountTimeValue >> 8));
                        bResult = CommandSend(CommandBytes, CommandBytes.Length);
                        if(bResult)
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
                        //*** Set Package Number
                        SlowDataRatePackageNumber = HeaderLength + ChannelLength + (EndDac - StartDac + 1) * OneDacDataLength + TailLength;
                        //*** Clear USB FIFO
                        byte[] ClearUSBFifo = ConstCommandByteArray(0xF0, 0xFA);
                        bResult = CommandSend(ClearUSBFifo, ClearUSBFifo.Length);//
                        if (bResult)
                            txtReport.AppendText("USB fifo cleared");
                        else
                            txtReport.AppendText("fail to clear USB fifo");
                        byte[] RemainData = new byte[64];
                        bResult = DataRecieve(RemainData, RemainData.Length);
                        #region Data ACQ
                        CommandBytes = ConstCommandByteArray(0xE0, 0xF0);
                        bResult = CommandSend(CommandBytes, CommandBytes.Length);
                        if (bResult)
                        {
                            txtReport.AppendText("SCurve Test Start\n");
                            Task SCurveDataAcq = new Task(() => GetSlowDataRateResultCallBack());
                            SCurveDataAcq.Start();
                            SCurveDataAcq.Wait();
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
                        else
                        {
                            txtReport.AppendText("SCurve Stop Failure\n");
                        }
                        #endregion
                    }
                    #endregion
                    #region 64Channel Mode
                    else if(cbxSingleOrAuto.SelectedIndex == AllChannel)
                    {
                        //*** Set Package Number
                        SlowDataRatePackageNumber = HeaderLength + (ChannelLength + (EndDac - StartDac + 1) * OneDacDataLength) * 64 + TailLength;
                        //*** Clear USB FIFO
                        byte[] ClearUSBFifo = ConstCommandByteArray(0xF0, 0xFA);
                        bResult = CommandSend(ClearUSBFifo, ClearUSBFifo.Length);//
                        if (bResult)
                            txtReport.AppendText("USB fifo cleared");
                        else
                            txtReport.AppendText("fail to clear USB fifo");
                        byte[] RemainData = new byte[64];
                        bResult = DataRecieve(RemainData, RemainData.Length);
                        #region Data ACQ
                        CommandBytes = ConstCommandByteArray(0xE0, 0xF0);
                        bResult = CommandSend(CommandBytes, CommandBytes.Length);
                        if (bResult)
                        {
                            txtReport.AppendText("SCurve Test Start\n");
                            Task SCurveDataAcq = new Task(() => GetSlowDataRateResultCallBack());
                            SCurveDataAcq.Start();
                            SCurveDataAcq.Wait();
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
                        else
                        {
                            txtReport.AppendText("SCurve Stop Failure\n");
                        }
                        #endregion
                    }
                    #endregion
                }
                #endregion
            }
            #endregion
            #region Sweep Acq
            else if (DataAcqMode == SweepAcq)
            {
                #region Set Package Number
                bool IsPackageNumberLegal = rxInt.IsMatch(txtPackageNumber.Text) && (int.Parse(txtPackageNumber.Text) < 65535);
                int PackageNumberValue;
                if(IsPackageNumberLegal)
                {
                    PackageNumberValue = int.Parse(txtPackageNumber.Text);
                } 
                else
                {
                    PackageNumberValue = 10000;
                }
                CommandBytes = ConstCommandByteArray(0xE6, (byte)PackageNumberValue);
                bResult = CommandSend(CommandBytes, CommandBytes.Length);
                if(!bResult)
                {
                    MessageBox.Show("Set count time failure. Please check the ", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
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
                    MessageBox.Show("Set count time failure. Please check the ", "USB Error", MessageBoxButton.OK, MessageBoxImage.Error);
                }
                #endregion
                #region Set Sweep Dac
                int SweepDacSelectValue = cbxDacSelect.SelectedIndex;
                CommandBytes = ConstCommandByteArray(0xE0, (byte)(SweepDacSelectValue));
                bResult = CommandSend(CommandBytes, CommandBytes.Length);
                if(bResult)
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
                //*** Clear USB FIFO
                byte[] ClearUSBFifo = ConstCommandByteArray(0xF0, 0xFA);
                bResult = CommandSend(ClearUSBFifo, ClearUSBFifo.Length);//
                if (bResult)
                    txtReport.AppendText("USB fifo cleared");
                else
                    txtReport.AppendText("fail to clear USB fifo");
                byte[] RemainData = new byte[64];
                bResult = DataRecieve(RemainData, RemainData.Length);
                #region Data ACQ
                CommandBytes = ConstCommandByteArray(0xE0, 0xF0);
                bResult = CommandSend(CommandBytes, CommandBytes.Length);
                if (bResult)
                {
                    txtReport.AppendText("Sweep Acq Test Start\n");
                    Task SCurveDataAcq = new Task(() => GetSlowDataRateResultCallBack());
                    SCurveDataAcq.Start();
                    SCurveDataAcq.Wait();
                    CommandBytes = ConstCommandByteArray(0xE0, 0xF1);
                    bResult = CommandSend(CommandBytes, CommandBytes.Length);
                    if (bResult)
                    {
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
            #endregion

        }
        //control channel calibration

        #region Old Code for ChnCali
        /*private void btnChnCali_Click(object sender, RoutedEventArgs e)
        {
            StringBuilder details = new StringBuilder();
            byte[] param = new byte[2];
            byte[] bytes = new byte[2];
            byte byte1, byte2;
            bool bResult = false;
            foreach (string str in hasht.Keys)
            {
                param = (byte[])hasht[str];//获取参数  
                byte1 = (byte)(param[0] >> 4 + 0xC0);
                byte2 = (byte)(param[0] << 4 + param[1]);   
                bytes = ConstCommandByteArray(byte1, byte2);
                bResult = CommandSend(bytes, bytes.Length);
                if (bResult)
                    details.AppendFormat("{0}, 4-bitDAC: {1}\n",str,param[1]);
                Thread.Sleep(10);
            }
            if (chk_PedCali.IsChecked.Value)
                txtReport.AppendText(details.ToString());
            else
                txtReport.AppendText("All channels without calibration\n");
        }*/
        //load channel calibration parameter

        /*private void chk_PedCali_Checked(object sender, RoutedEventArgs e)
        {
            hasht.Clear();
            #region Microroc No.203
            //--- MICROROC NO.203 SC 4-bit DAC Parameter ---
            //This parameter is caculated via DC voltage measured by KEITHLEY2701
            hasht.Add("Chn0", new byte[] { 0xC0, 0x02}); //chn0
            hasht.Add("Chn1", new byte[] { 0xC1, 0x03});//chn1
            hasht.Add("Chn2", new byte[] { 0xC2, 0x06});//chn2
            hasht.Add("Chn3", new byte[] { 0xC3, 0x01});//chn3
            hasht.Add("Chn4", new byte[] { 0xC4, 0x03});//chn4
            hasht.Add("Chn5", new byte[] { 0xC5, 0x03});//chn5
            hasht.Add("Chn6", new byte[] { 0xC6, 0x03});//chn6
            hasht.Add("Chn7", new byte[] { 0xC7, 0x01});//chn7
            hasht.Add("Chn8", new byte[] { 0xC8, 0x05});//chn8
            hasht.Add("Chn9", new byte[] { 0xC9, 0x02});//chn9
            hasht.Add("Chn10", new byte[] { 0xCA, 0x04});//chn10
            hasht.Add("Chn11", new byte[] { 0xCB, 0x04});//chn11
            hasht.Add("Chn12", new byte[] { 0xCC, 0x03});//chn12
            hasht.Add("Chn13", new byte[] { 0xCD, 0x03});//chn13
            hasht.Add("Chn14", new byte[] { 0xCE, 0x03});//chn14
            hasht.Add("Chn15", new byte[] { 0xCF, 0x03});//chn15
            hasht.Add("Chn16", new byte[] { 0xD0, 0x02});//chn16
            hasht.Add("Chn17", new byte[] { 0xD1, 0x01});//chn17
            hasht.Add("Chn18", new byte[] { 0xD2, 0x03});//chn18
            hasht.Add("Chn19", new byte[] { 0xD3, 0x04});//chn19
            hasht.Add("Chn20", new byte[] { 0xD4, 0x02});//chn20
            hasht.Add("Chn21", new byte[] { 0xD5, 0x02});//chn21
            hasht.Add("Chn22", new byte[] { 0xD6, 0x02});//chn22
            hasht.Add("Chn23", new byte[] { 0xD7, 0x03});//chn23
            hasht.Add("Chn24", new byte[] { 0xD8, 0x02});//chn24
            hasht.Add("Chn25", new byte[] { 0xD9, 0x03});//chn25
            hasht.Add("Chn26", new byte[] { 0xDA, 0x04});//chn26
            hasht.Add("Chn27", new byte[] { 0xDB, 0x02});//chn27
            hasht.Add("Chn28", new byte[] { 0xDC, 0x00});//chn28
            hasht.Add("Chn29", new byte[] { 0xDD, 0x02});//chn29
            hasht.Add("Chn30", new byte[] { 0xDE, 0x04});//chn30
            hasht.Add("Chn31", new byte[] { 0xDF, 0x04});//chn31
            hasht.Add("Chn32", new byte[] { 0xE0, 0x03});//chn32
            hasht.Add("Chn33", new byte[] { 0xE1, 0x01});//chn33
            hasht.Add("Chn34", new byte[] { 0xE2, 0x00});//chn34
            hasht.Add("Chn35", new byte[] { 0xE3, 0x04});//chn35
            hasht.Add("Chn36", new byte[] { 0xE4, 0x02});//chn36
            hasht.Add("Chn37", new byte[] { 0xE5, 0x02});//chn37
            hasht.Add("Chn38", new byte[] { 0xE6, 0x01});//chn38
            hasht.Add("Chn39", new byte[] { 0xE7, 0x03});//chn39
            hasht.Add("Chn40", new byte[] { 0xE8, 0x03});//chn40
            hasht.Add("Chn41", new byte[] { 0xE9, 0x02});//chn41
            hasht.Add("Chn42", new byte[] { 0xEA, 0x03});//chn42
            hasht.Add("Chn43", new byte[] { 0xEB, 0x04});//chn43
            hasht.Add("Chn44", new byte[] { 0xEC, 0x04});//chn44
            hasht.Add("Chn45", new byte[] { 0xED, 0x03});//chn45
            hasht.Add("Chn46", new byte[] { 0xEE, 0x03});//chn46
            hasht.Add("Chn47", new byte[] { 0xEF, 0x05});//chn47
            hasht.Add("Chn48", new byte[] { 0xF0, 0x04});//chn48
            hasht.Add("Chn49", new byte[] { 0xF1, 0x06});//chn49
            hasht.Add("Chn50", new byte[] { 0xF2, 0x01});//chn50
            hasht.Add("Chn51", new byte[] { 0xF3, 0x05});//chn51
            hasht.Add("Chn52", new byte[] { 0xF4, 0x03});//chn52
            hasht.Add("Chn53", new byte[] { 0xF5, 0x01});//chn53
            hasht.Add("Chn54", new byte[] { 0xF6, 0x02});//chn54
            hasht.Add("Chn55", new byte[] { 0xF7, 0x03});//chn55
            hasht.Add("Chn56", new byte[] { 0xF8, 0x04});//chn56
            hasht.Add("Chn57", new byte[] { 0xF9, 0x02});//chn57
            hasht.Add("Chn58", new byte[] { 0xFA, 0x01});//chn58
            hasht.Add("Chn59", new byte[] { 0xFB, 0x05});//chn59
            hasht.Add("Chn60", new byte[] { 0xFC, 0x02});//chn60
            hasht.Add("Chn61", new byte[] { 0xFD, 0x03});//chn61
            hasht.Add("Chn62", new byte[] { 0xFE, 0x03});//chn62
            hasht.Add("Chn63", new byte[] { 0xFF, 0x04});//chn63
            /*----
            //The parameter is caculate via S Curve Test
            hasht.Add("Chn0", new byte[] { 0xC0, 0x02 }); //chn0
            hasht.Add("Chn1", new byte[] { 0xC1, 0x02 });//chn1
            hasht.Add("Chn2", new byte[] { 0xC2, 0x04 });//chn2
            hasht.Add("Chn3", new byte[] { 0xC3, 0x02 });//chn3
            hasht.Add("Chn4", new byte[] { 0xC4, 0x03 });//chn4
            hasht.Add("Chn5", new byte[] { 0xC5, 0x03 });//chn5
            hasht.Add("Chn6", new byte[] { 0xC6, 0x01 });//chn6
            hasht.Add("Chn7", new byte[] { 0xC7, 0x01 });//chn7
            hasht.Add("Chn8", new byte[] { 0xC8, 0x03 });//chn8
            hasht.Add("Chn9", new byte[] { 0xC9, 0x02 });//chn9
            hasht.Add("Chn10", new byte[] { 0xCA, 0x02 });//chn10
            hasht.Add("Chn11", new byte[] { 0xCB, 0x03 });//chn11
            hasht.Add("Chn12", new byte[] { 0xCC, 0x01 });//chn12
            hasht.Add("Chn13", new byte[] { 0xCD, 0x03 });//chn13
            hasht.Add("Chn14", new byte[] { 0xCE, 0x02 });//chn14
            hasht.Add("Chn15", new byte[] { 0xCF, 0x01 });//chn15
            hasht.Add("Chn16", new byte[] { 0xD0, 0x02 });//chn16
            hasht.Add("Chn17", new byte[] { 0xD1, 0x02 });//chn17
            hasht.Add("Chn18", new byte[] { 0xD2, 0x02 });//chn18
            hasht.Add("Chn19", new byte[] { 0xD3, 0x03 });//chn19
            hasht.Add("Chn20", new byte[] { 0xD4, 0x02 });//chn20
            hasht.Add("Chn21", new byte[] { 0xD5, 0x02 });//chn21
            hasht.Add("Chn22", new byte[] { 0xD6, 0x02 });//chn22
            hasht.Add("Chn23", new byte[] { 0xD7, 0x02 });//chn23
            hasht.Add("Chn24", new byte[] { 0xD8, 0x02 });//chn24
            hasht.Add("Chn25", new byte[] { 0xD9, 0x02 });//chn25
            hasht.Add("Chn26", new byte[] { 0xDA, 0x03 });//chn26
            hasht.Add("Chn27", new byte[] { 0xDB, 0x01 });//chn27
            hasht.Add("Chn28", new byte[] { 0xDC, 0x01 });//chn28
            hasht.Add("Chn29", new byte[] { 0xDD, 0x02 });//chn29
            hasht.Add("Chn30", new byte[] { 0xDE, 0x02 });//chn30
            hasht.Add("Chn31", new byte[] { 0xDF, 0x02 });//chn31
            hasht.Add("Chn32", new byte[] { 0xE0, 0x02 });//chn32
            hasht.Add("Chn33", new byte[] { 0xE1, 0x02 });//chn33
            hasht.Add("Chn34", new byte[] { 0xE2, 0x01 });//chn34
            hasht.Add("Chn35", new byte[] { 0xE3, 0x03 });//chn35
            hasht.Add("Chn36", new byte[] { 0xE4, 0x01 });//chn36
            hasht.Add("Chn37", new byte[] { 0xE5, 0x01 });//chn37
            hasht.Add("Chn38", new byte[] { 0xE6, 0x01 });//chn38
            hasht.Add("Chn39", new byte[] { 0xE7, 0x01 });//chn39
            hasht.Add("Chn40", new byte[] { 0xE8, 0x00 });//chn40
            hasht.Add("Chn41", new byte[] { 0xE9, 0x01 });//chn41
            hasht.Add("Chn42", new byte[] { 0xEA, 0x01 });//chn42
            hasht.Add("Chn43", new byte[] { 0xEB, 0x01 });//chn43
            hasht.Add("Chn44", new byte[] { 0xEC, 0x01 });//chn44
            hasht.Add("Chn45", new byte[] { 0xED, 0x01 });//chn45
            hasht.Add("Chn46", new byte[] { 0xEE, 0x00 });//chn46
            hasht.Add("Chn47", new byte[] { 0xEF, 0x02 });//chn47
            hasht.Add("Chn48", new byte[] { 0xF0, 0x01 });//chn48
            hasht.Add("Chn49", new byte[] { 0xF1, 0x03 });//chn49
            hasht.Add("Chn50", new byte[] { 0xF2, 0x00 });//chn50
            hasht.Add("Chn51", new byte[] { 0xF3, 0x02 });//chn51
            hasht.Add("Chn52", new byte[] { 0xF4, 0x02 });//chn52
            hasht.Add("Chn53", new byte[] { 0xF5, 0x00 });//chn53
            hasht.Add("Chn54", new byte[] { 0xF6, 0x01 });//chn54
            hasht.Add("Chn55", new byte[] { 0xF7, 0x02 });//chn55
            hasht.Add("Chn56", new byte[] { 0xF8, 0x01 });//chn56
            hasht.Add("Chn57", new byte[] { 0xF9, 0x01 });//chn57
            hasht.Add("Chn58", new byte[] { 0xFA, 0x00 });//chn58
            hasht.Add("Chn59", new byte[] { 0xFB, 0x01 });//chn59
            hasht.Add("Chn60", new byte[] { 0xFC, 0x00 });//chn60
            hasht.Add("Chn61", new byte[] { 0xFD, 0x01 });//chn61
            hasht.Add("Chn62", new byte[] { 0xFE, 0x01 });//chn62
            hasht.Add("Chn63", new byte[] { 0xFF, 0x01 });//chn63
            */
        //# endregion
        /*}
        //without calibration
        private void chk_PedCali_UnChecked(object sender, RoutedEventArgs e)
        {
            hasht.Clear();
            hasht.Add("Chn0", new byte[] { 0xC0, 0x00});//chn0
            hasht.Add("Chn1", new byte[] { 0xC1, 0x00 });//chn1
            hasht.Add("Chn2", new byte[] { 0xC2, 0x00 });//chn2
            hasht.Add("Chn3", new byte[] { 0xC3, 0x00 });//chn3
            hasht.Add("Chn4", new byte[] { 0xC4, 0x00 });//chn4
            hasht.Add("Chn5", new byte[] { 0xC5, 0x00 });//chn5
            hasht.Add("Chn6", new byte[] { 0xC6, 0x00 });//chn6
            hasht.Add("Chn7", new byte[] { 0xC7, 0x00 });//chn7
            hasht.Add("Chn8", new byte[] { 0xC8, 0x00 });//chn8
            hasht.Add("Chn9", new byte[] { 0xC9, 0x00 });//chn9
            hasht.Add("Chn10", new byte[] { 0xCA, 0x00 });//chn10
            hasht.Add("Chn11", new byte[] { 0xCB, 0x00 });//chn11
            hasht.Add("Chn12", new byte[] { 0xCC, 0x00 });//chn12
            hasht.Add("Chn13", new byte[] { 0xCD, 0x00 });//chn13
            hasht.Add("Chn14", new byte[] { 0xCE, 0x00 });//chn14
            hasht.Add("Chn15", new byte[] { 0xCF, 0x00 });//chn15
            hasht.Add("Chn16", new byte[] { 0xD0, 0x00 });//chn16
            hasht.Add("Chn17", new byte[] { 0xD1, 0x00 });//chn17
            hasht.Add("Chn18", new byte[] { 0xD2, 0x00 });//chn18
            hasht.Add("Chn19", new byte[] { 0xD3, 0x00 });//chn19
            hasht.Add("Chn20", new byte[] { 0xD4, 0x00 });//chn20
            hasht.Add("Chn21", new byte[] { 0xD5, 0x00 });//chn21
            hasht.Add("Chn22", new byte[] { 0xD6, 0x00 });//chn22
            hasht.Add("Chn23", new byte[] { 0xD7, 0x00 });//chn23
            hasht.Add("Chn24", new byte[] { 0xD8, 0x00 });//chn24
            hasht.Add("Chn25", new byte[] { 0xD9, 0x00 });//chn25
            hasht.Add("Chn26", new byte[] { 0xDA, 0x00 });//chn26
            hasht.Add("Chn27", new byte[] { 0xDB, 0x00 });//chn27
            hasht.Add("Chn28", new byte[] { 0xDC, 0x00 });//chn28
            hasht.Add("Chn29", new byte[] { 0xDD, 0x00 });//chn29
            hasht.Add("Chn30", new byte[] { 0xDE, 0x00 });//chn30
            hasht.Add("Chn31", new byte[] { 0xDF, 0x00 });//chn31
            hasht.Add("Chn32", new byte[] { 0xE0, 0x00 });//chn32
            hasht.Add("Chn33", new byte[] { 0xE1, 0x00 });//chn33
            hasht.Add("Chn34", new byte[] { 0xE2, 0x00 });//chn34
            hasht.Add("Chn35", new byte[] { 0xE3, 0x00 });//chn35
            hasht.Add("Chn36", new byte[] { 0xE4, 0x00 });//chn36
            hasht.Add("Chn37", new byte[] { 0xE5, 0x00 });//chn37
            hasht.Add("Chn38", new byte[] { 0xE6, 0x00 });//chn38
            hasht.Add("Chn39", new byte[] { 0xE7, 0x00 });//chn39
            hasht.Add("Chn40", new byte[] { 0xE8, 0x00 });//chn40
            hasht.Add("Chn41", new byte[] { 0xE9, 0x00 });//chn41
            hasht.Add("Chn42", new byte[] { 0xEA, 0x00 });//chn42
            hasht.Add("Chn43", new byte[] { 0xEB, 0x00 });//chn43
            hasht.Add("Chn44", new byte[] { 0xEC, 0x00 });//chn44
            hasht.Add("Chn45", new byte[] { 0xED, 0x00 });//chn45
            hasht.Add("Chn46", new byte[] { 0xEE, 0x00 });//chn46
            hasht.Add("Chn47", new byte[] { 0xEF, 0x00 });//chn47
            hasht.Add("Chn48", new byte[] { 0xF0, 0x00 });//chn48
            hasht.Add("Chn49", new byte[] { 0xF1, 0x00 });//chn49
            hasht.Add("Chn50", new byte[] { 0xF2, 0x00 });//chn50
            hasht.Add("Chn51", new byte[] { 0xF3, 0x00 });//chn51
            hasht.Add("Chn52", new byte[] { 0xF4, 0x00 });//chn52
            hasht.Add("Chn53", new byte[] { 0xF5, 0x00 });//chn53
            hasht.Add("Chn54", new byte[] { 0xF6, 0x00 });//chn54
            hasht.Add("Chn55", new byte[] { 0xF7, 0x00 });//chn55
            hasht.Add("Chn56", new byte[] { 0xF8, 0x00 });//chn56
            hasht.Add("Chn57", new byte[] { 0xF9, 0x00 });//chn57
            hasht.Add("Chn58", new byte[] { 0xFA, 0x00 });//chn58
            hasht.Add("Chn59", new byte[] { 0xFB, 0x00 });//chn59
            hasht.Add("Chn60", new byte[] { 0xFC, 0x00 });//chn60
            hasht.Add("Chn61", new byte[] { 0xFD, 0x00 });//chn61
            hasht.Add("Chn62", new byte[] { 0xFE, 0x00 });//chn62
            hasht.Add("Chn63", new byte[] { 0xFF, 0x00 });//chn63
        }*/
        #endregion

        /*private void chk_PedCali_ASIC1_Checked(object sender, RoutedEventArgs e)
        {
            CaliHashTable[1].Clear();
            CaliHashTable[1]

        }

        private void chk_PedCali_ASIC2_Checked(object sender, RoutedEventArgs e)
        {

        }

        private void chk_PedCali_ASIC3_Checked(object sender, RoutedEventArgs e)
        {

        }



        private void chk_PedCali_ASIC4_Checked(object sender, RoutedEventArgs e)
        {

        }

        private void chk_PedCali_ASIC1_Unchecked(object sender, RoutedEventArgs e)
        {

        }

        private void chk_PedCali_ASIC2_Unchecked(object sender, RoutedEventArgs e)
        {

        }

        private void chk_PedCali_ASIC3_Unchecked(object sender, RoutedEventArgs e)
        {

        }

        private void chk_PedCali_ASIC4_Unchecked(object sender, RoutedEventArgs e)
        {

        }*/
    }
}
