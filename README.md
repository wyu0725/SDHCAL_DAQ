# SDHCAL_DAQ V2.0

> 新的SDHCAL DAQ工程，从硬件、逻辑、上位机和数据处理方面记录工程
>
> V 1.1 2017/07/21完成上位机说明和测试说明

## 硬件电路(待写)

>  硬件电路由3部分组成，探测器阳极板、Microroc前端板和DAQ板

### DAQ板

实物图如下![DAQBoard](D:\MyProject\SDHCAL_DAQ\QSunSync\DAQBoard.jpg)

## FPGA逻辑(待写)

### 时钟

+ 时钟使用MMCM( Mixed-Mode Clock Manager)产生
+ 7系列FPGA芯片时钟手册


## Microroc芯片(待写)

### 芯片简介

### 芯片管脚

### 芯片配置

### 模拟电路

#### 模拟电路结构

#### 模拟电路使用

### 数字电路

#### 数字电路结构

### 芯片测试

#### 探测器测试

> 30cmx30cmGEM探测器，高压从下往上为

##### 均匀性测试

+ 3


+ 串扰测试




## 上位机

> 上位机采用C#编写的WPF程序，框架和最初的功能都是由张俊斌师兄完成的，我在其最初的上位机基础上添加了一些测试功能

### 信息显示窗口

+ 最左边为信息显示窗口，用于显示发送命令和数据采集的信息

### Microroc控制窗口

#### SC/Readreg Control窗口

+ ASIC Number用于设置多少片ASIC一起工作，目前的硬件条件下，最多4片ASIC，注意：如果用的4片ASIC的板，最好把四片ASIC都配置上，不用的ASIC可以考虑把阈值设到最高，即所有的DAC码值设为0
+ Start Header是用来设置ASIC的Header的，只用设置第一片ASIC的Header，其后的ASIC的Header依次递增，注：最右边的一片ASIC为第一片
+ RAZ Chn Select可以选择Internal RAZ和External RAZ，RAZ的作用是复位Microroc芯片中的RS锁存器的输出，即Microroc中的三个比较器的比较结果会送到锁存器中进行锁存，锁存器的输出不会自动清零，需要一个RAZ信号来进行清零，选择Internal RAZ模式，即Microroc自动将锁存器清零，选择External RAZ则要求外部向Microroc发送一个清零信号，否者锁存器输出一直有效
+ Channel Select是选择数据读回的通道，Microroc中所有的数据读回通道都有两条，一条用于备份，因此在设置时需要选择一条读回通道
+ RS or Direct是用于测试用的，Microroc内部比较器的结果可以通过三个管脚输出，选择RS时，比较器比较的结果先经过锁存器锁存，然后从锁存器输出，Direct则是直接输出不经过比较器
+ Read or NOR64：Microroc有64个通道，每个通道有3个比较器，而用于测试用的比较器输出管脚只有3个，因此可以只输出一个通道的比较结果，或者选择64通道的比较结果或非输出

##### Channel Mask窗口

+ 窗口废弃

#### ASIC Parameter窗口

> 按照实际ASIC的摆放定义4片ASIC，选择不同ASIC数量时会激活不同的窗口

+ DAC0 VTH：为Microroc的第一个比较器设定阈值，有两种模式，目前与探测器联调的测试版用的第一种模式
  + 4.25DAC Unit/fC模式，基线大约在595（注：基线值会随着不同的ASIC而改变）
  + 数据暂未处理
+ DAC1 VTH 为Microroc的第二个比较器设定阈值，同样有两种模式，目前与探测器联调的测试版用的第一种模式
  + 4.25DAC Unit/fC模式，基线大约在607（注：基线值会随着不同的ASIC而改变）
  + 数据暂未处理
+ DAC2 VTH为Microroc的第三个比较器设定阈值，有两种模式，目前与探测器联调的测试版用的第一种模式
  + 1.0123DAC Unit/fC模式，基线大约在609（注：基线值会随着不同的ASIC而改变）
+ Shaper Output ：Microroc有一个管脚可用于输出成形后的信号，这个选项选择是High Gain成形输出还是Low Gain成形输出
+ Out sh：使能或者禁止成形信号输出
+ CTest：Microroc提供一个测试输入用于标定芯片和测试，CTest中填入的通道就是选择哪一个通道作为测试通道
+ sw_hg：是用来选择High Gain成形的参数的，目前只标定了01模式
+ sw_lg：是用来选择low Gain成形参数的，目前只标定了01模式
+ Internal RAZ time：在处于Internal RAZ模式时，选择当RS锁存器被清零后，多长时间才允许下一次触发
+ Pad Cali：使用4-bitDAC对Microroc的基线进行修正，目前这一功能只对编号为223的Microroc有效
+ ReadRegister：Microroc有一个管脚可用于输出成形后的信号，一个管脚用于输出峰保后的输出，这个选项用于选择查看哪一个通道的成形和峰保输出
+ Mask File：用于屏蔽坏通道，在框中填入*.txt文件名，在文件中写入需要屏蔽的通道，每个通道之间要换行

#### 选项按钮

+ SC or ReadReg
  + SC：选择向Microroc发送Slow Control参数，选择这个按钮之后，上方的按键将变成Slow Control，在按Slow Control按钮即可向Microroc发送Slow Control参数
  + ReadReg：向Microroc发送上面提到的ReadRegister参数，选择这个按钮后，上方按键将变成ReadRegister，在按下ReadRegister按钮后即可向Microroc发送ReadRegister参数
+ Mode Select
  + ACQ：正常采数模式
  + SCTest：S曲线测试模式（注意：在这种模式下上文提到的Slow Control按钮和ReadRegister按钮无效）
  + SweepACQ：扫域的方式进行采数，即采够指定的数据包个数之后，改变阈值，再次采指定的数据包个数，再改变阈值，直到采到指定的阈值结束（注意：在这种模式下上文提到的Slow Control按钮和ReadRegister按钮无效）
  + AD9220：使用ADC AD9220对Microroc的峰保输出进行采集
  + Efficiency：测量GEM探测效率，不改变SC参数

---

### ACQ Partameter窗口

+ External RAZ Delay：当选择ExternalRAZ模式时，RS锁存器有输出后多长时间之后开始复位RS锁存器

+ External RAZ Time：当选择ExternalRAZ模式时，RS锁存器被清零后多长时间才可以锁存下一次比较器输出

+ StartAcq Time：向Microroc发送开始采集命令的宽度，在这个时间宽度内，Microroc处于自触发状态，即有信号过阈，就将其写入内存

+ Hold Gen：Hold信号由FPGA提供给Microroc，用于产生峰保输出，这个选项用于选择下一条中的延时是相对哪个比较器的

+ Hold Delay用于决定在Microroc比较器过阈之后多长时间产生Hold信号，其后面的选项框的Disable和Enable用于选择是否要Hold输出

+ Hold Time：hold信号保持多长时间，在Hold信号保持期间，峰保输出一直有效

  点击SET HOLD按钮，上面的关于Hold的参数就被发送至FPGA

+ TRIG EXT：在Microroc开始采集后，强行写一次RAM，用于调试用

+ Reset cntb：复位BCID的计数器

+ OUT TH：用于选择是那片ASIC的Hold输出送给ADC进行采集。

+ TriggerDelay：使用SCTest模式和Efficiency模式时，Microroc比较器经过多长时间延时再送入计数器进行计数

+ Powerpulsing

  + Enable：使能Power Pulsing功能，即只有在开始采集时才给Microroc供电，其余时候处于节能模式
  + Disable：关掉节能模式，即Microroc一直上电

---

### Microroc Control窗口

#### Normal Acq窗口

+ DAQ Mode：
  + Auto：模式即Microroc不停的采数
  + Slave：模式即Microroc在外部触发到来的时候进行采数，这个时候外触发需要接到DAQ板的TRIG_EXT的SMA接口上
+ Data Rate
  + Fast：当数据速度达到MB/s的量级时，选择这个选项
  + Slow：数据产生速度慢时用这个选项
+ Data Number：在Slow Data Rate模式下，选择采集多少个数据之后停止采数
+ End Time：在完成一次SlaveDaq采数之后，会输出一个End信号，这个信号的宽度由End Time 决定

#### Sweep Test窗口

##### SCurve Test窗口

+ Trig or Count
  + Trig：触发率测试模式，即在信号注入的同时，注入一个上升沿信号给CLK_EXT管脚，这个时候要是Microroc的比较器有输出，相应的计数器加1
  + Count：计数率测试模式，在指定时间内计数器计Microroc比较器过阈次数
+ Single or Auto：
  + Single即对一个通道进行测试
  + Auto即从1通道测到64通道
+ CTest or Input
  + CTest：信号从CTest注入
  + Input：信号从输入管脚注入
+ Max count：触发率测试模式下计数器最大计到多大停止
+ Count Time：计数率测试模式时，计数时间
+ Single channel：单一通道测试时，测试通道

##### SweepAcq窗口

+ Package Number：SweepACQ模式下，采多少个数据包之后改变阈值
+ DAC Select：选择改变哪个DAC

#### 测试选项和按钮

+ Start DAC扫域从哪个值开始扫，其后面的Mask和Unmask选项是用于选择在扫一共通道时，其他通道是否需要被屏蔽
+ End DAC扫域扫到哪个值结束，其后面的框填入扫域DAC码值的间隔
+ SweepTestStart：开始采集

#### AD9220窗口

+ Start Delay：hold信号输出后，多长时间ADC开始采数，建议500ns
+ ACQ Times：对一次峰保输出采多少个点
+ hold或者Power：选择Hold即可


## Microroc 上位机测试使用说明

> 下文提到的Trig In和CLK_EXT参见本文开头的DAQ板的实物图，Trig In管脚是给Slave DAQ使用的，即外触发给出之后才开始采数，CLK_EXT是给S曲线测试和宇宙线效率使用的

### Auto DAQ

1. RAZ Chn Select选择Internal
2. 其余SC参数按需选择，

### Slave DAQ

1. RAZ Chn Select选择External，Powerpulsing选择Disasble
2. 设定External RAZ Delay和External RAZ Time
3. 设定合适的StartAcq Time
4. 选择Data Number
5. 将外触发连在DAQ板的TrigIn对应的SMA上
6. 开始采数

### SCTest

> SCTest是S Curve Test的缩写，即S曲线测试，S曲线是指芯片触发率随阈值变化的曲线，在S曲线测试中包含两种模式，一种是电子学S曲线测试，即在给定时刻输入一个电荷量，然后向FPGA送一个触发信号，然FPGA计数，同时FPGA计Microroc比较器信号是否过阈，这样可以得到给定阈值下的触发率，改变阈值继续测触发率，得到触发率vs阈值曲线；二是探测器计数率vs阈值曲线测试，即在指定时间段内计Microroc比较器过阈次数，目前时间段最短可以设为1ms最长可以设为65s，然后改变阈值，继续在相同时间段内计Microroc过阈次数，得到计数率vs阈值曲线

1. RAZ Chn Select选择External，Powerpulsing选择Disasble
2. 设定External RAZ Delay和External RAZ Time
3. 设定合适的Trigger Delay
4. 选择Trig模式(触发率)还是Count模式(计数率)
5. 选择Single还是Auto模式，Single模式是对单一通道扫阈，Auto是对64通道扫阈。若是进行宇宙线扫域测试，请选择Single，选择Single模式的理由参见第10条
6. 选择信号从CTest输入还是从Input管脚输入，若是与探测器相关的测试，请选择Input
7. 设定Max count或者Count Time
8. 设定Single channel，注：即使选择Auto模式也要填写Single channel 否则会报错
9. 设定Start DAC和End DAC以及扫域DAC的间隔
10. Mask或者Unmask，Mask的意思是处理被测试的通道之外其他通道都被屏蔽了，这样得到的结果才是该通道的结果，Unmask的意思是所有的测试通道都不屏蔽，这样的 目的是为了将64通道的触发输出连在一起。要是进行宇宙线扫域测试，请选择Unmask，选择Unmask后即将64通道的触发输出连在一次，这样在第5条选择Single模式后，相当于是64通道的扫阈，若在第五条中选择了Auto，又在这里选择了Unmask，那么相当于对64通道扫阈64次，费时费力没有意义。
11. 将外部的触发信号连在DAQ板的CLK_EXT对应的SMA管脚上
12. 存文件开始采数

### Sweep Acq

暂时不用

### AD9220

> AD9220是用ADC来采集峰保信号，Microroc的成型输出可以在外部给的一个Hold信号的作用下，将hold信号给出时刻的成形输出的电压值保持下来，但是请注意，这个保持并不是完全时刻对应的，在实测过程中发现hold信号有一个15ns左右的裕量，即hold信号在这个裕量范围内峰保值基本不变。

1. RAZ Chn Select选择External，Powerpulsing选择Disasble
2. 设定External RAZ Delay和External RAZ Time
3. 设定Hold Delay和Hold Time并将Hold Delay后面的选项框选择为Enable
4. 然后在AD9200的参数框中将StartDelay填为500，即在Hold信号给出500ns之后再使用ADC采数
5. 在AD9220的参数框中将Acq Times填为32，即一次Hold信号给出之后ADC采多少次数，ADC的采样率是10M，即每次采样间隔为0.1μs，采32次为3.2μs，减小ADC测量带来的误差
6. 存文件
7. 点击ADC Start
8. 由于程序存在bug(目前还没有找到)，在停止采数之后会报一个error，忽视即可

### Efficiency

> Efficiency是用来测宇宙线效率的程序，程序需要设定最大的计数，然后在不改变SC参数的条件下开始采数

1. RAZ Chn Select选择External，Powerpulsing选择Disasble
2. 设定External RAZ Delay和External RAZ Time
3. 设定合适的Trigger Delay
4. 选择Trig模式
5. 设定CPT_MAX
6. 存文件
7. 将外触发送给CLK_EXT管脚
8. 开始采数

## 数据处理程序