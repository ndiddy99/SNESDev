.macro LoadPalette source, colorIndex, numColors
;parameters:
;source, color to start on, number of colors to copy
    lda #colorIndex
    sta $2121       ; Start at START color
    lda #<.bank(source)        ; Using : before the parameter gets its bank.
    ldx #source         ; Not using : gets the offset address.
    ldy #(numColors * 2)   ; 2 bytes for every color
    jsr DMAPalette
.endmacro
	
.macro LoadBlockToVRAM source, destination, size
;parameters:
;source, destination, size
    lda #$80
    sta $2115       ; Set VRAM transfer mode to word-access, increment by 1
    ldx #destination         ; DEST
    stx $2116       ; $2116: Word address for accessing VRAM.
    lda #<.bank(source)        ; SRCBANK
    ldx #source         ; SRCOFFSET
    ldy #size         ; SIZE
   jsr LoadVRAM
.endmacro

.macro LoadBlockToWRAM source, destination, size
	ldx #source
	stx $4302 ;source address
	lda #<.bank(source)
	sta $4304 ;bank
	ldx #size
	stx $4305
	ldx #destination ; set wram transfer address
	stx $2181 
	stz $2183 ;only accesses the first 64k, yolo
	lda #$80 ;dest = vram port
	sta $4301
	stz $4300 ; 1 byte transfer, auto-increment
	lda #$1
	sta $420b ;start transfer
.endmacro

.macro DMATilemapMirror screen
	lda #$80
	sta $2115 ;word-access,increment by one
	a16
	lda screen ;calculate offset based on screen parameter
	xba
	clc
	rol a
	rol a
	sta $2116 ;vram address to write to
	rol a
	ora #$2000
	lda #$3000
	sta $4312 ;dma source address
	a8
	lda #$7e
	sta $4314 ;bank
	ldx #$800
	stx $4315
	lda #$18 ;dest = $2118, vram write register
	sta $4311
	lda #$1 ;word increment on dest, src increment
	sta $4310 
.endmacro

.macro WriteTilemap screen, xOff, yOff, data
;point to write to = ($800*screen + $20*yOff+xOff)*2
;writes to $0 and $1
	a16
	lda screen
	xba
	clc
	rol a
	rol a
	rol a ;screens are $800 apart, so multiply it by that
	sta $0
	lda yOff ;each "screen" is 32x32 words or $40x$40 bytes
	; rol a
	; rol a
	; rol a
	; rol a
	; rol a
	; rol a
	xba
	clc
	ror a
	ror a
	ora $0
	clc
	adc xOff ;words, so add twice to multiply by 2
	clc
	adc xOff
	sta $0
	a8
	lda #$7e
	pha
	plb
	a16
	lda data
	ldx $0
	sta $2000,x
	a8
	lda #$0
	pha
	plb
	stz $0 ;cleanup
	stz $1 ;cleanup
.endmacro

.macro DrawBox screen, x1, y1, x2, y2
;note that "coordinates" are tiles, not pixels
.scope
	lda x2 
	sta $4
	lda y1 ;$2 apart because gets read in 16-bit mdode
	sta $6 ;inside writeTilemap
	lda y2
	sta $8
@DrawVLoop:
	lda x1
	sta $2
@DrawHLoop:
	WriteTilemap screen, $2, $6, #$1
	lda $2
	inc a
	sta $2
	cmp $4
	bne @DrawHLoop
	lda $6
	inc a
	sta $6
	cmp $8
	bne @DrawVLoop
	ldx #$a
	jsr ClearMem
.endscope
.endmacro

.macro DrawLine screen, x1, x2, yVal
.scope
	lda x1 
	sta $2
	lda x2 ;$2 apart because gets read in 16-bit mdode
	sta $4 ;inside writeTilemap
@DrawLoop:
	WriteTilemap screen, $2, yVal, #$1
	lda $2
	inc a
	sta $2
	cmp $4
	bne @DrawLoop
	ldx #$6
	jsr ClearMem
.endscope
.endmacro


.macro StartDMA
;make sure to modify when i add more shit to dma
	lda #$3 ;channels 1 and 2
	sta $420b
.endmacro
	

.macro SetHScroll hVal
;parameter: mem address of horizontal scroll val
	rep #$20
	lda hVal
	sep #$20
	sta $210D	; BG1 horiz scroll
	xba
	sta $210D
.endmacro

.macro SetVScroll vVal
;parameter: mem address of vertical scroll val
	rep #$20
	lda vVal
	sep #$20
	sta $210E	; BG1 vert scroll
	xba
	sta $210E
.endmacro

.macro SetMosaic level
;parameter: mosaic level (0-15 dec, 0-f hex)
	lda level
	and #$F ;param %=15
	clc
	ror a
	ror a
	ror a
	ora #$1
	sta $2106
.endmacro

.macro PositiveDiff val1, val2
;puts the difference of val1 and val2 into a
	lda val1
	cmp val2
	bcs @Val1Greater
	sec
	lda val2
	sbc val1
	jmp @end
@Val1Greater:
	sec
	sbc val2
@end:
.endmacro

.macro a16
	rep #$20
	.a16
.endmacro

.macro a8
	sep #$20
	.a8
.endmacro

.segment "CODE"
DMAPalette: 
;a- data bank
;x- data offset
;y- size of data

;processor status onto stack
	phb
	php
	stx $4302 ;address into dma 0 source register
	sta $4304 ;bank into channel 0 bank register
	sty $4305 ;number of bytes into channel 0 size
	stz $4300 ;dma byte mode, increment by 1
	lda #$22 ;$2122=color palette write
	sta $4301
	lda #$1
	sta $420B ;start transfer
	
	plp
	plb
	rts
	
LoadVRAM:
;a- data bank
;x- data offset
;y- num of bytes to copy
	phb
    php         ; Preserve Registers
    stx $4302   ; Store Data offset into DMA source offset
    sta $4304   ; Store data Bank into DMA source bank
    sty $4305   ; Store size of data block

    lda #$1
    sta $4300   ; Set DMA mode (word, normal increment)
    lda #$18    ; Set the destination register (VRAM write register)
    sta $4301
    lda #$1    ; Initiate DMA transfer (channel 1)
	sta $420B

    plp         ; restore registers
	plb
    rts         ; return

ClearMem:
;x- amount of ram to clear
@ClearLoop:
	stz $0, x
	dex
	bne @ClearLoop
	rts
	