bits 16

global kernel
extern write_str

section .text
kernel:
    mov     si, msg
    call    write_str
    jmp     $

msg: db "Jag tycker om min hund!", 0x0D, 0x0A, 0

