.include "common.i"

.bank $00 slot 0
.orga $0150

.section "general_header" size $00b0 overwrite

x_multiply_8_8:
    jp multiply_8_8
x_divide_8_8:
    jp divide_8_8
x_subtract_16_16:
    jp subtract_16_16
x_compare_16_16:
    jp compare_16_16
x_multiply_16_16:
    jp multiply_16_16
x_divide_16_16:
    jp divide_16_16
x_add_24_24:
    jp add_24_24
x_subtract_24_24:
    jp subtract_24_24
x_compare_24_24:
    jp compare_24_24
x_random_integer:
    jp random_integer
x_game_update:
    jp game_update
x_process_button_press_events:
    jp process_button_press_events
x_wait_for_release:
    jp wait_for_release
x_vram_enable:
    jp vram_enable
x_vram_disable:
    jp vram_disable
x_far_call:
    jp far_call
x_multiply_24_8:
    jp multiply_24_8
x_divide_24_8:
    jp divide_24_8
x_draw_tile_rectangle:
    jp draw_tile_rectangle
x_wait_for_line_0x90:
    jp wait_for_line_0x90
x_test_chest_flag:
    jp test_chest_flag
x_set_chest_flag:
    jp set_chest_flag
x_get_script_var:
    jp get_script_var
x_set_script_var:
    jp set_script_var
x_test_script_var_0:
    jp test_script_var_0
x_add_player_offset:
    jp add_player_offset
x_load_player:
    jp load_player
x_fc_menu_start:
    jp fc_menu_start
x_fc_menu_party_order:
    jp fc_menu_party_order
x_read_buttons:
    jp read_buttons
x_bank_switch:
    jp bank_switch
x_draw_box_script:
    jp draw_box_script
x_menu_cursor_clear_position:
    jp menu_cursor_clear_position
x_menu_cursor_stops_clear:
    jp menu_cursor_stops_clear
x_menu_cursor_stops_clear_keep_selection:
    jp menu_cursor_stops_clear_keep_selection
x_execute_menu_cursor_with_options:
    jp execute_menu_cursor_with_options
x_decode_player_index:
    jp decode_player_index
x_script_window_push:
    jp script_window_push
x_script_window_pop:
    jp script_window_pop
x_execute_box_script_with_options:
    jp execute_box_script_with_options
x_sram_disable:
    jp sram_disable
x_sram_enable:
    jp sram_enable
x_script_window_write_frame:
    jp script_window_write_frame
x_draw_script_window:
    jp draw_script_window
x_fc_monster_gfx_setup:
    jp fc_monster_gfx_setup
x_fc_load_monster_gfx_dimensions:
    jp fc_load_monster_gfx_dimensions
x_fc_load_monster_gfx_address:
    jp fc_load_monster_gfx_address
x_fc_menu_meat:
    jp fc_menu_meat
x_fc_battle_animation:
    jp fc_battle_animation
x_fc_process_monster_gfx:
    jp fc_process_monster_gfx
x_test_memo_flag:
    jp test_memo_flag
x_execute_shop_command:
    jp execute_shop_command
x_oam_dma_standard:
    jp oam_dma_standard
x_load_standard_npc_gfx:
    jp load_standard_npc_gfx
x_end_battle_mode:
    jp end_battle_mode

.ends

.bank $00 slot 0
.orga $0200

.section "general" size $1700 overwrite

main:
    di
    ld sp, stack_top
    ld a, $80
    ldh (<LCDC), a
    xor a, a
    ldh (<IF), a
    ldh (<IE), a
    ldh (<STAT), a
    ldh (<BGP), a
    ldh (<OBP0), a
    ldh (<OBP1), a
    ldh (<SCX), a
    ldh (<SCY), a
    ld b, a
    ld a, $1b
    ld hl, soft_reset_sentinel
    push hl
    cp a, (hl)
    inc hl
    jr nz, +
    cpl
    cp a, (hl)
    jr nz, +
    inc b
+   push bc
    ld hl, $c000
    ld b, $a0
    call memclear
    ld hl, $c100
    ld bc, $0d00
    call memclear_16
    ld h, $cf
    ld b, $11
    call memclear_16
    ld hl, $ff80
    ld b, $7f
    call memclear
    pop bc
    pop hl
    ld a, $1b
    ldi (hl), a
    cpl
    ldi (hl), a
    ld (hl), b
    inc b
    dec b
    jr nz, +
    ld b, $40
    ld hl, random_seeds
    ldh a, (<DIV)
-   ldi (hl), a
    inc a
    dec b
    jr nz, -
+   ld hl, script_stack_pointer
    ld (hl), <script_stack_base
    inc hl
    ld (hl), >script_stack_base
    ld hl, hram_program_data
    ld de, hram.program_oam_dma
    ld b, $08
    call memcopy
    ld hl, ram_program_data
    ld de, ram_program_load_sp
    ld b, $0c
    call memcopy
    ld a, :xe_reset_audio
    rst $28
    call xe_reset_audio
    di
    xor a, a
    ldh (<LYC), a
    ldh (<IF), a
    ld a, $03
    ldh (<IE), a
    ld a, $40
    ldh (<STAT), a
    ld hl, ram_program_vblank_interrupt
    ld a, $c3
    ldi (hl), a
    ld a, <vblank_interrupt_standard
    ldi (hl), a
    ld a, >vblank_interrupt_standard
    ldi (hl), a
    ld hl, ram_program_lcd_stat_interrupt
    ld a, $c3
    ldi (hl), a
    ld a, <lcd_stat_interrupt_standard
    ldi (hl), a
    ld a, >lcd_stat_interrupt_standard
    ld (hl), a
    call load_standard_npc_gfx
    ld hl, data_font
    ld bc, $0800
    ld a, :data_font
    call vram_memcopy_16_from_bank
    call sram_enable
    ld hl, sram.sentinel
    ldi a, (hl)
    cp a, $1b
    jr nz, +
    ld a, (hl)
    cp a, $e4
    jr z, ++
+   ld a, $01
    ld (sram.save_count), a
++  call sram_disable
    ld hl, player.1.name
    ld c, $04
-   ld b, $04
    ld a, $ff
    call memset
    ld a, $1c
    rst $00
    dec c
    jr nz, -
    ld a, :x1_menu_main
    rst $28
    call x1_menu_main
    jp nc, x_new_game
    jp x_continue_game
multiply_8_8:
    push af
    push bc
    ld b, $08
    xor a, a
    ld c, a
-   rr h
    jr nc, +
    add a, l
+   rra
    rr c
    dec b
    jr nz, -
    ld h, a
    ld l, c
    pop bc
    pop af
    ret
divide_8_8:
    push af
    push bc
    ld a, l
    cpl
    ld c, a
    inc c
    xor a, a
    ld b, $08
-   sla h
    rla
    add a, c
    jr c, +
    add a, l
    inc h
+   dec b
    jr nz, -
    ld l, a
    ld a, h
    cpl
    ld h, a
    pop bc
    pop af
    ret
multiply_16_16:
    push af
    push bc
    ld c, l
    ld b, h
    ld hl, $0000
    ld a, $10
-   rr d
    rr e
    jr nc, +
    add hl, bc
+   rr h
    rr l
    dec a
    jr nz, -
    rr d
    rr e
    pop bc
    pop af
    ret
divide_16_16:
    di
    push af
    push bc
    ld c, l
    ld b, h
    ld hl, _divide_16_16_tail
    push hl
    ld (ram_program_load_sp.payload), sp
    ld a, e
    cpl
    ld l, a
    ld a, d
    cpl
    ld h, a
    inc hl
    ld sp, hl
    ld hl, $0000
    ld a, $10
-   sla c
    rl b
    rl l
    rl h
    add hl, sp
    jr c, +
    add hl, de
    inc c
+   dec a
    jr nz, -
    jp ram_program_load_sp
_divide_16_16_tail:
    push hl
    ld a, c
    cpl
    ld l, a
    ld a, b
    cpl
    ld h, a
    pop de
    pop bc
    pop af
    reti
subtract_16_16:
    ldh (<hram.temp.1), a
    push de
    ld a, l
    sub a, e
    ld l, a
    ld a, h
    sbc a, d
    ld h, a
    jr c, +
    or a, l
    jr ++
+   or a, l
    scf
++  pop de
    ldh a, (<hram.temp.1)
    ret
compare_16_16:
    push hl
    call subtract_16_16
    pop hl
    ret
add_24_24:
    ldh (<hram.temp.1), a
    push de
    push hl
    ld a, (de)
    add a, (hl)
    ld (de), a
    inc de
    inc hl
    ld a, (de)
    adc a, (hl)
    ld (de), a
    inc de
    inc hl
    ld a, (de)
    adc a, (hl)
    ld (de), a
    pop hl
    pop de
    ldh a, (<hram.temp.1)
    ret
subtract_24_24:
    ldh (<hram.temp.1), a
    push bc
    push de
    push hl
    ld a, (de)
    sub a, (hl)
    ld (de), a
    ld c, a
    inc de
    inc hl
    ld a, (de)
    sbc a, (hl)
    ld (de), a
    ld b, a
    inc de
    inc hl
    ld a, (de)
    sbc a, (hl)
    ld (de), a
    jr +
compare_24_24:
    ldh (<hram.temp.1), a
    push bc
    push de
    push hl
    ld a, (de)
    sub a, (hl)
    ld c, a
    inc de
    inc hl
    ld a, (de)
    sbc a, (hl)
    ld b, a
    inc de
    inc hl
    ld a, (de)
    sbc a, (hl)
+   jr c, +
    or a, c
    or a, b
    jr ++
+   or a, c
    or a, b
    scf
++  pop hl
    pop de
    pop bc
    ldh a, (<hram.temp.1)
    ret
multiply_24_8:
    push af
    push bc
    push de
    push hl
    push de
    ld l, e
    ld h, d
    ld e, (hl)
    inc hl
    ld d, (hl)
    inc hl
    ld l, (hl)
    ld h, a
    ld b, $18
    xor a, a
-   rr l
    rr d
    rr e
    jr nc, +
    add a, h
+   rra
    dec b
    jr nz, -
    rr l
    rr d
    rr e
    ld c, l
    pop hl
    ld (hl), e
    inc hl
    ld (hl), d
    inc hl
    ld (hl), c
    inc hl
    ld (hl), a
    jp pop_and_return
divide_24_8:
    push bc
    push de
    push hl
    ld l, e
    ld h, d
    ld c, a
    cpl
    ld b, a
    inc b
    push hl
    ld e, (hl)
    inc hl
    ld d, (hl)
    inc hl
    ld a, (hl)
    ld h, c
    ld c, a
    xor a, a
    ld l, $18
-   sla e
    rl d
    rl c
    rla
    add a, b
    jr c, +
    add a, h
    inc e
+   dec l
    jr nz, -
    pop hl
    ld b, a
    ld a, e
    cpl
    ldi (hl), a
    ld a, d
    cpl
    ldi (hl), a
    ld a, c
    cpl
    ld (hl), a
    ld a, b
    pop hl
    pop de
    pop bc
    ret
random_integer:
    push de
    push hl
    ld hl, random_seeds
    rst $00
    inc (hl)
    ld l, (hl)
    ld h, $40
    ld a, $0f
    rst $28
    ld h, (hl)
    rst $28
    ld a, e
    cp a, $ff
    jr z, +
    ld a, d
    and a, a
    jr z, +
    cp a, e
    jr z, +
    sub a, e
    ld l, a
    cp a, $ff
    ld a, h
    jr z, ++
    inc l
    call divide_8_8
    ld a, l
++  add a, e
+   pop hl
    pop de
    ret
process_button_press_events:
    ldh a, (<hram.joyp_raw)
    ld c, a
    ld a, (joyp_previous)
    cp a, c
    jr nz, +
    ld a, (joyp_counter)
    dec a
    jr z, ++
    ld (joyp_counter), a
    xor a, a
    ldh (<hram.joyp_button), a
    ret
++  ld a, $05
    ld (joyp_counter), a
    ld a, c
    ldh (<hram.joyp_button), a
    ret
+   ld a, $1e
    ld (joyp_counter), a
    ld a, c
    ldh (<hram.joyp_button), a
    ld (joyp_previous), a
    ret
read_buttons:
    call process_button_press_events
    call wait_for_vblank_and_oam_dma
    ldh a, (<hram.joyp_button)
    ret
wait_for_release:
    push af
-   rst $10
    ldh a, (<hram.joyp_raw)
    and a, a
    jr nz, -
    pop af
    ret
wait_for_release_dma:
    push af
-   call wait_for_vblank_and_oam_dma
    ldh a, (<hram.joyp_raw)
    and a, a
    jr nz, -
    pop af
    ret
bank_switch:
    push bc
    ld c, a
    ldh a, (<hram.bank)
    ld b, a
    ld a, c
    ldh (<hram.bank), a
    ld ($2100), a
    ld a, b
    pop bc
    ret
far_call:
    push af
    push hl
    push de
    ld hl, sp+$06
    ld a, (hl)
    ld e, a
    add a, $03
    ldi (hl), a
    ld d, (hl)
    jr nc, +
    inc (hl)
+   ld l, e
    ld h, d
    ldi a, (hl)
    ld (ram_program_far_call.addr), a
    ldi a, (hl)
    ld (ram_program_far_call.addr+1), a
    ld a, (hl)
    rst $28
    ld e, a
    ld hl, sp+$05
    ld a, (hl)
    di
    ld (hl), e
    ld (ram_program_far_call.bank), a
    pop de
    pop hl
    pop af
    dec sp
    ei
    call ram_program_far_call
    push af
    push hl
    ld hl, sp+$04
    ld a, (hl)
    rst $28
    pop hl
    pop af
    inc sp
    ret
sram_disable:
    push af
    xor a, a
    ld ($0000), a
    pop af
    reti
sram_enable:
    di
    push af
    ld a, $0a
    ld ($0000), a
    pop af
    ret
test_bit:
    push bc
    ld b, a
    ld a, c
    ld c, $47
    jr +
set_bit:
    push bc
    ld b, a
    ld a, c
    ld c, $c7
    jr +
clear_bit:
    push bc
    ld b, a
    ld a, c
    ld c, $87
+   and a, $07
    rlca
    rlca
    rlca
    or a, c
    ld (ram_program_bit.payload), a
    ld a, b
    call ram_program_bit
    pop bc
    ret
scale_8x:
    push af
    ld a, d
    add a, a
    add a, a
    add a, a
    ld d, a
    ld a, e
    add a, a
    add a, a
    add a, a
    ld e, a
    pop af
    ret
menu_cursor_stops_clear:
    xor a, a
    ldh (<hram.current_cursor), a
menu_cursor_stops_clear_keep_selection:
    xor a, a
    ld (cursor_stop_count), a
    ld (non_scrolling_cursor_stop_count), a
    dec a
    ld b, $80
    ld hl, cursor_stops
    jp memset
menu_cursor_clear_position:
    ld hl, hram.cursor.y
    ld a, $ff
    ldi (hl), a
    ldi (hl), a
    ldi (hl), a
    ld (hl), a
    ret
load_standard_npc_gfx:
    ld hl, data_standard_npc_gfx
    ld de, $8700
    ld b, $00
    ld a, :data_standard_npc_gfx
    jp vram_memcopy_from_bank
load_player:
    ldh (<hram.temp.1), a
    ld a, :data_monsters
    rst $28
    push af
    ldh a, (<hram.temp.1)
    ld l, a
    ld h, $0a
    call multiply_8_8
    ld de, data_monsters
    add hl, de
    push hl
    ld a, (player_index)
    ld hl, player.1.monster_id
    call add_player_offset
    ld e, l
    ld d, h
    ldh a, (<hram.temp.1)
    ld (de), a
    inc de
    pop hl
    ldi a, (hl)
    inc hl
    ldh (<hram.temp.3), a
    swap a
    and a, $0f
    ld (de), a
    ldh (<hram.temp.2), a
    inc de
    xor a, a
    ld (de), a
    inc de
    ld c, (hl)
    inc hl
    ld b, (hl)
    inc hl
    ld a, c
    ld (de), a
    inc de
    ld a, b
    ld (de), a
    inc de
    ld a, c
    ld (de), a
    inc de
    ld a, b
    ld (de), a
    inc de
    ld b, $04
    call memcopy
    ldh a, (<hram.temp.3)
    and a, $07
    inc a
    ld b, a
    ldh (<hram.temp.1), a
    ldi a, (hl)
    ld h, (hl)
    ld l, a
    push de
-   ldi a, (hl)
    ld (de), a
    inc de
    inc de
    dec b
    jr nz, -
    pop de
    ld a, :data_item_usage
    rst $28
    ldh a, (<hram.temp.1)
    ld b, a
-   ld a, (de)
    inc de
    ld hl, data_item_usage
    rst $00
    ldh a, (<hram.temp.2)
    cp a, $03
    ld a, (hl)
    jr nz, +
    cp a, $fe
    jr z, +
    srl a
+   ld (de), a
    inc de
    dec b
    jr nz, -
    pop af
    rst $28
    ret
add_player_offset:
    push bc
    ld b, a
    ldh a, (<hram.battle_flag)
    and a, a
    jr z, +
    ld a, b
    add a, h
    ld h, a
    jr ++
+   ld a, b
    call decode_player_index
    call scale_a_32x
    rst $00
++  pop bc
    ret
decode_player_index:
    push bc
    cp a, $04
    jr c, +
    ld a, $04
    jr ++
+   ld b, a
    inc b
    ld a, (party_order)
    rlca
    rlca
-   rrca
    rrca
    dec b
    jr nz, -
    and a, $03
++  pop bc
    ret
test_script_var_0:
    ldh (<hram.temp.1), a
    push de
    ld e, $00
    call get_script_var
    and a, a
    pop de
    ldh a, (<hram.temp.1)
    ret
test_chest_flag:
    push bc
    push hl
    call chest_flag_helper
    ld a, (hl)
    call test_bit
    pop hl
    pop bc
    ret
set_chest_flag:
    push bc
    push hl
    call chest_flag_helper
    ld a, (hl)
    call set_bit
    ld (hl), a
    pop hl
    pop bc
    ret
chest_flag_helper:
    ld c, a
    srl a
    srl a
    srl a
    ld hl, chest_flags
    rst $00
    ld a, c
    and a, $07
    ld c, a
    ret
get_script_var:
    push hl
    call script_var_helper
    jr c, +
    swap a
+   and a, $0f
    pop hl
    ret
set_script_var:
    push de
    push hl
    and a, $0f
    ld d, a
    call script_var_helper
    jr c, +
    and a, $0f
    swap d
    jr ++
+   and a, $f0
++  or a, d
    ld (hl), a
    pop hl
    pop de
    ret
script_var_helper:
    ld a, e
    and a, $1f
    srl a
    push af
    ld hl, script_vars
    rst $00
    pop af
    ld a, (hl)
    ret
test_memo_flag:
    push bc
    push hl
    call memo_flag_helper
    call test_bit
    pop hl
    pop bc
    ret
memo_flag_helper:
    ld a, d
    add a, a
    ld hl, memo_flags
    rst $00
    bit 3, e
    jr z, +
    inc hl
+   ld a, e
    and a, $07
    ld c, a
    ld a, (hl)
    ret
oam_dma_standard:
    ld a, (oam_staging_region)
    rst $18
    ret
wait_for_vblank_and_oam_dma:
    push af
    push bc
    rst $10
    ld c, >oam_staging_cc
    ldh a, (<hram.battle_flag)
    and a, a
    jr nz, +
    ld a, (window_enabled)
    and a, a
    jr nz, +
    ldh a, (<hram.window_sprite_mode)
    rrca
    jr c, +
    rrca
    jr c, +
    ld a, (oam_staging_region)
    ld c, a
+   ld a, c
    rst $18
    pop bc
    pop af
    ret
setup_oam_dma:
    push bc
    push de
    push hl
    ld hl, sprite_frame_counter
    inc (hl)
    ld a, (hl)
    ld hl, oam_staging_c0
    and a, $10
    swap a
    or a, h
    ld h, a
    ld (oam_staging_region), a
    ld a, (oam_use_c0_c1)
    and a, a
    jr z, +
    ld b, $28
    ldh a, (<hram.window_sprite_mode)
    and a, a
    jr z, ++
    ld b, $24
++  ld c, $5a
    ld de, oam_staging_cc
-   ldi a, (hl)
    cp a, c
    jr c, ++
    xor a, a
++  ld (de), a
    inc e
    ldi a, (hl)
    ld (de), a
    inc e
    ldi a, (hl)
    ld (de), a
    inc e
    ldi a, (hl)
    ld (de), a
    inc e
    dec b
    jr nz, -
    ld a, >oam_staging_cc
    ld (oam_staging_region), a
+   pop hl
    pop de
    pop bc
    ret
end_battle_mode:
    xor a, a
    ldh (<hram.battle_flag), a
    ld (window_enabled), a
    ldh (<hram.window_sprite_mode), a
    ldh (<hram.arsenal_cloud.enable), a
    jp load_standard_npc_gfx
read_script_stream_byte:
    push de
    call get_script_stream_ptr
    ld a, (de)
    inc de
    call set_script_stream_ptr
    pop de
    ret
execute_script_instruction:
    xor a, a
    ld (chomp), a
    rst $30
execute_script_instruction_with_byte:
    cp a, $9e
    jr nc, print_tile
    cp a, $4e
    jr nc, +
execute_script_function_with_byte:
    ld hl, jt_script_instruction
    add a, a
    rst $00
    ld e, (hl)
    inc hl
    ld d, (hl)
    push de
    pop hl
    jp (hl)
+   ld hl, data_digraphs
    sub a, $4e
    add a, a
    rst $00
    ld a, :data_digraphs
    call read_from_bank
    inc hl
    push hl
    call print_tile
    pop hl
    ld a, :data_digraphs
    call read_from_bank
print_tile:
    call script_window_begin
    call script_window_write
    call script_window_set_ptr
    ldh a, (<hram.script_mode)
    and a, a
    ret z
    cp a, $04
    ret z
    ld hl, window_text_line_remaining
    dec (hl)
    cp a, $05
    ret z
    jp handle_text_delay
script_window_write:
    ld hl, window_text_screen_x
    inc (hl)
    call script_window_get_ptr
    ldi (hl), a
    ret
script_window_begin:
    push af
    ldh a, (<hram.script_mode)
    and a, a
    jr z, +
    cp a, $04
    jr z, +
    cp a, $05
    jr z, ++
    call si_0c_window_show
++  push bc
    push de
    push hl
    ld hl, window_text_line_remaining
    ld a, (hl)
    and a, a
    jr nz, ++
    dec hl
    ldi a, (hl)
    ld (hl), a
    call si_06_text_newline_x2
++  pop hl
    pop de
    pop bc
    ldh a, (<hram.script_mode)
    cp a, $05
    jr z, +
    call wait_for_vblank_and_oam_dma
+   pop af
    ret
script_window_get_line_start:
    ld a, (window_text_line_ptr)
    ld l, a
    ld a, (window_text_line_ptr+1)
    ld h, a
    ret
script_window_set_line_start:
    ld a, l
    ld (window_text_line_ptr), a
    ld a, h
    ld (window_text_line_ptr+1), a
    ret
script_window_get_ptr:
    push af
    ld a, (window_text_ptr)
    ld l, a
    ld a, (window_text_ptr+1)
    ld h, a
    pop af
    ret
script_window_set_ptr:
    push af
    ld a, l
    ld (window_text_ptr), a
    ld a, h
    ld (window_text_ptr+1), a
    pop af
    ret
get_script_stream_ptr:
    push hl
    ld hl, hram.script_instr_ptr
    ld e, (hl)
    inc hl
    ld d, (hl)
    pop hl
    ret
set_script_stream_ptr:
    push hl
    ld hl, hram.script_instr_ptr
    ld (hl), e
    inc hl
    ld (hl), d
    pop hl
    ret
initialize_script_stream_ptr:
    ld l, e
    ldh a, (<hram.script_mode)
    and a, a
    jr z, +
    dec a
    jr z, +
    dec a
    jr z, ++
    dec a
    jr nz, +
    ld a, (battle_script_index)
    ld l, a
+   ld h, $00
    jr +
++  ld h, d
    dec h
+   add hl, hl
    add hl, bc
    ldi a, (hl)
    ldh (<hram.script_instr_ptr), a
    ld a, (hl)
    ldh (<hram.script_instr_ptr+1), a
    ret
initialize_script_stream_bank:
    push af
    ldh a, (<hram.script_mode)
    and a, a
    jr z, +
    dec a
    jr z, +
    dec a
    jr z, ++
+   ld a, :data_scripts_1
    jr +
++  ld a, :data_scripts_2
+   rst $28
    ldh (<hram.script_saved_bank), a
    pop af
    ret
execute_script:
    push af
    push bc
    push de
    push hl
    ldh a, (<hram.battle_flag)
    and a, a
    ld a, $03
    ld bc, data_battle_scripts
    jr nz, +
    dec a
    ld bc, data_scripts_2
    inc d
    dec d
    jr nz, +
    ld bc, data_scripts_1
    ld a, e
    cp a, $70
    ld a, $01
    jr nz, +
    ld a, $04
    ldh (<hram.script_mode), a
    ld a, $14
    ld (window_width), a
    call initialize_script_stream_bank
    call initialize_script_stream_ptr
    ld hl, window_buffer_1
    ld bc, $0300
    ld a, $ff
    call memset_16
    ld hl, window_buffer_1+$14
    call script_window_set_line_start
    call script_window_set_ptr
-   call execute_script_instruction
    jr -
    ldh a, (<hram.script_saved_bank)
    rst $28
    jp pop_and_return
+   push af
    push bc
    push de
    ld hl, script_stack_pointer
    ld e, (hl)
    inc hl
    ld d, (hl)
    push hl
    ld hl, hram.script_mode
    ld b, $04
    call memcopy
    pop hl
    ld (hl), d
    dec hl
    ld (hl), e
    ld hl, next_script_stack_level
    ld a, (hl)
    ld (current_script_stack_level), a
    inc (hl)
    pop de
    pop bc
    pop af
    ldh (<hram.script_mode), a
    call initialize_script_stream_bank
    call initialize_script_stream_ptr
    ld a, $20
    ld (window_width), a
-   call execute_script_instruction
    jr -
    ldh a, (<hram.script_saved_bank)
    rst $28
    ld hl, script_stack_pointer
    ld e, (hl)
    inc hl
    ld d, (hl)
    push hl
    ld hl, hram.script_mode+$03
    ld b, $04
    call reverse_memcopy
    pop hl
    ld (hl), d
    dec hl
    ld (hl), e
    ld hl, next_script_stack_level
    dec (hl)
    ld a, (hl)
    dec a
    ld (current_script_stack_level), a
    jp pop_and_return
reverse_memcopy:
    dec de
    ld a, (de)
    ldd (hl), a
    dec b
    jr nz, reverse_memcopy
    ret
script_window_scroll:
    ld hl, $9c40
    ld de, $9c20
    ld b, $e0
    ldh a, (<hram.script_mode)
    cp a, $03
    jr z, +
    ld b, $a0
+   call vram_enable
    call memcopy
    ld b, $12
    ld hl, $9d01
    ldh a, (<hram.script_mode)
    cp a, $03
    jr z, +
    ld hl, $9cc1
+   ld a, $ff
    call memset
    call vram_disable
handle_text_delay:
    ld c, <hram.joyp_raw
    ld a, (text_control_setting)
    ld e, a
    rrca
    jr c, +
    ldh a, (c)
    rrca
    ret c
+   ld a, (text_speed)
    add a, a
    and a, a
    ret z
    ld b, a
-   ldh a, (c)
    bit 0, e
    jr nz, +
    bit 0, a
    ret nz
+   bit 1, e
    jr nz, +
    bit 1, a
    jr z, +
    inc b
+   call wait_for_vblank_and_oam_dma
    dec b
    jr nz, -
    ret
execute_box_script_with_options:
    ld (script_window_options), a
    call execute_box_script_helper
    ret
execute_box_script:
    push af
    push bc
    push de
    push hl
    xor a, a
    ld (script_window_options), a
    call execute_box_script_helper
    jp pop_and_return
execute_box_script_helper:
    xor a, a
    ldh (<hram.script_mode), a
    ld hl, window_address_flag
    ldi (hl), a
    ld (hl), a
    call initialize_script_stream_bank
    ld bc, data_menu_scripts
    call initialize_script_stream_ptr
    call get_script_stream_ptr
    ld hl, window_address_flag
    ld bc, box_script_x
    ld a, $02
-   ldh (<hram.temp.1), a
    ld a, (de)
    rla
    rl (hl)
    inc hl
    ld a, (de)
    inc de
    and a, $1f
    ld (bc), a
    inc bc
    ldh a, (<hram.temp.1)
    dec a
    jr nz, -
    ld l, $02
-   ld a, (de)
    inc de
    ld (bc), a
    inc bc
    dec l
    jr nz, -
    call set_script_stream_ptr
    ld hl, window_buffer_1
    ld bc, $0300
    ld a, (window_address_flag)
    and a, a
    jr z, +
    ld h, >window_buffer_2
    ld b, $04
+   ld a, $ff
    call memset_16
    ld hl, window_y_offsets
    ldh a, (<hram.battle_flag)
    and a, a
    jr nz, +
    ld a, (window_enabled)
    and a, a
    jr z, ++
    ld hl, window_y_offsets+$02
    jr +
++  ld hl, window_y_offsets+$04
+   ld de, window_ty_offset
    ld b, $02
    call memcopy
    ld hl, box_script_x
    ld de, window_text_screen_x
    ld a, (script_window_options)
    bit 1, a
    jr z, +
    ldi a, (hl)
    ld (de), a
    inc de
    ld (de), a
    inc de
    ldi a, (hl)
    ld (de), a
    jr ++
+   ldi a, (hl)
    inc a
    ld (de), a
    inc de
    ld (de), a
    inc de
    ld a, (hl)
    inc a
    ld (de), a
++  ld a, (window_ty_offset)
    ld c, a
    ld a, (hl)
    sub a, c
    jr nc, +
    xor a, a
+   ld (hl), a
    ld hl, box_script_width
    ld b, (hl)
    inc hl
    ld c, (hl)
    ld a, (script_window_options)
    bit 1, a
    jr nz, +
    call script_window_write_frame
+   ld a, (box_script_width)
    ld b, a
    ld a, (window_address_flag)
    and a, a
    jr z, +
    ld b, $22
+   ld a, (box_script_scroll_flag)
    and a, a
    jr z, +
    ld a, l
    ld (window_unscrolled_start), a
    ld a, h
    ld (window_unscrolled_start+1), a
    dec b
    dec b
    ld a, b
    rst $00
    jr ++
+   call box_script_initial_script_window_ptr
++  ld a, b
    ld (window_width), a
    call script_window_set_line_start
    call script_window_set_ptr
    ld hl, box_script_x
    ld de, box_script_last_screen_x
    ld c, (hl)
    inc hl
    ld b, (hl)
    inc hl
    ldi a, (hl)
    add a, c
    dec a
    ld (de), a
    inc de
    ld a, (hl)
    add a, b
    dec a
    ld b, a
    ld a, (window_ty_offset)
    ld c, a
    add a, b
    ld (de), a
    ld hl, box_script_x
    ld de, box_script_first_screen_x
    ldi a, (hl)
    ld (de), a
    inc de
    ld a, (hl)
    add a, c
    ld (de), a
    ld a, (box_script_scroll_flag)
    and a, a
    jr z, +
    ld a, (cursor_stop_count)
+   ld (non_scrolling_cursor_stop_count), a
-   call execute_script_instruction
    jr -
    di
    call process_window_sprites
    ei
    call draw_box_script
    ldh a, (<hram.script_saved_bank)
    rst $28
    ret
script_window_write_frame:
    dec b
    dec b
    dec c
    dec c
    ld e, b
    ld hl, window_buffer_1
    ld a, (window_address_flag)
    and a, a
    jr z, +
    ld hl, window_buffer_2
+   ld a, $f7
    call script_window_write_frame_helper
-   ldi (hl), a
    push af
    ld a, $ff
    ld b, e
    call memset
    pop af
    inc a
    ldi (hl), a
    dec a
    dec c
    jr nz, -
    inc a
    inc a
script_window_write_frame_helper:
    ldi (hl), a
    ld b, e
    inc a
    call memset
    inc a
    ldi (hl), a
    inc a
    ret
draw_box_script:
    ld a, (script_window_options)
    rrca
    ret c
    ld hl, box_script_x
    ld c, (hl)
    ld b, $9c
    inc hl
    ld l, (hl)
    ld h, $00
    call add_bc_hl_32_x
    ld e, l
    ld d, h
    ld a, (box_script_scroll_flag)
    and a, a
    jr z, +
    push de
    ld a, (box_script_width)
    inc a
    ld e, a
    ld d, >window_buffer_1
    ld hl, window_unscrolled_start
    ld c, (hl)
    inc hl
    ld b, (hl)
    ld a, (window_width)
    ld l, a
    ld a, (window_scroll_y_offset)
    ld h, a
    call multiply_8_8
    add hl, bc
    ld a, (window_address_flag)
    and a, a
    jr z, ++
    ld d, >window_buffer_2
    ld a, (window_scroll_x_offset)
    rst $00
++  ld a, (box_script_width)
    sub a, $02
    ld b, a
    ld a, (box_script_height)
    sub a, $02
    ld c, a
--  push bc
    push hl
-   ldi a, (hl)
    ld (de), a
    inc de
    dec b
    jr nz, -
    inc de
    inc de
    pop hl
    pop bc
    ld a, (window_width)
    rst $00
    dec c
    jr nz, --
    pop de
+   ld hl, box_script_width
    ld b, (hl)
    inc hl
    ld c, (hl)
draw_script_window:
    ld hl, window_buffer_1
    ld a, (window_address_flag)
    and a, a
    jr z, +
    ld hl, window_buffer_2
+   call draw_tile_rectangle
    call wait_for_vblank_and_oam_dma
    ld a, (window_y_offset)
    ldh (<WY), a
    ld a, $07
    ldh (<WX), a
    ld a, $e3
    ldh (<LCDC), a
    ret
box_script_initial_script_window_ptr:
    ld a, (script_window_options)
    bit 1, a
    ld a, (box_script_width)
    jr nz, +
    add a, a
    inc a
+   ld hl, window_buffer_1
    rst $00
    ret
draw_tile_rectangle:
    call vram_enable
-   push bc
    call memcopy
    pop bc
    ld a, $20
    sub a, b
    add a, e
    ld e, a
    jr nc, +
    inc d
+   dec c
    jr nz, -
    jp vram_disable
window_y_offsets:
    .db $08, $40
    .db $0a, $50
    .db $00, $00
si_00_exit:
    ldh a, (<hram.script_mode)
    and a, a
    jr z, +
    cp a, $03
    jr nc, +
    ld a, (current_script_stack_level)
    and a, a
    jr nz, +
    ld a, (window_enabled)
    and a, a
    jr z, +
    call si_0b_prompt
    call wait_for_release_dma
    call si_0d_window_hide
+   pop hl
    inc hl
    inc hl
    jp (hl)
si_31_nop:
    ret
si_12_var_inc:
    call read_script_stream_script_var
    cp a, $0f
    jr z, _L000
    inc a
    jr _L000
si_13_var_dec:
    call read_script_stream_script_var
    and a, a
    jr z, _L000
    dec a
_L000:
    jp set_script_var
read_script_stream_script_var:
    rst $30
    ld e, a
    jp get_script_var
si_14_var_set:
    rst $30
    ld e, a
    rst $30
    jr _L000
si_18_memo_set:
    call read_script_stream_nybbles
    call memo_flag_helper
    call set_bit
    jr +
si_40_memo_clear:
    call read_script_stream_nybbles
    call memo_flag_helper
    call clear_bit
+   ld (hl), a
    ret
read_script_stream_nybbles:
    rst $30
    ld e, a
    and a, $f0
    swap a
    ld d, a
    ld a, e
    and a, $0f
    ld e, a
    ret
si_17_item_test:
    rst $30
    ld b, $04
    ld hl, player.1.inventory
    ld de, $0010
-   ld c, $08
    call item_list_contains
    ret nc
    add hl, de
    dec b
    jr nz, -
    call test_script_var_0
    jr z, +
    ld c, $08
    call item_list_contains
    ret nc
+   ld hl, inventory
    ld c, $10
    call item_list_contains
    ret nc
    jr script_jump
si_43_stone_test:
    ld bc, $0000
-   ld a, c
    ld hl, player.1.status
    call add_player_offset
    bit 4, (hl)
    jr z, +
    inc b
+   inc c
    ld a, c
    cp a, $04
    jr c, -
    ld a, b
    cp a, $04
    ret z
    jr script_jump
si_15_var_test:
    rst $30
    ld e, a
    rst $30
    ld c, a
    and a, $0f
    ld b, a
    ld a, c
    and a, $f0
    swap a
    ld c, a
    call get_script_var
    inc b
    cp a, c
    jr c, script_jump
    cp a, b
    jr nc, script_jump
    ret
si_1a_magi_test_count:
    rst $30
    ld b, a
    inc b
    ld a, (magi_total)
    cp a, b
    ret c
    jr script_jump
si_1b_magi_test:
    rst $30
    ld hl, magi_list
    add a, a
    rst $00
    ld a, (hl)
    and a, $0f
    ret nz
    jr script_jump
si_37_encounter_check:
    ld de, $0003
    ld a, (encounter_result)
    and a, a
    ret z
    jp execute_script
si_44_music_test:
    rst $30
    ld c, a
    ldh a, (<hram.audio.bg_music)
    cp a, c
    ret z
    jr script_jump
si_45_defeated_test:
    rst $30
    ld c, a
    ld a, (defeat_count)
    cp a, c
    ret nc
    jr script_jump
si_16_prompt_yes_no:
    call menu_yes_no
    and a, a
    ret z
script_jump:
    call get_script_stream_ptr
    inc de
    inc de
    inc de
    inc de
    jp set_script_stream_ptr
si_4d_game_end:
    call far_call
    .addr x1_the_end
    .db :x1_the_end
    call si_0b_prompt
    jp main
si_4c_teleport_disable:
    ld a, $ff
    ld (teleport_disable), a
    ret
si_4b_memo:
    call si_18_memo_set
    jp execute_memo_script
si_49_text_save:
    rst $30
    and a, a
    jr z, +
    call sram_enable
    dec a
    jr z, ++
    dec a
    jr z, _L001
    dec a
    jr z, _L002
    dec a
    jr z, _L003
    ld bc, player.1.status-player.1
    call get_current_save_slot_address
    xor a, a
    call add_player_offset
    ld a, (hl)
    call get_highest_status
    and a, a
    jr nz, _L004
    ld bc, player.1.max_hp-player.1
    call get_current_save_slot_address
    xor a, a
    call print_stat_16
    jr _L005
+   ld a, (script_arg_save_slot)
    inc a
    jp print_number_8
++  ld bc, save_count-player.1
    jr +
_L001:
    ld bc, magi_total-player.1
+   call get_current_save_slot_address
    call print_number_8_cap_99
    jr _L005
_L002:
    ld bc, player.1.name-player.1
    call get_current_save_slot_address
    xor a, a
    call print_player_name
    jr _L005
_L003:
    ld bc, player.1.current_hp-player.1
    call get_current_save_slot_address
    xor a, a
    call print_stat_16
    jr _L005
_L004:
    call print_status
_L005:
    jp sram_disable
get_current_save_slot_address:
    ld a, (script_arg_save_slot)
    call scale_a_16x
    ld l, a
    ld h, $15
    call multiply_8_8
    add hl, bc
    ld bc, $a000
    add hl, bc
    ret
si_48_battle_graphics_swap:
    rst $30
    ld c, a
    rst $30
    ld b, a
    call far_call
    .addr x1_monster_gfx_morph
    .db :x1_monster_gfx_morph
    ret
si_0b_prompt:
    call wait_for_release_dma
-   call wait_for_vblank_and_oam_dma
    call process_button_press_events
    ldh a, (<hram.joyp_button)
    and a, a
    jr z, -
    jp wait_for_release_dma
si_10_npc_refresh:
    call x_refresh_npcs
    jp wait_for_vblank_and_oam_dma
si_11_wait:
    rst $30
    ld b, a
-   call wait_for_vblank_and_oam_dma
    call wait_for_vblank_and_oam_dma
    dec b
    jr nz, -
    ret
si_07_text_raw:
    rst $30
    jp print_tile
si_39_cursor_text:
    ld de, text_cursor_stops
    call add_cursor
    ld b, $01
    call print_spaces
    rst $30
    push af
    ld de, text_cursor_temp
    ld a, (de)
    ld hl, text_cursor_data
    rst $00
    inc a
    ld (de), a
    pop af
    ld (hl), a
    jp execute_script_instruction_with_byte
si_2e_cursor:
    ld de, cursor_stops
add_cursor:
    ld hl, cursor_stop_count
    ld a, (hl)
    inc (hl)
    ld l, a
    ld h, $00
    add hl, hl
    add hl, de
    ld de, window_text_screen_y
    ld a, (de)
    inc a
    ldi (hl), a
    dec de
    dec de
    ld a, (de)
    dec a
    ld (hl), a
    ret
si_08_sprite:
    rst $30
    cp a, $05
    jr c, +
    cp a, $ff
    jr z, ++
    sub a, $05
    ld hl, script_arg_monster
    rst $00
    ld e, $c0
    jr _L006
++  ld a, (player_index)
+   cp a, $04
    jr nz, +
    call test_script_var_0
    jr z, script_window_advance_x2
+   push af
    call get_status_display_parameter
    ld hl, player.1.monster_id
    ldh a, (<hram.battle_flag)
    and a, a
    jr z, +
    ld hl, battle.data.1.monster_id
+   pop af
    call add_player_offset
_L006:
    ld c, (hl)
    ld hl, window_sprite_count
    ld a, (hl)
    ld b, a
    inc a
    cp a, $08
    jr c, +
    xor a, a
+   ld (hl), a
    ld hl, window_sprites
    ld a, b
    add a, a
    add a, a
    rst $00
    ld a, b
    or a, e
    ldi (hl), a
    push hl
    ld a, c
    ld hl, data_monster_npc_gfx
    rst $00
    ld a, :data_monster_npc_gfx
    call read_from_bank
    ld hl, data_animation_type
    rst $00
    ld a, :data_animation_type
    call read_from_bank
    pop hl
    cp a, $01
    jr nz, +
    or a, $04
+   ldi (hl), a
    push hl
    ld hl, window_text_screen_y
    ld d, (hl)
    dec hl
    dec hl
    ld e, (hl)
    inc (hl)
    inc (hl)
    pop hl
    call scale_8x
    ld (hl), d
    inc hl
    ld (hl), e
    ld l, b
    ld h, $00
    ld de, $8000
    call add_de_hl_128_x
    ld e, l
    ld d, h
    ld a, c
    call load_monster_half_sprite
script_window_advance_x2:
    call script_window_get_ptr
    inc hl
    inc hl
    jr _L007
get_status_display_parameter:
    call get_player_status_base_address
    call add_player_offset
    ld a, (hl)
    call get_highest_status
    ld hl, data_status_display
    rst $00
    ld a, :data_status_display
    call read_from_bank
    ld e, a
    ret
si_01_text_right:
    ld hl, window_text_screen_x
    inc (hl)
    call script_window_get_ptr
    inc hl
    jr _L007
si_02_text_left:
    ld hl, window_text_screen_x
    dec (hl)
    call script_window_get_ptr
    dec hl
    jr _L007
si_03_text_up:
    ld hl, window_text_screen_y
    dec (hl)
    ld a, (window_width)
    cpl
    inc a
    ld b, $ff
    jr +
si_04_text_down:
    ld hl, window_text_screen_y
    inc (hl)
    ld a, (window_width)
    ld b, $00
+   ld c, a
    call script_window_get_line_start
    add hl, bc
    call script_window_set_line_start
    call script_window_get_ptr
    add hl, bc
    jr _L007
si_36_text_space:
    rst $30
    ld c, a
    ld hl, window_text_screen_x
    add a, (hl)
    ld (hl), a
    ld a, c
    call script_window_get_ptr
    rst $00
_L007:
    jp script_window_set_ptr
si_06_text_newline_x2:
    call si_05_text_newline
si_05_text_newline:
    ld hl, window_text_width
    ldd a, (hl)
    ld (hl), a
    ldh a, (<hram.script_mode)
    and a, a
    jr z, +
    cp a, $04
    jr nc, +
    call si_0c_window_show
    ld de, $9d01
    cp a, $03
    jr z, ++
    ld de, $9cc1
++  call script_window_get_line_start
    call compare_16_16
    jr nz, +
    call script_window_scroll
    call script_window_get_line_start
    jr _L007
+   call script_window_get_line_start
    ld a, (window_width)
    rst $00
    call script_window_set_ptr
    call script_window_set_line_start
    ld hl, window_text_screen_y
    inc (hl)
    dec hl
    ldd a, (hl)
    ld (hl), a
    ret
si_0c_window_show:
    push af
    push bc
    push de
    push hl
    ld hl, window_enabled
    ld a, (hl)
    and a, a
    jr nz, +
    inc a
    ld (hl), a
    ld hl, oam_use_c0_c1
    ld (hl), a
    ldh a, (<hram.battle_flag)
    and a, a
    jr z, ++
    ld (hl), $00
    ld hl, window_sprites
    ld b, $20
    call memclear
    call menu_cursor_clear_position
++  call wait_for_vblank_and_oam_dma
    call si_0f_window_draw
+   jp pop_and_return
si_0d_window_hide:
    ld hl, window_enabled
    ld a, (hl)
    and a, a
    ret z
    xor a, a
    ld (hl), a
    ld (oam_use_c0_c1), a
    rst $10
    call oam_dma_standard
    ldh a, (<LCDC)
    and a, $c3
    ldh (<LCDC), a
    ret
si_0f_window_draw:
    call script_window_initialize_map_script_line
    ld hl, $9c41
    call script_window_set_ptr
    call script_window_set_line_start
    ld e, $50
    ld bc, $1408
    ldh a, (<hram.battle_flag)
    and a, a
    jr z, +
    ld e, $40
    ld bc, $140a
+   ld hl, window_y_offset
    ld (hl), e
    push bc
    call script_window_write_frame
    pop bc
    ld de, $9c00
    jp draw_script_window
script_window_initialize_map_script_line:
    ld a, $12
    ld hl, window_text_line_remaining
    ldi (hl), a
    ld (hl), a
    ret
_si_unused_text_dash:
    ld de, data_sys_script_dash
    jr execute_sys_script
si_3d_text_weak:
    ld de, data_sys_script_weak
    jr execute_sys_script
si_3c_text_resist:
    ld de, data_sys_script_resist
    jr execute_sys_script
si_2f_text_x:
    ld de, data_sys_script_x
    jr execute_sys_script
si_0a_icon_trash:
    ld de, data_sys_script_trash
execute_sys_script:
    ld a, :data_sys_script_trash
    rst $28
    push af
    call execute_script_at_address
    pop af
    rst $28
    ret
si_09_encounter:
    call si_0d_window_hide
    ldh a, (<hram.bank)
    push af
    rst $30
    ld (encounter_id), a
    cp a, $ff
    jr nz, +
    call x_load_random_encounter
    jr ++
+   ld c, a
    call x_load_encounter
++  pop af
    rst $28
-   xor a, a
    ld (window_enabled), a
    ld (encounter_result), a
    ld (oam_use_c0_c1), a
    cpl
    ldh (<hram.battle_flag), a
    call script_window_push
    call far_call
    .addr xd_battle
    .db :xd_battle
    call script_window_pop
    ld a, (encounter_result)
    and a, a
    ret z
    ld e, $0b
    call get_script_var
    and a, a
    jp nz, main
    ld de, $0003
    rst $20
    call menu_yes_no
    and a, a
    jp nz, main
    ld hl, defeat_count
    ld a, (hl)
    inc a
    jr z, -
    ld (hl), a
    jr -
si_46_order_reset:
    ld a, :x1_refresh_equipped_magi
    rst $28
    push af
    call x1_refresh_equipped_magi
    ld a, $e4
    ld (party_order), a
    call x1_refresh_magi_list
    call x_refresh_player_gfx
    pop af
    rst $28
    ret
si_38_guest:
    ld a, $04
    ld (player_index), a
    ld hl, menu_memory
    add a, a
    rst $00
    xor a, a
    ldi (hl), a
    ld (hl), a
    ld e, $00
    call get_script_var
    push af
    add a, $e0
    call load_player
    pop af
    add a, a
    add a, a
    ld hl, data_guest_names
    rst $00
    ld de, player.5.name
    ld a, :data_guest_names
    ld b, $04
    jp memcopy_from_bank
si_3e_restore:
    call far_call
    .addr x1_restore_party
    .db :x1_restore_party
    ret
si_3f_heal:
    rst $30
    ld c, a
    rst $30
    ld b, a
    call far_call
    .addr x1_heal_party
    .db :x1_heal_party
    ret
si_33_gp_subtract:
    ld hl, temp_24bit
    rst $30
    ldi (hl), a
    rst $30
    ldi (hl), a
    ld (hl), $00
    ld de, gp
    ld hl, temp_24bit
    call compare_24_24
    jp nc, subtract_24_24
    ld l, e
    ld h, d
    xor a, a
    ldi (hl), a
    ldi (hl), a
    ld (hl), a
    ret
si_34_select_party:
    call si_0d_window_hide
    call window_begin_menu
    call far_call
    .addr x1_menu_party_select
    .db :x1_menu_party_select
    ldh a, (<hram.bank)
    push af
    call x_restore_map_bank_d
    pop af
    rst $28
    jp window_end_menu
si_32_select_force:
    rst $30
    ld e, a
    push de
    call map_script_window_begin_menu
    pop de
    rst $08
-   call execute_menu_cursor
    cp a, $ff
    jr z, -
    jr +
si_47_jukebox:
    call map_script_window_begin_menu
    ld e, $45
    rst $08
    call execute_menu_cursor
    cp a, $ff
    jr z, +
    ld hl, data_jukebox
    rst $00
    ld a, :data_jukebox
    call read_from_bank
    ldh (<hram.audio.bg_music), a
    ld (saved_bg_music), a
+   jp map_script_window_end_menu
si_20_text_chomp:
    inc a
    ld (chomp), a
    rst $30
    jp execute_script_function_with_byte
si_2d_text_warp:
    ld e, $18
    call get_script_var
    ld c, a
    rst $30
    cp a, c
    jr z, +
    jp nc, remove_last_menu_cursor
+   ld l, a
    ld h, $00
    ld de, data_warp_names
    call add_de_hl_16_x
    ld b, $10
    call print_name
    jp si_06_text_newline_x2
si_1f_text_name:
    ld hl, player.1.name
    ldh a, (<hram.battle_flag)
    and a, a
    jr z, +
    ld hl, battle.data.1.name
+   rst $30
    cp a, $05
    jr c, print_player_name
    cp a, $0a
    jr c, +
    cp a, $0d
    jr nc, ++
    sub a, $0a
    add a, a
    ld hl, script_arg_battle
    rst $00
    ld a, (hl)
    ld hl, battle.data.1.name
    call add_player_offset
    ld b, $08
    jr _L008
+   sub a, $05
    call scale_a_32x
    rst $00
    jr +
++  ld a, (player_index)
print_player_name:
    call add_player_offset
+   ld b, $04
_L008:
    call copy_name_to_buffer
    jp print_buffer
si_21_text_monster:
    rst $30
    cp a, $05
    jr c, +
    cp a, $0d
    jr c, ++
    cp a, $10
    jr c, _L011
    cp a, $10
    jr z, _L009
    cp a, $14
    jr c, _L012
    rst $30
    ld l, a
    ld b, $08
    ld de, data_monster_names
    jp print_indexed_name_8
++  sub a, $05
    ld hl, script_arg_monster
    rst $00
    jr _L010
_L009:
    ld a, (player_index)
+   ld hl, player.1.monster_id
    call add_player_offset
_L010:
    ld b, $08
    ld de, data_monster_names
    jp print_indexed_name_8_addr
_L011:
    sub a, $0d
    add a, a
    ld hl, script_arg_battle
    rst $00
    jr _L010
_L012:
    sub a, $11
    ld hl, battle.data.5.max_stack
    add a, h
    ld h, a
    ld b, $08
    ld a, (hl)
    and a, a
    jp z, print_spaces
    ld a, $0a
    rst $00
    jr _L010
si_1c_text_magi:
    rst $30
    cp a, $10
    jr c, +
    cp a, $30
    jr nc, ++
    sub a, $20
    ld hl, script_arg_inventory
    add a, a
    rst $00
    jr _L013
+   ld hl, script_arg_magi
    rst $00
    jr _L013
++  ld a, (player_index)
    call get_player_magi_address
_L013:
    ld b, $08
    ld a, (hl)
    cp a, $ff
    jp z, print_spaces
    ld l, a
    ld de, data_item_names+$800
    jp print_indexed_name_8
get_player_magi_address:
    call scale_a_32x
    ld hl, player.1.magi
    rst $00
    ret
si_22_text_item:
    ld hl, player.1.inventory
    ld de, $0020
    rst $30
    cp a, $10
    jp c, _text_item_argument_slot
    cp a, $20
    jp c, _text_item_inventory
    cp a, $28
    jr c, _text_item_player_0
    cp a, $30
    jr c, _text_item_player_1
    cp a, $38
    jr c, _text_item_player_2
    cp a, $40
    jr c, _text_item_player_3
    cp a, $48
    jr c, _text_item_player_4
    cp a, $51
    jr c, _text_item_player_argument
    cp a, $63
    jr nc, +
    sub a, $60
    ld hl, script_arg_battle
    add a, a
    rst $00
    ldi a, (hl)
    ld h, (hl)
    ld l, a
    ld b, $08
    ld de, data_item_names
    jp print_indexed_16_name_8
+   rst $30
    ld b, $08
    ld l, a
    ld de, data_item_names
    jp print_indexed_name_8
_text_item_player_4:
    sub a, $08
    add hl, de
_text_item_player_3:
    sub a, $08
    add hl, de
_text_item_player_2:
    sub a, $08
    add hl, de
_text_item_player_1:
    sub a, $08
    add hl, de
_text_item_player_0:
    sub a, $20
    add hl, de
    jr +
_text_item_player_argument:
    sub a, $48
    ld b, a
    ldh a, (<hram.battle_flag)
    and a, a
    jr z, ++
    call is_battle_item_usable
    ld b, $08
    jp nc, print_spaces
    ldi a, (hl)
    ld h, (hl)
    ld l, a
    ld de, data_item_names
    jp print_indexed_16_name_8
++  ld a, (player_index)
    ld hl, player.1.inventory
    call add_player_offset
    ld a, b
    jr +
_text_item_inventory:
    sub a, $10
    ld hl, inventory
    jr +
_text_item_argument_slot:
    ld hl, script_arg_inventory
+   add a, a
    ld de, data_item_names
    rst $00
    ld b, $08
    ld a, (hl)
    inc a
    jp z, print_spaces
    jp print_indexed_name_8_addr
si_41_text_memo_bank:
    rst $30
    cp a, $10
    jr c, +
    ld a, (script_arg_memo_bank)
+   ld d, a
    ld e, $ff
-   inc e
    ld a, e
    cp a, $10
    jr nc, remove_last_menu_cursor
    call test_memo_flag
    jr z, -
    ld hl, script_memo_bank_index
    ld a, (hl)
    inc (hl)
    ld hl, script_arg_inventory
    rst $00
    ld (hl), d
    push de
    ld b, $01
    call print_spaces
    pop de
    ld hl, data_memo_names
    ld a, d
    call print_memo_name
    jp si_06_text_newline_x2
si_42_memo_box:
    ld a, (script_arg_memo_bank)
    ld d, a
    ld a, (script_arg_memo_index)
    ld e, a
    call test_memo_flag
    ret z
    call script_window_initialize_map_script_line
    ld hl, hram.script_mode
    ld a, (hl)
    push af
    ld (hl), $05
    call execute_memo_script
    pop af
    ldh (<hram.script_mode), a
    ret
execute_memo_script:
    ld l, d
    ld h, $00
    ld bc, data_memo
    call add_bc_hl_32_x
    ld a, e
print_memo_name:
    add a, a
    rst $00
    ld a, :data_memo
    rst $28
    push af
    ld e, (hl)
    inc hl
    ld d, (hl)
    call execute_script_at_address
    pop af
    rst $28
    ret
remove_last_menu_cursor:
    ld de, cursor_stops
    ld hl, cursor_stop_count
    dec (hl)
    ld l, (hl)
    ld h, $00
    add hl, hl
    add hl, de
    ld a, $ff
    ldi (hl), a
    ld (hl), a
    ret
si_24_text_current_hp:
    ld hl, player.1.current_hp
    ldh a, (<hram.battle_flag)
    and a, a
    jr z, +
    ld hl, battle.data.1.stat.1.hp
+   jr +
si_3b_text_status_or_max_hp:
    call get_player_status_base_address
    call read_script_stream_player_index
    ld c, a
    call add_player_offset
    ld a, (hl)
    call get_highest_status
    and a, a
    jr nz, print_status
    call si_01_text_right
    call get_player_max_hp_base_address
    ld a, c
    jr print_stat_16
print_status:
    dec a
    add a, a
    add a, a
    ld hl, data_status_names
    rst $00
    ld b, $04
    jp print_name
si_25_text_max_hp:
    call get_player_max_hp_base_address
+   call read_script_stream_player_index
print_stat_16:
    call add_player_offset
    ldi a, (hl)
    ld h, (hl)
    ld l, a
    ld de, $03e8
    call compare_16_16
    jr c, +
    ld hl, $03e7
+   call number_16_to_string
    ld hl, window_text_buffer+$02
    jp copy_string_to_buffer
si_1d_text_magi_count:
    rst $30
    cp a, $10
    jr c, +
    ld a, (player_index)
    call get_player_magi_address
    jr ++
+   ld hl, script_arg_magi
    rst $00
++  ld b, $01
    ld a, (hl)
    cp a, $ff
    jp z, print_spaces
    add a, a
    ld hl, magi_list
    rst $00
    ld a, (hl)
    and a, $0f
print_number_8:
    ld l, a
    ld h, $00
    call number_16_to_string
    ld hl, $c789
    jp copy_string_to_buffer
si_23_text_item_usage:
    ld hl, $0000
    ld de, $0020
    rst $30
    cp a, $10
    jr c, +
    cp a, $20
    jr c, ++
    cp a, $28
    jr c, _L019
    cp a, $30
    jr c, _L018
    cp a, $38
    jr c, _L017
    cp a, $40
    jr c, _L016
    cp a, $48
    jr c, _L015
    sub a, $48
    ld b, a
    ldh a, (<hram.battle_flag)
    and a, a
    ld a, b
    jr z, _L014
    call is_battle_item_usable
    ld b, $02
    jp nc, print_spaces
    inc hl
    inc hl
    jr _L022
_L014:
    ld hl, player.1.inventory
    add a, a
    rst $00
    ld a, (player_index)
    call add_player_offset
    jr _L021
_L015:
    sub a, $08
    add hl, de
_L016:
    sub a, $08
    add hl, de
_L017:
    sub a, $08
    add hl, de
_L018:
    sub a, $08
    add hl, de
_L019:
    ld de, player.1.inventory
    sub a, $20
    add hl, de
    jr _L020
++  sub a, $10
    ld hl, inventory
    jr _L020
+   ld hl, script_arg_inventory
_L020:
    add a, a
    rst $00
_L021:
    ld b, $02
    ldi a, (hl)
    inc a
    jp z, print_spaces
_L022:
    ld a, (hl)
    cp a, $fe
    jr nz, print_number_8_cap_99
    ld de, data_sys_script_unlimited
    jp execute_sys_script
si_27_text_str:
    ld hl, player.1.str
    jr +
si_28_text_def:
    ld hl, player.1.def
    jr +
si_29_text_agl:
    ld hl, player.1.agl
    jr +
si_2a_text_mana:
    ld hl, player.1.mana
+   call read_script_stream_player_index
    call add_player_offset
    jr print_number_8_cap_99
si_2c_text_magi_total:
    ld hl, magi_total
    jr print_number_8_cap_99
si_26_text_uint8:
    rst $30
    ld hl, script_arg_uint8
    rst $00
print_number_8_cap_99:
    ld a, (hl)
    cp a, $64
    jr c, +
    ld a, $63
+   ld l, a
    ld h, $00
    call number_16_to_string
    ld hl, window_text_buffer+$03
    jp copy_string_to_buffer
si_35_text_gp_n:
    call read_script_stream_gp_string
    ld hl, window_text_buffer
    rst $30
    add a, $02
    ld b, a
    ld a, $08
    sub a, b
    rst $00
    jp copy_string_to_buffer
si_1e_text_gp:
    call read_script_stream_gp_string
    ld hl, window_text_buffer
    jp copy_string_to_buffer
read_script_stream_gp_string:
    ld hl, gp
    rst $30
    and a, a
    jr z, +
    dec a
    ld c, a
    add a, a
    add a, c
    ld hl, script_arg_uint24
    rst $00
+   ldi a, (hl)
    and a, (hl)
    inc hl
    and a, (hl)
    dec hl
    dec hl
    inc a
    jr nz, +
    dec a
    ld b, $08
    call memset
    xor a, a
    ld (hl), a
    ret
+   ld de, const_999999
    call compare_24_24
    jr nc, +
    ld hl, const_999999
+   ld de, temp_24bit
    ld b, $03
    push de
    call memcopy
    pop de
    ld bc, window_text_buffer
    ld hl, powers_of_ten
    ld a, $05
--  ldh (<hram.temp.3), a
    xor a, a
-   call subtract_24_24
    inc a
    jr nc, -
    dec a
    call add_24_24
    ld (bc), a
    inc bc
    inc hl
    inc hl
    inc hl
    ldh a, (<hram.temp.3)
    dec a
    jr nz, --
    ld a, (de)
    ld (bc), a
    ld b, $06
    call digits_to_string
    ld (hl), $c0
    inc hl
    ld (hl), $c9
    inc hl
    ld (hl), $00
    ret
si_30_text_uint16:
    ld hl, script_arg_uint16
    rst $30
    add a, a
    rst $00
    ldi a, (hl)
    ld h, (hl)
    ld l, a
    call number_16_to_string
    ld hl, window_text_buffer
    jp copy_string_to_buffer
si_3a_text_monster_count:
    rst $30
    ld b, $02
    ld hl, battle.data.5.max_stack
    add a, h
    ld h, a
    ldi a, (hl)
    and a, a
    jp z, print_spaces
    jp print_number_8_cap_99
get_player_status_base_address:
    push af
    ld hl, player.1.status
    ldh a, (<hram.battle_flag)
    and a, a
    jr z, +
    ld hl, battle.data.1.stat.1.status
+   pop af
    ret
get_player_max_hp_base_address:
    push af
    ld hl, player.1.max_hp
    ldh a, (<hram.battle_flag)
    and a, a
    jr z, +
    ld hl, battle.data.1.hp
+   pop af
    ret
read_script_stream_player_index:
    rst $30
    cp a, $05
    ret c
    ld a, (player_index)
    ret
jt_script_instruction:
    .addr si_00_exit
    .addr si_01_text_right
    .addr si_02_text_left
    .addr si_03_text_up
    .addr si_04_text_down
    .addr si_05_text_newline
    .addr si_06_text_newline_x2
    .addr si_07_text_raw
    .addr si_08_sprite
    .addr si_09_encounter
    .addr si_0a_icon_trash
    .addr si_0b_prompt
    .addr si_0c_window_show
    .addr si_0d_window_hide
    .addr si_00_exit
    .addr si_0f_window_draw
    .addr si_10_npc_refresh
    .addr si_11_wait
    .addr si_12_var_inc
    .addr si_13_var_dec
    .addr si_14_var_set
    .addr si_15_var_test
    .addr si_16_prompt_yes_no
    .addr si_17_item_test
    .addr si_18_memo_set
    .addr si_19_command
    .addr si_1a_magi_test_count
    .addr si_1b_magi_test
    .addr si_1c_text_magi
    .addr si_1d_text_magi_count
    .addr si_1e_text_gp
    .addr si_1f_text_name
    .addr si_20_text_chomp
    .addr si_21_text_monster
    .addr si_22_text_item
    .addr si_23_text_item_usage
    .addr si_24_text_current_hp
    .addr si_25_text_max_hp
    .addr si_26_text_uint8
    .addr si_27_text_str
    .addr si_28_text_def
    .addr si_29_text_agl
    .addr si_2a_text_mana
    .addr si_23_text_item_usage
    .addr si_2c_text_magi_total
    .addr si_2d_text_warp
    .addr si_2e_cursor
    .addr si_2f_text_x
    .addr si_30_text_uint16
    .addr si_31_nop
    .addr si_32_select_force
    .addr si_33_gp_subtract
    .addr si_34_select_party
    .addr si_35_text_gp_n
    .addr si_36_text_space
    .addr si_37_encounter_check
    .addr si_38_guest
    .addr si_39_cursor_text
    .addr si_3a_text_monster_count
    .addr si_3b_text_status_or_max_hp
    .addr si_3c_text_resist
    .addr si_3d_text_weak
    .addr si_3e_restore
    .addr si_3f_heal
    .addr si_40_memo_clear
    .addr si_41_text_memo_bank
    .addr si_42_memo_box
    .addr si_43_stone_test
    .addr si_44_music_test
    .addr si_45_defeated_test
    .addr si_46_order_reset
    .addr si_47_jukebox
    .addr si_48_battle_graphics_swap
    .addr si_49_text_save
    .addr si_4a_text_accelerate_disable
    .addr si_4b_memo
    .addr si_4c_teleport_disable
    .addr si_4d_game_end
powers_of_ten:
    .db $a0, $86, $01 ; 100000
    .db $10, $27, $00 ; 10000
    .db $e8, $03, $00 ; 1000
    .db $64, $00, $00 ; 100
    .db $0a, $00, $00 ; 10
const_999999:
    .db $3f, $42, $0f ; 999999
si_4a_text_accelerate_disable:
    ld a, $03
    ld (text_control_setting), a
    ld a, $04
    ld (text_speed), a
    ret
menu_yes_no:
    call map_script_window_begin_menu
    call wait_for_release_dma
    ld e, $12
    rst $08
-   call execute_menu_cursor
    cp a, $ff
    jr z, -
    call wait_for_release_dma
    push af
    call map_script_window_end_menu
    pop af
    ret
si_19_command:
    ld hl, hram.script_instr_ptr
    ldi a, (hl)
    ld h, (hl)
    ld l, a
    rst $30
    ld d, a
    rst $30
    ld e, a
    ld a, d
    cp a, $04
    jp c, execute_script
    cp a, $04
    jr z, execute_shop_command
    call x_execute_script_command
    ld e, l
    ld d, h
    jp set_script_stream_ptr
execute_shop_command:
    push af
    push bc
    push de
    push hl
    push de
    call si_0d_window_hide
    call window_begin_menu
    pop de
    ld a, :x1_menu_shop
    rst $28
    push af
    call x1_menu_shop
    call x_restore_map_sprite_gfx
    pop af
    rst $28
    call window_end_menu
    jp pop_and_return
map_script_window_begin_menu:
    ld b, $00
    ld hl, $9c00
    ld de, $9d00
    call vram_memcopy
window_begin_menu:
    xor a, a
    ld (window_scroll_y_offset), a
    call menu_cursor_clear_position
    call menu_cursor_stops_clear
    ld a, $02
    ldh (<hram.window_sprite_mode), a
script_window_push:
    ld hl, script_stack_pointer
    ld e, (hl)
    inc hl
    ld d, (hl)
    push hl
    ld hl, hram.script_mode
    ld b, $04
    call memcopy
    ld hl, window_width
    ld b, $07
    call memcopy
    pop hl
    ld (hl), d
    dec hl
    ld (hl), e
    ret
map_script_window_end_menu:
    ld b, $00
    ld hl, $9d00
    ld de, $9c00
    call vram_memcopy
window_end_menu:
    xor a, a
    ldh (<hram.window_sprite_mode), a
    call menu_cursor_clear_position
    ld hl, oam_staging_cc+$80
    ld b, $20
    call memclear
    rst $10
    ld a, >oam_staging_cc
    rst $18
script_window_pop:
    ld hl, script_stack_pointer
    ld e, (hl)
    inc hl
    ld d, (hl)
    push hl
    ld hl, window_width+$06
    ld b, $07
    call reverse_memcopy
    ld hl, hram.script_mode+$03
    ld b, $04
    call reverse_memcopy
    pop hl
    ld (hl), d
    dec hl
    ld (hl), e
    ret
print_indexed_name_8_addr:
    ld l, (hl)
print_indexed_name_8:
    ld h, $00
print_indexed_16_name_8:
    call add_de_hl_8_x
print_name:
    ld a, $0f
    rst $28
    push af
    call copy_name_to_buffer
    pop af
    rst $28
    jr print_buffer
print_spaces:
    ld a, (chomp)
    and a, a
    ret nz
    dec a
    ld hl, window_text_buffer
    call memset
    xor a, a
    ld (hl), a
print_buffer:
    ld de, window_text_buffer
execute_script_at_address:
    ld hl, hram.script_instr_ptr
    ld c, (hl)
    inc hl
    ld b, (hl)
    ld (hl), d
    dec hl
    ld (hl), e
    push bc
    push hl
    ld hl, current_script_stack_level
    ld a, (hl)
    ld (hl), $01
    push af
-   call execute_script_instruction
    jr -
    pop af
    ld (current_script_stack_level), a
    pop hl
    pop de
    jp set_script_stream_ptr
copy_string_to_buffer:
    ld de, window_text_buffer
    ld a, (chomp)
    and a, a
    jr nz, _L023
-   ldi a, (hl)
    ld (de), a
    inc de
    and a, a
    jr nz, -
    jr +
_L023:
    ldi a, (hl)
    cp a, $ff
    jr z, _L023
    ld (de), a
    inc de
    and a, a
    jr nz, _L023
+   jp print_buffer
copy_name_to_buffer:
    ld de, window_text_buffer
    ld a, (chomp)
    and a, a
    jr nz, +
    call memcopy
    jr ++
+   ld c, e
-   ldi a, (hl)
    ld (de), a
    inc de
    inc a
    jr z, +
    ld c, e
+   dec b
    jr nz, -
    ld e, c
++  xor a, a
    ld (de), a
    ret
number_16_to_string:
    call number_16_to_digits
    ld b, $05
digits_to_string:
    ld hl, window_text_buffer
    ld c, $00
-   ld a, (hl)
    and a, a
    jr nz, +
    inc c
    dec c
    jr nz, +
    dec b
    jr nz, ++
    ld a, $b1
++  inc b
    dec a
    jr ++
+   inc c
    add a, $b0
++  ldi (hl), a
    dec b
    jr nz, -
    ld (hl), b
    ret
number_16_to_digits:
    ld bc, window_text_buffer
    ld de, $2710
    call number_16_to_digits_helper
    ld de, $03e8
    call number_16_to_digits_helper
    ld de, $0064
    call number_16_to_digits_helper
    ld de, $000a
    call number_16_to_digits_helper
    ld a, l
    ld (bc), a
    ret
number_16_to_digits_helper:
    xor a, a
-   call subtract_16_16
    inc a
    jr nc, -
    dec a
    add hl, de
    ld (bc), a
    inc bc
    ret
item_list_contains:
    cp a, (hl)
    ret z
    inc hl
    inc hl
    dec c
    jr nz, item_list_contains
    scf
    ret
load_monster_half_sprite:
    ld hl, data_monster_npc_gfx
    rst $00
    ld a, :data_monster_npc_gfx
    call read_from_bank
    ld h, >data_npc_gfx
    add a, h
    ld h, a
    ld l, <data_npc_gfx
    ld a, :data_npc_gfx
    ld b, $80
    jp vram_memcopy_from_bank
is_battle_item_usable:
    ld hl, battle.data.1.inventory
    ld a, (player_index)
    call add_player_offset
    ld a, b
    add a, a
    add a, b
    rst $00
    ld a, (hl)
    cp a, $ff
    ret z
    push hl
    inc hl
    ld h, (hl)
    ld l, a
    ld de, data_items
    call add_de_hl_8_x
    ld a, :data_items
    call read_from_bank
    pop hl
    and a, $01
    ret z
    scf
    ret
get_highest_status:
    push bc
    push de
    push hl
    ld b, a
    ld a, :data_status_priority
    rst $28
    push af
    ld hl, data_status_priority
    ld d, $08
-   ld c, (hl)
    inc hl
    ld e, c
    inc e
    ld a, b
    call test_bit
    jr nz, +
    dec d
    jr nz, -
    ld e, $00
+   pop af
    rst $28
    ld a, e
    pop hl
    pop de
    pop bc
    ret
wait_for_line_0x90:
    push af
-   ldh a, (<LY)
    cp a, $90
    jr nz, -
    pop af
    ret
vram_enable:
    rst $10
    di
    push af
    push de
    push hl
    ld hl, ram_program_lcd_stat_interrupt
    ld de, lcd_stat_interrupt_backup
    ld a, (hl)
    ld (de), a
    inc de
    ld a, $c3
    ldi (hl), a
    ld a, (hl)
    ld (de), a
    inc de
    ld a, <lcd_stat_interrupt_vram_access
    ldi (hl), a
    ld a, (hl)
    ld (de), a
    ld a, >lcd_stat_interrupt_vram_access
    jr +
vram_disable:
    rst $10
    di
    push af
    push de
    push hl
    ld hl, ram_program_lcd_stat_interrupt
    ld de, lcd_stat_interrupt_backup
    ld a, (de)
    inc de
    ldi (hl), a
    ld a, (de)
    inc de
    ldi (hl), a
    ld a, (de)
+   ld (hl), a
    pop hl
    pop de
    pop af
    reti
lcd_stat_interrupt_vram_access:
    push af
    ldh a, (<LY)
    and a, a
    call z, lcd_stat_interrupt_vram_access_helper
    inc a
    ldh (<LYC), a
    ldh a, (<STAT)
    ldh (<STAT), a
-   ldh a, (<STAT)
    and a, $03
    jr nz, -
    pop af
    reti
lcd_stat_interrupt_vram_access_helper:
    call game_update
    call wait_for_mode_3
-   ldh a, (<STAT)
    and a, $03
    jr nz, -
    call wait_for_mode_3
    ldh a, (<LY)
    ret
wait_for_mode_3:
    ldh a, (<STAT)
    and a, $03
    cp a, $03
    jr nz, wait_for_mode_3
    ret
lcd_stat_interrupt_standard:
    call game_update
    push af
    jr +
vblank_interrupt_standard:
    push af
    ldh a, (<hram.arsenal_cloud.enable)
    and a, a
    jr z, +
    ld a, :x1_arsenal_cloud_process_update
    ld ($2100), a
    call x1_arsenal_cloud_process_update
    ldh a, (<hram.bank)
    ld ($2100), a
+   xor a, a
    ldh (<LYC), a
    ldh (<IF), a
    pop af
    reti
game_update:
    push af
    push bc
    push de
    push hl
    ld hl, hram.game_update_guard
    ld a, (hl)
    and a, a
    jr nz, +
    inc (hl)
    ld a, :xe_update_audio
    call bank_switch
    push af
    call xe_update_audio
    ldh a, (<hram.arsenal_cloud.enable)
    and a, a
    jr z, ++
    ld a, :x1_arsenal_cloud_stage_update
    call bank_switch
    call x1_arsenal_cloud_stage_update
++  pop af
    call bank_switch
    ld hl, joyp_buffer
    ld de, joyp_buffer+$01
    ld b, $03
    push hl
    call memcopy
    pop hl
    ld c, <JOYP
    ld a, $20
    ldh (c), a
    call read_joypad_2
    swap a
    ld b, a
    ld a, $10
    ldh (c), a
    call read_joypad
    and a, b
    cpl
    ldi (hl), a
    inc hl
    inc hl
    ldd a, (hl)
    or a, (hl)
    dec hl
    and a, (hl)
    dec hl
    and a, (hl)
    ldh (<hram.joyp_raw), a
    ld a, $30
    ldh (c), a
    ldh a, (<hram.joyp_raw)
    and a, $0f
    cp a, $0f
    jp z, main
    ldh a, (<hram.window_sprite_mode)
    and a, a
    call nz, process_window_sprites
    ld hl, hram.game_update_guard
    dec (hl)
+   jp pop_and_return
read_joypad:
    ldh a, (c)
    ldh a, (c)
    ldh a, (c)
    ldh a, (c)
read_joypad_2:
    ldh a, (c)
    ldh a, (c)
    or a, $f0
    ret
process_window_sprites:
    ld a, :data_window_oam_template_info
    call bank_switch
    push af
    ld hl, window_sprite_frame_counter
    inc (hl)
    ld a, (hl)
    and a, $10
    jr z, +
    xor a, a
    ldi (hl), a
    ld a, (hl)
    and a, $01
    xor a, $01
    ld (hl), a
+   ldh a, (<hram.window_sprite_mode)
    bit 0, a
    jp z, @after_sprites
    ld hl, oam_staging_cc
    ld b, $80
    call memclear
    ld hl, window_sprites
    ld b, $08
@next_sprite:
    push bc
    ld a, (hl)
    rla
    jp nc, @after_sprite_enabled
    push hl
    ldi a, (hl)
    ldh (<hram.sprite_temp.3), a
    ldi a, (hl)
    ldh (<hram.sprite_temp.2), a
    ldh a, (<hram.sprite_temp.3)
    and a, $07
    add a, a
    add a, a
    add a, a
    add a, a
    ld d, (hl)
    inc hl
    ld e, (hl)
    ld l, a
    ld h, >oam_staging_cc
    ldh a, (<hram.sprite_temp.3)
    bit 5, a
    jr z, +
    ld a, (window_sprite_frame_flag)
    and a, a
    jr z, ++
+   ldh a, (<hram.sprite_temp.3)
    bit 6, a
    jr z, +
    ldh a, (<hram.sprite_temp.2)
    bit 2, a
    jr nz, +
    ld a, (window_sprite_frame_flag)
    add a, e
    ld e, a
+   push hl
    call process_window_sprites_helper
    ld hl, data_window_oam_template_info
    ldh a, (<hram.sprite_temp.3)
    bit 6, a
    jr z, +
    ld a, (window_sprite_frame_flag)
    and a, a
    jr z, +
    ld hl, data_window_oam_template_info+$18
+   ldh a, (<hram.sprite_temp.3)
    bit 4, a
    jr z, +
    ld a, $0c
    rst $00
+   ldh a, (<hram.sprite_temp.2)
    and a, $03
    add a, a
    add a, a
    rst $00
    ld e, l
    ld d, h
    pop hl
    ldh a, (<hram.sprite_temp.3)
    and a, $07
    add a, a
    add a, a
    add a, a
    ldh (<hram.sprite_temp.2), a
    ldh a, (<hram.sprite_temp.3)
    and a, $08
    rlca
    ldh (<hram.sprite_temp.1), a
    ld b, $04
-   inc hl
    inc hl
    ldh a, (<hram.sprite_temp.2)
    ld c, a
    ld a, (de)
    and a, $0f
    add a, c
    ldi (hl), a
    ldh a, (<hram.sprite_temp.1)
    ld c, a
    ld a, (de)
    inc de
    and a, $f0
    or a, c
    ldi (hl), a
    dec b
    jr nz, -
++  pop hl
@after_sprite_enabled:
    inc hl
    inc hl
    inc hl
    inc hl
    pop bc
    dec b
    jp nz, @next_sprite
@after_sprites:
    ld hl, oam_staging_cc+$90
    xor a, a
--  ldh (<hram.sprite_temp.3), a
    ld c, <hram.cursor.y
    add a, a
    add a, c
    ld c, a
    ldh a, (c)
    ld d, a
    inc c
    ldh a, (c)
    ld e, a
    inc a
    jr nz, +
    ld b, $10
    call memclear
    jr ++
+   call scale_8x
    push hl
    call process_window_sprites_helper
    pop hl
    ld b, $04
    ld a, $78
-   inc hl
    inc hl
    ldi (hl), a
    inc a
    ld (hl), $00
    inc hl
    dec b
    jr nz, -
++  ld hl, oam_staging_cc+$80
    ldh a, (<hram.sprite_temp.3)
    inc a
    cp a, $02
    jr c, --
    pop af
    call bank_switch
    ret
process_window_sprites_helper:
    push af
    push bc
    ld a, $04
    ld bc, data_window_oam_template_pos
-   ldh (<hram.sprite_temp.1), a
    ld a, (bc)
    inc bc
    add a, d
    ldi (hl), a
    ld a, (bc)
    inc bc
    add a, e
    ldi (hl), a
    inc hl
    inc hl
    ldh a, (<hram.sprite_temp.1)
    dec a
    jr nz, -
    pop bc
    pop af
    ret
fc_menu_start:
    call far_call
    .addr x1_menu_start
    .db :x1_menu_start
    ret
fc_menu_party_order:
    call far_call
    .addr x1_menu_party_order
    .db :x1_menu_party_order
    ret
fc_load_monster_gfx_dimensions:
    call far_call
    .addr x1_load_monster_gfx_dimensions
    .db :x1_load_monster_gfx_dimensions
    ret
fc_load_monster_gfx_address:
    call far_call
    .addr x1_load_monster_gfx_address
    .db :x1_load_monster_gfx_address
    ret
fc_menu_meat:
    call far_call
    .addr x1_menu_meat
    .db :x1_menu_meat
    ret
fc_monster_gfx_setup:
    call far_call
    .addr xf_monster_gfx_setup
    .db :xf_monster_gfx_setup
    ret
fc_battle_animation:
    call far_call
    .addr xd_battle_animation
    .db :xd_battle_animation
    ret
fc_process_monster_gfx:
    call far_call
    .addr xf_process_monster_gfx
    .db :xf_process_monster_gfx
    ret
execute_menu_cursor:
    xor a, a
    call execute_menu_cursor_with_options
    ldh a, (<hram.confirmed_cursor.1)
    ret
execute_menu_cursor_with_options:
    push af
    push bc
    push de
    push hl
    ld b, a
    ld a, (box_script_scroll_flag)
    add a, a
    or a, b
    ld (cursor_mode), a
    ld a, :x1_execute_menu_cursor_internal
    rst $28
    push af
    call x1_execute_menu_cursor_internal
    pop af
    rst $28
    jp pop_and_return
_unused:
    push af
    push bc
    push de
    push hl
    ld b, a
    ld a, (box_script_scroll_flag)
    add a, a
    or a, b
    ld (cursor_mode), a
    ld a, :x1_execute_menu_cursor_internal
    rst $28
    push af
    call x1_execute_menu_cursor_internal
    pop af
    rst $28
    jp pop_and_return

.ends


