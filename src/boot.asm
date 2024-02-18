bits 16

%include "io.inc"

section .text
    cli
    xor     ax, ax
    mov     ds ,ax
    mov     ss, ax
    mov     es, ax
    mov     sp, 0x7C00
    mov     [boot_drive], dl

    mov     ah, 0x00            ; reset disk drives
    int     0x13                ; low-level disk services

    mov     ah, 0x02            ; read sectors from drive
    mov     al, 4               ; number of sectors to read
    mov     ch, 0               ; cylinder
    mov     cl, 2               ; sector
    mov     dh, 0               ; header
    mov     dl, [boot_drive]
    xor     bp, bp
    mov     es, bp
    mov     bx, 0x7E00
    int     0x13                ; low-level disk services

    mov     si, msg
    call    write_str
    jmp     $

msg: db "TODO: load more sectors from disk!", 0x0D, 0x0A, 0
boot_drive: db 0

times 510-($-$$) db 0   ; padding
db 0x55, 0xAA           ; boot signature

