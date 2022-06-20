.include "common.i"

.bank $00 slot 0
.orga $1900

.section "map" size $2700 overwrite

x_new_game:
    jp new_game
x_continue_game:
    jp continue_game
x_execute_script_command:
    jp execute_script_command
x_refresh_npcs:
    jp refresh_npcs
x_use_item_helper:
    jp use_item_helper
x_load_encounter:
    jp load_encounter
x_update_save_variables:
    jp update_save_variables
x_restore_map_bank_d:
    jp restore_map_bank_d
x_add_player_offset_non_battle:
    jp add_player_offset_non_battle
x_restore_map_sprite_gfx:
    jp restore_map_sprite_gfx
x_load_random_encounter:
    jp load_random_encounter
x_refresh_player_gfx:
    jp refresh_player_gfx
    nop
    nop
    nop
fx_screen_shake_offsets:
    .db $00, $00
    .db $fc, $00
    .db $02, $01
    .db $00, $ff
    .db $00, $02
    .db $ff, $ff
    .db $01, $01
    .db $00, $ff
wavy_wipe_offsets:
    .db $04, $08
    .db $0a, $0c
    .db $0c, $0e
    .db $0c, $0a
    .db $08, $04
    .db $fc, $f8
    .db $f4, $f2
    .db $f0, $f2
    .db $f4, $f6
    .db $fa, $80
update_save_variables:
    ld a, (map_header)
    ld (saved_current_map), a
    ld a, (map_header+1)
    ld (saved_current_map+1), a
    ld a, (player.x)
    swap a
    and a, $0f
    ld c, a
    ld a, (camera.x)
    add a, c
    ld c, a
    ld a, (player.facing)
    rrca
    rrca
    and a, $c0
    or a, c
    ld (saved_player_x_and_dir), a
    ld a, (player.y)
    swap a
    and a, $0f
    ld c, a
    ld a, (camera.y)
    add a, c
    ld (saved_player_y), a
    ld a, (player.z)
    ld (saved_player_z), a
    ld a, (transparency_arg)
    ld (saved_transparency_arg), a
    ld a, (player.transparency)
    ld (saved_player_transparency), a
    ld a, (menu_fx_backup)
    ld (script_vars+$0f), a
    ret
continue_game:
    ld a, <npc_command_stack
    ld (npc_command_stack_top), a
    ld a, (saved_current_map)
    ld (map_header), a
    ld a, (saved_current_map+1)
    ld (map_header+1), a
    ld a, (saved_player_x_and_dir)
    ld b, a
    and a, $3f
    sub a, $05
    ld (camera.x), a
    ld a, b
    rlca
    rlca
    and a, $03
    ld (player.facing), a
    ld a, (saved_player_y)
    and a, $3f
    sub a, $04
    ld (camera.y), a
    ld a, $40
    ld (player.y), a
    ld a, $50
    ld (player.x), a
    ld a, $01
    ld (continue_flag), a
    jr +
new_game:
    ld a, <npc_command_stack
    ld (npc_command_stack_top), a
    xor a, a
    ld (continue_flag), a
    ld a, $fe
    ld (current_command), a
    ld a, $06
    ld (current_command+1), a
    call load_door
    ld a, $01
    jr ++
+   xor a, a
++  ld (hide_player_flag), a
    ldh (<BGP), a
    ldh (<OBP0), a
    ldh (<OBP1), a
    ld a, $90
    ldh (<WY), a
    call clear_staged_npc_oam
    call load_map_header
    ld a, (tileset)
    call load_tile_gfx
    call load_tilemap
    ld a, (tileset)
    call load_tile_info
    call start_game_helper
    call load_player_gfx
    call refresh_player
    call load_npcs
    call load_vehicles
    call refresh_npc_tile_info
    ld a, (continue_flag)
    or a, a
    jr z, +
    ld a, (saved_player_z)
    ld (player.z), a
    ld a, (saved_transparency_arg)
    ld (transparency_arg), a
    ld a, (saved_player_transparency)
    ld (player.transparency), a
+   call reset_scrolling_and_draw_tilemap
    call screen_reverse_wipe_fade
game_loop:
    ld a, (player.move_dir)
    or a, a
    jr nz, +
    call process_map_tile_events
    ld a, (current_command+1)
    cp a, $0e
    jp z, execute_door_command_inline
    cp a, $05
    jr c, ++
    cp a, $07
    jp c, execute_door_command_inline
++  call process_map_mode_button_input
    call process_map_mode_dpad_input
    call process_queued_player_move
+   call process_npc_wandering
    call process_npcs
    call process_command
    jr game_loop
vector_zero:
    .db $00, $00
vector_direction:
    .db $00, $01
    .db $00, $ff
    .db $ff, $00
    .db $01, $00
start_game_helper:
    ld a, $00
    ld (player.move_info), a
    xor a, a
    ld (hram.fade_in_type), a
    ld (battle_door), a
    ld ($c45d), a
    ld a, $ff
    ld (current_command), a
    ld (current_command+1), a
    ld a, $c3
    ldh (<LCDC), a
    ret
apply_scrolling_and_fx_and_oam_dma:
    push hl
    push af
    call x_oam_dma_standard
    ld a, (script_vars+$0f)
    and a, $f0
    cp a, $10
    jr nz, +
    ld hl, shake_frame_counter
    inc (hl)
    ld a, (hl)
    and a, $07
    add a, a
    add a, <fx_screen_shake_offsets
    ld l, a
    ld h, >fx_screen_shake_offsets
    ldi a, (hl)
    ldh (<hram.fx_shake.dy), a
    ld a, (hl)
    ldh (<hram.fx_shake.dx), a
    jr ++
+   xor a, a
    ldh (<hram.fx_shake.dy), a
    ldh (<hram.fx_shake.dx), a
    ld hl, fx_screen_shake_offsets+$01
++  ldh a, (<hram.scroll_base.x)
    add a, (hl)
    ldh (<SCX), a
    dec l
    ldh a, (<hram.scroll_base.y)
    add a, (hl)
    ldh (<SCY), a
    ld a, (wave_fx_counter)
    inc a
    and a, $1f
    ld (wave_fx_counter), a
    pop af
    pop hl
    ret
execute_door_command_inline:
    call execute_door_command
    ld a, $ff
    ld (current_command), a
    ld (current_command+1), a
    jp game_loop
execute_battle_door_command:
    call load_battle_door
    jr +
execute_door_command:
    call load_door
+   call screen_wipe_fade
    ld a, (script_vars+$0f)
    ld (temp_fx_3), a
    and a, $0f
    ld (script_vars+$0f), a
    call set_lcd_stat_interrupt_standard
    call load_map_header
    call clear_staged_npc_oam
    ld a, (lite_door_flag)
    or a, a
    jr nz, +
    ld a, (tileset)
    call load_tile_gfx
    call load_tilemap
    ld a, (tileset)
    call load_tile_info
    call load_player_gfx
    call load_npcs
    call load_vehicles
+   call refresh_player
    call refresh_npc_tile_info
    call reset_scrolling_and_draw_tilemap
    call screen_reverse_wipe
    ld a, (temp_fx_3)
    ld (script_vars+$0f), a
    ret
clear_staged_npc_oam:
    ld hl, oam_staging_c0+$10
    xor a, a
    ld b, $90
-   ldi (hl), a
    dec b
    jr nz, -
    ld hl, oam_staging_c1+$10
    ld b, $90
-   ldi (hl), a
    dec b
    jr nz, -
    ret
clear_staged_oam:
    ld hl, oam_staging_c0
    xor a, a
    ld b, $a0
-   ldi (hl), a
    dec b
    jr nz, -
    ld hl, oam_staging_c1
    ld b, $a0
-   ldi (hl), a
    dec b
    jr nz, -
    ret
restore_map_bank_d:
    call restore_map
    ld a, $0d
    rst $28
    ret
execute_script_without_fx:
    ld a, (script_vars+$0f)
    ld (temp_fx_1), a
    and a, $0f
    ld (script_vars+$0f), a
    call set_lcd_stat_interrupt_standard
    rst $20
    ld a, (script_vars+$0f)
    and a, $f0
    cp a, $30
    jr z, +
    or a, a
    ret nz
    ld a, (script_vars+$0f)
    and a, $0f
    ld b, a
    ld a, (temp_fx_1)
    and a, $f0
    or a, b
    ld (script_vars+$0f), a
    ret
+   ld a, (script_vars+$0f)
    and a, $0f
    ld (script_vars+$0f), a
    ret
add_player_offset_non_battle:
    cp a, $04
    jr z, +
    inc a
    push bc
    ld b, a
    ld a, (party_order)
    rlca
    rlca
-   rrca
    rrca
    dec b
    jr nz, -
    pop bc
    and a, $03
    swap a
    sla a
    add a, l
    ld l, a
    ret
+   ld a, l
    add a, $80
    ld l, a
    ret
load_tile_info:
    ld c, $00
    srl a
    rr c
    srl a
    rr c
    srl a
    rr c
    ld b, a
    ld hl, data_tile_set_info
    add hl, bc
    ld a, :data_tile_set_info
    rst $28
    ld de, tile_info_buffer
    ld b, $20
-   ldi a, (hl)
    ld (de), a
    inc e
    dec b
    jr nz, -
    ret
load_battle_door:
    ld a, (current_command)
    ld l, a
    ld a, (current_command+1)
    and a, $01
    ld h, a
    add hl, hl
    add hl, hl
    ld de, data_doors
    ld a, :data_doors
    rst $28
    add hl, de
    jr load_door_from_address
load_door:
    ld hl, vector_zero
    call get_player_position_plus_offset
    call get_map_tile
    ld a, (bc)
    res 7, a
    ld (bc), a
    ld a, (current_command)
    ld l, a
    ld a, (current_command+1)
    cp a, $0e
    jr nz, +
    and a, $01
    ld h, a
    add hl, hl
    add hl, hl
    ld de, data_doors_2
    jr ++
+   and a, $01
    xor a, $01
    ld h, a
    jr z, +
    ld a, l
    inc a
    jr nz, +
    ld hl, exit_door
    jr load_door_from_address
+   add hl, hl
    add hl, hl
    ld de, data_doors
++  ld a, :data_doors
    rst $28
    add hl, de
    ld a, (saved_current_map)
    ld (exit_door), a
    ld a, (saved_current_map+1)
    ld (exit_door+$01), a
    ld a, (camera.x)
    ld e, a
    ld a, (player.x)
    swap a
    and a, $0f
    add a, e
    ld e, a
    ld a, (player.facing)
    xor a, $01
    rrca
    rrca
    and a, $c0
    or a, e
    ld (exit_door+$02), a
    ld a, (camera.y)
    ld e, a
    ld a, (player.y)
    swap a
    and a, $0f
    add a, e
    inc a
    ld (exit_door+$03), a
load_door_from_address:
    ld e, (hl)
    inc hl
    ld d, (hl)
    inc hl
    ld a, e
    ld (saved_current_map), a
    ld (map_header), a
    ld a, d
    ld (saved_current_map+1), a
    ld (map_header+1), a
    ldi a, (hl)
    ld b, a
    and a, $3f
    sub a, $05
    ld (camera.x), a
    ld a, b
    rlca
    rlca
    and a, $03
    ld (player.facing), a
    ldi a, (hl)
    ld b, a
    and a, $3f
    sub a, $04
    ld (camera.y), a
    ld a, b
    and a, $40
    ld (lite_door_flag), a
    ld a, b
    and a, $80
    ld b, a
    jr z, +
    ld a, $16
    ldh (<hram.audio.sfx), a
+   ld a, (exit_door+$03)
    or a, b
    ld (exit_door+$03), a
    ld a, $40
    ld (player.y), a
    ld a, $50
    ld (player.x), a
    ret
load_map_header:
    ld a, :data_map_headers
    rst $28
    ld a, (map_header)
    ld e, a
    ld a, (map_header+1)
    ld d, a
    ld a, (de)
    inc de
    ld (tilemap), a
    ld a, (de)
    inc de
    ld (tilemap+1), a
    ld a, (de)
    inc de
    ld (tileset), a
    ld a, (de)
    inc de
    ld c, a
    and a, $0f
    ld (tileset_trigger_count), a
    ld a, $80
    and a, c
    ld (npc_flag), a
    ld a, $40
    and a, c
    ld (encounter_flag), a
    swap c
    ld a, c
    and a, $03
    ld (tile_animation_info), a
    ld a, (encounter_flag)
    or a, a
    jr z, +
    ld a, (de)
    ld (encounter_set), a
    inc de
    ld a, (de)
    ld (encounter_rate), a
    inc de
+   ld a, (de)
    ld l, a
    inc de
    ld a, e
    ld (map_trigger_data), a
    ld a, d
    ld (map_trigger_data+1), a
    ld h, $00
    add hl, hl
    add hl, de
    ld a, l
    ld (map_npc_gfx), a
    ld a, h
    ld (map_npc_gfx+1), a
    ret
battle_door_save:
    ld a, (battle_door)
    ld c, a
    ld a, (battle_door+$01)
    or a, c
    ret nz
    ld a, (player.z)
    ld (battle_door_saved_z), a
    ld a, (transparency_arg)
    ld (battle_door_saved_transparency_arg), a
    ld a, (player.transparency)
    ld (battle_door_saved_transparency), a
    ld a, (saved_current_map)
    ld (battle_door), a
    ld a, (saved_current_map+1)
    ld (battle_door+$01), a
    ld a, (camera.x)
    ld e, a
    ld a, (player.x)
    swap a
    and a, $0f
    add a, e
    ld e, a
    ld a, (player.facing)
    rrca
    rrca
    and a, $c0
    or a, e
    ld (battle_door+$02), a
    ld a, (camera.y)
    ld e, a
    ld a, (player.y)
    swap a
    and a, $0f
    add a, e
    ld (battle_door+$03), a
    ret
load_vehicles:
    xor a, a
    ld (vehicle_npc_index_backup), a
    ld de, npc.16
    ld hl, vehicle_data
    ld c, $04
_L000:
    push hl
    push bc
    ld a, (map_header)
    cp a, (hl)
    jp nz, _L001
    inc hl
    ld a, (map_header+1)
    xor a, (hl)
    and a, $3f
    jp nz, _L001
    ldi a, (hl)
    and a, $c0
    rlca
    rlca
    inc a
    ld c, $80
-   rlc c
    dec a
    jr nz, -
    ld a, e
    or a, $0c
    ld e, a
    ld a, c
    ld (de), a
    ld a, e
    and a, $f0
    ld e, a
    pop bc
    push bc
    ld a, $05
    sub a, c
    ld c, a
    push de
    ld e, $1f
    call x_get_script_var
    pop de
    cp a, c
    ld b, $80
    jr z, +
    ld b, $00
+   ldi a, (hl)
    ld c, a
    and a, $3f
    or a, $40
    or a, b
    ld (de), a
    inc e
    xor a, a
    ld (de), a
    inc e
    ld a, b
    or a, a
    ldi a, (hl)
    ld b, a
    jr nz, +
    push bc
    ld a, c
    and a, $3f
    ld c, a
    ld a, b
    and a, $3f
    ld b, a
    call get_map_tile
    set 7, a
    ld (bc), a
    pop bc
+   ld a, b
    and a, $3f
    ld (de), a
    inc e
    xor a, a
    ld (de), a
    inc e
    ld (de), a
    ld a, b
    and a, $c0
    rrca
    rrca
    ld b, a
    ld a, e
    and a, $f0
    or a, $0c
    ld e, a
    ld a, (de)
    or a, b
    ld (de), a
    ld a, e
    and a, $f0
    or a, $05
    ld e, a
    ld a, b
    or a, a
    jr z, +
    ld b, $01
+   ld a, c
    and a, $c0
    ld c, a
    rrca
    rrca
    or a, c
    or a, b
    ld (de), a
    inc e
    xor a, a
    ld (de), a
    inc e
    inc e
    pop bc
    push bc
    ld a, $10
    ld (de), a
    inc e
    ld a, $04
    sub a, c
    or a, $08
    ld (de), a
    inc e
    ld a, $f0
    ld (de), a
    inc e
    xor a, a
    ld (de), a
    inc e
    inc e
    ld (de), a
_L001:
    pop bc
    pop hl
    inc l
    inc l
    inc l
    inc l
    ld a, e
    and a, $f0
    sub a, $10
    ld e, a
    dec c
    jp nz, _L000
    ret
refresh_player:
    push de
    ld e, $1f
    call x_get_script_var
    pop de
    or a, a
    jr z, +
    ld b, a
    ld a, $05
    sub a, b
    ld b, $80
-   rlc b
    dec a
    jr nz, -
    ld a, b
    ld (player.current_speed), a
    ld (player.speed), a
    ld a, $01
    ld (player.sprite), a
    ld a, $01
    ld (player.animation_type), a
    ld a, <data_oam_templates+$80
    ld (player.oam_template), a
    ld a, >data_oam_templates
    ld (player.oam_template+1), a
    jr ++
+   ld a, $01
    ld (player.current_speed), a
    ld (player.speed), a
    xor a, a
    ld (player.sprite), a
    call load_player_oam_metadata
++  xor a, a
    ld (conveyer_speed), a
    ld (player.move_dir), a
    ld (tile_visited_flag), a
refresh_player_tilemap_data:
    ld hl, vector_zero
    call get_player_position_plus_offset
    call get_map_tile
    ld a, (bc)
    set 7, a
    ld (bc), a
    call get_trigger_map_tile
    ld c, a
    and a, $20
    ld (inside_flag), a
    ld a, c
    and a, $1f
    add a, <tile_info_buffer
    ld c, a
    ld b, >tile_info_buffer
    ld a, (bc)
    ld e, a
    cp a, $c0
    jr nc, +
    bit 7, a
    jr nz, _L003
    bit 2, a
    jr nz, ++
    and a, $03
    jr z, _L002
    xor a, $03
_L002:
    ld (player.z), a
_L003:
    ld a, e
    and a, $30
    ld (player.transparency), a
    jr _L004
++  ld a, (player.z)
    and a, $01
    jr z, _L003
    ld e, $30
    jr _L003
+   xor a, a
    ld (player.transparency), a
    ld (player.z), a
_L004:
    ld a, (player.facing)
    call stage_player_oam
    ret
load_player_oam_metadata:
    ld e, $1f
    call x_get_script_var
    or a, a
    jr nz, +
    xor a, a
-   push af
    ld hl, player.1.status
    call add_player_offset_non_battle
    pop af
    bit 4, (hl)
    jr z, ++
    inc a
    jr -
++  ld a, l
    sub a, player.1.status-player.1.monster_id
    ld l, a
    ld a, (hl)
    ld b, $00
    ld c, a
    ld hl, data_monster_npc_gfx
    add hl, bc
    ld a, :data_monster_npc_gfx
    rst $28
    ld a, (hl)
    add a, $00
    ld l, a
    ld h, >data_animation_type
    ld a, :data_animation_type
    rst $28
    ld c, $00
    ld a, (hl)
    ld (player.animation_type), a
    srl a
    rr c
    ld b, a
    ld hl, data_oam_templates
    add hl, bc
    ld a, l
    ld (player.oam_template), a
    ld a, h
    ld (player.oam_template+1), a
    ret
+   ld a, $01
    ld (player.animation_type), a
    ld a, <data_oam_templates+$80
    ld (player.oam_template), a
    ld a, >data_oam_templates
    ld (player.oam_template+1), a
    ret
refresh_player_gfx:
    call load_player_gfx
    call load_player_oam_metadata
    jp _L004
load_player_gfx:
    xor a, a
-   push af
    ld hl, player.1.status
    call add_player_offset_non_battle
    pop af
    bit 4, (hl)
    jr z, +
    inc a
    jr -
+   ld a, l
    sub a, player.1.status-player.1.monster_id
    ld l, a
    ld a, (hl)
    ld b, $00
    ld c, a
    ld hl, data_monster_npc_gfx
    add hl, bc
    ld a, :data_monster_npc_gfx
    rst $28
    ld a, (hl)
    add a, >data_npc_gfx
    ld h, a
    ld l, <data_npc_gfx
    ld a, :data_npc_gfx
    rst $28
    ld de, $8000
    ld bc, $0100
    call vram_memcopy_16
    ret
load_tile_gfx:
    ld c, $00
    srl a
    rr c
    srl a
    rr c
    srl a
    rr c
    ld b, a
    ld hl, data_tile_set_tiles
    add hl, bc
    ld a, :data_map_tile_gfx
    rst $28
-   ldh a, (<LY)
    cp a, $96
    jr nz, -
    ld a, $43
    ldh (<LCDC), a
    ld de, $9000
    ld b, $20
-   push bc
    ld a, :data_tile_set_tiles
    call read_from_bank
    inc hl
    ld b, a
    ld c, $00
    srl b
    rr c
    srl b
    rr c
    push hl
    ld hl, data_map_tile_gfx
    add hl, bc
    ld b, $40
    call memcopy
    pop hl
    pop bc
    dec b
    jr nz, -
    ld a, $c3
    ldh (<LCDC), a
    xor a, a
    ld (tile_animation_stage), a
    ret
finish_map_mode_frame:
    call update_fx
    rst $10
    call apply_scrolling_and_fx_and_oam_dma
update_scrolling_and_tile_animation:
    call update_tile_animation
    ld c, <hram.scroll_base.y
    ld a, (player.current_speed)
    ld b, a
    ld a, (player.move_dir)
    dec a
    jr z, +
    dec a
    jr z, ++
    dec a
    jr z, _L005
    inc c
    ldh a, (c)
    add a, b
    ldh (c), a
    add a, $08
    jr _L006
_L005:
    inc c
    ldh a, (c)
    sub a, b
    ldh (c), a
    add a, $08
    jr _L006
++  ldh a, (c)
    sub a, b
    jr ++
+   ldh a, (c)
    add a, b
    jr ++
++  ldh (c), a
_L006:
    and a, $0f
    ret nz
    ld (player.move_dir), a
    ld a, (player.speed)
    ld (player.current_speed), a
    xor a, a
    ld (conveyer_speed), a
    ret
player_move:
    add a, a
    ld e, a
    ld d, $00
    ld hl, jt_player_move
    add hl, de
    ld e, (hl)
    inc hl
    ld d, (hl)
    ld a, (vram_addr_of_upper_left_visible_16x16_tile)
    ld l, a
    ld a, (vram_addr_of_upper_left_visible_16x16_tile+1)
    ld h, a
    ld a, (camera.y)
    ld b, a
    ld a, (camera.x)
    ld c, a
    push de
    ret
jt_player_move:
    .addr _player_move_down
    .addr _player_move_up
    .addr _player_move_left
    .addr _player_move_right
_player_move_up:
    ld a, (camera.y)
    dec a
    ld (camera.y), a
    dec b
    ld de, $ffc0
    add hl, de
    ld a, h
    and a, $fb
    or a, $08
    ld h, a
    ld a, l
    ld (vram_addr_of_upper_left_visible_16x16_tile), a
    ld a, h
    ld (vram_addr_of_upper_left_visible_16x16_tile+1), a
    call load_tilemap_tile_row
    call draw_tilemap_row
    call update_scrolling_and_tile_animation
    ret
_player_move_down:
    ld a, (camera.y)
    inc a
    ld (camera.y), a
    ld a, b
    add a, $09
    ld b, a
    ld de, $0240
    add hl, de
    ld a, h
    and a, $fb
    ld h, a
    call load_tilemap_tile_row
    call draw_tilemap_row
    ld a, (vram_addr_of_upper_left_visible_16x16_tile)
    add a, $40
    ld (vram_addr_of_upper_left_visible_16x16_tile), a
    ld a, (vram_addr_of_upper_left_visible_16x16_tile+1)
    adc a, $00
    and a, $fb
    ld (vram_addr_of_upper_left_visible_16x16_tile+1), a
    call update_scrolling_and_tile_animation
    ret
_player_move_left:
    ld a, (camera.x)
    dec a
    ld (camera.x), a
    dec c
    ld a, l
    dec a
    dec a
    and a, $1f
    push af
    ld a, l
    and a, $e0
    ld l, a
    pop af
    or a, l
    ld l, a
    ld a, l
    ld (vram_addr_of_upper_left_visible_16x16_tile), a
    ld a, h
    ld (vram_addr_of_upper_left_visible_16x16_tile+1), a
    call load_tilemap_tile_column
    call draw_tilemap_column
    call update_scrolling_and_tile_animation
    ret
_player_move_right:
    ld a, (camera.x)
    inc a
    ld (camera.x), a
    ld a, c
    add a, $0b
    ld c, a
    ld a, l
    add a, $16
    and a, $1f
    push af
    ld a, l
    and a, $e0
    ld l, a
    pop af
    or a, l
    ld l, a
    call load_tilemap_tile_column
    call draw_tilemap_column
    ld a, (vram_addr_of_upper_left_visible_16x16_tile)
    ld l, a
    ld a, (vram_addr_of_upper_left_visible_16x16_tile+1)
    ld h, a
    ld a, l
    inc a
    inc a
    and a, $1f
    push af
    ld a, l
    and a, $e0
    ld l, a
    pop af
    or a, l
    ld l, a
    ld a, l
    ld (vram_addr_of_upper_left_visible_16x16_tile), a
    ld a, h
    ld (vram_addr_of_upper_left_visible_16x16_tile+1), a
    call update_scrolling_and_tile_animation
    ret
reset_scrolling_and_draw_tilemap:
    ld hl, vram_addr_of_upper_left_visible_16x16_tile
    ld (hl), $00
    inc hl
    ld (hl), $98
    xor a, a
    ldh (<hram.scroll_base.y), a
    ld a, $08
    ldh (<hram.scroll_base.x), a
    call draw_tilemap
    ret
draw_tilemap:
    ld a, (vram_addr_of_upper_left_visible_16x16_tile)
    ld l, a
    ld a, (vram_addr_of_upper_left_visible_16x16_tile+1)
    ld h, a
    ld a, (camera.y)
    ld b, a
    ld a, $09
-   push af
    push hl
    ld a, (camera.x)
    ld c, a
    call load_tilemap_tile_row
    call draw_tilemap_row
    pop hl
    ld de, $0040
    add hl, de
    ld a, h
    and a, $fb
    ld h, a
    pop af
    inc b
    dec a
    jr nz, -
    ret
load_tilemap_tile_row:
    push hl
    ld hl, tile_buffer
    ld a, $0b
-   push af
    ld a, b
    or a, c
    and a, $c0
    jr nz, +
    push bc
    call get_map_tile
    pop bc
    jr ++
+   xor a, a
++  call get_visible_map_tile
    add a, a
    add a, a
    ldi (hl), a
    inc a
    ldi (hl), a
    inc a
    ldi (hl), a
    inc a
    ldi (hl), a
    pop af
    inc c
    dec a
    jr nz, -
    pop hl
    ret
load_tilemap_tile_column:
    push hl
    ld hl, tile_buffer
    ld a, $09
-   push af
    ld a, c
    or a, b
    and a, $c0
    jr nz, +
    push bc
    call get_map_tile
    pop bc
    jr ++
+   xor a, a
++  call get_visible_map_tile
    add a, a
    add a, a
    ldi (hl), a
    inc a
    ldi (hl), a
    inc a
    ldi (hl), a
    inc a
    ldi (hl), a
    inc a
    pop af
    inc b
    dec a
    jr nz, -
    pop hl
    ret
draw_tilemap_row:
    call update_fx
    rst $10
    call apply_scrolling_and_fx_and_oam_dma
    ld de, tile_buffer
-   ld a, (de)
    ldi (hl), a
    inc e
    ld a, (de)
    ldd (hl), a
    inc e
    set 5, l
    ld a, (de)
    ldi (hl), a
    inc e
    ld a, (de)
    ld (hl), a
    inc e
    res 5, l
    inc l
    res 5, l
    ld a, e
    cp a, $2c
    jr c, -
    ret
draw_tilemap_column:
    push bc
    call update_fx
    rst $10
    call apply_scrolling_and_fx_and_oam_dma
    ld bc, tile_buffer
-   ld a, (bc)
    ldi (hl), a
    inc c
    ld a, (bc)
    ldd (hl), a
    inc c
    set 5, l
    ld a, (bc)
    ldi (hl), a
    inc c
    ld a, (bc)
    ldd (hl), a
    inc c
    ld de, $0020
    add hl, de
    ld a, h
    and a, $fb
    ld h, a
    ld a, c
    cp a, $24
    jr c, -
    pop bc
    ret
get_visible_map_tile:
    and a, $7f
    cp a, $40
    jr nc, +
    ld e, a
    ld a, (inside_flag)
    xor a, e
    cp a, $20
    ret c
    ld a, (inside_flag)
    swap a
    dec a
    cp a, $01
    ret z
    ld a, $02
    ret
+   and a, $1f
    ld e, a
    ld d, >trigger_original_tile_buffer
    ld a, (de)
    jr get_visible_map_tile
_update_tile_animation_top:
    ld a, (tile_animation_stage)
    add a, $80
    ld l, a
    xor a, $40
    ld e, a
    ld h, $97
    ld d, h
    ld a, (de)
    ld c, (hl)
    ldi (hl), a
    ld a, c
    ld (de), a
    inc e
    ld a, (de)
    ld c, (hl)
    ld (hl), a
    ld a, c
    ld (de), a
    set 4, l
    set 4, e
    ld a, (de)
    ld c, (hl)
    ldd (hl), a
    ld a, c
    ld (de), a
    dec e
    ld a, (de)
    ld c, (hl)
    ld (hl), a
    ld a, c
    ld (de), a
    jr +
update_tile_animation:
    ld a, (tile_animation_info)
    or a, a
    jr z, _update_tile_animation_top
    ld e, a
    ld d, a
    ld a, (tile_animation_stage)
    add a, $c0
    ld l, a
    ld h, $97
    ld c, (hl)
    set 4, l
    ld b, (hl)
    ld a, b
-   rra
    rr c
    rr b
    dec d
    jr nz, -
    ld (hl), b
    res 4, l
    ld (hl), c
    inc l
    ld c, (hl)
    set 4, l
    ld b, (hl)
    ld a, b
-   rra
    rr c
    rr b
    dec e
    jr nz, -
    ld (hl), b
    res 4, l
    ld (hl), c
+   ld a, (tile_animation_stage)
    inc a
    inc a
    ld (tile_animation_stage), a
    ld c, a
    and a, $0f
    ret nz
    ld a, c
    add a, $10
    and a, $20
    ld (tile_animation_stage), a
    ret
load_tilemap:
    ld a, (tilemap)
    ld l, a
    ld a, (tilemap+1)
    ld h, a
    call load_tilemap_helper
    ret
load_tilemap_helper:
    ld a, :data_tile_maps_2
    rst $28
    bit 6, h
    jr nz, +
    ld a, $40
    add a, h
    ld h, a
    ld a, :data_tile_maps_1
    rst $28
+   call load_tilemap_tiles
    call load_tilemap_triggers
    ret
load_tilemap_tiles:
    call tilemap_stream_load_block
    push hl
    ld d, $00
    ld hl, jt_tilemap_command
    add hl, de
    ld e, (hl)
    inc hl
    ld d, (hl)
    pop hl
    push de
    ret
jt_tilemap_command:
    .addr tc_00_end
    .addr tc_01_tile
    .addr tc_02_set_position
    .addr tc_03_rectangle_outline
    .addr tc_04_rectangle_filled
    .addr tc_05_circle
    .addr tc_06_line
    .addr tc_07_clear
    .addr tc_08_flood_fill
    .addr tc_09_line_contd
    .addr tc_0a_condition
tc_00_end:
    ret
tc_0a_condition:
    push de
    ld e, b
    and a, $0f
    call x_get_script_var
    pop de
    ld b, a
    ld a, c
    and a, $0f
    cp a, b
    ret c
    ld a, c
    swap a
    and a, $0f
    cp a, b
    jr z, load_tilemap_tiles
    ret nc
    jr load_tilemap_tiles
tc_08_flood_fill:
    call tilemap_unpack_12_6_6
    ld e, c
    ld a, (temp_map_x)
    ld c, a
    ld a, (temp_map_y)
    ld b, a
    push bc
    call get_map_tile
    pop bc
    ld d, a
    push bc
-   push bc
    call get_map_tile
    pop bc
    cp a, d
    jr nz, +
    call tilemap_flood_fill
    inc b
    ld a, b
    cp a, $40
    jr nc, +
    jr -
+   pop bc
    dec b
-   push bc
    call get_map_tile
    pop bc
    cp a, d
    jr nz, +
    call tilemap_flood_fill
    dec b
    ld a, b
    cp a, $40
    jr nc, +
    jr -
+   jp load_tilemap_tiles
tilemap_flood_fill:
    push bc
_L007:
    push bc
    call get_map_tile
    cp a, d
    jr nz, +
    ld a, e
    ld (bc), a
    pop bc
    inc c
    ld a, c
    cp a, $40
    jr nc, ++
    jp _L007
+   pop bc
++  pop bc
    push bc
    dec c
_L008:
    push bc
    call get_map_tile
    cp a, d
    jr nz, +
    ld a, e
    ld (bc), a
    pop bc
    dec c
    ld a, c
    cp a, $40
    jr nc, ++
    jp _L008
+   pop bc
++  pop bc
    ret
tc_07_clear:
    call tilemap_unpack_12_6_6
    push hl
    ld hl, tilemap_buffer
    ld e, $40
--  ld a, $20
-   ld (hl), c
    inc hl
    ld (hl), b
    inc hl
    dec a
    jr nz, -
    ld a, b
    ld b, c
    ld c, a
    dec e
    jr nz, --
    pop hl
    jp load_tilemap_tiles
tc_01_tile:
    ldi a, (hl)
    push hl
    and a, $3f
    ld hl, tilemap_buffer
    add hl, bc
    ld (hl), a
    pop hl
    jp load_tilemap_tiles
tc_02_set_position:
    call tilemap_unpack_12_6_6
    ld a, c
    ld (temp_map_x), a
    ld a, b
    ld (temp_map_y), a
    jp load_tilemap_tiles
tc_03_rectangle_outline:
    call tilemap_unpack_12_6_6
    call tilemap_stream_load_pair
    push hl
    call tilemap_justify_rectangle
    push hl
_L009:
    ld a, e
    call tilemap_set
    ld a, l
    cp a, c
    jr z, _L010
    ld a, e
    ld e, d
    ld d, a
    inc l
    jp _L009
_L010:
    ld a, e
    call tilemap_set
    ld a, h
    cp a, b
    jr z, +
    ld a, e
    ld e, d
    ld d, a
    inc h
    jp _L010
+   pop bc
_L011:
    ld a, e
    call tilemap_set
    ld a, l
    cp a, c
    jr z, _L012
    ld a, e
    ld e, d
    ld d, a
    dec l
    jp _L011
_L012:
    ld a, e
    call tilemap_set
    ld a, h
    cp a, b
    jr z, +
    ld a, e
    ld e, d
    ld d, a
    dec h
    jp _L012
+   pop hl
    jp load_tilemap_tiles
tc_04_rectangle_filled:
    call tilemap_unpack_12_6_6
    call tilemap_stream_load_pair
    push hl
    call tilemap_justify_rectangle
_L013:
    push de
    push hl
_L014:
    ld a, e
    call tilemap_set
    ld a, l
    cp a, c
    jr z, +
    ld a, e
    ld e, d
    ld d, a
    inc l
    jp _L014
+   pop hl
    pop de
    ld a, h
    cp a, b
    jr z, +
    ld a, d
    ld d, e
    ld e, a
    inc h
    jp _L013
+   pop hl
    jp load_tilemap_tiles
tilemap_small_circle:
    dec a
    add a, a
    ld e, a
    ld d, $00
    push hl
    ld hl, circle_data
    add hl, de
    ld e, (hl)
    inc hl
    ld d, (hl)
    pop hl
_L015:
    ld a, (de)
    cp a, $ff
    jr z, +
    inc de
    ld c, a
    ld a, (de)
    inc de
    ld b, a
    push hl
    ld a, l
    add a, c
    ld l, a
    ld a, h
    add a, b
    ld h, a
    call tilemap_set_safe
    pop hl
    push hl
    ld a, l
    add a, b
    ld l, a
    ld a, h
    sub a, c
    ld h, a
    call tilemap_set_safe
    pop hl
    push hl
    ld a, l
    sub a, c
    ld l, a
    ld a, h
    sub a, b
    ld h, a
    call tilemap_set_safe
    pop hl
    push hl
    ld a, l
    sub a, b
    ld l, a
    ld a, h
    add a, c
    ld h, a
    call tilemap_set_safe
    pop hl
    jp _L015
+   pop hl
    jp load_tilemap_tiles
tilemap_set_safe:
    ld a, l
    cp a, $40
    jr nc, +
    ld a, h
    cp a, $40
    jr nc, +
    ld a, (temp_map_6)
    call tilemap_set
+   ret
tc_05_circle:
    call tilemap_unpack_12_6_6
    call tilemap_stream_load_pair
    ld a, e
    ld (temp_map_6), a
    push hl
    ld a, (temp_map_x)
    ld l, a
    ld a, (temp_map_y)
    ld h, a
    ld a, c
    sub a, l
    ld c, a
    cp a, $80
    jr c, +
    xor a, $ff
    inc a
+   ld e, a
    ld a, b
    sub a, h
    ld b, a
    cp a, $80
    jr c, +
    xor a, $ff
    inc a
+   ld d, a
    ld a, e
    add a, d
    jr z, +
    cp a, $08
    jr nc, +
    jp tilemap_small_circle
+   ld (temp_map_5), a
    push hl
    ld h, $00
    ld l, a
    add hl, hl
    add hl, hl
    add hl, hl
    inc hl
    ld a, l
    ld (temp_map_8), a
    ld a, h
    ld (temp_map_9), a
    pop hl
    ld d, b
    ld b, c
    ld c, $00
    ld e, c
-   push hl
    ld h, d
    ld l, e
    call tilemap_math_divide_signed
    add hl, bc
    ld c, l
    ld b, h
    call tilemap_math_divide_signed
    ld a, l
    ld l, e
    ld e, a
    ld a, h
    ld h, d
    ld d, a
    ld a, e
    xor a, $ff
    ld e, a
    ld a, d
    xor a, $ff
    ld d, a
    inc de
    add hl, de
    ld e, l
    ld d, h
    pop hl
    push hl
    ld a, l
    add a, b
    cp a, $40
    jr nc, +
    ld l, a
    ld a, h
    add a, d
    cp a, $40
    jr nc, +
    ld h, a
    ld a, (temp_map_6)
    call tilemap_set
+   ld a, (temp_map_8)
    ld l, a
    ld a, (temp_map_9)
    ld h, a
    dec hl
    ld a, l
    ld (temp_map_8), a
    ld a, h
    ld (temp_map_9), a
    or a, l
    pop hl
    jr nz, -
    pop hl
    jp load_tilemap_tiles
tilemap_math_divide_signed:
    push de
    push bc
    push af
    ld a, h
    cp a, $80
    jr c, +
    ld a, h
    xor a, $ff
    ld h, a
    ld a, l
    xor a, $ff
    ld l, a
    inc hl
    call tilemap_math_divide_unsigned
    ld a, h
    xor a, $ff
    ld h, a
    ld a, l
    xor a, $ff
    ld l, a
    inc hl
    pop af
    pop bc
    pop de
    ret
+   call tilemap_math_divide_unsigned
    pop af
    pop bc
    pop de
    ret
tilemap_math_divide_unsigned:
    ld de, $0000
    ld a, (temp_map_5)
    ld c, a
    xor a, a
    ld b, $10
-   sla l
    rl h
    rla
    cp a, c
    ccf
    rl e
    rl d
    cp a, c
    jr c, +
    sub a, c
+   dec b
    jr nz, -
    ld l, e
    ld h, d
    ret
tc_09_line_contd:
    call tilemap_unpack_12_6_6
    call tilemap_stream_load_pair
    push hl
    ld a, (temp_map_lx)
    ld l, a
    ld a, (temp_map_ly)
    ld h, a
    jr +
tc_06_line:
    call tilemap_unpack_12_6_6
    call tilemap_stream_load_pair
    push hl
    ld a, (temp_map_x)
    ld l, a
    ld a, (temp_map_y)
    ld h, a
+   ld a, c
    ld (temp_map_lx), a
    ld a, b
    ld (temp_map_ly), a
    ld a, c
    sub a, l
    ld (temp_map_5), a
    ld a, b
    sub a, h
    ld (temp_map_6), a
    ld a, $01
    ld (temp_map_8), a
    ld (temp_map_9), a
    ld (temp_map_10), a
    ld (temp_map_11), a
    ld a, (temp_map_5)
    cp a, $80
    jr c, +
    xor a, $ff
    inc a
    ld (temp_map_5), a
    ld a, $ff
    ld (temp_map_8), a
    ld (temp_map_10), a
+   ld a, (temp_map_6)
    cp a, $80
    jr c, +
    xor a, $ff
    inc a
    ld (temp_map_6), a
    ld a, $ff
    ld (temp_map_9), a
    ld (temp_map_11), a
+   push hl
    ld a, (temp_map_6)
    ld l, a
    ld a, (temp_map_5)
    cp a, l
    jr nc, +
    ld a, (temp_map_5)
    ld l, a
    ld a, (temp_map_6)
    ld (temp_map_5), a
    ld a, l
    ld (temp_map_6), a
    xor a, a
    ld (temp_map_10), a
    jp _L016
+   xor a, a
    ld (temp_map_11), a
_L016:
    pop hl
    ld a, (temp_map_6)
    ld (temp_map_7), a
    ld a, (temp_map_5)
    srl a
    or a, a
    jr nz, +
    inc a
+   ld (temp_map_6), a
_L017:
    ld a, e
    call tilemap_set
    ld a, e
    ld e, d
    ld d, a
    ld a, c
    cp a, l
    jr nz, +
    ld a, b
    cp a, h
    jr z, ++
+   push hl
    ld a, (temp_map_7)
    ld l, a
    ld a, (temp_map_6)
    add a, l
    ld (temp_map_6), a
    ld l, a
    ld a, (temp_map_5)
    cp a, l
    pop hl
    jr nc, +
    ld a, (temp_map_8)
    add a, l
    ld l, a
    ld a, (temp_map_9)
    add a, h
    ld h, a
    push hl
    ld a, (temp_map_5)
    ld l, a
    ld a, (temp_map_6)
    sub a, l
    ld (temp_map_6), a
    pop hl
    jp _L017
+   ld a, (temp_map_10)
    add a, l
    ld l, a
    ld a, (temp_map_11)
    add a, h
    ld h, a
    jp _L017
++  pop hl
    jp load_tilemap_tiles
tilemap_set:
    push hl
    push af
    xor a, a
    srl h
    rr a
    and a, a
    srl h
    rr a
    or a, l
    ld l, a
    ld a, >tilemap_buffer
    or a, h
    ld h, a
    pop af
    ld (hl), a
    pop hl
    ret
tilemap_justify_rectangle:
    ld a, (temp_map_x)
    ld l, a
    ld a, (temp_map_y)
    ld h, a
    ld a, l
    cp a, c
    jr c, +
    ld a, l
    ld l, c
    ld c, a
+   ld a, h
    cp a, b
    ret c
    ld a, h
    ld h, b
    ld b, a
    ret
tilemap_stream_load_pair:
    ldi a, (hl)
    ld d, a
    ld e, a
    and a, $c0
    ret z
    ld a, e
    and a, $3f
    ld e, a
    ld d, (hl)
    inc hl
    ret
tilemap_stream_load_block:
    ldi a, (hl)
    ld c, (hl)
    inc hl
    ld b, a
    and a, $f0
    srl a
    srl a
    srl a
    ld e, a
    ld a, b
    and a, $0f
    ld b, a
    ret
tilemap_unpack_12_6_6:
    ld a, c
    rl c
    rl b
    rl c
    rl b
    and a, $3f
    ld c, a
    ld a, b
    and a, $3f
    ld b, a
    ret
get_map_tile:
    xor a, a
    srl b
    rr a
    srl b
    rr a
    or a, c
    ld c, a
    ld a, b
    add a, >tilemap_buffer
    ld b, a
    ld a, (bc)
    ret
load_tilemap_triggers:
    ld a, (tileset_trigger_count)
    or a, a
    ret z
    add a, $03
    ld b, a
    ld hl, tilemap_buffer
    ld de, trigger_original_tile_buffer
-   ld a, (hl)
    ld c, a
    and a, $1f
    cp a, $03
    jr c, +
    cp a, b
    jr nc, +
    ld a, c
    ld (de), a
    and a, $20
    or a, $40
    or a, e
    ld (hl), a
    inc e
+   inc hl
    ld a, h
    cp a, >tilemap_buffer+$10
    jr nz, -
    ret
circle_data:
    .addr circle_data_1
    .addr circle_data_2
    .addr circle_data_3
    .addr circle_data_4
    .addr circle_data_5
    .addr circle_data_6
    .addr circle_data_7
circle_data_1:
    .db $01
    .db $00
    .db $ff
circle_data_2:
    .db $02
    .db $00
    .db $02
    .db $01
    .db $01
    .db $02
    .db $ff
circle_data_3:
    .db $03
    .db $00
    .db $03
    .db $01
    .db $02
    .db $02
    .db $01
    .db $03
    .db $ff
circle_data_4:
    .db $04
    .db $00
    .db $04
    .db $01
    .db $04
    .db $02
    .db $03
    .db $03
    .db $02
    .db $04
    .db $01
    .db $04
    .db $ff
circle_data_5:
    .db $05
    .db $00
    .db $05
    .db $01
    .db $05
    .db $02
    .db $04
    .db $03
    .db $03
    .db $04
    .db $02
    .db $05
    .db $01
    .db $05
    .db $ff
circle_data_6:
    .db $06
    .db $00
    .db $06
    .db $01
    .db $06
    .db $02
    .db $05
    .db $03
    .db $05
    .db $04
    .db $04
    .db $05
    .db $03
    .db $05
    .db $02
    .db $06
    .db $01
    .db $06
    .db $ff
circle_data_7:
    .db $07
    .db $00
    .db $07
    .db $01
    .db $07
    .db $02
    .db $06
    .db $03
    .db $06
    .db $04
    .db $05
    .db $05
    .db $04
    .db $06
    .db $03
    .db $06
    .db $02
    .db $07
    .db $01
    .db $07
    .db $ff
process_map_mode_dpad_input:
    ld a, (player.move_info)
    or a, a
    jr z, +
    ld a, (player.facing)
    jp stage_player_oam
+   call get_joypad_direction
    or a, a
    jr nz, +
    ld a, (player.facing)
    jp stage_player_oam
+   dec a
    push af
    ld c, a
    ld a, (player.facing)
    cp a, c
    jr z, +
    ld a, c
    ld (player.facing), a
+   xor a, a
    ld (conveyer_speed), a
    ld a, c
    call stage_player_oam
    pop af
    push af
    add a, a
    ld e, a
    ld d, $00
    ld hl, vector_direction
    add hl, de
    call get_player_position_plus_offset
    ld a, c
    or a, b
    and a, $c0
    jr z, +
    pop af
    ret
+   push bc
    call get_map_tile
    pop de
    bit 7, a
    jr z, +
    pop af
    call get_npc
    ret c
    ld a, l
    and a, $f0
    or a, npc.1.bump-npc.1
    ld l, a
    ld a, (hl)
    or a, a
    ret z
    ld a, l
    sub a, npc.1.bump-npc.1.command
    ld l, a
    ldi a, (hl)
    ld h, (hl)
    ld l, a
    call set_command_safe
    ret
+   call get_trigger_map_tile
    and a, $1f
    add a, <tile_info_buffer
    ld c, a
    ld b, >tile_info_buffer
    ld a, (bc)
    pop de
    bit 7, a
    jr z, +
    jr ++
+   ld c, a
    ld a, (script_vars+$0f)
    and a, $0f
    jr nz, +
    ld a, c
    and a, $03
    cp a, $03
    ret z
    ld a, (player.z)
    and a, c
    jr z, ++
    ret
+   bit 3, c
    ret nz
++  ld a, (current_command)
    inc a
    ld c, a
    ld a, (current_command+1)
    inc a
    or a, c
    jr z, +
    ld a, (current_command+1)
    cp a, $f0
    ret nz
    ld a, (current_command)
    cp a, $04
    ret nc
    xor a, d
    and a, $03
    jr nz, ++
    ld a, (player.current_speed)
    sla a
    ld (player.current_speed), a
    ret
++  dec a
    jr nz, +
    ld a, (player.speed)
    ld e, a
    ld a, (player.current_speed)
    sub a, e
    jr c, ++
    jr nz, _L018
    ld hl, $ffff
    call set_command
    ld a, (player.speed)
    ld (player.current_speed), a
    ret
_L018:
    ld a, (player.current_speed)
    srl a
    or a, a
    ret z
    ld (player.current_speed), a
    ret
++  ld a, e
    srl a
    or a, a
    jr nz, ++
    inc a
++  ld (player.current_speed), a
-   ld l, d
    ld h, $f0
    call set_command
    ret
+   ld a, (player.speed)
    ld (player.current_speed), a
    jr -
process_map_tile_events:
    ld a, (tile_visited_flag)
    or a, a
    ret nz
    inc a
    ld (tile_visited_flag), a
    ld hl, vector_zero
    call get_player_position_plus_offset
    call get_map_tile
    bit 6, a
    jp nz, process_trigger
    call get_trigger_map_tile
    ld e, a
    push de
    and a, $20
    ld e, a
    ld a, (inside_flag)
    cp a, e
    jr z, +
    ld a, e
    ld (inside_flag), a
    call hide_npcs
    pop de
    push de
    ld a, e
    and a, $1f
    add a, <tile_info_buffer
    ld c, a
    ld b, >tile_info_buffer
    ld a, (bc)
    ld d, a
    and a, $c0
    cp a, $c0
    jr z, ++
    ld a, d
    and a, $30
    ld (player.transparency), a
    ld a, (player.facing)
    call stage_player_oam
++  call update_fx
    rst $10
    call apply_scrolling_and_fx_and_oam_dma
    ld a, (script_vars+$0f)
    ld (temp_fx_2), a
    and a, $0f
    ld (script_vars+$0f), a
    call set_lcd_stat_interrupt_standard
    call screen_in_out_transition
    call refresh_npc_tile_info
    ld a, (temp_fx_2)
    ld (script_vars+$0f), a
    call update_fx
    rst $10
    call apply_scrolling_and_fx_and_oam_dma
+   pop de
    ld a, e
    and a, $1f
    add a, <tile_info_buffer
    ld c, a
    ld b, >tile_info_buffer
    ld a, (bc)
    bit 7, a
    jr z, +
    bit 6, a
    jp nz, _L021
    ld e, a
    srl a
    srl a
    and a, $03
    inc a
    ld d, a
    ld a, $80
-   rlc a
    dec d
    jr nz, -
    ld (player.current_speed), a
    ld (conveyer_speed), a
    ld a, e
    and a, $03
    ld l, a
    ld h, $f0
    call set_command_safe
    jr _L019
+   bit 6, a
    call nz, process_tile_damage
    ld e, a
    bit 2, a
    jp nz, _L020
    ld a, e
    and a, $03
    jr z, +
    xor a, $03
+   ld (player.z), a
_L019:
    ld a, (player.transparency)
    ld d, a
    ld a, e
    and a, $30
    ld (player.transparency), a
    ld a, (encounter_flag)
    or a, a
    ret z
    ld a, (encounter_rate)
    ld c, a
    ld de, $ff00
    ld a, $09
    call x_random_integer
    cp a, c
    ret nc
    ld de, $0002
    call execute_script_without_fx
    ret
restore_map:
    ld a, (battle_door)
    ld c, a
    ld a, (battle_door+$01)
    or a, c
    jr z, +
    ld hl, battle_door
    call load_door_from_address
    call load_map_header
    xor a, a
    ld (battle_door), a
    ld (battle_door+$01), a
    call clear_staged_npc_oam
    ld a, (tileset)
    call load_tile_info
    call load_tilemap
    call load_player_gfx
    call load_npcs
    call load_vehicles
    call refresh_player
    ld a, (battle_door_saved_z)
    ld (player.z), a
    ld a, (battle_door_saved_transparency_arg)
    ld (transparency_arg), a
    ld a, (battle_door_saved_transparency)
    ld (player.transparency), a
    call load_player_oam_metadata
    call restore_map_sprite_gfx
    jr ++
+   call load_player_oam_metadata
    call restore_map_sprite_gfx
    call load_tilemap
++  xor a, a
    ldh (<BGP), a
    ldh (<OBP0), a
    ldh (<OBP1), a
    ld a, (tileset)
    call load_tile_gfx
    call draw_tilemap
    call refresh_npc_tile_info
    call process_npcs
    ld a, (player.facing)
    call stage_player_oam
    ld hl, vector_zero
    call get_player_position_plus_offset
    call get_map_tile
    ld a, (bc)
    set 7, a
    ld (bc), a
    ld a, :data_standard_npc_gfx
    rst $28
    ld hl, data_standard_npc_gfx
    ld de, $8700
    ld bc, $0100
    call vram_memcopy_16
    call screen_reverse_wipe_fade
    ret
_L020:
    ld a, (player.z)
    and a, $01
    jp z, _L019
    ld e, $30
    jp _L019
get_trigger_map_tile:
    and a, $7f
    cp a, $40
    ret c
    and a, $1f
    ld c, a
    ld b, >trigger_original_tile_buffer
    ld a, (bc)
    ret
process_tile_damage:
    push af
    ld hl, player.1.current_hp
    ld b, $05
-   ld e, (hl)
    inc l
    ld d, (hl)
    dec de
    ld a, e
    or a, d
    jr nz, +
    ld de, $0001
+   ld (hl), d
    dec l
    ld (hl), e
    ld a, l
    add a, player.2-player.1
    ld l, a
    dec b
    jr nz, -
    ld a, $2d
    ldh (<OBP0), a
    ld a, $36
    ldh (<hram.audio.sfx), a
    ld c, $03
-   call update_fx
    rst $10
    call apply_scrolling_and_fx_and_oam_dma
    dec c
    jr nz, -
    ld a, $d2
    ldh (<OBP0), a
    pop af
    ret
_L021:
    bit 5, a
    ret nz
process_trigger:
    and a, $1f
    add a, a
    ld l, a
    ld h, $00
    ld a, :data_map_headers
    rst $28
    ld a, (map_trigger_data)
    ld e, a
    ld a, (map_trigger_data+1)
    ld d, a
    add hl, de
    ldi a, (hl)
    ld h, (hl)
    ld l, a
    call set_command_safe
    ret
get_joypad_direction:
    ldh a, (<hram.joyp_raw)
    ld b, $04
-   rlca
    jr c, +
    dec b
    jr nz, -
    ld b, $05
+   ld a, $05
    sub a, b
    ret
get_player_position_plus_offset:
    ld a, (player.x)
    swap a
    and a, $0f
    add a, (hl)
    ld c, a
    inc hl
    ld a, (player.y)
    swap a
    and a, $0f
    add a, (hl)
    ld hl, camera.y
    add a, (hl)
    ld b, a
    dec hl
    ld a, c
    add a, (hl)
    ld c, a
    ret
set_command_safe:
    ld a, (current_command+1)
    inc a
    ret nz
    ld a, (current_command)
    inc a
    ret nz
set_command:
    ld a, l
    ld (current_command), a
    ld a, h
    ld (current_command+1), a
    ret
stage_player_oam:
    and a, $03
    swap a
    add a, a
    ld e, a
    ld c, a
    ld a, (player.oam_template)
    add a, e
    ld e, a
    ld a, (player.oam_template+1)
    ld d, a
    ld a, (conveyer_speed)
    or a, a
    jr z, +
    ld a, (player.animation_type)
    cp a, $01
    jr z, +
    cp a, $03
    jr nc, +
    ld e, $00
    srl a
    rr e
    ld d, a
    push hl
    ld hl, data_oam_templates+$180
    add hl, de
    ld a, l
    add a, c
    ld e, a
    ld d, h
    pop hl
+   ld a, (player.y)
    add a, $10
    ld b, a
    ld a, (player.x)
    ld c, a
    ld hl, oam_staging_c0
    ld a, (player.transparency)
    ld (transparency_arg), a
    ld a, (hide_player_flag)
    or a, a
    jr nz, +
    call stage_oam_template
    ld a, (player.sprite)
    swap a
    ld c, a
    ld hl, oam_staging_c0+$02
    ld b, $04
-   ld a, (hl)
    add a, c
    ld (hl), a
    set 0, h
    ld a, (hl)
    add a, c
    ld (hl), a
    res 0, h
    ld a, l
    add a, $04
    ld l, a
    dec b
    jr nz, -
    ret
+   ld hl, oam_staging_c0
    ld b, $10
    xor a, a
-   ld (hl), a
    set 0, h
    ldi (hl), a
    res 0, h
    dec b
    jr nz, -
    ret
stage_oam_template:
    push hl
-   xor a, a
    ld (hl), a
    set 0, h
    ldi (hl), a
    res 0, h
    ld a, l
    and a, $0f
    jr nz, -
    pop hl
    ld a, :data_oam_templates
    rst $28
    push hl
-   ld a, (de)
    inc e
    add a, b
    ld (hl), a
    set 0, h
    ld a, (de)
    inc e
    add a, b
    ldi (hl), a
    ld a, (de)
    inc e
    add a, c
    ld (hl), a
    res 0, h
    ld a, (de)
    inc e
    add a, c
    ldi (hl), a
    ld a, (de)
    inc e
    ld (hl), a
    set 0, h
    ld a, (de)
    inc e
    ldi (hl), a
    ld a, (de)
    inc e
    ld (hl), a
    res 0, h
    ld a, (de)
    inc e
    ldi (hl), a
    ld a, c
    add a, $08
    ld c, a
    bit 2, l
    jr nz, -
    ld a, c
    sub a, $10
    ld c, a
    ld a, b
    add a, $08
    ld b, a
    bit 3, l
    jr nz, -
    pop hl
    ld a, (transparency_arg)
    and a, $20
    jr z, +
    push hl
    inc l
    inc l
    inc l
    set 7, (hl)
    set 0, h
    set 7, (hl)
    inc l
    inc l
    inc l
    inc l
    set 7, (hl)
    res 0, h
    set 7, (hl)
    pop hl
+   ld a, (transparency_arg)
    and a, $10
    ret z
    ld a, l
    add a, $0b
    ld l, a
    set 7, (hl)
    set 0, h
    set 7, (hl)
    inc l
    inc l
    inc l
    inc l
    set 7, (hl)
    res 0, h
    set 7, (hl)
    ret
load_random_encounter:
    call choose_random_encounter
    call load_encounter
    ret
choose_random_encounter:
    ld a, (encounter_set)
    ld l, a
    ld h, $00
    add hl, hl
    add hl, hl
    add hl, hl
    ld de, data_encounter_sets
    add hl, de
    push hl
    ld a, :data_encounter_sets
    rst $28
    ld hl, data_encounter_probability
    ld a, $0a
    ld de, $ff00
    call x_random_integer
    ld b, $07
    ld c, $00
-   cp a, (hl)
    jr nc, +
    inc hl
    inc c
    dec b
    jr nz, -
+   ld b, $00
    pop hl
    add hl, bc
    ld c, (hl)
    ret
load_encounter:
    ld a, c
    push bc
    and a, $7f
    ld l, a
    ld h, $00
    add a, <data_encounters
    ld c, a
    ld a, >data_encounters
    adc a, $00
    ld b, a
    add hl, hl
    add hl, hl
    add hl, bc
    ld de, encounter_monster_data+$01
    ld b, $03
-   ld a, :data_encounters
    call read_from_bank
    ld (de), a
    inc de
    inc de
    inc hl
    dec b
    jr nz, -
    pop bc
    bit 7, c
    jr z, +
    inc hl
+   ld a, :data_encounters
    call read_from_bank
    push af
    and a, $c0
    rlca
    rlca
    add a, $00
    ld (battle_music), a
    pop af
    ld (battle.encounter_info), a
    ld (encounter_info), a
    and a, $1f
    ld c, a
    add a, a
    add a, c
    add a, <data_encounter_numbers
    ld l, a
    ld a, >data_encounter_numbers
    adc a, $00
    ld h, a
    ld de, encounter_monster_data
    ld b, $03
-   ld a, :data_encounter_numbers
    call read_from_bank
    push de
    ld e, a
    and a, $0f
    ld d, a
    ld a, e
    swap a
    and a, $0f
    ld e, a
    ld a, $0b
    call x_random_integer
    pop de
    inc hl
    ld (de), a
    inc de
    inc de
    dec b
    jr nz, -
    ld a, $28
    ldh (<hram.audio.sfx), a
    call screen_wipe_diamond
    ret
screen_wipe_scroll:
    call clear_staged_oam
    call screen_wipe_helper_initialize
    ld a, $00
    ld (temp_map_7), a
    ld a, $00
    ld (temp_map_10), a
    ld a, $02
    ld (temp_map_9), a
    rst $10
    call apply_scrolling_and_fx_and_oam_dma
    ld bc, lcd_stat_interrupt_screen_wipe_scroll
    call push_lcd_stat_lyc_interrupt
    ld d, $24
--  ldh a, (<LY)
    cp a, $90
    jr nc, --
-   ldh a, (<LY)
    cp a, $90
    jr c, -
    push de
    call x_game_update
    pop de
    xor a, a
    ld (temp_map_10), a
    ei
    ld a, (temp_map_7)
    add a, $01
    ld (temp_map_7), a
    cp a, d
    jr nz, --
    ld a, d
    srl a
    add a, d
    ld d, a
    ld a, (temp_map_9)
    sla a
    ld (temp_map_9), a
    cp a, $10
    jr nz, --
    xor a, a
    ldh (<BGP), a
    ldh (<OBP0), a
    ldh (<OBP1), a
    call screen_wipe_helper_restore
    ld a, (temp_fx_2)
    ld (script_vars+$0f), a
    ret
screen_wipe_helper_initialize:
    ld a, (script_vars+$0f)
    ld (temp_fx_2), a
    and a, $0f
    ld (script_vars+$0f), a
    call set_lcd_stat_interrupt_standard
    call x_vram_enable
    ld hl, $9c00
-   ld (hl), $ff
    inc hl
    ld a, h
    cp a, $a0
    jr nz, -
    call x_vram_disable
    ld a, $e3
    ldh (<LCDC), a
    xor a, a
    ldh (<WY), a
    ld a, $a7
    ldh (<WX), a
    ldh a, (<hram.scroll_base.y)
    ldh (<SCY), a
    ld (temp_map_11), a
    ldh a, (<hram.scroll_base.x)
    ldh (<SCX), a
    ld (temp_map_8), a
    ret
lcd_stat_interrupt_screen_wipe_scroll:
    push af
    push hl
    ldh a, (<LY)
    cp a, $48
    jr nc, +
    ld l, a
    ld a, (temp_map_7)
    cp a, l
    jr nc, _L022
    ld hl, temp_map_10
    ldh a, (<LY)
    cp a, (hl)
    ld a, (temp_map_11)
    jr c, ++
    add a, (hl)
    ld l, a
    ldh a, (<LY)
    sub a, l
    cpl
    inc a
++  ldh (<SCY), a
    ld a, (temp_map_9)
    ld hl, temp_map_10
    add a, (hl)
    ld (hl), a
    ld a, $a7
    ldh (<WX), a
    jr _L023
_L022:
    ld a, $07
    ldh (<WX), a
_L023:
    ld hl, LYC
    inc (hl)
    pop hl
    pop af
    reti
+   ld l, a
    ld a, $90
    sub a, l
    ld l, a
    ld a, (temp_map_7)
    cp a, l
    jr nc, _L022
    ld a, (temp_map_10)
    cp a, l
    ld a, (temp_map_11)
    jr nc, +
    add a, $90
    ld hl, temp_map_10
    sub a, (hl)
    ld hl, LY
    sub a, (hl)
+   ldh (<SCY), a
    ld a, (temp_map_10)
    ld hl, temp_map_9
    sub a, (hl)
    jr c, +
    ld (temp_map_10), a
+   ld a, $a7
    ldh (<WX), a
    jr _L023
lcd_stat_interrupt_wave_fx:
    push af
    push hl
    ldh a, (<LY)
    cp a, $90
    jr nc, +
    and a, $1f
    ld l, a
    ld a, (wave_fx_counter)
    cp a, l
    jr z, ++
    add a, $0a
    and a, $1f
    cp a, l
    jr nz, +
    ld hl, SCY
    inc (hl)
    jr +
++  ld hl, SCY
    dec (hl)
+   ld hl, LYC
    inc (hl)
    pop hl
    pop af
    reti
screen_wipe_diamond:
    call clear_staged_oam
    call screen_split
    ld a, $b0
    ld (temp_map_7), a
    rst $10
    call apply_scrolling_and_fx_and_oam_dma
    ld bc, lcd_stat_interrupt_screen_wipe_diamond
    call push_lcd_stat_lyc_interrupt
--  ldh a, (<LY)
    cp a, $90
    jr nc, --
-   ldh a, (<LY)
    cp a, $90
    jr c, -
    call x_game_update
    ei
    ld a, (temp_map_7)
    add a, $08
    ld (temp_map_7), a
    cp a, $50
    jr nz, --
    xor a, a
    ldh (<BGP), a
    ldh (<OBP0), a
    ldh (<OBP1), a
    call screen_wipe_helper_restore
    ld a, (temp_fx_2)
    ld (script_vars+$0f), a
    ret
screen_wipe_corners:
    call clear_staged_oam
    call screen_split
    ld a, $48
    ld (temp_map_7), a
    rst $10
    call apply_scrolling_and_fx_and_oam_dma
    ld bc, lcd_stat_interrupt_screen_wipe_corners
    call push_lcd_stat_lyc_interrupt
--  ldh a, (<LY)
    cp a, $90
    jr nc, --
-   ldh a, (<LY)
    cp a, $90
    jr c, -
    call x_game_update
    ei
    ld a, (temp_map_7)
    dec a
    ld (temp_map_7), a
    cp a, $ff
    jr nz, --
    xor a, a
    ldh (<OBP0), a
    ldh (<OBP1), a
    ldh (<BGP), a
    call screen_wipe_helper_restore
    ld a, (temp_fx_2)
    ld (script_vars+$0f), a
    ret
screen_reverse_wipe_corners:
    xor a, a
    ld (hram.fade_in_type), a
    call screen_split
    xor a, a
    ld (temp_map_7), a
    rst $10
    call apply_scrolling_and_fx_and_oam_dma
    ld bc, lcd_stat_interrupt_screen_wipe_corners
    call push_lcd_stat_lyc_interrupt
--  ldh a, (<LY)
    cp a, $90
    jr nc, --
-   ldh a, (<LY)
    cp a, $90
    jr c, -
    ld a, $d2
    ldh (<BGP), a
    call x_game_update
    ei
    ld a, (temp_map_7)
    inc a
    ld (temp_map_7), a
    cp a, $48
    jr nz, --
    di
    xor a, a
    ldh (<LYC), a
    call pop_lcd_stat_lyc_interrupt
    call screen_unsplit
    call screen_wipe_helper_restore_2
    ld a, (temp_fx_2)
    ld (script_vars+$0f), a
    ld a, $d2
    ldh (<OBP0), a
    ldh (<OBP1), a
    ret
screen_unsplit:
    ld a, (vram_addr_of_upper_left_visible_16x16_tile+1)
    ld h, a
    ld d, $9c
    ld a, (vram_addr_of_upper_left_visible_16x16_tile)
    push af
    add a, $0b
    and a, $1f
    ld l, a
    pop af
    and a, $e0
    or a, l
    ld l, a
    ld e, $00
    ld c, $12
--  ld b, $0b
    push hl
-   ldh a, (<LY)
    cp a, $90
    jr c, -
    cp a, $97
    jr nc, -
    ld a, (de)
    ld (hl), a
    ld a, l
    push af
    inc a
    and a, $1f
    ld l, a
    pop af
    and a, $e0
    or a, l
    ld l, a
    inc e
    dec b
    jr nz, -
    pop hl
    ld a, l
    add a, $20
    ld l, a
    ld a, h
    adc a, $00
    and a, $9b
    ld h, a
    ld a, e
    add a, $15
    ld e, a
    ld a, d
    adc a, $00
    ld d, a
    dec c
    jr nz, --
    ret
screen_split:
    ldh a, (<hram.scroll_base.y)
    ldh (<SCY), a
    ldh a, (<hram.scroll_base.x)
    ldh (<SCX), a
    ld a, (script_vars+$0f)
    ld (temp_fx_2), a
    and a, $0f
    ld (script_vars+$0f), a
    call set_lcd_stat_interrupt_standard
    call x_vram_enable
    ld hl, $9c00
-   ld (hl), $ff
    inc hl
    ld a, h
    cp a, $a0
    jr nz, -
    call x_vram_disable
    ld a, (vram_addr_of_upper_left_visible_16x16_tile+1)
    ld h, a
    ld d, $9c
    ld a, (vram_addr_of_upper_left_visible_16x16_tile)
    push af
    add a, $0b
    and a, $1f
    ld l, a
    pop af
    and a, $e0
    or a, l
    ld l, a
    ld e, $00
    ld c, $12
--  ld b, $0b
    push hl
-   ldh a, (<LY)
    cp a, $90
    jr c, -
    cp a, $97
    jr nc, -
    ld a, (hl)
    ld (de), a
    ld a, l
    push af
    inc a
    and a, $1f
    ld l, a
    pop af
    and a, $e0
    or a, l
    ld l, a
    inc e
    dec b
    jr nz, -
    ld hl, $0015
    add hl, de
    ld e, l
    ld d, h
    pop hl
    ld a, l
    add a, $20
    ld l, a
    ld a, h
    adc a, $00
    and a, $9b
    ld h, a
    dec c
    jr nz, --
    ld a, $e3
    ldh (<LCDC), a
    xor a, a
    ldh (<WY), a
    ld a, $57
    ldh (<WX), a
    ld h, $98
    ld a, (vram_addr_of_upper_left_visible_16x16_tile)
    add a, $0b
    and a, $1f
    ld l, a
    ld c, $20
--  ld b, $15
    push hl
-   ldh a, (<LY)
    cp a, $90
    jr c, -
    cp a, $97
    jr nc, -
    ld (hl), $ff
    ld a, l
    push af
    inc a
    and a, $1f
    ld l, a
    pop af
    and a, $e0
    or a, l
    ld l, a
    dec b
    jr nz, -
    pop hl
    ld a, l
    add a, $20
    ld l, a
    ld a, h
    adc a, $00
    ld h, a
    dec c
    jr nz, --
    ldh a, (<hram.scroll_base.x)
    ldh (<SCX), a
    ld (temp_map_8), a
    ldh a, (<hram.scroll_base.y)
    ldh (<SCY), a
    ld (temp_map_11), a
    ret
push_lcd_stat_lyc_interrupt:
    di
    ld hl, ram_program_lcd_stat_interrupt
    ld de, temp_map_x
    ld a, (hl)
    ld (de), a
    ld a, $c3
    ld (hl), a
    inc l
    inc e
    ld a, (hl)
    ld (de), a
    ld (hl), c
    inc l
    inc e
    ld a, (hl)
    ld (de), a
    ld (hl), b
    inc e
    ldh a, (<STAT)
    ld (de), a
    ld a, $c0
    ldh (<STAT), a
    ei
    ret
set_lcd_stat_interrupt_wave_fx:
    di
    ld a, $c3
    ld (ram_program_lcd_stat_interrupt), a
    ld a, <lcd_stat_interrupt_wave_fx
    ld (ram_program_lcd_stat_interrupt.payload), a
    ld a, >lcd_stat_interrupt_wave_fx
    ld (ram_program_lcd_stat_interrupt.payload+$01), a
    ei
    ret
set_lcd_stat_interrupt_standard:
    di
    ld a, $c3
    ld (ram_program_lcd_stat_interrupt), a
    ld a, (addr_lcd_stat_interrupt_standard)
    ld (ram_program_lcd_stat_interrupt.payload), a
    ld a, (addr_lcd_stat_interrupt_standard+$01)
    ld (ram_program_lcd_stat_interrupt.payload+$01), a
    xor a, a
    ldh (<LYC), a
    ei
    ret
screen_wipe_helper_restore:
    call pop_lcd_stat_lyc_interrupt
    call screen_wipe_helper_restore_2
    ret
pop_lcd_stat_lyc_interrupt:
    di
    xor a, a
    ldh (<LYC), a
    ld hl, temp_map_x
    ld de, ram_program_lcd_stat_interrupt
    ldi a, (hl)
    ld (de), a
    inc e
    ldi a, (hl)
    ld (de), a
    inc e
    ldi a, (hl)
    ld (de), a
    ld a, (hl)
    ldh (<STAT), a
    ei
    ret
screen_wipe_helper_restore_2:
    ld a, (temp_map_8)
    ldh (<SCX), a
    ld a, (temp_map_11)
    ldh (<SCY), a
    ld a, $c3
    ldh (<LCDC), a
    ld a, $91
    ldh (<WY), a
    ret
lcd_stat_interrupt_screen_wipe_diamond:
    push af
    push hl
    ldh a, (<LY)
    cp a, $48
    jr c, +
    ld l, a
    ld a, $90
    sub a, l
+   ld l, a
    ld a, (temp_map_7)
    add a, l
    cp a, $51
    jr nc, +
    ld l, a
    ld a, (temp_map_8)
    add a, l
    ldh (<SCX), a
    ld a, $57
    add a, l
    cp a, $a6
    jr nz, ++
    inc a
++  ldh (<WX), a
+   ld hl, LYC
    inc (hl)
    pop hl
    pop af
    reti
lcd_stat_interrupt_screen_wipe_corners:
    push af
    push hl
    ldh a, (<LY)
    cp a, $48
    jr c, +
    ld l, a
    ld a, $90
    sub a, l
+   ld l, a
    ld a, (temp_map_7)
    cp a, l
    jr c, +
    ld l, a
    ld a, $48
    sub a, l
    ld l, a
    ld a, (temp_map_8)
    add a, l
    ldh (<SCX), a
    ld a, $57
    add a, l
    cp a, $a6
    jr nz, ++
    inc a
++  ldh (<WX), a
    jr ++
+   ld a, (temp_map_8)
    add a, $50
    ldh (<SCX), a
    ld a, $a7
    ldh (<WX), a
++  ld hl, LYC
    inc (hl)
    pop hl
    pop af
    reti
update_fx:
    push af
    push hl
    ld a, (script_vars+$0f)
    and a, $f0
    cp a, $20
    jr nz, +
    ld a, (ram_program_lcd_stat_interrupt.payload)
    cp a, $95
    jr z, ++
    xor a, a
    ld (wave_fx_counter), a
    call set_lcd_stat_interrupt_wave_fx
++  call x_game_update
-   pop hl
    pop af
    ret
+   ld a, (ram_program_lcd_stat_interrupt.payload)
    ld l, a
    ld a, (addr_lcd_stat_interrupt_standard)
    cp a, l
    jr z, -
    xor a, a
    ld (wave_fx_counter), a
    call set_lcd_stat_interrupt_standard
    jr -
restore_map_sprite_gfx:
    ld a, (npc_flag)
    or a, a
    jp z, _L024
    call load_npc_gfx
_L024:
    call load_player_gfx
    ret
process_queued_player_move:
    ld a, (player.move_info)
    ld c, a
    and a, $07
    ret z
    bit 3, c
    jr nz, +
    add a, a
    add a, <vector_zero
    ld l, a
    ld h, >vector_zero
    ld c, (hl)
    inc l
    ld b, (hl)
    ld a, (player.current_speed)
-   rra
    jr c, ++
    sla b
    sla c
    jr -
++  ld a, (player.x)
    add a, c
    ld (player.x), a
    ld c, a
    inc l
    ld a, (player.y)
    add a, b
    ld (player.y), a
    or a, c
    and a, $0f
    ret nz
    ld a, (player.move_info)
    and a, $07
    dec a
    xor a, $01
    add a, a
    add a, <vector_direction
    ld l, a
    ld h, >vector_direction
    call get_player_position_plus_offset
    call get_map_tile
    res 7, a
    ld (bc), a
    ld hl, vector_zero
    call get_player_position_plus_offset
    call get_map_tile
    set 7, a
    ld (bc), a
-   xor a, a
    ld (tile_visited_flag), a
    ld a, (player.move_info)
    sub a, $10
    ld (player.move_info), a
    swap a
    and a, $0f
    ret nz
    ld (player.move_info), a
    ret
+   ld a, c
    and a, $07
    dec a
    ld (current_command), a
    ld a, $f0
    ld (current_command+1), a
    jr -
process_map_mode_button_input:
    call x_process_button_press_events
    bit 2, a
    jp nz, _on_button_select
    bit 3, a
    jp nz, _on_button_start
    bit 1, a
    jp nz, _L030
    and a, $01
    ret z
    ld e, $1f
    call x_get_script_var
    or a, a
    jp nz, _L028
    ld a, (player.facing)
    add a, a
    ld e, a
    ld d, $00
    ld hl, vector_direction
    add hl, de
    call get_player_position_plus_offset
    ld a, c
    or a, b
    and a, $c0
    ret nz
    push bc
    call get_map_tile
    pop de
    bit 7, a
    jp z, _L027
    call get_npc
    ret c
    ld a, l
    and a, $f0
    add a, npc.1.z-npc.1
    ld l, a
    ld a, (hl)
    and a, $03
    jr z, +
    ld a, (player.z)
    and a, $03
    jr z, +
    and a, (hl)
    ret z
+   ld a, l
    and a, $f0
    add a, npc.1.command-npc.1
    ld l, a
    ld c, (hl)
    inc l
    ld a, (hl)
    ld b, a
    cp a, $09
    jr z, +
    cp a, $0a
    jr z, +
    cp a, $0a
    jr z, +
    cp a, $04
    jr z, ++
    cp a, $f0
    jr nz, _L025
    ld a, c
    and a, $f8
    cp a, $08
    jr nz, _L025
    ld a, (player.facing)
    ld (current_command), a
    ld a, $f8
    ld (current_command+1), a
    ld a, l
    and a, $f0
    add a, npc.1.command-npc.1
    ld l, a
    ldi a, (hl)
    ld (second_command), a
    ld a, (hl)
    ld (second_command+1), a
    ld a, l
    and a, $f0
    ld (vehicle_npc_index_backup), a
    ret
_L025:
    ld a, c
    ld (current_command), a
    ld a, b
    ld (current_command+1), a
    ld a, l
    and a, $f0
    ld l, a
    ld a, l
    and a, $f0
    add a, npc.1.move-npc.1
    ld l, a
    ld a, (hl)
    and a, $0f
    cp a, $03
    ret z
    ld a, (player.facing)
    xor a, $01
    swap a
    ld c, a
    rlca
    rlca
    or a, c
    ld c, a
    ld a, (hl)
    and a, $0f
    or a, c
    ld (hl), a
    ret
++  ld a, c
    ld (current_command), a
    ld a, b
    ld (current_command+1), a
    ret
+   ld a, l
    and a, $f0
    or a, npc.1.move-npc.1
    ld l, a
    ld a, (hl)
    and a, $0f
    or a, $10
    ld (hl), a
    ld a, l
    and a, $f0
    ld l, a
    push bc
    push hl
    call refresh_npc_staged_oam
    pop hl
    pop bc
    ld a, l
    and a, $f0
    or a, npc.1.type-npc.1
    ld l, a
    ld a, (hl)
    call x_test_chest_flag
    jr nz, +
    ld a, b
    cp a, $0a
    jr z, ++
    ld a, c
    inc a
    jr z, _L026
    push hl
    call cmd_09_item
    pop hl
    or a, a
    ret nz
_npc_set_chest_flag:
    ld a, (hl)
    call x_set_chest_flag
    ret
++  push hl
    call cmd_0a_magi
    pop hl
    jr _npc_set_chest_flag
_L026:
    call _npc_set_chest_flag
+   ld de, $0103
    call execute_script_without_fx
    ret
_L027:
    bit 6, a
    ret nz
    call get_trigger_map_tile
    and a, $1f
    add a, <tile_info_buffer
    ld c, a
    ld b, >tile_info_buffer
    ld a, (bc)
    cp a, $e0
    ret c
    call process_trigger
    ret
_L028:
    ld hl, vector_zero
    call get_player_position_plus_offset
    call get_map_tile
    bit 6, a
    ret nz
    call get_trigger_map_tile
    and a, $1f
    add a, <tile_info_buffer
    ld c, a
    ld b, >tile_info_buffer
    ld a, (bc)
    cp a, $c0
    ret nc
    ld hl, $f005
    call set_command_safe
    ret
get_npc:
    ld hl, npc.1.x
-   ld c, (hl)
    bit 7, c
    jr nz, +
    ld a, c
    and a, $3f
    ld c, a
    inc l
    ldi a, (hl)
    or a, a
    jr z, ++
    dec c
    cp a, $80
    jr nc, ++
    inc c
    inc c
++  ld a, c
    and a, $3f
    cp a, e
    jr nz, +
    ld b, (hl)
    inc l
    ldi a, (hl)
    or a, a
    jr z, ++
    dec b
    cp a, $80
    jr nc, ++
    inc b
    inc b
++  ld a, b
    cp a, d
    jr z, ++
+   ld a, l
    and a, $f0
    add a, npc.2-npc.1
    ld l, a
    or a, a
    jr nz, -
    ld a, l
    scf
    ret
++  ld a, l
    and a, $f0
    ld l, a
    scf
    ccf
    ret
_on_button_select:
    ld a, (script_vars+$0f)
    ld (menu_fx_backup), a
    and a, $0f
    ld (script_vars+$0f), a
    call set_lcd_stat_interrupt_standard
    call x_fc_menu_party_order
    call load_player_oam_metadata
    ld a, (npc_flag)
    or a, a
    jr z, _L029
    jr +
_on_button_start:
    call set_lcd_stat_interrupt_standard
    ld a, (script_vars+$0f)
    ld (menu_fx_backup), a
    and a, $0f
    ld (script_vars+$0f), a
    call x_fc_menu_start
    ld a, (npc_flag)
    or a, a
    jp z, _L029
+   call load_npc_gfx
_L029:
    call load_player_gfx
    ld a, $d2
    ldh (<BGP), a
    ldh (<OBP0), a
    ldh (<OBP1), a
    ld a, (script_vars+$0f)
    and a, $f0
    cp a, $30
    jr z, +
    or a, a
    ret nz
    ld a, (script_vars+$0f)
    and a, $0f
    ld b, a
    ld a, (menu_fx_backup)
    and a, $f0
    or a, b
    ld (script_vars+$0f), a
    ret
+   ld a, (script_vars+$0f)
    and a, $0f
    ld (script_vars+$0f), a
    ret
_L030:
    ld de, $0058
    call execute_script_without_fx
    ret
use_item_helper:
    ld hl, jt_cscript_entry+$0a
    ld a, :jt_cscript_entry
    call read_from_bank
    ld e, a
    inc hl
    ld a, :jt_cscript_entry
    call read_from_bank
    ld d, a
    call x_far_call
    .addr xc_execute_cscript
    .db :xc_execute_cscript
    ret
process_npc_wandering:
    ld a, $01
    ld de, $0300
    call x_random_integer
    or a, a
    ret nz
    xor a, a
    ld de, $0f00
    call x_random_integer
    ld b, a
    swap a
    ld l, a
    ld h, >npc.1
    ldi a, (hl)
    bit 7, a
    ret nz
    bit 6, a
    ret nz
    ld c, a
    ld a, b
    add a, $20
    ld de, $0300
    call x_random_integer
    and a, $03
    ld (temp_map_12), a
    add a, a
    add a, <vector_direction
    ld e, a
    ld d, >vector_direction
    ld a, (de)
    inc e
    add a, c
    ld c, a
    ldi a, (hl)
    or a, a
    ret nz
    ld a, (de)
    add a, (hl)
    ld b, a
    or a, c
    and a, $c0
    ret nz
    inc l
    ldi a, (hl)
    or a, a
    ret nz
    ld a, (hl)
    or a, a
    ret nz
    call get_map_tile
    bit 7, a
    ret nz
    call get_trigger_map_tile
    ld c, a
    and a, $1f
    add a, <tile_info_buffer
    ld e, a
    ld d, >tile_info_buffer
    ld a, (de)
    bit 7, a
    ret nz
    ld c, a
    ld a, l
    and a, $f0
    add a, npc.1.z-npc.1
    ld l, a
    ld a, (hl)
    and a, c
    ret nz
    bit 2, c
    jr nz, +
    ld a, c
    and a, $03
    jr z, ++
    cp a, $03
    ret z
    xor a, $03
++  ld (hl), a
+   ld a, l
    and a, $f0
    add a, npc.1.move_count-npc.1
    ld l, a
    ld (hl), $01
    inc l
    ld a, (hl)
    and a, $0f
    ld c, a
    ld a, (temp_map_12)
    ld b, a
    rlca
    rlca
    or a, b
    swap a
    or a, c
    ld (hl), a
    ret
refresh_npc_tile_info:
    ld hl, npc.1
-   ldi a, (hl)
    bit 7, a
    jr nz, +
    and a, $3f
    ld c, a
    ld d, (hl)
    inc l
    ld b, (hl)
    inc l
    ldi a, (hl)
    or a, d
    ld d, a
    inc l
    inc l
    call get_map_tile
    ld e, a
    ld a, d
    or a, a
    jr nz, ++
    set 7, e
    ld a, e
    ld (bc), a
++  ld a, e
    call get_trigger_map_tile
    ld c, a
    and a, $1f
    add a, <tile_info_buffer
    ld e, a
    ld d, >tile_info_buffer
    ld a, (de)
    ld b, a
    ld a, c
    and a, $20
    ld c, a
    ld a, (inside_flag)
    xor a, c
    jr nz, ++
    ld a, b
    cp a, $c0
    jr nc, +
    and a, $30
    ld (hl), a
    jr _L031
++  ld (hl), $30
_L031:
    ld a, l
    and a, $f0
    add a, npc.1.z-npc.1
    ld l, a
    ld a, b
    cp a, $80
    jr nc, +
    bit 2, b
    jr nz, +
    and a, $03
    jr z, ++
    xor a, $03
++  ld (hl), a
+   ld a, l
    and a, $f0
    add a, npc.2-npc.1
    ld l, a
    or a, a
    jr nz, -
    ret
refresh_npcs:
    ld a, (hram.bank)
    ld (temp_refresh_npcs), a
    ld hl, tilemap_buffer
-   ld a, (hl)
    and a, $7f
    ldi (hl), a
    ld a, h
    cp a, >tilemap_buffer+$10
    jr nz, -
    ld a, (map_npc_gfx)
    ld l, a
    ld a, (map_npc_gfx+1)
    ld h, a
    ld d, $81
-   ld a, :data_map_headers
    rst $28
    ld a, d
    cp a, $87
    jr z, +
    ldi a, (hl)
    cp a, $ff
    jr z, +
    inc d
    jr -
+   call load_npcs_no_gfx
    call refresh_npc_tile_info
    call process_npcs
    call update_fx
    rst $10
    call apply_scrolling_and_fx_and_oam_dma
    ld hl, vector_zero
    call get_player_position_plus_offset
    call get_map_tile
    ld a, (bc)
    set 7, a
    ld (bc), a
    ld a, (temp_refresh_npcs)
    rst $28
    ret
load_npcs:
    ld de, npc.1
    ld a, (npc_flag)
    or a, a
    jp z, _L034
    call load_npc_gfx
load_npcs_no_gfx:
    ld de, npc.1.x
_L032:
    ldi a, (hl)
    cp a, $ff
    jp z, _L034
    cp a, $80
    jr nz, +
    ldi a, (hl)
    ld c, a
    call x_test_chest_flag
    jp nz, _L033
    ld a, e
    and a, $f0
    or a, npc.1.type-npc.1
    ld e, a
    ld a, c
    ld (de), a
    jr ++
+   push de
    and a, $1f
    ld e, a
    call x_get_script_var
    pop de
    inc a
    ld c, a
    ldi a, (hl)
    ld b, a
    swap a
    and a, $0f
    cp a, c
    jr nc, _L033
    ld a, b
    and a, $0f
    dec c
    cp a, c
    jr c, _L033
++  push hl
    push hl
    dec hl
    dec hl
    ld a, (hl)
    and a, $40
    ld c, a
    ld a, e
    and a, $f0
    or a, npc.1.bump-npc.1
    ld e, a
    ld a, c
    ld (de), a
    pop hl
    ldi a, (hl)
    ld c, a
    ldi a, (hl)
    ld b, a
    ldi a, (hl)
    ld h, (hl)
    ld l, a
    ld a, e
    and a, $f0
    or a, npc.1.command-npc.1
    ld e, a
    ld a, l
    ld (de), a
    inc e
    ld a, h
    and a, $0f
    ld (de), a
    inc e
    xor a, a
    ld (de), a
    ld a, e
    and a, $f0
    ld e, a
    ld a, c
    and a, $3f
    ld l, a
    ld a, h
    and a, $80
    rrca
    or a, l
    ld (de), a
    inc e
    xor a, a
    ld (de), a
    inc e
    ld a, b
    and a, $3f
    ld (de), a
    inc e
    xor a, a
    ld (de), a
    inc e
    ld (de), a
    inc e
    ld a, b
    and a, $c0
    rlca
    rlca
    ld l, a
    ld a, c
    and a, $c0
    ld c, a
    rrca
    rrca
    or a, c
    or a, l
    ld (de), a
    inc e
    xor a, a
    ld (de), a
    inc e
    ld (de), a
    inc e
    ld a, h
    and a, $70
    ld (de), a
    ld a, e
    and a, $f0
    add a, npc.2-npc.1
    ld e, a
    pop hl
    or a, a
    ret z
_L033:
    inc hl
    inc hl
    inc hl
    inc hl
    jp _L032
_L034:
    ld l, e
    ld h, d
-   ld a, h
    cp a, >npc.1+$01
    ret z
    ld (hl), $80
    ld de, npc.2-npc.1
    add hl, de
    jr -
process_npcs:
    ld a, $f0
    ld (npc_processing_counter), a
    ld a, $10
    ld (temp_map_13), a
    ld a, (camera.y)
    ld d, a
    ld a, (camera.x)
    ld e, a
    ld hl, npc.1
@npc_stage_oam_and_move:
    push de
    ldi a, (hl)
    bit 7, a
    jp nz, @next_npc
    and a, $3f
    sub a, e
    cp a, $0b
    jr nc, @npc_process_dx
    swap a
    add a, (hl)
    ld c, a
    inc l
    ldi a, (hl)
    sub a, d
    cp a, $09
    jr nc, @npc_process_dx
    swap a
    add a, $10
    add a, (hl)
    ld b, a
    inc l
    inc l
    ld a, (hl)
    and a, $07
    ld e, <data_oam_templates
    srl a
    rr e
    add a, >data_oam_templates
    ld d, a
    ldi a, (hl)
    and a, $30
    add a, a
    add a, e
    ld e, a
    ldi a, (hl)
    ld (transparency_arg), a
    ld a, (temp_map_13)
    ldi (hl), a
    cp a, $a0
    jr z, @npc_process_dx
    push hl
    ld l, a
    ld h, >oam_staging_c0
    push hl
    call stage_oam_template
    ld a, (temp_map_13)
    add a, $10
    ld (temp_map_13), a
    pop de
    pop hl
    ld c, (hl)
    inc e
    inc e
    ld b, $04
-   ld a, (de)
    add a, c
    ld (de), a
    set 0, d
    ld a, (de)
    add a, c
    ld (de), a
    res 0, d
    ld a, e
    add a, $04
    ld e, a
    dec b
    jr nz, -
@npc_process_dx:
    ld a, l
    and a, $f0
    inc a
    ld l, a
    ld a, (hl)
    or a, a
    jr z, @npc_process_dy
    and a, $0f
    jr z, @npc_finish_step
@npc_pixel_move:
    bit 7, (hl)
    jr nz, +
    inc (hl)
    jp @next_npc_no_inc
+   dec (hl)
    jp @next_npc_no_inc
@npc_process_move_count:
    inc l
    ldi a, (hl)
    or a, a
    jp z, @npc_no_move
    ldd a, (hl)
    rlca
    rlca
    and a, $03
    add a, a
    add a, <vector_direction
    ld e, a
    ld d, >vector_direction
    dec l
    dec l
    dec l
    ld a, (de)
    ldi (hl), a
    inc e
    inc l
    ld a, (de)
    ldi (hl), a
    jr @npc_start_step
@npc_process_dy:
    inc l
    inc l
    ld a, (hl)
    or a, a
    jr z, @npc_process_move_count
    and a, $0f
    jr nz, @npc_pixel_move
@npc_finish_step:
    ld a, (hl)
    ld e, l
    ld d, h
    sra a
    sra a
    sra a
    sra a
    ldd (hl), a
    add a, (hl)
    and a, $3f
    ld c, a
    ld a, (hl)
    and a, $c0
    or a, c
    ld (hl), a
    ld a, l
    and a, $f0
    or a, npc.1.move_count-npc.1
    ld l, a
    ld a, (hl)
    or a, a
    jr nz, @npc_start_step
    xor a, a
    ld (de), a
@npc_no_move:
    ld a, l
    and a, $f0
    ld l, a
    ld a, (hl)
    and a, $3f
    ld c, a
    inc l
    inc l
    ld b, (hl)
    call get_map_tile
    set 7, a
    ld (bc), a
    jr @next_npc
@npc_start_step:
    dec (hl)
    ld a, l
    and a, $f0
    ld l, a
    ld a, (hl)
    and a, $3f
    ld c, a
    inc l
    inc l
    ld b, (hl)
    call get_map_tile
    res 7, a
    ld (bc), a
    inc l
    ldd a, (hl)
    add a, (hl)
    and a, $3f
    ld b, a
    dec l
    ldd a, (hl)
    add a, (hl)
    and a, $3f
    ld c, a
    call get_map_tile
    set 7, a
    ld (bc), a
    call get_trigger_map_tile
    ld e, a
    and a, $1f
    add a, <tile_info_buffer
    ld c, a
    ld b, >tile_info_buffer
    ld a, l
    and a, $f0
    add a, npc.1.z-npc.1
    ld l, a
    ld a, (bc)
    ld b, a
    bit 7, a
    jr nz, +
    bit 2, b
    jr nz, +
    ld a, b
    and a, $03
    jr z, ++
    xor a, $03
++  ld (hl), a
+   ld c, (hl)
    ld a, l
    and a, $f0
    add a, npc.1.transparency-npc.1
    ld l, a
    ld a, e
    and a, $20
    ld e, a
    ld a, (inside_flag)
    xor a, e
    jr nz, @next_npc_no_inc_transparent
    ld a, b
    cp a, $c0
    jr nc, +
    bit 2, b
    jr z, ++
    ld a, c
    and a, $01
    jr z, ++
    ld b, $30
++  ld a, b
    and a, $30
    ld (hl), a
    jr @next_npc_no_inc
+   ld (hl), $00
    jr @next_npc_no_inc
@next_npc:
    ld a, (npc_processing_counter)
    inc a
    ld (npc_processing_counter), a
    jr @next_npc_no_inc
@next_npc_no_inc_transparent:
    ld (hl), $30
@next_npc_no_inc:
    pop de
    ld a, l
    and a, $f0
    add a, npc.2-npc.1
    ld l, a
    or a, a
    jp nz, @npc_stage_oam_and_move
    ld a, (temp_map_13)
    ld l, a
    ld e, a
    ld h, >oam_staging_c0
-   ld a, l
    cp a, $a0
    jr nc, +
    ld (hl), $00
    set 0, h
    ld (hl), $00
    res 0, h
    ld a, l
    add a, $04
    ld l, a
    jr -
+   ld a, (player.move_dir)
    or a, a
    ret z
    ld hl, oam_staging_c0+$10
    dec a
    jr z, @player_down
    dec a
    jr z, @player_up
    dec a
    jr z, @player_left
    ldh a, (<hram.scroll_base.x)
    add a, $08
    cpl
    inc a
    and a, $0f
    jr +
@player_left:
    ldh a, (<hram.scroll_base.x)
    add a, $08
    cpl
    inc a
    and a, $0f
    or a, $f0
    jr +
@player_up:
    ldh a, (<hram.scroll_base.y)
    cpl
    inc a
    and a, $0f
    or a, $f0
    jr ++
@player_down:
    ldh a, (<hram.scroll_base.y)
    cpl
    inc a
    and a, $0f
    jr ++
+   inc l
++  ld c, a
-   ld a, l
    cp a, e
    ret nc
    ld a, (hl)
    add a, c
    ld (hl), a
    set 0, h
    ld a, (hl)
    add a, c
    ld (hl), a
    res 0, h
    ld a, l
    add a, $04
    ld l, a
    jr -
hide_npcs:
    ld hl, oam_staging_c0+$10
-   ld a, l
    cp a, $a0
    ret nc
    ld (hl), $00
    set 0, h
    ld (hl), $00
    res 0, h
    ld a, l
    add a, $04
    ld l, a
    jr -
load_npc_gfx:
    ld a, (map_npc_gfx)
    ld l, a
    ld a, (map_npc_gfx+1)
    ld h, a
    ld de, $8100
-   ld a, :data_map_headers
    rst $28
    ld a, d
    cp a, $87
    jr z, +
    ldi a, (hl)
    cp a, $ff
    jr z, +
    push hl
    push de
    ld l, <data_npc_gfx
    add a, >data_npc_gfx
    bit 7, a
    jr z, ++
    and a, $7f
    or a, >data_npc_gfx_2
    ld h, a
    ld a, :data_npc_gfx_2
    rst $28
    jr _L035
++  ld h, a
    ld a, :data_npc_gfx
    rst $28
_L035:
    ld bc, $0100
    call vram_memcopy_16
    pop de
    pop hl
    inc d
    jr -
+   ret
refresh_npc_staged_oam:
    ld a, (camera.y)
    ld d, a
    ld a, (camera.x)
    ld e, a
    ldi a, (hl)
    and a, $3f
    sub a, e
    swap a
    ld c, a
    inc l
    ldi a, (hl)
    sub a, d
    swap a
    add a, $10
    ld b, a
    inc l
    inc l
    ld a, (hl)
    and a, $07
    ld e, <data_oam_templates
    srl a
    rr e
    add a, >data_oam_templates
    ld d, a
    ldi a, (hl)
    and a, $30
    add a, a
    add a, e
    ld e, a
    ldi a, (hl)
    ld (transparency_arg), a
    ldi a, (hl)
    cp a, $a0
    ret z
    push hl
    ld l, a
    ld h, >oam_staging_c0
    push hl
    call stage_oam_template
    pop de
    pop hl
    ld c, (hl)
    inc e
    inc e
    ld b, $04
-   ld a, (de)
    add a, c
    ld (de), a
    set 0, d
    ld a, (de)
    add a, c
    ld (de), a
    res 0, d
    ld a, e
    add a, $04
    ld e, a
    dec b
    jr nz, -
    call update_fx
    rst $10
    call apply_scrolling_and_fx_and_oam_dma
    ret
screen_in_out_transition:
    ld a, (vram_addr_of_upper_left_visible_16x16_tile)
    ld l, a
    ld a, (vram_addr_of_upper_left_visible_16x16_tile+1)
    inc a
    and a, $fb
    ld h, a
    ld a, l
    push af
    add a, $0a
    and a, $1f
    ld l, a
    pop af
    and a, $e0
    or a, l
    ld l, a
    ld d, $00
    ld b, $08
    ld c, $0a
    call screen_in_out_transition_helper_1
    ld a, $01
_L036:
    push af
    ld e, a
-   ld a, d
    xor a, $01
    ld d, a
    ld a, l
    push af
    inc a
    and a, $1f
    ld l, a
    pop af
    and a, $e0
    or a, l
    ld l, a
    inc c
    call screen_in_out_transition_helper_1
    dec e
    jr nz, -
    pop af
    push af
    ld e, a
-   ld a, d
    xor a, $02
    ld d, a
    ld a, l
    add a, $20
    ld l, a
    ld a, h
    adc a, $00
    and a, $fb
    ld h, a
    inc b
    call screen_in_out_transition_helper_1
    dec e
    jr nz, -
    pop af
    inc a
    cp a, $17
    jp z, _L037
    push af
    ld e, a
-   ld a, d
    xor a, $01
    ld d, a
    ld a, l
    push af
    dec a
    and a, $1f
    ld l, a
    pop af
    and a, $e0
    or a, l
    ld l, a
    dec c
    call screen_in_out_transition_helper_1
    dec e
    jr nz, -
    pop af
    push af
    ld e, a
-   ld a, d
    xor a, $02
    ld d, a
    ld a, l
    sub a, $20
    ld l, a
    ld a, h
    sbc a, $00
    and a, $fb
    or a, $08
    ld h, a
    dec b
    call screen_in_out_transition_helper_1
    dec e
    jr nz, -
    pop af
    inc a
    cp a, $17
    jr z, _L037
    jp _L036
_L037:
    ld a, (vram_addr_of_upper_left_visible_16x16_tile)
    push af
    dec a
    and a, $1f
    ld l, a
    pop af
    and a, $e0
    or a, l
    sub a, $40
    ld l, a
    ld a, (vram_addr_of_upper_left_visible_16x16_tile+1)
    sbc a, $00
    and a, $fb
    or a, $08
    ld h, a
    ld d, $01
    ld b, $fe
    ld c, $ff
    ld a, $16
_L038:
    push af
    ld e, a
-   ld a, d
    xor a, $01
    ld d, a
    ld a, l
    push af
    inc a
    and a, $1f
    ld l, a
    pop af
    and a, $e0
    or a, l
    ld l, a
    inc c
    call screen_in_out_transition_helper_2
    dec e
    jr nz, -
    pop af
    dec a
    ret z
    push af
    ld e, a
-   ld a, d
    xor a, $02
    ld d, a
    ld a, l
    add a, $20
    ld l, a
    ld a, h
    adc a, $00
    and a, $fb
    ld h, a
    inc b
    call screen_in_out_transition_helper_2
    dec e
    jr nz, -
    pop af
    push af
    ld e, a
-   ld a, d
    xor a, $01
    ld d, a
    ld a, l
    push af
    dec a
    and a, $1f
    ld l, a
    pop af
    and a, $e0
    or a, l
    ld l, a
    dec c
    call screen_in_out_transition_helper_2
    dec e
    jr nz, -
    pop af
    dec a
    ret z
    push af
    ld e, a
-   ld a, d
    xor a, $02
    ld d, a
    ld a, l
    sub a, $20
    ld l, a
    ld a, h
    sbc a, $00
    and a, $fb
    or a, $08
    ld h, a
    dec b
    call screen_in_out_transition_helper_2
    dec e
    jr nz, -
    pop af
    jp _L038
screen_in_out_transition_helper_2:
    push bc
    push de
    ld a, (camera.x)
    sra c
    add a, c
    ld c, a
    ld a, (camera.y)
    sra b
    add a, b
    ld b, a
    or a, c
    and a, $c0
    jr z, +
    xor a, a
    jr ++
+   call get_map_tile
++  and a, $7f
    cp a, $40
    jr c, +
    and a, $1f
    ld e, a
    ld d, >trigger_original_tile_buffer
    ld a, (de)
+   ld e, a
    ld a, (inside_flag)
    xor a, e
    cp a, $20
    jp c, _L039
    ld a, (inside_flag)
    swap a
    dec a
    cp a, $01
    jr z, +
    ld a, $02
+   add a, a
    add a, a
    pop de
    pop bc
    add a, d
    push af
-   ldh a, (<LY)
    cp a, $90
    jr c, -
    cp a, $98
    jr nc, -
    pop af
    ld (hl), a
    ret
screen_in_out_transition_helper_1:
    push bc
    push de
    ld a, (camera.x)
    sra c
    add a, c
    ld c, a
    ld a, (camera.y)
    sra b
    add a, b
    ld b, a
    or a, c
    and a, $c0
    jr z, +
    xor a, a
    jr ++
+   call get_map_tile
++  and a, $7f
    cp a, $40
    jr c, +
    and a, $1f
    ld e, a
    ld d, >trigger_original_tile_buffer
    ld a, (de)
+   ld e, a
    ld a, (inside_flag)
    xor a, e
    cp a, $20
    jr nc, _L039
    add a, a
    add a, a
    pop de
    pop bc
    add a, d
    push af
-   ldh a, (<LY)
    cp a, $90
    jr c, -
    cp a, $98
    jr nc, -
    pop af
    ld (hl), a
    ret
_L039:
    pop de
    pop bc
    ret
execute_script_command:
    ld a, (npc_command_stack_top)
    ld e, a
    ld d, >npc_command_stack
    ld a, (hram.bank)
    ld (de), a
    inc e
    ld a, e
    ld (npc_command_stack_top), a
-   ld a, (npc_command_stack_top)
    ld e, a
    ld d, >npc_command_stack
    dec e
    ld a, (de)
    rst $28
    ldi a, (hl)
    ld (current_command+1), a
    ld b, a
    cp a, $ff
    jr z, +
    ldi a, (hl)
    ld (current_command), a
    ld c, a
    ld a, b
    cp a, $f5
    jr z, ++
    cp a, $f6
    jr nz, _L040
++  ldi a, (hl)
    ld (second_command), a
_L040:
    push bc
    push hl
    call execute_command
    pop hl
    pop bc
    ld a, b
    cp a, $f0
    jr c, ++
    cp a, $f7
    jr nc, ++
    cp a, $f0
    jr nz, -
    ld a, c
    cp a, $04
    jr nc, ++
    jr -
+   push hl
-   ld a, (player.move_dir)
    or a, a
    jr nz, +
    call process_queued_player_move
    ld a, (player.facing)
    call stage_player_oam
+   call process_npcs
    call process_command
    ld a, (player.move_info)
    ld c, a
    and a, $07
    jr nz, -
    ld a, (player.move_dir)
    or a, a
    jr nz, -
    ldh a, (<hram.scroll_base.y)
    ldh (<SCY), a
    ldh a, (<hram.scroll_base.x)
    ldh (<SCX), a
    ld a, (npc_processing_counter)
    or a, a
    jr nz, -
    call process_npcs
    pop hl
++  ld a, (npc_command_stack_top)
    dec a
    ld (npc_command_stack_top), a
    ld e, a
    ld d, >npc_command_stack
    ld a, (de)
    rst $28
    ret
process_command:
    ld a, (player.move_dir)
    or a, a
    jp nz, _L042
    ld a, (current_command+1)
    ld b, a
    ld a, (current_command)
    ld c, a
    inc a
    jr nz, execute_command
    ld a, b
    inc a
    jp z, cmd_done
execute_command:
    ld a, b
    cp a, $04
    jr z, cmd_04_shop
    cp a, $05
    jp z, cmd_05_06_0e_door
    cp a, $06
    jp z, cmd_05_06_0e_door
    cp a, $07
    jp z, cmd_07_audio
    cp a, $08
    jp z, cmd_done
    cp a, $09
    jp z, cmd_09_item
    cp a, $0a
    jp z, cmd_0a_magi
    cp a, $0b
    jp z, cmd_0b_item_force
    cp a, $0c
    jr z, cmd_0c_0d_battle_door
    cp a, $0d
    jr z, cmd_0c_0d_battle_door
    cp a, $0e
    jp z, cmd_05_06_0e_door
    ld a, b
    and a, $f0
    cp a, $f0
    jp nz, cmd_00_01_02_03_script
    bit 3, b
    jp nz, cmd_f8
    ld a, b
    and a, $0f
    jp z, cmd_f0_misc
    dec a
    jp z, cmd_f1_player_move
    dec a
    jp z, cmd_f2_player_slide
    dec a
    jp z, cmd_f3_player_move_no_camera
    dec a
    jp z, cmd_f4_player_slide_no_camera
    dec a
    jr z, cmd_f5_npc_slide
    dec a
    jr z, cmd_f6_npc_move
    dec a
    jr z, cmd_f7_player_transparency
    jp cmd_done
cmd_f7_player_transparency:
    ld a, c
    and a, $30
    ld (player.transparency), a
    ld a, (player.facing)
    call stage_player_oam
    call update_fx
    rst $10
    call apply_scrolling_and_fx_and_oam_dma
    jp cmd_done
cmd_05_06_0e_door:
    call execute_door_command
    jp cmd_done
cmd_04_shop:
    ld e, c
    ld d, b
    call x_execute_shop_command
    jp cmd_done
cmd_0c_0d_battle_door:
    call battle_door_save
    call execute_battle_door_command
    jp cmd_done
cmd_f6_npc_move:
    ld a, (second_command)
    swap a
    and a, $f0
    add a, <npc.1.move
    ld l, a
    ld h, >npc.1.move
    ld a, (hl)
    ld b, a
    and a, $0f
    cp a, $03
    jr z, cmd_f5_npc_slide
    ld a, b
    and a, $cf
    ld b, a
    ld a, c
    and a, $03
    swap a
    or a, b
    ld (hl), a
cmd_f5_npc_slide:
    ld a, c
    and a, $f0
    swap a
    ld b, a
    ld a, (second_command)
    swap a
    and a, $f0
    add a, <npc.1.move_count
    ld l, a
    ld h, >npc.1.move_count
    ld (hl), b
    inc l
    ld a, (hl)
    and a, $3f
    ld b, a
    ld a, c
    and a, $03
    rrca
    rrca
    or a, b
    ld (hl), a
    jp cmd_done
cmd_f1_player_move:
    ld a, (player.move_info)
    or a, a
    jp nz, _L043
    ld e, $08
    ld a, c
    and a, $03
    ld (player.facing), a
    jp _L041
cmd_f2_player_slide:
    ld a, (player.move_info)
    or a, a
    jp nz, _L043
    ld e, $08
    jp _L041
cmd_f3_player_move_no_camera:
    ld a, (player.move_info)
    or a, a
    jp nz, _L043
    ld a, c
    and a, $03
    ld (player.facing), a
    jr +
cmd_f4_player_slide_no_camera:
    ld a, (player.move_info)
    or a, a
    jp nz, _L043
+   ld e, $00
_L041:
    ld a, (player.facing)
    push de
    push bc
    call stage_player_oam
    call update_fx
    rst $10
    call apply_scrolling_and_fx_and_oam_dma
    pop bc
    pop de
    ld a, c
    and a, $03
    inc a
    ld b, a
    ld a, c
    and a, $f0
    jp z, cmd_done
    or a, b
    or a, e
    ld (player.move_info), a
    jp _clear_command
cmd_00_01_02_03_script:
    ld a, b
    cp a, $04
    jp nc, cmd_done
    ld d, b
    ld e, c
    ld a, (script_vars+$0f)
    ld (temp_fx_4), a
    and a, $0f
    ld (script_vars+$0f), a
    call set_lcd_stat_interrupt_standard
    rst $20
    ld a, (script_vars+$0f)
    and a, $f0
    cp a, $30
    jr z, +
    or a, a
    jp nz, cmd_done
    ld a, (script_vars+$0f)
    and a, $0f
    ld b, a
    ld a, (temp_fx_4)
    and a, $f0
    or a, b
    ld (script_vars+$0f), a
    jp cmd_done
+   ld a, (script_vars+$0f)
    and a, $0f
    ld (script_vars+$0f), a
    jp cmd_done
cmd_f0_misc:
    ld a, c
    cp a, $04
    jp c, cmd_f0_player_step
    cp a, $04
    jp z, cmd_f004
    cp a, $05
    jp z, cmd_f005_vehicle_stop
    cp a, $06
    jp z, cmd_done
    cp a, $07
    jp z, cmd_done
    cp a, $0c
    jp z, cmd_f00c_screen_shake
    cp a, $0d
    jp z, cmd_f00d_map_refresh
    cp a, $0e
    jp z, cmd_f00e_screen_wipe_fade
    cp a, $0f
    jp z, cmd_f00f_screen_reverse_wipe_fade
    cp a, $10
    jp z, cmd_f010_transition_corners
    cp a, $11
    jp z, cmd_f011_screen_reverse_wipe_corners
    cp a, $12
    jp z, cmd_f012_screen_flash
    cp a, $13
    jp z, cmd_f013_screen_wipe_diamond
    cp a, $14
    jp z, cmd_f014_screen_wipe_scroll
    cp a, $15
    jp z, cmd_f015_player_hide
    cp a, $16
    jp z, cmd_f016_player_show
    cp a, $17
    jp z, cmd_f017_magi_remove
    cp a, $18
    jp z, cmd_f018_magi_restore
    cp a, $0c
    jp c, cmd_f008_vehicle_start
    jp cmd_done
cmd_f015_player_hide:
    ld a, $01
    ld (hide_player_flag), a
    ld a, (player.facing)
    call stage_player_oam
    jp cmd_done
cmd_f016_player_show:
    xor a, a
    ld (hide_player_flag), a
    ld a, (player.facing)
    call stage_player_oam
    jp cmd_done
cmd_f00d_map_refresh:
    call load_tilemap
    call refresh_player_tilemap_data
    call draw_tilemap
    call refresh_npc_tile_info
    jp cmd_done
cmd_f0_player_step:
    push af
    xor a, a
    ld (tile_visited_flag), a
    ld hl, vector_zero
    call get_player_position_plus_offset
    call get_map_tile
    ld a, (bc)
    res 7, a
    ld (bc), a
    pop af
    and a, $03
    inc a
    ld (player.move_dir), a
    dec a
    call player_move
    ld hl, vector_zero
    call get_player_position_plus_offset
    call get_map_tile
    ld a, (bc)
    set 7, a
    ld (bc), a
    jp _clear_command
cmd_f8:
    ld a, b
    and a, $f7
    ld b, a
    call execute_command
    ld a, (second_command)
    ld (current_command), a
    ld a, (second_command+1)
    ld (current_command+1), a
    ret
cmd_f005_vehicle_stop:
    ld e, $1f
    call x_get_script_var
    or a, a
    jp z, cmd_done
    ld a, (player.facing)
    add a, a
    add a, <vector_direction
    ld l, a
    ld h, >vector_direction
    call get_player_position_plus_offset
    ld a, c
    or a, b
    and a, $c0
    jp nz, cmd_done
    call get_map_tile
    bit 7, a
    jp nz, cmd_done
    call get_trigger_map_tile
    and a, $1f
    add a, <tile_info_buffer
    ld c, a
    ld b, >tile_info_buffer
    ld a, (bc)
    bit 7, a
    jr z, +
    bit 6, a
    jr z, ++
    bit 5, a
    jp nz, cmd_done
    jr ++
+   ld c, a
    ld a, (player.z)
    and a, c
    jp nz, cmd_done
    ld a, c
    and a, $03
    cp a, $03
    jp z, cmd_done
++  ld e, $1f
    call x_get_script_var
    dec a
    and a, $0f
    add a, a
    add a, a
    add a, <vehicle_data
    ld l, a
    ld h, >vehicle_data
    ld a, (map_header)
    ldi (hl), a
    ld a, (player.speed)
    ld c, $00
-   rrca
    jr c, +
    inc c
    jr -
+   rrc c
    rrc c
    ld a, (map_header+1)
    or a, c
    ldi (hl), a
    ld a, (player.facing)
    rrca
    rrca
    ld b, a
    ld a, (player.x)
    swap a
    and a, $0f
    ld c, a
    ld a, (camera.x)
    add a, c
    or a, b
    ldi (hl), a
    ld a, (player.animation_type)
    rrca
    rrca
    ld b, a
    ld a, (player.y)
    swap a
    and a, $0f
    ld c, a
    ld a, (camera.y)
    add a, c
    or a, b
    ld (hl), a
    ld a, $01
    ld (player.current_speed), a
    ld (player.speed), a
    xor a, a
    ld (player.sprite), a
    ld e, $1f
    ld a, $00
    call x_set_script_var
    call load_player_oam_metadata
    ld a, (player.facing)
    call stage_player_oam
    ld a, (player.facing)
    ld c, a
    ld (current_command), a
    ld a, $f0
    ld b, a
    ld (current_command+1), a
    call execute_command
    call load_vehicles
    call refresh_npc_tile_info
    ret
cmd_f008_vehicle_start:
    ld a, (vehicle_npc_index_backup)
    or a, a
    jr z, +
    ld l, a
    ld h, >npc.1
    set 7, (hl)
+   xor a, a
    ld (vehicle_npc_index_backup), a
    ld a, $01
    ld (player.sprite), a
    ld a, c
    and a, $03
    push af
    inc a
    ld e, $1f
    call x_set_script_var
    pop bc
    ld a, $04
    sub a, b
    ld b, $80
-   rlc b
    dec a
    jr nz, -
    ld a, b
    ld (player.current_speed), a
    ld (player.speed), a
    ld a, $01
    ld (player.animation_type), a
    ld a, <data_oam_templates+$80
    ld (player.oam_template), a
    ld a, >data_oam_templates
    ld (player.oam_template+1), a
    jp cmd_done
_L042:
    call finish_map_mode_frame
    ld a, (current_command+1)
    cp a, $f0
    ret nz
    ld a, (current_command)
    cp a, $04
    ret nc
    jp _clear_command
cmd_done:
    call update_fx
    rst $10
    call apply_scrolling_and_fx_and_oam_dma
    call update_tile_animation
    jp _clear_command
_L043:
    call update_fx
    rst $10
    call apply_scrolling_and_fx_and_oam_dma
    ret
cmd_f004:
    jp _clear_command
_clear_command:
    ld a, $ff
    ld (current_command), a
    ld (current_command+1), a
    ret
screen_reverse_wipe_wavy:
    xor a, a
    ld (hram.fade_in_type), a
    ld a, <wavy_wipe_offsets
    ld (temp_map_7), a
    ldh a, (<hram.scroll_base.x)
    ldh (<SCX), a
    ld (temp_map_8), a
    rst $10
    call apply_scrolling_and_fx_and_oam_dma
    di
    ld hl, ram_program_lcd_stat_interrupt
    ld de, temp_map_x
    ld bc, lcd_stat_interrupt_screen_wipe_wavy
    ld a, (hl)
    ld (de), a
    ld a, $c3
    ld (hl), a
    inc l
    inc e
    ld a, (hl)
    ld (de), a
    ld (hl), c
    inc l
    inc e
    ld a, (hl)
    ld (de), a
    ld (hl), b
    inc e
    ldh a, (<STAT)
    ld (de), a
    ld a, $c0
    ldh (<STAT), a
    ei
    ld a, $3c
_L044:
    push af
    swap a
    and a, $0f
    ld l, a
    ld a, $03
    sub a, l
    ld (temp_map_6), a
    ld l, $40
    dec a
    jr nz, +
    ld l, $81
    jr ++
+   dec a
    jr nz, +
    ld l, $81
    jr ++
+   dec a
    jr nz, ++
    ld l, $d2
++  ld a, l
    ldh (<BGP), a
    ldh (<OBP0), a
    ldh (<OBP1), a
    ld a, <wavy_fade_in_offset_buffer
    ld (temp_map_5), a
    ld h, >wavy_wipe_offsets
    ld a, (temp_map_7)
    ld l, a
    ld de, wavy_fade_in_offset_buffer
    ld b, $90
--  ld c, (hl)
    ld a, (temp_map_6)
    or a, a
    jr z, +
-   sra c
    dec a
    jr nz, -
+   ld a, (temp_map_8)
    add a, c
    ld (de), a
    inc l
    ld a, (hl)
    cp a, $80
    jr nz, +
    ld l, <wavy_wipe_offsets
+   inc e
    dec b
    jr nz, --
    call x_game_update
    ei
-   ldh a, (<LY)
    cp a, $90
    jr nc, -
-   ldh a, (<LY)
    cp a, $90
    jr c, -
    ld a, (temp_map_7)
    ld l, a
    ld h, >wavy_wipe_offsets
    inc l
    ld a, (hl)
    cp a, $80
    jr nz, +
    ld l, <wavy_wipe_offsets
+   ld a, l
    ld (temp_map_7), a
    pop af
    dec a
    jr nz, _L044
    di
    ld hl, temp_map_x
    ld de, ram_program_lcd_stat_interrupt
    ldi a, (hl)
    ld (de), a
    inc e
    ldi a, (hl)
    ld (de), a
    inc e
    ldi a, (hl)
    ld (de), a
    ld a, (hl)
    ldh (<STAT), a
    ei
    ret
lcd_stat_interrupt_screen_wipe_wavy:
    push af
    push hl
    ldh a, (<LY)
    cp a, $90
    jr nc, +
    ld a, (temp_map_5)
    ld l, a
    ld h, >wavy_fade_in_offset_buffer
    ld a, (hl)
    ldh (<SCX), a
    inc l
    ld a, l
    ld (temp_map_5), a
+   ld hl, LYC
    inc (hl)
    pop hl
    pop af
    reti
cmd_f00c_screen_shake:
    ld a, $27
    ldh (<hram.audio.sfx), a
    ldh a, (<hram.scroll_base.x)
    ldh (<SCX), a
    ld (temp_map_x), a
    ldh a, (<hram.scroll_base.y)
    ldh (<SCY), a
    ld (temp_map_y), a
    ld hl, cmd_screen_shake_offsets
--  ld a, (hl)
    or a, a
    jp z, _L045
    push hl
    push af
    ld a, $0c
    ld de, $0100
    call x_random_integer
    ld e, a
    pop af
    dec e
    jr z, +
    cpl
    inc a
+   ld c, a
    ld a, (hl)
    push af
    ld a, $0d
    ld de, $0100
    call x_random_integer
    ld e, a
    pop af
    dec e
    jr z, +
    cpl
    inc a
+   ld b, a
    call screen_shake_helper_y
    call screen_shake_helper_x
    ld b, $03
-   call update_fx
    rst $10
    call apply_scrolling_and_fx_and_oam_dma
    dec b
    jr nz, -
    pop hl
    inc hl
    jr --
_L045:
    ld a, (temp_map_x)
    ldh (<SCX), a
    ld a, (temp_map_y)
    ldh (<SCY), a
    jp _clear_command
screen_shake_helper_y:
    ld a, (temp_map_y)
    add a, c
    ldh (<SCY), a
    ret
screen_shake_helper_x:
    ld a, (temp_map_x)
    add a, b
    ldh (<SCX), a
    ret
cmd_screen_shake_offsets:
    .db $02, $04
    .db $08, $0c
    .db $04, $0c
    .db $06, $04
    .db $00
cmd_07_audio:
    ld a, c
    bit 7, a
    jr nz, +
    bit 6, a
    jr nz, ++
    ldh (<hram.audio.bg_music), a
    ld (saved_bg_music), a
    jp cmd_done
++  sub a, $40
    ldh (<hram.audio.fg_music), a
    jp cmd_done
+   sub a, $80
    ldh (<hram.audio.sfx), a
    jp cmd_done
cmd_f013_screen_wipe_diamond:
    call screen_wipe_diamond
    jp cmd_done
cmd_f014_screen_wipe_scroll:
    call screen_wipe_scroll
    jp cmd_done
cmd_f010_transition_corners:
    ld a, $01
    ld (hram.fade_in_type), a
    call screen_wipe_corners
    jp cmd_done
cmd_f00e_screen_wipe_fade:
    call screen_wipe_fade
    jp cmd_done
screen_reverse_wipe:
    ld a, (hram.fade_in_type)
    cp a, $01
    jp z, screen_reverse_wipe_corners
    or a, a
    jp nz, screen_reverse_wipe_wavy
    jp screen_reverse_wipe_fade
screen_wipe_fade:
    ld d, $03
--  ldh a, (<BGP)
    ld c, a
    ld b, $00
    ld e, $04
-   ld a, c
    and a, $03
    cp a, d
    jr nz, +
    dec a
+   rra
    rr b
    rra
    rr b
    rrc c
    rrc c
    dec e
    jr nz, -
    call update_fx
    rst $10
    call apply_scrolling_and_fx_and_oam_dma
    ld a, b
    ldh (<BGP), a
    ldh (<OBP0), a
    ldh (<OBP1), a
    ld e, $06
-   call update_fx
    rst $10
    call apply_scrolling_and_fx_and_oam_dma
    dec e
    jr nz, -
    dec d
    jr nz, --
    ret
cmd_f011_screen_reverse_wipe_corners:
    call screen_reverse_wipe_corners
    jp cmd_done
cmd_f00f_screen_reverse_wipe_fade:
    call screen_reverse_wipe_fade
    jp cmd_done
screen_reverse_wipe_fade:
    ld d, $01
--  ld c, $d2
    ld b, $00
    ld e, $04
-   ld a, c
    and a, $03
    cp a, d
    jr c, +
    ld a, d
+   rra
    rr b
    rra
    rr b
    rrc c
    rrc c
    dec e
    jr nz, -
    call update_fx
    rst $10
    call apply_scrolling_and_fx_and_oam_dma
    ld a, b
    ldh (<BGP), a
    ldh (<OBP0), a
    ldh (<OBP1), a
    ld e, $06
-   call update_fx
    rst $10
    call apply_scrolling_and_fx_and_oam_dma
    dec e
    jr nz, -
    inc d
    ld a, d
    cp a, $04
    jr nz, --
    ret
cmd_09_item:
    call _get_empty_inventory_slot
    jr z, _L046
    ld de, $0104
    call execute_script_without_fx
    ld de, $0105
    call execute_script_without_fx
    call _clear_command
    ld a, $01
    ret
_L046:
    ld a, c
    inc a
    jr nz, +
    ld de, $0103
    call execute_script_without_fx
    call _clear_command
    ld a, $01
    ret
+   ld (hl), c
    ld a, c
    ld (script_arg_inventory), a
    inc hl
    push hl
    ld a, <data_item_usage
    add a, c
    ld l, a
    ld a, >data_item_usage
    adc a, $00
    ld h, a
    ld a, :data_item_usage
    call read_from_bank
    pop hl
    ld (hl), a
    ld de, $0107
    call execute_script_without_fx
    call _clear_command
    xor a, a
    ret
cmd_0b_item_force:
    call _get_empty_inventory_slot
    jr z, _L046
    ld de, $0104
    call execute_script_without_fx
-   ld de, $0106
    call execute_script_without_fx
    ld a, (hram.confirmed_cursor.1)
    inc a
    jr z, -
    add a, a
    add a, <(inventory-$02)
    ld l, a
    ld a, >(inventory-$02)
    adc a, $00
    ld h, a
    ld a, $ff
    ldi (hl), a
    ldd (hl), a
    jr _L046
cmd_0a_magi:
    ld a, <data_item_usage
    add a, c
    ld l, a
    ld h, >data_item_usage+$01
    ld a, :data_item_usage
    call read_from_bank
    ld b, a
    ld a, c
    add a, a
    add a, <magi_list
    ld l, a
    ld a, >magi_list
    adc a, $00
    ld h, a
    inc (hl)
    inc hl
    ld (hl), b
    ld hl, magi_total
    inc (hl)
    ld a, c
    ld (script_arg_inventory), a
    ld de, $0102
    call execute_script_without_fx
    jp _clear_command
_get_empty_inventory_slot:
    ld hl, inventory
    ld b, $10
-   ld a, (hl)
    inc a
    ret z
    inc hl
    inc hl
    dec b
    jr nz, -
    or a, a
    ret
cmd_f012_screen_flash:
    ld a, $18
    ldh (<hram.audio.sfx), a
    ld b, $03
--  ldh a, (<BGP)
    xor a, $ff
    ldh (<BGP), a
    ldh (<OBP0), a
    ldh (<OBP1), a
    ld c, $04
-   call update_fx
    rst $10
    call apply_scrolling_and_fx_and_oam_dma
    dec c
    jr nz, -
    ldh a, (<BGP)
    xor a, $ff
    ldh (<BGP), a
    ldh (<OBP0), a
    ldh (<OBP1), a
    ld c, $06
-   call update_fx
    rst $10
    call apply_scrolling_and_fx_and_oam_dma
    dec c
    jr nz, -
    dec b
    jr nz, --
    jp cmd_done
cmd_f017_magi_remove:
    ld hl, magi_list
    ld b, $1c
    xor a, a
-   ldi (hl), a
    dec b
    jr nz, -
    xor a, a
    ld (magi_total), a
    jp cmd_done
cmd_f018_magi_restore:
    ld a, :data_item_usage
    rst $28
    ld de, data_item_usage+$100
    ld hl, magi_list
    ld b, $08
-   ld a, (hl)
    or a, $09
    ldi (hl), a
    ld a, (de)
    inc de
    ldi (hl), a
    dec b
    jr nz, -
    ld b, $06
-   ld a, (hl)
    or a, $01
    ldi (hl), a
    ld a, (de)
    inc de
    ldi (hl), a
    dec b
    jr nz, -
    ld a, $4e
    ld (magi_total), a
    jp cmd_done

.ends


