.include "common.i"

.bank $0f slot 1
.orga $6080

.section "monster_gfx" size $04e0 overwrite

xf_monster_gfx_setup:
    jp monster_gfx_setup
xf_process_monster_gfx:
    jp process_monster_gfx
xf_load_monster_gfx_tilemaps:
    jp load_monster_gfx_tilemaps
xf_draw_monster_gfx_tilemap:
    jp draw_monster_gfx_tilemap
xf_get_monster_gfx_dimensions_and_offset:
    jp get_monster_gfx_dimensions_and_offset
xf_load_arsenal_cloud_background_lower:
    jp load_arsenal_cloud_background_lower
xf_load_monster_gfx_offset_and_size:
    jp load_monster_gfx_offset_and_size
xf_get_monster_gfx_tilemap_address:
    jp get_monster_gfx_tilemap_address
monster_gfx_setup:
    rst $10
    xor a, a
    ldh (<BGP), a
    ldh (<OBP0), a
    ldh (<OBP1), a
    ld a, $c0
    ldh (<LCDC), a
    ld hl, $d920
    ld bc, $01e0
    call memclear_16
    ldh (<hram.window_sprite_mode), a
    dec a
    ld hl, $9800
    ld bc, $0800
    call vram_memset_16
    ld hl, oam_staging_cc
    ld b, $a0
    call memclear
    rst $10
    ld a, >oam_staging_cc
    rst $18
    ld hl, data_font_extension
    ld de, $9700
    ld bc, $0100
    ld a, :data_font_extension
    call vram_memcopy_16_from_bank
    ld hl, death_animation_flag
    xor a, a
    ldi (hl), a
    ldi (hl), a
    ld (hl), a
    ld a, (encounter_id)
    and a, a
    jr z, @set_arsenal_encounter
    ld b, $07
    ld hl, special_encounters
-   cp a, (hl)
    jr z, @set_special_encounter
    inc hl
    dec b
    jr nz, -
    xor a, a
    jr +
@set_special_encounter:
    ld a, $01
    jr +
@set_arsenal_encounter:
    ld a, $02
+   ld (special_encounter), a
    call x_far_call
    .addr xd_load_monster_gfx_metadata
    .db :xd_load_monster_gfx_metadata
    call load_monster_gfx_offset_and_size
    call load_monster_gfx_tiles
    call load_monster_gfx_tilemaps
    rst $10
    ld a, $40
    ldh (<WY), a
    ld a, $07
    ldh (<WX), a
    xor a, a
    ldh (<SCY), a
    ldh (<SCX), a
    ld a, $c3
    ldh (<LCDC), a
    ld a, (special_encounter)
    and a, a
    jr z, +
    dec a
    jr z, ++
    call arsenal_initialize
    jr @after_spawn
++  call special_encounter_initialize
    jr @after_spawn
+   call monster_gfx_spawn_animation
@after_spawn:
    rst $10
    ld a, $d2
    ldh (<BGP), a
    ld (menu_palette_backup), a
    ld a, $d2
    ldh (<OBP0), a
    ld (menu_palette_backup+$01), a
    ld a, $81
    ldh (<OBP1), a
    ld (menu_palette_backup+$02), a
    ret
load_monster_gfx_tilemaps:
    call load_monster_gfx_background
    xor a, a
-   ldh (<hram.temp.1), a
    ld hl, battle.data.5.current_stack
    add a, h
    ld h, a
    ld a, (hl)
    and a, a
    call nz, load_monster_gfx_tilemap
    ldh a, (<hram.temp.1)
    inc a
    cp a, $03
    jr c, -
    ret
load_monster_gfx_tilemap:
    call get_monster_gfx_dimensions_and_offset
    ldh a, (<hram.temp.1)
    call get_monster_gfx_tilemap_address
draw_monster_gfx_tilemap:
    call x_vram_enable
--  ld e, c
    push hl
-   ld a, h
    cp a, $98
    jr c, +
    ld (hl), d
+   inc hl
    inc d
    dec e
    jr nz, -
    pop hl
    ld a, $20
    rst $00
    dec b
    jr nz, --
    jp x_vram_disable
get_monster_gfx_dimensions_and_offset:
    ldh a, (<hram.temp.1)
    add a, a
    ld hl, monster_gfx_offset
    rst $00
    ld d, (hl)
    ld hl, monster_gfx_dims
    rst $00
    ld c, (hl)
    inc hl
    ld b, (hl)
    ret
load_monster_gfx_background:
    ld hl, $9800
    ld c, $04
    ld a, (special_encounter)
    cp a, $02
    jr z, load_arsenal_cloud_background
    ld a, $ff
    ld bc, $0100
    jp vram_memset_16
load_arsenal_cloud_background_lower:
    ld hl, $9900
    ld c, $05
load_arsenal_cloud_background:
    call x_vram_enable
-   call load_arsenal_cloud_background_row_0
    call load_arsenal_cloud_background_row_1
    dec c
    jr nz, -
    jp x_vram_disable
load_arsenal_cloud_background_row_1:
    ld de, $1d1c
    jr +
load_arsenal_cloud_background_row_0:
    ld de, $0e00
+   ld b, $10
-   ld (hl), e
    inc hl
    ld (hl), d
    inc hl
    dec b
    jr nz, -
    ret
get_monster_gfx_tilemap_address:
    push af
    push bc
    push de
    ld hl, monster_gfx_x
    rst $00
    ld e, (hl)
    inc hl
    inc hl
    inc hl
    ld l, (hl)
    ld bc, $9800
    ld h, c
    ld d, c
    call add_de_hl_32_x
    add hl, bc
    pop de
    pop bc
    pop af
    ret
arsenal_initialize:
    ld hl, hram.arsenal_cloud.enable
    ld (hl), $01
    inc hl
    ld (hl), $00
    ret
special_encounter_initialize:
    ret
monster_gfx_spawn_animation:
    ld e, $01
    ld a, $ff
    ldh (<hram.temp.1), a
    rst $10
    ld a, $d2
    ldh (<BGP), a
    di
-   dec e
    jr nz, _L000
    ld e, $04
    ldh a, (<hram.temp.1)
    inc a
    cp a, $04
    jr nc, +
    ldh (<hram.temp.1), a
    ld hl, spawn_repeat_counts
    rst $00
    ld a, (hl)
    ldh (<hram.temp.2), a
    call monster_gfx_spawn_animation_helper
    ld hl, spawn_y_offsets
    ldh a, (<hram.temp.1)
    rst $00
    ld d, (hl)
_L000:
    ldh a, (<LY)
    cp a, $00
    jr nz, _L000
--  ldh a, (<LY)
    cp a, $40
    jr c, ++
    call x_game_update
    jr -
++  ld bc, window_buffer_1
    ld l, a
    ld h, $00
    add hl, bc
-   ldh a, (<STAT)
    and a, $03
    jr nz, -
    ld a, (hl)
    add a, d
    ldh (<SCY), a
    jr --
+   xor a, a
    ldh (<SCY), a
    reti
monster_gfx_spawn_animation_helper:
    push de
    ld hl, window_buffer_1
    ldh a, (<hram.temp.2)
    ld e, a
    xor a, a
    ld c, $40
--  ld b, e
-   ldi (hl), a
    dec c
    jr z, +
    dec b
    jr nz, -
    inc a
    jr --
+   pop de
    ret
load_monster_gfx_offset_and_size:
    call x_far_call
    .addr xd_load_monster_gfx_dimensions
    .db :xd_load_monster_gfx_dimensions
    ld a, (enemy_group_count)
    ld b, a
    ld hl, monster_gfx_dims
    ld de, monster_gfx_offset
    ld c, $00
-   ld a, c
    ld (de), a
    inc de
    push hl
    ldi a, (hl)
    ld l, (hl)
    ld h, a
    call x_multiply_8_8
    ld a, l
    pop hl
    ld (de), a
    inc de
    inc hl
    inc hl
    add a, c
    ld c, a
    dec b
    jr nz, -
    ret
load_monster_gfx_tiles:
    ld a, (enemy_group_count)
    ld b, a
    ld de, $9000
    xor a, a
    ldh (<hram.temp.1), a
-   push bc
    push de
    call x_far_call
    .addr xd_load_monster_gfx_address
    .db :xd_load_monster_gfx_address
    pop de
    call vram_memcopy_16_from_bank
    pop bc
    ld hl, hram.temp.1
    inc (hl)
    dec b
    jr nz, -
    ret
spawn_y_offsets:
    .db $e0
    .db $f0
    .db $f4
    .db $f8
spawn_repeat_counts:
    .db $01
    .db $02
    .db $03
    .db $04
special_encounters:
    .db $80
    .db $01
    .db $81
    .db $03
    .db $83
    .db $04
    .db $84
process_monster_gfx:
    ld b, $10
    ld hl, data_battle_animation_gfx+$1fe0
    call x_far_call
    .addr xd_load_animation_gfx
    .db :xd_load_animation_gfx
    ld a, (enemy_group_count)
    ld b, a
    ld hl, battle.data.5.current_stack
    ld de, battle_animation_lift_flag
    ld c, $00
-   ld a, (hl)
    and a, a
    jr nz, +
    call process_monster_gfx_death
    xor a, a
    ld (de), a
+   ld a, (de)
    and a, a
    jr z, +
    ld a, c
    ldh (<hram.temp.1), a
    call process_monster_gfx_lift
+   inc de
    inc h
    inc c
    dec b
    jr nz, -
    ld a, (battle_animation_fade_out)
    and a, a
    ret z
    call x_far_call
    .addr xd_pba_fade_in
    .db :xd_pba_fade_in
    ret
process_monster_gfx_death:
    push af
    push bc
    push de
    push hl
    ld a, c
    ld hl, death_animation_flag
    rst $00
    ld a, (hl)
    and a, a
    jp nz, _L001
    cpl
    ld (hl), a
    ld a, c
    ldh (<hram.temp.1), a
    ld hl, battle_animation_lift_flag
    rst $00
    ld a, (hl)
    and a, a
    jp nz, _L001
    ld a, (special_encounter)
    cp a, $02
    jp z, _L002
    ldh a, (<hram.temp.1)
    add a, a
    ld hl, monster_gfx_dims
    rst $00
    ldi a, (hl)
    ldh (<hram.temp.2), a
    ld a, (hl)
    ld c, a
    dec c
    srl a
    ldh (<hram.temp.3), a
    ldh a, (<hram.temp.1)
    call get_monster_gfx_tilemap_address
    call store_enemy_death_top_write_position
    ld e, l
    ld d, h
    ld l, c
    ld h, $00
    call add_de_hl_32_x
    call store_enemy_death_bottom_write_position
-   rst $10
    call load_enemy_death_top_write_position
    call enemy_death_clear_row
    ld a, $20
    rst $00
    call store_enemy_death_top_write_position
    rst $10
    call load_enemy_death_bottom_write_position
    call enemy_death_clear_row
    ld de, -$0020
    add hl, de
    call store_enemy_death_bottom_write_position
    rst $10
    rst $10
    ld hl, hram.temp.3
    dec (hl)
    jr nz, -
    ld a, (battle_animation_fade_out)
    and a, a
    jp nz, _L001
    ldh a, (<hram.temp.1)
    ld hl, monster_gfx_x_raw
    rst $00
    ld a, (hl)
    add a, a
    add a, a
    add a, a
    add a, $04
    ld e, a
    ldh a, (<hram.temp.1)
    ld hl, monster_gfx_y
    rst $00
    ld d, (hl)
    add a, a
    ld hl, monster_gfx_dims+$01
    rst $00
    ld a, (hl)
    srl a
    add a, d
    add a, a
    add a, a
    add a, a
    add a, $08
    ld d, a
    ld hl, battle_animation_buffer
    ld b, $09
-   ld (hl), d
    inc hl
    ld (hl), e
    inc hl
    dec b
    jr nz, -
    ld hl, death_animation_counter
    ld (hl), $08
    ld (hl), $01
-   call enemy_death_stage_oam
    rst $10
    ld a, >oam_staging_cc
    rst $18
    ld a, (battle_animation_buffer+$01)
    ld e, a
    ld hl, death_animation_counter
    inc (hl)
    inc (hl)
    ld a, (hl)
    cp a, $20
    jr nc, +
    ld d, a
    ld a, (hl)
    srl a
    srl a
    srl a
    add a, a
    ld hl, battle_animation_buffer+$03
    rst $00
    ld c, a
    ld a, e
    sub a, d
    ld (hl), a
    ld a, c
    ld hl, battle_animation_buffer+$0b
    rst $00
    ld a, e
    add a, d
    ld (hl), a
    jr -
+   ld hl, enemy_death_palettes+$01
    ld b, $02
--  ld d, $04
-   rst $10
    ld a, (hl)
    ldh (<OBP0), a
    dec d
    jr nz, -
    inc hl
    dec b
    jr nz, --
    ld hl, oam_staging_cc
    ld b, $28
    call memclear
    rst $10
    ld a, >oam_staging_cc
    rst $18
    ld a, $d2
    ldh (<OBP0), a
_L001:
    pop hl
    pop de
    pop bc
    pop af
    ret
_L002:
    xor a, a
    ldh (<hram.audio.bg_music), a
    ld hl, $9900
    ld c, $0c
    call load_arsenal_cloud_background
    ld c, $40
-   ld b, $02
    call arsenal_death_shake
    ld hl, SCY
    dec (hl)
    dec c
    jr nz, -
    ld hl, $9800
    ld c, $04
    call load_arsenal_cloud_background
    rst $10
    xor a, a
    ldh (<SCY), a
    jr _L001
arsenal_death_shake:
    ld a, $04
    ldh (<hram.temp.1), a
-   rst $10
    rst $10
    ld a, $27
    ldh (<hram.audio.sfx), a
    ldh a, (<hram.temp.1)
    ldh (<SCX), a
    rst $10
    rst $10
    xor a, a
    ldh (<SCX), a
    rst $10
    rst $10
    ldh a, (<hram.temp.1)
    cpl
    inc a
    ldh (<SCX), a
    dec b
    jr nz, -
    ret
enemy_death_clear_row:
    push hl
    ldh a, (<hram.temp.2)
    ld b, a
    ld a, $ff
    call memset
    pop hl
    ret
load_enemy_death_top_write_position:
    ld hl, battle_animation_top_ptr
    ldi a, (hl)
    ld h, (hl)
    ld l, a
    ret
store_enemy_death_top_write_position:
    ld a, l
    ld (battle_animation_top_ptr), a
    ld a, h
    ld (battle_animation_top_ptr+1), a
    ret
load_enemy_death_bottom_write_position:
    ld hl, battle_animation_bottom_ptr
    ldi a, (hl)
    ld h, (hl)
    ld l, a
    ret
store_enemy_death_bottom_write_position:
    ld a, l
    ld (battle_animation_bottom_ptr), a
    ld a, h
    ld (battle_animation_bottom_ptr+1), a
    ret
enemy_death_stage_oam:
    ld b, $09
    ld de, battle_animation_buffer
    ld hl, oam_staging_cc
-   ld a, (de)
    inc de
    ldi (hl), a
    ld a, (de)
    inc de
    ldi (hl), a
    ld (hl), $00
    inc hl
    ld (hl), $00
    inc hl
    dec b
    jr nz, -
    ret
process_monster_gfx_lift:
    push af
    push bc
    push de
    push hl
    ldh a, (<hram.temp.1)
    ld hl, battle_animation_lift_flag
    rst $00
    ld (hl), $00
    call get_monster_gfx_tilemap_address
    ld de, -$00e0
    add hl, de
    call store_enemy_death_top_write_position
    ldh a, (<hram.temp.1)
    ld hl, monster_gfx_x
    rst $00
    ld a, (hl)
    ld hl, $9800
    rst $00
    call store_enemy_death_bottom_write_position
    ld a, $08
    ldh (<hram.temp.2), a
    call get_monster_gfx_dimensions_3
    ld a, $08
    sub a, b
    ldh (<hram.temp.3), a
-   call get_monster_gfx_dimensions_and_offset
    call load_enemy_death_top_write_position
    call draw_monster_gfx_tilemap
    call load_enemy_death_top_write_position
    ld a, $20
    rst $00
    call store_enemy_death_top_write_position
    ld hl, hram.temp.2
    dec (hl)
    jr nz, -
-   ldh a, (<hram.temp.3)
    and a, a
    jp z, pop_and_return
    call get_monster_gfx_dimensions_3
    call load_enemy_death_bottom_write_position
    ld b, c
    ld a, $ff
    rst $10
    call memset
    call load_enemy_death_bottom_write_position
    ld a, $20
    rst $00
    call store_enemy_death_bottom_write_position
    ld hl, hram.temp.3
    dec (hl)
    jr -
get_monster_gfx_dimensions_3:
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
enemy_death_palettes:
    .db $d2
    .db $81
    .db $40

.ends


