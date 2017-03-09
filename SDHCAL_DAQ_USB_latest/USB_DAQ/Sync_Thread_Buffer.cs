using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Threading;
//一个同步程序,生产者向一个缓冲区(定义为三个字节)中写入数据,消费者从中提取数  
//据,如果缓冲区中没有数据,那么consumer只好wait,进入等待状态,当另一个线程(也就是  
//生产者)向缓冲区中写入数据猴,执行了Monitor.pulse,唤醒了consumer的等待,开始读取  
//数据.反之,当producer写入数据的时候,如果缓冲区已满,那么只好进入等待状态,当另一  
//个线程(也就是消费者)从中读取了数据,缓冲区有了空间,那么消费者执行  
//Monitor.pulse,唤醒生产者,继续写入数据.  
//程序使用了lock来锁定共享数据区,而不是使用Monitor.enter和Monitor.exit，因为你可  
//能很容易忘记enter后exit掉,而lock则是隐式的执行了exit,所以建议用lock.  
//当然,在程序执行的过程中,因为是线程,所以执行结果是不可再现的!!每次可能执行的顺  
//序有很多种!!  
//定义了四个类:  
//第一个类LetSynchronized,主要用来存取数据,并且在存取的时候,加上了共享锁.  
//第二个类Producer,生产者,调用一个LetSynchronized类的实例的setBuffer方法来存放  
//数据.  
//第三个类Consumer,消费者, 调用一个LetSynchronized类的实例的getBuffer方法来存放  
//数据.  
//第四个类ThreadStart,测试类,也是这个cs中的启动类,定义了LetSynchornized实例,然  
//后传递给了Producer和Consumer,然后定义了两个线程,线程启动的是Producer  
//的produce方法和Consumer的consume方法,最后启动这两个线程.  

namespace USB_DAQ
{
    class Sync_Thread_Buffer
    {
        //private byte[] buffer = new byte[512 * 4];//定义2048字节的缓冲区
        //private Queue<byte[]> buffer = new Queue<byte[]>(16384);//定义队列
        //private Queue<byte> buffer = new Queue<byte>(512*16384);//定义长度524288的队列
        //private long bufferCount = 0;//缓冲区内数值个数
        //private int readLocation = 0, writeLocation = 0;//确定读写位置
        //private Queue<byte[]> buffer;
        private Queue<byte> buffer;
        private int length;
        public bool IsBufferEmpty()
        {
            bool empty = (buffer.Count == 0);
            return empty;
        }
        public bool IsBufferFull()
        {
            bool full = (buffer.Count == length);
            return full;
        }
        public Sync_Thread_Buffer(int len)
        {
            buffer = new Queue<byte>(len);
            length = len;
        }
        public void Clear()
        {
            buffer.Clear();
           // bufferCount = 0;
        }
        public byte[] getBuffer()
        {
            lock(this)
            {
                
                //if (bufferCount == 0) //缓冲区里没有数据
               // if(buffer.Count == 0)
                if(IsBufferEmpty())
                {
                    Monitor.Wait(this);//Consumer 进入wait状态
                }
                //已从缓冲区读取数据
                byte[] temp = new byte[4096];//Modified by wyu 512->1024
                //temp = buffer.Dequeue();
                for(int i = 0; i < 4096; i++)
                    temp[i]=buffer.Dequeue();             
                //byte[] temp = buffer[readLocation:readLocation + 512 - 1];
                // bufferCount = bufferCount - 512;
                //byte[] temp = buffer.Dequeue();
                Monitor.Pulse(this);
                return temp;//返回值
            }
        }
        //将数据放入缓冲区
        public void setBuffer(byte[] temp)
        {
            lock(this)
            {               
                if (IsBufferFull())
                {
                    Monitor.Wait(this);//缓冲区已满，producer进入wait状态
                }
                // buffer.Enqueue(temp);
                //buffer[writeLocation: writeLocation + 512 - 1] = temp;
                for (int i = 0; i < 4096; i++)
                    buffer.Enqueue(temp[i]);
                //bufferCount = bufferCount + 512;
                //写下一个位置
                // writeLocation = (writeLocation + 512) % buffer.Length;
                //buffer.Enqueue(temp);
                Monitor.Pulse(this);
            }
        }
    }
}
