.include "common.i"

.bank $00 slot 0
.orga $0000

.section "rst_08" size $0008 overwrite

    push bc
    ld b, $00
    ld c, a
    add hl, bc
    pop bc
    ret

.ends

.bank $00 slot 0
.orga $0008

.section "rst_10" size $0008 overwrite

    jp execute_box_script
pop_and_return:
    pop hl
    pop de
    pop bc
    pop af
    ret

.ends

.bank $00 slot 0
.orga $0010

.section "rst_18" size $0008 overwrite

rst_10:
    jp wait_for_vblank
addr_lcd_stat_interrupt_standard:
    .addr lcd_stat_interrupt_standard

.ends

.bank $00 slot 0
.orga $0018

.section "rst_20" size $0008 overwrite

    jp hram.program_oam_dma

.ends

.bank $00 slot 0
.orga $0020

.section "rst_28" size $0008 overwrite

xr_execute_script:
    jp execute_script

.ends

.bank $00 slot 0
.orga $0028

.section "rst_30" size $0008 overwrite

    di
    call bank_switch
    reti

.ends

.bank $00 slot 0
.orga $0030

.section "rst_38" size $0008 overwrite

    jp read_script_stream_byte

.ends

.bank $00 slot 0
.orga $0040

.section "int_vblank" size $0008 overwrite

    jp ram_program_vblank_interrupt

.ends

.bank $00 slot 0
.orga $0048

.section "int_lcd_stat" size $0003 overwrite

    jp ram_program_lcd_stat_interrupt

.ends

.bank $00 slot 0
.orga $004b

.section "system" size $00b5 overwrite

scale_a_64x:
    add a, a
scale_a_32x:
    add a, a
scale_a_16x:
    add a, a
scale_a_8x:
    add a, a
scale_a_4x:
    add a, a
scale_a_2x:
    add a, a
    ret
scale_hl_128x:
    add hl, hl
scale_hl_64x:
    add hl, hl
scale_hl_32x:
    add hl, hl
scale_hl_16x:
    add hl, hl
scale_hl_8x:
    add hl, hl
scale_hl_4x:
    add hl, hl
scale_hl_2x:
    add hl, hl
    ret
add_bc_hl_128_x:
    add hl, hl
add_bc_hl_64_x:
    add hl, hl
add_bc_hl_32_x:
    add hl, hl
add_bc_hl_16_x:
    add hl, hl
add_bc_hl_8_x:
    add hl, hl
add_bc_hl_4_x:
    add hl, hl
add_bc_hl_2_x:
    add hl, hl
    add hl, bc
    ret
add_de_hl_128_x:
    add hl, hl
add_de_hl_64_x:
    add hl, hl
add_de_hl_32_x:
    add hl, hl
add_de_hl_16_x:
    add hl, hl
add_de_hl_8_x:
    add hl, hl
add_de_hl_4_x:
    add hl, hl
add_de_hl_2_x:
    add hl, hl
    add hl, de
    ret
memclear:
    xor a, a
memset:
    ldi (hl), a
    dec b
    jr nz, memset
    ret
memclear_16:
    xor a, a
memset_16:
    push af
    push de
    ld e, a
-   ld (hl), e
    inc hl
    dec bc
    ld a, c
    or a, b
    jr nz, -
    pop de
    pop af
    ret
memcopy:
    push af
-   ldi a, (hl)
    ld (de), a
    inc de
    dec b
    jr nz, -
    pop af
    ret
memcopy_16:
    push af
-   ldi a, (hl)
    ld (de), a
    inc de
    dec bc
    ld a, c
    or a, b
    jr nz, -
    pop af
    ret
vram_memset:
    call vram_enable
    call memset
    jr +
vram_memset_16:
    call vram_enable
    call memset_16
    jr +
vram_memcopy:
    call vram_enable
    call memcopy
    jr +
vram_memcopy_16:
    call vram_enable
    call memcopy_16
+   jp vram_disable
memcopy_from_bank:
    rst $28
    push af
    call memcopy
    jr +
memcopy_16_from_bank:
    rst $28
    push af
    call memcopy_16
    jr +
vram_memcopy_from_bank:
    rst $28
    push af
    call vram_memcopy
    jr +
vram_memcopy_16_from_bank:
    rst $28
    push af
    call vram_memcopy_16
+   pop af
    rst $28
    ret
read_from_bank:
    push bc
    rst $28
    ld c, (hl)
    rst $28
    ld a, c
    pop bc
    ret
wait_for_vblank:
    push af
    call setup_oam_dma
-   halt
    ldh a, (<LY)
    cp a, $90
    jr c, -
    pop af
    ret
ram_program_data:
    ld sp, $0000
    ret
    ld a, $00
    jp $0000
    bit 0, a
    ret
hram_program_data:
    ldh (<DMA), a
    ld a, $28
-   dec a
    jr nz, -
    ret

.ends

.bank $00 slot 0
.orga $0100

.section "entry" size $0004 overwrite

    nop
    jp main

.ends


