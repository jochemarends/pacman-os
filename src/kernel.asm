[BITS 16]

start:
    mov     si, msg
    call    write
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