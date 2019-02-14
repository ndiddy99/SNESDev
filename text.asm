.macro DrawText textAddr, xPos, yPos ;assumes a is 16 bits
	php
	lda #textAddr
	sta $0
	lda xPos
	sta $2
	lda yPos
	sta $4
	jsr WriteString
	plp
.endmacro

.segment "CODE"
;tile number = (((asciiNum - $20)/8) * $20) + (((asciiNum - $20)%8) * 2)
;			 = ((asciiNum - $20) & $fff8 << 2) + ((asciiNum - $20) & $7 << 1)

TextL0:
.byte "Hit or miss?",0
TextL1:
.byte "I guess they",0
TextL2:
.byte "never miss, huh?",0
TextL3:
.byte "You got a boyfr-",0
TextL4:
.byte "iend, I bet he",0
TextL5:
.byte "doesn't kiss ya!",0


WriteString:
	a16
	lda $4 ;yPos * 32 + xPos = tilemap pos to start writing at
	asl
	asl
	asl
	asl
	asl
	clc
	adc $2
	asl ;words -> bytes
	tax
	
	lda #$0
	ldy #$0
	
	AsciiLoop:
	lda ($0), y
	and #$ff ;limit to first byte
	beq EndAsciiLoop ;strings are null terminated
		sec
		sbc #$20
		pha ;>
		and #$fff8
		asl
		asl
		sta $6
		
		pla ;<
		and #$7
		asl
		clc
		adc $6
		ora #$2000 ;max priority
		sta TextMirror, x
		
		inx ;destination- words so inc by 2
		inx 
		iny ;source- bytes so inc by 1
	bra AsciiLoop
	EndAsciiLoop:
	rts
	
