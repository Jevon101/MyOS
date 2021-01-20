;实模式下打印文字
;nasm.exe disp.asm -o disp.bin
;dd.exe if=disp.bin of=dingst.vhd bs=512 count=1
mov ax,0xb800 ;指向显示缓冲区
mov es,ax

mov byte [es:0x00],'I'
mov byte [es:0x01],0x07;黑底白字
mov byte [es:0x02],'m'
mov byte [es:0x03],0x06
mov byte [es:0x04],'J'
mov byte [es:0x05],0x07
jmp $
times 510 - ($-$$) db 0
dw 0xaa55