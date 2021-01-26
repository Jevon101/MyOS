# OS：从加电自检到内核引导

## 0x00 参考资料及环境搭建:

[如何从零开始写一个简单的操作系统？](https://www.bilibili.com/video/BV19f4y1Y7Kq)  

《操作系统真象还原》

创建虚拟磁盘 : 1.进入命令行 输入diskpart   2.create vdisk file=d:\dingst.vhd maximum=10

对应代码：hello.asm

![image-20210119213655010](http://cdn.jev0n.com//image-20210119213655010.png)

## 0x01 验证性实验

在实模式下使用汇编显示文字  

对应代码：disp.asm

![image-20210120110842236](http://cdn.jev0n.com//image-20210120110842236.png)

![image-20210120111702250](http://cdn.jev0n.com//image-20210120111702250.png)

## 0x02 实模式下磁盘的内容读取

对应代码：mbr.asm   loader.asm

参考资料：[CHS和LBA逻辑块地址](https://blog.csdn.net/jadeshu/article/details/89072512)

![image-20210123180755831](http://cdn.jev0n.com//image-20210123180755831.png)![image-20210123183226440](http://cdn.jev0n.com//image-20210123183226440.png)

## 0x03 保护模式

对应代码：p1.asm

段描述符：![image-20210126195122255](http://cdn.jev0n.com//image-20210126195122255.png)

逻辑地址 -> 线性地址(平坦模式) -> 物理地址![image-20210126202106873](http://cdn.jev0n.com//image-20210126202106873.png)