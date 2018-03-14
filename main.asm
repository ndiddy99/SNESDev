.include "header.inc"
.include "initSNES.inc"
.include "defines.asm"
.include "variables.asm"
.include "macros.asm"
.include "sprites.asm"
.include "art.asm"
.include "larry.asm"
.include "sound.asm"

.segment "CODE"
Reset:
	InitSNES
	jsl LoadSPC
	LoadPalette BGPalette, 0, $100
    LoadPalette SpritePalette, $80, $F
	; Load Tile data to VRAM
    LoadBlockToVRAM BGTiles, $2000, $0040	; 2 tiles, 2bpp, = 32 bytes
	LoadBlockToVRAM LarryTiles, $6000, $2000 ;16x16, 4bpp=128 bytes
	LoadBlockToVRAM BGTilemap, $0000, $2000
	
    ; Setup Video modes and other stuff, then turn on the screen
    jsr SetupVideo
	jsr InitSprites
	lda #$81
	sta $4200 ;enable vblank interrupt and joypad read
	lda #$00 ;idk why but sometimes spc writes crash the cpu without this line, at least on no$sns
	;did a bit more debugging, looks like it's a conflict b/t loading larrytiles and bgtilemap to vram
	rep #$20
	.a16
	lda #$11b
	sta scrollY
	sep #$20
	.a8
	lda #$50
	sta spriteX
.define GROUND_Y $B0
	lda #GROUND_Y
	sta spriteY
MainLoop:
	lda $4219 ;p1 joypad read address ;if yes but it is no longer pressed, state=RIGHT_RELEASED
	bit #JOY_RIGHT
	beq AssignRightReleased ;if it is still being pressed, state=RIGHT_PRESSED
	lda #STATE_RIGHT_PRESSED
	sta movementState
	lda #$30 ;max sprite priority
	sta playerAttrs
	jmp EndRightAssign
	
AssignRightReleased:
	lda movementState
	cmp #STATE_RIGHT_PRESSED ;was right pressed last frame?
	bne EndRightAssign ;if no, skip
	lda #STATE_RIGHT_RELEASED
	sta movementState
	
EndRightAssign:

	lda $4219 ;p1 joypad read address ;if yes but it is no longer pressed, state=RIGHT_RELEASED
	bit #JOY_LEFT
	beq AssignLeftReleased ;if it is still being pressed, state=RIGHT_PRESSED
	lda #STATE_LEFT_PRESSED
	sta movementState
	lda #$70 ;max sprite priority, mirrored
	sta playerAttrs
	jmp EndLeftAssign
	
AssignLeftReleased:
	lda movementState
	cmp #STATE_LEFT_PRESSED ;was right pressed last frame?
	bne EndLeftAssign ;if no, skip
	lda #STATE_LEFT_RELEASED
	sta movementState
	
EndLeftAssign:

;if player is on ground, assign jump state
	lda $4219
	bit #JOY_B
	beq JumpNotPressed
	lda playerState
	cmp #STATE_GROUND
	bne JumpNotPressed
	lda #STATE_JUMP_RISE
	sta playerState
	lda #MAX_LARRY_JUMP_HEIGHT
	sta playerVSpeed
JumpNotPressed:
	
EndStateAssigns:
	

;accelerate player until reaches max speed
	lda movementState
	cmp #STATE_RIGHT_PRESSED
	bne RightNotPressed
	
	lda playerHSpeed
	cmp #MAX_LARRY_SPEED
	beq @DontAdd
	clc
	adc #LARRY_ACCEL
	sta playerHSpeed
@DontAdd:
	a16
	lda scrollX
	clc
	adc playerHSpeed
	sta scrollX
	a8
RightNotPressed:

;decelerate player right until they stop
	lda movementState
	cmp #STATE_RIGHT_RELEASED
	bne RightNotReleased
	
	lda playerHSpeed
	cmp #$0
	bne @Subtract
	lda #STATE_NONE
	sta movementState
	jmp RightNotReleased
@Subtract:
	sec
	sbc #LARRY_ACCEL
	sta playerHSpeed
	a16
	lda scrollX
	clc
	adc playerHSpeed
	sta scrollX
	a8
RightNotReleased:

;accelerate player until they hit max speed
	lda movementState
	cmp #STATE_LEFT_PRESSED
	bne LeftNotPressed
	
	lda playerHSpeed
	cmp #MAX_LARRY_SPEED
	beq @DontAdd
	clc
	adc #LARRY_ACCEL
	sta playerHSpeed
@DontAdd:
	a16
	lda scrollX
	sec
	sbc playerHSpeed
	sta scrollX
	a8
LeftNotPressed:

;decelerate player until they stop
	lda movementState
	cmp #STATE_LEFT_RELEASED
	bne LeftNotReleased
	
	lda playerHSpeed
	cmp #$0
	bne @Subtract
	lda #STATE_NONE
	sta movementState
	jmp LeftNotReleased
@Subtract:
	sec
	sbc #LARRY_ACCEL
	sta playerHSpeed
	a16
	lda scrollX
	sec
	sbc playerHSpeed
	sta scrollX
	a8
LeftNotReleased:

;animate player based on speed
	PositiveDiff spriteX, lastAnimPoint
	cmp #MAX_LARRY_SPEED ;if sprite pos is less than max speed, don't animate
	bcc DontAnimate
	lda playerTileNum
	ina
	ina
	sta playerTileNum
	cmp #NUM_LARRY_TILES
	bne DontAnimate
	lda #$2
	sta playerTileNum
	lda scrollX+1
	sta lastAnimPoint
DontAnimate:

	lda movementState
	cmp #STATE_NONE
	bne DontStandStill
	lda #$0
	sta playerTileNum
DontStandStill:
	
;1. subtract gravity accel value until initial speed is 0
;2. set state to fall
	
	lda playerState
	cmp #STATE_JUMP_RISE
	bne DontRise
	lda playerVSpeed
	bne @SubSpeed ;branch if player v speed isn't 0
	lda #STATE_JUMP_FALL
	sta playerState
	jmp DontRise
@SubSpeed:
	sec
	sbc #LARRY_ACCEL
	sta playerVSpeed
	lda spriteY
	sec
	sbc playerVSpeed
	sta spriteY
DontRise:

;3. add gravity accel value until player touches ground
;4. set state to ground
	
	lda playerState
	cmp #STATE_JUMP_FALL
	bne DontFall
	lda spriteY
	cmp #GROUND_Y
	bne @AddSpeed
	lda #STATE_GROUND
	sta playerState
	jmp DontFall
@AddSpeed:
	lda playerVSpeed
	clc
	adc #LARRY_ACCEL
	sta playerVSpeed
	lda spriteY
	clc
	adc playerVSpeed
	sta spriteY
DontFall:

	SetHScroll scrollX
	SetVScroll scrollY
	HandleLarry spriteX,spriteY,playerTileNum
	wai
	jmp MainLoop
	
VBlank:
	pha ;push regs to stack so if my main loop is ever too long it'll continue without
	phx ;fucking up
	phy
	jsr DMASpriteMirror
	lda $4210 ;clear vblank flag
	ply
	plx
	pla
	
	rti
	
SetupVideo:
    php
	
	lda #$73
	sta $2101 ;16x16 or 32x32 sprites, sprite data @ $6000
	stz $2102 ;oam starts at $0 vram
	stz $2103
	lda #$1
    sta $2105           ; Set Video mode 1, 8x8 tiles

    lda #$03           ; Set BG1's Tile Map offset to $0000 (Word address)
    sta $2107           ; And the Tile Map size to 64x64

	lda #$52
    sta $210B           ; Set BG1's Character VRAM offset to $2000 (word address), BG2's to $5000

    lda #$11            ; Enable BG1 and sprites
    sta $212C

    lda #$FF ;bg1 horizontal scroll to -1 to fix weird stuff
    sta $210E
    sta $210E

    lda #$0F
    sta $2100           ; Turn on screen, full Brightness

    plp
    rts
	
DMASpriteMirror:
	stz $2102		; set OAM address to 0
	stz $2103

	LDY #$0400
	STY $4300		; CPU -> PPU, auto increment, write 1 reg, $2104 (OAM data write)
	LDY #$0400
	STY $4302		; source offset
	LDY #$0220
	STY $4305		; number of bytes to transfer
	LDA #$7E
	STA $4304		; bank address = $7E  (work RAM)
	LDA #$01
	STA $420B		;start DMA transfer
	rts