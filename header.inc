; Sets up ROM headers/vectors

.p816   ; 65816 processor
.i16    ; X/Y are 16 bits
.a8     ; A is 8 bits

.define ROM_NAME "zoz"

.segment "HEADER"     ; +$7FE0 in file
    .byte ROM_NAME 

.segment "ROMINFO"    ; +$7FD5 in file
    .byte $30         ; LoROM, fast-capable
    .byte 0           ; no battery RAM
    .byte $07         ; 128K ROM
    .byte 0,0,0,0
    .word $AAAA,$5555 ; dummy checksum and complement

;cop,brk,abort,nmi,reset,irq
;cop,abort,nmi,res,brk,irqbrk
.segment "VECTORS"
    .word 0, 0, EmptyHandler0, EmptyHandler1, EmptyHandler2, VBlank, Reset, EmptyHandler3
    .word 0, 0, EmptyHandler4, EmptyHandler5, VBlank, EmptyHandler6, Reset, EmptyHandler7
	
.segment "CODE"
EmptyHandler0:
	rti
EmptyHandler1:
	rti
EmptyHandler2:
	rti
EmptyHandler3:
	rti
EmptyHandler4:
	rti
EmptyHandler5:
	rti
EmptyHandler6:
	rti
EmptyHandler7:
	rti