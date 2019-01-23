.segment "CODE"
;2 way scrolling code (eventually)

sourceAddr = $0
destAddr = $2
columnNum = $4

InitScroll:
	lda #BGTilemap ;address of first offscreen column
	sta scrollScreenAddr
	rts
	
HandleScroll:
	lda playerDirection ;0 = still, 1 = left, 2 = right
	beq EndHandleScroll ;if player's not moving, don't have to worry about scroll
	cmp #$2 
	beq MovingRight
	;issue: if the left and right boundaries are on 2 different screens, scroll screws up
	;because of how i set scrollScreenAddr
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
	NotOnScreenBoundary:
	
	DoneMovementTests:
		lda scrollColumn
		asl ;words->bytes
		pha ;>
		clc
		adc scrollScreenAddr
		sta scrollPtr
		pla ;<
		adc #TilemapMirror
		sta destAddr
		ldx #$e ;number of tiles to copy
		ldy #$0
		a8
		lda #$2 ;bank with map data
		pha
		plb
		a16
		@CopyLoop:
			lda (scrollPtr), y
			sta (destAddr), y
			tya
			clc
			adc #$40
			tay
			dex
			bne @CopyLoop
		a8
		lda #$0
		pha
		plb
		a16
	EndHandleScroll:
	rts
	
VramScrollCopy: ;run during vblank if there's new tile data to copy
	a8
	lda #$1 ;increment vram access by 64 bytes
	sta PPUCTRL
	a16
	lda scrollColumn
	asl
	clc
	adc #TilemapMirror ;copy from tilemap mirror to real tilemap
	sta sourceAddr
	
	lda scrollColumn
	sta PPUADDR ;set up where to write to in VRAM
	
	ldx #$e ;number of tiles to copy
	ldy #$0
	@CopyLoop:
		lda (sourceAddr), y
		sta PPUDATA
		tya
		clc
		adc #$40
		tay
		dex
		bne @CopyLoop
	a8
	rts
	