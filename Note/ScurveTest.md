# S曲线测试

## 什么是S曲线，为什么要测S曲线？

S曲线的测试用来测试不同电荷输入的情况下，DAC阈值与触发率的关系，目的就是把阈值设置的尽量精确，在基线修正的情况下测得的S曲线，做为与探测器联调的阈值设置参考，同时可获得在同一触发率下，输入电荷与DAC阈值的线性关系做为评估系统性能的关键参数之一。

## 如何测试S曲线?

## 问题

+ The "Ctest" of all the other channels are automatically disabled as well as the corresponding triggers?

## S曲线SC参数需要注意的地方

+ （575）Disc_or_NOR = 1, 使得out_trig0~2是64通道对应的比较器or之后的输出。
+ （577）Raz_chn_int = 0, （578）Raz_chn_ext = 1. 内部的RAZ关闭，使用外部的RAZ信号。
+ （336）RS_or_Discri = 1,选择RS模式
+ 扫描10-bitDAC (min to max)。
+ 需要记录输入的脉冲个数，FPGA 每一个阈值比较器输出的脉冲个数同时记录阈值DAC码值。
+ AFG3252, 一个通道用于产生阶跃信号将电荷注入到ASIC某一个通道中，另一个通道产生与该阶跃信号相同频率的TTL脉冲输入到FPGA中，两个通道的相位和频率保持一致（10KHZ-100KHZ）。注入的电荷的同时开始计数，一个外部使能管脚En_count_T启动计数.
+ S曲线注意不能有通道的trigger被屏蔽，只能一个一个通道进行测试（这个测试用于芯片输入管脚测试，只能一个一个来）。通过CTest管脚，就可以自动选通通道完成所有通道S曲线的测试。(问题)
+ 芯片手册的S曲线测试时序![S曲线测试时序](http://ogs54iji1.bkt.clouddn.com/SDHCALScurveCali_TS.png-SDHCAL)




## S 曲线测试逻辑

1. 单一通道，单一trigger测试模块

   ```verilog
   input out_trigger;
   input CLK_EXT;
   input Test_Start;
   output [15:0] CPT_PULSE;
   output [15:0] CPT_TRIGGER;
   output CPT_DONE;
   ```

   + 按照上图的时序设计模块，SC_参数按照user_guide上设置
   + CLK_EXT的上升沿和电荷注入的时刻对齐
   + 在Test_Start有效后的**几**个系统时钟时钟周期，使CPT_PULSE计数使能，开始计数有多少个脉冲输入
   + 在CLK_EXT为高电平时，CPT_TRIGGER计数使能，计算这次电荷输入过程有没有触发输出。其实CPT_TRIGGER计数使能不需要这么长时间，使能的时间只要超过成形电路的成形输出回到0的时间即可
   + 总脉冲输入CPT_PULSE计数到指定的数目后，停止计数，输出CPT_DONE，将数据交给上层模块



2. 单一通道，控制trigger0~2测试模块

   ```verilog
   input out_trigger0b;
   input out_trigger1b;
   input out_trigger2b;
   input CLK_EXT;
   input SCurve_Test_Start;

   output [15:0] SCurve_data;
   output Single_Trigger_Done;//
   output SignalChn_SCurve_Done;
   ```

   + 控制上一个模块
   + 在SCurve_Test_Start有效后，从out_trigger0b开始，启动上一个模块进行触发率计数
   + 然后将上一个模块的数据保存在一个FIFO中，给数据加上out_trigger0~2的标识
   + 三个trigger计数完成后输出一个done信号




3. 控制单通道测试，还是64通道测试（64通道自动测试需要从Ctest管脚输入）

   ```verilog
   input out_trigger0b;
   input out_trigger1b;
   input out_trigger2b;
   input Single_or_64Chn;
   input CLK_EXT;
   input SCurve_Start;
   input [5:0] Test_Chn;
   input [15:0] SCurve_Data;

   output [15:0] usb_data_fifo_wr_din;
   output [15:0] usb_data_fifo_wr_en;
   output [63:0] CTest_Chn;//64通道测试时用
   output SC_Param_Load;
   output Ctest_AllDone;
   ```

   + 选择单通道测试还是64通道轮流测试，然后启动上一个模块
   + 从上一个模块写入的FIFO中读出数据，加上通道的标识，写入USB数据FIFO
   + 如果是64通道FIFO，再输出一个Ctest_Chn信号用于改变SC参数中Ctest输入的通道
   + 测试完后输出Ctest_AllDone




##  多路选择逻辑

用于选通SCurve 测试还是数据采集



![SCurveTest_BlockFunction](http://ogs54iji1.bkt.clouddn.com/SDHCALSCurveTest_BlockFunction.jpg-SDHCAL)


