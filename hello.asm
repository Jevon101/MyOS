;MBR  nasm.exe hello.asm -o boot.bin
;dd.exe if=boot.bin of=dingst.vhd bs=512 count=1
;With VirtualBox
org 07c00h
mov ax,cs
mov ds,ax
mov es,ax
call DISP
jmp $
DISP:
    mov ax,BootMsg
    mov bp,ax
    mov cx,16        ;字符串长度
    mov ax,01301h    ;黑底红字
    mov bx,000ch
    mov dl,0
    int 10h          ;10h号中断
BootMsg: db "Hello, OS World!"
times 510 - ($-$$) db 0
dw 0xaa55