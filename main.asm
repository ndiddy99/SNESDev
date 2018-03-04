.include "header.inc"
.include "initSNES.inc"
.include "defines.asm"
.include "variables.asm"
.include "ppuMacros.asm"
.include "sprites.asm"
.include "art.asm"
.include "sound.asm"

.segment "CODE"
Reset:
	InitSNES
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
	
	rep #$20
	.a16
	lda #$11B ;default scroll pos
	sta scrollY
	sep #$20
	.a8
	
	lda #$B1
	sta spriteY
MainLoop:
	lda $4219 ;p1 joypad read address
	bit #JOY_LEFT
	beq NOT_LEFT
	rep #$20
	dec scrollX
	sep #$20
	dec spriteX
	dec spriteX
	
	lda #$70 ;max sprite priority, mirror sprite
	sta spriteAttrs
	
	inc spriteTileNum
	inc spriteTileNum
	lda spriteTileNum
	cmp #NUM_LARRY_TILES
	bne NOT_RIGHT
	lda #$2
	sta spriteTileNum
NOT_LEFT:
	lda $4219
	
	bit #JOY_RIGHT
	beq NOT_RIGHT
	rep #$20
	inc scrollX
	sep #$20
	inc spriteX
	inc spriteX
	
	lda #$30
	sta spriteAttrs ;max sprite priority
	
	inc spriteTileNum
	inc spriteTileNum
	lda spriteTileNum
	cmp #NUM_LARRY_TILES
	bne NOT_RIGHT
	lda #$2
	sta spriteTileNum
NOT_RIGHT:
	lda $4219

	; bit #JOY_UP
	; beq NOT_UP
	; rep #$20
	; dec scrollY
	; sep #$20
	; dec spriteY
	; dec spriteY
; NOT_UP:

	; bit #JOY_DOWN
	; beq NOT_DOWN
	; rep #$20
	; inc scrollY
	; sep #$20
	; inc spriteY
	; inc spriteY
; NOT_DOWN:

	bit #JOY_B
	beq NOT_B
	inc mosaic
NOT_B:
	SetHScroll scrollX
	SetVScroll scrollY
	HandleLarry spriteX,spriteY,spriteTileNum
	wai
	jmp MainLoop
	
VBlank:
	pha ;push regs to stack so if my main loop is ever too long it'll continue without
	phx ;fucking up
	phy
	jsr DMASpriteMirror
	SetMosaic mosaic
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