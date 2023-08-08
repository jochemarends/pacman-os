BITS 16
org 0x7C00

%macro write 1
    
%endmacro 

this:
    cli
    xor     ax, ax
    mov     ds, ax
    mov     ss, ax
    mov     sp, 0x7C00

    mov     si, msg
    call    write

    push    0
    mov     ax, 16
    mov     di, buf
    call    u16_to_bin
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