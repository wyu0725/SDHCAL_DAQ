# 处理SlaveDAQ模块采到的数据

## Improtdata()

弹出窗口选择文件，返回数据，数据以ubit2格式存（为了方便处理每个通道的数据）。

## [TriggerCount, PackageEnd] = CheckPackageEnd(InitialData, PackageNumber)

判断读到的数据的第一个word是不是0xff45 (65349)

+ 如果是PackageEnd = 1，同时从前一个数据块中将TriggerCount读回，如果没有前一个块，TriggerCount = 0
+ 如果不是：PackageEnd = 0

## [ Header, BCID, ChannelData, TriggerHeader, TriggerCount ] = ReadSlaveDaqPackage( InitialData, PackageNumber )

将每个数据块中的数据读回来，调用这个函数之前先调用CheckPackageEnd检查包是否结束

