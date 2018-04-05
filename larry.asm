.macro HandleLarry xPos, yPos, tileNum
;parameters: pointer to xpos, pointer to ypos, pointer to tile number
	lda xPos
	sta $4
	lda yPos
	sta $5
	lda tileNum
	sta $6
	LoadSprite #0, $4, $5, $6, playerAttrs, #0, #0
	lda $5 ;add $10 to sprite y pos because second 16x16 sprite is directly below first
	clc
	adc #$10
	sta $5

	lda $6
	clc
	adc #LARRY_OFFSET
	sta $6
	LoadSprite #1, $4, $5, $6, playerAttrs, #0, #0
	ldx $7
	ClearMemRange $0, #$7
.endmacro

.macro ClearMemRange start, range
;start-address to start clearing
;range-num of bytes to clear
.scope
	ldx #$0
	@loop:
	stz start,x
	inx
	cpx range
	bne @loop
.endscope
.endmacro

;sprite constants
.define LARRY_ACCEL $1
.define MAX_LARRY_SPEED $10
.define MAX_LARRY_JUMP_HEIGHT $12
;various movement states
.define STATE_NONE $0
.define STATE_RIGHT_PRESSED $1
.define STATE_RIGHT_RELEASED $2
.define STATE_LEFT_PRESSED $3
.define STATE_LEFT_RELEASED $4

;player states
.define STATE_GROUND $0
.define STATE_JUMP_RISE $1
.define STATE_JUMP_FALL $2

SetPlayerVals:
	;set "absolute" player x and y values
	a16
	lda spriteX
	clc
	adc scrollX
	and #$1ff ;snes background = 512 pixels, or $200 binary
	sta playerX
	lda spriteY
	clc
	adc scrollY
	and #$1ff
	sta playerY
	lda playerX ; reduce the position to a $3f range
	ror a ;divide by 8
	ror a
	ror a
	and #$3f
	sta $0
	lda playerY ;same "formula" as for x, but also needs to be shifted left 6 times
	rol a
	rol a
	rol a 
	and #$fc0 ;max possible value
	clc
	adc $0
	sta playerTileOffset
	a8
	ldx #$2
	jsr ClearMem
	rts

CheckCollisionR: ;sprite is 16x32 or 2x4 tiles
	a16
	lda playerTileOffset ;top right
	clc
	adc #$1
	tax
	lda CollisionMap, x
	sta collision
	txa ;load offset back into a
	clc
	adc #$80 ;$40 tiles per row
	tax
	lda CollisionMap, x
	ora collision ;if top or bottom collision
	sta collision
	a8
	rts
	
CheckCollisionL:
	a16
	ldx playerTileOffset ;top left
	lda CollisionMap, x
	sta $0
	txa 
	clc
	adc #$80 ;bottom left
	tax
	lda CollisionMap, x
	ora $0 
	a8
	ldx #$2
	jsr ClearMem
	rts
	