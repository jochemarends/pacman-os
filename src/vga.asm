bits 16

extern vga_mode_0x13_test

%include "write.inc"

section .text

vga_mode_0x13_test:
    push    ax
    push    es
; entering mode 0x13
    mov     ah, 0x00
    mov     al, 0x13
    int     0x10
; writing to the first pixel (top left corner)
    mov     ax, 0xA000
    mov     es, ax
    inc     byte [es:0x0000]
    pop     es
    pop     ax
    ret

msg: db "debug", 0x0D, 0x0A, 0

