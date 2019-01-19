.segment "CODE"
;2 way scrolling code (eventually)

sourceAddr = $0
destAddr = $2

InitScroll:
	lda #BGTilemap ;address of first offscreen column
	sta scrollScreenAddr
	rts

HandleScroll:
	lda scrollX
	lsr
	lsr
	lsr
	lsr ;leftmost tile column on screen
	clc
	adc #$11 ;first offscreen tile
	cmp scrollColumn ;beyond a new scroll boundary?
	bcc EndHandleScroll
	beq EndHandleScroll
		sta scrollColumn
		and #$1f
		bne NotOnScreenBoundary
			lda scrollScreenAddr
			clc
			adc #$380 ;32 columns, 14 rows, 1 word per tile
			sta scrollScreenAddr
	NotOnScreenBoundary:
		lda scrollColumn
		and #$1f
		asl
		clc
		adc scrollScreenAddr
		sta scrollPtr
		sta sourceAddr ;set up source and destination pointers
		lda scrollColumn
		and #$1f
		asl
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
			lda (sourceAddr), y
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
	and #$1f
	asl
	clc
	adc #TilemapMirror
	sta sourceAddr
	
	lda scrollColumn
	and #$1f
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
	