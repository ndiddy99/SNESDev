macro dspWrite(variable reg,variable val) {
	lda #reg
	sta $f2
	lda #val
	sta $f3
}

macro dspClear(variable reg) {
	lda #reg
	sta $f2
	lda #$00
	sta $f3
}

architecture spc700

	origin 0
	base $200
	
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
	
	dspClear($3d) //disable noise
	dspClear($4d) //disable noise
	dspClear($05) //direct gain
	dspClear($06) //direct gain
	
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

	origin $200
	base $400
Directory:
	dw Sample
	dw Sample
Sample:
	insert ".\samples\nyaa.brr"
EndSample:
	
end: