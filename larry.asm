.macro HandleLarry xPos, yPos, tileNum
;parameters: pointer to xpos, pointer to ypos, pointer to tile number
lda xPos
sta $4
lda yPos
sta $5
lda tileNum
sta $6
LoadSprite #0, $4, $5, $6, spriteAttrs, #0, #0
lda $5 ;add $10 to sprite y pos because second 16x16 sprite is directly below first
clc
adc #$10
sta $5

lda $6
clc
adc #LARRY_OFFSET
sta $6
LoadSprite #1, $4, $5, $6, spriteAttrs, #0, #0
.endmacro

;sprite constants
.define LARRY_ACCEL $1 
.define MAX_LARRY_SPEED $6
;various states
.define STATE_NONE $0
.define STATE_RIGHT_PRESSED $1
.define STATE_RIGHT_RELEASED $2
.define STATE_LEFT_PRESSED $3
.define STATE_LEFT_RELEASED $4
