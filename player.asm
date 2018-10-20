.segment "CODE"

PLAYER_ACCEL = $3fff ;0.25 px
MAX_PLAYER_SPEED = $2
PLAYER_STILL_TILE = $0
FIRST_PLAYER_TILE = $2
LAST_PLAYER_TILE = $8 ;horizontally
PLAYER_TIMER_VAL = $6 ;animation timer
GROUND = $AC

PLAYER_RIGHT_ATTRS = %00110000
PLAYER_LEFT_ATTRS =  %01110000

.enum
STATE_STILL
STATE_RIGHT_HELD 
STATE_RIGHT_RELEASED
STATE_LEFT_HELD
STATE_LEFT_RELEASED
.endenum

.enum
ANIM_MODE_ADD
ANIM_MODE_SUBTRACT
.endenum	

InitPlayer:
	php
	a8
	lda #GROUND
	sta playerY+2
	lda #PLAYER_RIGHT_ATTRS
	sta playerAttrs
	lda #FIRST_PLAYER_TILE
	sta playerTileNum
	plp
	rts

HandlePlayerMovement:
	php
	a16
	lda joypad 
	cmp #KEY_RIGHT ;sets up player state based on joypad input
	bne NotRight
		a8
		lda #STATE_RIGHT_HELD
		sta playerState
		lda #PLAYER_RIGHT_ATTRS
		sta playerAttrs
		a16
		jmp EndStateAssign
	NotRight:
	cmp #KEY_LEFT
	bne NotLeft
		a8
		lda #STATE_LEFT_HELD
		sta playerState
		lda #PLAYER_LEFT_ATTRS
		sta playerAttrs
		a16
		jmp EndStateAssign
	NotLeft:
	lda playerState
	cmp #STATE_RIGHT_HELD
	bne RightNotReleased
		a8
		lda #STATE_RIGHT_RELEASED
		sta playerState
		a16
		jmp EndStateAssign
	RightNotReleased:
	cmp #STATE_LEFT_HELD
	bne LeftNotReleased
		a8
		lda #STATE_LEFT_RELEASED
		sta playerState
		a16
		jmp EndStateAssign
	LeftNotReleased:
	
	EndStateAssign:
		lda playerState
		cmp #STATE_RIGHT_HELD
		beq Pressed
		cmp #STATE_LEFT_HELD
		beq Pressed
		cmp #STATE_RIGHT_RELEASED
		beq Released
		cmp #STATE_LEFT_RELEASED
		beq Released
	
	a8
	lda #PLAYER_STILL_TILE
	sta playerTileNum
	lda #PLAYER_TIMER_VAL
	sta playerAnimTimer
	lda #ANIM_MODE_ADD
	sta playerAnimMode
	a16
	
	jmp EndStateMachine
	Pressed: ;add accel to speed until you get max speed, add speed to player x
		lda playerXSpeed+2
		cmp #MAX_PLAYER_SPEED
		beq ModifySpeed
			lda playerXSpeed ;add 0.25 to low word of x speed
			clc
			adc #PLAYER_ACCEL 
			sta playerXSpeed
			lda playerXSpeed+2
			adc #$0 ;carry to high word of x speed
			sta playerXSpeed+2
			jmp ModifySpeed
			
	Released: ;subtract accel from speed until you get to 0
		lda playerXSpeed+2 ;has X speed been reduced to 0?
		bne NotZero
		lda playerXSpeed ;check both decimal and whole part
		bne NotZero
			lda #STATE_STILL ;if so, set player state to "still"
			sta playerState
			jmp EndStateMachine
		NotZero:
		lda playerXSpeed ;otherwise subtract PLAYER_ACCEL from x speed
		sec
		sbc #PLAYER_ACCEL
		sta playerXSpeed
		lda playerXSpeed+2
		sbc #$0
		sta playerXSpeed+2
		
	ModifySpeed:
		a8
		dec playerAnimTimer
		a16
		lda playerState
		cmp #STATE_RIGHT_HELD
		beq AddSpeed
		cmp #STATE_RIGHT_RELEASED
		beq AddSpeed
		jmp SubtractSpeed
	
	AddSpeed:
		lda playerX
		clc
		adc playerXSpeed
		sta playerX
		lda playerX+2
		adc playerXSpeed+2
		sta playerX+2
		jmp EndStateMachine
		
	SubtractSpeed:
		lda playerX
		sec
		sbc playerXSpeed
		sta playerX
		lda playerX+2
		sbc playerXSpeed+2
		sta playerX+2
	
	EndStateMachine:
	
	a8
	lda playerAnimTimer ;is timer zero?
	bne DrawSprite
		lda #PLAYER_TIMER_VAL
		sta playerAnimTimer
		lda playerAnimMode
		bne AnimSubtract
			lda playerTileNum ;add to tile nim
			ina
			ina
			sta playerTileNum
			cmp #LAST_PLAYER_TILE ;if up to last tile, go to subtract mode
			bne DrawSprite
				lda #ANIM_MODE_SUBTRACT
				sta playerAnimMode
				jmp DrawSprite
		AnimSubtract: ;subtract from tile num
			lda playerTileNum
			dea
			dea
			sta playerTileNum
			cmp #FIRST_PLAYER_TILE
			bne DrawSprite
				lda #ANIM_MODE_ADD
				sta playerAnimMode
	DrawSprite:
	LoadSprite #$1, playerTileNum, playerX+2, playerY+2, playerAttrs
	a16
	lda playerY+2
	clc
	adc #$10
	sta $a
	lda playerTileNum
	clc
	adc #$20
	sta $c
	LoadSprite #$2, $c, playerX+2, $a, playerAttrs
	
	plp
	rts
	