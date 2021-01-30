;.\nasm2\nasm.exe .\MyOS\pm.asm -o pm.exe

DA_32 equ 4000h ;32位
DA_C equ 98h ;只执行
DA_DRW equ 92h;可读写
DA_DRWA equ 93h;存在的已访问的可读写的

%macro Descriptor 3
    dw %2 & 0FFFFh ;段界限1
    dw %1 & 0FFFFh ;段基址1
    db (%1 >> 16) & 0FFh ;段基址2
    dw ((%2 >> 8) & 0F00h) | (%3 & 0F0FFh) ;属性1 + 段界限2  + 属性2
    db (%1 >> 24) & 0FFh  ;段基址3
%endmacro


org 0100h
jmp PM_BEGIN ;跳入PM_BEGIN 

[SECTION .gdt]
;GDT
;                           段基址   段界限  属性
PM_GDT:         Descriptor  0,      0,      0
PM_DESC_CODE32: Descriptor  0,      SegCode32Len - 1,      DA_C + DA_32
PM_DESC_DATA:   Descriptor  0,      DATALen - 1,           DA_DRW 
PM_DESC_STACK:  Descriptor  0,      TopOfStack,            DA_DRWA + DA_32
PM_DESC_TEST:   Descriptor  0200000h,0FFFFh,               DA_DRW
PM_DESC_IMAGE:  Descriptor  0B8000h,0FFFFh,                DA_DRW

GDTLen equ $ - PM_GDT
GDTPtr dw GDTLen - 1
dd 0 ;GDT基地址,在进入保护模式时会填充

;GDT 选择子
SelectorCODE32 equ PM_DESC_CODE32 - PM_GDT
SelectorDATA equ PM_DESC_DATA - PM_GDT
SelectorSTACK equ PM_DESC_STACK - PM_GDT
SelectorTEST equ PM_DESC_TEST - PM_GDT
SelectorIMAGE equ PM_DESC_IMAGE - PM_GDT
;END of [SECTION .gdt]


[SECTION .data]
ALIGN 32
[BITS 32]
PM_DATA:
    PMMESSAGE: DB "Protected Mode",0
    OFFSETPMMESSAGE equ PMMESSAGE - $$
    DATALen equ $ - PM_DATA
;END of [SECTION .data]

;堆栈段
[SECTION .gs]
ALIGN 32
[BITS 32]
PM_STACK:
    times 512 db 0
TopOfStack equ $ - PM_STACK - 1
;END Of STACK


[SECTION .s16]
[BITS 16]
PM_BEGIN:
    mov ax,cs
    mov ds,ax
    mov es,ax
    mov ss,ax
    mov sp,0100h

    ;初始化GDT内的数据段
    xor eax,eax
    mov ax,ds
    shl eax,4
    add eax,PM_DATA
    mov word [PM_DESC_DATA + 2],ax ;段基址1
    shr eax,16
    mov byte [PM_DESC_DATA + 4],al ;段基址2
    mov byte [PM_DESC_DATA + 7],ah ;段基址3

    ;初始化GDT内的代码段
    xor eax,eax
    mov ax,cs
    shl eax,4
    add eax,PM_SEG_CODE32
    mov word [PM_DESC_CODE32 + 2],ax ;段基址1
    shr eax,16
    mov byte [PM_DESC_CODE32 + 4],al ;段基址2
    mov byte [PM_DESC_CODE32 + 7],ah ;段基址3

    ;初始化GDT内的堆栈段
    xor eax,eax
    mov ax,ds
    shl eax,4
    add eax,PM_STACK
    mov word [PM_DESC_STACK + 2],ax ;段基址1
    shr eax,16
    mov byte [PM_DESC_STACK + 4],al ;段基址2
    mov byte [PM_DESC_STACK + 7],ah ;段基址3

    ;加载GDTR
    xor eax,eax
    mov ax,ds
    shl eax,4
    add eax,PM_GDT
    mov dword [GDTPtr + 2],eax
    lgdt[GDTPtr]

    ;打开A20地址线
    cli

    in al,92h
    or al,00000010b
    out 92h,al

    ;进入保护模式
    mov eax,cr0
    or eax,1
    mov cr0,eax


    jmp dword SelectorCODE32:0

[SECTION .s32]
[BITS 32]
PM_SEG_CODE32:
    mov ax,SelectorDATA ;把选择子放入ds寄存器，使用段+偏移进行寻址
    mov ds,ax
    mov ax,SelectorTEST
    mov es,ax
    mov ax,SelectorIMAGE
    mov gs,ax
    mov ax,SelectorSTACK
    mov ss,ax
    mov esp,TopOfStack

    mov ah,0Ch
    xor esi,esi
    xor edi,edi
    mov esi,OFFSETPMMESSAGE  ;字符串起始位置
    mov edi,(80 * 10 + 30) * 2 ;显示位置
    cld

.lo:
    lodsb
    test al,al
    jz .ou
    mov [gs:edi],ax
    add edi,2
    jmp .lo

;显示完毕
.ou:
    jmp $

SegCode32Len equ $ - PM_SEG_CODE32
;END Of CODE