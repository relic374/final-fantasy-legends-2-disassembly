.include "common.i"

.bank $0c slot 1
.orga $4000

.section "cscript" size $0680 overwrite

xc_execute_cscript:
    ld a, <cscript_stack
    ld (cscript_stack_pointer), a
    ld a, >cscript_stack
    ld (cscript_stack_pointer+1), a
_cscript_instruction:
    ld a, (de)
    and a, $1f
    cp a, $1f
    ret z
    add a, a
    add a, <_jt_cscript
    ld l, a
    ld a, $00
    adc a, >_jt_cscript
    ld h, a
    ldi a, (hl)
    ld h, (hl)
    ld l, a
    jp (hl)
_cscript_expression:
    ld a, (de)
    and a, $1f
    add a, a
    add a, <_jt_cscript_expression
    ld l, a
    ld a, $00
    adc a, >_jt_cscript_expression
    ld h, a
    ldi a, (hl)
    ld h, (hl)
    ld l, a
    jp (hl)
_jt_cscript:
    .addr _cs_0_assign
    .addr _cs_1_test
    .addr _cs_2_goto
    .addr _cs_3_asm_call
    .addr _cs_4
    .addr _cs_5_call
    .addr _cs_6_ret
    .addr _cs_7_8_inc_dec
    .addr _cs_7_8_inc_dec
    .addr _cs_9_indirect_call
_cs_7_8_inc_dec:
    ld a, (de)
    swap a
    srl a
    and a, $07
    inc a
    ld c, a
    ld a, (de)
    and a, $1f
    ld b, a
    inc de
    ld a, (de)
    ld l, a
    inc de
    ld h, >cscript_vars
    ld a, b
    cp a, $08
    jr z, +
    inc (hl)
    jr nz, ++
    dec c
    jr z, ++
    inc hl
    inc (hl)
    jr nz, ++
    dec c
    jr z, ++
    inc hl
    inc (hl)
    jr ++
+   dec (hl)
    ld a, (hl)
    cp a, $ff
    jr nz, ++
    dec c
    jr z, ++
    inc hl
    dec (hl)
    ld a, (hl)
    cp a, $ff
    jr nz, ++
    dec c
    jr z, ++
    inc hl
    dec (hl)
    jr ++
++  jp _cscript_instruction
_cs_0_assign:
    ld a, (de)
    swap a
    srl a
    and a, $07
    ld c, a
    inc de
    ld a, (de)
    ld l, a
    inc de
    ld h, >cscript_vars
    ld a, c
    cp a, $03
    jr c, +
    cp a, $05
    jr nc, ++
    ldi a, (hl)
    ld h, (hl)
    ld l, a
    jr +
++  ld a, (de)
    ld h, a
    inc de
+   ld a, l
    ld (cscript_assign_target_address), a
    ld a, h
    ld (cscript_assign_target_address+1), a
    ld a, c
    ld (cscript_assign_format), a
    xor a, a
    ld (cscript_conditional_op), a
    jp _cscript_expression
_cs_1_test:
    ld a, $01
    ld (cscript_conditional_op), a
    jp _ce_00_atom
_cs_9_indirect_call:
    inc de
    ld a, (de)
    ld c, a
    inc de
    ld b, >cscript_vars
    ld a, (bc)
    push af
    inc bc
    ld a, (bc)
    ld b, a
    pop af
    ld c, a
    jr +
_cs_5_call:
    inc de
    ld a, (de)
    ld c, a
    inc de
    ld a, (de)
    ld b, a
    inc de
+   ld a, (cscript_stack_pointer)
    ld l, a
    ld a, (cscript_stack_pointer+1)
    ld h, a
    ld (hl), e
    inc hl
    ld (hl), d
    inc hl
    ld a, l
    ld (cscript_stack_pointer), a
    ld a, h
    ld (cscript_stack_pointer+1), a
    ld d, b
    ld e, c
    jp _cscript_instruction
_cs_6_ret:
    ld a, (cscript_stack_pointer)
    ld l, a
    ld a, (cscript_stack_pointer+1)
    ld h, a
    dec hl
    ld d, (hl)
    dec hl
    ld e, (hl)
    ld a, l
    ld (cscript_stack_pointer), a
    ld a, h
    ld (cscript_stack_pointer+1), a
    jp _cscript_instruction
_cs_2_goto:
    inc de
    ld a, (de)
    ld c, a
    inc de
    ld a, (de)
    ld d, a
    ld e, c
    jp _cscript_instruction
_cs_3_asm_call:
    inc de
    ld a, (de)
    ld c, a
    inc de
    ld a, (de)
    inc de
    ld b, a
    push de
    ld hl, _asm_ret
    push hl
    push bc
    ret
_asm_ret:
    pop de
    jp _cscript_instruction
_cs_4:
    inc de
    ld a, (de)
    ld (cscript_special), a
    inc de
    jp _cscript_instruction
_jt_cscript_expression:
    .addr _ce_00_atom
    .addr _ce_01_mul
    .addr _ce_02_div
    .addr _ce_03_add
    .addr _ce_04_sub
    .addr _ce_05_and
    .addr _ce_06_or
    .addr _ce_07_nand
    .addr _ce_08_xor
    .addr _ce_09_cpl
    .addr _ce_0a_sr
    .addr _ce_0b_sl
    .addr _ce_compare
    .addr _ce_compare
    .addr _ce_compare
    .addr _ce_compare
    .addr _ce_compare
    .addr _ce_11_ssub
    .addr _ce_compare
    .addr _ce_compare
    .addr _ce_00_atom
    .addr _ce_00_atom
    .addr _ce_00_atom
    .addr _ce_00_atom
    .addr _ce_00_atom
    .addr _ce_00_atom
    .addr _ce_00_atom
    .addr _ce_00_atom
    .addr _ce_00_atom
    .addr _ce_00_atom
    .addr _ce_00_atom
    .addr _ce_1f_end
_ce_1f_end:
    inc de
    ld a, (cscript_conditional_op)
    or a, a
    jr z, +
    push de
    ld de, cscript_test_value
    ld hl, cscript_accumulator
    call x_compare_24_24
    pop de
    jr z, ++
    jr c, _L000
    ld a, (cscript_conditional_op)
    cp a, $0e
    jp z, _cscript_instruction
    cp a, $10
    jp z, _cscript_instruction
    jr _L001
++  ld a, (cscript_conditional_op)
    cp a, $0c
    jp z, _cscript_instruction
    cp a, $13
    jp z, _cscript_instruction
    cp a, $0f
    jp z, _cscript_instruction
    cp a, $10
    jp z, _cscript_instruction
    jr _L001
_L000:
    ld a, (cscript_conditional_op)
    cp a, $0d
    jp z, _cscript_instruction
    cp a, $0f
    jp z, _cscript_instruction
_L001:
    call _cscript_skip
    jp _cscript_instruction
+   push de
    ld a, (cscript_assign_format)
    cp a, $03
    jr c, +
    cp a, $05
    jr nc, ++
    sub a, $03
    jr +
++  sub a, $05
+   inc a
    ld c, a
    ld a, (cscript_assign_target_address)
    ld l, a
    ld a, (cscript_assign_target_address+1)
    ld h, a
    ld de, cscript_accumulator
    ld a, (de)
    inc de
    ldi (hl), a
    dec c
    jr z, +
    ld a, (de)
    inc de
    ldi (hl), a
    dec c
    jr z, +
    ld a, (de)
    ld (hl), a
+   pop de
    jp _cscript_instruction
_cscript_skip:
    ld a, (de)
    ld c, a
    and a, $1f
    cp a, $1f
    jr z, _skip_1_byte
    add a, a
    add a, <_jt_cscript_skip
    ld c, a
    ld a, >_jt_cscript_skip
    adc a, $00
    ld b, a
    ld a, (bc)
    push af
    inc bc
    ld a, (bc)
    ld b, a
    pop af
    ld c, a
    push bc
    ret
_skip_expression:
    ld a, (de)
    ld c, a
    and a, $1f
    cp a, $1f
    jr z, _skip_1_byte
_skip_01_cond:
    ld a, c
    and a, $1f
    cp a, $13
    jr z, _skip_3_bytes_and_expr
    ld a, c
    swap a
    srl a
    and a, $07
    cp a, $07
    jr z, _skip_3_bytes_and_expr
    jr _skip_2_bytes_and_expr
_skip_1_byte:
    inc de
    ret
_jt_cscript_skip:
    .addr _skip_00_assign
    .addr _skip_01_cond
    .addr _skip_3_bytes
    .addr _skip_3_bytes
    .addr _skip_2_bytes
    .addr _skip_3_bytes
    .addr _skip_1_byte
    .addr _skip_2_bytes
    .addr _skip_2_bytes
    .addr _skip_2_bytes
    .addr _skip_1_byte
_skip_00_assign:
    ld a, (de)
    swap a
    srl a
    and a, $07
    cp a, $05
    jr c, _skip_2_bytes_and_expr
_skip_3_bytes_and_expr:
    inc de
_skip_2_bytes_and_expr:
    inc de
    inc de
    jp _skip_expression
_skip_3_bytes:
    inc de
_skip_2_bytes:
    inc de
    jp _skip_1_byte
_ce_00_atom:
    call _cscript_get_atom
    ld hl, cscript_accumulator
    ld bc, cscript_temp.1
    ld a, (bc)
    inc bc
    ldi (hl), a
    ld a, (bc)
    inc bc
    ldi (hl), a
    ld a, (bc)
    inc bc
    ld (hl), a
    jp _cscript_expression
_ce_01_mul:
    call _cscript_get_atom
    ld hl, cscript_accumulator+$02
    ld a, (hl)
    ld (cscript_sign), a
    call _abs_24
    ld hl, cscript_temp.3
    ld a, (cscript_sign)
    xor a, (hl)
    ld (cscript_sign), a
    call _abs_24
    ld a, (cscript_accumulator)
    ld l, a
    ld a, (cscript_accumulator+$01)
    ld h, a
    push de
    ld a, (cscript_temp.1)
    ld e, a
    ld a, (cscript_temp.2)
    ld d, a
    call x_multiply_16_16
    ld a, (cscript_sign)
    and a, $80
    jr z, +
    ld a, e
    cpl
    ld e, a
    ld a, d
    cpl
    ld d, a
    ld a, l
    cpl
    ld l, a
    inc e
    jr nz, +
    inc d
    jr nz, +
    inc l
+   ld a, e
    ld (cscript_accumulator), a
    ld a, d
    ld (cscript_accumulator+$01), a
    ld a, l
    ld (cscript_accumulator+$02), a
    pop de
    jp _cscript_expression
_abs_24:
    ld a, (hl)
    bit 7, a
    ret z
    cpl
    ldd (hl), a
    ld a, (hl)
    cpl
    ldd (hl), a
    ld a, (hl)
    cpl
    inc a
    ld (hl), a
    ret nz
    inc hl
    inc (hl)
    ret nz
    inc hl
    inc (hl)
    ret
_ce_02_div:
    call _cscript_get_atom
    ld hl, cscript_accumulator+$02
    ld a, (hl)
    ld (cscript_sign), a
    call _abs_24
    ld hl, cscript_temp.3
    ld a, (cscript_sign)
    xor a, (hl)
    ld (cscript_sign), a
    call _abs_24
    ld a, (cscript_accumulator)
    ld l, a
    ld a, (cscript_accumulator+$01)
    ld h, a
    push de
    ld a, (cscript_temp.1)
    ld e, a
    ld a, (cscript_temp.2)
    ld d, a
    call x_divide_16_16
    ld e, $00
    ld a, (cscript_sign)
    and a, $80
    jr z, +
    ld e, $ff
    ld a, l
    cpl
    ld l, a
    ld a, h
    cpl
    ld h, a
    inc l
    jr nz, +
    inc h
+   ld a, l
    ld (cscript_accumulator), a
    ld a, h
    ld (cscript_accumulator+$01), a
    ld a, e
    ld (cscript_accumulator+$02), a
    pop de
    jp _cscript_expression
_ce_03_add:
    call _cscript_get_atom
    push de
    ld de, cscript_accumulator
    ld hl, cscript_temp.1
    call x_add_24_24
    pop de
    jp _cscript_expression
_ce_04_sub:
    call _cscript_get_atom
    push de
    ld de, cscript_accumulator
    ld hl, cscript_temp.1
    call x_subtract_24_24
    pop de
    jp _cscript_expression
_ce_11_ssub:
    call _cscript_get_atom
    push de
    ld de, cscript_accumulator
    ld hl, cscript_temp.1
    call x_subtract_24_24
    jr nc, +
    ld hl, cscript_accumulator
    xor a, a
    ldi (hl), a
    ldi (hl), a
    ld (hl), a
+   pop de
    jp _cscript_expression
_ce_05_and:
    call _cscript_get_atom
    push de
    ld hl, cscript_accumulator
    ld de, cscript_temp.1
    ld a, (de)
    and a, (hl)
    ldi (hl), a
    inc de
    ld a, (de)
    and a, (hl)
    ldi (hl), a
    inc de
    ld a, (de)
    and a, (hl)
    ld (hl), a
    pop de
    jp _cscript_expression
_ce_06_or:
    call _cscript_get_atom
    push de
    ld hl, cscript_accumulator
    ld de, cscript_temp.1
    ld a, (de)
    or a, (hl)
    ldi (hl), a
    inc de
    ld a, (de)
    or a, (hl)
    ldi (hl), a
    inc de
    ld a, (de)
    or a, (hl)
    ld (hl), a
    pop de
    jp _cscript_expression
_ce_07_nand:
    call _cscript_get_atom
    push de
    ld hl, cscript_accumulator
    ld de, cscript_temp.1
    ld a, (de)
    and a, (hl)
    cpl
    ldi (hl), a
    inc de
    ld a, (de)
    and a, (hl)
    cpl
    ldi (hl), a
    inc de
    ld a, (de)
    and a, (hl)
    cpl
    ld (hl), a
    pop de
    jp _cscript_expression
_ce_08_xor:
    call _cscript_get_atom
    push de
    ld hl, cscript_accumulator
    ld de, cscript_temp.1
    ld a, (de)
    xor a, (hl)
    ldi (hl), a
    inc de
    ld a, (de)
    xor a, (hl)
    ldi (hl), a
    inc de
    ld a, (de)
    xor a, (hl)
    ld (hl), a
    pop de
    jp _cscript_expression
_ce_09_cpl:
    call _cscript_get_atom
    push de
    ld hl, cscript_accumulator
    ld de, cscript_temp.1
    ld a, (de)
    cpl
    ldi (hl), a
    inc de
    ld a, (de)
    cpl
    ldi (hl), a
    inc de
    ld a, (de)
    cpl
    ld (hl), a
    pop de
    jp _cscript_expression
_ce_0a_sr:
    call _cscript_get_atom
    ld a, (cscript_temp.1)
-   or a, a
    jp z, _cscript_expression
    dec a
    ld hl, cscript_accumulator+$02
    srl (hl)
    dec hl
    rr (hl)
    dec hl
    rr (hl)
    jr -
_ce_0b_sl:
    call _cscript_get_atom
    ld a, (cscript_temp.1)
-   or a, a
    jp z, _cscript_expression
    dec a
    ld hl, cscript_accumulator
    sla (hl)
    inc hl
    rl (hl)
    inc hl
    rl (hl)
    jr -
_ce_compare:
    ld a, (cscript_conditional_op)
    or a, a
    jr z, +
    ld a, (de)
    and a, $1f
    ld (cscript_conditional_op), a
    ld hl, cscript_test_value
    ld bc, cscript_accumulator
    ld a, (bc)
    inc bc
    ldi (hl), a
    ld a, (bc)
    inc bc
    ldi (hl), a
    ld a, (bc)
    inc bc
    ld (hl), a
+   ld a, (de)
    and a, $1f
    cp a, $13
    jr z, +
    cp a, $12
    jr nz, ++
    inc de
    ld a, (de)
    ld c, a
    inc de
    ld b, >cscript_vars
    push de
    ld a, (bc)
    ld d, a
    ld e, $00
    ld a, $05
    call x_random_integer
    pop de
    ld hl, cscript_accumulator
    ldi (hl), a
    xor a, a
    ldi (hl), a
    ld (hl), a
    jp _cscript_expression
+   ld a, (de)
    inc de
    swap a
    srl a
    and a, $07
    ld c, a
    ld a, (de)
    inc de
    ld l, a
    ld a, (de)
    inc de
    ld h, a
    call _cscript_get_atom_ptr
    jr +
++  call _cscript_get_atom
+   ld hl, cscript_accumulator
    ld bc, cscript_temp.1
    ld a, (bc)
    inc bc
    ldi (hl), a
    ld a, (bc)
    inc bc
    ldi (hl), a
    ld a, (bc)
    inc bc
    ld (hl), a
    jp _cscript_expression
_cscript_get_atom:
    ld a, (de)
    inc de
    swap a
    srl a
    and a, $07
    ld c, a
    cp a, $05
    jr z, _cscript_get_atom_rand
    cp a, $06
    jr z, _cscript_get_atom_uint8
    cp a, $07
    jr z, _cscript_get_atom_uint16
    ld a, (de)
    inc de
    ld l, a
    ld h, >cscript_vars
_cscript_get_atom_ptr:
    ld a, c
    cp a, $03
    jr c, +
    dec c
    dec c
    dec c
    ldi a, (hl)
    ld h, (hl)
    ld l, a
+   inc c
    push de
    ld de, cscript_temp.3
    xor a, a
    ld (de), a
    dec de
    ld (de), a
    dec de
    ldi a, (hl)
    ld (de), a
    inc de
    dec c
    jr z, +
    ldi a, (hl)
    ld (de), a
    inc de
    dec c
    jr z, +
    ldi a, (hl)
    ld (de), a
+   pop de
    ret
_cscript_get_atom_uint16:
    ld a, (de)
    inc de
    ld hl, cscript_temp.1
    ldi (hl), a
    ld a, (de)
    inc de
    ldi (hl), a
    ld (hl), $00
    ret
_cscript_get_atom_uint8:
    ld a, (de)
    inc de
    ld hl, cscript_temp.1
    ldi (hl), a
    xor a, a
    ldi (hl), a
    ld (hl), a
    ret
_cscript_get_atom_rand:
    ld a, (de)
    inc de
    push de
    ld d, a
    ld e, $00
    ld a, $06
    call x_random_integer
    ld hl, cscript_temp.1
    ldi (hl), a
    xor a, a
    ldi (hl), a
    ld (hl), a
    pop de
    ret

.ends


