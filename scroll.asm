.segment "CODE"
;2 way scrolling code (eventually)

sourceAddr = $0
destAddr = $2
columnNum = $4

InitScroll:
	lda #BGTilemap ;address of first offscreen column
	sta scrollScreenAddr
	
	pea $0002
	plb
	lda BGRightLim
	sta rScrollLim
	plb
	
	rts
	
HandleScroll:
	php
	a16
	lda playerX+2
	cmp #$80 ; if playerX < $80
	beq LockL
	bcs NoLockL
	LockL:
		sta playerSpriteX ;spriteX = playerX
		stz scrollX ;scrollX = 0
		bra EndSetScroll
	NoLockL:
	
	lda playerX+2
	cmp rScrollLim ;if playerX > rScrollLim
	bcc NoLockR
		sec ;playerSpriteX = playerX - rScrollLim + #$80 (middle of screen)
		sbc rScrollLim
		clc
		adc #$80
		sta playerSpriteX
		
		lda rScrollLim ;scrollX + rScrollLim - #$80 & #$3ff
		sec
		sbc #$80
		and #$3ff
		sta scrollX
		jmp EndHandleScroll ;since we're locked, don't need to scroll further
	NoLockR:
	
	lda playerX+2 ;else, keep sprite centered, do scrolling normally
	sec
	sbc #$80
	sta scrollX
	lda #$80
	sta playerSpriteX
	EndSetScroll:
	
	lda playerXSpeed
	bne NotZero ;if player's not moving, don't have to worry about scroll
	lda playerXSpeed+2
	bne NotZero
	bra DoneMovementTests
	
	NotZero:
	lda playerXSpeed+2
	and #$8000
	beq MovingRight
	;if going left and scroll & 1f goes up, that means you wrapped (so should change screen addy)
	;same if going right and scroll & 1f goes down
	MovingLeft:
	lda scrollX
	lsr
	lsr
	lsr
	lsr ;leftmost onscreen column
	dec a ;first offscreen column to the left
	and #$1f
	cmp scrollColumn
	beq EndHandleScroll ; if it's the same, don't have to do anything
	sta scrollColumn
	bcc DoneMovementTests ;if it's less, normal screen movement
		lda scrollScreenAddr
		sec
		sbc #$380 ;32 columns, 14 rows, 1 word per tile
		sta scrollScreenAddr
		dec scrollScreenNum
		bra DoneMovementTests
	
	MovingRight:
	lda scrollX
	lsr
	lsr
	lsr
	lsr ;leftmost tile column on screen
	clc
	adc #$11 ;first offscreen tile
	and #$1f
	cmp scrollColumn ;beyond a new scroll boundary?
	beq EndHandleScroll ;same? don't do anything
	sta scrollColumn
	bcs DoneMovementTests ;greater? tile pos didn't wrap
		lda scrollScreenAddr ;otherwise, you've reached a new screen
		clc
		adc #$380 ;32 columns, 14 rows, 1 word per tile
		sta scrollScreenAddr
		inc scrollScreenNum
	NotOnScreenBoundary:
	
	DoneMovementTests:
		lda scrollColumn
		asl ;words->bytes
		pha ;>
		clc
		adc scrollScreenAddr
		sta sourceAddr
		pla ;<
		clc
		adc #TilemapMirror
		sta scrollMirrorPtr
		ldx #$e ;number of tiles to copy
		ldy #$0
		pea $0002 ;bank with map data: $2 return bank: $0
							;doesn't use immediate syntax for some reason
		plb ;load $2 from stack
		@CopyLoop:
			lda (sourceAddr), y
			sta (scrollMirrorPtr), y
			tya
			clc
			adc #$40
			tay
			dex
			bne @CopyLoop
		plb ;load $0 from stack
	EndHandleScroll:
	plp
	rts
	
VramScrollCopy: ;run during vblank if there's new tile data to copy
	a8
	lda #$81 ;increment vram access by 64 bytes
	sta PPUCTRL
	a16
	; lda scrollColumn
	; asl
	; clc
	; adc #TilemapMirror ;copy from tilemap mirror to real tilemap
	; sta sourceAddr
	
	lda scrollColumn
	sta PPUADDR ;set up where to write to in VRAM
	ldx #$e ;number of tiles to copy
	ldy #$0
	@CopyLoop:
		lda (scrollMirrorPtr), y
		sta PPUDATA
		tya
		clc
		adc #$40
		tay
		dex
		bne @CopyLoop
	stz scrollMirrorPtr ;how I mark that the tile column has been copied already
	a8
	rts
	