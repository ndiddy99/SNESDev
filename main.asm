.include "header.inc"
.include "snes.inc"
.include "initSNES.inc"
.include "constants.asm"
.include "variables.asm"
.include "macros.asm"
.include "sprites.asm"
.include "text.asm"
.include "tiles.asm"
.include "player.asm"
.include "scroll.asm"
.include "art.asm"
.include "sound.asm"

.segment "CODE"

Reset:
	InitSNES
	jsl LoadSPC
	LoadPalette BGPalette, $0, $10
	LoadPalette BG2Palette, $10, $10
	LoadPalette FontPalette, $20, $4
    LoadPalette PlayerPalette, $80, $10
	; Load Tile data to VRAM
	LoadBlockToVRAM BGTilemap, $0, $400
	LoadBlockToWRAM BGTilemap, TilemapMirror, $380
    LoadBlockToVRAM BGTiles, $1000, $400

	LoadBlockToVRAM BG2Tilemap, $2000, $800	
	LoadBlockToVRAM BG2Tiles, $3000, $200 ;8 tiles, 4bpp
	
	LoadBlockToVRAM FontTiles, $4000, $600
	LoadBlockToVRAM PlayerTiles, $6000, $1000
    ; Setup Video modes and other stuff, then turn on the screen
    jsr SetupVideo
	
	jsr InitSprites
	
	a16
	DrawText TextL0, #$0, #$1
	DrawText TextL1, #$0, #$2
	DrawText TextL2, #$0, #$3
	DrawText TextL3, #$0, #$4
	DrawText TextL4, #$0, #$5
	DrawText TextL5, #$4, #$6
	; DrawText DumText, #$0, #$1a
	a8
	
	WaitStartFrame:
	lda $2137 ;latches h/v counter
	lda $213d
	bne WaitStartFrame ;if not at the start of a frame, don't continue
	
	lda $4210
	lda #VBLANK_NMI | AUTOREAD
	sta PPUNMI ;enable vblank interrupt and joypad read
	lda $4210
	
	a16
	stz scrollX
	stz scrollY
	
	jsr InitPlayer
	jsr InitScroll
	
MainLoop:
	a8
	lda #$1
	sta frameStatus ;how we check if the program's done executing
	a16
	lda JOY1CUR ;p1 joypad read address
	sta joypad
	jsr HandlePlayerMovement
	jsr HandleScroll
	
	a16
	LoadSprite #$0, playerTileNum, playerSpriteX, playerY+2, playerAttrs
	lda playerY+2
	clc
	adc #$10
	sta $a
	lda playerTileNum
	clc
	adc #$20
	sta $c
	LoadSprite #$1, $c, playerSpriteX, $a, playerAttrs
	
; SetupScrollTable:
	; clc
	; lda scroll2X
	; clc
	; adc #$5
	; sta scroll2X
	; ror
	; sta BG2ScrollTable
	; ror
	; sta BG2ScrollTable+2
	; ror
	; sta BG2ScrollTable+4
	; ror
	; sta BG2ScrollTable+6
	; ror
	; sta BG2ScrollTable+8
	; a8
	
	lda joypad
	sta joypadBuf
	; DrawByte playerSpriteX, #$5, #$a
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
	a8
	lda frameStatus
	bne SkipVblank
	lda #FORCEBLANK
	sta PPUBRIGHT
	SetHScroll scrollX
	SetVScroll scrollY
	jsr TransferTextQueue
	
	a16
	lda scrollMirrorPtr ;how I check if need to copy scroll data or not
	beq DontCopyScroll
		jsr VramScrollCopy
	DontCopyScroll:
	a8
	jsr DMASpriteMirror
	lda #$1 ;start dma transfer on channel 1 (change to 3 if i reenable dmatilemapmirror)
	sta $420b
	; jsr SetupHDMA
	
	lda #$F ;disable force blank, set back to max brightness
	sta PPUBRIGHT
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
	lda #%00011001
    sta BGMODE ;mode 1, 16x16 tiles in bgs 1 and 3, 8x8 tiles in bg 2

    lda #$0 ;bg1 tilemap offset $0, size 32x32
    sta NTADDR
	
	lda #$20  ; bg2 tilemap offset: $2000, size: 32x32
	sta NTADDR+1
	
	lda #$4c
	sta NTADDR+2 ;bg3 tilemap offset: $4C00, size 32x32

	lda #$31
    sta BGCHRADDR ;bg2 chr vram addr to $3000, bg1 chr vram offset $1000
	
	lda #$04
	sta BGCHRADDR+1 ;bg3 chr vram addr is $4000
	
    lda #%00010111 ;enable bg1, bg2, bg3, and sprites
    sta BLENDMAIN

    lda #$F ;max brightness
    sta PPUBRIGHT

    plp
    rts
	
	
; ScrollTable:
	; .byte $80
	; .word $0000
	; .byte $10
	; .word BG2ScrollTable+8
	; .byte $10
	; .word BG2ScrollTable+6
	; .byte $10
	; .word BG2ScrollTable+4
	; .byte $10
	; .word BG2ScrollTable+2
	; .byte $10
	; .word BG2ScrollTable
	; .byte $00

; PaletteIndexTable: ;needed because palette index auto-increments after every write
; ;400 instead of $4 because the endianness of the CGRAM write port is reversed for some reason
	; .byte $C
	; .word $400
	; .byte $C
	; .word $400
	; .byte $C
	; .word $400
	; .byte $C
	; .word $400
	; .byte $C
	; .word $400
	; .byte $C
	; .word $400
	; .byte $C
	; .word $400
	; .byte $C
	; .word $400
	; .byte $C
	; .word $400
	; .byte $C
	; .word $400
	; .byte $C
	; .word $400
	; .byte $00
	
	
; GradientTable:
	; .byte $C
	; .word $71C4; R:4 G:14 B:28
	; .byte $C
	; .word $5DC7; R:7 G:14 B:23
	; .byte $C
	; .word $51CB; R:11 G:14 B:20
	; .byte $C
	; .word $49CD; R:13 G:14 B:18
	; .byte $C
	; .word $41F1; R:17 G:15 B:16
	; .byte $C
	; .word $35F4; R:20 G:15 B:13
	; .byte $C
	; .word $2DF7; R:23 G:15 B:11
	; .byte $C
	; .word $221A; R:26 G:16 B:8
	; .byte $C
	; .word $1A1C; R:28 G:16 B:6
	; .byte $C
	; .word $121F; R:31 G:16 B:4
	; .byte $C
	; .word $71A1
	; .byte $00
	
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
	