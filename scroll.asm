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
		lda #$2
		pha
		plb
		a16
		CopyLoop:
			lda (sourceAddr), y
			sta (destAddr), y
			tya
			clc
			adc #$40
			tay
			dex
			bne CopyLoop
		a8
		lda #$0
		pha
		plb
		a16
	EndHandleScroll:
	rts
	