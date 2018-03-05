macro dspWrite(variable reg,variable val) {
	lda #reg
	sta $f2
	lda #val
	sta $f3
}

architecture spc700

	origin 0
	base $200
	
start:
	clp //clear direct page flag (direct page = $0, not $100
	ldx #$ef
	txs //set up stack pointer
	
	ldx #$00
	
	lda #$2c //init registers
	sta $f2 //zero echo vol
	stx $f3
	
	lda #$3c
	sta $f2
	stx $f3
	
	lda #$4c //zero key on
	sta $f2
	stx $f3
	
	
	lda #$5c //zero key off
	sta $f2
	stx $f3
	
	lda #$6c //zero flag register
	sta $f2
	stx $f3
	
	lda #$0d //zero echo feedback vol
	sta $f2
	stx $f3

	lda #$2d //disable pitch modulation
	sta $f2
	stx $f3
	
	lda #$3d //disable noise
	sta $f2
	stx $f3

	lda #$4d //disable noise
	sta $f2
	stx $f3
	
	lda #$05 //direct gain
	sta $f2
	stx $f3
	
	lda #$06
	sta $f2
	stx $f3

	dspWrite($07,$3f) //channel 0 gain
	dspWrite($00,$7f) //channel 0 vol
	dspWrite($01,$7f) 
	dspWrite($0c,$7f) //master vol
	dspWrite($1c,$7f)
	dspWrite($03,$10) //pitch: 32000 hz
	dspWrite($02,$00) 
	dspWrite($5d,$04) //set dir to $400
	dspWrite($04,$00) //select instrument 0
	dspWrite($4c,$01) //k on
	
	jmp loop
	
loop:
	lda $f4 //i/o port 0
	clc
	adc #$01
	sta $f5 //i/o port 1
jmp loop

	origin $400
Sample:
	insert ".\samples\nyaa.brr"
EndSample:
	
end: