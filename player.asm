.segment "CODE"

PLAYER_ACCEL = $3fff ;0.25 px
; PLAYER_JUMP_SPEED = $fff8 ;-7
PLAYER_JUMP_SPEED = $fff4 ;-7
GRAVITY = $6fff ;~0.4px


MAX_PLAYER_SPEED = $2
PLAYER_STILL_TILE = $0
FIRST_PLAYER_TILE = $2
LAST_PLAYER_TILE = $8 ;horizontally
PLAYER_JUMPING_TILE = $E
PLAYER_TIMER_VAL = $6 ;animation timer
GROUND = $B0

PLAYER_RIGHT_ATTRS = %00110000
PLAYER_LEFT_ATTRS =  %01110000

PLAYER_WIDTH = $10

.enum
STATE_STILL
STATE_RIGHT_HELD 
STATE_RIGHT_RELEASED
STATE_LEFT_HELD
STATE_LEFT_RELEASED
.endenum

.enum
PLAYER_STATE_NORMAL
PLAYER_STATE_JUMPING
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
	lda playerState
	cmp #STATE_RIGHT_HELD
	bne RightNotReleased
		lda #STATE_RIGHT_RELEASED
		sta playerState
		jmp EndStateAssign
	RightNotReleased:
	cmp #STATE_LEFT_HELD
	bne LeftNotReleased
		lda #STATE_LEFT_RELEASED
		sta playerState
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
	
	a8 ;if not pressing any buttons, reset tile and animation timer
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
	
	AddSpeed: ;add speed to playerx when going right
		lda playerX
		clc
		adc playerXSpeed
		sta playerX
		lda playerX+2
		adc playerXSpeed+2
		sta playerX+2
		
		REjectLoop:
		jsr CheckXCollisionR
		beq NoCollisionR
			stz playerXSpeed+2
			stz playerXSpeed
			dec playerX+2
			jmp REjectLoop
		NoCollisionR:
		jmp EndStateMachine
		
	SubtractSpeed: ;subtract speed from playerx when going left
		lda playerX
		sec
		sbc playerXSpeed
		sta playerX
		lda playerX+2
		sbc playerXSpeed+2
		sta playerX+2
		
		LEjectLoop:
		jsr CheckXCollisionL
		beq NoCollisionL
			stz playerXSpeed+2
			stz playerXSpeed
			inc playerX+2
			jmp LEjectLoop
		NoCollisionL:
	EndStateMachine:
	
	lda joypad
	bit #KEY_B
	beq DontStartJump
		lda #PLAYER_STATE_JUMPING
		cmp movementState
		beq NotRising ;don't want player jumping in air
			sta movementState
			lda #PLAYER_JUMP_SPEED
			sta playerYSpeed+2
			jmp NotRising
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
	
	
	lda movementState
	cmp #PLAYER_STATE_JUMPING
	bne NotJumping
		lda playerYSpeed
		clc
		adc #GRAVITY
		sta playerYSpeed
		lda playerYSpeed+2
		adc #$0
		sta playerYSpeed+2
		lda playerY
		clc
		adc playerYSpeed
		sta playerY
		lda playerY+2
		adc playerYSpeed+2
		sta playerY+2
		cmp #GROUND
		bcc NotInGround ;if player y is greater than ground, no longer jumping
			stz playerYSpeed
			stz playerYSpeed+2
			lda #GROUND
			sta playerY+2
			stz playerY
			lda #PLAYER_STATE_NORMAL
			sta movementState
			a8
			lda #PLAYER_STILL_TILE
			sta playerTileNum
			lda #PLAYER_TIMER_VAL
			sta playerAnimTimer
			lda #ANIM_MODE_ADD
			sta playerAnimMode
			a16
		NotInGround:
	NotJumping:
	
	a8
	lda movementState
	cmp #PLAYER_STATE_JUMPING
	bne NoJumpingSprite ;switch to jumping sprite when jumping
		lda #PLAYER_JUMPING_TILE
		sta playerTileNum
		jmp DrawSprite
	NoJumpingSprite:
	
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
	LoadSprite #$0, playerTileNum, playerX+2, playerY+2, playerAttrs
	lda playerY+2
	clc
	adc #$10
	sta $a
	lda playerTileNum
	clc
	adc #$20
	sta $c
	LoadSprite #$1, $c, playerX+2, $a, playerAttrs
	
	plp
	rts
	
CheckXCollisionL: ;for when player is moving left
	lda playerX+2
	sta $0
	lda playerY+2
	sta $2
	jmp CheckPlayerCollision

CheckXCollisionR:
	lda playerX+2
	clc
	adc #PLAYER_WIDTH
	sta $0
	lda playerY+2
	sta $2
	
CheckPlayerCollision:
	lda $0 ;divide by 16, the clcs are so it doesn't wrap around
	clc
	ror
	clc
	ror
	clc
	ror
	clc
	ror
	sta playerBGTile
	lda $2 ;dividing y tile by 16 and then multiplying by 32 since tilemap's 32x32
	clc
	adc scrollY
	and #$fff0	  ;is the same as removing last nibble and shifting left once
	rol
	clc
	adc playerBGTile
	rol ;words->bytes
	tax
	lda f:BGTilemap, x
	sta playerBGTile
	rts
	