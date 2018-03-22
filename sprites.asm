spriteNum = $0
oam2Data = $1
oam2WriteIndex = $2

.macro LoadSprite sprite, xOffset, yOffset, tileNum, attributes, xBit, size
;parameters: sprite num, pointer to x coord, pointer to y coord, pointer to tile num, attributes,first bit of x coordinate, big/small
;shoutout to nintendo for making me go through all this bullshit, can't have
; all the memory together or something sane
	lda sprite
	sta spriteNum
	a16
	lda sprite
	clc
	rol a
	rol a ;multiply sprite num by 4 because each index in oam table is 4 bytes
	tax
	a8
	lda xOffset
	sta OamMirror,x
	inx
	lda yOffset
	sta OamMirror,x
	inx
	lda tileNum
	sta OamMirror,x
	inx
	lda attributes
	sta OamMirror,x
	
	lda xBit
	and #$1 ;make sure only 1 bit
	sta oam2Data ;mess around with first bit of x coordinate b/c nintendo stored it separately
	lda size
	and #$1 ;combine sprite size and msb of xpos
	ror a
	ora oam2Data
	sta oam2Data
	lda spriteNum
	clc
	ror a ;4 sprites per oam table byte
	ror a
	and #$7F
	sta oam2WriteIndex
	jsr SetOam2Mirror
.endmacro

.segment "CODE"
InitSprites:
	php
	lda #$1
	ldx #$0
OamInitLoop: ;apparently just setting the sprites to $100 doesn't actually cause them to be removed from the scanline limit
	sta OamMirror,x
	inx
	inx
	inx
	inx
	cpx #$200
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
	
SetOam2Mirror:
	php
	lda $0
	and #$3 ;check where in the byte to place 1st x bit/sprite size
	cmp #0
	beq Sprite0
	cmp #1
	beq Sprite1
	cmp #2
	beq Sprite2
	cmp #3
	beq Sprite3
	
Sprite0:
	ldx oam2WriteIndex
	lda Oam2Mirror,x
	and #SPRITE0_MASK
	ora oam2Data
	sta Oam2Mirror,x
	jmp EndBitStuff
	
Sprite1:
	clc
	ror oam2Data
	ror oam2Data
	
	ldx oam2WriteIndex
	lda Oam2Mirror,x
	and #SPRITE1_MASK
	ora oam2Data
	sta Oam2Mirror,x
	jmp EndBitStuff
Sprite2:
	clc
	ror oam2Data
	ror oam2Data
	ror oam2Data
	ror oam2Data
	
	ldx oam2WriteIndex
	lda Oam2Mirror,x
	and #SPRITE2_MASK
	ora oam2Data
	sta Oam2Mirror,x
	jmp EndBitStuff
Sprite3:
	clc
	ror oam2Data
	ror oam2Data
	ror oam2Data
	ror oam2Data
	ror oam2Data
	ror oam2Data
	
	ldx oam2WriteIndex
	lda Oam2Mirror,x
	and #SPRITE3_MASK
	ora oam2Data
	sta Oam2Mirror,x
	jmp EndBitStuff
	
EndBitStuff:
	plp
	rts
	