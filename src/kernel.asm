[BITS 16]

start:
    mov     si, msg
    call    write

    mov     ah, 0x00
    mov     al, 0x13
    int     0x10

    xor     ax, ax
.loop:
    cld
    mov     cx, 0xFA00
    mov     bp, 0xA000
    mov     es, bp
    xor     di, di
    rep     stosb
    mov     al, 1
    jmp     .loop

    jmp     $

msg: db "welkom in de kernel!", 0x0D, 0x0A, 0

;----------------------------------------------------------
write:
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

times 512-($-$$) db 0