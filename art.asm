.macro HandleLarry xPos, yPos, tileNum
;parameters: pointer to xpos, pointer to ypos, pointer to tile number
lda xPos
sta $3
lda yPos
sta $4
lda tileNum
sta $5
LoadSprite #0, $3, $4, $5, #$30, #0, #0
lda $4 ;add $10 to sprite x pos because second 16x16 sprite is directly below first
clc
adc #$10
sta $4

lda $5
clc
adc #LARRY_OFFSET
sta $5
LoadSprite #1, $3, $4, $5, #$30, #0, #0
.endmacro

BGPalette:
	.INCBIN ".\art\bg.clr"
	
SpritePalette:
	.INCBIN ".\art\larry.clr"

LarryTiles:
	.define NUM_LARRY_TILES $E
	.define LARRY_OFFSET $20
	.define LARRY_ANIMATION_DELAY $2 ;number of frames between incrementing movement
	.INCBIN ".\art\larry.pic"
BGTiles:
	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.incbin ".\art\bg.pic"
