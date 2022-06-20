.include "common.i"

.bank $0e slot 1
.orga $4000

.section "audio" size $09f5 overwrite

xe_update_audio:
    jr update_audio
    nop
xe_reset_audio:
    jr reset_audio
    nop
update_audio:
    push af
    push bc
    push de
    push hl
    ldh a, (<hram.audio.fg_music)
    or a, a
    jr z, +
    ldh a, (<hram.audio.fg_music_flag)
    or a, a
    jr z, ++
    call update_foreground_music
    jr _L000
++  call play_foreground_music
    jr _L000
+   ldh a, (<hram.audio.fg_music_flag)
    or a, a
    jr z, +
    call stop_foreground_music
    jr _L000
+   ld a, (mctrl.2.sound_timer)
    or a, a
    jr nz, +
    ldh a, (<hram.audio.current_bg_music)
    ld b, a
    ldh a, (<hram.audio.bg_music)
    cp a, b
    call nz, play_background_music
+   ldh a, (<hram.audio.sfx)
    or a, a
    call nz, play_sound
_L000:
    call update_music
    call update_sound
    pop hl
    pop de
    pop bc
    pop af
    ret
reset_audio:
    ld a, $ff
    ldh (<NR52), a
    call reset_music_control
    ld a, $ff
    ld (mctrl.1.enable), a
    ld (mctrl.2.enable), a
    ld (mctrl.3.enable), a
    ld (mctrl.4.enable), a
    ld a, $10
    ldh (<NR12), a
    ldh (<NR22), a
    ldh (<NR32), a
    ldh (<NR42), a
    call silence_audio
    xor a, a
    ld (mctrl.2.sound_timer), a
    ld a, $77
    ldh (<NR50), a
    ld a, $ff
    ldh (<NR51), a
    ld hl, hram.audio.bg_music
    ld c, $10
    xor a, a
-   ldi (hl), a
    dec c
    jr nz, -
    ret
reset_music_control:
    ld hl, music_time_divider
    ld a, $ff
    ldi (hl), a
    ld a, $3c
    ldi (hl), a
    ld b, $03
--  ld de, audio_init_data
    ld c, $18
-   ld a, (de)
    ldi (hl), a
    inc e
    dec c
    jr nz, -
    dec b
    jr nz, --
    ret
play_background_music:
    ldh (<hram.audio.current_bg_music), a
    or a, a
    jr nz, play_music
    call reset_audio
    ret
play_music:
    push af
    call reset_music_control
    pop af
    dec a
    ld e, a
    add a, a
    add a, e
    add a, a
    ld hl, data_music
    ld e, a
    ld d, $00
    add hl, de
    ldi a, (hl)
    ld (mctrl.1.stream_ptr), a
    ldi a, (hl)
    ld (mctrl.1.stream_ptr+1), a
    ldi a, (hl)
    ld (mctrl.2.stream_ptr), a
    ldi a, (hl)
    ld (mctrl.2.stream_ptr+1), a
    ldi a, (hl)
    ld (mctrl.3.stream_ptr), a
    ldi a, (hl)
    ld (mctrl.3.stream_ptr+1), a
    ret
silence_audio:
    xor a, a
    ldh (<NR10), a
    ld a, $ff
    ldh (<NR13), a
    ldh (<NR23), a
    ldh (<NR31), a
    ldh (<NR33), a
    ld a, $07
    ldh (<NR14), a
    ldh (<NR24), a
    ldh (<NR34), a
    xor a, a
    ldh (<NR42), a
    ld a, $80
    ldh (<NR44), a
    ret
play_foreground_music:
    call silence_audio
    xor a, a
    ld (mctrl.2.sound_timer), a
    ld (mctrl.4.sound_timer), a
    ld c, $62
    ld hl, music_time_divider
    ld de, mctrl_backup
-   ldi a, (hl)
    ld (de), a
    inc e
    dec c
    jr nz, -
    ldh a, (<hram.audio.fg_music)
    call play_music
    ld a, $01
    ldh (<hram.audio.fg_music_flag), a
    ret
update_foreground_music:
    ld a, (mctrl.1.enable)
    ld e, a
    ld a, (mctrl.2.enable)
    ld d, a
    ld a, (mctrl.3.enable)
    and a, d
    and a, e
    cp a, $ff
    ret nz
stop_foreground_music:
    call silence_audio
    ld c, $62
    ld hl, music_time_divider
    ld de, mctrl_backup
-   ld a, (de)
    ldi (hl), a
    inc e
    dec c
    jr nz, -
    xor a, a
    ldh (<hram.audio.fg_music), a
    ldh (<hram.audio.fg_music_flag), a
    ld a, (mctrl.1.wave_duty)
    ldh (<NR21), a
    ld a, (mctrl.1.wave_volume)
    ldh (<NR22), a
    ld a, $87
    ldh (<NR24), a
    ldh a, (<hram.audio.wave_sample)
    ld l, a
    ldh a, (<hram.audio.wave_sample+1)
    ld h, a
    call load_wave_sample
stop_sound_tone_channel:
    xor a, a
    ldh (<NR10), a
    ld a, (mctrl.2.wave_duty)
    ldh (<NR11), a
    ld a, (mctrl.2.wave_volume)
    ldh (<NR12), a
    ld a, $ff
    ldh (<NR13), a
    ld a, $87
    ldh (<NR14), a
    ld a, (mctrl.2.pan)
    ld e, a
    ldh a, (<NR51)
    and a, $ee
    or a, e
    ldh (<NR51), a
    ret
stop_sound_noise_channel:
    xor a, a
    ldh (<NR42), a
    ldh (<NR43), a
    ld a, $80
    ldh (<NR44), a
    ret
audio_init_data:
    .db $00
    .db $01
    .dw $0000
    .db $14
    .dw default_pitch_fx
    .dw default_pitch_fx
    .db $60
    .db $00
    .db $00
    .db $00
    .db $00
    .db $10
    .db $0f
    .db $00
    .db $00
    .db $01
    .dw default_volume_fx
    .dw default_volume_fx
default_pitch_fx:
    .db $0a
    .db $00
    .db $02
    .db $01
    .db $02
    .db $00
    .db $00
    .dw default_pitch_fx+$02
default_volume_fx:
    .db $ff
    .db $f0
    .db $00
    .dw default_volume_fx
note_freq_table:
    .dw $802c
    .dw $809d
    .dw $8107
    .dw $816b
    .dw $81c9
    .dw $8223
    .dw $8277
    .dw $82c7
    .dw $8312
    .dw $8358
    .dw $839b
    .dw $83da
    .dw $8416
    .dw $844e
    .dw $8483
    .dw $84b5
    .dw $84e5
    .dw $8511
    .dw $853b
    .dw $8563
    .dw $8589
    .dw $85ac
    .dw $85ce
    .dw $85ed
    .dw $860b
    .dw $8627
    .dw $8642
    .dw $865b
    .dw $8672
    .dw $8689
    .dw $869e
    .dw $86b2
    .dw $86c4
    .dw $86d6
    .dw $86e7
    .dw $86f7
    .dw $8706
    .dw $8714
    .dw $8721
    .dw $872d
    .dw $8739
    .dw $8744
    .dw $874f
    .dw $8759
    .dw $8762
    .dw $876b
    .dw $8773
    .dw $877b
    .dw $8783
    .dw $878a
    .dw $8790
    .dw $8797
    .dw $879d
    .dw $87a2
    .dw $87a7
    .dw $87ac
    .dw $87b1
    .dw $87b6
    .dw $87ba
    .dw $87be
    .dw $87c1
    .dw $87c5
    .dw $87c8
    .dw $87cb
    .dw $87ce
    .dw $87d1
    .dw $87d4
    .dw $87d6
    .dw $87d9
    .dw $87db
    .dw $87dd
    .dw $87df
    .dw $87e1
    .dw $87e2
    .dw $87e4
    .dw $87e6
    .dw $87e7
    .dw $87e9
    .dw $87ea
    .dw $87eb
    .dw $87ec
    .dw $87ed
    .dw $87ee
    .dw $87ef
    .dw $87f0
note_length_table:
    .db $60
    .db $48
    .db $30
    .db $20
    .db $24
    .db $18
    .db $10
    .db $12
    .db $0c
    .db $08
    .db $06
    .db $04
    .db $03
update_music:
    ld a, (music_time_divider)
    ld b, a
    ld a, (music_tempo)
    add a, b
    ld (music_time_divider), a
    jr nc, +
    call update_music_streams
    call update_music_streams
+   ldh a, (<hram.audio.music_effect_channel)
    inc a
    cp a, $03
    jr nz, +
    xor a, a
+   ldh (<hram.audio.music_effect_channel), a
    or a, a
    call z, update_music_channel_0_effects
    ldh a, (<hram.audio.music_effect_channel)
    cp a, $01
    call z, update_music_channel_1_effects
    ldh a, (<hram.audio.music_effect_channel)
    cp a, $02
    call z, update_music_channel_2_effects
    ret
update_music_streams:
    ld a, (mctrl.1.enable)
    cp a, $ff
    jp z, _update_music_streams_channel_1
    ld a, (mctrl.1.music_timer)
    dec a
    ld (mctrl.1.music_timer), a
    ldh (<hram.audio.note_length.1), a
    jp nz, _update_music_streams_channel_1
_next_byte_channel_0:
    call music_channel_0_stream_read_1
    ld e, a
    cp a, $d0
    jr nc, +
    and a, $f0
    swap a
    ld c, a
    ld hl, note_length_table
    ld b, $00
    add hl, bc
    ld a, (hl)
    ld (mctrl.1.music_timer), a
    ld a, e
    and a, $0f
    ld (mctrl.1.last_note), a
    cp a, $0e
    jp z, _update_music_streams_channel_1
    cp a, $0f
    jr nz, ++
    ld a, $ff
    ldh (<NR23), a
    ld a, $07
    ldh (<NR24), a
    jp _update_music_streams_channel_1
++  add a, a
    ld e, a
    ld a, (mctrl.1.octave)
    add a, e
    ld e, a
    ld d, $00
    ld hl, note_freq_table
    add hl, de
    push hl
    ld a, (mctrl.1.volume_fx_ptr_start)
    ld l, a
    ld a, (mctrl.1.volume_fx_ptr_start+1)
    ld h, a
    ldi a, (hl)
    ld (mctrl.1.volume_fx_timer), a
    ldi a, (hl)
    ldh (<NR22), a
    ld a, l
    ld a, (mctrl.1.volume_fx_ptr_current)
    ld a, h
    ld a, (mctrl.1.volume_fx_ptr_current+1)
    pop hl
    ldi a, (hl)
    ldh (<NR23), a
    ld (mctrl.1.freq_low), a
    ld a, (hl)
    ldh (<NR24), a
    ld (mctrl.1.freq_high), a
    ld hl, mctrl.1.pitch_fx_timer
    call restart_music_channel_effect
    ld hl, mctrl.1.volume_fx_timer
    call restart_music_channel_effect
    jp _update_music_streams_channel_1
+   cp a, $ff
    jr nz, +
    ld (mctrl.1.enable), a
    ldh (<NR23), a
    ld a, $07
    ldh (<NR24), a
    jp _update_music_streams_channel_1
+   cp a, $e0
    jr nc, +
    bit 3, a
    jr nz, ++
    and a, $07
    add a, a
    add a, a
    add a, a
    ld e, a
    add a, a
    add a, e
    ld (mctrl.1.octave), a
    jp _next_byte_channel_0
++  and a, $07
    ld e, a
    ld d, $00
    ld hl, octave_table
    add hl, de
    ld e, (hl)
    ld a, (mctrl.1.octave)
    add a, e
    ld (mctrl.1.octave), a
    jp _next_byte_channel_0
+   and a, $0f
    add a, a
    ld hl, _jt_ch0_command
    ld e, a
    ld d, $00
    add hl, de
    call dispatch_music_channel_0_command
    jp _next_byte_channel_0
dispatch_music_channel_0_command:
    ldi a, (hl)
    ld e, a
    ld a, (hl)
    ld h, a
    ld l, e
    jp (hl)
music_command_null_handler:
    ret
_jt_ch0_command:
    .addr music_channel_0_volume_effect
    .addr music_channel_0_jump
    .addr music_channel_0_loop_counter_jump
    .addr music_channel_0_loop_counter
    .addr music_channel_0_pitch_effect
    .addr music_channel_0_wave_duty
    .addr music_channel_0_pan
    .addr music_set_tempo
    .addr music_command_null_handler
    .addr music_channel_0_loop_counter_2_jump
    .addr music_channel_0_loop_counter_2
    .addr music_channel_0_compare_jump
music_channel_0_volume_effect:
    ld hl, mctrl.1.stream_ptr
    ld e, (hl)
    inc hl
    ld d, (hl)
    ld a, (de)
    ld c, a
    inc de
    ld a, (de)
    inc de
    ld (mctrl.1.volume_fx_ptr_start+1), a
    ld (mctrl.1.volume_fx_ptr_current+1), a
    ld a, c
    ld (mctrl.1.volume_fx_ptr_start), a
    ld (mctrl.1.volume_fx_ptr_current), a
    ld a, e
    ld (mctrl.1.stream_ptr), a
    ld a, d
    ld (mctrl.1.stream_ptr+1), a
    ret
music_channel_0_jump:
    ld hl, mctrl.1.stream_ptr
    ld e, (hl)
    inc hl
    ld d, (hl)
    ld a, (de)
    inc de
    ld (mctrl.1.stream_ptr), a
    ld a, (de)
    ld (mctrl.1.stream_ptr+1), a
    ret
music_channel_0_loop_counter_jump:
    ld hl, mctrl.1.stream_ptr
    call music_stream_read_2_helper
    ld b, a
    ld a, (mctrl.1.loop_counter)
    dec a
    ld (mctrl.1.loop_counter), a
    jr music_stream_conditional_jump
music_channel_1_loop_counter_jump:
    ld hl, mctrl.2.stream_ptr
    call music_stream_read_2_helper
    ld b, a
    ld a, (mctrl.2.loop_counter)
    dec a
    ld (mctrl.2.loop_counter), a
    jr music_stream_conditional_jump
music_channel_2_loop_counter_jump:
    ld hl, mctrl.3.stream_ptr
    call music_stream_read_2_helper
    ld b, a
    ld a, (mctrl.3.loop_counter)
    dec a
    ld (mctrl.3.loop_counter), a
    jr music_stream_conditional_jump
music_channel_0_loop_counter_2_jump:
    ld hl, mctrl.1.stream_ptr
    call music_stream_read_2_helper
    ld b, a
    ld a, (mctrl.1.alt_loop_counter)
    dec a
    ld (mctrl.1.alt_loop_counter), a
    jr music_stream_conditional_jump
music_channel_1_loop_counter_2_jump:
    ld hl, mctrl.2.stream_ptr
    call music_stream_read_2_helper
    ld b, a
    ld a, (mctrl.2.alt_loop_counter)
    dec a
    ld (mctrl.2.alt_loop_counter), a
    jr music_stream_conditional_jump
music_channel_2_loop_counter_2_jump:
    ld hl, mctrl.3.stream_ptr
    call music_stream_read_2_helper
    ld b, a
    ld a, (mctrl.3.alt_loop_counter)
    dec a
    ld (mctrl.3.alt_loop_counter), a
    jr music_stream_conditional_jump
music_stream_read_2_helper:
    ld e, (hl)
    inc hl
    ld d, (hl)
    ld a, (de)
    ld c, a
    inc de
    ld a, (de)
    inc de
    ret
music_stream_conditional_jump:
    jr nz, +
    ld (hl), d
    dec hl
    ld (hl), e
    ret
+   ld (hl), b
    dec hl
    ld (hl), c
    ret
music_channel_0_compare_jump:
    call music_channel_0_stream_read_1
    ld c, a
    ld a, (mctrl.1.stream_ptr)
    ld l, a
    ld a, (mctrl.1.stream_ptr+1)
    ld h, a
    ldi a, (hl)
    ld e, a
    ldi a, (hl)
    ld d, a
    ld a, (mctrl.1.loop_counter)
    cp a, c
    jr nz, +
    push de
    pop hl
+   ld a, l
    ld (mctrl.1.stream_ptr), a
    ld a, h
    ld (mctrl.1.stream_ptr+1), a
    ret
music_channel_1_compare_jump:
    call music_channel_1_stream_read_1
    ld c, a
    ld a, (mctrl.2.stream_ptr)
    ld l, a
    ld a, (mctrl.2.stream_ptr+1)
    ld h, a
    ldi a, (hl)
    ld e, a
    ldi a, (hl)
    ld d, a
    ld a, (mctrl.2.loop_counter)
    cp a, c
    jr nz, +
    push de
    pop hl
+   ld a, l
    ld (mctrl.2.stream_ptr), a
    ld a, h
    ld (mctrl.2.stream_ptr+1), a
    ret
music_channel_2_compare_jump:
    call music_channel_2_stream_read_1
    ld c, a
    ld a, (mctrl.3.stream_ptr)
    ld l, a
    ld a, (mctrl.3.stream_ptr+1)
    ld h, a
    ldi a, (hl)
    ld e, a
    ldi a, (hl)
    ld d, a
    ld a, (mctrl.3.loop_counter)
    cp a, c
    jr nz, +
    push de
    pop hl
+   ld a, l
    ld (mctrl.3.stream_ptr), a
    ld a, h
    ld (mctrl.3.stream_ptr+1), a
    ret
music_channel_0_loop_counter:
    call music_channel_0_stream_read_1
    ld (mctrl.1.loop_counter), a
    ret
music_channel_0_loop_counter_2:
    call music_channel_0_stream_read_1
    ld (mctrl.1.alt_loop_counter), a
    ret
music_channel_0_pitch_effect:
    ld hl, mctrl.1.stream_ptr
    ld e, (hl)
    inc hl
    ld d, (hl)
    ld a, (de)
    ld c, a
    inc de
    ld a, (de)
    inc de
    ld (mctrl.1.pitch_fx_ptr_start+1), a
    ld (mctrl.1.pitch_fx_ptr_current+1), a
    ld a, c
    ld (mctrl.1.pitch_fx_ptr_start), a
    ld (mctrl.1.pitch_fx_ptr_current), a
    ld a, e
    ld (mctrl.1.stream_ptr), a
    ld a, d
    ld (mctrl.1.stream_ptr+1), a
    ret
music_channel_0_wave_duty:
    call music_channel_0_stream_read_1
    ldh (<NR21), a
    ld (mctrl.1.wave_duty), a
    ret
music_channel_0_pan:
    call music_channel_0_stream_read_1
    ld e, a
    ld d, $00
    ld hl, pan_lookup_channel_0
    add hl, de
    ldh a, (<NR51)
    and a, $dd
    or a, (hl)
    ldh (<NR51), a
    ret
pan_lookup_channel_1:
    .db $00
    .db $01
    .db $10
    .db $11
music_set_tempo:
    call music_channel_0_stream_read_1
    ld (music_tempo), a
    ret
_update_music_streams_channel_1:
    ld a, (mctrl.2.enable)
    cp a, $ff
    jp z, _update_music_streams_channel_2
    ld a, (mctrl.2.music_timer)
    dec a
    ld (mctrl.2.music_timer), a
    ldh (<hram.audio.note_length.2), a
    jp nz, _update_music_streams_channel_2
_next_byte_channel_1:
    call music_channel_1_stream_read_1
    ld e, a
    cp a, $d0
    jr nc, +
    and a, $f0
    swap a
    ld c, a
    ld hl, note_length_table
    ld b, $00
    add hl, bc
    ld a, (hl)
    ld (mctrl.2.music_timer), a
    ld a, e
    and a, $0f
    ld (mctrl.2.last_note), a
    cp a, $0e
    jp z, _update_music_streams_channel_2
    ld c, a
    ld a, (mctrl.2.sound_timer)
    or a, a
    jp nz, _update_music_streams_channel_2
    ld a, c
    cp a, $0f
    jr nz, ++
    ld a, $ff
    ldh (<NR13), a
    ld a, $07
    ldh (<NR14), a
    jp _update_music_streams_channel_2
++  add a, a
    ld e, a
    ld a, (mctrl.2.octave)
    add a, e
    ld e, a
    ld d, $00
    ld hl, note_freq_table
    add hl, de
    push hl
    ld a, (mctrl.2.volume_fx_ptr_start)
    ld l, a
    ld a, (mctrl.2.volume_fx_ptr_start+1)
    ld h, a
    ldi a, (hl)
    ld (mctrl.2.volume_fx_timer), a
    ldi a, (hl)
    ldh (<NR12), a
    ld a, l
    ld a, (mctrl.2.volume_fx_ptr_current)
    ld a, h
    ld a, (mctrl.2.volume_fx_ptr_current+1)
    pop hl
    ldi a, (hl)
    ldh (<NR13), a
    ld (mctrl.2.freq_low), a
    ld a, (hl)
    ldh (<NR14), a
    ld (mctrl.2.freq_high), a
    ld hl, mctrl.2.pitch_fx_timer
    call restart_music_channel_effect
    ld hl, mctrl.2.volume_fx_timer
    call restart_music_channel_effect
    jp _update_music_streams_channel_2
+   cp a, $ff
    jr nz, +
    ld (mctrl.2.enable), a
    ldh (<NR23), a
    ld a, $07
    ldh (<NR24), a
    jp _update_music_streams_channel_2
+   cp a, $e0
    jr nc, +
    bit 3, a
    jr nz, ++
    and a, $07
    add a, a
    add a, a
    add a, a
    ld e, a
    add a, a
    add a, e
    ld (mctrl.2.octave), a
    jp _next_byte_channel_1
++  and a, $07
    ld e, a
    ld d, $00
    ld hl, octave_table
    add hl, de
    ld e, (hl)
    ld a, (mctrl.2.octave)
    add a, e
    ld (mctrl.2.octave), a
    jp _next_byte_channel_1
+   and a, $0f
    add a, a
    ld hl, _jt_ch1_command
    ld e, a
    ld d, $00
    add hl, de
    call dispatch_music_channel_1_command
    jp _next_byte_channel_1
dispatch_music_channel_1_command:
    ldi a, (hl)
    ld e, a
    ld a, (hl)
    ld h, a
    ld l, e
    jp (hl)
_jt_ch1_command:
    .addr music_channel_1_volume_effect
    .addr music_channel_1_jump
    .addr music_channel_1_loop_counter_jump
    .addr music_channel_1_loop_counter
    .addr music_channel_1_pitch_effect
    .addr music_channel_1_wave_duty
    .addr music_channel_1_pan
    .addr music_command_null_handler
    .addr music_command_null_handler
    .addr music_channel_1_loop_counter_2_jump
    .addr music_channel_1_loop_counter_2
    .addr music_channel_1_compare_jump
music_channel_1_volume_effect:
    ld hl, mctrl.2.stream_ptr
    ld e, (hl)
    inc hl
    ld d, (hl)
    ld a, (de)
    ld c, a
    inc de
    ld a, (de)
    inc de
    ld (mctrl.2.volume_fx_ptr_start+1), a
    ld a, c
    ld (mctrl.2.volume_fx_ptr_start), a
    ld a, e
    ld (mctrl.2.stream_ptr), a
    ld a, d
    ld (mctrl.2.stream_ptr+1), a
    ret
music_channel_1_jump:
    ld hl, mctrl.2.stream_ptr
    ld e, (hl)
    inc hl
    ld d, (hl)
    ld a, (de)
    inc de
    ld (mctrl.2.stream_ptr), a
    ld a, (de)
    ld (mctrl.2.stream_ptr+1), a
    ret
music_channel_1_loop_counter:
    call music_channel_1_stream_read_1
    ld (mctrl.2.loop_counter), a
    ret
music_channel_1_loop_counter_2:
    call music_channel_1_stream_read_1
    ld (mctrl.2.alt_loop_counter), a
    ret
music_channel_1_pitch_effect:
    ld hl, mctrl.2.stream_ptr
    ld e, (hl)
    inc hl
    ld d, (hl)
    ld a, (de)
    ld c, a
    inc de
    ld a, (de)
    inc de
    ld (mctrl.2.pitch_fx_ptr_start+1), a
    ld (mctrl.2.pitch_fx_ptr_current+1), a
    ld a, c
    ld (mctrl.2.pitch_fx_ptr_start), a
    ld (mctrl.2.pitch_fx_ptr_current), a
    ld a, e
    ld (mctrl.2.stream_ptr), a
    ld a, d
    ld (mctrl.2.stream_ptr+1), a
    ret
music_channel_1_wave_duty:
    call music_channel_1_stream_read_1
    ld (mctrl.2.wave_duty), a
    ld b, a
    ld a, (mctrl.2.sound_timer)
    or a, a
    ret nz
    ld a, b
    ldh (<NR11), a
    ret
music_channel_1_pan:
    call music_channel_1_stream_read_1
    ld e, a
    ld d, $00
    ld hl, pan_lookup_channel_1
    add hl, de
    ld a, (hl)
    ld (mctrl.2.pan), a
    ld a, (mctrl.2.sound_timer)
    or a, a
    ret nz
    ldh a, (<NR51)
    and a, $ee
    or a, (hl)
    ldh (<NR51), a
    ret
pan_lookup_channel_0:
    .db $00
    .db $02
    .db $20
    .db $22
_update_music_streams_channel_2:
    ld a, (mctrl.3.enable)
    cp a, $ff
    jp z, _update_music_streams_end
    ld a, (mctrl.3.music_timer)
    dec a
    ld (mctrl.3.music_timer), a
    ldh (<hram.audio.note_length.3), a
    jp nz, _update_music_streams_end
_next_byte_channel_2:
    call music_channel_2_stream_read_1
    ld e, a
    cp a, $d0
    jr nc, +
    and a, $f0
    swap a
    ld c, a
    ld hl, note_length_table
    ld b, $00
    add hl, bc
    ld a, (hl)
    ld (mctrl.3.music_timer), a
    ld a, e
    and a, $0f
    ld (mctrl.3.last_note), a
    cp a, $0e
    jp z, _update_music_streams_end
    cp a, $0f
    jr nz, ++
    ld a, $00
    ldh (<NR32), a
    jp _update_music_streams_end
++  add a, a
    ld e, a
    ld a, (mctrl.3.octave)
    add a, e
    ld e, a
    ld d, $00
    ld hl, note_freq_table
    add hl, de
    ld a, (mctrl.3.wave_volume)
    ldh (<NR32), a
    ldi a, (hl)
    ldh (<NR33), a
    ld (mctrl.3.freq_low), a
    ld a, (hl)
    and a, $07
    ldh (<NR34), a
    ld (mctrl.3.freq_high), a
    ld hl, mctrl.3.pitch_fx_timer
    call restart_music_channel_effect
    jp _update_music_streams_end
+   cp a, $ff
    jr nz, +
    ld (mctrl.3.enable), a
    ldh (<NR33), a
    ld a, $07
    ldh (<NR34), a
    jp _update_music_streams_end
+   cp a, $e0
    jr nc, +
    bit 3, a
    jr nz, ++
    and a, $07
    add a, a
    add a, a
    add a, a
    ld e, a
    add a, a
    add a, e
    ld (mctrl.3.octave), a
    jp _next_byte_channel_2
++  and a, $07
    ld e, a
    ld d, $00
    ld hl, octave_table
    add hl, de
    ld e, (hl)
    ld a, (mctrl.3.octave)
    add a, e
    ld (mctrl.3.octave), a
    jp _next_byte_channel_2
+   and a, $0f
    add a, a
    ld hl, _jt_ch2_command
    ld e, a
    ld d, $00
    add hl, de
    call dispatch_music_channel_2_command
    jp _next_byte_channel_2
dispatch_music_channel_2_command:
    ldi a, (hl)
    ld e, a
    ld a, (hl)
    ld h, a
    ld l, e
    jp (hl)
_jt_ch2_command:
    .addr music_channel_2_volume
    .addr music_channel_2_jump
    .addr music_channel_2_loop_counter_jump
    .addr music_channel_2_loop_counter
    .addr music_channel_2_pitch_effect
    .addr music_command_null_handler
    .addr music_channel_2_pan
    .addr music_command_null_handler
    .addr music_channel_2_wave_sample
    .addr music_channel_2_loop_counter_2_jump
    .addr music_channel_2_loop_counter_2
    .addr music_channel_2_compare_jump
music_channel_2_volume:
    call music_channel_2_stream_read_1
    ld (mctrl.3.wave_volume), a
    ldh (<NR32), a
    ret
music_channel_2_jump:
    ld hl, mctrl.3.stream_ptr
    ld e, (hl)
    inc hl
    ld d, (hl)
    ld a, (de)
    inc de
    ld (mctrl.3.stream_ptr), a
    ld a, (de)
    ld (mctrl.3.stream_ptr+1), a
    ret
music_channel_2_loop_counter:
    call music_channel_2_stream_read_1
    ld (mctrl.3.loop_counter), a
    ret
music_channel_2_loop_counter_2:
    call music_channel_2_stream_read_1
    ld (mctrl.3.alt_loop_counter), a
    ret
music_channel_2_pitch_effect:
    ld hl, mctrl.3.stream_ptr
    ld e, (hl)
    inc hl
    ld d, (hl)
    ld a, (de)
    ld c, a
    inc de
    ld a, (de)
    inc de
    ld (mctrl.3.pitch_fx_ptr_start+1), a
    ld (mctrl.3.pitch_fx_ptr_current+1), a
    ld a, c
    ld (mctrl.3.pitch_fx_ptr_start), a
    ld (mctrl.3.pitch_fx_ptr_current), a
    ld a, e
    ld (mctrl.3.stream_ptr), a
    ld a, d
    ld (mctrl.3.stream_ptr+1), a
    ret
music_channel_2_pan:
    call music_channel_2_stream_read_1
    ld e, a
    ld d, $00
    ld hl, pan_lookup_channel_2
    add hl, de
    ldh a, (<NR51)
    and a, $bb
    or a, (hl)
    ldh (<NR51), a
    ret
pan_lookup_channel_2:
    .db $00
    .db $04
    .db $40
    .db $44
music_channel_2_wave_sample:
    ld hl, mctrl.3.stream_ptr
    ld e, (hl)
    inc hl
    ld d, (hl)
    ld a, (de)
    ld c, a
    ldh (<hram.audio.wave_sample), a
    inc de
    ld a, (de)
    ld b, a
    ldh (<hram.audio.wave_sample+1), a
    inc de
    ld (hl), d
    dec hl
    ld (hl), e
    push bc
    pop hl
load_wave_sample:
    xor a, a
    ldh (<NR30), a
    ld c, <WAVE
    ld b, $10
-   ldi a, (hl)
    ldh (c), a
    inc c
    dec b
    jr nz, -
    ld a, $80
    ldh (<NR30), a
    ld a, $00
    ldh (<NR32), a
    ld a, $87
    ldh (<NR34), a
    ret
_update_music_streams_end:
    ret
restart_music_channel_effect:
    ld a, $01
    ldi (hl), a
    ldi a, (hl)
    ld e, (hl)
    inc hl
    ldi (hl), a
    ld (hl), e
    ret
octave_table:
    .db $18
    .db $30
    .db $48
    .db $60
    .db $e8
    .db $d0
    .db $b8
    .db $a0
music_channel_0_stream_read_1:
    ld hl, mctrl.1.stream_ptr
music_stream_read_1:
    ld e, (hl)
    inc hl
    ld d, (hl)
    ld a, (de)
    inc de
    ld (hl), d
    dec hl
    ld (hl), e
    ret
music_channel_1_stream_read_1:
    ld hl, mctrl.2.stream_ptr
    jr music_stream_read_1
music_channel_2_stream_read_1:
    ld hl, mctrl.3.stream_ptr
    jr music_stream_read_1
update_music_channel_0_effects:
    ld a, (mctrl.1.sound_timer)
    ld e, a
    ld a, (mctrl.1.enable)
    or a, e
    ret nz
    ldh a, (<hram.audio.note_length.1)
    or a, a
    ret z
    ld a, (mctrl.1.last_note)
    cp a, $0f
    ret z
    ld a, (mctrl.1.pitch_fx_timer)
    dec a
    ld (mctrl.1.pitch_fx_timer), a
    jr nz, +
    ld a, (mctrl.1.pitch_fx_ptr_current)
    ld l, a
    ld a, (mctrl.1.pitch_fx_ptr_current+1)
    ld h, a
    ldi a, (hl)
    or a, a
    call z, handle_effect_stream_jump
    ld (mctrl.1.pitch_fx_timer), a
    ldi a, (hl)
    ld e, a
    ld a, l
    ld (mctrl.1.pitch_fx_ptr_current), a
    ld a, h
    ld (mctrl.1.pitch_fx_ptr_current+1), a
    ld d, $00
    bit 7, e
    jr z, ++
    dec d
++  ld a, (mctrl.1.freq_low)
    ld l, a
    ld a, (mctrl.1.freq_high)
    ld h, a
    add hl, de
    ld a, l
    ldh (<NR23), a
    ld a, h
    and a, $07
    ldh (<NR24), a
+   ld a, (mctrl.1.volume_fx_timer)
    cp a, $ff
    ret z
    dec a
    ld (mctrl.1.volume_fx_timer), a
    ret nz
    ld a, (mctrl.1.volume_fx_ptr_current)
    ld l, a
    ld a, (mctrl.1.volume_fx_ptr_current+1)
    ld h, a
    ldi a, (hl)
    or a, a
    call z, handle_effect_stream_jump
    ld (mctrl.1.volume_fx_timer), a
    ldi a, (hl)
    ldh (<NR22), a
    ld a, (mctrl.1.freq_high)
    ldh (<NR24), a
    ld a, l
    ld (mctrl.1.volume_fx_ptr_current), a
    ld a, h
    ld (mctrl.1.volume_fx_ptr_current+1), a
    ret
update_music_channel_1_effects:
    ld a, (mctrl.2.sound_timer)
    ld e, a
    ld a, (mctrl.2.enable)
    or a, e
    ret nz
    ldh a, (<hram.audio.note_length.2)
    or a, a
    ret z
    ld a, (mctrl.2.last_note)
    cp a, $0f
    ret z
    ld a, (mctrl.2.pitch_fx_timer)
    dec a
    ld (mctrl.2.pitch_fx_timer), a
    jr nz, +
    ld a, (mctrl.2.pitch_fx_ptr_current)
    ld l, a
    ld a, (mctrl.2.pitch_fx_ptr_current+1)
    ld h, a
    ldi a, (hl)
    or a, a
    call z, handle_effect_stream_jump
    ld (mctrl.2.pitch_fx_timer), a
    ldi a, (hl)
    ld e, a
    ld a, l
    ld (mctrl.2.pitch_fx_ptr_current), a
    ld a, h
    ld (mctrl.2.pitch_fx_ptr_current+1), a
    ld d, $00
    bit 7, e
    jr z, ++
    dec d
++  ld a, (mctrl.2.freq_low)
    ld l, a
    ld a, (mctrl.2.freq_high)
    ld h, a
    add hl, de
    ld a, l
    ldh (<NR13), a
    ld a, h
    and a, $07
    ldh (<NR14), a
+   ld a, (mctrl.2.volume_fx_timer)
    cp a, $ff
    ret z
    dec a
    ld (mctrl.2.volume_fx_timer), a
    ret nz
    ld a, (mctrl.2.volume_fx_ptr_current)
    ld l, a
    ld a, (mctrl.2.volume_fx_ptr_current+1)
    ld h, a
    ldi a, (hl)
    or a, a
    call z, handle_effect_stream_jump
    ld (mctrl.2.volume_fx_timer), a
    ldi a, (hl)
    ldh (<NR12), a
    ld a, (mctrl.2.freq_high)
    ldh (<NR14), a
    ld a, l
    ld (mctrl.2.volume_fx_ptr_current), a
    ld a, h
    ld (mctrl.2.volume_fx_ptr_current+1), a
    ret
update_music_channel_2_effects:
    ld a, (mctrl.3.sound_timer)
    ld e, a
    ld a, (mctrl.3.enable)
    or a, e
    ret nz
    ldh a, (<hram.audio.note_length.3)
    or a, a
    ret z
    ld a, (mctrl.3.last_note)
    cp a, $0f
    ret z
    ld a, (mctrl.3.pitch_fx_timer)
    dec a
    ld (mctrl.3.pitch_fx_timer), a
    jr nz, +
    ld a, (mctrl.3.pitch_fx_ptr_current)
    ld l, a
    ld a, (mctrl.3.pitch_fx_ptr_current+1)
    ld h, a
    ldi a, (hl)
    or a, a
    call z, handle_effect_stream_jump
    ld (mctrl.3.pitch_fx_timer), a
    ldi a, (hl)
    ld e, a
    ld a, l
    ld (mctrl.3.pitch_fx_ptr_current), a
    ld a, h
    ld (mctrl.3.pitch_fx_ptr_current+1), a
    ld d, $00
    bit 7, e
    jr z, ++
    dec d
++  ld a, (mctrl.3.freq_low)
    ld l, a
    ld a, (mctrl.3.freq_high)
    ld h, a
    add hl, de
    ld a, l
    ldh (<NR33), a
    ld a, h
    and a, $07
    ldh (<NR34), a
+   ret
handle_effect_stream_jump:
    ldi a, (hl)
    ld e, a
    ldi a, (hl)
    ld (hl), e
    inc hl
    ldi (hl), a
    ld l, e
    ld h, a
    ldi a, (hl)
    ret
play_sound:
    dec a
    add a, a
    ld e, a
    ld d, $00
    ld hl, data_sound_tone
    add hl, de
    ldi a, (hl)
    ld (sfx_tone_stream_ptr), a
    ld a, (hl)
    ld (sfx_tone_stream_ptr+1), a
    ld hl, data_sound_noise
    add hl, de
    ldi a, (hl)
    ld (sfx_noise_stream_ptr), a
    ldi a, (hl)
    ld (sfx_noise_stream_ptr+1), a
    ld a, $01
    ld (mctrl.2.sound_timer), a
    ld (mctrl.4.sound_timer), a
    xor a, a
    ldh (<hram.audio.sfx), a
    ret
update_sound:
    ld a, (mctrl.2.sound_timer)
    or a, a
    jp z, _L001
    dec a
    ld (mctrl.2.sound_timer), a
    jr nz, _L001
    ld a, (sfx_tone_stream_ptr)
    ld l, a
    ld a, (sfx_tone_stream_ptr+1)
    ld h, a
-   ldi a, (hl)
    ld (mctrl.2.sound_timer), a
    or a, a
    jr nz, +
    call stop_sound_tone_channel
    jr _L001
+   cp a, $ef
    jr nz, +
    ldi a, (hl)
    ld c, a
    ldi a, (hl)
    ld b, a
    ldh a, (<hram.audio.sfx_tone_loop_counter)
    dec a
    ldh (<hram.audio.sfx_tone_loop_counter), a
    jr z, -
    ld l, c
    ld h, b
    jr -
+   cp a, $f0
    jr c, +
    and a, $0f
    ldh (<hram.audio.sfx_tone_loop_counter), a
    jr -
+   ld c, <NR10
    ld b, $05
-   ldi a, (hl)
    ldh (c), a
    inc c
    dec b
    jr nz, -
    ldh a, (<NR51)
    or a, $11
    ldh (<NR51), a
    ld a, l
    ld (sfx_tone_stream_ptr), a
    ld a, h
    ld (sfx_tone_stream_ptr+1), a
_L001:
    ld a, (mctrl.4.sound_timer)
    or a, a
    jr z, +
    dec a
    ld (mctrl.4.sound_timer), a
    jr nz, +
    ld a, (sfx_noise_stream_ptr)
    ld l, a
    ld a, (sfx_noise_stream_ptr+1)
    ld h, a
-   ldi a, (hl)
    ld (mctrl.4.sound_timer), a
    or a, a
    jr nz, ++
    call stop_sound_noise_channel
    jr +
++  cp a, $ef
    jr nz, ++
    ldi a, (hl)
    ld c, a
    ldi a, (hl)
    ld b, a
    ldh a, (<hram.audio.sfx_noise_loop_counter)
    dec a
    ldh (<hram.audio.sfx_noise_loop_counter), a
    jr z, -
    ld l, c
    ld h, b
    jr -
++  cp a, $f0
    jr c, ++
    and a, $0f
    ldh (<hram.audio.sfx_noise_loop_counter), a
    jr -
++  ldi a, (hl)
    ldh (<NR42), a
    ldi a, (hl)
    ldh (<NR43), a
    ld a, $80
    ldh (<NR44), a
    ldh a, (<NR51)
    or a, $88
    ldh (<NR51), a
    ld a, l
    ld (sfx_noise_stream_ptr), a
    ld a, h
    ld (sfx_noise_stream_ptr+1), a
+   ret

.ends


