BITS 16
ORG 0x7C00

    cli
    xor     ax, ax
    mov     ds, ax
    mov     ss, ax
    mov     sp, 0x7C00

    mov     si, msg
    call    write

    mov     ax, 0xABC7
    mov     si, buf
    call    u16_to_hex
    mov     si, buf
    call    write

    jmp     $
 
msg: db "hoi!", 0x0D, 0x0A, 0
buf: times 20 db 0

;----------------------------------------------------------
read_disk:
;----------------------------------------------------------

;----------------------------------------------------------
lba_to_chs:
;----------------------------------------------------------

;----------------------------------------------------------
u16_to_hex:
; receives: ax = the unsigned value to convert.
;           si = pointer to a buffer that can hold at least 
;                seven bytes.
; returns:  nothing
;----------------------------------------------------------
    cld
    mov     di, si
    mov     dx, ax
; add prefix
    mov     ax, "0x"
    stosw
; loop over each nibble
    mov     cx, 4
.L1:
    rol     dx, 4
    mov     bx, dx
    and     bx, 0x0F
    mov     al, [bx + .digits]
    stosb
    loop    .L1
; add null-terminator ; hey
    mov     BYTE [di], 0
    mov     byte [di], 0
    ret
.digits: db "0123456789ABCDEF", 0

;----------------------------------------------------------
u16_to_dec:
; receives: ax = the unsigned value to convert.
;           si = pointer to a buffer that can hold at least 
;                seven bytes.
; returns:  nothing
;----------------------------------------------------------
    xor     cx, cx
; pushing ASCII digits on the stack
.L1:
    mov     bx, ax
    shr     ax, 4               ; quotient
    and     bx, 0x0F            ; remainder
    push    WORD [bx + .digits]
    inc     cx
    or      al, al
    jnz     .L1

; add a prefix
    mov     WORD [si], "0x"
    add     si, 2

    mov     ax, 4
    sub     ax, cx
.L2:
    mov     BYTE [si], "0"
    inc     si
    loop    .L2


; popping ASCII digits from the stack
.L3:
    pop     WORD [si]
    inc     si
    loop    .L3
    mov     BYTE [si], 0
    ret
.digits: db "0123456789ABCDEF", 0

;----------------------------------------------------------
write:
; receives: si = pointer to a null-terminated string.
; returns:  nothing
;----------------------------------------------------------
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
    ret

    times 510-($-$$) db 0   ; padding
    dw 0xAA55               ; boot signature