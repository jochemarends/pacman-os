bits 16
org 0x07E00
    jmp     start

video_buffer equ 0

screen_w    equ 320
screen_h    equ 200
screen_size equ screen_w * screen_h

front_buffer equ 0xA0000
back_buffer  equ 0x10000

;----------------------------------------------------------
setup_vga:
; receives: none
; returns:  es = base address to the back buffer
;----------------------------------------------------------
    push    ax
    push    bp
    mov     ah, 0x00
; use VGA video mode 13h
    mov     al, 0x13
    int     0x10
; set the base address of the extra segment register to the back buffer
    mov     bp, back_buffer / 16
    mov     es, bp
    pop     bp
    pop     ax
    ret

;----------------------------------------------------------
setup_pit:
; receives: none
; returns:  none
;----------------------------------------------------------
    push    ax
    mov     al, 0x36
    out     0x43, al
; set frequency of PIT 100 hz
    mov     ax, 11931 
    out     0x40, al
    mov     al, ah
    mov     [0x0020], dword pit_handler
    pop     ax
    ret

;----------------------------------------------------------
setup_kb:
; receives: none
; returns:  none
;----------------------------------------------------------
    mov     [0x0024], dword kb_handler
    ret

;----------------------------------------------------------
pit_handler:
; receives: none
; returns:  none
;----------------------------------------------------------
    push    ax
; send EOI signal to the PIC
    mov     al, 0x20
    out     0x20, al
    pop     ax
    iret

;----------------------------------------------------------
kb_handler:
; receives: none
; returns:  none
;----------------------------------------------------------
    pusha
    in      al, 0x60
    test    al, 0x80
    jnz     .button_up

.button_up:
; send EOI signal to the PIC
    mov     al, 0x20
    out     0x20, al
    popa
    iret

;----------------------------------------------------------
start:
; info:     entry point of kernel
; receives: none
; returns:  none
;----------------------------------------------------------
    call    setup_vga
    call    setup_pit
    call    setup_kb
; fill the screen 
    mov     al, 0x02
    mov     cx, screen_size
    xor     di, di
    rep     stosb

    mov     si, img
    call    draw_image

    call    copy_back_buffer
    jmp     $

;----------------------------------------------------------
copy_back_buffer:
; info:     copies 64kB from the back buffer to the front 
;           buffer (vram)
; receives: none
; returns:  none
;----------------------------------------------------------
    pusha
    push    ds
    push    es
; set the source operand to the back buffer
    mov     bp, back_buffer / 16
    mov     ds, bp
    xor     si, si
; set the destination operand to the front buffer 
    mov     bp, front_buffer / 16
    mov     es, bp
    xor     di, di
 
    mov     cx, screen_size / 2
    rep     movsw

    pop     es
    pop     ds
    popa
    ret

img: db 16, 16
times (16 * 16) db 14

;----------------------------------------------------------
draw_image:
; receives: ds:si = address to image data
;           ds:bx = x-offset
;           ds:dx = y-offset
; returns:  none
;----------------------------------------------------------
    pusha
; load the width of the image (1st byte)
    lodsb
    mov     ah, al
; load the height of the image (2nd byte)
    lodsb
    xor     di, di
    jmp     .test_row
.draw_row:
    dec     al
; draw the image at the beginning of the buffer for now
    mov     bp, di
    movzx   cx, ah
    rep     movsb
    lea     di, [bp + screen_w]
; check whether there is a row to draw
.test_row:
    test    al, al
    jnz     .draw_row
    popa
    ret


;----------------------------------------------------------
draw_square:
; receives: al = colour
;           bx = top left x position
;           cx = top left y position
;           dx = size
; returns:  nothing
;----------------------------------------------------------
    pusha
    mov     di, bx
    push    ax
    push    dx
    mov     ax, cx
    mov     bx, screen_w
    mul     bx
    add     di, ax
    pop     dx
    pop     ax
    mov     cx, dx
    test    cx, cx
    jz      .done
.draw_row:
    push    cx
; save the offset to the beginning of the current row
    mov     si, di
    mov     cx, dx
    rep     stosb
    mov     di, si
; move the offset to the next row
    add     di, screen_w
    pop     cx
    loop    .draw_row
.done:
    popa
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

times 512-($-$$) db 0