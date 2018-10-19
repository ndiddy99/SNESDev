.include "header.inc"
.include "snes.inc"
.include "initSNES.inc"
.include "constants.asm"
.include "variables.asm"
.include "macros.asm"
.include "sprites.asm"
.include "player.asm"
.include "art.asm"
.include "sound.asm"

.segment "CODE"
Reset:
	InitSNES
	jsl LoadSPC
	LoadPalette BGPalette, $0, $10
	LoadPalette BG2Palette, $10, $10
    LoadPalette PlayerPalette, $80, $10
	; Load Tile data to VRAM
    LoadBlockToVRAM BGTiles, $2000, $C0	
	LoadBlockToVRAM BG2Tiles, $5000, $200 ;8 tiles, 4bpp
	LoadBlockToVRAM PlayerTiles, $6000, $1000
	LoadBlockToVRAM BGTilemap, $0000, $2000
	LoadBlockToVRAM BG2Tilemap, $4000, $800
	LoadBlockToWRAM BGTilemap, TilemapMirror, $2000
    ; Setup Video modes and other stuff, then turn on the screen
    jsr SetupVideo
	
	jsr InitSprites
	lda #VBLANK_NMI | AUTOREAD
	sta PPUNMI ;enable vblank interrupt and joypad read
	a16
	lda #$11b
	sta scrollY
	sep #$20
	a8
	lda #$50
	sta playerX
	
	
.define GROUND_Y $A0
	lda #GROUND_Y
	sta playerY+2
	
	lda #$30 ;max sprite priority
	sta playerAttrs
	
MainLoop:
	a8
	lda #$1
	sta frameStatus ;how we check if the program's done executing
	a16
	lda JOY1CUR ;p1 joypad read address
	sta joypad
	jsr HandlePlayerMovement

SetupScrollTable:
	a16
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
	
	lda #OBSIZE_16_32 | $3
	sta OBSEL ;16x16 or 32x32 sprites, sprite data @ $6000
	stz OAMADDR ;set OAM write cursor to $0
	stz OAMADDR+1
	lda #$1
    sta BGMODE ;mode 1, 8x8 tiles

    lda #$03 ;bg1 tilemap 0ffset $0, size 64x64
    sta NTADDR
	
	lda #$40  ; bg2 tilemap offset: $4000, size: 32x32
	sta NTADDR+1

	lda #$52
    sta BGCHRADDR ;bg2 chr vram addr to $5000, bg1 chr vram offset $2000
	
    lda #%00010011 ;enable bg0, bg1, and sprites
    sta BLENDMAIN

    lda #$FF ;bg1 horizontal scroll to -1 to fix weird stuff
    sta BGSCROLLY
    sta BGSCROLLY

    lda #$F ;max brightness
    sta PPUBRIGHT

    plp
    rts
	
SetupHDMA:
	lda #DMA_INDIRECT | DMA_00 ;write twice, indirect mode
	sta DMAMODE
	lda #$0f ;write to $210f, bg 2 scroll reg
	sta DMAPPUREG
	a16
	lda #ScrollTable
	sta DMAADDR
	lda #$0
	sta DMAADDRBANK
	a8
	lda #$7e
	sta HDMAINDBANK ;ram bank to read from for indirect hdma
	
	lda #DMA_00 ;write twice, direct mode
	sta $4310
	lda #$21 ;write to $2121, cgram palette address reg
	sta $4311
	ldy #PaletteIndexTable
	sty $4312
	stz $4314

	lda #DMA_00 ;write twice, direct mode
	sta $4320
	lda #$22 ;write to $2122, cgram palette data reg
	sta $4321
	a16
	lda #GradientTable
	sta $4322
	stz $4324
	a8	
	lda #%00000111
	sta HDMASTART ;enable hdma channels 0-2
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
	stz OAMADDR		; set OAM write cursor to 0
	stz OAMADDR+1

	lda #DMA_LINEAR
	sta DMAMODE
	lda #$04 ;write to $2104 (OAMDATA)
	sta DMAPPUREG
	ldy #OamMirror
	sty DMAADDR		; source offset
	lda #$7E
	sta DMAADDRBANK		; bank address = $7E  (work RAM)
	ldy #$0220
	sty DMALEN		; number of bytes to transfer
	rts
	