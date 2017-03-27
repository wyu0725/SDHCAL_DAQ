# SDHCAL工作日志

------
## **上位机命令集合**

+ 控制命令

+ F0F0:开始

+ F0F1:停止

+ B00X:Led灯

+ Microroc命令

+ A类：配置参数，设置好之后基本不需改动

+ A0A0:输出SC参数

+ A0A1:输出Read Register参数

+ A0BX:Microroc片数

+ A0C0:High gain shaper 输出

+ A0C1:Low gain shaper 输出

+ A0D0:Disable Selected shaper output OTA

+ A0D1:Enable Selected shaper output OTA

+ A1XX:使能XX通道Ctest

+ A2XX:选通XX通道Read register

+ A3A0:Power pulse unenable

+ A3A1:Power pulse enable

+ A4A0:select channel 2 to readout

+ A4A1:select channel 1 to readout

+ A5AX:

+ A6XX:

+ A7A1:清零Gray Counter

+ > 新添加的命令20170309

+ A8A0:Enable internal raz_chn and disable external raz_chn

+ A8A1:Disable internal raz_chn and enable external raz_chn

+ A8BX:X --> Internal RAZ mode select

+ A8CX:X --> External RAZ mode select

+ A8DX:X*25ns --> External RAZ delay time:delay time指的是trigger输出之后，多长时间之后FPGA才开始输出RAZ信号

+ > 新添加的命令结束20170309

+ A9A0:External trigger unenable

+ A9A1:External trigger enable

+ >  这条命令没用了AAAX:Raz mode select

+ ABXX:XX id Chip ID

+ > 新添加的命令 20170308

+ ACA0:SC336=> Select latched

+ ACA1:SC336=>Select direct output

+ ACB0:SC575=>Select Channel Trigger selected by Read Register

+ ACB1:SC575=>Select Channel Trigger selected by NOR64

+ > 新添加命令结束 20170308

+ B类：采集参数，可以调整
  + B1XX:XX为Start_Acq_Time的低八位
  + B2YY:YY为Start_Acq_Time的高八位，YYXX*25ns为Start_Acq的时间
  + B3XY: X:sw_hg<1:0>, sw_lg<1:0>

+ C类：10-bit DAC和4-bit DAC码值设置
  + CXXX:10-bit DAC Code(这里是需要修改的) C000~CBFF
  + CC00~CFFF:4-bit DAC Code
    详细说明一下:
  + 从CC0X开始到CCFX，这里一共16个命令为1~16通道的4-bit DAC码值
  + 从CD0X开始到CDFX，16个命令为17~32通道的码值
  + CE0X~~~CEFX：33~48
  + CF0X~~~CFFX：49~64   

+ D类：开始停止命令
  + D0A2:向芯片载入SC参数
  + D1Bx:选择哪个ASIC上out_T&H输出
  + D2F0:选择监控测试板上的功耗
  + D2F1:选择监控测试板上的out_T&H（默认）

+ E类：S曲线测试(还没有完成，这段代码目前在新的逻辑中)
  + E0A0:选择ACQ
  + E0A1:选择S Curve Test
  + E0B0:选择单通道测试
  + E0B1:选择64通道测试
  + E0C0:单通道测试时从Ctest管脚输入信号
  + E0C1:单通道测试时选择从Input管脚输入信号
  + E0F0:SCurve 测试开始命令
  + E0F1:SCurve测试结束命令
  + E1XX:XX为单通道测试时的通道号
  + E2XX:选择最大计数：
    + 00：200
    + 01：1000
    + 02：2000
    + 03：5000
    + 04：10000
    + 05：20000
    + 06：40000
    + 07：50000
  + ​


## 2016/12/09

+ B板连接器焊接完好
+ 添加如下debug
  ```verilog
  	(*mark_debug = "true"*)wire start_debug;
  	(*mark_debug = "true"*)wire End_Readout_debug;
  	(*mark_debug = "true"*)wire Chipsatb_debug;
  	(*mark_debug = "true"*)wire Reset_b_debug;
  	(*mark_debug = "true"*)wire Start_Acq_debug;
  	(*mark_debug = "true"*)wire Start_Readout_debug;
  	(*mark_debug = "true"*)wire Pwr_on_a_debug;
  	(*mark_debug = "true"*)wire Pwr_on_d_debug;
  	(*mark_debug = "true"*)wire Pwr_on_dac_debug;
  	(*mark_debug = "true"*)wire Once_end_debug;
  	assign start_debug = start;
  	assign End_Readout_debug = End_Readout;
  	assign Chipsatb_debug = Chipsatb;
  	assign Reset_b_debug = Reset_b;
  	assign Start_Acq_debug = Start_Acq;
  	assign Start_Readout_debug = Start_Readout;
  	assign Pwr_on_a_debug = Pwr_on_a;
  	assign Pwr_on_d_debug = Pwr_on_d;
  	assign Pwr_on_dac_debug = Pwr_on_dac;
  	assign Once_end_debug = Once_end;
  ```
+ 没有TransmitOn信号

> 没有TransmitOn信号的原因是没有给trigger，无法写入RAM

## 2016/12/13
+ RAM读数时序正确
+ 三个问题
  1. Dout在低电平输出时，信号会慢慢升高，高过CMOS低电平阈值时，便会出现错误。Header为FF时就会有这样的情况
     ![header = ff](http://ogs54iji1.bkt.clouddn.com/header_ff_Dout_TransmitOn.jpg_SDHCAL)
     ![header = ff](http://ogs54iji1.bkt.clouddn.com/header_ff_All.jpg_SDHCAL)
     ![header = aa](http://ogs54iji1.bkt.clouddn.com/header_55_Dout_TransmitOn.jpg_SDHCAL)
  2. USB采到的数据，第一个总是0000
  3. USB数据高8位和低8位没有交换过来
+ Trigg_Gen中的RST_COUNTERB输出有问题，修改中
+ 在服务器上的程序是最新的，去掉了所有的debug信号
+ 所有芯片的上拉电阻都被焊上，也就是说上拉电阻现在已经变成250Ω

> 待解决问题：改写RAMReadout模块
> USB写数第一个是0000
> USB数据高8位和低八位颠倒

## 2016/12/14
+ RamReadOut改写完成，仿真正确
+ 汇报PPT初稿完成
+ ​
### 待解决问题
+ 如何使BCID变化 => 在一次Start_Acq中产生两次trigger
  + 从Start_Acq到ChipSatb有多长时间？
  + BCID是如何变化的，是不是在一个Start_Acq内进行计数？
  > 已解决，原代码一直在输出有效的RST_COUNTERB
  > 上位机发送一个rst_counterb正脉冲即可，FPGA会输出一个1us的清零信号

### 新的问题
+ TransmitOn有毛刺，由于昨天的问题一，导致TransmitOn在Dout为低电平时会上涨，最终带来毛刺
+ 下图中蓝线为FPGA得到的TransmitOn，红线是示波器测到管脚上的TransmitOn
  ![header == 48  1周期](http://ogs54iji1.bkt.clouddn.com/header_48_asic.jpg-SDHCAL)
  ![header == 48  放大](http://ogs54iji1.bkt.clouddn.com/header_48_asic1.jpg-SDHCAL)
  ![header == 55  1周期](http://ogs54iji1.bkt.clouddn.com/header_55_asic.jpg-SDHCAL)
  ![header == 55  放大](http://ogs54iji1.bkt.clouddn.com/header_55_asic1.jpg-SDHCAL)
+ 将Dout2b和TransmitOn2b的上拉电阻换成4.02k得到下图
  + 红色的是Dout2b，蓝色的是Dout1b，绿线和黄线分别是FPGA输出的Start_Acq和FPGA得到的Dout
    ![header == 55  1周期](http://ogs54iji1.bkt.clouddn.com/SDHCALheader_55_asic_ch2-dout-1.jpg-SDHCAL)
    ![header == 55  放大](http://ogs54iji1.bkt.clouddn.com/SDHCALheader_55_asic_ch2-dout-2.jpg-SDHCAL)
  + 红色的是TransmitOn2b，蓝色的是TransmitOn1b，可以看到，上拉电阻加大之后，上升沿变缓了，而问题得不到改善
    ![header == 55  1周期](http://ogs54iji1.bkt.clouddn.com/SDHCALheader_55_asic_ch2-TransmitOn-1.jpg-SDHCAL)
    ![header == 55  放大](http://ogs54iji1.bkt.clouddn.com/SDHCALheader_55_asic_ch2-TransmitOn-2.jpg-SDHCAL)

## 2016/12/15
+ 汇报PPT
+ 测量其他管脚问题依旧存在

## 2016/12/16
+ PWR_ON_D, PWR_ON_A, PWR_ON_DAC一直为高电平，问题依旧存在
+ [汇报](http://ogs54iji1.bkt.clouddn.com/SlideDHCAL工作汇报20161216.pptx-SDHCAL)
+ 再焊一块测试板
  + 测试板上的配置电压完全按照芯片手册设置

+ 不用配置电阻
+ RTN管脚一定要很好的接地


## 2016/12/19
+ 芯片的header LSB先输出，而BCID是MSB先输出
+ 在USB命令解析模块中写入header时，将高位和低位交换一下写入
+ Ctest管脚输入电荷没有采集到信号，同时out_q管脚和out_fsb管脚也没有输出，应该是配置参数设置的问题

> **上位机命令集合**
> + 控制命令
	+ F0F0:开始
	+ F0F1:停止
> + B00X:Led灯
> + Microroc命令
> + A类：配置参数，设置好之后基本不需改动
	+ A0A0:输出SC参数
	+ A0A1:输出Read Register参数
	+ A0BX:Microroc片数
	+ A1XX:使能XX通道Ctest
	+ A2XX:选通XX通道Read register
	+ A3A0:Power pulse unenable
	+ A3A1:Power pulse enable
	+ A4A0:select channel 2 to readout
	+ A4A1:select channel 1 to readout
	+ A5AX:
	+ A6XX:
	+ A7A1:清零Gray Counter
	+ A8A0:raz_chn unenable
	+ A8A1:raz_chn enable
	+ A9A0:External trigger unenable
	+ A9A1:External trigger enable
	+ AAAX:Raz mode select
	+ ABXX:XX id Chip ID
+ B类：采集参数，可以调整
  + B1XX:XX*25ns为Start_Acq有效时间（默认值最小值为8）
  + B2XY: X:sw_hg<1:0>, sw_lg<1:0>
  + CXXX:10-bit DAC Code(这里是需要修改的)
  + D0A2:向芯片载入SC参数


## 2016/12/20

+ 选通Ctest后还需要在read register选通输出通道，发现out_q和out_fsb没有输出
+ 新版上位机可以使用
+ 在USB命令解析模块中，将ADC的低位和高位交换一下写入





## 2016/12/21

+ B板在

+ 重新测了一组DAC的码值和输出电压关系，发现线性还是不好，码值和电压对应如下

### 原来焊接的测试板，称之为A板

| 码值   | Vth0\测量值(V)      | Vth1\测量值(V)      | Vth2\测量值(V)      |
| ---- | ---------------- | ---------------- | ---------------- |
| 0    | C000    $0.8270$ | C400    $0.8229$ | C800    $0.8270$ |
| 127  | C07F    $1.0995$ | C47F    $1.0931$ | C87F    $1.0995$ |
| 255  | C0FF    $1.3776$ | C4FF    $1.3678$ | C8FF    $1.3776$ |
| 383  | C17F    $1.6670$ | C57F    $1.6441$ | C97F    $1.6533$ |
| 511  | C1FF    $1.9471$ | C5FF    $1.9189$ | C9FF    $1.9315$ |
| 639  | C27F    $2.2253$ | C67F    $2.1919$ | CA7F    $2.2039$ |
| 767  | C2FF    $2.4985$ | C6FF    $2.4607$ | CAFF    $2.4762$ |
| 895  | C37F    $2.7355$ | C77F    $2.7199$ | CB7F    $2.7365$ |
| 1023 | C3FF    $2.7475$ | C7FF    $2.7420$ | CBFF    $2.7668$ |

+ 最后一组1023对应的码值已经不线性了，在线性拟合时应当把它剔除去除最后一组码值后线性拟合曲线如下
  + ![Vth0 A Board](http://ogs54iji1.bkt.clouddn.com/SDHCALVth0_ABoard.jpg-SDHCAL)
  + ![Vth1 A Board](http://ogs54iji1.bkt.clouddn.com/SDHCALVth1_ABoard.jpg-SDHCAL)
  + ![Vth2 A Board](http://ogs54iji1.bkt.clouddn.com/SDHCALVth2_ABoard.jpg-SDHCAL)

### 新焊接的板，称之为B板

| 码值   | Vth0\测量值(V)      | Vth1\测量值(V)      | Vth2\测量值(V)      |
| ---- | ---------------- | ---------------- | ---------------- |
| 0    | C000    $0.8323$ | C400    $0.8346$ | C800    $0.8326$ |
| 127  | C07F    $1.1070$ | C47F    $1.1099$ | C87F    $1.1082$ |
| 255  | C0FF    $1.3867$ | C4FF    $1.3887$ | C8FF    $1.3871$ |
| 383  | C17F    $1.6706$ | C57F    $1.6702$ | C97F    $1.6693$ |
| 511  | C1FF    $1.9505$ | C5FF    $1.9492$ | C9FF    $1.9485$ |
| 639  | C27F    $2.2235$ | C67F    $2.2285$ | CA7F    $2.2268$ |
| 767  | C2FF    $2.4965$ | C6FF    $2.4990$ | CAFF    $2.4988$ |
| 895  | C37F    $2.7287$ | C77F    $2.7177$ | CB7F    $2.7432$ |
| 1023 | C3FF    $2.7391$ | C7FF    $2.7275$ | CBFF    $2.7553$ |

+ 依然最后一组码值对应电压已经偏离线性范围
  + ![Vth0 B Board](http://ogs54iji1.bkt.clouddn.com/SDHCALVth0_BBoard.jpg-SDHCAL)
  + ![Vth1 B Board](http://ogs54iji1.bkt.clouddn.com/SDHCALVth1_BBoard.jpg-SDHCAL)
  + ![Vth2 B Board](http://ogs54iji1.bkt.clouddn.com/SDHCALVth2_BBoard.jpg-SDHCAL)

### 将B板的PIN 73通过200kΩ电阻上拉到V_bg后
| 码值   | Vth0\测量值(V)      | Vth1\测量值(V)      | Vth2\测量值(V)      |
| ---- | ---------------- | ---------------- | ---------------- |
| 0    | C000    $0.9317$ | C400    $0.9339$ | C800    $0.9315$ |
| 127  | C07F    $1.1085$ | C47F    $1.1112$ | C87F    $1.1091$ |
| 255  | C0FF    $1.2888$ | C4FF    $1.2910$ | C8FF    $1.2891$ |
| 383  | C17F    $1.4711$ | C57F    $1.4727$ | C97F    $1.4719$ |
| 511  | C1FF    $1.6515$ | C5FF    $1.6527$ | C9FF    $1.6526$ |
| 639  | C27F    $1.8289$ | C67F    $1.8332$ | CA7F    $1.8315$ |
| 767  | C2FF    $2.0096$ | C6FF    $2.0134$ | CAFF    $2.0119$ |
| 895  | C37F    $2.1925$ | C77F    $2.1947$ | CB7F    $2.1937$ |
| 1023 | C3FF    $2.3705$ | C7FF    $2.3717$ | CBFF    $2.3717$ |
+ 所有的码值都没有明显偏离
  + ![Vth0 B Board new](http://ogs54iji1.bkt.clouddn.com/SDHCALVth0_BBoard_P73_200k2Vbg.jpg-SDHCAL)
  + ![Vth1 B Board new](http://ogs54iji1.bkt.clouddn.com/SDHCALVth1_BBoard_P73_200k2Vbg.jpg-SDHCAL)
  + ![Vth2 B Board new](http://ogs54iji1.bkt.clouddn.com/SDHCALVth2_BBoard_P73_200k2Vbg.jpg-SDHCAL)

## 2016/12/22
+ 修改了DaqControl的逻辑，使得Start_Acq的时间是固定的
+ 新的上位机
+ 数据拿到了，out_fsb上有波形了
  + ![Out_fsb 1V@20dB](http://ogs54iji1.bkt.clouddn.com/SDHCALout_fsb_20dB.jpg-SDHCAL)
  + ![Out_fsb 1V@20dB](http://ogs54iji1.bkt.clouddn.com/SDHCALout_fsb1_20dB.jpg-SDHCAL)
  + ![Out_fsb 1V@10dB](http://ogs54iji1.bkt.clouddn.com/SDHCALout_fsb_10dB.jpg-SDHCAL)
  + ![Out_fsb 1V@10dB](http://ogs54iji1.bkt.clouddn.com/SDHCALout_fsb1_10dB.jpg-SDHCAL)

+ 上位机也可以采到数据了，数据格式和datasheet一致
+ 问题
  + out_q没有输出
  + out_fsb的基准电压不是2.2V，而是1.5V的样子，和datasheet不一致
  + 每个通道其实是有一定的噪声的，所以4-bits DAC修正是必须的，后面再考虑
  + BCID并不是顺序的

## 2016/12/26
+ 需要增加的功能：
  + 4-bit DAC用起来，增加上位机命令
  + 观测out_trig0~3的波形，hold信号应当是当这三个信号到来之后的某一个时刻开始产生
+ 增加功能
  + 4-bits DAC码值控制，out_fsb上看不出来，但是SC参数中可以看到正确的配置进去了。波形上看不出来的原因是码值对应的电压变化太小了，最多才10mV
  + 修改通道1的4bit DAC值，得到如下的SC参数变化，命令是正确的![SC 参数，Ch0 4-bitDAC值被修改](http://ogs54iji1.bkt.clouddn.com/SDHCALSC_4bitDAC1.jpg-SDHCAL)
  + out_fsb和out_trig0的关系![out_fsb和out_trig0的关系](http://ogs54iji1.bkt.clouddn.com/SDHCALInject_Start_trig2.jpg-SDHCAL)out_trig0大概比脉冲峰值早100ns时间
  + 这个图上还有一个信息是值得注意的![Start_Acq有效时来了几个脉冲就会有多少个数据被读出](http://ogs54iji1.bkt.clouddn.com/SDHCALInject_Start_trig.jpg-SDHCAL)图中绿色为Start_Acq信号，在其有效时来了四个电荷输入(红色)，在数据读出时就会读出四个数据 ![Start_Acq有效时来了几个脉冲就会有多少个数据被读出](http://ogs54iji1.bkt.clouddn.com/SDHCALInject_Start_trig1.jpg-SDHCAL)
+ hold信号是怎么样的
+ hold多长时间？
+ 示波器可以接上Samba服务器，图片方便传出，明天用树莓派挂载优盘从新建一个专用的服务器

## 2016/12/27
+ 比较out_trig0b, out_trig1b, out_trig2b输出是否是同时的（想来应当不是，阈值不同）
+ 修改hold信号产生的逻辑，out_trig信号下降沿到hold信号产生有太大的延时了

+ 修改
  + Hold_Gen模块，减小从out_trig下降沿到hold信号有效的延迟，延迟减小为50ns
  + 芯片的管脚数错了

+ hold信号可以正常输出了
  ![hold 信号有输出](http://ogs54iji1.bkt.clouddn.com/SDHCALInject_Start_trig1.jpg-SDHCAL)
  ![hold 信号有输出](http://ogs54iji1.bkt.clouddn.com/SDHCALInject_Start_trig2.jpg-SDHCAL)
+ out_q信号是有输出的
  ![hold 信号有输出](http://ogs54iji1.bkt.clouddn.com/SDHCALHold25_outq_inject_start.jpg-SDHCAL)
  ![hold 信号有输出](http://ogs54iji1.bkt.clouddn.com/SDHCALHold25_outq_inject_start1.jpg-SDHCAL)
  ![hold 信号有输出](http://ogs54iji1.bkt.clouddn.com/SDHCALHold_outq_inject_start.jpg-SDHCAL)

+ 问题
  + hold住的电平是不正确的，按照分析，hold信号到来的时候，输出就是当时的电荷信号，但是从波形上看并不是
  + Hold时间设置成0有问题，会使得hold信号有一个较大的延后![hold 信号有输出](http://ogs54iji1.bkt.clouddn.com/SDHCALHold_outq_inject_start.jpg-SDHCAL)
  + 似乎hold信号只是决定了什么时候输出电荷信号，而对电荷的大小没有什么影响

## 2016/12/28
+ 习题课PPT，今日没测
+ hold信号保持的是Low Gain Shaper输出的波形，而out_fsb输出的波形不确定是哪个shaper的输出，所以从数据手册之中找到这个信息

## 2016/12/29
+ 昨晚的猜想是对的，对SC参数不够熟悉，SC参数中有一位是控制out_fsb输出的，第72个SC参数
  > SC 72:Select analogue Shaper output: Low Gain (1) or High Gain (0)
+ 修改：
  + 在USB命令中加入一条选择shaper输出的命令
  + 在USB中添加Enable Shaper OTA的命令

+ 选择low gain shaper时,输出如下![Low Gain Shaper Out](http://ogs54iji1.bkt.clouddn.com/SDHCALlow gain.jpg-SDHCAL)
+ 选择high gain shaper时，输出如下![High Gain Shaper Out](http://ogs54iji1.bkt.clouddn.com/SDHCALhigh gain.jpg-SDHCAL)
+ 问题：
  + high gain 和low gain shaper输出明显反了，是datasheet错误还是我们理解有误？
  + 基线依旧不对

+ 汇报ppt
+ 今天发现MATLAB代码的管理极其混乱，将所有的MATLAB代码存放在实验室台式机的MATLAB_workspace中

## 2016/12/30
+ 汇报
+ 设计一个转接板，一个SMA转接成32路
+ 配置电压似乎是正确的。。。

## 2017/01/03
+ 电荷输入板原理图

## 2017/01/04
+ 电荷输入板完成，1转32路

## 2017/01/05
+ 电荷输入电容100pF太大了，改成1pF，1拖32完全没问题
+ 已投板
+ 发现实际测量到的输出信号和MATLAB计算的值查了一个数量级，可能是推公式中，换算量纲的时候错了
+ Datasheet的Low Gain 和High Gain shaper输出应该是写反了
  + ![DataSheetShaperoutput](http://ogs54iji1.bkt.clouddn.com/SDHCALDataSheetShaperoutput.png-SDHCAL)

## 2017/01/09
+ 目前的问题总结
  1. out_sh基线问题
  2. out_q信号和hold信号没有对应上
  3. 300fC输入时，信号开始变形，底部有一点被削了

## 2017/01/10
+ out_sh问题解决，运放输入端被错误的连接了一个453Ω电阻，去掉就正确了
+ out_q保持的是low gain shaper的输出，因此看是否hold住时应该选择low gain shaper输出
+ 出现的问题
  + out_trig的输出有延迟，红线是low gain shaper输出，黄线是out_trigger2b输出，out_trigger2b并没有在shaper输出过阈的时候输出，而是有一个延迟![out_trigger2b并不是在刚好过阈时输出的](http://ogs54iji1.bkt.clouddn.com/SDHCALlgShaper_Start_outtrig2_hold6.jpg-SDHCAL)
  + out_trigger0b也是这样![out_trigger0b并不是在刚好过阈时输出的](http://ogs54iji1.bkt.clouddn.com/SDHCALR_outtrig0b-B_outfsbHG1.jpg-SDHCAL)
  + out_trigger1b![out_trigger0b并不是在刚好过阈时输出的](http://ogs54iji1.bkt.clouddn.com/SDHCALR_outtrig1b-B_outfsbHG1.jpg-SDHCAL)
  + out_trigger0,1,2b输出几乎同时，黄色：out_trigger0b，红色：out_trigger1b，蓝色：out_trigger2b![out_trigger0,1,2b输出几乎同时](http://ogs54iji1.bkt.clouddn.com/SDHCALY_outrig0b-R_outtrig1b-B_outtrig2b.jpg-SDHCAL)

+ 正在进行的测试
  + 输入不同幅度的电荷，然后用示波器测量shaper输出的最小幅度，是否线性
  + 从20fC开始，每隔20fC测一个点，得到如下的结果![Charge vs High gain shaper out](http://ogs54iji1.bkt.clouddn.com/Charge_vs_ShaperOut.jpg-SDHCAL)![Charge vs High gain shaper out](http://ogs54iji1.bkt.clouddn.com/Deviation_Charge_vs_ShaperOut.jpg-SDHCAL)

## 2017/01/11
+ 下一步进行的测试
  1. 示波器测试：
     + sw_hg选择不同的参数，测量在该参数下注入电荷量和成形输出$\Delt V$的线性。
     + 需要注意的问题是：探测器电容对输出是有影响的；不同的注入电荷实际上会造成成形时间的波动。
     + 可以变化的参数：输入电荷量、探测器电容、sw_hg
  2. 64通道基线电压一致性
     + 64通道的HG shaper和LG shaper在没有电荷注入情况下，基线电压的一致性
     + 经过4bit DAC修正后，将各个通道的基线电压差异性减小。
     + 向平均值修正还是向其他某一个特定值修正？
  3. S曲线测试
     + S曲线是用来测试在特定注入电荷量情况下，DAC阈值和触发率的关系
     + 在两种情况下测量S曲线：经过4bit DAC修正和未经过4bit DAC修正
     + 获得特定输入电荷对应触发率为50%时的10bit DAC输出值，为该电荷对应的成形输出值
     + 目的就是为了将10bit DAC阈值设置准确 
  4. 噪声测试
     + 在同一输入电荷情况下，多次测量S曲线，取50%触发率对应的DAC码值（阈值）作为该电荷输入情况下的成形输出值，多次测量DAC码值的波动
     + 该波动应当理解成由于噪声引起的，可以测量出噪声对应的电压水平
+ 可以进行的工作
  + 之前计算的模拟电路输出使用的理想的电荷注入完成的，要和实际测量对比，应该考虑弹道亏损

## 2017/01/12
+ 示波器测试完成
  1. 最小可分辨信号3fC![3fC HG Sh Out](http://ogs54iji1.bkt.clouddn.com/SDHCAL3fC_HGShOut.jpg-SDHCAL)![3fC HG Sh Out](http://ogs54iji1.bkt.clouddn.com/SDHCAL3fC_HGShOut1.jpg-SDHCAL)![3fC HG Sh Out](http://ogs54iji1.bkt.clouddn.com/SDHCAL3fC_HGShOut2.jpg-SDHCAL)
  2. 4fC![4fC HG Sh Out](http://ogs54iji1.bkt.clouddn.com/SDHCAL4fC_HGShOut.jpg-SDHCAL)![4fC HG Sh Out](http://ogs54iji1.bkt.clouddn.com/SDHCAL4fC_HGShOut1.jpg-SDHCAL)
  3. 10fC![10fC HG Sh Out](http://ogs54iji1.bkt.clouddn.com/SDHCAL10fC_HGShOut.jpg-SDHCAL)![10fC HG Sh Out](http://ogs54iji1.bkt.clouddn.com/SDHCAL10fC_HGShOut1.jpg-SDHCAL)
  4. 20fC![20fC HG Sh Out](http://ogs54iji1.bkt.clouddn.com/SDHCAL20fC_HGShOut.jpg-SDHCAL)
  5. 200fC![200fC HG Sh Out](http://ogs54iji1.bkt.clouddn.com/SDHCAL200fC_HGShOut.jpg-SDHCAL)
  6. 500fC![500fC HG Sh Out](http://ogs54iji1.bkt.clouddn.com/SDHCAL500fC_HGShOut.jpg-SDHCAL)
  7. 600fC开始变形了![600fC HG Sh Out](http://ogs54iji1.bkt.clouddn.com/SDHCAL600fC_HGShOut.jpg-SDHCAL)
  8. High gain shaper输出线性较好，测量了不同sw_hg下的输出
  + sw_hg = 00
    ![HG Shaper output vs Charge](http://ogs54iji1.bkt.clouddn.com/SDHCALHGShaper_vs_Charge_swhg00A.jpg-SDHCAL)![HG Shaper output vs Charge](http://ogs54iji1.bkt.clouddn.com/SDHCALHGShaper_vs_Charge_swhg00B_2.jpg-SDHCAL)
  + sw_hg = 01
    ![HG Shaper output vs Charge](http://ogs54iji1.bkt.clouddn.com/SDHCALHGShaper_vs_Charge_swhg01A.jpg-SDHCAL)![HG Shaper output vs Charge](http://ogs54iji1.bkt.clouddn.com/SDHCALHGShaper_vs_Charge_swhg01B_2.jpg-SDHCAL)
  + sw_hg = 10
    ![HG Shaper output vs Charge](http://ogs54iji1.bkt.clouddn.com/SDHCALHGShaper_vs_Charge_swhg10A.jpg-SDHCAL)![HG Shaper output vs Charge](http://ogs54iji1.bkt.clouddn.com/SDHCALHGShaper_vs_Charge_swhg10B_2.jpg-SDHCAL)
  + sw_hg = 11
    ![HG Shaper output vs Charge](http://ogs54iji1.bkt.clouddn.com/SDHCALHGShaper_vs_Charge_swhg11A.jpg-SDHCAL)![HG Shaper output vs Charge](http://ogs54iji1.bkt.clouddn.com/SDHCALHGShaper_vs_Charge_swhg11B_2.jpg-SDHCAL)​
  9. Low gain shaper输出太小了，线性测量不可靠
+ 64通道基线电压一致性测试完成
  1. High gain shaper输出基线电压，不受sw_hg控制。与Ctest是否选通无关?（昨天晚上测试的数据说明是有关的，但是今天看却无关了，这个后面遇到再测，留下一个记录）
     ![HG Shaper DC](http://ogs54iji1.bkt.clouddn.com/SDHCALDC_Uniform_HG_woCorrection.jpg-SDHCAL)
  2. 经过4-bit DAC校正后的High gain shaper输出基线电压，标准差小了很多
     ![HG Shaper DC](http://ogs54iji1.bkt.clouddn.com/SDHCALDC_Uniform_HG_wiCorrection.jpg-SDHCAL)
  3. 3.Low gain shaper输出的基线电压，标准差本身就不大
     ![LG Shaper DC](http://ogs54iji1.bkt.clouddn.com/SDHCALDC_Uniform_LG.jpg-SDHCAL)
  4. 试验中观察到，基线电压随着芯片上电时间增加会下降，中午12:50测到的第40通道的值为2.13994V，下午14:07分时该通道值变成了2.13893V，具体影响因素是什么还不清楚，猜想应当是温度造成的影响。

+ 修改的地方
  + Verilog代码中的USB命令解析有一个笔误
  + 增加了MATLAB绘制shaper输出线性
  + Shaper线性应该用积分非线性表征，具体定义有很多种，这里选择了一种。

## 2017/01/13
+ 报告
+ 整理文档，整理工程
+ 确定接下来工作任务
+ 组会记录
  + S曲线和测噪声，测量方法虽然一样，但是有区别
  + 测量lg_Shaper的成形时间
  + out_t&h的hold信号应该由high gain shaper的触发信号来产生

## 2017/01/18

+ out_q应当测量管脚而不是连接器上的点，测试的时候失误了，测量当连接器上的点了。
  + 多路选通器A0，A1没有分配管脚
  + 多路选通器可能带来延迟
    ![LG Shaper DC](http://ogs54iji1.bkt.clouddn.com/SDHCALADG904_outQ.jpg-SDHCAL)

## 2017/02/16
+ 去掉测试板上Ch1, Ch2, Ch33的50Ω保护电阻，对信号输入没有影响。
+ SMA Charge Inject Board 正常工作

## 2017/02/17
+ 修改USB命令解析里面的笔误

## 2017/02/20
+ Microroc的Ctest输入电容大小是500fF而不是2pF
+ out_t&h输出为什么不正确？

##  2017/02/21

+ out_t&h输出需要enable widlar power pulsing
+ out_t&h有输出
  ![out_t&h有输出](http://ogs54iji1.bkt.clouddn.com/SDHCALB-outSH_Y-outT&H_R_hold.jpg-SDHCAL)
+ hold信号也有作用
  ![hold信号起作用](http://ogs54iji1.bkt.clouddn.com/SDHCALB-outSH_Y-outT&H_R_hold1.jpg-SDHCAL)
  ![hold信号起作用](http://ogs54iji1.bkt.clouddn.com/SDHCALB-outSH_Y-outT&H_R_hold2.jpg-SDHCAL)
+ 但是hold信号到保持住有一个延迟
  ![hold信号起作用](http://ogs54iji1.bkt.clouddn.com/SDHCALB-outSH_Y-outT&H_R_hold3.jpg-SDHCAL)

## 2017/02/23

+ 单通道MATLAB程序完成
  ![MATLAB Demo](http://ogs54iji1.bkt.clouddn.com/SDHCALmatlabDemo20170223.jpg-SDHCAL)
+ 实际上成形信号会受到其他通道的影响
  + 首先是没有电荷注入的通道，会受到其他通道注入的较大的电荷量(大约>200fC)的影响
    没有信号注入的通道的out_sh，其他通道也没有电荷注入
    ![Ch2 wo chn33 to 64 Inject](http://ogs54iji1.bkt.clouddn.com/SDHCAL0fC_Ch2_Inject_WithoutChn33to64Inject.jpg-SDHCAL)
    没有信号注入的通道的out_sh，其他通道有电荷注入
    ![Ch2 wi chn33 to 64 Inject](http://ogs54iji1.bkt.clouddn.com/SDHCAL0fC_Ch2_Inject_WithChn33to64Inject.jpg-SDHCAL)
  + 有信号输入的通道也会受到影响，甚至成形信号都看不见了
    10fC的high gain成形输出，其他通道没有电荷注入
    ![Ch1 10FC wo chn33 to 64 Inject](http://ogs54iji1.bkt.clouddn.com/SDHCAL10fC_Ch1_Inject_WithoutChn33to64Inject.jpg-SDHCAL)
    10fC的high gain成形输出，其他通道有电荷注入，信号已经被干扰淹没了
    ![Ch1 10FC wi chn33 to 64 Inject](http://ogs54iji1.bkt.clouddn.com/SDHCAL10fC_Ch1_Inject_WithChn33to64Inject.jpg-SDHCAL)
+ 成形信号还会受到开始采集与否的干扰
  大约3fC的信号，没有开始采集即没有StartAcq
  ![3fC Chn1 Inject wo ACQ](http://ogs54iji1.bkt.clouddn.com/SDHCAL3fC_Ch1_Inject_WithoutAcq1.jpg-SDHCAL)
  大约3fC的信号，开始采集，信号有，但是噪声已经超过3fC了
  ![3fC Chn1 Inject wi ACQ](http://ogs54iji1.bkt.clouddn.com/SDHCAL3fC_Ch1_Inject_WithAcq.jpg-SDHCAL)


## 2017/02/24

+ 昨天的第三个问题：成形信号会受到开始采集与否的影响。原因应当是数据传输管脚Dout的串扰

  + 蓝色是Dout1b管脚上的信号，红色是5fC输入信号的high gain成形输出，可以看到干扰发生在Dout1b信号跳变时刻

    ![SDHCALR-outSH_B-Dout1b.jpg](http://ogs54iji1.bkt.clouddn.com/SDHCALR-outSH_B-Dout1b.jpg-SDHCAL)

    ![SDHCALR-outSH_B-Dout1b.jpg](http://ogs54iji1.bkt.clouddn.com/SDHCALR-outSH_B-Dout1b1.jpg-SDHCAL)

+ 不过这个问题影响信号的采集，因为在采集结束之后才会进行数据传输，即Dout的跳变在采集结束之后

  + 蓝色是Dout1b管脚上的信号，红色是5fC输入信号的high gain成形输出，黄色是TransmitOn信号。绿色是StartAcq信号。

  + 只有在StartAcq有效时来的电荷输入才会被记录下来，StartAcq结束之后，开始传输数据，对StartAcq有效期间的成形输出不会受到干扰

    ![R-outSH_B-Dout1b_G-StartAcq_Y_TransmitOn](http://ogs54iji1.bkt.clouddn.com/SDHCALR-outSH_B-Dout1b_G-StartAcq_Y_TransmitOn.jpg-SDHCAL)

    ![R-outSH_B-Dout1b_G-StartAcq_Y_TransmitOn](http://ogs54iji1.bkt.clouddn.com/SDHCALR-outSH_B-Dout1b_G-StartAcq_Y_TransmitOn3.jpg-SDHCAL)

    ![R-outSH_B-Dout1b_G-StartAcq_Y_TransmitOn](http://ogs54iji1.bkt.clouddn.com/SDHCALR-outSH_B-Dout1b_G-StartAcq_Y_TransmitOn1.jpg-SDHCAL)

    ![R-outSH_B-Dout1b_G-StartAcq_Y_TransmitOn](http://ogs54iji1.bkt.clouddn.com/SDHCALR-outSH_B-Dout1b_G-StartAcq_Y_TransmitOn2.jpg-SDHCAL)

+ S曲线测试

+ S曲线测试时序
   ![S曲线测试时序](http://ogs54iji1.bkt.clouddn.com/SDHCALScurveCali_TS.png-SDHCAL)


##  2017/03/09

+  添加了上位机修改SC parameter 336：Select latched (RS : 1) or direct output (trigger : 0)， 和SC parameter 575：Select Channel Trigger selected by Read Register (0) or NOR64 output (1) 的逻辑
+  目前的情况来看，要有trigger输出，必须要StartAcq有效，在S曲线测试的时候，这个比较麻烦
+  以前的USB命令有两个地方需要修改
   +  在Trig_Gen里面产生的raz_chn只在上位机发送Trig_Gen_en的时候产生了一次，实际上应该在每次比较之后都产生才可以
   +  根据之前邮件交流的内容，SC参数581和582是指定internal raz 的宽度的，也就是说internal raz和external raz需要两套独立的命令来控制
+  上述两个地方修改完成
+  在代码中添加了如下的模块
   +  USB发送命令控制是使用internal raz还是external raz
   +  USB命令选择internal raz的宽度，即对应的SC参数
   +  USB命令选择external raz的宽度，即产生的脉冲的宽度
   +  USB命令控制external raz在trigger有效之后多长时间输出
+  目前的实验观察到如下两个现象
   +  在使用internal raz的时候，如果不给Start_acq信号，那么trigger没有输出；使用external raz的时候，不给Start_acq，trigger也有输出，同时，外部给的raz信号能够很好的清除trigger。（这里存在一个猜想，外部的raz信号其实可以任意长度的，只要外部有raz，trigger相当于被锁死，明天试一试）
   +  在trigger有输出的时候，成形输出会受到干扰，而且，当阈值设得很低的时候，误触发特别的严重。（从一个角度说明了En_Count_T的重要性）


## 2017/03/10

+ sw_hg=11，sw_lg=11时，达峰时间最长，达峰时间在输入很大的时候不会随着输入的减小而减小，只有当输入减小到一定程度时，会随着输入的减小而减小，最大的达峰时间不超过100ns，这个时间可以用作En_Count_T的参考，同时，从电荷注入开始到有成形输出，这个过程有大约50ns的延迟
+ 修正一下昨天观察到的第一个现象
  + 使能PowerPulsing时，只有Start_Acq信号来的时候，才有trigger输出
  + 不使能PowerPulsing时，在使用internal raz的时候，如果不给Start_acq信号，那么trigger没有输出；使用external raz的时候，不给Start_acq，trigger也有输出
  + 原因是使能PowerPulsing时，只有在Start_Acq时，芯片的Power_on管脚才为1，其他时候为0，相当于没有供电，不使能PowerPulsing时，Power_on管脚为1
+ S曲线测试代码完成



## 2017/03/15

+ SCurve测试逻辑还需要如下修改
  + 给SCurve Test一个单独的启动信号
  + SCurve Test 结束之后判断USB大FIFO是否为空，若为空，停止USB_Acq_Start_Stop
  + 在下层SCTest_Control中加入channel mask,多通道测试时屏蔽非测试通道的trigger
+ 上位机需要增加一个线程接收SCurve test的数据
+ 组会：
  + 尽快和探测器尽心联调
    + 联调时可以使用粗略阈值
    + 接上阳极板测噪声
  + 使用高频时钟来输出hold信号，如400M时钟，5ns的步进长度
  + 再焊一块测试板，四片芯片都焊上
  + “触发率-阈值”测试==>目的是阈值标定



## 2017/03/24

+ 阳极板接上探测器后侧边漏气，阳极板不平整
  + 以后阳极板做厚一点，厚度：3.2mm
  + 考虑阳极板残铜率，做成关于中心层对称的结构

+ S曲线测试完成
  + 单通道S曲线：

    ![单通道S曲线](http://ogs54iji1.bkt.clouddn.com/SDHCALSCurve80fC.jpg-SDHCAL)

  + 64通道S曲线

    ![64通道S曲线](http://ogs54iji1.bkt.clouddn.com/SDHCALTrig0_SCurve_0fC_WoCorrection.jpg-SDHCAL)

  + 根据零输入情况下S曲线计算64通道基线不一致性，然后做修正，修正结果与直接用电压表量到的值计算出来的修正做对比
    + 直接用电压表量到的结果做修正，S曲线50%触发率对应的码值一致性更好

      + 64通道S曲线，未修正

        ![64通道S曲线，未修正](http://ogs54iji1.bkt.clouddn.com/SDHCALTrig0_SCurve_0fC_WoCorrection.jpg-SDHCAL)

      + 64通道S曲线，使用电压表测量到的结果修正

        ![64通道S曲线，DC修正](http://ogs54iji1.bkt.clouddn.com/SDHCALTrig0_SCurve_0fC_WiCorrection_DC.jpg-SDHCAL)

      + 使用未修正的S曲线的50%触发率的值作为基线电压值进行修正

        ![64通道S曲线，SCurveTest修正](http://ogs54iji1.bkt.clouddn.com/SDHCALTrig0_SCurve_0fC_WiCorrection_SCT.jpg-SDHCAL)

    + 可以明显看到修正之后的S曲线更加聚拢，即一致性更好

    + 统计分析

      ![64通道S曲线50%触发率对应的DAC码值对比](http://ogs54iji1.bkt.clouddn.com/SDHCALComparisonOf50PercentTriggerEfficiency.jpg-SDHCAL)

    + 不管是用直流电压进行修正还是用S曲线的值尽心修正，修正之后的结果都更好

      + 使用S曲线进行修正的方法有一点不完善的地方，使用S曲线50%触发率对应的DAC码值进行修正时，对应的码值大部分时候不是整数，结果是取整了的，也就是说DAC码值对应的点并不是50%的点，只是最靠近50%触发率的点。这样修正的4-bitDAC码值就不是很准确。

      + 这些比较中没有包含61通道，61通道有问题，64通道50%触发率对应的DAC码值更低

        + 61通道S曲线和其他通道S曲线对比

          ![61通道和其他通道对比](http://ogs54iji1.bkt.clouddn.com/SDHCALChn61SCurve_vs_All.jpg-SDHCAL)

        + 61通道明显噪声更大

        + trigger有输出时out_sh会有一个反向的噪声，感觉像是互感串扰

          + 红色：out_trigger0， 绿色：out_sh， 黄色：DAC输出电压

          ![61通道0fC](http://ogs54iji1.bkt.clouddn.com/SDHCALch61-0fC1.jpg-SDHCAL)

          ![61通道0fC](http://ogs54iji1.bkt.clouddn.com/SDHCALch61-0fC2.jpg-SDHCAL)

        + 每个通道都有这样的现象，但是61通道更严重，这样子会造成一个结果，就是每当trigger从0跳变到1的时候，out_sh会有一个向下的串扰，这个串扰可能会使out_sh低于DAC值，然后trigger又输出了，形成一个正反馈，61通道的正反馈尤其严重

          + 1通道在配置时，会有一段上述的反馈，但是反馈很快就消失了的，在进行S曲线测试时不会有干扰，红色：out_trigger0， 黄色：DAC输出电压， 绿色：out_sh， 蓝色：FPGA配置输出完成， 白色虚线：配置稳定后基线的电压

            ![1通道配置时的波形](http://ogs54iji1.bkt.clouddn.com/SDHCALchn1_Config.jpg-SDHCAL)

          + 61通道配置时，正反馈一直持续，红色：out_trigger0， 黄色：DAC输出电压， 绿色：out_sh， 蓝色：FPGA配置输出完成， 白色虚线：配置稳定后基线的电压

            ![61通道配置时的波形](http://ogs54iji1.bkt.clouddn.com/SDHCALchn61_Config.jpg-SDHCAL)

  + 64通道S曲线测试已做：0fC, 1fC, 2fC, 4fC, 5fC, 6fC, 8fC, 10fC

    + 50%触发率对应的DAC码值曲线，1fC时和0fC没有办法分辨，第61通道的数据有问题

      ![50%触发率对应的DAC码值](http://ogs54iji1.bkt.clouddn.com/SDHCALASIC203_50PercentTrig_Efficiency_vs_Charge.jpg-SDHCAL)

    + 转换成电压值之后进行线性拟合

      ![50%触发率对应的DAC码值转换成电压值之后线性拟合](http://ogs54iji1.bkt.clouddn.com/SDHCALASIC203_LinearfitOfCharge_vs_50TrigEfficiency.jpg-SDHCAL)

    + 在低电荷量(<4fC)输入时，61通道的结果是有问题的

+ 另外一块板B板是好的

  + 64通道S曲线，每个通道都是好的

  ![B板ASIC215的S曲线](http://ogs54iji1.bkt.clouddn.com/SDHCALB_Board_0fC_DAC0.jpg-SDHCAL)

  ![B板ASIC215的S曲线](http://ogs54iji1.bkt.clouddn.com/SDHCALASIC215_SCurveDAC0.jpg-SDHCAL)



## 2017/03/27

+ 多片ASIC工作方式
  + 配置
    + 级联配置的方式，配置好第一片之后，再对第一片进行配置，第一片将配置信息输出给第二片，以此类推。目前的逻辑在不修改的情况下是可以配置4片的。
      + Header要不一样
      + 10-bit DAC码值可能不一样
      + 4-bit DAC ，码值不一样
    + 可以再加一个配置多片的模块，自动改变Header，以及预先将DAC码值准备好
  + ACQ
    + 同步给出Start_Acq信号，现在的逻辑就是这么做的
    + 当一片芯片的一个通道给出trigger信号之后，所有的芯片都应该在这一时刻将比较器的结果编码存入RAM中 => trigger应当送到FPGA中然后trig_ext输出，trigger输出到trig_ext输出之间延时应当尽可能的小
    + 数据读回：目前看来不需要修改的
    + rst_counterb：什么时候清零BCID，是每一次start_acq之后就清零一次还是一次测试清零一次？
    + VAL_EVT的作用是什么？