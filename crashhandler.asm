.segment "CODE"

CrashHandler:
	stz PPUNMI
	a16
	sta $10 ;store register state
	stx $12
	sty $14
	tsc
	sta $16 ;stack pointer
	a8
	lda NMISTATUS ;clear NMI in case we crashed during vblank
	pla
	sta $18 ;status register
	pla
	sta $1a ;pc low
	pla
	sta $1c ;pc high
	pla
	sta $1e ;program bank
	a16
	DrawText ErrorMessage, #$3, #$3
	DrawText ErrorMessage2, #$3, #$4
	DrawText Registers, #$3, #$6
	DrawWord $10, #$6, #$6 ;a register
	DrawWord $12, #$e, #$6 ;x register
	DrawWord $14, #$16, #$6 ;y register
	DrawText PCLabel, #$3, #$7
	DrawByte $1e, #$7, #$7 ;PC data bank
	DrawWord $1a, #$a, #$7 ;program counter
	DrawWord $16, #$16, #$7 ;stack pointer
	DrawText StackLabel, #$3, #$9
	;stack row 1
	DrawByte $1ff0, #$3, #$a
	DrawByte $1ff1, #$6, #$a
	DrawByte $1ff2, #$9, #$a
	DrawByte $1ff3, #$c, #$a
	DrawByte $1ff4, #$f, #$a
	DrawByte $1ff5, #$12, #$a
	DrawByte $1ff6, #$15, #$a
	DrawByte $1ff7, #$18, #$a
	;stack row 2
	DrawByte $1ff8, #$3, #$b
	DrawByte $1ff9, #$6, #$b
	DrawByte $1ffa, #$9, #$b
	DrawByte $1ffb, #$c, #$b
	DrawByte $1ffc, #$f, #$b
	DrawByte $1ffd, #$12, #$b
	DrawByte $1ffe, #$15, #$b
	DrawByte $1fff, #$18, #$b
	
	a8
	lda #FORCEBLANK
	sta PPUBRIGHT ;force blank enabled
	
	;----zerofill text layer-----
	a16
	lda #$4c00 ;vram address to write to
	sta $2116
	a8
	lda #$80
	sta $2115 ;VRAM transfer: words, inc by 1
	lda #$9 ;fixed a-bus word transfer
	sta $4300
	lda #$18 ;vram write port, $2118
	sta $4301
	a16
	lda #ClearWord
	sta $4302 ;address to write from
	lda #$800 ;# of bytes to write
	sta $4305
	a8
	stz $4304 ;bank
	lda #$1 ;start the transfer
	sta $420b
	
    lda #%00000100 ;only enable bg3 (text layer)
    sta BLENDMAIN	
	
	jsr TransferTextQueue
	stz $2121
	lda #$f
	sta $2122
	stz $2122
	lda #$f ;turn on ppu rendering, max brightness
	sta PPUBRIGHT
	
	ForeverLoop:
		bra ForeverLoop
	
ClearWord:
	.word $0
ErrorMessage:
;          0123456789ABCDEF0123456789ABCDEF
	.byte "The programmer has a nap!",0
ErrorMessage2:
	.byte "Hold out! Programmer!",0
Registers:
	.byte "a: #### x: #### y: ####",0
PCLabel:
	.byte "pc: ##:#### stack: ####",0
StackLabel:
	.byte "stack (starting @ $1ff0):",0
