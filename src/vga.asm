
extern vga_mode_0x13_test

section .boot

vga_mode_0x13_test:
    push    ax
    mov     ah, 0x00
    mov     al, 0x13
    int     0x10
    pop     ax
    ret

