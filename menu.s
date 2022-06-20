.include "common.i"

.bank $01 slot 1
.orga $5000

.section "menu" size $2000 overwrite

x1_menu_start:
    jp menu_start
x1_menu_party_order:
    jp menu_party_order
x1_menu_party_select:
    jp menu_party_select
x1_menu_shop:
    jp menu_shop
x1_execute_menu_cursor_internal:
    jp execute_menu_cursor_internal
x1_menu_main:
    jp main_menu
x1_load_monster_gfx_metadata:
    jp menu_inn
x1_load_monster_gfx_dimensions:
    jp init_and_draw_standard_battle_windows
x1_load_monster_gfx_address:
    jp battle_menu
x1_menu_meat:
    jp meat_menu
x1_restore_party:
    jp restore_party
x1_refresh_equipped_magi:
    jp refresh_equipped_magi_2
x1_refresh_magi_list:
    jp refresh_magi_list
x1_heal_party:
    jp heal_party
x1_monster_gfx_morph:
    jp monster_gfx_morph
x1_arsenal_cloud_process_update:
    jp arsenal_cloud_process_update
x1_do_meat_animation:
    jp do_meat_animation
x1_arsenal_cloud_stage_update:
    jp arsenal_cloud_stage_update
x1_the_end:
    jp the_end
execute_menu_cursor_internal:
    xor a, a
    ld (second_cursor), a
    ld hl, cursor_stops
-   ldi a, (hl)
    inc a
    jr nz, -
    dec hl
    dec hl
    ldd a, (hl)
    ld (last_cursor.x), a
    ld a, (hl)
    ld (last_cursor.y), a
    call get_cursor_stop_coordinates
    call set_scrolling_y_cursor_coordinates
    jr _L001
_L000:
    call play_invalid_sound
_L001:
    call update_first_cursor_position
    call x_read_buttons
    bit 7, a
    jr nz, @cursor_button_down
    bit 6, a
    jr nz, @cursor_button_up
    bit 5, a
    jr nz, @cursor_button_left
    bit 4, a
    jp nz, @cursor_button_right
    bit 1, a
    jp nz, @cursor_button_b
    bit 0, a
    jp nz, @cursor_button_a
    jr _L001
@cursor_button_down:
    ld a, (cursor_mode)
    bit 1, a
    jr nz, +
    call move_cursor_down
    jr nz, ++
    call wrap_cursor_down
    jr nz, ++
    ld hl, cursor_stops
    ld b, (hl)
    inc hl
    ld c, (hl)
    xor a, a
    ldh (<hram.current_cursor), a
++  call set_cursor_coordinates
    jr _L001
+   call move_cursor_down
    jr z, _L000
    call update_first_cursor_position
    call set_scrolling_y_cursor_coordinates
    jr _L001
@cursor_button_up:
    ld a, (cursor_mode)
    bit 1, a
    jr nz, +
    call move_cursor_up
    jr nz, ++
    call wrap_cursor_up
    jr nz, ++
    ld hl, last_cursor.y
    ld b, (hl)
    inc hl
    ld c, (hl)
    ld a, (cursor_stop_count)
    dec a
    ldh (<hram.current_cursor), a
++  call set_cursor_coordinates
    jr _L001
+   call move_cursor_up
    jr z, _L000
    call update_first_cursor_position
    call set_scrolling_y_cursor_coordinates
    jp _L001
@cursor_button_left:
    ld a, (cursor_mode)
    bit 1, a
    jr nz, +
    ldh a, (<hram.current_cursor)
    and a, a
    jr nz, ++
    ld a, (cursor_stop_count)
++  dec a
    ldh (<hram.current_cursor), a
    call get_cursor_stop_coordinates
    call set_cursor_coordinates
    jp _L001
+   ldh a, (<hram.current_cursor)
    and a, a
    jp z, _L000
    dec a
    ldh (<hram.current_cursor), a
    call update_first_cursor_position
    call get_cursor_stop_coordinates
    call set_scrolling_y_cursor_coordinates
    jp _L001
@cursor_button_right:
    ld a, (cursor_mode)
    bit 1, a
    jr nz, +
    ld a, (cursor_stop_count)
    ld b, a
    ldh a, (<hram.current_cursor)
    inc a
    cp a, b
    jr c, ++
    xor a, a
++  ldh (<hram.current_cursor), a
    call get_cursor_stop_coordinates
    call set_cursor_coordinates
    jp _L001
+   ld a, (cursor_stop_count)
    ld b, a
    ldh a, (<hram.current_cursor)
    inc a
    cp a, b
    jp nc, _L000
    ldh (<hram.current_cursor), a
    call update_first_cursor_position
    call get_cursor_stop_coordinates
    call set_scrolling_y_cursor_coordinates
    jp _L001
@cursor_button_b:
    ld a, (cursor_mode)
    bit 0, a
    jr z, +
    ld hl, second_cursor
    ld a, (hl)
    and a, a
    jr z, @clear_both_cursors
    xor a, a
    ld (hl), a
    call @clear_both_cursors
    ld hl, hram.cursor0.y
    ldi (hl), a
    ld (hl), a
    jp _L001
@clear_both_cursors:
    dec a
    ld hl, hram.confirmed_cursor.1
    ldi (hl), a
    ld (hl), a
    ret
+   ld hl, hram.confirmed_cursor.1
    ld (hl), $ff
    ret
@cursor_button_a:
    ld a, (cursor_mode)
    bit 0, a
    jr z, +
    ld a, (second_cursor)
    and a, a
    jr z, ++
    ld hl, hram.confirmed_cursor.2
    ldd a, (hl)
    ldi (hl), a
    ldh a, (<hram.current_cursor)
    ld (hl), a
    ret
++  inc a
    ld (second_cursor), a
    ldh a, (<hram.current_cursor)
    ldh (<hram.confirmed_cursor.2), a
    call play_confirm_sound
    jp _L001
+   ldh a, (<hram.current_cursor)
    ldh (<hram.confirmed_cursor.1), a
    ret
execute_text_entry_cursor:
    ld a, $06
    ld (cursor_mode), a
    ld hl, text_cursor_stops
-   ldi a, (hl)
    inc a
    jr nz, -
    dec hl
    dec hl
    ldd a, (hl)
    ld (last_cursor.x), a
    ld a, (hl)
    ld (last_cursor.y), a
    call get_cursor_stop_coordinates
    call set_scrolling_cursor_coordinates
    jr _L002
-   call nz, set_scrolling_cursor_coordinates
    call z, play_invalid_sound
_L002:
    call x_read_buttons
    rlca
    jr c, @text_button_down
    rlca
    jr c, @text_button_up
    rlca
    jr c, @text_button_left
    rlca
    jr c, @text_button_right
    rlca
    jr c, @text_button_start
    rlca
    jr c, @text_button_select
    rlca
    jr c, @text_button_b
    rlca
    jr c, @text_button_a
    jr _L002
@text_button_down:
    call move_cursor_down
    jr -
@text_button_up:
    call move_cursor_up
    jr -
@text_button_left:
    call move_cursor_left
    jr -
@text_button_right:
    call move_cursor_right
    jr -
@text_button_start:
    ld a, $fe
    jr +
@text_button_select:
    ld a, $fd
    jr +
@text_button_b:
    ld a, $ff
    jr ++
@text_button_a:
    ldh a, (<hram.current_cursor)
+   call play_confirm_sound
++  ldh (<hram.confirmed_cursor.1), a
    ret
set_scrolling_cursor_coordinates:
    push af
    xor a, a
    ldh (<hram.temp.1), a
    ldh a, (<hram.current_cursor)
    call check_cursor_scroll_y
    jr nc, +
    call cursor_scroll_y
    ld a, $01
    ldh (<hram.temp.1), a
+   call cursor_check_scroll_x
    jr nc, +
    call cursor_scroll_x
    ldh a, (<hram.temp.1)
    or a, $02
    ldh (<hram.temp.1), a
+   ldh a, (<hram.temp.1)
    and a, a
    jr z, +
    push bc
    call x_draw_box_script
    pop bc
+   call set_cursor_coordinates
    pop af
    ret
cursor_check_scroll_x:
    push de
    ld a, $80
    and a, c
    jr nz, +
    ld a, (box_script_last_screen_x)
    sub a, $02
    ld e, a
    ld a, c
    cp a, e
    jr nc, +
    ld a, (box_script_first_screen_x)
    ld e, a
    ld a, c
    cp a, e
    jr ++
+   ccf
++  pop de
    ret
cursor_scroll_x:
    push de
    bit 7, c
    jr z, +
    ld a, (window_scroll_x_offset)
    add a, c
    ld e, $00
    jr ++
+   ld a, (window_scroll_x_offset)
    ld d, a
    ld a, (box_script_first_screen_x)
    ld e, a
    ld a, c
    cp a, e
    jr nc, +
    ld a, e
    sub a, c
    cpl
    inc a
    add a, d
    jr ++
+   ld a, (box_script_last_screen_x)
    sub a, $03
    ld e, a
    ld a, c
    sub a, e
    add a, d
++  ld (window_scroll_x_offset), a
    ld c, e
    pop de
    ret
menu_memory_load:
    call get_menu_memory_address
    ldi a, (hl)
    ldh (<hram.current_cursor), a
    ld a, (hl)
    ld (window_scroll_y_offset), a
    ret
menu_memory_save:
    call get_menu_memory_address
    ldh a, (<hram.current_cursor)
    ldi (hl), a
    ld a, (window_scroll_y_offset)
    ld (hl), a
    ret
menu_memory_clear:
    call get_menu_memory_address
    xor a, a
    ldi (hl), a
    ld (hl), a
    ret
get_menu_memory_address:
    ld hl, menu_memory
    add a, a
    rst $00
    ret
set_scrolling_y_cursor_coordinates:
    ldh a, (<hram.current_cursor)
    call check_cursor_scroll_y
    jr nc, +
    call cursor_scroll_y
    push bc
    call x_draw_box_script
    pop bc
+   jp set_cursor_coordinates
update_first_cursor_position:
    ld a, (cursor_mode)
    bit 0, a
    ret z
    ld a, (second_cursor)
    and a, a
    ret z
    push bc
    ld hl, cursor_stops
    ldh a, (<hram.confirmed_cursor.2)
    add a, a
    rst $00
    ld b, (hl)
    inc hl
    ld c, (hl)
    ld hl, hram.cursor0.y
    ldh a, (<hram.confirmed_cursor.2)
    call check_cursor_scroll_y
    jr nc, +
    ld bc, $fffe
+   inc c
    ld (hl), b
    inc hl
    ld (hl), c
    pop bc
    ret
add_menu_scroll_offsets:
    push hl
    ld hl, window_scroll_x_offset
    ld a, c
    sub a, (hl)
    ld c, a
    inc hl
    ld a, b
    sub a, (hl)
    ld b, a
    pop hl
    ret
check_cursor_scroll_y:
    push de
    ld d, a
    ld a, (cursor_mode)
    bit 1, a
    jr z, +
    ld a, (non_scrolling_cursor_stop_count)
    ld e, a
    ld a, d
    cp a, e
    jr nc, ++
+   and a, a
    jr +
++  call add_menu_scroll_offsets
    ld a, (box_script_last_screen_y)
    dec a
    cp a, b
    jr c, +
    ld a, (box_script_first_screen_y)
    add a, $02
    cp a, b
    jr z, +
    ccf
+   pop de
    ret
cursor_scroll_y:
    push de
    ld a, (window_scroll_y_offset)
    ld d, a
    ld a, (box_script_first_screen_y)
    add a, $02
    cp a, b
    jr c, +
    ld e, a
    sub a, b
    cpl
    inc a
    add a, d
    jr ++
+   ld a, (box_script_last_screen_y)
    dec a
    ld e, a
    ld a, b
    sub a, e
    add a, d
++  ld (window_scroll_y_offset), a
    ld b, e
    pop de
    ret
move_cursor_down:
    call get_cursor_stop_coordinates
    call find_cursor_down
    ld b, e
    inc d
    dec d
    ret z
    ldh (<hram.current_cursor), a
    ret
find_cursor_down:
    ld hl, cursor_stops
    ld a, (cursor_mode)
    bit 2, a
    jr z, +
    ld hl, text_cursor_stops
+   ld de, $00ff
    xor a, a
    ldh (<hram.temp.1), a
-   inc hl
    ld a, c
    call find_cursor_stop_coordinate
    cp a, $ff
    ldh a, (<hram.temp.2)
    ret z
    dec hl
    ld a, b
    cp a, (hl)
    jr nc, +
    ld a, e
    cp a, (hl)
    jr c, +
    ld e, (hl)
    ld d, $ff
    ldh a, (<hram.temp.1)
    ldh (<hram.temp.2), a
+   ldh a, (<hram.temp.1)
    inc a
    ldh (<hram.temp.1), a
    inc hl
    inc hl
    jr -
move_cursor_right:
    call get_cursor_stop_coordinates
    jr +
wrap_cursor_down:
    ld a, (cursor_stops)
    ld b, a
+   call find_cursor_right
    ld c, e
    inc d
    dec d
    ret z
    ldh (<hram.current_cursor), a
    ret
find_cursor_right:
    ld hl, cursor_stops
    ld a, (cursor_mode)
    bit 2, a
    jr z, +
    ld hl, text_cursor_stops
+   ld de, $00ff
    xor a, a
    ldh (<hram.temp.1), a
-   ld a, b
    call find_cursor_stop_coordinate
    cp a, $ff
    ldh a, (<hram.temp.2)
    ret z
    inc hl
    ld a, c
    cp a, (hl)
    jr nc, +
    ld a, e
    cp a, (hl)
    jr c, +
    ld e, (hl)
    ld d, $ff
    ldh a, (<hram.temp.1)
    ldh (<hram.temp.2), a
+   ldh a, (<hram.temp.1)
    inc a
    ldh (<hram.temp.1), a
    inc hl
    jr -
move_cursor_up:
    call get_cursor_stop_coordinates
    call find_cursor_up
    ld b, e
    inc d
    dec d
    ret z
    ldh (<hram.current_cursor), a
    ret
find_cursor_up:
    ld hl, cursor_stops
    ld a, (cursor_mode)
    bit 2, a
    jr z, +
    ld hl, text_cursor_stops
+   ld de, $0000
    xor a, a
    ldh (<hram.temp.1), a
-   inc hl
    ld a, c
    call find_cursor_stop_coordinate
    cp a, $ff
    ldh a, (<hram.temp.2)
    ret z
    dec hl
    ld a, (hl)
    cp a, b
    jr nc, +
    ld a, (hl)
    cp a, e
    jr c, +
    ld e, (hl)
    ld d, $ff
    ldh a, (<hram.temp.1)
    ldh (<hram.temp.2), a
+   ldh a, (<hram.temp.1)
    inc a
    ldh (<hram.temp.1), a
    inc hl
    inc hl
    jr -
move_cursor_left:
    call get_cursor_stop_coordinates
    jr +
wrap_cursor_up:
    ld a, (last_cursor.y)
    ld b, a
+   call find_cursor_left
    ld c, e
    inc d
    dec d
    ret z
    ldh (<hram.current_cursor), a
    ret
find_cursor_left:
    ld hl, cursor_stops
    ld a, (cursor_mode)
    bit 2, a
    jr z, +
    ld hl, text_cursor_stops
+   ld de, $0000
    xor a, a
    ldh (<hram.temp.1), a
-   ld a, b
    call find_cursor_stop_coordinate
    cp a, $ff
    ldh a, (<hram.temp.2)
    ret z
    inc hl
    ld a, (hl)
    cp a, c
    jr nc, +
    ld a, (hl)
    cp a, e
    jr c, +
    ld e, (hl)
    ld d, $ff
    ldh a, (<hram.temp.1)
    ldh (<hram.temp.2), a
+   ldh a, (<hram.temp.1)
    inc a
    ldh (<hram.temp.1), a
    inc hl
    jr -
find_cursor_stop_coordinate:
    push bc
    ld c, a
-   ld a, (hl)
    cp a, $ff
    jr z, +
    cp a, c
    jr z, +
    inc hl
    inc hl
    ldh a, (<hram.temp.1)
    inc a
    ldh (<hram.temp.1), a
    jr -
+   pop bc
    ret
get_cursor_stop_coordinates:
    push de
    ld de, cursor_stops
    ld a, (cursor_mode)
    bit 2, a
    jr z, +
    ld de, text_cursor_stops
+   ldh a, (<hram.current_cursor)
    ld l, a
    ld h, $00
    add hl, hl
    add hl, de
    ld b, (hl)
    inc hl
    ld c, (hl)
    pop de
    ret
set_cursor_coordinates:
    ld hl, hram.cursor.y
    ld (hl), b
    inc hl
    ld (hl), c
    ret
menu_start:
    rst $10
    xor a, a
    ldh (<BGP), a
    ldh (<OBP0), a
    ldh (<OBP1), a
    call load_misc_tiles_with_backup
    call menu_memory_clear_all
    ld (menu_start_saved_sp), sp
_L003:
    call menu_initialize_normal
    ld e, $02
    rst $08
    ld e, $03
    rst $08
    call draw_characters_menu
_L004:
    call x_menu_cursor_stops_clear
    ld a, $05
    call menu_memory_load
    ld e, $01
    rst $08
    xor a, a
    call x_execute_menu_cursor_with_options
    ld a, $05
    call menu_memory_save
    ldh a, (<hram.confirmed_cursor.1)
    cp a, $ff
    jr nz, +
    xor a, a
    ld hl, menu_palette_backup
    ldi (hl), a
    ldi (hl), a
    ld (hl), a
    jp exit_menu
+   call play_confirm_sound
    and a, a
    jr z, _menu_start_abil
    dec a
    jp z, _menu_start_item
    dec a
    jp z, _menu_start_equip
    dec a
    jp z, _menu_start_magi
    dec a
    jp z, _menu_start_memo
_menu_start_save:
    call menu_initialize_blank
    call save_menu
    ldh a, (<hram.confirmed_cursor.1)
    cp a, $ff
    jr z, _L003
    call x_menu_cursor_stops_clear
    ldh a, (<hram.confirmed_cursor.1)
    ld (script_arg_uint8), a
    ld e, $19
    rst $08
    xor a, a
    call x_execute_menu_cursor_with_options
    ldh a, (<hram.confirmed_cursor.1)
    cp a, $ff
    jr z, _menu_start_save
    call play_confirm_sound
    and a, a
    jr nz, _menu_start_save
    ld a, (script_arg_uint8)
    call save_game
    jp _L003
_menu_start_abil:
    call player_select_menu
    jr z, _L004
    call play_confirm_sound
    ld (player_index), a
    call menu_initialize_normal
    ld a, $07
    call menu_memory_clear
-   call clear_window_sprites_and_cursor_stops
    ld e, $07
    rst $08
    ld e, $06
    rst $08
    ld a, $07
    call menu_memory_load
    ld e, $08
    rst $08
    ld a, $01
    call x_execute_menu_cursor_with_options
    ld a, $07
    call menu_memory_save
    ld hl, hram.confirmed_cursor.1
    ldi a, (hl)
    cp a, $ff
    jr z, +
    cp a, (hl)
    jr z, ++
    call play_confirm_sound
    ld b, (hl)
    call get_equipment_slot_address
    ld e, l
    ld d, h
    ld a, b
    call get_equipment_slot_address
    xor a, a
    ldh (<hram.item_swap_flags), a
    ldh (<hram.item_swap_fail), a
    call swap_items
    jr -
++  ldh (<hram.item_index), a
    ld hl, player.1.inventory
    add a, a
    rst $00
    ld a, (player_index)
    call x_add_player_offset
    ld a, (hl)
    cp a, $ff
    call z, play_invalid_sound
    jr z, +
    ld hl, use_item_id
    ldi (hl), a
    ld (hl), $00
    call use_item
    call menu_initialize_normal
    jr -
+   call menu_initialize_normal
    call redraw_start_menu
    jr _menu_start_abil
_menu_start_item:
    ld a, $07
    call menu_memory_clear
_L005:
    call menu_initialize_normal
-   call clear_window_sprites_and_cursor_stops_keep_selection
    ld a, $07
    call menu_memory_load
    ld e, $09
    rst $08
    ld a, $01
    call x_execute_menu_cursor_with_options
    ld a, $07
    call menu_memory_save
    ld hl, hram.confirmed_cursor.1
    ldi a, (hl)
    cp a, $ff
    jp z, _L003
    cp a, (hl)
    jr z, _menu_start_item_use
    call play_confirm_sound
    cp a, $10
    jr z, +
    ld a, (hl)
    cp a, $10
    jr z, ++
    ldh a, (<hram.confirmed_cursor.1)
    call get_inventory_slot_address
    push hl
    ld e, (hl)
    inc hl
    ld d, (hl)
    ldh a, (<hram.confirmed_cursor.2)
    call get_inventory_slot_address
    ld c, (hl)
    inc hl
    ld b, (hl)
    ld (hl), d
    dec hl
    ld (hl), e
    pop hl
    ld (hl), c
    inc hl
    ld (hl), b
    jr -
+   ld a, (hl)
    jr +
++  dec hl
    ld a, (hl)
+   call get_inventory_slot_address
    ld a, $ff
    ldi (hl), a
    ld (hl), a
    jr -
get_inventory_slot_address:
    ld hl, inventory
    add a, a
    rst $00
    ret
_menu_start_item_use:
    ldh (<hram.item_index), a
    call get_inventory_slot_address
    ld a, (hl)
    cp a, $ff
    call z, play_invalid_sound
    jr z, -
    ld hl, use_item_id
    ldi (hl), a
    ld (hl), $00
    ld a, $ff
    ld (player_index), a
    call x_menu_cursor_clear_position
    call use_item
    ldh a, (<hram.confirmed_cursor.1)
    cp a, $ff
    jr z, -
    jp _L005
_menu_start_equip:
    call player_select_menu
    jp z, _L004
    call play_confirm_sound
    ld (player_index), a
    call menu_initialize_normal
    ld a, $07
    call menu_memory_clear
    ld a, $08
    call menu_memory_clear
_L006:
    call clear_window_sprites_and_cursor_stops
    ld e, $07
    rst $08
    ld e, $06
    rst $08
    ld a, $07
    call menu_memory_load
    ld e, $09
    rst $08
-   call x_menu_cursor_stops_clear
    ld a, $08
    call menu_memory_load
    ld e, $08
    rst $08
    xor a, a
    call x_execute_menu_cursor_with_options
    ld a, $08
    call menu_memory_save
    ldh a, (<hram.confirmed_cursor.1)
    cp a, $ff
    jr nz, +
    xor a, a
    ldh (<hram.item_swap_flags), a
    ldh (<hram.item_swap_fail), a
    call menu_initialize_normal
    ld e, $01
    rst $08
    ld e, $02
    rst $08
    ld e, $03
    rst $08
    jr _menu_start_equip
+   call play_confirm_sound
    ld hl, hram.cursor.y
    ld de, hram.cursor0.y
    ld b, $02
    call memcopy
    call x_menu_cursor_stops_clear
    ld a, $07
    call menu_memory_load
    ld e, $09
    rst $08
    xor a, a
    call x_execute_menu_cursor_with_options
    ld a, $07
    call menu_memory_save
    ldh a, (<hram.confirmed_cursor.1)
    cp a, $ff
    jr nz, +
    ld a, $ff
    ld hl, hram.cursor0.y
    ldi (hl), a
    ld (hl), a
    jr -
+   xor a, a
    ldh (<hram.item_swap_flags), a
    ldh (<hram.item_swap_fail), a
    call get_equipment_slot_item_from_menu_memory_8
    ldh (<hram.temp.1), a
    ld de, window_text_buffer
    call get_item_data
    call get_inventory_slot_item_from_menu_memory_7
    ldh (<hram.temp.2), a
    ld de, window_text_buffer+$08
    call get_item_data
    ld a, $07
    call get_menu_memory_address
    ld a, (hl)
    cp a, $10
    jr c, +
    ldh a, (<hram.temp.1)
    inc a
    jp nz, _L008
    call play_confirm_sound
    jp _L006
+   ldh a, (<hram.temp.2)
    inc a
    jr nz, +
    ldh a, (<hram.temp.1)
    inc a
    jp z, _L006
    jp _L008
+   ldh a, (<hram.temp.1)
    inc a
    jr z, +
    ld a, (window_text_buffer)
    bit 2, a
    jr nz, ++
    ld a, (player_index)
    cp a, $04
    jr z, ++
    ld hl, player.1.race
    call x_add_player_offset
    ld a, (hl)
    cp a, $03
    jr z, _L007
    call move_item_slot_to_backup_from_equipment_slot_from_menu_memory_8
    call check_armor_slots
    call move_item_slot_from_backup_to_equipment_slot_from_menu_memory_8
    jr c, ++
_L007:
    call unequip_item
    call move_item_slot_to_backup_from_equipment_slot_from_menu_memory_8
    call equip_item
    call move_item_slot_from_backup_to_equipment_slot_from_menu_memory_8
    call check_and_swap_items
    jp _L006
++  call play_invalid_sound
    jp _L006
move_item_slot_to_backup_from_equipment_slot_from_menu_memory_8:
    call get_equipment_slot_address_from_menu_memory_8
    ld de, item_backup
    ld a, (hl)
    ld (de), a
    ld (hl), $ff
    inc de
    inc hl
    ld a, (hl)
    ld (de), a
    ld (hl), $ff
    ret
move_item_slot_from_backup_to_equipment_slot_from_menu_memory_8:
    push af
    call get_equipment_slot_address_from_menu_memory_8
    ld de, item_backup
    ld a, (de)
    ld (hl), a
    inc de
    inc hl
    ld a, (de)
    ld (hl), a
    pop af
    ret
+   call equip_item
    call check_and_swap_items
    jp _L006
equip_item:
    ld a, (player_index)
    ld hl, player.1.race
    call x_add_player_offset
    ld a, (hl)
    cp a, $02
    jp z, play_invalid_sound
    cp a, $03
    jr z, @equip_item_robot
    ld a, (window_text_buffer+$0a)
    and a, $0f
    jr z, +
    call check_armor_slots
    jp c, play_invalid_sound
    ld a, (player_index)
    ld hl, player.1.def
    call x_add_player_offset
    ld a, (window_text_buffer+$0c)
    add a, (hl)
    ld (hl), a
+   ld a, (player_index)
    ld hl, player.1.str
    call x_add_player_offset
    ld a, (window_text_buffer+$0d)
    ld b, a
    ld a, (window_text_buffer+$0a)
    bit 6, a
    ret z
    ld a, b
    and a, $0f
    ld c, a
    ld e, $04
-   rl b
    jr nc, +
    ld a, c
    add a, (hl)
    ld (hl), a
+   inc hl
    dec e
    jr nz, -
    ret
@equip_item_robot:
    ldh a, (<hram.temp.2)
    ld hl, data_item_robot_stats
    rst $00
    ld a, :data_item_robot_stats
    call read_from_bank
    ldh (<hram.temp.3), a
    and a, $0f
    inc a
    ld l, a
    ld h, $00
    add hl, hl
    add hl, hl
    add hl, hl
    rst $00
    ld e, l
    ld d, h
    ld a, (player_index)
    ld hl, player.1.current_hp
    call x_add_player_offset
    ld b, $02
-   push bc
    push hl
    ldi a, (hl)
    ld h, (hl)
    ld l, a
    add hl, de
    ld c, l
    ld b, h
    pop hl
    ld (hl), c
    inc hl
    ld (hl), b
    inc hl
    pop bc
    dec b
    jr nz, -
    ldh a, (<hram.temp.3)
    ld b, a
    and a, $0f
    inc a
    add a, a
    ld c, a
    ld e, $04
-   rl b
    jr nc, +
    ld a, c
    add a, (hl)
    ld (hl), a
+   inc hl
    ld a, e
    cp a, $03
    jr nz, +
    rl b
    inc hl
    dec e
+   dec e
    jr nz, -
    ld hl, hram.item_swap_flags
    ld a, (hl)
    or a, $01
    ld (hl), a
    ret
_L008:
    ld a, (player_index)
    cp a, $04
    jr z, +
    ld a, (window_text_buffer)
    bit 2, a
    jr nz, +
    call unequip_item
    call check_and_swap_items
    jr ++
+   call play_invalid_sound
++  jp _L006
unequip_item:
    ld a, (player_index)
    ld hl, player.1.race
    call x_add_player_offset
    ld a, (hl)
    cp a, $03
    jr z, @unequip_item_robot
    ld a, (window_text_buffer+$02)
    and a, $0f
    jr z, +
    ld a, (player_index)
    ld hl, player.1.def
    call x_add_player_offset
    ld a, (window_text_buffer+$04)
    ld c, a
    ld a, (hl)
    sub a, c
    ld (hl), a
+   ld a, (player_index)
    ld hl, player.1.str
    call x_add_player_offset
    ld a, (window_text_buffer+$05)
    ld b, a
    ld a, (window_text_buffer+$02)
    bit 6, a
    ret z
    ld a, b
    and a, $0f
    ld c, a
    ld e, $04
-   rl b
    jr nc, +
    ld a, (hl)
    sub a, c
    ld (hl), a
+   inc hl
    dec e
    jr nz, -
    ret
@unequip_item_robot:
    ldh a, (<hram.temp.1)
    ld hl, data_item_robot_stats
    rst $00
    ld a, :data_item_robot_stats
    call read_from_bank
    ldh (<hram.temp.3), a
    and a, $0f
    inc a
    ld l, a
    ld h, $00
    add hl, hl
    add hl, hl
    add hl, hl
    rst $00
    ld e, l
    ld d, h
    ld a, (player_index)
    ld hl, player.1.max_hp+$01
    call x_add_player_offset
    push hl
    ldd a, (hl)
    ld l, (hl)
    ld h, a
    call x_subtract_16_16
    ld c, l
    ld b, h
    pop hl
    ld (hl), b
    dec hl
    ld (hl), c
    dec hl
    ld d, (hl)
    dec hl
    ld e, (hl)
    push hl
    ld l, c
    ld h, b
    call x_compare_16_16
    jr nc, +
    ld e, l
    ld d, h
+   pop hl
    ld (hl), e
    inc hl
    ld (hl), d
    inc hl
    inc hl
    inc hl
    ldh a, (<hram.temp.3)
    ld b, a
    and a, $0f
    inc a
    add a, a
    ld c, a
    ld e, $04
-   rl b
    jr nc, +
    ld a, (hl)
    sub a, c
    ld (hl), a
+   inc hl
    ld a, e
    cp a, $03
    jr nz, +
    rl b
    inc hl
    dec e
+   dec e
    jr nz, -
    ld hl, hram.item_swap_flags
    ld a, (hl)
    or a, $02
    ld (hl), a
    ret
check_and_swap_items:
    ldh a, (<hram.item_swap_fail)
    and a, a
    ret nz
    call play_confirm_sound
    call get_equipment_slot_address_from_menu_memory_8
    ld e, l
    ld d, h
    ld a, $07
    call get_menu_memory_address
    ld a, (hl)
    cp a, $10
    jr c, +
    ld a, $ff
    ld (de), a
    inc de
    ld (de), a
    ret
+   add a, a
    ld hl, inventory
    rst $00
swap_items:
    ldh a, (<hram.item_swap_flags)
    ld b, a
    inc de
    inc hl
    ld a, (de)
    ld c, (hl)
    dec de
    ld a, (de)
    inc de
    call get_item_robot_no_reduce_flag
    ld a, (de)
    jr z, +
    and a, a
    jr nz, ++
    jr _L009
+   bit 1, b
    jr z, ++
    srl a
    jr nz, ++
_L009:
    ld a, b
    or a, $04
    ld b, a
    ld a, $ff
++  ldd (hl), a
    ld a, (hl)
    call get_item_robot_no_reduce_flag
    ld a, c
    jr nz, +
    bit 0, b
    jr z, +
    srl a
+   ld (de), a
    dec de
    ld a, (de)
    ld c, (hl)
    bit 2, b
    jr z, +
    ld a, $ff
+   ld (hl), a
    ld a, c
    ld (de), a
    ret
get_item_robot_no_reduce_flag:
    push de
    push hl
    ld de, data_items+$02
    call read_bank_c_data_8
    bit 7, a
    pop hl
    pop de
    ret
_menu_start_magi:
    call menu_initialize_normal
    call refresh_equipped_magi_1
    xor a, a
    ld (player_index), a
    ld a, $07
    call menu_memory_clear
    ld a, $08
    call menu_memory_clear
-   call magi_menu_start
    xor a, a
    call x_execute_menu_cursor_with_options
    ldh a, (<hram.confirmed_cursor.1)
    cp a, $ff
    jr nz, +
    call set_equipped_magi
    jp _L003
+   call play_confirm_sound
    and a, a
    jr z, _L010
--  call unequipped_magi_box
    xor a, a
    call x_execute_menu_cursor_with_options
    ld a, $07
    call menu_memory_save
    ldh a, (<hram.confirmed_cursor.1)
    cp a, $ff
    jr z, -
    call get_magi_list_value
    cp a, $ff
    call z, play_invalid_sound
    jr z, --
    call play_confirm_sound
    ld hl, use_item_id
    ldi (hl), a
    ld (hl), $01
    call use_item_skip_usage_check
    call menu_initialize_normal
    call magi_menu_start
    jr --
_L010:
    call magi_player_select_box
    call magi_select_player_menu
    ld a, $08
    call menu_memory_save
    ldh a, (<hram.confirmed_cursor.1)
    cp a, $ff
    jr z, -
-   call magi_summary_box
    call unequipped_magi_box
    xor a, a
    call x_execute_menu_cursor_with_options
    ld a, $07
    call menu_memory_save
    ldh a, (<hram.confirmed_cursor.1)
    cp a, $ff
    jr z, _L010
    call play_confirm_sound
    ldh a, (<hram.confirmed_cursor.1)
    call get_magi_list_value
    cp a, $ff
    jr z, +
    ld a, (player_index)
    call get_player_magi_address_1
    ld a, (hl)
    cp a, $ff
    jr z, ++
    ld e, l
    ld d, h
    ldh a, (<hram.confirmed_cursor.1)
    call get_magi_list_address
    ld a, (de)
    ld b, a
    ld a, (hl)
    ld (hl), b
    ld (de), a
    jr -
++  ld e, l
    ld d, h
    ldh a, (<hram.confirmed_cursor.1)
    call get_magi_list_value
    ld (de), a
    ld (hl), $ff
    jr -
+   ld a, (player_index)
    call get_player_magi_address_1
    ld a, (hl)
    cp a, $ff
    call z, play_invalid_sound
    jr z, -
    ld b, a
    ld (hl), $ff
    ldh a, (<hram.confirmed_cursor.1)
    call get_magi_list_address
    ld (hl), b
    jr -
magi_select_player_menu:
    call magi_summary_box
    xor a, a
    ld (cursor_mode), a
    call get_cursor_stop_coordinates
    call set_cursor_coordinates
-   call x_read_buttons
    bit 7, a
    jr nz, @magi_player_forward
    bit 6, a
    jr nz, @magi_player_backward
    bit 5, a
    jr nz, @magi_player_backward
    bit 4, a
    jr nz, @magi_player_forward
    bit 1, a
    jr nz, @magi_player_b
    bit 0, a
    jr nz, @magi_player_a
    jr -
@magi_player_forward:
    ld hl, player_index
    ld a, (hl)
    inc a
    cp a, $04
    jr c, +
    xor a, a
+   ld (hl), a
    ldh (<hram.current_cursor), a
    jr magi_select_player_menu
@magi_player_backward:
    ld hl, player_index
    ld a, (hl)
    dec a
    cp a, $ff
    jr nz, +
    ld a, $03
+   ld (hl), a
    ld a, (hl)
    ldh (<hram.current_cursor), a
    jr magi_select_player_menu
@magi_player_b:
    ld a, $ff
    ldh (<hram.confirmed_cursor.1), a
    ret
@magi_player_a:
    ldh a, (<hram.current_cursor)
    ldh (<hram.confirmed_cursor.1), a
    jp play_confirm_sound
magi_menu_start:
    call x_menu_cursor_clear_position
    call magi_summary_box
    call magi_player_select_box
    call unequipped_magi_box
    xor a, a
    ld (window_scroll_y_offset), a
    call x_menu_cursor_stops_clear
    ld e, $0b
    rst $08
    ret
unequipped_magi_box:
    call x_menu_cursor_stops_clear
    ld a, $07
    call menu_memory_load
    ld e, $0e
    rst $08
    ret
magi_summary_box:
    ld a, $04
    ld (window_sprite_count), a
    xor a, a
    ld (window_scroll_y_offset), a
    ld e, $0c
    rst $08
    ret
magi_player_select_box:
    call x_menu_cursor_stops_clear
    xor a, a
    ld (window_sprite_count), a
    ld (window_scroll_y_offset), a
    ld a, $08
    call menu_memory_load
    ld e, $0d
    rst $08
    ret
get_magi_list_value:
    call get_magi_list_address
    ld a, (hl)
    ret
get_magi_list_address:
    ld hl, script_arg_magi
    rst $00
    ret
_menu_start_memo:
    ld a, $07
    call menu_memory_clear
    call menu_initialize_normal
    ld e, $41
    rst $08
@memo_button:
    call x_menu_cursor_stops_clear_keep_selection
    xor a, a
    ld (script_memo_bank_index), a
    ld a, $07
    call menu_memory_load
    ld e, $42
    rst $08
    xor a, a
    call x_execute_menu_cursor_with_options
    ld a, $07
    call menu_memory_save
    ldh a, (<hram.confirmed_cursor.1)
    cp a, $ff
    jp z, _L003
    call play_confirm_sound
    ld hl, script_arg_inventory
    rst $00
    ld a, (hl)
    ld (script_arg_memo_bank), a
    xor a, a
    ld (window_scroll_y_offset), a
    ld a, (script_arg_memo_bank)
    ld d, a
    ld a, $ff
-   inc a
    cp a, $10
    jr c, +
    xor a, a
+   ld e, a
    call x_test_memo_flag
    ld a, e
    jr z, -
--  ld (script_arg_memo_index), a
    ld e, $44
    rst $08
-   call x_read_buttons
    bit 7, a
    jr nz, @memo_forward
    bit 6, a
    jr nz, @memo_backward
    bit 5, a
    jr nz, @memo_backward
    bit 4, a
    jr nz, @memo_forward
    bit 1, a
    jr nz, @memo_button
    bit 0, a
    jr nz, @memo_button
    jr -
@memo_forward:
    ld a, (script_arg_memo_bank)
    ld d, a
    ld a, (script_arg_memo_index)
-   inc a
    cp a, $10
    jr c, +
    xor a, a
+   ld e, a
    call x_test_memo_flag
    ld a, e
    jr z, -
    jr --
@memo_backward:
    ld a, (script_arg_memo_bank)
    ld d, a
    ld a, (script_arg_memo_index)
-   and a, a
    jr z, +
    dec a
    jr ++
+   ld a, $0f
++  ld e, a
    call x_test_memo_flag
    ld a, e
    jr z, -
    jr --
set_equipped_magi:
    ld hl, magi_list
    ld b, $0e
-   ld a, (hl)
    and a, $0f
    ldi (hl), a
    inc hl
    dec b
    jr nz, -
    ld bc, $0400
-   ld a, c
    call get_player_magi_address_1
    ld a, (hl)
    cp a, $ff
    jr z, +
    call get_magi_list_byte_1_1
    and a, $0f
    ld e, c
    inc e
    swap e
    or a, e
    ld (hl), a
+   inc c
    dec b
    jr nz, -
    ret
get_magi_list_byte_1_1:
    add a, a
    ld hl, magi_list
    rst $00
    ld a, (hl)
    ret
refresh_equipped_magi_1:
    ld b, $00
-   ld a, b
    call get_player_magi_address_1
    ld (hl), $ff
    inc b
    ld a, b
    cp a, $04
    jr c, -
    ld hl, script_arg_magi
    push hl
    ld a, $ff
    ld b, $0e
    call memset
    pop de
    ld hl, magi_list
    ld bc, $0e00
-   ld a, (hl)
    and a, $0f
    jr z, +
    ld a, (hl)
    and a, $f0
    jr z, ++
    swap a
    dec a
    push hl
    call get_player_magi_address_1
    ld (hl), c
    pop hl
    jr +
++  ld a, c
    ld (de), a
    inc de
+   inc hl
    inc hl
    inc c
    dec b
    jr nz, -
    ret
get_player_magi_address_1:
    call scale_a_32x
    ld hl, player.1.magi
    rst $00
    ret
redraw_start_menu:
    ld e, $02
    rst $08
    ld e, $03
    rst $08
    call draw_characters_menu
    call x_menu_cursor_stops_clear
    ld e, $01
    rst $08
    ret
player_select_menu:
    ld a, $06
    call menu_memory_load
    ld de, $0504
    call draw_box_and_guest_box_keep_selection
    xor a, a
    call x_execute_menu_cursor_with_options
    ld a, $06
    call menu_memory_save
    ldh a, (<hram.confirmed_cursor.1)
    cp a, $ff
    ret
use_item:
    call get_item_slot_usage
    and a, a
    jp z, play_invalid_sound
use_item_skip_usage_check:
    ld a, (player_index)
    cp a, $ff
    jr z, +
    ld hl, player.1.status
    call x_add_player_offset
    ld a, (hl)
    and a, $10
    jp nz, play_invalid_sound
+   ld hl, use_item_id
    ldi a, (hl)
    ld h, (hl)
    ld l, a
    ld de, data_items
    call add_de_hl_8_x
    ld a, :data_items
    call read_from_bank
    bit 1, a
    jp z, play_invalid_sound
    call play_confirm_sound
    bit 4, a
    jr z, +
    ld a, $08
    jr ++
+   xor a, a
    ldh (<hram.current_cursor), a
    ld de, $0504
    call draw_box_and_guest_box_keep_selection_and_sprites
    xor a, a
    call x_execute_menu_cursor_with_options
    ldh a, (<hram.confirmed_cursor.1)
    cp a, $ff
    ret z
++  ld (use_item_target), a
    ld b, a
    ld a, (player_index)
    cp a, $ff
    jr nz, +
    ld a, b
+   ld (use_item_source), a
    call x_use_item_helper
    ld a, (use_item_result)
    and a, a
    jr z, _item_result_00_refresh
    dec a
    jr z, _item_result_01_nothing_happened
    dec a
    jr z, _item_result_02_warp
    dec a
    jr z, _item_result_03_tent
    dec a
    jp z, _item_result_04_prism
    dec a
    jr z, _item_result_05_str_up
    dec a
    jr z, _item_result_06_agi_up
    dec a
    jr z, _item_result_07_mana_up
    dec a
    jr z, _item_result_08_hp_up
    ld de, $0255
    xor a, a
    ld hl, menu_palette_backup
    ldi (hl), a
    ldi (hl), a
    ld (hl), a
    push de
    call exit_menu
    pop de
    ld hl, menu_start_saved_sp
    ldi a, (hl)
    ld h, (hl)
    ld l, a
    di
    ld sp, hl
    ei
    jp xr_execute_script
_item_result_08_hp_up:
    ld e, $3a
    jr +
_item_result_07_mana_up:
    ld e, $3b
    jr +
_item_result_06_agi_up:
    ld e, $3c
    jr +
_item_result_05_str_up:
    ld e, $3d
+   rst $08
    call reduce_item_usage
    jp wait_for_button
_item_result_00_refresh:
    call reduce_item_usage
    ld hl, window_sprite_count
    ld a, (hl)
    sub a, $04
    jr nc, +
    xor a, a
+   ld (hl), a
    ld de, $0504
    call draw_box_and_guest_box_keep_selection_and_sprites
    jp wait_for_button
_item_result_01_nothing_happened:
    ld e, $0a
    rst $08
    jp wait_for_button
_item_result_03_tent:
    call reduce_item_usage
    jp restore_party
_item_result_02_warp:
    ld a, (teleport_disable)
    and a, a
    jp nz, play_invalid_sound
    call menu_initialize_normal
    ld e, $2e
    rst $08
    ld e, $2f
    rst $08
    xor a, a
    call x_execute_menu_cursor_with_options
    ldh a, (<hram.confirmed_cursor.1)
    cp a, $ff
    ret z
    call reduce_item_usage
    ld e, $1d
    xor a, a
    call x_set_script_var
    inc e
    xor a, a
    call x_set_script_var
    ldh a, (<hram.confirmed_cursor.1)
    add a, $60
    ld e, a
    ld d, $00
    ld a, $d2
    ld hl, menu_palette_backup
    ldi (hl), a
    ldi (hl), a
    ld (hl), a
    push de
    call clear_palettes
    call x_far_call
    .addr x_restore_map_sprite_gfx
    .db $01
    call exit_menu
    pop de
    ld hl, menu_start_saved_sp
    ldi a, (hl)
    ld h, (hl)
    ld l, a
    di
    ld sp, hl
    ei
    jp xr_execute_script
_item_result_04_prism:
    call menu_initialize_normal
    ld e, $3f
    rst $08
    ld e, $3e
    rst $08
    ld e, $0e
    call x_get_script_var
    ld hl, data_prism
    rst $00
    ld a, :data_prism
    call read_from_bank
    ld hl, magi_total
    sub a, (hl)
    jr nc, +
    xor a, a
+   ld hl, script_arg_uint8
    ld (hl), $00
    inc hl
    ldd (hl), a
-   push hl
    ld a, $02
    ld e, $40
    call x_execute_box_script_with_options
    pop hl
    ldi a, (hl)
    cp a, (hl)
    jp z, wait_for_button
    dec hl
    inc (hl)
    jr -
reduce_item_usage:
    ld a, (use_item_id+1)
    and a, a
    ret nz
    call get_item_slot_usage
    cp a, $fe
    ret z
    dec (hl)
    ret nz
    ld a, (player_index)
    cp a, $ff
    jr z, +
    push hl
    ld hl, player.1.race
    call x_add_player_offset
    ld a, (hl)
    pop hl
    and a, a
    jr z, +
    dec a
    jr z, ++
    ret
++  dec hl
    ld a, (hl)
    cp a, $80
    ret nc
    inc hl
+   ld a, $ff
    ldd (hl), a
    ld (hl), a
    ret
get_item_slot_usage:
    ld hl, inventory+$01
    ld a, (player_index)
    cp a, $ff
    jr z, +
    ld hl, player.1.inventory+$01
    call x_add_player_offset
+   ldh a, (<hram.item_index)
    add a, a
    rst $00
    ld a, (hl)
    ret
get_equipment_slot_item_from_menu_memory_8:
    call get_equipment_slot_address_from_menu_memory_8
    ld a, (hl)
    ret
get_equipment_slot_address_from_menu_memory_8:
    ld a, $08
    call get_menu_memory_address
    ld a, (hl)
get_equipment_slot_address:
    add a, a
    ld hl, player.1.inventory
    rst $00
    ld a, (player_index)
    jp x_add_player_offset
get_inventory_slot_item_from_menu_memory_7:
    call get_inventory_slot_address_from_menu_memory_7
    ld a, (hl)
    ret
get_inventory_slot_address_from_menu_memory_7:
    ld a, $07
    call get_menu_memory_address
    ld a, (hl)
    add a, a
    ld hl, inventory
    rst $00
    ret
_unused:
    ld c, a
    ld a, (player_index)
    ld hl, player.1.str
    call x_add_player_offset
    push hl
    ld de, data_items+$05
    ld a, c
    call read_bank_c_data_8
    ld b, a
    ld de, data_items+$02
    ld a, c
    call read_bank_c_data_8
    pop hl
    ret
read_bank_c_data_8:
    ld l, a
    ld h, $00
    call add_de_hl_8_x
    ld a, :data_items
    jp read_from_bank
get_item_data:
    ld h, $00
    ld l, a
    ld bc, data_items
    call add_bc_hl_8_x
    ld a, :data_items
    ld b, $08
    jp memcopy_from_bank
check_armor_slots:
    ld a, (window_text_buffer+$0a)
    and a, $0f
    ret z
    ld c, a
    ld hl, player.1.inventory
    ld a, (player_index)
    call x_add_player_offset
    ld b, $08
    ld e, $00
-   push hl
    ld a, (hl)
    inc a
    jr z, +
    ld l, (hl)
    ld h, $00
    push bc
    ld bc, data_items+$02
    call add_bc_hl_8_x
    pop bc
    ld a, :data_items
    call read_from_bank
    and a, c
    jr z, +
    inc e
+   pop hl
    inc hl
    inc hl
    dec b
    jr nz, -
    ld a, e
    and a, a
    ret z
    scf
    ret
menu_initialize_blank:
    xor a, a
    ldh (<hram.window_sprite_mode), a
    call clear_palettes
    call clear_window_sprites_cursor_stops_and_scroll_1
    rst $10
    ld a, >oam_staging_cc
    rst $18
    call menu_initialize_gb_win
    ld a, $03
    ldh (<hram.window_sprite_mode), a
    ret
menu_initialize_normal:
    xor a, a
    ldh (<hram.window_sprite_mode), a
    call clear_window_sprites_cursor_stops_and_scroll_1
    rst $10
    ld a, >oam_staging_cc
    rst $18
    call clear_gb_win_light_gray
    call menu_initialize_gb_win
    call set_palettes_standard
    ld a, $03
    ldh (<hram.window_sprite_mode), a
    ret
clear_window_sprites_and_cursor_stops:
    call clear_window_sprites_and_cursor_position
    jp x_menu_cursor_stops_clear
clear_window_sprites_and_cursor_stops_keep_selection:
    call clear_window_sprites_and_cursor_position
    jp x_menu_cursor_stops_clear_keep_selection
clear_window_sprites_cursor_stops_and_scroll_1:
    xor a, a
    ld (window_scroll_y_offset), a
clear_window_sprites_cursor_stops_and_scroll_2:
    call clear_window_sprites_and_cursor_position
    ld hl, window_scroll_x_offset
    ldi (hl), a
    ld (hl), a
    jp x_menu_cursor_stops_clear
clear_window_sprites_and_cursor_position:
    call x_menu_cursor_clear_position
clear_window_sprites:
    ld hl, window_sprites
    ld b, $20
    call memclear
    ld hl, oam_staging_cc
    ld b, $a0
    call memclear
    ld (window_sprite_count), a
    ld (script_memo_bank_index), a
    ret
menu_memory_clear_all:
    ld hl, menu_memory+$0a
    ld b, $0a
    jp memclear
draw_characters_menu:
    ld de, $0504
draw_box_and_guest_box:
    xor a, a
    ldh (<hram.current_cursor), a
draw_box_and_guest_box_keep_selection:
    xor a, a
    ld (window_sprite_count), a
draw_box_and_guest_box_keep_selection_and_sprites:
    call x_menu_cursor_stops_clear_keep_selection
    rst $08
    call x_test_script_var_0
    ret z
    ld e, d
    rst $08
    ret
load_misc_tiles_with_backup:
    ld a, (hram.battle_flag)
    and a, a
    jr nz, load_misc_tiles
    ld hl, $9600
    ld de, $9e40
    ld bc, $01c0
    call vram_memcopy_16
    ld de, $9c14
    ld c, $08
    call x_vram_enable
-   ld b, $08
    call memcopy
    ld a, e
    add a, $18
    ld e, a
    jr nc, +
    inc d
+   dec c
    jr nz, -
    call x_vram_disable
load_misc_tiles:
    ld hl, data_font_extension
    ld de, $9700
    ld bc, $0100
    ld a, :data_font_extension
    jp vram_memcopy_16_from_bank
exit_menu:
    call x_wait_for_release
exit_menu_now:
    rst $10
    ld a, >oam_staging_c0
    rst $18
    xor a, a
    ldh (<BGP), a
    ldh (<OBP0), a
    ldh (<OBP1), a
    call load_backup_tiles
    xor a, a
    ldh (<hram.window_sprite_mode), a
    call clear_window_sprites_cursor_stops_and_scroll_2
    rst $10
    ldh a, (<LCDC)
    and a, $df
    ldh (<LCDC), a
    ld hl, menu_palette_backup
    ldi a, (hl)
    ldh (<BGP), a
    ldi a, (hl)
    ldh (<OBP0), a
    ldi a, (hl)
    ldh (<OBP1), a
    ret
load_backup_tiles:
    ld hl, $9e40
    ld de, $9600
    ld bc, $01c0
    call vram_memcopy_16
    ld hl, $9c14
    ld c, $08
    call x_vram_enable
-   ld b, $08
    call memcopy
    ld a, $18
    rst $00
    dec c
    jr nz, -
    jp x_vram_disable
play_invalid_sound:
    push af
    ld a, $13
    ldh (<hram.audio.sfx), a
    ldh (<hram.item_swap_fail), a
    pop af
    ret
play_confirm_sound:
    push af
    ld a, $37
    ldh (<hram.audio.sfx), a
    pop af
    ret
set_palettes_standard:
    rst $10
    ld hl, menu_palette_backup
    ld a, $d2
    ldh (<BGP), a
    ldi (hl), a
    ld a, $d2
    ldh (<OBP0), a
    ldi (hl), a
    ld a, $81
    ldh (<OBP1), a
    ldi (hl), a
    ret
clear_palettes:
    rst $10
    xor a, a
    ldh (<BGP), a
    ldh (<OBP0), a
    ldh (<OBP1), a
    ret
clear_gb_win_light_gray:
    ld e, $75
    ld hl, $9c00
    ld c, $12
    call x_vram_enable
-   ld b, $14
    ld a, e
    call memset
    ld a, $0c
    rst $00
    dec c
    jr nz, -
    jp x_vram_disable
menu_initialize_gb_win:
    rst $10
    xor a, a
    ldh (<WY), a
    ld a, $07
    ldh (<WX), a
    ld a, $e3
    ldh (<LCDC), a
    ret
menu_party_order:
    rst $10
    xor a, a
    ldh (<BGP), a
    ldh (<OBP0), a
    ldh (<OBP1), a
    call load_misc_tiles_with_backup
    call menu_initialize_normal
    call refresh_equipped_magi_2
_L011:
    call clear_window_sprites_and_cursor_stops
    ld de, $1110
    call draw_box_and_guest_box
    ld a, $01
    call x_execute_menu_cursor_with_options
    ld hl, hram.confirmed_cursor.1
    ldi a, (hl)
    cp a, $ff
    jr nz, +
    call refresh_magi_list
    xor a, a
    ld hl, menu_palette_backup
    ldi (hl), a
    ldi (hl), a
    ld (hl), a
    jp exit_menu
+   ld c, (hl)
    cp a, c
    jr c, +
    jr z, _L011
    ldd (hl), a
    ld (hl), c
+   ldh a, (<hram.confirmed_cursor.1)
    ld hl, player.1.status
    call x_add_player_offset
    ld a, (hl)
    and a, $90
    jr nz, _L011
    ldh a, (<hram.confirmed_cursor.2)
    ld hl, player.1.status
    call x_add_player_offset
    ld a, (hl)
    and a, $90
    call nz, play_invalid_sound
    jr nz, _L011
    call play_confirm_sound
    xor a, a
    call get_window_sprite_position
    ld e, b
    ld a, $01
    call get_window_sprite_position
    ld a, b
    sub a, e
    ldh (<hram.temp.1), a
    call x_menu_cursor_clear_position
    ld e, $10
-   xor a, a
    call get_window_sprite_position
    dec c
    call set_window_sprite_position
    inc a
    call get_window_sprite_position
    inc c
    call set_window_sprite_position
    call wait_for_1_frame
    dec e
    jr nz, -
    ldh a, (<hram.temp.1)
    ld e, a
-   xor a, a
    call get_window_sprite_position
    inc b
    call set_window_sprite_position
    inc a
    call get_window_sprite_position
    dec b
    call set_window_sprite_position
    call wait_for_1_frame
    dec e
    jr nz, -
    ld e, $10
-   xor a, a
    call get_window_sprite_position
    inc c
    call set_window_sprite_position
    inc a
    call get_window_sprite_position
    dec c
    call set_window_sprite_position
    call wait_for_1_frame
    dec e
    jr nz, -
    ld hl, hram.confirmed_cursor.1
    ld b, (hl)
    ld c, b
    call get_party_order
    ld d, a
    inc hl
    ld b, (hl)
    call get_party_order
    ld e, a
    ld a, d
    call set_party_order
    ld b, c
    ld a, e
    call set_party_order
    jp _L011
wait_for_1_frame:
    push bc
    ld b, $01
-   rst $10
    ld a, >oam_staging_cc
    rst $18
    dec b
    jr nz, -
    pop bc
    ret
get_party_order:
    push bc
    inc b
    ld a, (party_order)
    rlca
    rlca
-   rrca
    rrca
    dec b
    jr nz, -
    and a, $03
    pop bc
    ret
set_party_order:
    push bc
    inc b
    ld c, $3f
    rrca
    rrca
-   rlca
    rlca
    rlc c
    rlc c
    dec b
    jr nz, -
    ld b, a
    ld a, (party_order)
    and a, c
    or a, b
    ld (party_order), a
    pop bc
    ret
get_window_sprite_position:
    push af
    push hl
    call get_window_sprite_y_address
    ld b, (hl)
    inc hl
    ld c, (hl)
    pop hl
    pop af
    ret
set_window_sprite_position:
    push af
    push hl
    call get_window_sprite_y_address
    ld (hl), b
    inc hl
    ld (hl), c
    pop hl
    pop af
    ret
get_window_sprite_y_address:
    ld hl, hram.confirmed_cursor.1
    rst $00
    ld a, (hl)
    add a, a
    add a, a
    ld hl, window_sprites+$02
    rst $00
    ret
refresh_magi_list:
    ld hl, magi_list
    ld b, $0e
-   ld a, (hl)
    and a, $0f
    ldi (hl), a
    inc hl
    dec b
    jr nz, -
    ld bc, $0400
-   ld a, c
    call get_player_magi_address_2
    ld a, (hl)
    cp a, $ff
    jr z, +
    call get_magi_list_byte_1_2
    and a, $0f
    ld e, c
    inc e
    swap e
    or a, e
    ld (hl), a
+   inc c
    dec b
    jr nz, -
    ret
get_magi_list_byte_1_2:
    add a, a
    ld hl, magi_list
    rst $00
    ld a, (hl)
    ret
refresh_equipped_magi_2:
    ld b, $00
-   ld a, b
    call get_player_magi_address_2
    ld (hl), $ff
    inc b
    ld a, b
    cp a, $04
    jr c, -
    ld hl, magi_list
    ld de, script_arg_magi
    ld bc, $0e00
-   ld a, (hl)
    and a, $0f
    jr z, +
    ld a, (hl)
    and a, $f0
    jr nz, ++
    ld a, c
    jr _L012
++  swap a
    dec a
    push hl
    call get_player_magi_address_2
    ld (hl), c
    pop hl
+   ld a, $ff
_L012:
    ld (de), a
    inc de
    inc hl
    inc hl
    inc c
    dec b
    jr nz, -
    ret
get_player_magi_address_2:
    ld hl, player.1.magi
    jp x_add_player_offset
menu_party_select:
    call clear_palettes
    call load_misc_tiles_with_backup
    ld a, $01
--  ld (player_index), a
-   call menu_character_select
    jr nc, +
_L013:
    call menu_name_select
    jr nc, -
    ld a, (player_index)
    inc a
    cp a, $04
    jr c, --
    ld hl, menu_palette_backup
    xor a, a
    ldi (hl), a
    ldi (hl), a
    ld (hl), a
    jp exit_menu_now
+   ld a, (player_index)
    cp a, $02
    jr c, -
    dec a
    ld (player_index), a
    jr _L013
menu_character_select:
    call menu_initialize_blank
    ld a, (player_index)
    ld hl, player.1.inventory
    call x_add_player_offset
    ld a, $ff
    ld b, $10
    call memset
    ld hl, script_arg_monster
    ld b, $08
    ld a, $f0
-   ldi (hl), a
    inc a
    dec b
    jr nz, -
    ld e, $15
    rst $08
    call set_palettes_standard
    xor a, a
    call x_execute_menu_cursor_with_options
    ldh a, (<hram.confirmed_cursor.1)
    cp a, $ff
    ret z
    call play_confirm_sound
    ld hl, script_arg_monster
    rst $00
    ld a, (hl)
    call x_load_player
    scf
    ret
menu_name_select:
    ld a, (player_index)
    ld hl, player.1.name
    call x_add_player_offset
    ld de, name_buffer
    ld b, $04
    call memcopy
    call menu_initialize_blank
    ld e, $2c
    rst $08
    ld e, $2d
    ld a, $02
    call x_execute_box_script_with_options
    ld hl, text_cursor_data
    ld b, $00
    call memclear
    ld (text_cursor_temp), a
    ld hl, text_cursor_stops
    ld bc, $0170
    ld a, $ff
    call memset_16
    ld hl, $8080
    ld b, $40
    xor a, a
    call vram_memset
    ld hl, name_cursor_gfx
    ld de, $80a0
    ld b, $10
    call vram_memcopy
    ld hl, window_sprites+$04
    ld a, $a1
    ldi (hl), a
    xor a, a
    ldi (hl), a
    ld (hl), $08
    inc hl
    ld (hl), $68
    ld e, $00
    rst $08
    xor a, a
    ld (text_cursor_temp), a
    call set_palettes_standard
_L014:
    ld hl, window_sprites+$04
    ld a, (text_cursor_temp)
    cp a, $04
    jr c, +
    res 7, (hl)
    jr ++
+   set 7, (hl)
    add a, $0d
    add a, a
    add a, a
    add a, a
    ld hl, window_sprites+$07
    ld (hl), a
++  call execute_text_entry_cursor
    ldh a, (<hram.confirmed_cursor.1)
    cp a, $fe
    jp z, _L016
    cp a, $fd
    jr z, +
    cp a, $ff
    jr nz, ++
    ld hl, text_cursor_temp
    ld a, (hl)
    and a, a
    jr z, _L015
    dec (hl)
    jr _L014
_L015:
    ld a, (player_index)
    ld hl, player.1.name
    call x_add_player_offset
    ld e, l
    ld d, h
    ld hl, name_buffer
    ld b, $04
    call memcopy
    and a, a
    ret
+   ld hl, text_cursor_temp
    ld a, (hl)
    cp a, $04
    jr z, _L016
    inc (hl)
    jp _L014
++  ld hl, text_cursor_data
    rst $00
    ld e, l
    ld d, h
    ld bc, text_cursor_temp
    ld a, (bc)
    cp a, $04
    jr z, _L016
    ld hl, player.1.name
    rst $00
    inc a
    ld (bc), a
    ld a, (player_index)
    call x_add_player_offset
    ld a, (de)
    ld (hl), a
    ld hl, hram.script_mode
    ld de, name_entry_script_stack_frame_backup
    ld b, $04
    call memcopy
    ld hl, script_stack_pointer
    ld b, $8c
    call memcopy
    ld hl, window_scroll_x_offset
    xor a, a
    ldi (hl), a
    ld (hl), a
    ld e, $2d
    ld a, $02
    call x_execute_box_script_with_options
    ld hl, name_entry_script_stack_frame_backup
    ld de, hram.script_mode
    ld b, $04
    call memcopy
    ld de, script_stack_pointer
    ld b, $8c
    call memcopy
    jp _L014
_L016:
    ld a, (player_index)
    ld hl, player.1.name
    call x_add_player_offset
    ld a, $ff
    and a, (hl)
    inc hl
    and a, (hl)
    inc hl
    and a, (hl)
    inc hl
    and a, (hl)
    cp a, $ff
    scf
    ret nz
    call play_invalid_sound
    jp _L014
name_cursor_gfx:
    .db $00
    .db $ff
    .db $00
    .db $ff
    .db $00
    .db $ff
    .db $00
    .db $ff
    .db $00
    .db $ff
    .db $00
    .db $ff
    .db $00
    .db $ff
    .db $00
    .db $ff
menu_inn:
    rst $10
    xor a, a
    ldh (<BGP), a
    ldh (<OBP0), a
    ldh (<OBP1), a
    call load_misc_tiles_with_backup
    call menu_initialize_normal
    ld de, $1c1b
    call draw_box_and_guest_box
    ld e, $1a
    rst $08
    ld e, $1d
    rst $08
    xor a, a
    ld hl, script_arg_uint24
    ldi (hl), a
    ldi (hl), a
    ld (hl), a
    ld hl, player.1.current_hp
    ld b, $04
-   call inn_cost_helper
    dec b
    jr nz, -
    call x_test_script_var_0
    call nz, inn_cost_helper
    ld e, $1e
    rst $08
    xor a, a
    call x_execute_menu_cursor_with_options
    ld e, $2a
    ldh a, (<hram.confirmed_cursor.1)
    cp a, $ff
    jr z, +
    and a, a
    call nz, play_confirm_sound
    jr nz, +
    ld de, gp
    ld hl, script_arg_uint24
    call x_compare_24_24
    jr c, ++
    call x_subtract_24_24
    ld a, $33
    ldh (<hram.audio.sfx), a
    call restore_party
    call clear_window_sprites_cursor_stops_and_scroll_2
    ld de, $1c1b
    call draw_box_and_guest_box
    ld e, $1d
    rst $08
    ld e, $29
    jr +
++  call play_invalid_sound
    ld e, $1f
+   call x_menu_cursor_clear_position
    rst $08
    call x_wait_for_release
-   call x_read_buttons
    and a, a
    jr z, -
    jp exit_menu
inn_cost_helper:
    push hl
    dec hl
    ldi a, (hl)
    and a, $90
    jr nz, +
    ld e, (hl)
    inc hl
    ld d, (hl)
    inc hl
    ldi a, (hl)
    ld h, (hl)
    ld l, a
    call x_subtract_16_16
    ld a, (script_arg_uint24)
    ld e, a
    ld a, (script_arg_uint24+$01)
    ld d, a
    add hl, de
    ld a, l
    ld (script_arg_uint24), a
    ld a, h
    ld (script_arg_uint24+$01), a
+   pop hl
    ld a, $20
    rst $00
    ret
restore_party:
    ld a, (player_index)
    push af
    xor a, a
-   call restore_single
    inc a
    cp a, $04
    jr c, -
    call x_test_script_var_0
    jr z, +
    call restore_single
+   ld bc, $0e00
    ld hl, magi_list
-   push hl
    ldi a, (hl)
    and a, $0f
    jr z, +
    ld e, l
    ld d, h
    ld hl, data_item_usage+$100
    ld a, c
    rst $00
    ld a, :data_item_usage
    call read_from_bank
    ld (de), a
+   pop hl
    inc hl
    inc hl
    inc c
    dec b
    jr nz, -
    pop af
    ld (player_index), a
    ret
restore_single:
    ld (player_index), a
    ld hl, player.1.status
    call x_add_player_offset
    ldi a, (hl)
    and a, $90
    jp nz, @restore_finished
    inc hl
    inc hl
    inc hl
    ldd a, (hl)
    ld c, (hl)
    dec hl
    ldd (hl), a
    ld (hl), c
    dec hl
    dec hl
    ld a, (hl)
    ld de, $000a
    add hl, de
    and a, a
    jp z, @restore_finished
    dec a
    jr z, @restore_mutant
    dec a
    jr z, @restore_monster
    ld b, $08
-   push bc
    push hl
    ld a, (hl)
    cp a, $ff
    jr z, +
    call get_item_robot_no_reduce_flag
    ldi a, (hl)
    jr nz, +
    call get_item_usage
    srl a
    ld (hl), a
+   pop hl
    pop bc
    inc hl
    inc hl
    dec b
    jr nz, -
    jp @restore_finished
@restore_mutant:
    ld b, $08
-   push bc
    push hl
    ldi a, (hl)
    cp a, $ff
    jr z, +
    cp a, $80
    jr c, +
    call get_item_usage
    ld (hl), a
+   pop hl
    pop bc
    inc hl
    inc hl
    dec b
    jr nz, -
    jr @restore_finished
@restore_monster:
    ld hl, window_text_buffer
    ld b, $10
    ld a, $ff
    call memset
    ld a, (player_index)
    ld hl, player.1.monster_id
    call x_add_player_offset
    ld l, (hl)
    ld h, $0a
    call x_multiply_8_8
    ld de, data_monsters
    add hl, de
    ld a, :data_monsters
    call read_from_bank
    ld c, a
    ld a, $08
    rst $00
    ld a, :data_monsters
    call read_from_bank
    ld e, a
    inc hl
    ld a, :data_monsters
    call read_from_bank
    ld h, a
    ld l, e
    ld de, window_text_buffer
    ld a, c
    and a, $07
    inc a
    ld b, a
    ldh (<hram.temp.2), a
    ld a, :data_monster_inventories
    call memcopy_from_bank
    ld hl, window_text_buffer
    ldh a, (<hram.temp.2)
    ld b, a
--  ldi a, (hl)
    push hl
    push af
    ld hl, player.1.inventory
    ld a, (player_index)
    call x_add_player_offset
    pop af
    ld c, $08
-   cp a, (hl)
    jr z, +
    inc hl
    inc hl
    dec c
    jr nz, -
+   inc hl
    call get_item_usage
    ld (hl), a
    pop hl
    dec b
    jr nz, --
@restore_finished:
    ld a, (player_index)
    ret
get_item_usage:
    push de
    push hl
    ld hl, data_item_usage
    rst $00
    ld a, :data_item_usage
    call read_from_bank
    pop hl
    pop de
    ret
heal_party:
    xor a, a
-   call heal_player
    inc a
    cp a, $04
    jr c, -
    call x_test_script_var_0
    ret z
heal_player:
    push af
    ld hl, player.1.status
    call x_add_player_offset
    ldi a, (hl)
    and a, $90
    jr nz, +
    inc hl
    inc hl
    inc hl
    ld d, (hl)
    dec hl
    ld e, (hl)
    dec hl
    push hl
    ldd a, (hl)
    ld l, (hl)
    ld h, a
    add hl, bc
    call x_compare_16_16
    jr nc, ++
    ld e, l
    ld d, h
++  pop hl
    ld (hl), d
    dec hl
    ld (hl), e
+   pop af
    ret
menu_shop:
    ld a, e
    inc a
    jp z, menu_inn
    ld a, e
    add a, a
    add a, a
    add a, a
    ld hl, data_shops
    rst $00
    ld a, :data_shops
    ld b, $08
    ld de, window_text_buffer
    push de
    call memcopy_from_bank
    pop hl
    ld de, script_arg_inventory
    ld b, $08
-   push bc
    ldi a, (hl)
    ld (de), a
    inc de
    push hl
    ld hl, data_item_usage
    rst $00
    ld a, :data_item_usage
    call read_from_bank
    pop hl
    ld (de), a
    inc de
    pop bc
    dec b
    jr nz, -
    ld hl, script_arg_inventory
    ld de, script_arg_uint24
    ld b, $08
-   ldi a, (hl)
    inc hl
    call item_price
    dec b
    jr nz, -
    rst $10
    xor a, a
    ldh (<BGP), a
    ldh (<OBP0), a
    ldh (<OBP1), a
    call load_misc_tiles_with_backup
    call menu_memory_clear_all
    xor a, a
    ldh (<hram.current_cursor), a
    inc a
    ld (window_scroll_y_offset), a
    ld a, $05
    call menu_memory_save
@shop_again_init:
    call menu_initialize_normal
@shop_again:
    call clear_window_sprites_cursor_stops_and_scroll_2
    ld e, $21
    rst $08
    ld e, $22
    rst $08
    ld e, $20
    rst $08
    xor a, a
    call x_execute_menu_cursor_with_options
    ldh a, (<hram.confirmed_cursor.1)
    cp a, $ff
    jr z, +
    call play_confirm_sound
    and a, a
    jr z, @shop_buy
    dec a
    jp z, @shop_sell
+   jp @shop_exit
@shop_buy:
    call clear_window_sprites_cursor_stops_and_scroll_2
    ld a, $05
    call menu_memory_load
    ld e, $23
    rst $08
    ld de, script_arg_inventory
    ld hl, cursor_stops
    ld bc, $0800
-   ld a, (de)
    cp a, $ff
    jr z, @shop_empty_fill
    inc de
    inc de
    inc hl
    inc hl
    inc c
    dec b
    jr nz, -
    jr +
@shop_empty_fill:
    ldi (hl), a
    ldi (hl), a
    dec b
    jr nz, @shop_empty_fill
+   ld a, c
    ld (cursor_stop_count), a
    xor a, a
    call x_execute_menu_cursor_with_options
    ld a, $05
    call menu_memory_save
    ldh a, (<hram.confirmed_cursor.1)
    cp a, $ff
    jr z, @shop_again
    add a, a
    ld hl, script_arg_inventory+$01
    rst $00
    ldd a, (hl)
    ld (script_arg_inventory+$1f), a
    ld a, (hl)
    ld (script_arg_inventory+$1e), a
    ld c, a
    call _get_empty_inventory_slot
    jr c, +
    ld a, c
    ld de, temp_24bit
    push de
    call item_price
    pop hl
    ld de, gp
    call x_compare_24_24
    jr c, ++
    call x_subtract_24_24
    call _get_empty_inventory_slot
    ld de, script_arg_inventory+$1e
    ld a, (de)
    inc de
    ldi (hl), a
    ld a, (de)
    ld (hl), a
    ld a, $22
    ldh (<hram.audio.sfx), a
    call clear_window_sprites_cursor_stops_and_scroll_2
    ld e, $24
    rst $08
    ld e, $21
    rst $08
    call wait_for_button
    jp @shop_again
+   call play_invalid_sound
    call clear_window_sprites_cursor_stops_and_scroll_2
    ld e, $2b
    rst $08
    call wait_for_button
    jp @shop_again
++  call play_invalid_sound
    ld de, script_arg_uint24+$1b
    ld b, $03
    call memcopy
    call clear_window_sprites_cursor_stops_and_scroll_2
    ld e, $25
    rst $08
    call wait_for_button
    jp @shop_again
@shop_sell:
    call clear_window_sprites_cursor_stops_and_scroll_2
    ld e, $27
    rst $08
    ld a, $06
    call menu_memory_load
    ld e, $26
    rst $08
-   ld a, $06
    call menu_memory_load
    xor a, a
    call x_execute_menu_cursor_with_options
    ld a, $06
    call menu_memory_save
    ldh a, (<hram.confirmed_cursor.1)
    cp a, $ff
    jp z, @shop_again_init
    ld (script_arg_uint8), a
    add a, a
    ld hl, inventory
    rst $00
    ldi a, (hl)
    cp a, $ff
    call z, play_invalid_sound
    jr z, -
    call play_confirm_sound
    ldd a, (hl)
    ld (script_arg_inventory+$1f), a
    ld a, (hl)
    ld (script_arg_inventory+$1e), a
    ld de, script_arg_uint24+$1b
    push de
    call item_price
    pop de
    ld a, (script_arg_inventory+$1e)
    ld hl, data_item_usage
    rst $00
    ld a, :data_item_usage
    call read_from_bank
    ldh (<hram.temp.3), a
    ld b, a
    ld a, (script_arg_inventory+$1f)
    cp a, b
    jr z, +
    ldh a, (<hram.temp.3)
    call x_divide_24_8
    ld a, (script_arg_inventory+$1f)
    call x_multiply_24_8
+   ld a, $02
    call x_divide_24_8
    ld l, e
    ld h, d
    push hl
    ldi a, (hl)
    or a, (hl)
    inc hl
    or a, (hl)
    pop hl
    jr nz, +
    ld (hl), $01
+   call clear_window_sprites_cursor_stops_and_scroll_2
    ld e, $28
    rst $08
    xor a, a
    call x_execute_menu_cursor_with_options
    ldh a, (<hram.confirmed_cursor.1)
    cp a, $ff
    jp z, @shop_sell
    call play_confirm_sound
    and a, a
    jp nz, @shop_sell
    ld de, gp
    ld hl, script_arg_uint24+$1b
    call x_add_24_24
    ld a, (script_arg_uint8)
    add a, a
    ld hl, inventory
    rst $00
    ld a, $ff
    ldi (hl), a
    ld (hl), a
    jp @shop_sell
@shop_exit:
    jp exit_menu
wait_for_button:
    call x_wait_for_release
-   call x_read_buttons
    and a, a
    jr z, -
    ret
_get_empty_inventory_slot:
    ld b, $10
    ld hl, inventory
-   ld a, (hl)
    inc a
    jr z, +
    inc hl
    inc hl
    dec b
    jr nz, -
    scf
    ret
+   and a, a
    ret
item_price:
    push af
    push bc
    push hl
    cp a, $ff
    jr nz, +
    ld (de), a
    inc de
    ld (de), a
    inc de
    ld (de), a
    inc de
    jr ++
+   ld l, a
    ld h, $00
    add hl, hl
    rst $00
    ld bc, data_prices
    add hl, bc
    ld b, $03
    ld a, :data_prices
    call memcopy_from_bank
++  pop hl
    pop bc
    pop af
    ret
save_menu:
    call x_sram_enable
    ld hl, $c200
    ld de, sram.backup
    ld bc, $0180
    call memcopy_16
    call x_sram_disable
    xor a, a
    ldh (<hram.window_sprite_mode), a
    call clear_window_sprites_cursor_stops_and_scroll_2
    xor a, a
-   call draw_save_menu
    ld a, (script_arg_uint8+$01)
    inc a
    cp a, $03
    jr c, -
    call clear_window_sprites_cursor_stops_and_scroll_2
    ld a, $03
    ldh (<hram.window_sprite_mode), a
    rst $10
    ld a, >oam_staging_cc
    rst $18
    call set_palettes_standard
--  ldh a, (<hram.current_cursor)
    add a, a
    ld hl, save_offsets
    rst $00
    ldi a, (hl)
    ldh (<hram.cursor.y), a
    ld a, (hl)
    ldh (<hram.cursor.x), a
    ldh a, (<hram.current_cursor)
    call draw_save_menu
-   call x_read_buttons
    bit 7, a
    jr nz, @save_down
    bit 6, a
    jr nz, @save_up
    bit 1, a
    jp nz, @save_b
    bit 0, a
    jp nz, @save_a
    jr -
@save_down:
    ldh a, (<hram.current_cursor)
    inc a
    cp a, $03
    jr c, +
    xor a, a
+   ldh (<hram.current_cursor), a
    jr --
@save_up:
    ldh a, (<hram.current_cursor)
    and a, a
    jr nz, +
    ld a, $03
+   dec a
    ldh (<hram.current_cursor), a
    jr --
@save_b:
    call restore_game
    ld a, $ff
    ldh (<hram.confirmed_cursor.1), a
    ret
@save_a:
    call restore_game
    ldh a, (<hram.current_cursor)
    ldh (<hram.confirmed_cursor.1), a
    jp play_confirm_sound
draw_save_menu:
    push af
    call clear_window_sprites
    pop af
    ld (script_arg_uint8+$01), a
    call load_game_and_check
    jr nc, +
    ld a, (save_count)
    ld (script_arg_uint8), a
    ld a, (script_arg_uint8+$01)
    add a, $16
    ld e, a
    rst $08
    ret
+   ld bc, $1406
    push bc
    call x_script_window_write_frame
    ld a, (script_arg_uint8+$01)
    ld l, a
    ld h, $c0
    call x_multiply_8_8
    ld de, $9c00
    add hl, de
    ld e, l
    ld d, h
    pop bc
    ld hl, window_buffer_1
    xor a, a
    ld (window_y_offset), a
    jp x_draw_script_window
restore_game:
    call x_sram_enable
    ld hl, sram.backup
    ld de, $c200
    ld bc, $0180
    call memcopy_16
    jp x_sram_disable
load_game_and_check:
    call load_game_raw
    ld hl, saved_sentinel
    ldi a, (hl)
    cp a, $1b
    jr nz, clear_game
    ld a, (hl)
    cp a, $e4
    jr nz, clear_game
    call calculate_save_checksum
    push hl
    ld hl, saved_checksum
    ldi a, (hl)
    ld h, (hl)
    ld l, a
    pop de
    call x_compare_16_16
    jr nz, clear_game
    scf
    ret
load_game_raw:
    call save_io_start
    ld de, $c200
    call memcopy_16
    jp x_sram_disable
clear_game:
    ld hl, $c200
    ld bc, $017c
    call memclear_16
    dec a
    ld hl, inventory
    ld b, $20
    call memset
    ld a, $06
    ld (text_speed), a
    ld a, $e4
    ld (party_order), a
    ld hl, $c200
    ld b, $05
-   ld a, $ff
    ldi (hl), a
    ldi (hl), a
    ldi (hl), a
    ldi (hl), a
    ld a, $1c
    rst $00
    dec b
    jr nz, -
    and a, a
    ret
save_game:
    push af
    push bc
    push de
    push hl
    push af
    call x_update_save_variables
    call x_sram_enable
    ld hl, sram.save_count
    ld a, (hl)
    ld (save_count), a
    inc a
    cp a, $64
    jr c, +
    ld a, $01
+   ld (hl), a
    ld hl, sram.sentinel
    call store_sentinel
    call x_sram_disable
    ldh a, (<hram.audio.bg_music)
    ld (saved_bg_music), a
    ld hl, saved_sentinel
    call store_sentinel
    push hl
    call calculate_save_checksum
    pop de
    ld a, l
    ld (de), a
    inc de
    ld a, h
    ld (de), a
    inc de
    pop af
    call save_io_start
    ld e, l
    ld d, h
    ld hl, $c200
    call memcopy_16
    call x_sram_disable
    jp pop_and_return
save_io_start:
    call scale_a_16x
    ld l, a
    ld h, $18
    call x_multiply_8_8
    ld bc, sram
    add hl, bc
    ld bc, $0180
    jp x_sram_enable
store_sentinel:
    ld a, $1b
    ldi (hl), a
    cpl
    ldi (hl), a
    ret
calculate_save_checksum:
    ld de, $c200
    ld hl, $0000
    ld bc, $017e
-   ld a, (de)
    inc de
    rst $00
    dec bc
    ld a, c
    or a, b
    jr nz, -
    ret
save_offsets:
    .db $04, $00
    .db $0a, $00
    .db $10, $00
main_menu:
    ld a, $05
    ldh (<hram.audio.bg_music), a
    ld hl, data_title_screen
    ld de, $9000
    ld bc, $0800
    ld a, :data_title_screen
    call vram_memcopy_16_from_bank
_L017:
    call clear_tilemap_9800
    call x_vram_enable
    ld bc, $1008
    ld de, $9842
    ld hl, data_title_screen_indices
-   push bc
    push de
    ld a, :data_title_screen_indices
    call memcopy_from_bank
    pop de
    pop bc
    ld a, $20
    add a, e
    ld e, a
    jr nc, +
    inc d
+   dec c
    jr nz, -
    call x_vram_disable
    call clear_window_sprites_cursor_stops_and_scroll_2
    ld e, $14
    ld a, $03
    call x_execute_box_script_with_options
    ld hl, box_script_x
    ld c, (hl)
    ld b, $98
    inc hl
    ld l, (hl)
    ld h, $00
    call add_bc_hl_32_x
    ld e, l
    ld d, h
    ld hl, box_script_width
    ld b, (hl)
    inc hl
    ld c, (hl)
    ld hl, window_buffer_1
    call x_draw_tile_rectangle
    rst $10
    ld a, >oam_staging_cc
    rst $18
    ld a, $c3
    ldh (<LCDC), a
    call set_palettes_standard
    call check_sram
    ldh (<hram.current_cursor), a
    ld a, $02
    ldh (<hram.window_sprite_mode), a
-   xor a, a
    call x_execute_menu_cursor_with_options
    ldh a, (<hram.confirmed_cursor.1)
    cp a, $ff
    jr nz, +
    ldh a, (<hram.joyp_raw)
    and a, $0c
    cp a, $0c
    jp z, sound_test
    jr -
+   and a, a
    jp nz, _L019
_L018:
    call clear_palettes
    rst $10
    ld a, $c3
    ldh (<LCDC), a
    xor a, a
    ldh (<hram.window_sprite_mode), a
    call clear_window_sprites_and_cursor_stops
    rst $10
    ld a, >oam_staging_cc
    rst $18
    ld de, $0070
    rst $20
    ldh (<SCX), a
    ld a, $99
    ldh (<SCY), a
    ld de, $9800
    ld bc, $1420
    ld hl, window_buffer_1
    call x_draw_tile_rectangle
    ld a, $0a
    ldh (<hram.temp.1), a
    rst $10
    di
--  call x_game_update
    ldh a, (<hram.joyp_raw)
    bit 0, a
    jr z, +
    ld a, $01
    ldh (<hram.temp.1), a
+   ld c, <LY
    ld hl, SCY
-   ldh a, (c)
    cp a, $91
    jr nz, -
    ldh a, (<hram.temp.1)
    dec a
    ldh (<hram.temp.1), a
    jr nz, +
    ld a, $0a
    ldh (<hram.temp.1), a
    ld a, (hl)
    cp a, $74
    jr z, ++
    inc (hl)
+   ld b, $24
    ld e, $40
-   ldh a, (c)
    cp a, b
    jr nz, -
    ld a, e
    ldh (<BGP), a
    ld b, $28
    ld e, $81
-   ldh a, (c)
    cp a, b
    jr nz, -
    ld a, e
    ldh (<BGP), a
    ld b, $2c
    ld e, $d2
-   ldh a, (c)
    cp a, b
    jr nz, -
    ld a, e
    ldh (<BGP), a
    ld b, $64
    ld e, $81
-   ldh a, (c)
    cp a, b
    jr nz, -
    ld a, e
    ldh (<BGP), a
    ld b, $68
    ld e, $40
-   ldh a, (c)
    cp a, b
    jr nz, -
    ld a, e
    ldh (<BGP), a
    ld b, $6c
    ld e, $00
-   ldh a, (c)
    cp a, b
    jr nz, -
    ld a, e
    ldh (<BGP), a
    jr --
++  ei
    call clear_game
    call clear_tilemap_9800
    call set_palettes_standard
    xor a, a
    ldh (<SCY), a
    ld (player_index), a
-   call menu_character_select
    jp nc, _L017
    call menu_name_select
    jr nc, -
    call clear_window_sprites_and_cursor_stops_2
    and a, a
    ret
_L019:
    call check_sram
    and a, a
    jp z, _L018
    call save_menu
    ldh a, (<hram.confirmed_cursor.1)
    cp a, $ff
    jp z, _L017
    call load_game_and_check
    jp nc, _L018
    call clear_window_sprites_and_cursor_stops_2
    ld a, (saved_bg_music)
    ldh (<hram.audio.bg_music), a
    scf
    ret
sound_test:
    ld e, $4c
    ld a, $03
    call x_execute_box_script_with_options
    ld hl, box_script_x
    ld c, (hl)
    ld b, $98
    inc hl
    ld l, (hl)
    ld h, $00
    call add_bc_hl_32_x
    ld e, l
    ld d, h
    ld hl, box_script_width
    ld b, (hl)
    inc hl
    ld c, (hl)
    ld hl, window_buffer_1
    call x_draw_tile_rectangle
-   call get_cursor_stop_coordinates
    ld hl, hram.cursor.y
    ld (hl), b
    inc hl
    ld (hl), c
    call x_read_buttons
    bit 7, a
    jr nz, @sound_test_up_down
    bit 6, a
    jr nz, @sound_test_up_down
    bit 5, a
    jr nz, @sound_test_left
    bit 4, a
    jp nz, @sound_test_right
    bit 0, a
    jp nz, @sound_test_a
    jr -
@sound_test_up_down:
    ldh a, (<hram.current_cursor)
    xor a, $01
    ldh (<hram.current_cursor), a
    jr -
@sound_test_left:
    ld b, $39
    ldh a, (<hram.current_cursor)
    and a, a
    jr z, +
    ld b, $13
+   ld hl, script_arg_uint8
    rst $00
    ld a, (hl)
    inc a
    cp a, b
    jr c, +
    xor a, a
+   ld (hl), a
    jr sound_test
@sound_test_right:
    ld b, $39
    ldh a, (<hram.current_cursor)
    and a, a
    jr z, +
    ld b, $13
+   ld hl, script_arg_uint8
    rst $00
    ld a, (hl)
    sub a, $01
    jr nc, +
    ld a, b
+   ld (hl), a
    jr sound_test
@sound_test_a:
    ld hl, script_arg_uint8
    ldi a, (hl)
    ldh (<hram.audio.sfx), a
    ld a, (hl)
    ldh (<hram.audio.bg_music), a
    jr -
check_sram:
    call x_sram_enable
    ld b, $01
    ld hl, sram.sentinel
    ldi a, (hl)
    cp a, $1b
    jr nz, +
    ld a, (hl)
    cp a, $e4
    jr z, ++
+   ld b, $00
++  ld a, b
    jp x_sram_disable
clear_window_sprites_and_cursor_stops_2:
    call clear_window_sprites_and_cursor_stops
    xor a, a
    ldh (<hram.window_sprite_mode), a
    rst $10
    ld a, >oam_staging_cc
    rst $18
    jp load_misc_tiles
clear_tilemap_9800:
    ld a, $ff
    ld hl, $9800
    ld bc, $0800
    jp vram_memset_16
the_end:
    ld hl, data_end_screen
    ld de, $8800
    ld bc, $0800
    ld a, :data_end_screen
    call vram_memcopy_16_from_bank
    ld c, $04
-   ld b, $3c
    call the_end_wait
    dec c
    jr nz, -
    xor a, a
-   push af
    call the_end_helper
    ld b, $04
    call the_end_wait
    pop af
    inc a
    cp a, $08
    jr c, -
    ret
the_end_wait:
    rst $10
    dec b
    jr nz, the_end_wait
    ret
the_end_helper:
    ldh (<hram.temp.1), a
    ld hl, the_end_left_table
    rst $00
    ld a, (hl)
    ldh (<hram.temp.2), a
    ldh a, (<hram.temp.1)
    ld hl, the_end_right_table
    rst $00
    ld a, (hl)
    ldh (<hram.temp.3), a
    call x_vram_enable
    ld c, $00
-   ld hl, $9880
    ldh a, (<hram.temp.1)
    ld b, a
    ld a, $0a
    sub a, b
    rst $00
    ld a, c
    call scale_a_32x
    rst $00
    ldh a, (<hram.temp.2)
    ld (hl), a
    add a, $10
    ldh (<hram.temp.2), a
    ldh a, (<hram.temp.1)
    add a, a
    inc a
    rst $00
    ldh a, (<hram.temp.3)
    ld (hl), a
    add a, $10
    ldh (<hram.temp.3), a
    inc c
    ld a, c
    cp a, $08
    jr nz, -
    jp x_vram_disable
the_end_left_table:
    .db $87
    .db $86
    .db $85
    .db $84
    .db $83
    .db $82
    .db $81
    .db $80
the_end_right_table:
    .db $88
    .db $89
    .db $8a
    .db $8b
    .db $8c
    .db $8d
    .db $8e
    .db $8f
init_and_draw_standard_battle_windows:
    call x_load_standard_npc_gfx
    call initialize_battle_window
    ld a, (special_encounter)
    cp a, $02
    jr nz, +
    call x_far_call
    .addr xf_load_arsenal_cloud_background_lower
    .db :xf_load_arsenal_cloud_background_lower
    jr +
draw_standard_battle_windows:
    call clear_window_sprites_cursor_stops_and_scroll_2
+   ld e, $32
    rst $08
    ld de, $3130
    jp draw_box_and_guest_box
battle_menu_player_select:
    call draw_standard_battle_windows
    xor a, a
    jp x_execute_menu_cursor_with_options
battle_menu:
    call x_menu_cursor_stops_clear
    ld e, $33
    rst $08
-   xor a, a
    call x_execute_menu_cursor_with_options
    ldh a, (<hram.confirmed_cursor.1)
    cp a, $ff
    jr z, -
    and a, a
    jr z, +
    ld a, $ff
    ldh (<hram.confirmed_cursor.1), a
    jp clear_window_and_load_animation_data
+   call play_confirm_sound
    xor a, a
_L020:
    ld (player_index), a
--  call check_status_can_act
    jr nz, +
    call battle_ability_menu
    ldh a, (<hram.confirmed_cursor.1)
    cp a, $ff
    jr nz, +
-   ld hl, player_index
    ld a, (hl)
    and a, a
    jr z, ++
    dec (hl)
    call check_status_can_act
    jr nz, -
    jr --
++  call init_and_draw_standard_battle_windows
    jr battle_menu
+   ld a, (player_index)
    inc a
    cp a, $04
    jr c, _L020
    cp a, $05
    jr nc, +
    call x_test_script_var_0
    jr nz, _L020
+   ldh (<hram.confirmed_cursor.1), a
    jp clear_window_and_load_animation_data
battle_ability_menu:
    call initialize_battle_window
    ld e, $34
    rst $08
    ld hl, battle.data.1.inventory
    ld a, (player_index)
    call x_add_player_offset
    ld bc, $0800
-   push hl
    ld a, (hl)
    cp a, $ff
    jr z, +
    ld e, (hl)
    inc hl
    ld d, (hl)
    call read_item_1
    and a, $01
    jr z, +
    inc hl
    ld a, (hl)
    and a, a
    jr z, +
    ld c, $01
+   pop hl
    inc hl
    inc hl
    inc hl
    dec b
    jr nz, -
    inc c
    dec c
    jr nz, +
    ld e, $39
    rst $08
    call play_invalid_sound
    call wait_for_a_b
    rrca
    ld a, $00
    jr c, ++
    cpl
++  ldh (<hram.confirmed_cursor.1), a
    ret
+   ld a, (player_index)
    call x_decode_player_index
    call menu_memory_load
    ld e, $35
    rst $08
-   xor a, a
    call x_execute_menu_cursor_with_options
    ld a, (player_index)
    call x_decode_player_index
    call menu_memory_save
    ldh a, (<hram.confirmed_cursor.1)
    cp a, $ff
    ret z
    ld b, a
    ld a, (player_index)
    ld hl, battle.data.1.inventory
    call x_add_player_offset
    ld a, b
    add a, a
    add a, b
    rst $00
    ldi a, (hl)
    cp a, $ff
    call z, play_invalid_sound
    jr z, -
    ld e, a
    ld d, (hl)
    inc hl
    ld a, (hl)
    and a, a
    call z, play_invalid_sound
    jr z, -
    ld a, (player_index)
    ld hl, battle.data.1.stat.1.item_slot_index
    call x_add_player_offset
    ld (hl), b
    dec hl
    dec hl
    ld (hl), d
    dec hl
    ld (hl), e
    call read_item_1
    ldh (<hram.temp.3), a
    ld c, a
    and a, $01
    call z, play_invalid_sound
    jr z, -
    ld a, c
    and a, $20
    jr nz, +
    ld a, c
    and a, $10
    jr z, ++
    ld a, $08
    jr _L021
++  call battle_menu_player_select
    ldh a, (<hram.confirmed_cursor.1)
    cp a, $ff
    jp z, battle_ability_menu
    jr _L021
+   call clear_window_sprites_cursor_stops_and_scroll_2
    ld e, $36
    rst $08
    ldh a, (<hram.temp.3)
    and a, $10
    jr z, +
    ld e, $38
    rst $08
    call wait_for_a_b
    rrca
    jp nc, battle_ability_menu
    call play_confirm_sound
    ld a, $09
    jr _L021
+   ld a, (enemy_group_count)
    ld b, a
    ld hl, cursor_stops
    ld de, monster_gfx_y
    push bc
    push hl
-   ld a, (de)
    inc de
    ldi (hl), a
    inc hl
    dec b
    jr nz, -
    pop hl
    pop bc
    inc hl
    ld de, monster_gfx_x_raw
-   ld a, (de)
    sub a, $02
    inc de
    ldi (hl), a
    inc hl
    dec b
    jr nz, -
    xor a, a
-   call _is_enemy_stack_defeated
    jr nz, +
    inc a
    jr -
+   ldh (<hram.current_cursor), a
    call battle_menu_enemy_select
    ldh a, (<hram.confirmed_cursor.1)
    cp a, $ff
    jp z, battle_ability_menu
    add a, $05
_L021:
    call play_confirm_sound
    ld b, a
    ld a, (player_index)
    ld hl, battle.data.1.stat.1.target
    call x_add_player_offset
    ld (hl), b
    ret
meat_menu:
    call do_meat_animation
    call x_script_window_push
    call x_load_standard_npc_gfx
    ld hl, $9c00
    ld de, $9d40
    ld bc, $0140
    call vram_memcopy_16
    call x_wait_for_release
--  xor a, a
    ldh (<hram.window_sprite_mode), a
    ld (window_enabled), a
    call clear_window_sprites_cursor_stops_and_scroll_2
    ld a, $03
    ldh (<hram.window_sprite_mode), a
    ld e, $37
    rst $08
    xor a, a
    call x_execute_menu_cursor_with_options
    ldh a, (<hram.confirmed_cursor.1)
    cp a, $ff
    jr z, +
    call play_confirm_sound
    and a, a
    jr z, ++
+   ld a, $ff
    ldh (<hram.confirmed_cursor.1), a
    jr +
++  call clear_window_sprites_cursor_stops_and_scroll_2
    ld e, $30
    rst $08
-   xor a, a
    call x_execute_menu_cursor_with_options
    ldh a, (<hram.confirmed_cursor.1)
    cp a, $ff
    jr z, ++
    call read_battle_stat_1
    and a, $90
    call nz, play_invalid_sound
    jr nz, -
    call play_confirm_sound
    jr +
++  call restore_battle_window_backup
    jr --
+   xor a, a
    ldh (<hram.window_sprite_mode), a
    call clear_window_sprites_cursor_stops_and_scroll_2
    rst $10
    ld a, >oam_staging_cc
    rst $18
    call restore_battle_window_backup
    jp x_script_window_pop
restore_battle_window_backup:
    ld hl, $9d40
    ld de, $9c00
    ld bc, $0140
    jp vram_memcopy_16
check_status_can_act:
    ld a, (player_index)
    call read_battle_stat_1
    and a, $9b
    ret
read_battle_stat_1:
    ld hl, battle.data.1.stat.1.status
    call x_add_player_offset
    ld a, (hl)
    ret
read_item_1:
    push de
    push hl
    ld l, e
    ld h, d
    ld de, data_items
    call add_de_hl_8_x
    ld a, :data_items
    call read_from_bank
    pop hl
    pop de
    ret
initialize_battle_window:
    xor a, a
    ldh (<hram.window_sprite_mode), a
    ld (window_enabled), a
    call clear_window_sprites_cursor_stops_and_scroll_2
    rst $10
    ld a, >oam_staging_cc
    rst $18
    ld hl, $9c00
    ld bc, $0140
    ld a, $75
    call vram_memset_16
    rst $10
    ld a, $d2
    ldh (<BGP), a
    ld a, $d2
    ldh (<OBP0), a
    ld a, $81
    ldh (<OBP1), a
    ld a, $03
    ldh (<hram.window_sprite_mode), a
    ret
clear_window_and_load_animation_data:
    xor a, a
    ldh (<hram.window_sprite_mode), a
    call clear_window_sprites_cursor_stops_and_scroll_2
    call x_menu_cursor_clear_position
    rst $10
    ld a, >oam_staging_cc
    rst $18
    ldh a, (<LCDC)
    and a, $c3
    ldh (<LCDC), a
    ld a, :data_battle_animation_gfx
    ld bc, $0600
    ld de, $8200
    ld hl, data_battle_animation_gfx
    jp vram_memcopy_16_from_bank
battle_menu_enemy_select:
    call update_cursor_coords
    call x_read_buttons
    bit 7, a
    jr nz, @enemy_forward
    bit 6, a
    jr nz, @enemy_backward
    bit 5, a
    jr nz, @enemy_backward
    bit 4, a
    jr nz, @enemy_forward
    bit 1, a
    jr nz, @enemy_b
    bit 0, a
    jr nz, @enemy_a
    jr battle_menu_enemy_select
@enemy_b:
    ld a, $ff
    ldh (<hram.confirmed_cursor.1), a
    ret
@enemy_a:
    ldh a, (<hram.current_cursor)
    ldh (<hram.confirmed_cursor.1), a
    ret
@enemy_forward:
    ldh a, (<hram.current_cursor)
-   inc a
    cp a, $03
    jr c, +
    xor a, a
+   call _is_enemy_stack_defeated
    jr z, -
    ldh (<hram.current_cursor), a
    jr battle_menu_enemy_select
@enemy_backward:
    ldh a, (<hram.current_cursor)
-   and a, a
    jr nz, +
    ld a, $03
+   dec a
    call _is_enemy_stack_defeated
    jr z, -
    ldh (<hram.current_cursor), a
    jr battle_menu_enemy_select
_is_enemy_stack_defeated:
    ld b, a
    ld hl, battle.data.5.current_stack
    add a, h
    ld h, a
    ld a, (hl)
    and a, a
    ld a, b
    ret
update_cursor_coords:
    call get_cursor_stop_coordinates
    ld hl, hram.cursor.y
    ld (hl), b
    inc hl
    ld (hl), c
    ret
wait_for_a_b:
    call x_read_buttons
    and a, $03
    jr z, wait_for_a_b
    ret
arsenal_cloud_process_update:
    push bc
    push hl
    ld hl, hram.arsenal_cloud.addr.1
    ldi a, (hl)
    ld h, (hl)
    ld l, a
    ldh a, (<LY)
    cp a, $90
    jr c, +
    push hl
    ld c, (hl)
    inc l
    ld b, (hl)
    ld hl, hram.arsenal_cloud.addr.2
    ldi a, (hl)
    ld h, (hl)
    ld l, a
    ld a, c
    rrca
    rr (hl)
    rr c
    inc l
    ld a, b
    rrca
    rr (hl)
    rr b
    pop hl
    ld (hl), c
    inc l
    ld (hl), b
+   pop hl
    pop bc
    ret
arsenal_cloud_stage_update:
    push af
    push bc
    push hl
    ld hl, $90e0
    ldh a, (<hram.arsenal_cloud.row)
    ld b, a
    bit 3, a
    jr z, +
    ld hl, $91d0
+   and a, $07
    ld c, a
    add a, a
    add a, l
    ldh (<hram.arsenal_cloud.addr.1), a
    ld a, h
    ldh (<hram.arsenal_cloud.addr.1+1), a
    ld hl, $9000
    bit 3, b
    jr z, +
    ld hl, $91c0
+   ld a, c
    add a, a
    add a, l
    ldh (<hram.arsenal_cloud.addr.2), a
    ld a, h
    ldh (<hram.arsenal_cloud.addr.2+1), a
    inc b
    ld a, b
    and a, $0f
    ldh (<hram.arsenal_cloud.row), a
    pop hl
    pop bc
    pop af
    ret
monster_gfx_morph:
    ld a, b
    ldh (<hram.temp.2), a
    ld hl, monster_gfx_id
    ld a, c
    and a, $f0
    swap a
    ldi (hl), a
    ld a, c
    and a, $0f
    ld (hl), a
    call x_far_call
    .addr xf_load_monster_gfx_offset_and_size
    .db :xf_load_monster_gfx_offset_and_size
    xor a, a
    ldh (<hram.temp.1), a
    call x_far_call
    .addr xd_load_monster_gfx_address
    .db :xd_load_monster_gfx_address
    ld de, $9000
    ldh (<hram.temp.1), a
    ldh a, (<hram.temp.2)
    and a, a
    ldh a, (<hram.temp.1)
    jp nz, vram_memcopy_16_from_bank
    ld (gfx_morph_frame_src_bank), a
    ld a, l
    ld (gfx_morph_frame_src_addr), a
    ld a, h
    ld (gfx_morph_frame_src_addr+1), a
    ld hl, gfx_morph_frame_dst_addr
    ld (hl), e
    inc hl
    ld (hl), d
    inc hl
    srl b
    rr c
    srl b
    rr c
    srl b
    rr c
    srl b
    rr c
    srl c
    ld (hl), c
    inc hl
    xor a, a
    ldi (hl), a
    ld (hl), a
    ld hl, window_buffer_1
    ld b, $40
    ld a, $09
    call memset
    ld hl, window_buffer_1+$100
    ld b, $40
    call memclear
    ld a, $02
    ld (gfx_morph_frame_counter), a
    di
    xor a, a
    ldh (<IF), a
    ldh (<IE), a
    ld a, $01
-   ldh (<hram.temp.1), a
    ld de, $1101
    call update_monster_gfx_morph_wave_effect
    call display_monster_gfx_morph_wave_effect
    ldh a, (<hram.temp.1)
    inc a
    cp a, $40
    jr c, -
    ld a, $01
    ld (gfx_morph_start), a
    ld a, $60
-   ldh (<hram.temp.2), a
    ld de, $1101
    call update_monster_gfx_morph_wave_effect
    call display_monster_gfx_morph_wave_effect
    ld a, (gfx_morph_finish)
    and a, a
    jr nz, +
    ldh a, (<hram.temp.2)
    dec a
    jr nz, -
+   ld a, $40
-   ldh (<hram.temp.1), a
    ld de, $1101
    call update_monster_gfx_morph_wave_effect
    call display_monster_gfx_morph_wave_effect
    ldh a, (<hram.temp.1)
    dec a
    cp a, $ff
    jr nz, -
    xor a, a
    ldh (<IF), a
    ld a, $03
    ldh (<IE), a
    ei
    ret
display_monster_gfx_morph_wave_effect:
    ld hl, gfx_morph_frame_dst_addr+$01
    ld d, (hl)
    dec hl
    ld e, (hl)
    dec hl
    ldd a, (hl)
    ld l, (hl)
    ld h, a
    ld b, $20
-   ldh a, (<LY)
    cp a, $91
    jr c, -
    ld a, (gfx_morph_start)
    and a, a
    jr z, +
    ld a, (gfx_morph_frame_src_bank)
    call memcopy_from_bank
    ld a, l
    ld (gfx_morph_frame_src_addr), a
    ld a, h
    ld (gfx_morph_frame_src_addr+1), a
    ld hl, gfx_morph_frame_dst_addr
    ld (hl), e
    inc hl
    ld (hl), d
    ld hl, gfx_morph_progress_remaining
    dec (hl)
    jr nz, +
    xor a, a
    ld hl, gfx_morph_start
    ldi (hl), a
    inc a
    ld (hl), a
+   ldh a, (<hram.temp.1)
    ld e, a
    ld hl, window_buffer_1
--  ld a, (hl)
    sub a, $09
    ldh (<SCX), a
-   ldh a, (<LY)
    cp a, l
    jr nz, -
    cp a, e
    jr nc, +
    cp a, $3f
    jr z, +
    inc l
    jr --
+   xor a, a
    ldh (<SCX), a
    call x_game_update
    ld hl, gfx_morph_frame_counter
    dec (hl)
    jr nz, display_monster_gfx_morph_wave_effect
    ld (hl), $02
    ret
update_monster_gfx_morph_wave_effect:
    ld hl, window_buffer_1
    ldh a, (<hram.temp.1)
    ld b, a
-   inc h
    ld a, (hl)
    dec h
    and a, a
    jr nz, +
    ld a, (hl)
    add a, $02
    cp a, d
    jr c, ++
    ld a, d
    inc h
    ld (hl), $01
    dec h
    jr ++
+   ld a, (hl)
    sub a, $02
    jr c, +
    cp a, e
    jr nc, ++
+   ld a, e
    inc h
    ld (hl), $00
    dec h
++  ldi (hl), a
    dec b
    jr nz, -
    ret
do_meat_animation:
    ld hl, data_anim_gfx_meat
    ld b, $40
    call x_far_call
    .addr xd_load_animation_gfx
    .db :xd_load_animation_gfx
    xor a, a
-   ldh (<hram.temp.3), a
    add a, a
    ld hl, data_meat_animation_coords
    rst $00
    call x_far_call
    .addr xd_read_pba_oam_type_data
    .db :xd_read_pba_oam_type_data
    ld c, a
    call x_far_call
    .addr xd_read_pba_oam_type_data
    .db :xd_read_pba_oam_type_data
    ld b, a
    ld a, $06
    ld hl, oam_staging_cc
    call x_far_call
    .addr xd_stage_pba_oam_data_helper
    .db :xd_stage_pba_oam_data_helper
    ld b, $02
    call x_far_call
    .addr xd_render_cc00_frames
    .db :xd_render_cc00_frames
    ldh a, (<hram.temp.3)
    inc a
    cp a, $0a
    jr c, -
    call x_vram_enable
    ld hl, $8000
    ld de, $9000
    ld b, $40
    call memcopy
    xor a, a
    ld hl, $98c9
    ldi (hl), a
    inc a
    ld (hl), a
    inc a
    ld hl, $98e9
    ldi (hl), a
    inc a
    ld (hl), a
    jp x_vram_disable
    ldi (hl), a
    inc a
    ld (hl), a
    jp x_vram_disable

.ends


