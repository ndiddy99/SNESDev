.segment "CODE"

ENEMY1_ACCEL = $5000
ENEMY1_MAXSPEED = $5
Enemy1Handler:
	lda collisionX+2
	cmp playerX+2
	bcs OnLeft
		lda collisionXSpeed+2
		cmp #ENEMY1_MAXSPEED
		beq Done
			lda collisionXSpeed
			clc
			adc #ENEMY1_ACCEL
			sta collisionXSpeed
			lda collisionXSpeed+2
			adc #$0
			sta collisionXSpeed+2
			bra Done
	OnLeft:
		lda collisionXSpeed+2
		cmp #-(ENEMY1_MAXSPEED)
		beq Done
			lda collisionXSpeed
			sec
			sbc #ENEMY1_ACCEL
			sta collisionXSpeed
			lda collisionXSpeed+2
			sbc #$0
			sta collisionXSpeed+2
	Done:
	lda collisionX
	clc
	adc collisionXSpeed
	sta collisionX
	lda collisionX+2
	adc collisionXSpeed+2
	sta collisionX+2
	
	rts
