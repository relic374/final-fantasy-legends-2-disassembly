.include "common.i"

.bank $0d slot 1
.orga $5000

.section "battle_animation" size $1400 overwrite

xd_battle_animation:
    jp battle_animation
xd_pba_fade_in:
    jp pba_fade_in
xd_render_cc00_frames:
    jp render_cc00_frames
xd_load_animation_gfx:
    jp load_animation_gfx
xd_read_pba_oam_type_data:
    jp read_pba_oam_type_data
xd_stage_pba_oam_data_helper:
    jp stage_pba_oam_data_helper
xd_load_monster_gfx_metadata:
    jp load_monster_gfx_metadata
xd_load_monster_gfx_dimensions:
    jp load_monster_gfx_dimensions
xd_load_monster_gfx_address:
    jp load_monster_gfx_address
battle_animation:
    push af
    push bc
    push de
    push hl
    ld a, $16
    ldh (<OBP1), a
    ld (menu_palette_backup+$02), a
    call battle_animation_helper
    jp pop_and_return
battle_animation_helper:
    ld a, (battle_animation_id)
    bit 7, a
    jp z, procedural_battle_animation
    and a, $7f
    add a, a
    ld hl, data_battle_animation_metadata
    rst $00
    call animation_stream_read_byte
    ld c, a
    call animation_stream_read_byte
    ld b, a
    and a, $02
    srl a
    ld (battle_animation_global), a
    ld l, c
    ld a, b
    and a, $01
    ld h, a
    ld bc, data_battle_animation_gfx
    call add_bc_hl_16_x
    ld de, $8000
    ld a, :data_battle_animation_gfx
    ld bc, $0200
    call vram_memcopy_16_from_bank
    xor a, a
    ld hl, missile_animation_flag
    ldi (hl), a
    ldd (hl), a
    ld a, (battle_animation_id)
    cp a, $a0
    jr nz, +
    ld (hl), a
    jr @multi_target_animation
+   ld a, (battle_animation_global)
    and a, a
    jr nz, @animation_on_enemy
    ld a, (battle_animation_target_parameter)
    cp a, $09
    jr nz, @single_target_animation
@multi_target_animation:
    xor a, a
-   call _is_enemy_stack_defeated
    jr nz, @enemy_is_present
    inc a
    jr -
@enemy_is_present:
    ld (battle_animation_target), a
    call @animation_on_enemy
    ld hl, missile_animation_flip
    inc (hl)
    ld a, (battle_animation_target)
    cp a, $02
    ret nc
-   inc a
    call _is_enemy_stack_defeated
    jr nz, @enemy_is_present
    cp a, $02
    jr c, -
    ret
@single_target_animation:
    sub a, $05
    ld (battle_animation_target), a
@animation_on_enemy:
    xor a, a
    ld (battle_animation_current_base_tile), a
    ld a, (battle_animation_id)
    and a, $7f
    add a, a
    ld hl, data_battle_animation_streams
    rst $00
    call animation_dereference
    call animation_stream_set_position
-   call animation_stream_read
    cp a, $ff
    jp z, render_cc00_frame_with_no_oam
    bit 7, a
    jr z, @render_sprites
    bit 6, a
    jr nz, @pba
    bit 5, a
    jr z, @pba
    call animation_stream_read
    ld (battle_animation_current_base_tile), a
    jr -
@pba:
    call procedural_battle_animation
    jr -
@render_sprites:
    call decode_animation_data
    ld a, (battle_animation_current_frame_length)
    ld b, a
    call render_cc00_frames
    jr -
decode_animation_data:
    ld hl, battle_animation_current_frame_length
    ld c, a
    and a, $0f
    inc a
    add a, a
    add a, a
    ldi (hl), a
    ld a, c
    and a, $70
    ld (hl), a
    ld hl, battle_animation_y
    ld (hl), $10
    inc hl
    ld (hl), $40
    ld a, (missile_animation_flag)
    and a, a
    jr nz, +
    ld a, (battle_animation_global)
    and a, a
    jr nz, ++
+   call animation_adjust_x
++  call animation_stream_read
    ld l, a
    ld h, $00
    ld bc, data_battle_animation_frames
    add hl, hl
    add hl, bc
    call animation_frame_dereference
    ld de, battle_animation_buffer
    ld b, $30
--  call animation_frame_read_byte
    bit 7, a
    jr z, +
    and a, $7f
    push af
    call animation_frame_read_byte
    ld c, a
    pop af
-   ld (de), a
    inc de
    dec b
    jr z, ++
    dec c
    jr nz, -
    jr --
+   ld (de), a
    inc de
    dec b
    jr nz, --
++  ld a, (battle_animation_current_frame_flags)
    bit 6, a
    call nz, animation_frame_y_flip
    bit 5, a
    call nz, animation_frame_x_flip
    ld hl, missile_animation_flag
    ldi a, (hl)
    and a, a
    jr z, +
    ld a, (hl)
    rrca
    call c, animation_frame_y_flip
    rrca
    call c, animation_frame_x_flip
+   ld hl, oam_staging_cc
    ld b, $a0
    call memclear
    ld hl, battle_animation_y
    ldi a, (hl)
    ldh (<hram.temp.1), a
    ld a, (hl)
    ldh (<hram.temp.2), a
    ld de, battle_animation_buffer
    ld hl, oam_staging_cc
    ld b, $08
--  push bc
    ld c, $06
-   ld b, $1f
    ld a, (de)
    and a, b
    cp a, b
    jr z, +
    ldh a, (<hram.temp.1)
    ldi (hl), a
    ldh a, (<hram.temp.2)
    ldi (hl), a
    ld a, (de)
    and a, b
    ld b, a
    ld a, (battle_animation_current_base_tile)
    add a, b
    ldi (hl), a
    ld a, (de)
    and a, $60
    ld b, a
    ld a, (battle_animation_current_frame_flags)
    and a, $10
    or a, b
    ldi (hl), a
+   inc de
    ldh a, (<hram.temp.2)
    add a, $08
    ldh (<hram.temp.2), a
    dec c
    jr nz, -
    ldh a, (<hram.temp.1)
    add a, $08
    ldh (<hram.temp.1), a
    ld a, (battle_animation_x)
    ldh (<hram.temp.2), a
    pop bc
    dec b
    jr nz, --
    ret
animation_frame_y_flip:
    push af
    ld hl, battle_animation_buffer
    ld de, battle_animation_buffer+$2a
    ld b, $04
--  ld c, $06
-   push bc
    ld c, $40
    ld b, (hl)
    ld a, (de)
    xor a, c
    ldi (hl), a
    ld a, b
    xor a, c
    ld (de), a
    inc de
    pop bc
    dec c
    jr nz, -
    ld a, e
    sub a, $0c
    ld e, a
    jr nc, +
    dec d
+   dec b
    jr nz, --
    pop af
    ret
animation_frame_x_flip:
    push af
    ld hl, battle_animation_buffer
    ld de, battle_animation_buffer+$05
    ld b, $08
--  ld c, $03
-   push bc
    ld c, $20
    ld b, (hl)
    ld a, (de)
    xor a, c
    ldi (hl), a
    ld a, b
    xor a, c
    ld (de), a
    dec de
    pop bc
    dec c
    jr nz, -
    ld a, $03
    rst $00
    ld a, e
    add a, $09
    ld e, a
    jr nc, +
    inc d
+   dec b
    jr nz, --
    pop af
    ret
animation_stream_read:
    call animation_stream_get_position
    call animation_stream_read_byte
animation_stream_set_position:
    push af
    ld a, l
    ld (battle_animation_stream), a
    ld a, h
    ld (battle_animation_stream+1), a
    pop af
    ret
animation_stream_get_position:
    push af
    ld hl, battle_animation_stream
    ldi a, (hl)
    ld h, (hl)
    ld l, a
    pop af
    ret
animation_frame_dereference:
    push af
    push bc
    call animation_frame_read_byte
    ld c, a
    call animation_frame_read_byte
    ld h, a
    ld l, c
    pop bc
    pop af
    ret
animation_dereference:
    push af
    push bc
    call animation_stream_read_byte
    ld c, a
    call animation_stream_read_byte
    ld h, a
    ld l, c
    pop bc
    pop af
    ret
animation_stream_read_byte:
    ld a, :data_battle_animation_streams
    jr stream_read_helper
animation_frame_read_byte:
    ld a, :data_battle_animation_frames
stream_read_helper:
    call read_from_bank
    inc hl
    ret
animation_adjust_x:
    ld a, (battle_animation_target)
    ld hl, monster_gfx_x_raw
    rst $00
    ld a, (hl)
    add a, a
    add a, a
    add a, a
    sub a, $10
    ld (battle_animation_x), a
    ret
_is_enemy_stack_defeated:
    ld b, a
    ld hl, battle.data.5.current_stack
    add a, h
    ld h, a
    ld a, (hl)
    and a, a
    ld a, b
    ret
load_monster_gfx_metadata:
    ld de, battle.data.5.max_stack
    ld hl, enemy_group_count
    ld (hl), $00
    ld b, $03
-   ld a, (de)
    inc d
    and a, a
    jr z, +
    inc (hl)
+   dec b
    jr nz, -
    ld a, (enemy_group_count)
    ld b, a
    ld de, monster_gfx_id
    ld hl, battle.data.5.monster_id
-   ld a, (hl)
    push hl
    ld hl, data_monster_gfx_table
    rst $00
    ld a, (hl)
    and a, $f0
    swap a
    ld (de), a
    inc de
    ld a, (hl)
    and a, $0f
    ld (de), a
    dec de
    pop hl
    inc de
    inc de
    inc h
    dec b
    jr nz, -
    call load_monster_gfx_dimensions
    ld a, (enemy_group_count)
    ld c, a
    dec a
    ld b, a
    add a, a
    add a, b
    ld hl, data_monster_gfx_x_offsets
    rst $00
    ld de, monster_gfx_x_raw
    ld b, $03
    call memcopy
    ld b, c
    ld de, monster_gfx_x
    xor a, a
-   ldh (<hram.temp.1), a
    add a, a
    ld hl, monster_gfx_dims
    rst $00
    ld c, (hl)
    srl c
    ldh a, (<hram.temp.1)
    ld hl, monster_gfx_x_raw
    rst $00
    ld a, (hl)
    sub a, c
    ld (de), a
    inc de
    ldh a, (<hram.temp.1)
    inc a
    dec b
    jr nz, -
    ld a, (enemy_group_count)
    ld b, a
    ld de, monster_gfx_y
    ld hl, monster_gfx_id
-   ldi a, (hl)
    inc hl
    push hl
    ld hl, data_monster_gfx_y_offsets
    rst $00
    ld a, (hl)
    pop hl
    ld (de), a
    inc de
    dec b
    jr nz, -
    ret
load_monster_gfx_dimensions:
    ld a, (enemy_group_count)
    ld b, a
    ld de, monster_gfx_dims
    ld hl, monster_gfx_id
-   ldi a, (hl)
    inc hl
    push hl
    ld hl, data_monster_gfx_size
    rst $00
    ld a, (hl)
    and a, $f0
    swap a
    ld (de), a
    inc de
    ld a, (hl)
    and a, $0f
    ld (de), a
    inc de
    pop hl
    dec b
    jr nz, -
    ret
load_monster_gfx_address:
    ldh a, (<hram.temp.1)
    add a, a
    ld hl, monster_gfx_id
    rst $00
    ld a, (hl)
    add a, a
    add a, (hl)
    ld hl, data_monster_gfx_index
    rst $00
    ldi a, (hl)
    push af
    ld c, (hl)
    inc hl
    ld b, (hl)
    ldh a, (<hram.temp.1)
    add a, a
    ld hl, monster_gfx_offset+$01
    rst $00
    ld d, (hl)
    ld hl, monster_gfx_id+$01
    rst $00
    ld h, (hl)
    ld l, d
    call x_multiply_8_8
    call add_bc_hl_16_x
    ld c, d
    ld b, $00
    sla c
    rl b
    sla c
    rl b
    sla c
    rl b
    sla c
    rl b
    pop af
    ret
procedural_battle_animation:
    push af
    push bc
    push de
    push hl
    push af
    call render_cc00_frame_with_no_oam
    pop af
    call procedural_battle_animation_helper
    call render_cc00_frame_with_no_oam
    jp pop_and_return
procedural_battle_animation_helper:
    and a, $3f
    add a, a
    ld hl, _jt_pba
    rst $00
    ldi a, (hl)
    ld h, (hl)
    ld l, a
    jp (hl)
pba_00_window_shake_vertical:
    ld b, $02
--  push bc
    ld hl, shake_offset_table
    ld bc, $084a
    ld e, $40
-   rst $10
    ld a, e
    add a, (hl)
    inc hl
    ldh (c), a
    dec b
    jr nz, -
    pop bc
    dec b
    jr nz, --
    rst $10
    ld a, $40
    ldh (<WY), a
    ret
pba_01_fade_out:
    call copy_window_to_background
    call erase_window_monster_gfx
    ld e, l
    ld d, h
    ld hl, $9900
    ld bc, $0140
    call vram_memcopy_16
    call monster_gfx_fade_out
    call use_full_battle_window
    call erase_monster_gfx
    rst $10
    ld a, $c3
    ldh (<LCDC), a
    jr restore_normal_battle_window
pba_fade_in:
    call copy_window_to_background
    ld hl, $9800
    ld de, $9c00
    ld bc, $0240
    call vram_memcopy_16
    call use_full_battle_window
    call x_far_call
    .addr xf_load_monster_gfx_tilemaps
    .db :xf_load_monster_gfx_tilemaps
    rst $10
    ld a, $c3
    ldh (<LCDC), a
    ld e, $00
    call display_monster_gfx_with_palette
    call monster_gfx_fade_in
    call restore_normal_battle_window
    ld a, (special_encounter)
    cp a, $02
    ret nz
    call x_far_call
    .addr xf_load_arsenal_cloud_background_lower
    .db :xf_load_arsenal_cloud_background_lower
    ret
erase_monster_gfx:
    ld hl, $9800
    jr +
erase_window_monster_gfx:
    ld hl, $9c00
+   ld b, $00
    ld a, $ff
    jp vram_memset
copy_window_to_background:
    ld hl, $9c00
    ld de, $9900
    ld bc, $0140
    call vram_memcopy_16
    rst $10
    ld a, $c3
    ldh (<LCDC), a
    ret
use_full_battle_window:
    rst $10
    ld a, $e3
    ldh (<LCDC), a
    ldh a, (<WY)
    ld (battle_animation_window_y_backup), a
    xor a, a
    ldh (<WY), a
    ret
restore_normal_battle_window:
    ld hl, $9900
    ld de, $9c00
    ld bc, $0140
    call vram_memcopy_16
    rst $10
    ld a, $e3
    ldh (<LCDC), a
    ld a, (battle_animation_window_y_backup)
    ldh (<WY), a
    ld hl, $9900
    ld bc, $0140
    ld a, $ff
    call vram_memset_16
    ld hl, $9d40
    ld bc, $0080
    jp vram_memset_16
pba_02_fade_out_in:
    call monster_gfx_fade_out
monster_gfx_fade_in:
    ld b, $03
--  push bc
    ld a, b
    dec a
    ld hl, fade_in_palette_table
    rst $00
    ld e, (hl)
    ld d, $07
-   rst $10
    call display_monster_gfx_with_palette
    dec d
    jr nz, -
    pop bc
    dec b
    jr nz, --
    xor a, a
    ld (battle_animation_fade_out), a
    ret
monster_gfx_fade_out:
    ld b, $03
--  push bc
    ld a, b
    dec a
    ld hl, fade_out_palette_table
    rst $00
    ld e, (hl)
    ld d, $07
-   rst $10
    call display_monster_gfx_with_palette
    dec d
    jr nz, -
    pop bc
    dec b
    jr nz, --
    ld a, $01
    ld (battle_animation_fade_out), a
    ret
display_monster_gfx_with_palette:
    ld a, e
    ldh (<BGP), a
    ldh (<OBP0), a
    ldh (<OBP1), a
-   ldh a, (<LY)
    cp a, $40
    jr nz, -
    ld a, (fade_out_palette_table+$03)
    ldh (<BGP), a
    ldh (<OBP0), a
    ldh (<OBP1), a
    ret
pba_12_monster_shake_horizontal:
    xor a, a
    ldh (<hram.temp.1), a
    xor a, a
    ldh (<hram.temp.2), a
    call @shake_iteration
@shake_iteration:
    xor a, a
    ldh (<hram.temp.3), a
-   rst $10
    ldh a, (<hram.temp.1)
    ldh (<SCX), a
    rst $10
    xor a, a
    ldh (<SCX), a
    rst $10
    ldh a, (<hram.temp.1)
    cpl
    inc a
    ldh (<SCX), a
    ldh a, (<hram.temp.3)
    and a, a
    ret nz
    ldh a, (<hram.temp.2)
    and a, a
    jr nz, +
    ldh a, (<hram.temp.1)
    add a, $01
    cp a, $08
    jr c, ++
    ld a, $01
    ldh (<hram.temp.2), a
    ld a, $08
++  ldh (<hram.temp.1), a
    jr -
+   ldh a, (<hram.temp.1)
    sub a, $01
    jr nc, +
    ld a, $ff
    ldh (<hram.temp.3), a
    xor a, a
    ldh (<hram.temp.2), a
+   ldh (<hram.temp.1), a
    jr -
pba_03_monster_shake_severe:
    ld b, $02
-   push bc
    ld hl, shake_offset_table
    ld bc, $0800+<SCX
    call shake_helper
    dec c
    call shake_helper
    pop bc
    dec b
    jr nz, -
    rst $10
    xor a, a
    ldh (<SCX), a
    ldh (<SCY), a
    ret
shake_helper:
    push bc
    push hl
-   rst $10
    ldi a, (hl)
    ldh (c), a
    dec b
    jr nz, -
    pop hl
    pop bc
    ret
pba_04_flicker:
    push af
    ld b, $02
--  push bc
-   ldh a, (<LY)
    cp a, $91
    jr c, -
    ldh a, (<LCDC)
    res 7, a
    ldh (<LCDC), a
    ldh (<DIV), a
-   ldh a, (<DIV)
    bit 2, a
    jr z, -
    ldh a, (<LCDC)
    set 7, a
    ldh (<LCDC), a
    ld b, $05
-   rst $10
    dec b
    jr nz, -
    pop bc
    dec b
    jr nz, --
    pop af
    ret
pba_05_nop:
    ret
pba_06_lift:
    ld a, (battle_animation_target_parameter)
    cp a, $09
    jr nz, +
    xor a, a
-   ldh (<hram.temp.1), a
    ld hl, battle.data.5.current_stack
    add a, h
    ld h, a
    ld a, (hl)
    and a, a
    call nz, @lift_single
    ldh a, (<hram.temp.1)
    inc a
    cp a, $03
    jr c, -
    ret
+   sub a, $05
    ldh (<hram.temp.1), a
@lift_single:
    ldh a, (<hram.temp.1)
    call x_far_call
    .addr xf_get_monster_gfx_tilemap_address
    .db :xf_get_monster_gfx_tilemap_address
    ld de, -$0020
    add hl, de
    call load_lift_write_position
    ld e, l
    ld d, h
    call get_monster_gfx_dimensions
    ld l, b
    ld h, $00
    call add_de_hl_32_x
    call store_lift_clear_position
    ld a, $07
    ldh (<hram.temp.2), a
    inc a
    ldh (<hram.temp.3), a
-   ldh a, (<hram.temp.2)
    and a, a
    jr z, +
    call x_far_call
    .addr xf_get_monster_gfx_dimensions_and_offset
    .db :xf_get_monster_gfx_dimensions_and_offset
    call store_lift_write_position
    call x_far_call
    .addr xf_draw_monster_gfx_tilemap
    .db :xf_draw_monster_gfx_tilemap
    call store_lift_write_position
    ld de, -$0020
    add hl, de
    call load_lift_write_position
    ld hl, hram.temp.2
    dec (hl)
+   ldh a, (<hram.temp.2)
    cp a, $05
    jr nc, +
    ldh a, (<hram.temp.3)
    and a, a
    jr z, +
    call get_monster_gfx_dimensions
    call load_lift_clear_position
    ld b, c
    ld a, $ff
    rst $10
    call memset
    call load_lift_clear_position
    ld de, -$0020
    add hl, de
    call store_lift_clear_position
    ld hl, hram.temp.3
    dec (hl)
+   ld hl, hram.temp.2
    ldi a, (hl)
    or a, (hl)
    jr nz, -
    ldh a, (<hram.temp.1)
    ld hl, battle_animation_lift_flag
    rst $00
    ld (hl), $01
    ret
get_monster_gfx_dimensions:
    push hl
    ldh a, (<hram.temp.1)
    add a, a
    ld hl, monster_gfx_dims
    rst $00
    ld c, (hl)
    inc hl
    ld b, (hl)
    pop hl
    ret
store_lift_write_position:
    ld hl, battle_animation_top_ptr
    ldi a, (hl)
    ld h, (hl)
    ld l, a
    ret
load_lift_write_position:
    ld a, l
    ld (battle_animation_top_ptr), a
    ld a, h
    ld (battle_animation_top_ptr+1), a
    ret
load_lift_clear_position:
    ld hl, battle_animation_bottom_ptr
    ldi a, (hl)
    ld h, (hl)
    ld l, a
    ret
store_lift_clear_position:
    ld a, l
    ld (battle_animation_bottom_ptr), a
    ld a, h
    ld (battle_animation_bottom_ptr+1), a
    ret
pba_07_scroll:
    ld a, (battle_animation_target_parameter)
    cp a, $09
    jr nz, +
    xor a, a
-   ldh (<hram.temp.1), a
    call _is_enemy_stack_defeated_2
    call nz, @scroll_single
    ldh a, (<hram.temp.1)
    inc a
    cp a, $03
    jr c, -
    ret
+   sub a, $05
    ldh (<hram.temp.1), a
@scroll_single:
    call buffer_monster_gfx
    ld b, $03
--  push bc
    call get_monster_gfx_dimensions_2
-   push bc
    call scroll_helper
    call copy_buffered_monster_gfx
    pop bc
    dec c
    jr nz, -
    pop bc
    dec b
    jr nz, --
    ret
_is_enemy_stack_defeated_2:
    ldh a, (<hram.temp.1)
    ld hl, battle.data.5.current_stack
    add a, h
    ld h, a
    ld a, (hl)
    and a, a
    ret
scroll_helper:
    call get_monster_gfx_dimensions_2
    ld c, b
    ld hl, monster_gfx_offset+$01
    rst $00
    ld e, (hl)
    ld a, e
    ldh (<hram.temp.2), a
    ldh a, (<hram.temp.1)
    ld hl, window_buffer_1
    add a, h
    ld h, a
    ld d, a
    push hl
    call memcopy
    pop de
    ld h, d
    ld l, c
    ldh a, (<hram.temp.2)
    ld b, a
    jp memcopy
copy_buffered_monster_gfx:
    call setup_monster_gfx_buffer_data
    call x_vram_enable
--  push bc
    push hl
-   ld a, (de)
    inc de
    ldi (hl), a
    dec b
    jr nz, -
    pop hl
    pop bc
    ld a, $20
    rst $00
    dec c
    jr nz, --
    jp x_vram_disable
buffer_monster_gfx:
    call setup_monster_gfx_buffer_data
    call x_vram_enable
-   push bc
    push hl
    call memcopy
    pop hl
    pop bc
    ld a, $20
    rst $00
    dec c
    jr nz, -
    jp x_vram_disable
setup_monster_gfx_buffer_data:
    call get_monster_gfx_dimensions_2
    ldh a, (<hram.temp.1)
    call x_far_call
    .addr xf_get_monster_gfx_tilemap_address
    .db :xf_get_monster_gfx_tilemap_address
    ld de, window_buffer_1
    add a, d
    ld d, a
    ret
get_monster_gfx_dimensions_2:
    ldh a, (<hram.temp.1)
    add a, a
    ld hl, monster_gfx_dims
    rst $00
    ld b, (hl)
    inc hl
    ld c, (hl)
    ret
pba_08_kill:
    ld a, (battle_animation_target_parameter)
    cp a, $09
    jr z, +
    ld hl, battle.data.1.current_stack
    add a, h
    ld h, a
    ld (hl), $00
    call x_far_call
    .addr xf_process_monster_gfx
    .db :xf_process_monster_gfx
+   ret
pba_09_line:
    ld d, $0f
    rst $10
--  ldh a, (<LY)
    cp a, $2f
    jr nz, --
    xor a, a
    ldh (<BGP), a
    ldh (<OBP0), a
    ldh (<OBP1), a
-   ldh a, (<LY)
    cp a, $31
    jr nz, -
    ld a, $d2
    ldh (<BGP), a
    ldh (<OBP0), a
    ld a, $16
    ldh (<OBP1), a
    dec d
    jr nz, --
    ret
pba_0a_nop:
    ret
pba_0b_rain:
    ld b, $10
    ld hl, data_battle_animation_gfx+$1100
    call load_animation_gfx
    call particle_initialize
    ld hl, window_buffer_1.particle_oam_type
    ld b, $28
    ld a, $0c
    call memset
    ld hl, window_buffer_1.particle_user_array_1
    ld b, $28
    ld a, $ff
    call memset
    ld b, $14
    ld de, $4001
    call particle_random_start_delay
    ld hl, window_buffer_1.particle_update
    ld (hl), $06
    inc hl
    ld (hl), $07
    ld hl, window_buffer_1.particle_count
    ld (hl), $14
    inc hl
    ld (hl), $28
    jp execute_particles
update_06_rain_particle:
    ldh a, (<hram.temp.1)
    add a, a
    ld hl, window_buffer_1.particle_position+$01
    rst $00
    ld a, (hl)
    add a, $0c
    cp a, $39
    jr nc, +
    ld (hl), a
    ret
+   ld hl, window_buffer_1.particle_user_data
    ld a, (hl)
    and a, a
    jp z, kill_particle
    dec (hl)
    ldh a, (<hram.temp.1)
    ld hl, window_buffer_1.particle_delay
    rst $00
    ld (hl), $01
    ld hl, window_buffer_1.particle_user_array_1
    rst $00
    ld (hl), $ff
    ret
update_07_rain_global:
    ld b, $01
    call render_cc00_frames
    xor a, a
_L000:
    ldh (<hram.temp.2), a
    ld hl, window_buffer_1.particle_delay
    rst $00
    inc (hl)
    dec (hl)
    jr nz, +
    ld hl, window_buffer_1.particle_user_array_1
    rst $00
    inc (hl)
    ld a, (hl)
    and a, a
    jr nz, +
    ld a, $33
    ld de, $1300
    call x_random_integer
    add a, a
    add a, a
    add a, a
    ld c, a
    ldh a, (<hram.temp.2)
    add a, a
    ld hl, window_buffer_1.particle_position
    rst $00
    ld (hl), c
    inc hl
    ld (hl), $00
+   ld a, (window_buffer_1.particle_count)
    ld b, a
    ldh a, (<hram.temp.2)
    inc a
    cp a, b
    jp c, _L000
    rst $10
    ret
pba_0c_curse_song:
    call pba_21_song
    ld b, $50
    ld hl, data_battle_animation_gfx+$4e0
    call load_animation_gfx
    ld b, $10
    ld hl, data_battle_animation_gfx+$5f0
    call load_animation_gfx_at_address
    call particle_initialize
    call setup_enemy_particles
    ldh a, (<hram.temp.2)
    ld c, a
    cp a, $03
    jr nz, +
    ld a, $20
    ld (window_buffer_1.particle_position+$03), a
+   ld a, c
    ld hl, window_buffer_1.particle_alive
    rst $00
-   cp a, $03
    jr z, +
    ld (hl), $ff
    inc hl
    inc a
    jr -
+   ld hl, window_buffer_1.particle_oam_type
    ld de, window_buffer_1.particle_delay
    ld b, $03
-   ld (hl), $05
    inc hl
    xor a, a
    ld (de), a
    inc de
    dec b
    jr nz, -
    ld hl, window_buffer_1.particle_update
    ld (hl), $09
    inc hl
    ld (hl), $0a
    ld a, $03
    ld (window_buffer_1.particle_count), a
    jp execute_particles
update_09_wraith_particle:
    ldh a, (<hram.temp.1)
    ld hl, window_buffer_1.particle_velocity+$01
    add a, a
    rst $00
    ld a, (hl)
    sub a, $03
    cp a, $70
    jp c, kill_particle
    ld (hl), a
    ret
update_0a_wraith_global:
    ld b, $02
    jp render_cc00_frames
setup_enemy_particles:
    xor a, a
    ldh (<hram.temp.2), a
-   call _is_enemy_stack_defeated
    jr nz, _L001
    inc a
    jr -
_L001:
    ldh (<hram.temp.1), a
    ld hl, monster_gfx_x_raw
    rst $00
    ld c, (hl)
    ldh a, (<hram.temp.2)
    add a, a
    ld hl, window_buffer_1.particle_position
    rst $00
    ld a, c
    sub a, $02
    add a, a
    add a, a
    add a, a
    ldi (hl), a
    ld (hl), $10
    ld hl, hram.temp.2
    inc (hl)
    ldh a, (<hram.temp.1)
    cp a, $02
    ret nc
-   inc a
    call _is_enemy_stack_defeated
    jr nz, _L001
    cp a, $02
    jr c, -
    ret
pba_11_heart_song:
    call pba_21_song
    ld b, $30
    ld hl, data_battle_animation_gfx+$4b0
    call load_animation_gfx
    ld hl, pba_heart_delay
    call particle_initialize_with_start_delay
    ld hl, window_buffer_1.particle_position
    ld de, pba_heart_x_position
    ld b, $0a
-   ld a, (de)
    inc de
    ldi (hl), a
    ld (hl), $30
    inc hl
    dec b
    jr nz, -
    ld hl, window_buffer_1.particle_oam_type
    ld bc, $0a00
-   ld a, c
    and a, $01
    add a, $03
    ldi (hl), a
    inc c
    dec b
    jr nz, -
    ld hl, window_buffer_1.particle_user_array_1
    ld b, $0a
    xor a, a
-   ldi (hl), a
    xor a, $01
    dec b
    jr nz, -
    xor a, a
    ldh (<hram.temp.2), a
    ld hl, window_buffer_1.particle_update
    ld (hl), $01
    inc hl
    ld (hl), $02
    ld a, $06
    ld (window_buffer_1.particle_count), a
    jp execute_particles
update_01_heart_particle:
    ldh a, (<hram.temp.1)
    ld hl, window_buffer_1.particle_user_array_1
    rst $00
    ld a, (hl)
    and a, a
    jr nz, +
    ldh a, (<hram.temp.1)
    ld hl, window_buffer_1.particle_position+$01
    add a, a
    rst $00
    ld a, (hl)
    sub a, $04
    jp c, kill_particle
    ld (hl), a
    ldh a, (<hram.temp.1)
    add a, a
    ld hl, window_buffer_1.particle_velocity
    rst $00
    ld a, (hl)
    add a, $02
    ld (hl), a
    cp a, $89
    ret c
    ld (hl), $88
    ldh a, (<hram.temp.1)
    ld hl, window_buffer_1.particle_user_array_1
    rst $00
    ld (hl), $01
    ret
+   ldh a, (<hram.temp.1)
    ld hl, window_buffer_1.particle_position+$01
    add a, a
    rst $00
    ld a, (hl)
    sub a, $04
    jp c, kill_particle
    ld (hl), a
    ldh a, (<hram.temp.1)
    add a, a
    ld hl, window_buffer_1.particle_velocity
    rst $00
    ld a, (hl)
    sub a, $02
    ld (hl), a
    cp a, $78
    ret nc
    ld (hl), $78
    ldh a, (<hram.temp.1)
    ld hl, window_buffer_1.particle_user_array_1
    rst $00
    ld (hl), $00
    ret
update_02_heart_global:
    ld b, $02
    call render_cc00_frames
    ld hl, hram.temp.2
    inc (hl)
    ldh a, (<hram.temp.2)
    and a, $04
    jr nz, +
    ld b, $0a
    ld hl, window_buffer_1.particle_oam_type
-   ld a, (hl)
    cp a, $04
    jr nc, ++
    ld a, $04
    jr _L002
++  ld a, $03
_L002:
    ldi (hl), a
    dec b
    jr nz, -
+   ret
pba_21_song:
    ld hl, data_battle_animation_gfx+$ea0
    ld b, $40
    call load_animation_gfx
    ld hl, pba_song_delay
    call particle_initialize_with_start_delay
    ld hl, window_buffer_1.particle_position
    ld de, pba_song_position
    ld b, $14
-   ld a, (de)
    inc de
    ldi (hl), a
    dec b
    jr nz, -
    ld hl, window_buffer_1.particle_oam_type
    ld bc, $0a00
-   ld a, c
    and a, $01
    add a, $06
    ldi (hl), a
    inc c
    dec b
    jr nz, -
    ld hl, window_buffer_1.particle_user_array_1
    ld b, $0a
    xor a, a
-   xor a, $01
    ldi (hl), a
    dec b
    jr nz, -
    ld hl, window_buffer_1.particle_update
    ld (hl), $03
    inc hl
    ld (hl), $04
    ld hl, window_buffer_1.particle_count
    ld (hl), $0a
    inc hl
    ld (hl), $14
    jp execute_particles
update_03_song_particle:
    ldh a, (<hram.temp.1)
    ld hl, window_buffer_1.particle_position
    add a, a
    rst $00
    ld a, (hl)
    add a, $06
    ld (hl), a
    cp a, $91
    jp nc, kill_particle
    ldh a, (<hram.temp.1)
    ld hl, window_buffer_1.particle_user_array_1
    rst $00
    ld a, (hl)
    and a, a
    jr nz, +
    ldh a, (<hram.temp.1)
    ld hl, window_buffer_1.particle_velocity+$01
    add a, a
    rst $00
    inc (hl)
    ld a, (hl)
    cp a, $88
    ret c
    ld (hl), $88
    ldh a, (<hram.temp.1)
    ld hl, window_buffer_1.particle_user_array_1
    rst $00
    ld (hl), $01
    ret
+   ldh a, (<hram.temp.1)
    ld hl, window_buffer_1.particle_velocity+$01
    add a, a
    rst $00
    dec (hl)
    ld a, (hl)
    cp a, $78
    ret nc
    ld (hl), $78
    ldh a, (<hram.temp.1)
    ld hl, window_buffer_1.particle_user_array_1
    rst $00
    ld (hl), $00
    ret
update_04_song_global:
    ld b, $02
    call render_cc00_frames
    ld hl, window_buffer_1.particle_user_data
    dec (hl)
    ret nz
    ld hl, window_buffer_1.particle_alive
    ld b, $28
    ld a, $ff
    jp memset
pba_0d_question:
    ld hl, data_battle_animation_gfx+$13a0
    ld b, $40
    call load_animation_gfx
    call particle_initialize
    ld hl, window_buffer_1.particle_delay
    ld b, $0a
-   ld a, $32
    ld de, $0501
    call x_random_integer
    ldi (hl), a
    dec b
    jr nz, -
    ld hl, window_buffer_1.particle_user_array_1
    ld b, $28
    ld a, $ff
    call memset
    ld hl, window_buffer_1.particle_update
    ld (hl), $00
    inc hl
    ld (hl), $0b
    ld hl, window_buffer_1.particle_count
    ld (hl), $05
    inc hl
    ld (hl), $0a
    jp execute_particles
update_0b_question_global:
    ld b, $04
    call render_cc00_frames
    xor a, a
_L003:
    ldh (<hram.temp.2), a
    ld hl, window_buffer_1.particle_delay
    rst $00
    inc (hl)
    dec (hl)
    jr nz, +
    ld hl, window_buffer_1.particle_user_array_1
    rst $00
    inc (hl)
    ld a, (hl)
    and a, a
    jr z, ++
    ld (hl), $ff
    ldh a, (<hram.temp.2)
    ld hl, window_buffer_1.particle_delay
    rst $00
    ld (hl), $01
    ld hl, window_buffer_1.particle_user_data
    ld a, (hl)
    and a, a
    jr z, _L004
    dec (hl)
    jr nz, +
_L004:
    ldh a, (<hram.temp.2)
    ld hl, window_buffer_1.particle_alive
    rst $00
    ld (hl), $ff
    jr +
++  ld a, $30
    ld de, $0400
    call x_random_integer
    call scale_a_32x
    ld c, a
    ldh a, (<hram.temp.2)
    add a, a
    ld hl, window_buffer_1.particle_position
    rst $00
    ld (hl), c
    inc hl
    ld (hl), $00
    ldh a, (<hram.temp.2)
    ld hl, window_buffer_1.particle_oam_type
    rst $00
    ld (hl), $06
+   ld a, (window_buffer_1.particle_count)
    ld b, a
    ldh a, (<hram.temp.2)
    inc a
    cp a, b
    jp c, _L003
    ret
pba_13_short_explosions:
    ld a, $08
    ldh (<hram.temp.1), a
    ld a, $01
    ldh (<hram.temp.3), a
    jr +
pba_0e_long_explosions:
    ld a, $10
    ldh (<hram.temp.1), a
    ld a, $02
    ldh (<hram.temp.3), a
+   call load_explosion_sprites
    call particle_initialize
    ld hl, window_buffer_1.particle_delay
    ld b, $03
    ld a, $01
-   ldi (hl), a
    inc a
    dec b
    jr nz, -
    ld hl, window_buffer_1.particle_user_array_1
    ld b, $28
    ld a, $ff
    call memset
    ld hl, window_buffer_1.particle_update
    ld (hl), $00
    inc hl
    ld (hl), $05
    ld hl, window_buffer_1.particle_count
    ld (hl), $03
    inc hl
    ldh a, (<hram.temp.1)
    ld (hl), a
    jp execute_particles
update_05_explode_global:
    ldh a, (<hram.temp.3)
    ld b, a
    call render_cc00_frames
    xor a, a
_L005:
    ldh (<hram.temp.2), a
    ld hl, window_buffer_1.particle_delay
    rst $00
    inc (hl)
    dec (hl)
    jr nz, +
    ld hl, window_buffer_1.particle_user_array_1
    rst $00
    inc (hl)
    ld a, (hl)
    cp a, $03
    jr c, ++
    ld (hl), $ff
    ldh a, (<hram.temp.2)
    ld hl, window_buffer_1.particle_delay
    rst $00
    ld (hl), $01
    ld hl, window_buffer_1.particle_user_data
    ld a, (hl)
    and a, a
    jr z, _L006
    dec (hl)
    jr nz, +
_L006:
    ldh a, (<hram.temp.2)
    ld hl, window_buffer_1.particle_alive
    rst $00
    ld (hl), $ff
    jr +
++  and a, a
    jr nz, ++
    ld a, $30
    ld de, $1000
    call x_random_integer
    add a, a
    add a, a
    add a, a
    ld c, a
    ld a, $31
    ld de, $0400
    call x_random_integer
    add a, a
    add a, a
    add a, a
    ld b, a
    ldh a, (<hram.temp.2)
    add a, a
    ld hl, window_buffer_1.particle_position
    rst $00
    ld (hl), c
    inc hl
    ld (hl), b
++  ldh a, (<hram.temp.2)
    ld hl, window_buffer_1.particle_user_array_1
    rst $00
    ld c, (hl)
    ld hl, window_buffer_1.particle_oam_type
    rst $00
    ld (hl), c
+   ld a, (window_buffer_1.particle_count)
    ld b, a
    ldh a, (<hram.temp.2)
    inc a
    cp a, b
    jp c, _L005
    ret
pba_0f_gather_and_fade_out:
    call pba_gather
    jp pba_01_fade_out
pba_gather:
    ld hl, data_battle_animation_gfx+$1930
    ld b, $20
    call load_animation_gfx
    call particle_initialize
    ld hl, window_buffer_1.particle_user_array_1
    ld b, $28
    ld a, $ff
    call memset
    ld b, $28
    ld de, $1001
    call particle_random_start_delay
    ld hl, window_buffer_1.particle_update
    ld (hl), $00
    inc hl
    ld (hl), $0e
    ld a, $28
    ld (window_buffer_1.particle_count), a
    jp execute_particles
update_0e_gather_global:
    rst $10
    ld a, >oam_staging_cc
    rst $18
    xor a, a
_L007:
    ldh (<hram.temp.2), a
    ld hl, window_buffer_1.particle_delay
    rst $00
    inc (hl)
    dec (hl)
    jp nz, _L008
    ldh a, (<hram.temp.2)
    ld hl, window_buffer_1.particle_user_array_1
    rst $00
    inc (hl)
    ld a, (hl)
    and a, a
    jr nz, +
    ld a, $30
    ld de, $ff00
    call x_random_integer
    ld hl, window_buffer_1.particle_user_array_2
    ld b, a
    ldh a, (<hram.temp.2)
    rst $00
    ld (hl), b
    ld a, $31
    ld de, $4010
    call x_random_integer
    ld hl, window_buffer_1.particle_user_array_3
    ld b, a
    ldh a, (<hram.temp.2)
    rst $00
    ld (hl), b
+   ldh a, (<hram.temp.2)
    ld hl, window_buffer_1.particle_user_array_2
    rst $00
    ld e, (hl)
    ld hl, window_buffer_1.particle_user_array_3
    rst $00
    ld d, (hl)
    ld bc, $1c4c
    call polar_offset
    ldh a, (<hram.temp.2)
    add a, a
    ld hl, window_buffer_1.particle_position
    rst $00
    ld (hl), c
    inc hl
    ld (hl), b
    ldh a, (<hram.temp.2)
    ld hl, window_buffer_1.particle_user_array_1
    rst $00
    ld c, (hl)
    ld hl, window_buffer_1.particle_oam_type
    rst $00
    ld a, c
    and a, $01
    add a, $08
    ld (hl), a
    ldh a, (<hram.temp.2)
    ld hl, window_buffer_1.particle_user_array_3
    rst $00
    ld a, (hl)
    sub a, $08
    jr nc, +
    push hl
    ldh a, (<hram.temp.2)
    ld hl, window_buffer_1.particle_alive
    rst $00
    ld (hl), $ff
    pop hl
    xor a, a
+   ld (hl), a
_L008:
    ld a, (window_buffer_1.particle_count)
    ld b, a
    ldh a, (<hram.temp.2)
    inc a
    cp a, b
    jp c, _L007
    ret
pba_10_circles:
    ld hl, data_battle_animation_gfx+$420
    ld b, $20
    call load_animation_gfx
    call particle_initialize
    ld hl, window_buffer_1.particle_delay
    ld b, $0a
-   ld a, $32
    ld de, $0401
    call x_random_integer
    ldi (hl), a
    dec b
    jr nz, -
    ld hl, window_buffer_1.particle_user_array_1
    ld b, $28
    ld a, $ff
    call memset
    ld hl, window_buffer_1.particle_update
    ld (hl), $00
    inc hl
    ld (hl), $08
    ld hl, window_buffer_1.particle_count
    ld (hl), $0a
    inc hl
    ld (hl), $0a
    jp execute_particles
update_08_circles_global:
    ld b, $04
    call render_cc00_frames
    xor a, a
_L009:
    ldh (<hram.temp.2), a
    ld hl, window_buffer_1.particle_delay
    rst $00
    inc (hl)
    dec (hl)
    jr nz, +
    ld hl, window_buffer_1.particle_user_array_1
    rst $00
    inc (hl)
    ld a, (hl)
    cp a, $02
    jr c, ++
    ld (hl), $ff
    ldh a, (<hram.temp.2)
    ld hl, window_buffer_1.particle_delay
    rst $00
    ld (hl), $01
    ld hl, window_buffer_1.particle_user_data
    ld a, (hl)
    and a, a
    jr z, _L010
    dec (hl)
    jr nz, +
_L010:
    ldh a, (<hram.temp.2)
    ld hl, window_buffer_1.particle_alive
    rst $00
    ld (hl), $ff
    jr +
++  and a, a
    jr nz, ++
    ld a, $30
    ld de, $1200
    call x_random_integer
    add a, a
    add a, a
    add a, a
    ld c, a
    ld a, $31
    ld de, $0600
    call x_random_integer
    add a, a
    add a, a
    add a, a
    ld b, a
    ldh a, (<hram.temp.2)
    add a, a
    ld hl, window_buffer_1.particle_position
    rst $00
    ld (hl), c
    inc hl
    ld (hl), b
++  ldh a, (<hram.temp.2)
    ld hl, window_buffer_1.particle_user_array_1
    rst $00
    ld c, (hl)
    ld hl, window_buffer_1.particle_oam_type
    rst $00
    ld a, c
    add a, $0a
    ld (hl), a
+   ld a, (window_buffer_1.particle_count)
    ld b, a
    ldh a, (<hram.temp.2)
    inc a
    cp a, b
    jp c, _L009
    ret
_unused:
    ret
pba_15_arsenal_cannon_1:
    ld bc, $0028
    call arsenal_cannon_explosion
    ld bc, $1038
    ld a, $11
    ldh (<hram.temp.1), a
    ld a, $0d
    ldh (<hram.temp.2), a
    xor a, a
    ldh (<hram.temp.3), a
    jr arsenal_cannon_beam
pba_16_arsenal_cannon_2:
    ld bc, $1860
    call arsenal_cannon_explosion
    ld bc, $2868
    ld a, $11
    ldh (<hram.temp.1), a
    ld a, $0e
    ldh (<hram.temp.2), a
    ld a, $01
    ldh (<hram.temp.3), a
    jr arsenal_cannon_beam
pba_17_arsenal_cannon_3:
    ld bc, $2030
    call arsenal_cannon_explosion
    ld bc, $3040
    ld a, $09
    ldh (<hram.temp.1), a
    ld a, $0f
    ldh (<hram.temp.2), a
    ld a, $02
    ldh (<hram.temp.3), a
    jr arsenal_cannon_beam
pba_18_arsenal_cannon_4:
    ld bc, $0860
    call arsenal_cannon_explosion
    ld bc, $1068
    ld a, $09
    ldh (<hram.temp.1), a
    ld a, $10
    ldh (<hram.temp.2), a
    ld a, $03
    ldh (<hram.temp.3), a
arsenal_cannon_beam:
    push bc
    ld b, $30
    ld hl, data_battle_animation_gfx+$1f40
    call load_animation_gfx
    pop bc
    ldh a, (<hram.temp.1)
    ld hl, oam_staging_cc
    call stage_pba_oam_data_at_address
    push bc
    call render_cc00_frame
    pop bc
    ld e, $05
-   ldh a, (<hram.temp.3)
    and a, a
    jr z, +
    dec a
    jr z, ++
    dec a
    jr z, _L011
    ld a, c
    sub a, $08
    ld c, a
    jr _L013
_L011:
    ld a, c
    add a, $08
    ld c, a
    jr _L012
++  ld a, c
    sub a, $08
    ld c, a
_L012:
    ld a, b
    sub a, $08
    ld b, a
    jr ++
+   ld a, c
    add a, $08
    ld c, a
_L013:
    ld a, b
    add a, $08
    ld b, a
++  ldh a, (<hram.temp.2)
    call stage_pba_oam_data
    push bc
    call render_cc00_frame
    pop bc
    dec e
    jr nz, -
    ld hl, oam_staging_cc
    ld b, $04
    call memclear
    call render_cc00_frame
    ld e, $05
-   ld b, $0c
    call memclear
    call render_cc00_frame
    dec e
    jr nz, -
    ret
render_cc00_frame:
    ld b, $01
    jp render_cc00_frames
load_explosion_sprites:
    ld hl, data_battle_animation_gfx+$330
    ld b, $90
    call load_animation_gfx
    ld hl, data_battle_animation_gfx+$440
    ld b, $60
    jp load_animation_gfx_at_address
arsenal_cannon_explosion:
    ld hl, hram.temp.1
    ld (hl), c
    inc hl
    ld (hl), b
    call load_explosion_sprites
    ld a, $00
    call @explosion_frame
    ld a, $15
    call @explosion_frame
    ld a, $01
@explosion_frame:
    ld hl, hram.temp.1
    ld c, (hl)
    inc hl
    ld b, (hl)
    ld hl, oam_staging_cc
    call stage_pba_oam_data_helper
    ld b, $04
    call render_cc00_frames
    ld hl, oam_staging_cc
    ld b, $a0
    jp memset
pba_19_launch_smasher:
    ld hl, $9300
    ld de, arsenal_gfx_backup
    call x_vram_enable
    call backup_arsenal_hatch_tiles
    call backup_arsenal_hatch_tiles
    call backup_arsenal_hatch_tiles
    call x_vram_disable
    ld hl, data_battle_animation_gfx+$1d20
    ld b, $04
-   push bc
    call load_arsenal_hatch_tiles
    ld b, $0f
    call render_cc00_frames
    pop bc
    dec b
    jr nz, -
    ld b, $60
    ld hl, data_battle_animation_gfx+$1ea0
    call load_animation_gfx
    ld b, $03
-   push bc
    call initialize_launch_smasher_start
    ld b, $04
    call render_cc00_frames
    ld hl, oam_staging_cc
    ld b, $a0
    call memclear
    ld b, $04
    call render_cc00_frames
    pop bc
    dec b
    jr nz, -
pba_1c_launch_smasher_fireballs:
    ld b, $90
    ld hl, data_battle_animation_gfx+$1c90
    call load_animation_gfx
    call particle_initialize
    ld hl, window_buffer_1.particle_position
    ld b, $04
-   ld (hl), $44
    inc hl
    ld (hl), $14
    inc hl
    dec b
    jr nz, -
    ld hl, window_buffer_1.particle_oam_type
    ld bc, $0400
-   ld a, c
    and a, $01
    add a, $13
    ldi (hl), a
    inc c
    dec b
    jr nz, -
    ld hl, window_buffer_1.particle_user_array_1
    xor a, a
    ld b, $04
-   ldi (hl), a
    add a, $40
    dec b
    jr nz, -
    xor a, a
    ldh (<hram.temp.2), a
    ld hl, window_buffer_1.particle_update
    ld (hl), $0c
    inc hl
    ld (hl), $0d
    ld a, $04
    ld (window_buffer_1.particle_count), a
    ld a, $26
    ldh (<hram.audio.sfx), a
    jp execute_particles
update_0c_smasher_particle:
    ldh a, (<hram.temp.1)
    ld hl, window_buffer_1.particle_user_array_1
    rst $00
    ld e, (hl)
    ldh a, (<hram.temp.2)
    ld d, a
    ld bc, $1444
    call polar_offset
    ldh a, (<hram.temp.1)
    ld hl, window_buffer_1.particle_user_array_1
    rst $00
    ld a, (hl)
    add a, $10
    ld (hl), a
    ldh a, (<hram.temp.1)
    add a, a
    ld hl, window_buffer_1.particle_position
    rst $00
    ld (hl), c
    inc hl
    ld (hl), b
    ldh a, (<hram.temp.1)
    ld hl, window_buffer_1.particle_oam_type
    rst $00
    ld b, $13
    ld a, (hl)
    cp a, b
    ld a, b
    jr nz, +
    ld a, b
    inc a
+   ld (hl), a
    ret
update_0d_smasher_global:
    ld b, $02
    call render_cc00_frames
    ldh a, (<hram.temp.2)
    add a, $01
    ldh (<hram.temp.2), a
    cp a, $28
    ret c
    ld hl, window_buffer_1.particle_alive
    ld b, $04
    ld a, $ff
    jp memset
load_arsenal_hatch_tiles:
    call x_vram_enable
    ld de, $9300
    call load_arsenal_hatch_tiles_helper
    ld de, $93e0
    call load_arsenal_hatch_tiles_helper
    ld de, $94c0
    call load_arsenal_hatch_tiles_helper
    jp x_vram_disable
backup_arsenal_hatch_tiles:
    ld b, $20
    call memcopy
    ld a, $c0
    rst $00
    ret
load_arsenal_hatch_tiles_helper:
    ld b, $20
    ld a, :data_battle_animation_gfx
    jp memcopy_from_bank
initialize_launch_smasher_start:
    ld a, $12
    ld bc, $1848
    ld hl, oam_staging_cc
    jp stage_pba_oam_data_helper
pba_1a_close_hatch:
    ld bc, $0400
-   push bc
    ld hl, smasher_hatch_address_table
    ld a, c
    add a, a
    rst $00
    ldi a, (hl)
    ld h, (hl)
    ld l, a
    call load_arsenal_hatch_tiles
    ld b, $0f
    call render_cc00_frames
    pop bc
    inc c
    dec b
    jr nz, -
    ret
pba_1b_morph_apollo:
    ld bc, $0033
    jr +
pba_1f_morph_apollo_injured:
    ld bc, $0134
    jr +
pba_20_morph_apollo_injured_2:
    ld bc, $0135
+   call x_far_call
    .addr x1_monster_gfx_morph
    .db :x1_monster_gfx_morph
    ret
pba_22_meat:
    call x_far_call
    .addr x1_do_meat_animation
    .db :x1_do_meat_animation
    ret
particle_random_start_delay:
    ld hl, window_buffer_1.particle_delay
-   ld a, $32
    call x_random_integer
    ldi (hl), a
    dec b
    jr nz, -
    ret
_jt_particle_update:
    .addr update_00_nop
    .addr update_01_heart_particle
    .addr update_02_heart_global
    .addr update_03_song_particle
    .addr update_04_song_global
    .addr update_05_explode_global
    .addr update_06_rain_particle
    .addr update_07_rain_global
    .addr update_08_circles_global
    .addr update_09_wraith_particle
    .addr update_0a_wraith_global
    .addr update_0b_question_global
    .addr update_0c_smasher_particle
    .addr update_0d_smasher_global
    .addr update_0e_gather_global
update_00_nop:
    ret
_jt_pba:
    .addr pba_00_window_shake_vertical
    .addr pba_01_fade_out
    .addr pba_02_fade_out_in
    .addr pba_03_monster_shake_severe
    .addr pba_04_flicker
    .addr pba_05_nop
    .addr pba_06_lift
    .addr pba_07_scroll
    .addr pba_08_kill
    .addr pba_09_line
    .addr pba_0a_nop
    .addr pba_0b_rain
    .addr pba_0c_curse_song
    .addr pba_0d_question
    .addr pba_0e_long_explosions
    .addr pba_0f_gather_and_fade_out
    .addr pba_10_circles
    .addr pba_11_heart_song
    .addr pba_12_monster_shake_horizontal
    .addr pba_13_short_explosions
    .addr _unused
    .addr pba_15_arsenal_cannon_1
    .addr pba_16_arsenal_cannon_2
    .addr pba_17_arsenal_cannon_3
    .addr pba_18_arsenal_cannon_4
    .addr pba_19_launch_smasher
    .addr pba_1a_close_hatch
    .addr pba_1b_morph_apollo
    .addr pba_1c_launch_smasher_fireballs
    .addr update_00_nop
    .addr pba_1b_morph_apollo
    .addr pba_1f_morph_apollo_injured
    .addr pba_20_morph_apollo_injured_2
    .addr pba_21_song
    .addr pba_22_meat
smasher_hatch_address_table:
    .addr data_battle_animation_gfx+$1de0
    .addr data_battle_animation_gfx+$1d80
    .addr data_battle_animation_gfx+$1d20
    .addr arsenal_gfx_backup
shake_offset_table:
    .db $02
    .db $04
    .db $08
    .db $10
    .db $f0
    .db $f8
    .db $fc
    .db $fe
fade_out_palette_table:
    .db $00
    .db $40
    .db $81
    .db $d2
fade_in_palette_table:
    .db $d2
    .db $81
    .db $40
    .db $00
pba_heart_delay:
    .db $01
    .db $0a
    .db $03
    .db $0c
    .db $01
    .db $05
    .db $05
    .db $0f
    .db $19
    .db $08
pba_heart_x_position:
    .db $10
    .db $30
    .db $48
    .db $70
    .db $88
    .db $10
    .db $30
    .db $48
    .db $70
    .db $88
pba_song_delay:
    .db $01
    .db $01
    .db $01
    .db $01
    .db $01
    .db $01
    .db $01
    .db $01
    .db $08
    .db $10
_unused_table:
    .db $02
    .db $01
    .db $00
    .db $01
    .db $02
    .db $01
    .db $01
    .db $00
    .db $00
    .db $01
pba_song_position:
    .db $08, $20
    .db $18, $10
    .db $30, $28
    .db $38, $08
    .db $50, $18
    .db $68, $28
    .db $70, $08
    .db $80, $20
    .db $00, $08
    .db $00, $28
_unused_table_2:
    .db $08, $00
    .db $28, $00
    .db $48, $00
    .db $68, $00
    .db $88, $00
    .db $18, $10
    .db $38, $10
    .db $58, $10
    .db $78, $10
polar_offset:
    push af
    push de
    push hl
    ld a, e
    add a, $40
    call sine
    add a, c
    push af
    ld a, e
    call sine
    add a, b
    ld b, a
    pop af
    ld c, a
    pop hl
    pop de
    pop af
    ret
sine:
    ld l, a
    ld h, >data_sine
    ld a, :data_sine
    call read_from_bank
    push af
    bit 7, a
    jr z, +
    cpl
    inc a
+   ld l, a
    ld h, d
    call x_multiply_8_8
    ld a, $7f
    call divide_u16_u8
    pop af
    rlca
    jr nc, +
    ld a, l
    cpl
    inc a
    ld l, a
+   ld a, l
    ret
divide_u16_u8:
    push bc
    push de
    ld e, a
    cpl
    ld d, a
    inc d
    xor a, a
    ld b, $10
-   sla l
    rl h
    rla
    add a, d
    jr c, +
    add a, e
    inc l
+   dec b
    jr nz, -
    ld b, a
    ld a, l
    cpl
    ld l, a
    ld a, h
    cpl
    ld h, a
    ld a, b
    pop de
    pop bc
    ret
execute_particles:
    call clear_staged_oam_cc
    ld hl, oam_staging_cc
    call set_pba_oam_staging_address
    xor a, a
_L014:
    ldh (<hram.temp.1), a
    ld hl, window_buffer_1.particle_delay
    rst $00
    inc (hl)
    dec (hl)
    jr nz, +
    ld hl, window_buffer_1.particle_alive
    rst $00
    inc (hl)
    dec (hl)
    jr nz, +
    ldh a, (<hram.temp.1)
    add a, a
    ld hl, window_buffer_1.particle_position
    rst $00
    ld c, (hl)
    inc hl
    ld b, (hl)
    ldh a, (<hram.temp.1)
    add a, a
    ld hl, window_buffer_1.particle_velocity
    rst $00
    ldi a, (hl)
    sub a, $80
    add a, c
    ld c, a
    ld a, (hl)
    sub a, $80
    add a, b
    ld b, a
    ldh a, (<hram.temp.1)
    ld hl, window_buffer_1.particle_oam_type
    rst $00
    ld a, (hl)
    call stage_pba_oam_data
    ld a, (window_buffer_1.particle_update)
    call particle_update
+   ldh a, (<hram.temp.1)
    ld hl, window_buffer_1.particle_delay
    rst $00
    ld a, (hl)
    and a, a
    jr z, +
    dec (hl)
+   ld a, (window_buffer_1.particle_count)
    ld b, a
    ldh a, (<hram.temp.1)
    inc a
    cp a, b
    jp c, _L014
    ld a, (window_buffer_1.particle_global_update)
    call particle_update
    call are_all_particles_dead
    jp nz, execute_particles
    jp render_cc00_frame_with_no_oam
particle_update:
    add a, a
    ld hl, _jt_particle_update
    rst $00
    ldi a, (hl)
    ld h, (hl)
    ld l, a
    jp (hl)
particle_initialize_with_start_delay:
    push hl
    call particle_initialize
    pop hl
    ld de, window_buffer_1.particle_delay
    ld b, $0a
    jp memcopy
particle_initialize:
    ld hl, window_buffer_1
    ld bc, $0140
    call memclear_16
    ld a, $80
    ld b, $50
    jp memset
kill_particle:
    ldh a, (<hram.temp.1)
    ld hl, window_buffer_1.particle_alive
    rst $00
    ld (hl), $ff
    ret
are_all_particles_dead:
    ld a, (window_buffer_1.particle_count)
    ld b, a
    ld c, $ff
    ld hl, window_buffer_1.particle_alive
-   ldi a, (hl)
    and a, c
    ld c, a
    dec b
    jr nz, -
    inc c
    ret
stage_pba_oam_data:
    call get_pba_oam_staging_address
stage_pba_oam_data_at_address:
    call stage_pba_oam_data_helper
set_pba_oam_staging_address:
    push af
    ld a, l
    ld (window_buffer_1.particle_oam_ptr), a
    ld a, h
    ld (window_buffer_1.particle_oam_ptr+1), a
    pop af
    ret
get_pba_oam_staging_address:
    push af
    ld hl, window_buffer_1.particle_oam_ptr
    ldi a, (hl)
    ld h, (hl)
    ld l, a
    pop af
    ret
stage_pba_oam_data_helper:
    push af
    push de
    ld e, l
    ld d, h
    add a, a
    ld hl, data_oam_types
    rst $00
    call read_pba_oam_type_data
    push af
    call read_pba_oam_type_data
    ld h, a
    pop af
    ld l, a
-   call read_pba_oam_type_data
    cp a, $ff
    jr z, +
    add a, b
    ld (de), a
    inc de
    call read_pba_oam_type_data
    add a, c
    ld (de), a
    inc de
    call read_pba_oam_type_data
    push af
    and a, $0f
    ld (de), a
    inc de
    pop af
    and a, $f0
    ld (de), a
    inc de
    jr -
+   ld l, e
    ld h, d
    pop de
    pop af
    ret
read_pba_oam_type_data:
    ld a, :data_oam_types
    jp stream_read_helper
load_animation_gfx:
    ld de, $8000
load_animation_gfx_at_address:
    ld a, :data_battle_animation_gfx
    jp vram_memcopy_from_bank
clear_staged_oam_cc:
    ld b, $a0
    ld hl, oam_staging_cc
    jp memclear
render_cc00_frame_with_no_oam:
    call clear_staged_oam_cc
    ld b, $01
render_cc00_frames:
    rst $10
    ld a, >oam_staging_cc
    rst $18
    dec b
    jr nz, render_cc00_frames
    ret

.ends


