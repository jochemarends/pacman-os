bits 16
org 0x07E00
    jmp     start
;----------------------------------------------------------
;
; 
;----------------------------------------------------------

screen_w    equ 640
screen_h    equ 480
screen_size equ screen_w * screen_h

plane_row_size equ screen_w / 8

front_buffer equ 0xA0000
back_buffer  equ 0x10000

tile_w equ 8
tile_h equ 8

map_cols equ 28
map_rows equ 36
map_tile_count equ map_cols * map_rows

map_w equ tile_w * map_cols
map_h equ tile_h * map_rows
map_x equ plane_row_size / 2 - map_w / 2
map_y equ screen_h / 2 - map_h / 2

seq_index_register equ 0x03C4
seq_data_register  equ 0x03C5

crt_index_register equ 0x03D4
crt_data_register  equ 0x03D5

;----------------------------------------------------------
setup_vga:
; receives: none
; returns:  es = base address to the back buffer
;----------------------------------------------------------
    push    ax
    push    bp
    mov     ah, 0x00
; use VGA video mode 13h
    mov     al, 0x12
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


buflen equ 38400
rowlen equ buflen / 480

;----------------------------------------------------------
start:
; info:     entry point of kernel
; receives: none
; returns:  none
;----------------------------------------------------------
    call    setup_vga
    call    setup_pit
    call    setup_kb

.loop:
    mov     dx, seq_index_register
    mov     al, 0x02
    out     dx, al

    mov     dx, seq_data_register
    mov     al, 0x01
    out     dx, al

; fill the screen 
    mov     bp, 0xA000
    mov     es, bp
    mov     al, 0xFF
    mov     cx, buflen
    xor     di, di
    rep     stosb

    mov     al, 0xFF
    
    xor     di, di
    mov     cx, 28
   ; rep     stosb
    
    xor     di, di
    add     di, rowlen / 2 - 28/2
    add     di, rowlen * (240 - 36*4)
    mov     cx, 8 * 36
    xor     bx, bx
.draw_tile:
    push    di
    push    cx
    mov     al, [tile + bx]
    mov     cx, 28
    rep     stosb
    inc     bx
    and     bx, 0b00000111
    pop     cx
    pop     di
    add     di, rowlen
    loop    .draw_tile

    mov     dx, seq_index_register
    mov     al, 0x02
    out     dx, al

    mov     dx, seq_data_register
    mov     al, 0x01
    out     dx, al

plane_size equ plane_row_size * screen_h

    mov     dx, crt_index_register
    mov     al, 0x0C
    out     dx, al
    mov     dx, crt_data_register
    mov     al, 64000 >> 8 ;plane_size >> 8 
    out     dx, al

    mov     dx, crt_index_register
    mov     al, 0x0D
    out     dx, al
    mov     dx, crt_data_register
    mov     al, 64000 & 0xFF ;cplane_size & 0x00FF
    out     dx, al

    
    push    es
    mov     bp, (0xA0000 + 64000) / 16
    mov     es, bp
    mov     al, 0xFF
    mov     cx, plane_size ;25600
    xor     di, di
    rep     stosb
    pop     es
    jmp     $

    mov     dx, crt_index_register
    mov     al, 0x0C
    out     dx, al
    mov     dx, crt_data_register
    mov     al, 0x00
    out     dx, al

    mov     dx, crt_index_register
    mov     al, 0x0D
    out     dx, al
    mov     dx, crt_data_register
    mov     al, 0x00
    out     dx, al
    jmp     $
    ;call    draw_map
    jmp     .loop

map: times (map_cols * map_rows) db 0x00

swap_buffers:


;----------------------------------------------------------
draw_map:
; receives: none
; returns:  none
;----------------------------------------------------------
    mov     si, tile
    xor     di, di
    mov     cx, map_cols
.draw_map_row:
.draw_tile:
    push    di
    mov     bx, tile_h
    mov     si, tile
.draw_tile_row:
    push    di
    movsb
    pop     di
    add     di, plane_row_size
    dec     bx
    jnz     .draw_tile_row
    pop     di
    inc     di
    loop    .draw_tile
    ret

;----------------------------------------------------------
draw_tile:
; receives: none
; returns:  none
;----------------------------------------------------------
    mov     si, tile
    xor     di, di
    ret


;----------------------------------------------------------
draw_bin_image:
; receives: es:si = address to image data
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
    shr     cx, 3
    rep     movsb
    mov     cl, byte [di]
    and     cx, 0x07

    lea     di, [bp + screen_w]
; check whether there is a row to draw
.test_row:
    test    al, al
    jnz     .draw_row
    popa
    ret

tile:
; left corner tile
db 0b00001111
db 0b00110000
db 0b01000000
db 0b01000111
db 0b10001000
db 0b10010000
db 0b10010000
db 0b10010000


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
 
    ;mov     cx, screen_size / 2
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

times 4*512-($-$$) db 0