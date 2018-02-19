.MACRO LoadPalette
;parameters:
;source, color to start on, number of colors to copy
    lda #\2
    sta $2121       ; Start at START color
    lda #:\1        ; Using : before the parameter gets its bank.
    ldx #\1         ; Not using : gets the offset address.
    ldy #(\3 * 2)   ; 2 bytes for every color
    jsr DMAPalette
.ENDM
	
.MACRO LoadBlockToVRAM
;parameters:
;source, destination, size
    lda #$80
    sta $2115       ; Set VRAM transfer mode to word-access, increment by 1
    ldx #\2         ; DEST
    stx $2116       ; $2116: Word address for accessing VRAM.
    lda #:\1        ; SRCBANK
    ldx #\1         ; SRCOFFSET
    ldy #\3         ; SIZE
    jsr LoadVRAM
.ENDM

.MACRO SetHScroll
;parameter: mem address of horizontal scroll val
	rep #$20
	lda \1
	sep #$20
	sta $210D	; BG1 horiz scroll
	xba
	sta $210D
.endm

.MACRO SetVScroll
;parameter: mem address of vertical scroll val
	rep #$20
	lda \1
	sep #$20
	sta $210E	; BG1 vert scroll
	xba
	sta $210E
.endm

.macro SetMosaic
;parameter: mosaic level (0-15 dec, 0-f hex)
	lda \1
	and #$F ;param %=15
	clc
	ror a
	ror a
	ror a
	ora #$1
	sta $2106
.endm

