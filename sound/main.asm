architecture spc700

	origin 0
	base $200
	
start:
	clp //clear direct page flag (direct page = $0, not $100
	ldx #$ef
	txs //set up stack pointer
	
	lda #$00 //init registers
	sta $0c //zero l master volume
	sta $1c //zero r master volume
	sta $2c //zero l echo volume
	sta $3c //zero r echo volume
	sta $4c //zero key on
	sta $5c //zero key off
	
	lda #$e0
	sta $6c //keyed off/muted/echo write off/noise stopped
	
	lda #$00
	sta $0d //echo feedback vol zeroed
	sta $2d //disable pitch modulation
	sta $3d //disable noise
	sta $4d //disable echo
	
	jmp loop
	
loop:
	lda $f4 //i/o port 0
	clc
	adc #$01
	sta $f5 //i/o port 1
jmp loop

Sample:
	insert ".\samples\nyaa.brr"
EndSample:
	
end: