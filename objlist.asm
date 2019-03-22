.segment "CODE"

; local vars:
; $a : sprite number (objectCursor + 2)
; $c : onscreen x pos (absolute x - scroll x)
; $e : sprite y pos

InitObject:
	php
	a16
	lda #$40
	sta ObjectList+2
	lda #$80
	sta ObjectList+6
	lda #MOVE_STATE_FALLING
	sta ObjectList+16
	lda #Enemy1Handler-1
	sta ObjectList+20
	lda #$1
	sta numObjects
	plp
	rts

ProcessObjects:
	php
	a16
	stz objectCursor
	stz objectIndex
	
	ProcessLoop:
	lda objectCursor
	cmp numObjects
	beq DoneProcess
		lda #ObjectList
		clc
		adc objectIndex
		pha ;store source for later
		tax ;source for block copy
		ldy #collisionX ;destination
		lda #(OBJ_ENTRY_SIZE-1) ;size - 1
		mvn $0, $0
		lda ObjectList+20
		jsr FunctionLauncher
		; jsr Enemy1Handler
		jsr HandleCollision
		ldx #collisionX ;source
		ply ;destination
		lda #(OBJ_ENTRY_SIZE-1) ;size - 1
		mvn $0, $0
		
		lda objectCursor
		clc
		adc #$2
		sta $a
		
		ldx objectIndex
		inx
		inx ;get non-decimal x pos
		lda ObjectList, x
		sec
		sbc scrollX
		sta $c
		
		txa
		clc
		adc #$4
		tax ;non-decimal y pos
		lda ObjectList, x
		clc
		adc #$10
		sta $e
		LoadSprite $a, #$40, $c, $e, #%00110010
		
		DoneSprite:
		inc objectCursor
		lda objectIndex
		clc
		adc #OBJ_ENTRY_SIZE
		sta objectIndex
		bra ProcessLoop
	DoneProcess:
	plp
	rts
	
FunctionLauncher:
	pha
	rts
