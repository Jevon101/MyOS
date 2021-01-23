;loader.asm
;放入 0x900  
;nasm.exe loader.asm -o loader.bin
;dd.exe if=loader.bin of=..\dingst.vhd bs=512 count=1 seek=2
LOADER_BASE_ADDR equ 0x900

SECTION LOADER vstart=LOADER_BASE_ADDR
mov ax,0xb800 ;指向显示缓冲区
mov es,ax
mov byte [es:0x00],'L'
mov byte [es:0x01],0x07;黑底白字
mov byte [es:0x02],'O'
mov byte [es:0x03],0x06
mov byte [es:0x04],'A'
mov byte [es:0x05],0x07
mov byte [es:0x06],'D'
mov byte [es:0x07],0x07
mov byte [es:0x08],'E'
mov byte [es:0x09],0x07
mov byte [es:0x0A],'R'
mov byte [es:0x0B],0x07
 
jmp $