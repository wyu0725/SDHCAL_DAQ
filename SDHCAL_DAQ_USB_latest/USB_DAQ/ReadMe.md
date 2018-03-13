# MainWindows.cs

# MyCyUsb.cs

# CommandHeader.cs

> CommandHeader类用于生成USB命令的头，用于区分不同的命令，详见Microroc命令类

# MicrorocControl.cs

##构造函数

有参构造函数，用Header和ASIC Number来确定一串Microroc芯片

## Check**XXX**Legal

所有的命令，如果在上位机界面是通过TextBox输入的，都用string送入，然后通过CheckLegal判断

## SetAsicHeader

通过USB向DIF发送header，Header必须是8bit的，否则超出的位舍去

