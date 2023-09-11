bits 16
org 0x7C00

    cli
    xor     ax, ax
    mov     ds, ax
    mov     ss, ax
    mov     sp, 0x7C00

    mov     si, msg
    call    write

    mov     [boot_drive], dl    ; saving the bootdrive

    mov     ah, 0x02
    mov     al, 4               ; number of sectors to read
    mov     ch, 2               ; cylinder
    mov     cl, 2               ; sector
    mov     dh, 0               ; header
    mov     dl, 
    
    jmp     $
    
msg: db "hoi!", 0x0D, 0x0A, 0
boot_drive: db 0

;----------------------------------------------------------
read_disk:
;----------------------------------------------------------

;----------------------------------------------------------
lba_to_chs:
;----------------------------------------------------------

;----------------------------------------------------------
u16_to_bin:
;----------------------------------------------------------
    push    bx
    push    cx
    push    di

    cld
    mov     bx, ax
; add prefix
    mov     ax, "0b"
    stosw
; convert each bit
    mov     cx, 16
.L1:
    mov     al, "0"
    shl     bx, 1
    adc     al, 0
    stosb
    loop    .L1
; add null-terminator
    mov     BYTE [di], 0

    pop     di
    pop     cx
    pop     bx
    ret

;----------------------------------------------------------
u16_to_hex:
; receives: ax = the unsigned value to convert.
;           si = pointer to a buffer that can hold at least 
;                seven bytes.
; returns:  nothing
;----------------------------------------------------------
    push    ax
    push    bx
    push    cx
    push    dx
    push    di

    cld
    mov     dx, ax
; add prefix
    mov     ax, "0x"
    stosw
; convert each nibble
    mov     cx, 4
.L1:
    rol     dx, 4
    mov     bx, dx
    and     bx, 0x0F
    mov     al, [bx + .digits]
    stosb
    loop    .L1
; add null-terminator
    mov     BYTE [di], 0
    
    pop     di
    pop     dx
    pop     cx
    pop     bx
    pop     ax
    ret
.digits: db "0123456789ABCDEF", 0

;----------------------------------------------------------
u16_to_dec:
; receives: ax = the unsigned value to convert.
;           si = pointer to a buffer that can hold at least 
;                seven bytes.
; returns:  nothing
;----------------------------------------------------------
    push    ax
    push    bx
    push    cx
    push    dx
    push    di

    cld
    xor     cx, cx
.L1:
    xor     dx, dx
    mov     bx, 10
    div     bx
    add     dx, "0"
    push    dx
    inc     cx
    or      ax, ax
    jnz     .L1
.L2:
    pop     ax
    stosb
    loop    .L2
; add null-terminator
    mov     BYTE [di], 0

    pop     di
    pop     dx
    pop     cx
    pop     bx
    pop     ax
    ret

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

    times 510-($-$$) db 0   ; padding
    dw 0xAA55               ; boot signature