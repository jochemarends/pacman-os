bits 16

global kernel

%include "write.inc"
%include "vga.inc"

section .text
kernel:
    mov     si, msg
    call    write_str
    call    vga_mode_0x13_test
    jmp     $

msg: db "Jag tycker om min hund!", 0x0D, 0x0A, 0

