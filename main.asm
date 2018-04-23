.include "header.inc"
.include "initSNES.inc"
.include "constants.asm"
.include "macros.asm"
.include "sprites.asm"
.include "art.asm"
.include "larry.asm"
.include "sound.asm"

.segment "CODE"
Reset:
	InitSNES
	jsl LoadSPC
	ldx #$0
	lda #$2
	LoadPalette BGPalette, 0, $10
	LoadPalette BG2Palette, $10, $10
    LoadPalette SpritePalette, $80, $F
	; Load Tile data to VRAM
    LoadBlockToVRAM BGTiles, $2000, $C0	
	LoadBlockToVRAM BG2Tiles, $5000, $200 ;8 tiles, 4bpp
	LoadBlockToVRAM LarryTiles, $6000, $800
	LoadBlockToVRAM BGTilemap, $0000, $2000
	LoadBlockToVRAM BG2Tilemap, $4000, $800
	LoadBlockToWRAM BGTilemap, TilemapMirror, $2000
    ; Setup Video modes and other stuff, then turn on the screen
    jsr SetupVideo
	
	jsr InitSprites
	lda #$81
	sta $4200 ;enable vblank interrupt and joypad read
	lda #$00 ;idk why but sometimes spc writes crash the cpu without this line, at least on no$sns
	;did a bit more debugging, looks like it's a conflict b/t loading larrytiles and bgtilemap to vram
	a16
	lda #$11b
	sta scrollY
	sep #$20
	a8
	lda #$50
	sta spriteX
	
.define GROUND_Y $B0
	lda #GROUND_Y
	sta spriteY
	
	lda #$30 ;max sprite priority
	sta playerAttrs
	
	
MainLoop:
	lda #$1
	sta frameStatus ;how we check if the program's done executing
	lda $4219 ;p1 joypad read address ;if yes but it is no longer pressed, state=RIGHT_RELEASED
	bit #JOY_RIGHT
	beq AssignRightReleased ;if it is still being pressed, state=RIGHT_PRESSED
	lda playerHSpeed
	bne EndRightAssign
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
	lda playerHSpeed
	bne EndLeftAssign
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
	lda #LARRY_JUMP_FRAME
	sta playerTileNum
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
	and #$3ff ;limit to 10 bits
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
	and #$3ff ;limit to 10 bits
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
	and #$3ff
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
	and #$3ff
	sta scrollX
	a8
LeftNotReleased:

;animate player based on speed
	lda playerState
	cmp #STATE_GROUND
	bne DontAnimate
	lda movementState
	cmp #STATE_NONE
	beq DontAnimate
	
	lda playerTileNum
	ina
	ina
	sta playerTileNum
	cmp #NUM_LARRY_TILES
	bcc DontAnimate
	lda #$2
	sta playerTileNum
DontAnimate:

	;if player isn't above solid surface, fall
	lda playerState
	cmp #STATE_GROUND
	bne DontApplyGravity
	jsr SetPlayerVals
	jsr CheckCollisionB
	bne DontApplyGravity
	lda #STATE_JUMP_FALL
	sta playerState
DontApplyGravity:
	
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
	jsr SetPlayerVals ;have player fall until they're inside the ground
	jsr CheckCollisionB
	beq @AddSpeed
@EjectLoop: ;eject player from the ground
	dec spriteY
	jsr SetPlayerVals
	jsr CheckCollisionB
	bne @EjectLoop
	inc spriteY ;insert player one pixel into the ground so they won't be constantly falling
	lda #STATE_GROUND
	sta playerState
	stz playerVSpeed
	stz playerTileNum
	jmp DontFall
@AddSpeed:
	lda playerVSpeed
	cmp #MAX_LARRY_FALL_SPEED
	bcs @DontAdd
	clc
	adc #LARRY_ACCEL
	sta playerVSpeed
@DontAdd:
	lda spriteY
	clc
	adc playerVSpeed
	sta spriteY
DontFall:
	
	jsr SetPlayerVals
	lda movementState
	beq EndCollisionDetect ;if player's not moving, don't bather w/ wall collision detection
	cmp #STATE_LEFT_PRESSED
	bcs LCollision ;if state is left pressed or left released, branch
	jsr CheckCollisionR
	beq EndCollisionDetect
@EjectLoop:
	dec scrollX
	jsr SetPlayerVals
	jsr CheckCollisionR
	bne @EjectLoop ;eject player from the wall until they're out
	stz playerHSpeed ;if player needs to be ejected, set speed to 0
	jmp EndCollisionDetect
LCollision:
	jsr CheckCollisionL
	beq SubtractSpeed
@EjectLoop:
	inc scrollX
	jsr SetPlayerVals
	jsr CheckCollisionL
	bne @EjectLoop
	stz playerHSpeed
	jmp SubtractSpeed
EndCollisionDetect:
	;calculate bg2's scroll
	a16
	lda playerHSpeed
	ror
	sta $0
	lda scroll2X
	clc
	adc $0
	sta scroll2X
	stz $0
	jmp SetupScrollTable
SubtractSpeed:
	a16
	lda playerHSpeed
	ror
	sta $0
	lda scroll2X
	sec
	sbc $0
	sta scroll2X
	stz $0
SetupScrollTable:
	clc
	lda scroll2X
	clc
	adc #$5
	sta scroll2X
	ror
	sta BG2ScrollTable
	ror
	sta BG2ScrollTable+2
	ror
	sta BG2ScrollTable+4
	ror
	sta BG2ScrollTable+6
	ror
	sta BG2ScrollTable+8
	a8
	HandleLarry spriteX,spriteY,playerTileNum
	; DrawLine #$2, #$11, #$15, #$15
	
	stz frameStatus
	wai
	jmp MainLoop
	
VBlank:
	php
	phb
	phd
	pha ;push regs to stack so if my main loop is ever too long it'll continue without
	phx ;fucking up
	phy
	lda frameStatus
	bne SkipVblank
	SetHScroll scrollX
	SetVScroll scrollY
	;DMATilemapMirror #$2
	jsr DMASpriteMirror
	lda #$1 ;start dma transfer on channel 1 (change to 3 if i reenable dmatilemapmirror)
	sta $420b
	jsr SetupHDMA
	lda $4210 ;clear vblank flag
SkipVblank:
	ply
	plx
	pla
	pld
	plb
	plp
	
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
	
	lda #$40  ; bg2 tilemap offset: $4000, size: 32x32
	sta $2108

	lda #$52
    sta $210B           ; Set BG1's Character VRAM offset to $2000 (word address), BG2's to $5000

    lda #$13            ; Enable BG1, BG2, and sprites
    sta $212C

    lda #$FF ;bg1 horizontal scroll to -1 to fix weird stuff
    sta $210E
    sta $210E

    lda #$0F
    sta $2100           ; Turn on screen, full Brightness

    plp
    rts
	
SetupHDMA:
	lda #%01000010 ;write twice, indirect mode
	sta $4300
	lda #$0f ;write to $210f, bg 2 scroll reg
	sta $4301
	a16
	lda #ScrollTable
	sta $4302
	lda #$0
	sta $4304
	a8
	lda #$7e
	sta $4307 ;ram bank to read from for indirect hdma
	
	lda #$2 ;write twice, direct mode
	sta $4310
	lda #$21 ;write to $2121, cgram palette address reg
	sta $4311
	a16
	lda #PaletteIndexTable
	sta $4312
	stz $4314
	a8

	lda #$2 ;write twice, direct mode
	sta $4320
	lda #$22 ;write to $2122, cgram palette data reg
	sta $4321
	a16
	lda #GradientTable
	sta $4322
	stz $4324
	a8	
	lda #$7
	sta $420c ;enable hdma channels 0-2
	rts
	
	
ScrollTable:
	.byte $80
	.word $0000
	.byte $10
	.word BG2ScrollTable+8
	.byte $10
	.word BG2ScrollTable+6
	.byte $10
	.word BG2ScrollTable+4
	.byte $10
	.word BG2ScrollTable+2
	.byte $10
	.word BG2ScrollTable
	.byte $00

PaletteIndexTable: ;needed because palette index auto-increments after every write
;400 instead of $4 because the endianness of the CGRAM write port is reversed for some reason
	.byte $C
	.word $400
	.byte $C
	.word $400
	.byte $C
	.word $400
	.byte $C
	.word $400
	.byte $C
	.word $400
	.byte $C
	.word $400
	.byte $C
	.word $400
	.byte $C
	.word $400
	.byte $C
	.word $400
	.byte $C
	.word $400
	.byte $C
	.word $400
	.byte $00
	
	
GradientTable:
	.byte $C
	.word $71C4; R:4 G:14 B:28
	.byte $C
	.word $5DC7; R:7 G:14 B:23
	.byte $C
	.word $51CB; R:11 G:14 B:20
	.byte $C
	.word $49CD; R:13 G:14 B:18
	.byte $C
	.word $41F1; R:17 G:15 B:16
	.byte $C
	.word $35F4; R:20 G:15 B:13
	.byte $C
	.word $2DF7; R:23 G:15 B:11
	.byte $C
	.word $221A; R:26 G:16 B:8
	.byte $C
	.word $1A1C; R:28 G:16 B:6
	.byte $C
	.word $121F; R:31 G:16 B:4
	.byte $C
	.word $71A1
	.byte $00
	
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
	rts
	