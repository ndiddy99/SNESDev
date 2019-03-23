.segment "CODE"

ENEMY1_ACCEL = $5000
ENEMY1_MAXSPEED = $5
Enemy1Handler:
	.scope
	lda collisionX+2
	cmp playerX+2
	bcs OnLeft
		lda collisionXSpeed+2
		cmp #ENEMY1_MAXSPEED
		beq DoneX
			lda collisionXSpeed
			clc
			adc #ENEMY1_ACCEL
			sta collisionXSpeed
			lda collisionXSpeed+2
			adc #$0
			sta collisionXSpeed+2
			bra DoneX
	OnLeft:
		lda collisionXSpeed+2
		cmp #-(ENEMY1_MAXSPEED)
		beq DoneX
			lda collisionXSpeed
			sec
			sbc #ENEMY1_ACCEL
			sta collisionXSpeed
			lda collisionXSpeed+2
			sbc #$0
			sta collisionXSpeed+2
	DoneX:
	lda collisionX
	clc
	adc collisionXSpeed
	sta collisionX
	lda collisionX+2
	adc collisionXSpeed+2
	sta collisionX+2
	
	lda movementState
	cmp #MOVE_STATE_JUMPING
	beq DontJump
	cmp #MOVE_STATE_FALLING
	beq DontJump
	lda collisionY+2
	cmp playerY+2
	beq DontJump
	bcc DontJump
		lda #$fff9
		sta collisionYSpeed+2
		lda #MOVE_STATE_JUMPING
		sta movementState
	DontJump:
	.endscope
	rts
