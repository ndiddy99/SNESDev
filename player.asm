.segment "CODE"

PLAYER_ACCEL = $3fff ;0.25 px
MAX_PLAYER_SPEED = $3

.enum
STATE_STILL
STATE_RIGHT_HELD 
STATE_RIGHT_RELEASED
STATE_LEFT_HELD
STATE_LEFT_RELEASED
.endenum	

HandlePlayerMovement:
	a16
	lda joypad 
	cmp #KEY_RIGHT ;sets up player state based on joypad input
	bne NotRight
		a8
		lda #STATE_RIGHT_HELD
		sta playerState
		a16
		jmp EndStateAssign
	NotRight:
	cmp #KEY_LEFT
	bne NotLeft
		a8
		lda #STATE_LEFT_HELD
		sta playerState
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
	
	LoadSprite #$0, #$20, playerX+2, playerY+2, #%00110000
	rts
	