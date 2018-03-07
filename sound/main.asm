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

	
start:
	clp //clear direct page flag (direct page = $0, not $100)
	ldx #$ef
	txs //set up stack pointer
	
	dspClear($2c) //zero echo vol
	dspClear($3c)
	
	dspClear($4c) //zero key on
	dspClear($5c) //zero key off
	dspClear($6c) //zero flag register
	dspClear($0d) //zero echo feedback vol
	dspClear($2d) //disable pitch modulation
	dspWrite($0c,$7f) //master vol max
	dspWrite($1c,$7f)
	
	dspWrite($07,$3f) //channel 0 gain
	dspWrite($00,$7f) //channel 0 vol
	dspWrite($01,$7f) 
	dspWrite($03,$10) //pitch: 32000 hz
	dspWrite($02,$00) 
	dspWrite($5d,$04) //set dir to $400
	dspWrite($04,$01) //select instrument 0
	
	dspWrite($4c,$01) //channel 0 k on
	
	lda #$20 //timer 0 divider around 240 hz
	sta $fa
	
	lda #$01
	sta $f1 //enable timer 0
Main:
	// lda $fd
	// beq Main
	// inc $10
	// cmp #$FF
	// dspWrite($04,$01)
	// bne Main
//	dspWrite($4c,$00) //channel 0 k off
	dspRead($7c)
	cmp #$01
	bne Main
	dspWrite($4c,$01)
	
	jmp Main
	
	
	origin $200
	base $400
Directory:
	dw Nyaa
	dw Nyaa
	dw Cymbal
	dw Cymbal
	dw Roland
	dw Roland+3000
Nyaa:
	insert ".\samples\nyaa.brr"
Cymbal:
	insert ".\samples\cymbal.brr"
Roland:
	insert ".\samples\roland.brr"

end: