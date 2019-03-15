.segment "CODE"

HandleCollision:
.scope

	a16
	php
	
	lda collisionXSpeed+2
	and #$8000
	beq CheckRightCollision
		jsr HandleXCollisionL ;going left
		bra EndCheckCollision
	CheckRightCollision:
		jsr HandleXCollisionR
	EndCheckCollision:
	
	lda movementState ;eject vertically to the next tile when walking off a slope
	cmp #MOVE_STATE_SLOPE
	bne @NotOnSlope
		jsr CheckYCollisionD ;if on a non-slope tile and was on a slope
		beq @NotOnSlope
		tax
		lda TileAttrs, x
		bne @NotOnSlope
			lda #MOVE_STATE_NORMAL
			sta movementState
			@EjectLoop: ;vertical eject
				dec collisionY+2
				jsr CheckYCollisionD
				beq @NotOnSlope
				tax
				lda TileAttrs, x
				bne @NotOnSlope
			bra @EjectLoop
	@NotOnSlope:
	
	lda movementState
	cmp #MOVE_STATE_JUMPING
	beq OnGround
	cmp #MOVE_STATE_FALLING
	beq OnGround
		jsr CheckYCollisionD
		beq StartFall
			tax
			lda TileAttrs, x
			bne SlopeInsertLoop
		bra OnGround
			SlopeInsertLoop: ;if on a slope tile, insert into ground until touching a non-slope tile
				inc collisionY+2
				jsr CheckYCollisionD
				tax
				lda TileAttrs, x
				beq OnGround
			bra SlopeInsertLoop 
		StartFall:	
			lda #MOVE_STATE_FALLING
			sta movementState
	OnGround:
	jsr HandleSlopeCollision

	lda movementState
	cmp #MOVE_STATE_JUMPING
	beq Jumping
	cmp #MOVE_STATE_FALLING
	beq Jumping
	jmp NotJumping
	Jumping:
		lda collisionYSpeed
		clc
		adc #GRAVITY
		sta collisionYSpeed
		lda collisionYSpeed+2
		adc #$0
		sta collisionYSpeed+2
		lda collisionY
		clc
		adc collisionYSpeed
		sta collisionY
		lda collisionY+2
		adc collisionYSpeed+2
		sta collisionY+2
		UEjectLoop:
		jsr CheckYCollisionU
		beq NoCollisionU
			stz collisionYSpeed
			stz collisionYSpeed+2
			inc collisionY+2
			bra UEjectLoop
		NoCollisionU:
		lda collisionYSpeed+2 ;if player isn't falling, don't check down collision
		and #$8000
		bne NotJumping
		jsr HandleYCollisionD
	NotJumping:
	
	plp
	rts
	
HandleXCollisionL:
	lda movementState ;no wall collision if on slope
	cmp #MOVE_STATE_SLOPE
	beq NoCollisionL
	jsr CheckXCollisionL
	beq NoCollisionL
	tax
	lda TileAttrs, x
	bne NoCollisionL
		stz collisionXSpeed
		stz collisionXSpeed+2
		stz collisionX
		bra :+
		LEjectLoop:
		jsr CheckXCollisionL
		beq DoneLEject
			tax
			lda TileAttrs, x
			bne NoCollisionL
		:	inc collisionX+2
			bra LEjectLoop
		DoneLEject:
	NoCollisionL:
	rts

HandleXCollisionR:
	lda movementState
	cmp #MOVE_STATE_SLOPE
	beq NoCollisionR
	jsr CheckXCollisionR
	beq NoCollisionR
	tax
	lda TileAttrs, x
	bne NoCollisionR
		stz collisionXSpeed
		stz collisionXSpeed+2
		lda #$ffff
		sta collisionX
		bra :+
		REjectLoop:
		jsr CheckXCollisionR
		beq DoneREject
			tax
			lda TileAttrs, x
			bne NoCollisionR
		:	dec collisionX+2
			bra REjectLoop
		DoneREject:
	NoCollisionR:	
	rts


HandleYCollisionD:
	jsr CheckYCollisionD ;0 = sprite in air
	beq NotInGround

	; tax
	; lda TileAttrs, x
	; beq NormalEject
	; jmp HandleSlopeCollision
	NormalEject:
		stz collisionYSpeed 
		stz collisionYSpeed+2
		stz collisionY
		lda #MOVE_STATE_NORMAL
		sta movementState
		; a8
		; lda #PLAYER_STILL_TILE
		; sta playerTileNum
		; lda #PLAYER_TIMER_VAL
		; sta playerAnimTimer
		; lda #ANIM_MODE_ADD
		; sta playerAnimMode
		; a16
		YEjectLoop:
			dec collisionY+2
			jsr CheckYCollisionD
			beq EjectedFromGround
			tax ;don't eject from ground if it's a slope tile
			lda TileAttrs, x
			bne EjectedFromGround
		bra YEjectLoop
		EjectedFromGround:
			inc collisionY+2
	NotInGround:
	rts
	
	;collisionY = ((collisionY + PLAYER_HEIGHT-1) & $FFF0) - (tileLut, (middle of sprite x & $F)) - $10
HandleSlopeCollision:
	lda movementState
	cmp #MOVE_STATE_JUMPING
	beq NotOnSlope
	jsr CheckCollisionC
	tax
	lda TileAttrs, x
	beq NotOnSlope
		sta $4 ;location of height LUT for that block
		lda currBGTile
		and #$4000 
		bne SubXCalc
			lda $0 ;x value of middle of sprite
			and #$000f
			asl ;words->bytes
			tay
			bra EndXCalc
		SubXCalc:
			lda $0 ;x value of middle of sprite
			and #$000f
			sta $0
			lda #$f ;if it's been mirrored, start looking at height LUT from the end of the tile
			sec
			sbc $0
			asl ;words->bytes
			tay
		EndXCalc:
		lda ($4), y
		sta $0 ;value to bump up y position by
		lda $2 ;tile where sprite's feet are
		and #$fff0
		sec
		sbc $0
		sec
		sbc #$10
		sta collisionY+2
		lda #MOVE_STATE_SLOPE
		sta movementState
		
		lda currBGTile
		and #$4000 ;has tile been mirrored?
		beq @SubtractMomentum
			lda collisionXSpeed
			clc
			adc MomentumTable, x
			sta collisionXSpeed
			lda collisionXSpeed+2
			adc #$0
			cmp #MAX_SLOPE_SPEED
			bne @DontCapAddSpeed
				stz collisionXSpeed
			@DontCapAddSpeed:
			sta collisionXSpeed+2
			bra NotOnSlope
		@SubtractMomentum:
			lda collisionXSpeed
			sec
			sbc MomentumTable, x
			sta collisionXSpeed
			lda collisionXSpeed+2
			sbc #$0
			cmp #-(MAX_SLOPE_SPEED+1)
			bne @DontCapSubSpeed
				lda #$ffff
				sta collisionXSpeed
				lda #-(MAX_SLOPE_SPEED+1)
			@DontCapSubSpeed:
			sta collisionXSpeed+2
	NotOnSlope:
	rts
	
CheckXCollisionL: ;for when player is moving left
	lda collisionX+2
	sta $0
	lda collisionY+2
	clc
	adc #PLAYER_HEIGHT-1
	sta $2
	jmp CheckCollision

CheckXCollisionR: ;when player is moving right
	lda collisionX+2
	clc
	adc #PLAYER_WIDTH
	sta $0
	lda collisionY+2
	clc
	adc #PLAYER_HEIGHT-1
	sta $2
	jmp CheckCollision

;center collision -> left collision -> right collision	
CheckYCollisionD:
	lda collisionX+2 ;1. check for bottom-center collision
	clc
	adc #PLAYER_WIDTH/2
	sta $0
	lda collisionY+2
	clc
	adc #PLAYER_HEIGHT+1
	sta $2
	jsr CheckCollision
	bne @EndCheck ;if center hard collision, exit routine
	
	lda collisionX+2 ;2. check for bottom-left collision
	sta $0
	jsr CheckCollision
	bne @EndCheck
	
	lda collisionX+2 ;3. check for bottom-right collision
	clc
	adc #PLAYER_WIDTH
	sta $0
	jsr CheckCollision
	@EndCheck:
	rts

CheckYCollisionU: ;when player is moving up
	lda collisionX+2 ;1. check for bottom-center collision
	clc
	adc #PLAYER_WIDTH/2
	sta $0
	lda collisionY+2
	clc
	adc #PLAYER_TOP+2
	sta $2
	jsr CheckCollision
	bne @EndCheck ;if center collision, exit routine
	
	lda collisionX+2 ;2. check for bottom-left collision
	sta $0
	jsr CheckCollision
	bne @EndCheck
	
	lda collisionX+2 ;3. check for bottom-right collision
	clc
	adc #PLAYER_WIDTH
	sta $0
	jsr CheckCollision
	@EndCheck:
	rts
	
CheckCollisionC: ;look at the center of the bottom of the player
	lda collisionX+2
	clc
	adc #(PLAYER_WIDTH/2)
	sta $0
	lda collisionY+2
	clc
	adc #PLAYER_HEIGHT-1
	sta $2
	
CheckCollision:
	lda $0 ;divide by 16
	and #$1ff
	lsr
	lsr
	lsr
	lsr
	sta currBGTile
	lda $2 ;dividing y tile by 16 and then multiplying by 32 since tilemap's 32x32
	clc
	adc scrollY
	and #$fff0	  ;is the same as removing last nibble and shifting left once
	rol
	clc
	adc currBGTile
	rol ;words->bytes
	tax
	lda TilemapMirror, x
	pha
	and #$43ff ;just get the 9 bit tile number and the x flip bit
	sta currBGTile
	pla
	and #$3ff
	rts
	
.endscope
