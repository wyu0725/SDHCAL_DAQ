# SDHCAL_DAQ V2.0

> 新的SDHCAL DAQ工程，从硬件、逻辑、上位机和数据处理方面记录工程

## 硬件电路

## FPGA逻辑

### 时钟

+ 时钟使用MMCM( Mixed-Mode Clock Manager)产生
+ 7系列FPGA芯片时钟手册



## Microroc芯片

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

+ DAC0 VTH：为Microroc的第一片ASIC设定阈值，有两种模式，目前与探测器联调的测试版用的第一种模式
  + 4.25V/fC模式，基线大约在595
  + ​

## 数据处理程序