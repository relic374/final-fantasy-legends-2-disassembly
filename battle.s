.include "common.i"

.bank $0d slot 1
.orga $4000

.section "battle" size $1000 overwrite

xd_battle:
    ld hl, cscript_vars
    ld b, $e0
    xor a, a
-   ldi (hl), a
    dec b
    jr nz, -
    ld a, (encounter_info)
    ld (battle.encounter_info), a
    ld h, >battle.data.1.max_stack
    ld b, $08
    xor a, a
-   ld l, <battle.data.1.max_stack
    ldi (hl), a
    ld (hl), a
    inc h
    dec b
    jr nz, -
    ld h, >battle.data.5.max_stack
    ld de, encounter_monster_data
    ld b, $03
-   ld a, (de)
    or a, a
    jr z, +
    ld l, <battle.data.5.max_stack
    ldi (hl), a
    ld (hl), a
    inc de
    ld a, (de)
    dec de
    ld l, <battle.data.5.monster_id
    ld (hl), a
    inc h
+   inc de
    inc de
    dec b
    jr nz, -
    ld d, >battle.data.5.max_stack
    ld b, $03
-   push bc
    push de
    ld e, <battle.data.5.max_stack
    ld a, (de)
    or a, a
    jr z, +
    call load_monster_battle_data
+   pop de
    inc d
    pop bc
    push bc
    ld a, $03
    sub a, b
    add a, <enemy_inventory_sizes
    ld c, a
    ld b, >enemy_inventory_sizes
    ld a, (out_enemy_inventory_size)
    ld (bc), a
    pop bc
    dec b
    jr nz, -
    xor a, a
    ld d, >battle.data.1.max_stack
    ld b, $05
-   push bc
    push af
    ld hl, player.1
    call x_add_player_offset_non_battle
    push de
    call load_player_battle_data
    pop de
    inc d
    pop af
    inc a
    pop bc
    dec b
    jr nz, -
    call x_test_script_var_0
    jr nz, +
    ld hl, battle.data.4.max_stack
    xor a, a
    ldi (hl), a
    ld (hl), a
+   ld bc, battle.data.5.max_stack
    ld a, $03
-   push af
    push bc
    call load_monster_battle_hp
    pop bc
    inc b
    pop af
    dec a
    jr nz, -
    ld hl, magi_list
    ld b, $0e
    ld c, $00
-   push bc
    ld a, (hl)
    and a, $f0
    jr z, +
    push hl
    inc hl
    ld e, (hl)
    swap a
    dec a
    add a, >(battle.data.1.inventory+$18)
    ld h, a
    ld l, <(battle.data.1.inventory+$18)
    ld (hl), c
    inc l
    ld (hl), $01
    inc l
    ld (hl), e
    pop hl
+   inc hl
    inc hl
    pop bc
    inc c
    dec b
    jr nz, -
    ld hl, battle.data.1.inventory
    ld a, $08
-   push af
    push hl
    call load_battle_resists
    pop hl
    inc h
    pop af
    dec a
    jr nz, -
    ld hl, last_used
    ld b, $08
-   ld a, $ff
    ldi (hl), a
    xor a, a
    ldi (hl), a
    dec b
    jr nz, -
    ld a, (battle_music)
    cp a, $03
    jr z, +
    add a, $11
    ldh (<hram.audio.bg_music), a
+   call x_fc_monster_gfx_setup
    ld a, $00
    call execute_battle_cscript
    xor a, a
    ld (battle_turn), a
_L000:
    call x_fc_load_monster_gfx_dimensions
    ld a, (battle_turn)
    inc a
    ld (battle_turn), a
    ld hl, actors
    ld b, $41
    ld a, $ff
-   ldi (hl), a
    dec b
    jr nz, -
    xor a, a
    ld (current_actor_index), a
    ld hl, battle.data.1.max_stack
    ld c, $08
--  ld a, (hl)
    or a, a
    jr z, +
    ld b, a
    ld l, <battle.data.1.stat.1.item_id
-   ld (hl), $ff
    inc l
    ld (hl), $00
    ld a, l
    add a, $07
    ld l, a
    dec b
    jr nz, -
+   inc h
    ld l, $00
    dec c
    jr nz, --
    call choose_default_abilities
    ld a, (ambush)
    cp a, $02
    jr z, +
    call x_fc_load_monster_gfx_address
    ld a, (hram.confirmed_cursor.1)
    cp a, $ff
    jr nz, +
    ld a, $01
    call execute_battle_cscript
    ld a, (run_result)
    or a, a
    jr z, ++
    ld a, $38
    ldh (<hram.audio.sfx), a
    call _wait_for_input_and_end_battle_mode
    call commit_battle_data
    call x_restore_map_bank_d
    ld a, (saved_bg_music)
    ldh (<hram.audio.bg_music), a
    ret
_wait_for_input_and_end_battle_mode:
    ld a, (hram.joyp_raw)
    ld b, a
-   rst $10
    ld a, (hram.joyp_raw)
    cp a, b
    jr z, -
    or a, a
    jr z, _wait_for_input_and_end_battle_mode
    call x_end_battle_mode
    ret
++  call choose_default_abilities
+   ld a, (ambush)
    dec a
    jr z, +
    ld a, $02
    call execute_battle_cscript
+   xor a, a
    ld (ambush), a
    ld a, $03
    call execute_battle_cscript
    ld hl, actors
_L001:
    push hl
    ldi a, (hl)
    cp a, $ff
    jr nz, +
    pop hl
    jp _L004
+   add a, a
    add a, a
    add a, a
    add a, <battle.data.1.stat.1.status
    ld c, a
    ldi a, (hl)
    ld l, a
    add a, >battle.data.1.current_stack
    ld d, a
    ld e, <battle.data.1.current_stack
    ld a, l
    add a, a
    add a, <last_used
    ld l, a
    ld h, >last_used
    ld a, (de)
    or a, a
    jr z, +
    ld e, c
    ld a, (de)
    ld c, a
    and a, $90
    jr nz, +
    bit 3, c
    jr z, ++
    push de
    push hl
    ld a, $04
    call execute_battle_cscript
    pop hl
    pop de
++  push de
    push hl
    ld a, $05
    call execute_battle_cscript
    pop hl
    pop de
    inc e
    inc e
    inc e
    ld a, (de)
    ldi (hl), a
    ld c, a
    inc e
    ld a, (de)
    ld (hl), a
    ld h, a
    ld l, c
    ld a, c
    cp a, $ff
    jr z, ++
    cp a, $0e
    jr z, _L002
    cp a, $0f
    jr nz, _L003
    ld a, h
    or a, a
    jr z, _L003
_L002:
    ld a, h
    dec a
    jr z, ++
_L003:
    inc e
    inc e
    ld a, (de)
    cp a, $ff
    jr z, ++
    ld e, a
    add a, a
    add a, e
    add a, <(battle.data.1.inventory+$02)
    ld e, a
    ld a, (de)
    cp a, $fe
    jr z, ++
    dec a
    ld (de), a
++  call x_fc_process_monster_gfx
    ld hl, battle.data.1.current_stack
    ld b, $05
    call count_battle_data
    or a, a
    jr z, ++
    ld b, $03
    call count_battle_data
    or a, a
    jr z, _L005
+   pop hl
    inc hl
    inc hl
    ld a, (current_actor_index)
    inc a
    ld (current_actor_index), a
    ld a, (hl)
    cp a, $ff
    jp nz, _L001
_L004:
    ld hl, battle.data.1.current_stack
    ld b, $05
    call count_battle_data
    or a, a
    jr z, +
    ld b, $03
    call count_battle_data
    or a, a
    jr z, _L006
    ld a, $06
    call execute_battle_cscript
    call x_fc_process_monster_gfx
    ld hl, battle.data.1.current_stack
    ld b, $05
    call count_battle_data
    or a, a
    jr z, +
    ld b, $03
    call count_battle_data
    or a, a
    jr z, _L006
    ld a, $07
    call execute_battle_cscript
    ld hl, actors
    jp _L000
++  pop hl
+   ld a, $59
    ld (battle_script_index), a
    rst $20
    call _wait_for_input_and_end_battle_mode
    xor a, a
    ldh (<BGP), a
    ldh (<OBP0), a
    ldh (<OBP1), a
    ld a, $01
    ld (defeated_flag), a
    ld (encounter_result), a
    ld a, $02
    ld (hram.fade_in_type), a
    ld a, $07
    ldh (<hram.audio.bg_music), a
    ret
_L005:
    pop hl
_L006:
    ld a, (battle.data.5.monster_id)
    inc a
    jr z, +
    ld a, $03
    ldh (<hram.audio.bg_music), a
+   xor a, a
    ld (defeated_flag), a
    ld a, $5a
    ld (battle_script_index), a
    rst $20
    call commit_battle_data
    ld a, (battle.data.5.monster_id)
    inc a
    jp z, _L008
    ld a, $08
    call execute_battle_cscript
    ld a, (meat_flag)
    or a, a
    jp z, _L007
    call x_fc_menu_meat
    ld a, (hram.confirmed_cursor.1)
    cp a, $ff
    jp z, _L007
    ld (transformation_index), a
    ld hl, player.1.monster_id
    call x_add_player_offset_non_battle
    push hl
    ld a, $09
    call execute_battle_cscript
    pop hl
    ld a, (transformation_flag)
    or a, a
    jp z, _L007
    ld a, (transformation_result)
    ldi (hl), a
    push hl
    ld l, a
    ld h, $00
    add hl, hl
    ld e, l
    ld d, h
    add hl, hl
    add hl, hl
    add hl, de
    ld de, data_monsters
    add hl, de
    ld a, :data_monsters
    call read_from_bank
    ld b, a
    swap a
    and a, $0f
    pop de
    ld (de), a
    inc e
    inc e
    inc hl
    inc hl
    ld a, :data_monsters
    call read_from_bank
    ld (de), a
    ld c, a
    inc e
    inc hl
    ld a, :data_monsters
    call read_from_bank
    ld (de), a
    inc e
    inc e
    ld (de), a
    dec e
    ld a, c
    ld (de), a
    inc e
    inc e
    inc hl
    ld c, $04
-   ld a, :data_monsters
    call read_from_bank
    ld (de), a
    inc e
    inc hl
    dec c
    jr nz, -
    ld a, :data_monsters
    call read_from_bank
    ld c, a
    inc hl
    ld a, :data_monsters
    call read_from_bank
    ld h, a
    ld l, c
    push de
    ld c, $10
    ld a, $ff
-   ld (de), a
    inc de
    dec c
    jr nz, -
    pop de
    ld a, b
    and a, $0f
    inc a
    ld b, a
    push bc
    push de
-   ld a, :data_monster_inventories
    call read_from_bank
    ld (de), a
    inc e
    inc e
    inc hl
    dec b
    jr nz, -
    pop de
    pop bc
-   ld a, (de)
    add a, <data_item_usage
    ld l, a
    ld a, >data_item_usage
    adc a, $00
    ld h, a
    inc e
    ld a, :data_item_usage
    call read_from_bank
    ld (de), a
    inc e
    dec b
    jr nz, -
_L007:
    ld a, $0a
    call execute_battle_cscript
_L008:
    call _wait_for_input_and_end_battle_mode
    call x_restore_map_bank_d
    ld a, (saved_bg_music)
    ldh (<hram.audio.bg_music), a
    ret
count_battle_data:
    xor a, a
-   add a, (hl)
    inc h
    dec b
    jr nz, -
    ret
execute_battle_cscript:
    add a, a
    add a, <jt_cscript_entry
    ld l, a
    ld a, >jt_cscript_entry
    adc a, $00
    ld h, a
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
commit_battle_data:
    xor a, a
    ld d, >battle.data.1.stat.1
    ld b, $05
--  push af
    push bc
    push de
    ld hl, player.1.status
    call x_add_player_offset_non_battle
    ld e, <battle.data.1.stat.1.status
    ld a, (de)
    and a, $f0
    ld (hl), a
    bit 7, a
    jr z, +
    and a, $70
    ld (hl), a
-   inc e
    ld a, $01
    ld (de), a
    inc e
    dec a
    ld (de), a
    dec e
    dec e
    jr ++
+   inc e
    ld a, (de)
    ld b, a
    inc e
    ld a, (de)
    dec e
    dec e
    or a, b
    jr z, -
++  inc l
    inc de
    ld a, (de)
    ldi (hl), a
    inc de
    ld a, (de)
    ldi (hl), a
    ld e, <battle.data.1.inventory
    ld a, l
    add a, player.1.inventory-player.1.max_hp
    ld l, a
    ld b, $08
-   ld a, (de)
    ld c, a
    inc de
    inc de
    ld a, (de)
    or a, a
    jr nz, +
    push de
    ld e, <battle.data.1.race
    ld a, (de)
    pop de
    cp a, $02
    jr nc, +
    ld a, c
    cp a, $80
    jr nc, +
    ld c, $ff
    ld a, c
    ld (de), a
+   ld a, c
    ldi (hl), a
    ld a, (de)
    ldi (hl), a
    inc de
    dec b
    jr nz, -
    ld a, (de)
    cp a, $ff
    jr z, +
    add a, a
    add a, <(magi_list+$01)
    ld l, a
    ld a, >(magi_list+$01)
    adc a, $00
    ld h, a
    inc e
    inc e
    ld a, (de)
    ld (hl), a
+   pop de
    inc d
    pop bc
    pop af
    inc a
    dec b
    jr nz, --
    ret
load_battle_resists:
    ld e, <battle.data.1.resist
    ld d, h
    xor a, a
    ld (de), a
    inc e
    ld (de), a
    dec e
    ld b, $09
-   push bc
    ldi a, (hl)
    cp a, $ff
    jr z, +
    push hl
    ld h, (hl)
    ld l, a
    push de
    add hl, hl
    add hl, hl
    add hl, hl
    ld de, data_items+$02
    add hl, de
    ld a, :data_items
    call read_from_bank
    and a, $30
    jr z, ++
    pop de
    push de
    cp a, $10
    jr z, _L009
    inc de
_L009:
    inc hl
    inc hl
    inc hl
    ld a, :data_items
    call read_from_bank
    ld l, a
    ld a, (de)
    or a, l
    ld (de), a
++  pop de
    pop hl
+   inc hl
    inc hl
    pop bc
    dec b
    jr nz, -
    ret
load_monster_battle_hp:
    ld a, (bc)
    or a, a
    ret z
    push af
    ld c, <battle.data.1.hp
    ld a, (bc)
    ld l, a
    inc c
    ld a, (bc)
    ld h, a
    ld d, h
    ld e, l
    ld c, <battle.data.1.monster_id
    ld a, (bc)
    inc a
    jr nz, +
    ld de, $0000
+   srl d
    rr e
    srl d
    rr e
    srl d
    rr e
    pop af
    ld c, <battle.data.1.stat.1.status
-   push af
    push hl
    push bc
    push de
    ld e, $00
    ld a, $07
    call x_random_integer
    ld c, a
    pop de
    push de
    ld d, e
    ld e, $00
    ld a, $08
    call x_random_integer
    ld e, a
    ld d, c
    ld a, d
    cpl
    ld d, a
    ld a, e
    cpl
    add a, $01
    ld e, a
    ld a, d
    adc a, $00
    ld d, a
    add hl, de
    pop de
    pop bc
    xor a, a
    ld (bc), a
    inc c
    ld a, l
    ld (bc), a
    inc c
    ld a, h
    ld (bc), a
    ld a, c
    and a, $f8
    add a, battle.data.1.stat.2-battle.data.1.stat.1
    ld c, a
    pop hl
    pop af
    dec a
    jr nz, -
    ret
load_player_battle_data:
    ld a, $01
    ld e, <battle.data.1.max_stack
    ld (de), a
    ld e, <battle.data.1.name
    ld b, $04
-   ldi a, (hl)
    ld (de), a
    inc e
    dec b
    jr nz, -
    ld b, $04
-   ld a, $ff
    ld (de), a
    inc e
    dec b
    jr nz, -
    ldi a, (hl)
    ld (de), a
    inc e
    ldi a, (hl)
    ld (de), a
    inc e
    push de
    ld e, <battle.data.1.stat.1.status
    ldi a, (hl)
    ld (de), a
    inc e
    push de
    and a, $10
    swap a
    xor a, $01
    ld e, <battle.data.1.current_stack
    ld (de), a
    pop de
    ldi a, (hl)
    ld (de), a
    inc e
    ldi a, (hl)
    ld (de), a
    pop de
    ld b, $06
-   ldi a, (hl)
    ld (de), a
    inc e
    dec b
    jr nz, -
    ld b, $08
-   ldi a, (hl)
    ld (de), a
    inc e
    xor a, a
    ld (de), a
    inc e
    ldi a, (hl)
    ld (de), a
    inc e
    dec b
    jr nz, -
    ld a, $ff
    ld (de), a
    inc e
    inc a
    ld (de), a
    dec a
    inc e
    ld (de), a
    inc e
    xor a, a
    ld (de), a
    inc e
    ld (de), a
    ret
load_monster_battle_data:
    ld e, <battle.data.1.monster_id
    ld a, (de)
    ld l, a
    ld e, <battle.data.1.name
    ld h, $00
    add hl, hl
    push hl
    add hl, hl
    add hl, hl
    push de
    ld de, data_monster_names
    add hl, de
    pop de
    ld a, :data_monster_names
    ld b, $08
    call memcopy_from_bank
    pop hl
    push de
    ld e, l
    ld d, h
    add hl, hl
    add hl, hl
    add hl, de
    ld de, data_monsters
    add hl, de
    ld b, $0a
    ld de, monster_temp
    ld a, :data_monsters
    call memcopy_from_bank
    pop de
    ld hl, monster_temp
    ldi a, (hl)
    push af
    and a, $f0
    swap a
    ld e, <battle.data.1.race
    ld (de), a
    inc hl
    ldi a, (hl)
    ld e, <battle.data.1.hp
    ld (de), a
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
    ldi a, (hl)
    ld (de), a
    inc e
    ldi a, (hl)
    ld (de), a
    ldi a, (hl)
    ld h, (hl)
    ld l, a
    pop af
    and a, $0f
    ld (out_enemy_inventory_size), a
    inc a
    ld b, a
    ld e, <battle.data.1.inventory
-   ld a, :data_monster_inventories
    call read_from_bank
    inc hl
    ld (de), a
    inc e
    xor a, a
    ld (de), a
    inc e
    ld a, $fe
    ld (de), a
    inc e
    dec b
    jr nz, -
-   ld a, $ff
    ld (de), a
    inc e
    xor a, a
    ld (de), a
    inc e
    ld a, $ff
    ld (de), a
    inc e
    ld a, e
    cp a, <(battle.data.1.inventory+$1b)
    jr c, -
    xor a, a
    ld e, <battle.data.1.resist
    ld (de), a
    inc e
    ld (de), a
    ret
choose_default_abilities:
    ld h, >battle.data.1.current_stack
    ld c, $05
--  ld de, default_ability_table
    ld l, <battle.data.1.current_stack
    ld a, (hl)
    or a, a
    ld a, $80
    ld l, <battle.data.1.stat.1.status
    ld b, $07
    jr z, +
    ldi a, (hl)
-   rrca
    jr c, _L010
    inc de
    inc de
    dec b
    jr nz, -
    jp _L010
default_ability_table:
    .dw $010f
    .dw $010e
    .dw $00ff
    .dw $00ff
    .dw $00ff
    .dw $00ff
    .dw $00ff
    .dw $00ff
_L010:
    inc l
    inc l
    ld a, (de)
    ldi (hl), a
    inc de
    ld a, (de)
    ld (hl), a
+   inc h
    dec c
    jr nz, --
    ret

.ends


