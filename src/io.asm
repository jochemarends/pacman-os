bits 16

section .text

extern write_str

;----------------------------------------------------------
write_str:
; receives: si = pointer to a null-terminated string.
; returns:  nothing
;----------------------------------------------------------
    push    ax
    push    bx
    push    si
    cld
.loop:
    lodsb
    or      al, al
    jz      .done
    mov     ah, 0x0E
    mov     bh, 0x00
    int     0x10
    jmp     .loop
.done:
    pop     si
    pop     bx
    pop     ax
    ret

