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
        private string rx_Command= @"\b[0-9a-fA-F]{4}\b";//match 16 bit Hex
        private string rx_Byte = @"\b[0-9a-fA-F]{2}\b";//match 8 bit Hex
        private string rx_Integer = @"^\d+$";   //匹配非负 整数
        //private string rx_Float = @"^\d+(\.\d{1,3})?$";//小数可有可无最多3位小数 
        private string filepath = null;//文件路径
        private static bool AcqStart = false; //采集标志
        private static bool Enabled_Ext_Trigger = false;
        private static bool ScurveStart_En = false;
       // private static bool SPopen = false; //串口是否打开
       // private SerialPort mySerialPort = new SerialPort();//新建串口
        private static int Packetcnt;
        private BinaryWriter bw;
        private Sync_Thread_Buffer threadbuffer = new Sync_Thread_Buffer(16384*512);
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
        private const int Single_SCurve_Data_Length = 7171 * 2;
        private const int AllChn_SCurve_Data_Length = 458818 * 2;
        private const int SCurve_Package_Length = 512;
        private static int Scurve_Data_Pkg;
        private static int Scurve_Data_Remain;
        private NoSortHashtable hasht = new NoSortHashtable(); //排序之后的哈希表
        public MainWindow()
        {

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
            if (button.Content.ToString() == "SC")
            { 
                btnSC_or_ReadReg.Content = "Slow control";
                btnSC_or_ReadReg.Background = Brushes.GreenYellow;
                txtRead_reg.IsEnabled = false;
                txtDAC0_VTH.IsEnabled = true;
                txtDAC1_VTH.IsEnabled = true;
                txtDAC2_VTH.IsEnabled = true;
                txtHeader.IsEnabled = true;
                txtCTest.IsEnabled = true;

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
            else if (button.Content.ToString() == "ReadReg")
            {             
                btnSC_or_ReadReg.Content = "Read Register";
                btnSC_or_ReadReg.Background = Brushes.Orange;
                txtRead_reg.IsEnabled = true;
                txtDAC0_VTH.IsEnabled = false;
                txtDAC1_VTH.IsEnabled = false;
                txtDAC2_VTH.IsEnabled = false;
                txtHeader.IsEnabled = false;
                txtCTest.IsEnabled = false;
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
        }
        private void btnSC_or_ReadReg_Click(object sender, RoutedEventArgs e)
        {
            //if there is a slow control operation
            bool bResult = false;
            if ((string)btnSC_or_ReadReg.Content == "Slow control")
            {
                Regex rx_int = new Regex(rx_Integer);
                bool Is_DAC_legal = rx_int.IsMatch(txtDAC0_VTH.Text) && rx_int.IsMatch(txtDAC1_VTH.Text) && rx_int.IsMatch(txtDAC2_VTH.Text);
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
                }
                //*************** Header**********************//
                Regex rx_b = new Regex(rx_Byte);
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
                }
                /*-------------CText--------------*/
                bool Is_Ctest_legal = rx_int.IsMatch(txtCTest.Text);
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
                }
                //------------------sw_hg and sw_lg---------------------------//
                int value_hg = cbxsw_hg.SelectedIndex * 16;
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
                }
                //-----------------Out_sh, high gain shaper or low gain shaper-----------//
                int value_out_sh = cbxOut_sh.SelectedIndex + 192; //要不要加1？
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
                }
                //------------------Internal RAZ Mode Select ----------------------------//
                int value_Internal_RAZ_Time = cbxInternal_RAZ_Time.SelectedIndex + 176;//0xB0
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
                }
                //----------------------- Select shaper output enable --------------------//
                int value_Shaper_Output_Enable = cbxShaper_Output_Enable.SelectedIndex + 208;
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
                }
            }
            //-----if there is Read Register opertation
            else if ((string)btnSC_or_ReadReg.Content == "Read Register")
            {
                Regex rx_int = new Regex(rx_Integer);
                bool Is_ReadReg_legal = rx_int.IsMatch(txtRead_reg.Text);
                if (Is_ReadReg_legal)
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
                }
            }
            /*----------------ASIC number and start load---------------------*/
            int value = cbxASIC_Number.SelectedIndex + 176 + 1;
            byte[] com_bytes = new byte[2];
            com_bytes = ConstCommandByteArray(0xA0,(byte)(value));
            bResult = CommandSend(com_bytes, com_bytes.Length);
            if (bResult)
            {
                string report = string.Format("ASIC quantity : {0}\n", cbxASIC_Number.Text);
                txtReport.AppendText(report);
            }
            else
            {
                MessageBox.Show("set ASIC quantity failure, please check USB", //text
                                 "USB Error",   //caption
                                 MessageBoxButton.OK,//button
                                 MessageBoxImage.Error);//icon
            }
            //---start load
            com_bytes = ConstCommandByteArray(0xD0, 0xA2);
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
            }
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
                    MessageBox.Show("set StartAcq Time failure, please check USB", //text
                                     "USB Error",   //caption
                                     MessageBoxButton.OK,//button
                                     MessageBoxImage.Error);//icon
                }
                bytes = ConstCommandByteArray(0xB1, (byte)(value));
                bResult = CommandSend(bytes, bytes.Length);
                if (bResult)
                {
                    string report = string.Format("set StartAcq Time : {0}\n", txtStartAcqTime.Text);
                    txtReport.AppendText(report);
                }
                else
                {
                    MessageBox.Show("set StartAcq Time failure, please check USB", //text
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
        private void ACQ_or_SCTest_Checked(object sender, RoutedEventArgs e)
        {
            var botton = sender as RadioButton;
            bool bResult = false;
            if(botton.Content.ToString() == "ACQ") //这里已经直接将通道都切换过去
            {
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
        }
        //E0B0选择单通道测试，E0B1选择64通道测试，这里决定要获取的数据长度
        private void Single_or_64Chn_Checked(object sender, RoutedEventArgs e)
        {
            var botton = sender as RadioButton;
            bool bResult = false;
            if (botton.Content.ToString() == "Single")
            {
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
                Scurve_Data_Pkg = Single_SCurve_Data_Length / SCurve_Package_Length;
                Scurve_Data_Remain = Single_SCurve_Data_Length % SCurve_Package_Length;
            }
            else if (botton.Content.ToString() == "Auto")
            {
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
                Scurve_Data_Pkg = AllChn_SCurve_Data_Length / SCurve_Package_Length;
                Scurve_Data_Remain = AllChn_SCurve_Data_Length % SCurve_Package_Length;
            }
        }
        //E0C0:单通道测试时从CTest管脚输入,E0C1单通道测试从direct input输入
        private void CTest_or_Input_Checked(object sender, RoutedEventArgs e)
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
        }

        private void btnSet_SCT_Param_Click(object sender, RoutedEventArgs e)
        {
            /*-------------- Set the single test channel -------------------*/
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
            /*---------------------- Set the max counter--------------------------*/
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
        }
        //--Scurve测试开始E0F0,Scurve测试结束E0F1--//
        private void btnScurve_start_Click(object sender, RoutedEventArgs e)
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
        }
        private void Get_ScurveResultCallBack()
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
            /*for (int i = 0; i < Scurve_data_pkg; i++)
            {
                bResult = DataRecieve(bytes, bytes.Length);
                if (bResult)
                {
                    bw.Write(bytes); //接收成功写入文件,写文件很慢，没事可以等
                }
            }*/
            /*byte[] test = new byte[512];
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
            }*/
            //---------------------------------------//
            //bw.Flush();
            bw.Dispose();
            bw.Close();
            //report = string.Format("data stored in {0}\n", filepath);
            //Dispatcher.Invoke(dp2, report);
        }
        //control channel calibration
        private void btnChnCali_Click(object sender, RoutedEventArgs e)
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
        }
        //load channel calibration parameter
        
        private void chk_PedCali_Checked(object sender, RoutedEventArgs e)
        {
            hasht.Clear();
            /*
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
            hasht.Add("Chn63", new byte[] { 0xFF, 0x04});//chn63*/
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
        }
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
        }
    }
}
