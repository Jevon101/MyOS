;mbr.asm
;将第二个扇区的内容加载进内存
;nasm.exe mbr.asm -o mbr.bin
;dd.exe if=mbr.bin of=..\dingst.vhd bs=512 count=1

LOADER_BASE_ADDR equ 0x900
LOADER_START_SECTOR equ 0x2  ;LBA方式存在第二扇区

SECTION MBR vstart=0x7c00
    mov ax,cs
    mov ds,ax
    mov es,ax
    mov ss,ax
    mov fs,ax
    mov sp,0x7c00
    mov ax,0xb800
    mov gs,ax    ;显存位置

;利用0x06的功能，调用10号中断刷新显示
; AH = 0x06   AL = 0 表示全部都要清除
; BH = 上卷行的属性  ？？
; (CL,CH)  左上角 x,y
; (DL,DH)  右下角 x,y

    mov ax,0600h
    mov bx,0700h
    mov cx,0
    mov dx,184fh;(80,25)

    int 10h

;打印字符串
    mov byte [gs:0x00], 'M'
    mov byte [gs:0x01], 0xA4
    mov byte [gs:0x02], 'B'
    mov byte [gs:0x03], 0xA4
    mov byte [gs:0x04], 'R'
    mov byte [gs:0x05], 0xA4
    mov byte [gs:0x06], ' '
    mov byte [gs:0x07], 0xA4
    mov byte [gs:0x08], '!'
    mov byte [gs:0x09], 0xA4
    
    mov eax,LOADER_START_SECTOR ;LBA 读入的扇区
    mov bx,LOADER_BASE_ADDR     ;写入的地址
    mov cx, 1                   ;读入的扇区数
    call rd_disk

    jmp LOADER_BASE_ADDR        ;跳转到实际的物理内存

rd_disk:
    mov esi,eax
    mov di,cx

;读写磁盘
    mov dx,0x1f2
    mov al,cl
    out dx,al  ;LBA方式：写0x1f2: 要读的扇区数

    mov eax,esi

;将LBA的地址存入(0x1f3, 0x1f6)

    mov cl,8
    ;0-7位写0x1f3  扇区号
    mov dx,0x1f3
    out dx,al

    ;8-15位写0x1f4
    shr eax,cl
    mov dx,0x1f4
    out dx,al

    ;16-23位写0x1f5
    shr eax,cl
    mov dx,0x1f5
    out dx,al

    ;设置24-27位为0111，LBA模式，24-31位写0x1f6
    shr eax,cl
    and al,0x0f
    or  al,0xe0 ;1110 0000
    mov dx,0x1f6
    out dx,al

    ;向0x1f7写入读命令
    mov dx,0x1f7
    mov al,0x20
    out dx,al

;检测硬盘状态
.not_ready:
    nop
    in al,dx
    and al,0x88 ;1000 1000  四位为1 可以传输   七位为1  表示硬盘忙
    cmp al,0x08
    jnz .not_ready

;读数据
    mov ax,di
    mov dx,0x100
    mul dx
    mov cx,ax
    mov dx,0x1f0

.go_on:
    in ax,dx
    mov [bx],ax
    add bx,2
    loop .go_on
    ret

times 510 - ($-$$) db 0
dw 0xaa55




