
.macro LoadSprite
;parameters: sprite num, x coord, y coord, tile num, attributes,first bit of x coordinate, big/small
;shoutout to nintendo for making me go through all this bullshit, can't have
; all the memory together or something sane
	lda #\1
	sta $0
	rep #$20
	lda #\1
	clc
	rol a
	rol a ;multiply sprite num by 4 because each index in oam table is 4 bytes
	tax
	sep #$20 ;8 bit a
	lda #\2
	sta OamMirror,x
	inx
	lda #\3
	sta OamMirror,x
	inx
	lda #\4
	sta OamMirror,x
	inx
	lda #\5
	sta OamMirror,x
	lda #\6
	and #$1 ;make sure only 1 bit
	sta $1 ;mess around with first bit of x coordinate b/c nintendo stored it separately
	lda #\7
	and #$1
	sta $2
	jsr SetOamMirror2
.endm

.define OamMirror $400
.define OamMirror2 $600

.bank 0
.section "SpriteStuff"
InitSprites:
	php
	lda #$55
	ldx #$0
SpriteInitLoop:
	sta OamMirror2,x
	inx
	cpx #$20 ;size of oam pt 2
	bne SpriteInitLoop
	plp
	rts
	
SetOamMirror2:
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
	lda $2 ;combine sprite size and msb of xpos
	clc
	ror a
	ora $1
	sta $1
	lda $0
	clc
	ror a ;4 sprites per oam table byte
	ror a
	and #$7F
	tax
	lda OamMirror2,x
	and #SPRITE0_MASK
	ora $1
	sta OamMirror2,x
	jmp EndBitStuff
	
Sprite1:
	jmp EndBitStuff
Sprite2:
	jmp EndBitStuff
Sprite3:
	jmp EndBitStuff
	
EndBitStuff:
	plp
	rts
	
.ends