# Microroc数字部分解读

------

## 模拟数字转换部分

![A2DInterface](http://i.imgur.com/YlEuJqV.jpg)

### 比较器及输出
+ 三个比较器通过10bit-DAC设置阈值电压，根据Datasheet，Vth0设置在2fC左右，Vth1在20fC左右，Vth2设置在200fC左右
+ 比较器的输出直接被送入RS锁存器进行存储
+ 完成一次比较后RS锁存器的数据再通过Raz_chn信号进行清零，这样就可以进行下一次比较

### Trigger
+ using rs_or_discri (SC 337) and the disc_or_or  (SC  579)  SC  parameters,  the  latched  or  direct  discriminator  output  or  the  OR64  ouput  can  be selected to be seen on scope.
+ SC_337参数可以控制比较器的输出是送给RS锁存器输出还是直接输出(这里不是很理解，不经过RS锁存器的数据怎么输出，从图上可以看出，比较器输出的数据可以直接送给或非门电路进行处理，但是怎么输出不是很清楚，当然实际上我们也不会用这种模式)
+ SC_579参数可以控制在out_trig1b~out_trig2b上面输出的信号是比较器直接输出的结果还是讲64通道比较器输出或非之后的结果
+ 还可以在SC参数中设置trigger mask，是的某一通道的某一个比较器不输出，当然这个功能不用
+ 编码：每个通道的3个比较器输出的结果会被编码成两位二进制，编码方式如下

|Discri2|Discri2|Discri0|EnCode<1>|EnCode<0>|
|---|---|---|---|---|
|0|0|0|0|0|
|0|0|1|0|1
|0|1|1|1|0|
|1|1|1|1|1|

+ 编码的结果通过一个或非门输出写使能信号，输出给后端电路进行一次写入使能，然后编码信息被写入RAM

## 数字部分

![MicrorocDigitalPart](http://i.imgur.com/UxrZJLA.jpg)

### RAM部分

+ 编码信息在触发信号的作用下，被写入RAM
+ 片内RAM大小为128×160b，即RAM的一个地址存储一次编码的结果，即为1帧
+ 帧按照如下的顺序排列
	1 byte Header (a5a5)
	3 bites BCID (Bunch Counter ID)
	4 bytes (encode0<Ch48>,encode1<ch48>,...,encode0<Ch63>,encode1<ch63>)
	4 bytes (Ch32 to Ch47)
	4 bytes (Ch16 to Ch31)
	4 bytes (Ch0  to Ch15)
+ 帧的顺序有一点点奇怪，排列下来似乎是这样子的$Ch48\sim Ch63,Ch32\sim Ch47,Ch16\sim Ch31,Ch0\simCh15$
+ 当可以读出后，TransmitOn管脚输出低电平，在读书时钟控制下串行读回
