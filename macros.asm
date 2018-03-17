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

.macro WRAMToVRAM source, destination, size
;reading from the wram port because you can access data ~1.5x faster 
	lda #$80
	sta $2115 ;word-access,increment by one
	ldx #destination
	stx $2116
	ldx #source
	stx $2181
	stz $2183 ;also only accesses first 64k
	ldx #$2180
	stx $4302 ;dma source address=wram read port
	stz $4304 ;bank
	ldx #size
	stx $4305
	lda #$18 ;dest = $2118, vram write register
	sta $4301
	lda #$9 ;word increment on dest, no src increment
	sta $4300 
	lda #$1
	sta $420b ;start transfer
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

.macro ClearMem start, range
;start-address to start clearing
;range-num of bytes to clear
	ldx #$0
	@loop:
	stz start,x
	inx
	cpx range
	bne @loop
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

	