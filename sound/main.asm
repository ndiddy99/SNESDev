architecture spc700

macro dspWrite(variable reg,variable val) {
	lda #reg
	sta $f2
	lda #val
	sta $f3
}

macro dspWritePointer(variable reg,variable val) {
	lda #reg
	sta $f2
	lda val
	sta $f3
}

macro dspClear(variable reg) {
	lda #reg
	sta $f2
	lda #$00
	sta $f3
}

macro dspRead(variable reg) {
	lda #reg
	sta $f2
	lda $f3
}
	origin 0
	base $200

//defines for variables
constant c0Pitch = $10 
constant c0Inst = $11 //stands for instrument
constant c0Counter = $12
constant c1Pitch = $13
constant c1Inst = $14
constant c1Counter = $15
constant numTimerTicksC0 = $16
constant numTimerTicksC1 = $17
	
start:
	clp //clear direct page flag (direct page = $0, not $100)
	ldx #$ef
	txs //set up stack pointer
	
	dspClear($2c) //zero echo vol
	dspClear($3c)
	dspClear($3d) //disable noise
	dspClear($4c) //zero key on
	dspClear($5c) //zero key off
	dspWrite($6c,$20) //noise off, echo buffer writes off
	dspClear($0d) //zero echo feedback vol
	dspClear($2d) //disable pitch modulation
	dspClear($4d) //disable echo
	dspWrite($6d,$d0) //echo buffer out of the way
	dspWrite($0c,$7f) //master vol max
	dspWrite($1c,$7f)
	//channel 0 initialization
	dspWrite($07,$3f) //channel 0 gain
	dspWrite($00,$30) //channel 0 vol
	dspWrite($01,$30) 
	dspWrite($03,$10) //pitch: 32000 hz
	dspWrite($02,$00) 

	//channel 1 init
	dspWrite($17,$3f) //channel 0 gain
	dspWrite($10,$0) //channel 0 vol
	dspWrite($11,$0) 
	dspWrite($13,$10) //pitch: 32000 hz
	dspWrite($12,$00) 
	
	dspWrite($5d,$04) //set dir to $400
	lda #$20 //timer 0 divider around 240 hz
	sta $fa
	
	lda #$01
	sta $f1 //enable timer 0
	
variable SONG_LENGTH_C0 = EndSongC0 - SongC0
variable SONG_LENGTH_C1 = EndSongC1 - SongC1
	 
Main:
	lda numTimerTicksC0
	bne DontSetC0
	jsr WriteNoteC0
DontSetC0:
	lda numTimerTicksC1
	bne DontSetC1
	jsr WriteNoteC1
DontSetC1:
Wait:
	lda $fd //wait for timer to tick
	beq Wait
	inc numTimerTicksC0
	inc numTimerTicksC1
	ldx c0Counter
	lda SongC0,x //load "reference" note duration
	cmp numTimerTicksC0 //compare to current note duration
	bne DontWriteC0 //if it's not the same, don't increment note
	lda #$00 
	sta numTimerTicksC0 //how we identify which note to write
	inx
	stx c0Counter
	txa
	cmp #SONG_LENGTH_C0 //if song length's greater than current index, set to beginning
	bcc DontWriteC0
	lda #$00
	sta c0Counter
DontWriteC0:
	ldx c1Counter
	lda SongC1,x
	cmp numTimerTicksC1
	bne DontWriteC1
	lda #$00
	sta numTimerTicksC1
	inx
	stx c1Counter
	txa
	cmp #SONG_LENGTH_C1
	bcc DontWriteC1
	lda #$00
	sta c1Counter
DontWriteC1:
	jmp Main

	
	// inc c0Counter
	// lda c0Counter
	// cmp #SONG_LENGTH_C0 //if song length < x, loop song
	// bcc Main
	// lda #$00
	// sta c0Counter
	
WriteNoteC0:
	ldx c0Counter
	lda SongC0,x
	sta c0Pitch
	inx
	lda SongC0,x
	sta c0Inst
	dspWritePointer($03,c0Pitch)
	dspWritePointer($04,c0Inst)
	dspWrite($4c,$01) //keyon
	dspWrite($5c,$00) //keyon
	inx //x points to "note" duration
	stx c0Counter
	rts
	
WriteNoteC1:
	ldx c1Counter
	lda SongC1,x
	sta c1Pitch
	inx
	lda SongC1,x
	sta c1Inst
	dspWritePointer($13,c1Pitch)
	dspWritePointer($14,c1Inst)
	dspWrite($4c,$02) //keyon
	dspWrite($5c,$00) //keyon
	inx //x points to "note" duration
	stx c1Counter
	rts
	
constant drum = $00
constant hidrum = $01

SongC0: //format: instrument pitch, instrument, duration
	db $d, drum, $50
	db $10, hidrum, $50
	db $d, drum, $20
	db $d, drum, $30
	db $10, hidrum, $50
	db $d, drum, $50
	db $10, hidrum, $50
	db $d, drum, $20
	db $d, drum, $30
	db $10, hidrum, $50
	db $d, drum, $50
	db $10, hidrum, $50
	db $d, drum, $20
	db $d, drum, $30
	db $10, hidrum, $50
	

	db $d, drum, $20
	db $10, drum, $20
	db $d, hidrum, $70
	db $10, drum, $30
	db $10, hidrum, $50
EndSongC0:
	
SongC1:
	db $10, $00, $20
	db $12, $00, $20
EndSongC1:

	origin $200
	base $400
Directory:
	dw Drum
	dw Drum
	dw HiDrum
	dw HiDrum
	dw Nyaa
	dw Nyaa
Drum:
	insert ".\samples\drum.brr"
HiDrum:
	insert ".\samples\hidrum.brr"
Nyaa:
	insert ".\samples\nyaa.brr"
