bits 16

section .text
    extern  write

    jmp     $
    mov     si, msg
    call    write
    jmp     $

msg: db "welcome to the kernel", 0x0D, 0x0A, 0
