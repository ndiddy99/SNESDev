.macro DrawText textAddr, xPos, yPos ;assumes a is 16 bits
	lda #textAddr
	sta $0
	lda xPos
	sta $2
	lda yPos
	jsr WriteString
.endmacro

.macro DrawByte byteAddr, xPos, yPos ;assumes a is 16 bits
	lda byteAddr
	sta $0
	lda xPos
	sta $2
	lda yPos
	jsr WriteByte
.endmacro

.segment "CODE"

;tile number = (asciiNum - $20)

TextL0:
;      01234567890123456789012345678901
.byte "Hit or miss, I guess they never",0
TextL1:
.byte "miss, huh? You got a boyfriend?",0
TextL2:
.byte "I bet he doesn't kiss ya! He gon",0
TextL3:
.byte "find another girl and he won't",0
TextL4:
.byte "miss ya! He gon' skrrt and hit",0
TextL5:
.byte "the dab like Wiz Khalifa.",0


WriteString:
	a16
	asl ;yPos (already in a) * 32 + xPos = tilemap pos to start writing at
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
		ora #$2000 ;max priority
		sta TextMirror, x
		
		inx ;destination- words so inc by 2
		inx 
		iny ;source- bytes so inc by 1
	bra AsciiLoop
	EndAsciiLoop:
	rts
	
WriteByte:
	a16
	asl ;yPos (already in a) * 32 + xPos = tilemap pos to start writing at
	asl
	asl
	asl
	asl
	clc
	adc $2
	asl ;words -> bytes
	tax
	
	lda $0
	and #$f0
	lsr
	lsr
	lsr
	lsr
	cmp #$a ;because of how ASCII works, you have to add #$10 to the value to get
	bcs AddLettersN1 ;the ascii tile if it's between 0-9, but #$17 if it's between A-F
		clc
		adc #$10
		bra DoneAddN1
	AddLettersN1:
		clc
		adc #$17
	DoneAddN1:
	ora #$2000
	sta TextMirror, x
	inx
	inx
	;repeat for second nybble
	lda $0
	and #$0f
	cmp #$a 
	bcs AddLettersN2 
		clc
		adc #$10
		bra DoneAddN2
	AddLettersN2:
		clc
		adc #$17
	DoneAddN2:
	ora #$2000
	sta TextMirror, x	
	rts
	
