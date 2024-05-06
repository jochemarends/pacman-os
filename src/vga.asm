bits 16

global vga_mode_0x13_test
global vga_mode_0x10_test

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
; drawing a rectangle of 40x40 (top left corner)
    mov     cx, 40
    mov     al, 1
    xor     di, di
.loop:
    push    cx
    mov     cx, 40
    rep     stosb
    add     di, 280
    pop     cx
    sub     cx, 1
    jnz     .loop

    pop     es
    pop     ax
    ret

msg: db "debug", 0x0D, 0x0A, 0

vga_mode_0x10_test:
    push    ax
    push    es
; entering mode 0x10
    mov     ah, 0x00
    mov     al, 0x10
    int     0x10
; writing to the first pixel (top left corner)
    mov     al, 0x02
    mov     ah, 0x02
    mov     dx, 0x3C4
    out     dx, ax

    mov     ax, 0xA000
    mov     es, ax
    inc     byte [es:0x0000]

    cld
    mov     al, 0xFF
    mov     cx, (640 + 320) / 8
    xor     di, di
    rep     stosb

    pop     es
    pop     ax
    ret

