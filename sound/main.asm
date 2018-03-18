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
variable c0Pitch = $10 
variable c0Inst = $11 //stands for instrument
variable numTimerTicks = $12
	
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
	
	dspWrite($07,$3f) //channel 0 gain
	dspWrite($00,$7f) //channel 0 vol
	dspWrite($01,$7f) 
	dspWrite($03,$10) //pitch: 32000 hz
	dspWrite($02,$00) 
	dspWrite($5d,$04) //set dir to $400
	dspWrite($04,$00) //select instrument 0
	
	//dspWrite($4c,$01) //channel 0 k on
	
	lda #$20 //timer 0 divider around 240 hz
	sta $fa
	
	lda #$01
	sta $f1 //enable timer 0
	
	ldx #$00 //set up counter
	
variable SONG_LENGTH = EndSong - Song
Main:
	lda Song,x
	sta c0Pitch
	inx
	lda Song,x
	sta c0Inst
	dspWritePointer($03,c0Pitch)
	dspWritePointer($04,c0Inst)
	dspWrite($4c,$01) //keyon
	dspWrite($5c,$00) //keyon
	inx //x points to "note" duration
TimerWait:
	lda $fd //wait for timer to tick
	beq TimerWait
	inc numTimerTicks
	lda Song,x
	cmp numTimerTicks //if number of timer ticks is greater than/equal to 
	bne TimerWait		//song data, continue, otherwise wait 
	lda #$00
	sta numTimerTicks
	inx
	txa
	cmp #SONG_LENGTH //if song length < x, loop song
	bcc Main
	ldx #$00
	jmp Main
	
	
Song: //format: pitch, instrument, duration (timer ticks)
	db $10,$01,$20
	db $10,$01,$50
	db $0f,$01,$40
	db $09,$01,$70
	// db $10,$00,$50
EndSong:
	

	origin $200
	base $400
Directory:
	dw Nyaa
	dw Nyaa
	dw Cymbal
	dw Cymbal
	dw Roland
	dw Roland
Nyaa:
	insert ".\samples\nyaa.brr"
Cymbal:
	insert ".\samples\cymbal.brr"
Roland:
	insert ".\samples\roland.brr"