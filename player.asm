.segment "CODE"

PLAYER_ACCEL = $4000 ;0.25 px
PLAYER_JUMP_SPEED = $fff8 ;-7
GRAVITY = $6fff ;~0.4px


MAX_PLAYER_SPEED = $3
MAX_SLOPE_SPEED = $4
PLAYER_STILL_TILE = $0
FIRST_PLAYER_TILE = $2
LAST_PLAYER_TILE = $8 ;horizontally
PLAYER_JUMPING_TILE = $E
PLAYER_TIMER_VAL = $6 ;animation timer
GROUND = $B0

PLAYER_RIGHT_ATTRS = %00110000
PLAYER_LEFT_ATTRS =  %01110000

PLAYER_WIDTH = $10
PLAYER_HEIGHT = $20
PLAYER_TOP = $9 ;offset from y pos to top of sprite

;playerState
.enum
STATE_DECEL
STATE_RIGHT_HELD 
STATE_LEFT_HELD
.endenum
;moveState
.enum
MOVE_STATE_NORMAL
MOVE_STATE_JUMPING
MOVE_STATE_FALLING ;like jumping but without the jumping frame
MOVE_STATE_SLOPE ;when player is on slope
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
	lda #$20
	sta playerX+2
	sta playerSpriteX
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
	bit #KEY_RIGHT ;sets up player state based on joypad input
	beq NotRight
		lda #STATE_RIGHT_HELD
		sta playerState
		a8
		lda #PLAYER_RIGHT_ATTRS
		sta playerAttrs
		a16
		jmp EndStateAssign
	NotRight:
	bit #KEY_LEFT
	beq NotLeft
		lda #STATE_LEFT_HELD
		sta playerState
		a8
		lda #PLAYER_LEFT_ATTRS
		sta playerAttrs
		a16
		jmp EndStateAssign
	NotLeft:
	lda #STATE_DECEL
	sta playerState
	
	EndStateAssign:
	
	lda playerState
	bne ModifySpeed
		jmp Released
	ModifySpeed:
	cmp #STATE_RIGHT_HELD
	bne RightNotHeld
		lda playerXSpeed+2		;if player speed is greater than max speed, don't apply acceleration
		cmp #MAX_PLAYER_SPEED
		bmi @AccelPlayer
			jmp AddSpeed
		@AccelPlayer:
			lda playerXSpeed
			clc
			adc #PLAYER_ACCEL
			sta playerXSpeed
			lda playerXSpeed+2
			adc #$0
			sta playerXSpeed+2
			jmp AddSpeed
	RightNotHeld:
	cmp #STATE_LEFT_HELD
	bne LeftNotHeld
		lda playerXSpeed+2
		cmp #-(MAX_PLAYER_SPEED)
		bpl @AccelPlayer
			jmp AddSpeed
		@AccelPlayer:
			lda playerXSpeed
			sec
			sbc #PLAYER_ACCEL
			sta playerXSpeed
			lda playerXSpeed+2
			sbc #$0
			sta playerXSpeed+2
			jmp AddSpeed
	LeftNotHeld:
	 
	Released:
	lda playerXSpeed
	bne PlayerMoving
	lda playerXSpeed+2
	bne PlayerMoving
	jmp PlayerStill
	PlayerMoving:
		lda playerXSpeed+2
		and #$8000
		beq DecelRight
			lda playerXSpeed ;going left, add speed until 0
			clc
			adc #PLAYER_ACCEL
			sta playerXSpeed
			lda playerXSpeed+2
			adc #$0
			sta playerXSpeed+2
			and #$8000
			bne @NotBelowZero
				stz playerXSpeed
				stz playerXSpeed+2
		@NotBelowZero:	
			bra AddSpeed
		DecelRight:
			lda playerXSpeed
			sec
			sbc #PLAYER_ACCEL
			sta playerXSpeed
			lda playerXSpeed+2
			sbc #$0
			sta playerXSpeed+2
			and #$8000
			beq @NotBelowZero
				stz playerXSpeed
				stz playerXSpeed+2
			@NotBelowZero:
		
	AddSpeed:
	dec playerAnimTimer
	lda playerX
	clc
	adc playerXSpeed
	sta playerX
	lda playerX+2
	adc playerXSpeed+2
	sta playerX+2
	bra CheckJump
	
	PlayerStill:	
	a8 ;if not pressing any buttons, reset tile and animation timer
	lda #PLAYER_STILL_TILE
	sta playerTileNum
	lda #PLAYER_TIMER_VAL
	sta playerAnimTimer
	lda #ANIM_MODE_ADD
	sta playerAnimMode
	a16
	EndModifySpeed:
	
	CheckJump:
	lda joypad
	bit #KEY_B
	beq DontStartJump
	lda joypadBuf ;if holding down B from last jump, don't start jumping again
	bit #KEY_B
	bne NotRising
		lda playerMove
		cmp #MOVE_STATE_JUMPING
		beq NotRising ;don't want player jumping in air
		cmp #MOVE_STATE_FALLING
		beq NotRising
			lda #MOVE_STATE_JUMPING
			sta playerMove
			lda #PLAYER_JUMP_SPEED
			sta playerYSpeed+2
			bra NotRising
			; dec playerY+2
	DontStartJump:	
	lda playerYSpeed+2
	and #$8000
	beq NotRising ;if player is rising and let go of jump button, add a big ass number to speed to make them
		lda playerYSpeed ;fall faster
		clc
		adc #$B000
		sta playerYSpeed
		lda playerYSpeed+2
		adc #$0
		sta playerYSpeed+2
	NotRising:

	lda playerMove
	cmp #MOVE_STATE_JUMPING
	bne NoJumpingSprite ;switch to jumping sprite when jumping
		a8
		lda #PLAYER_JUMPING_TILE
		sta playerTileNum
		lda #$1
		sta playerAnimTimer ;gets decremented to 0, this makes it go right back to walking animation
		lda #ANIM_MODE_SUBTRACT
		sta playerAnimMode
		bra DoneAnim
	NoJumpingSprite:

	a8
	lda playerAnimTimer ;is timer zero?
	bne DoneAnim
		lda #PLAYER_TIMER_VAL
		sta playerAnimTimer
		lda playerAnimMode
		bne AnimSubtract
			lda playerTileNum ;add to tile nim
			ina
			ina
			sta playerTileNum
			cmp #LAST_PLAYER_TILE ;if up to last tile, go to subtract mode
			bne DoneAnim
				lda #ANIM_MODE_SUBTRACT
				sta playerAnimMode
				jmp DoneAnim
		AnimSubtract: ;subtract from tile num
			lda playerTileNum
			dea
			dea
			sta playerTileNum
			cmp #FIRST_PLAYER_TILE
			bne DoneAnim
				lda #ANIM_MODE_ADD
				sta playerAnimMode
	DoneAnim:
	
	plp
	rts
	
	