.include "header.asm"
.include "InitSNES.asm"
.include "defines.asm"
.include "variables.asm"
.include "ppuMacros.asm"
.include "sprites.asm"

;---start---

.bank 0 slot 0
.org 0
.section "Main"

Start:
    InitSNES    ; Clear registers, etc.	
	jsr InitSprites
    LoadPalette BGPalette, 0, 4
    LoadPalette BGPalette, 0, $100
    ; Load Palette for our tiles

    ; Load Tile data to VRAM
    LoadBlockToVRAM BGTiles, $2000, $0020	; 2 tiles, 2bpp, = 32 bytes
	LoadBlockToVRAM SpriteTiles, $6000, $2000 ;16x16, 4bpp=128 bytes
	; LoadSprite 0,$15,$25,0,$30,0,0
	LoadSprite 0,$9,$30,0,$30,0,0
	jsr DMASpriteMirror
	
    lda #$80 ;load bg tilemap
    sta $2115
    ldx #$0000
    stx $2116
    lda #$01
    sta $2118
LoadLoop:
	inx
	stx $2116 ;fill background w/ faces
	sta $2118
	cpx #$3FF
	bne LoadLoop
	
    ; Setup Video modes and other stuff, then turn on the screen
    jsr SetupVideo

	lda #$81
	sta $4200 ;enable vblank interrupt and joypad read
	
	
MainLoop:
	lda $4219 ;p1 joypad read address
	bit #JOY_LEFT
	beq NOT_LEFT
	rep #$20
	dec scrollX
	sep #$20
	dec spriteX
	dec spriteX
NOT_LEFT:

	bit #JOY_RIGHT
	beq NOT_RIGHT
	rep #$20
	inc scrollX
	sep #$20
	inc spriteX
	inc spriteX
NOT_RIGHT:

	bit #JOY_UP
	beq NOT_UP
	rep #$20
	dec scrollY
	sep #$20
	dec spriteY
	dec spriteY
NOT_UP:

	bit #JOY_DOWN
	beq NOT_DOWN
	rep #$20
	inc scrollY
	sep #$20
	inc spriteY
	inc spriteY
NOT_DOWN:

	bit #JOY_B
	beq NOT_B
	inc mosaic
NOT_B:
	SetHScroll scrollX
	SetVScroll scrollY
	LoadSprite 0, spriteX,spriteY,0,$30,0,0
	clc
	lda spriteY
	adc #$10
	sta sprite2Y
	LoadSprite 1, spriteX,sprite2Y,2,$30,0,0
	wai
	jmp MainLoop
	
	
VBlank:
	jsr DMASpriteMirror
	SetMosaic mosaic
	lda $4210 ;clear vblank flag
	rti
	
SetupVideo:
    php
	
	lda #$73
	sta $2101 ;16x16 or 32x32 sprites, sprite data @ $6000
	stz $2102 ;oam starts at $0 vram
	stz $2103
	lda 1
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

DMAPalette: 
;a- data bank
;x- data offset
;y- size of data

;processor status onto stack
	phb
	php
	stx $4302 ;address into dma 0 source register
	sta $4304 ;bank into channel 0 bank register
	sty $4305 ;number of bytes into channel 0 size
	stz $4300 ;dma byte mode, increment by 1
	lda #$22 ;$2122=color palette write
	sta $4301
	lda #$1
	sta $420B ;start transfer
	
	plp
	plb
	rts
	
LoadVRAM:
;a- data bank
;x- data offset
;y- num of bytes to copy
    php         ; Preserve Registers

    stx $4302   ; Store Data offset into DMA source offset
    sta $4304   ; Store data Bank into DMA source bank
    sty $4305   ; Store size of data block

    lda #$01
    sta $4300   ; Set DMA mode (word, normal increment)
    lda #$18    ; Set the destination register (VRAM write register)
    sta $4301
    lda #$01    ; Initiate DMA transfer (channel 1)
    sta $420B

    plp         ; restore registers
    rts         ; return
	
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

.ends

.bank 1 slot 0
.org 0
.section "TileData"
BGPalette:
	.INCBIN ".\art\bg.clr"
	.INCBIN ".\art\larry.clr"

SpriteTiles:
	.INCBIN ".\art\larry.pic"
BGTiles:
	.incbin ".\art\bg.pic"

.ends