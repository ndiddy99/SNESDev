.define SPRITE3_MASK %00111111
.define SPRITE2_MASK %11001111
.define SPRITE1_MASK %11110011
.define SPRITE0_MASK %11111100

spriteNum = $0
xPos = $1
yPos = $3
tileNum = $4
sprAttrs = $5
oam2Data = $6
oam2WriteIndex = $7


.macro LoadSprite sprite, tile, xOffset, yOffset, attributes
;parameters: sprite num, pointer to x coord, pointer to y coord, pointer to tile num, attributes, big/small
;shoutout to nintendo for making me go through all this bullshit, can't have
; all the memory together or something sane
	a8
	lda sprite
	sta spriteNum
	a16
	lda xOffset
	sta xPos
	a8
	lda yOffset
	sta yPos
	lda tile
	sta tileNum
	lda attributes
	sta sprAttrs
	jsr SetOamMirror
	a16
.endmacro

.segment "CODE"
InitSprites:
	php
	lda #$1
	ldx #$0
OamInitLoop: ;apparently just setting the sprites to $100 doesn't actually cause them to be removed from the scanline limit
	sta OamMirror,x ;sets lower byte of every sprite's x pos to 1
	inx
	inx
	inx
	inx
	cpx #$200 ;$80 * 4
	bne OamInitLoop
	lda #$55
	ldx #$0
Oam2InitLoop:
	sta Oam2Mirror,x
	inx
	cpx #$20 ;size of oam pt 2
	bne Oam2InitLoop
	plp
	rts
	
SetOamMirror: ;OAM handler function
	lda spriteNum
	xba
	lda #$0 ;make sure top byte of a is 0
	xba
	a16
	clc
	rol a ;we multiply by 4 because each sprite has 4 bytes of data in OAM table
	rol a
	tax
	lda xPos
	a8
	sta OamMirror,x
	xba ;high byte of sprite x position
	and #$1 ;SNES only cares about bit 9
	sta oam2Data ;data to write to OAM part 2
	inx
	lda yPos
	sta OamMirror,x
	inx
	lda tileNum
	sta OamMirror,x
	inx
	lda sprAttrs
	sta OamMirror,x
	
	; lda size ;i don't care about size at the moment, might enable later if I do
	; and #$1 ;combine sprite size and msb of xpos
	; ror a
	; ora oam2Data
	; sta oam2Data
	lda spriteNum
	clc
	ror a ;4 sprites per oam table byte
	ror a
	and #$7F
	sta oam2WriteIndex
	
	lda spriteNum
	and #%00000011 ;only care if it's 0 to 3 since there's 4 bytes in OAM pt 2
	beq Sprite0 ;check where in the byte to place 1st x bit/sprite size
	cmp #$2
	bcc Sprite1
	beq Sprite2
	bra Sprite3
	
Sprite0:
	ldx oam2WriteIndex
	lda Oam2Mirror,x
	and #SPRITE0_MASK
	ora oam2Data
	sta Oam2Mirror,x
	jmp EndBitStuff
	
Sprite1:
	clc
	rol oam2Data
	rol oam2Data
	
	ldx oam2WriteIndex
	lda Oam2Mirror,x
	and #SPRITE1_MASK
	ora oam2Data
	sta Oam2Mirror,x
	jmp EndBitStuff
	
Sprite2:
	clc
	rol oam2Data
	rol oam2Data
	rol oam2Data
	rol oam2Data
	
	ldx oam2WriteIndex
	lda Oam2Mirror,x
	and #SPRITE2_MASK
	ora oam2Data
	sta Oam2Mirror,x
	jmp EndBitStuff
	
Sprite3:
	clc
	rol oam2Data
	rol oam2Data
	rol oam2Data
	rol oam2Data
	rol oam2Data
	rol oam2Data
	
	ldx oam2WriteIndex
	lda Oam2Mirror,x
	and #SPRITE3_MASK
	ora oam2Data
	sta Oam2Mirror,x
	
EndBitStuff:
	rts
	