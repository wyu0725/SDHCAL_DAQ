# 2018/07/18

## 有待修改的功能

### 每片Microroc开始采集需要一个统一的Trigger信号保证所有ASIC一起开始采数

+ 这个Trigger信号应当由外部给出
+ 在测试中用4串ASIC的EndReadout信号的与作为Trigger

### ExternalRaz、Hold、CK5和CK40、PowerPulsing控制不由每个ASIC自己产生，由一个单独的模块来生成

+ 这些信号是共用的，单独产生不利于使用

### PowerPulsing Pin 控制的上位机命令

## 完成的功能



# 2018/07/20

## 完成

+ Top层信号连接
+ 每片ASIC有一个统一的Trigger信号保证一起StartAcquisition， 目前这个信号由所有芯片的EndReadout“与”给出，不是简单与，是所有芯片都给出EndReadout后给出