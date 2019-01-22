.segment "CODE"

BGPalette:
	.INCBIN ".\art\bgtiles.clr"

BG2Palette:
	.INCBIN ".\art\bg2tiles.clr"
	
PlayerPalette:
	.INCBIN ".\art\player.clr"
.segment "BANK2"
PlayerTiles:
	.define NUM_LARRY_TILES $E
	.define LARRY_ANIMATION_DELAY $2 ;number of frames between incrementing movement
	.INCBIN ".\art\player.pic"
BGTiles:
	.incbin ".\art\bgtiles.pic"

BG2Tiles:
	.incbin ".\art\bg2tiles.pic"

BGTilemap: ;14 columns tall ($380 bytes) because SNES screen is 14 tiles tall (14*16=224)
	.word $2,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
	.word $2,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
	.word $2,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
	.word $2,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
	.word $2,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
	.word $2,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$2,$2,$0,$0,$2,$0,$0,$2,$0,$0,$2,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
	.word $2,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
	.word $2,$0,$0,$0,$0,$0,$0,$0,$2,$2,$2,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
	.word $2,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
	.word $2,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
	.word $2,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
	.word $2,$0,$0,$0,$0,$0,$4,$2,$6,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
	.word $2,$0,$0,$0,$8,$a,$2,$2,$2,$6,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
	.word $2,$2,$2,$2,$2,$2,$2,$2,$2,$2,$2,$2,$2,$2,$2,$2,$2,$2,$2,$2,$2,$2,$2,$2,$2,$2,$2,$2,$2,$2,$2,$2
	
BGTilemapPt2: ;part that gets scrolled in
	.word $0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$2
	.word $0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$2
	.word $0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$2
	.word $0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$2
	.word $0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$2
	.word $0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$2
	.word $0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$2
	.word $0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$2
	.word $0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$2
	.word $0,$0,$0,$0,$4,$2,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$2
	.word $0,$0,$0,$4,$2,$2,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$2
	.word $0,$0,$4,$2,$2,$2,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$2
	.word $0,$4,$2,$2,$2,$2,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$2
	.word $2,$2,$2,$2,$2,$2,$2,$2,$2,$2,$2,$2,$2,$2,$2,$2,$2,$2,$2,$2,$2,$2,$2,$2,$2,$2,$2,$2,$2,$2,$2,$2	
	
BG2Tilemap:
	.word $0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
	.word $0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
	.word $0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
	.word $0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
	.word $0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
	.word $0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
	.word $0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
	.word $0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
	.word $0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
	.word $0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
	.word $0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
	.word $0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
	.word $0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
	.word $0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
	.word $0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
	.word $0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
	.word $1,$2,$3,$4,$1,$2,$3,$4,$1,$2,$3,$4,$1,$2,$3,$4,$1,$2,$3,$4,$1,$2,$3,$4,$1,$2,$3,$4,$1,$2,$3,$4
	.word $5,$6,$7,$8,$5,$6,$7,$8,$5,$6,$7,$8,$5,$6,$7,$8,$5,$6,$7,$8,$5,$6,$7,$8,$5,$6,$7,$8,$5,$6,$7,$8
	.word $1,$2,$3,$4,$1,$2,$3,$4,$1,$2,$3,$4,$1,$2,$3,$4,$1,$2,$3,$4,$1,$2,$3,$4,$1,$2,$3,$4,$1,$2,$3,$4
	.word $5,$6,$7,$8,$5,$6,$7,$8,$5,$6,$7,$8,$5,$6,$7,$8,$5,$6,$7,$8,$5,$6,$7,$8,$5,$6,$7,$8,$5,$6,$7,$8
	.word $1,$2,$3,$4,$1,$2,$3,$4,$1,$2,$3,$4,$1,$2,$3,$4,$1,$2,$3,$4,$1,$2,$3,$4,$1,$2,$3,$4,$1,$2,$3,$4
	.word $5,$6,$7,$8,$5,$6,$7,$8,$5,$6,$7,$8,$5,$6,$7,$8,$5,$6,$7,$8,$5,$6,$7,$8,$5,$6,$7,$8,$5,$6,$7,$8
	.word $1,$2,$3,$4,$1,$2,$3,$4,$1,$2,$3,$4,$1,$2,$3,$4,$1,$2,$3,$4,$1,$2,$3,$4,$1,$2,$3,$4,$1,$2,$3,$4
	.word $5,$6,$7,$8,$5,$6,$7,$8,$5,$6,$7,$8,$5,$6,$7,$8,$5,$6,$7,$8,$5,$6,$7,$8,$5,$6,$7,$8,$5,$6,$7,$8
	.word $1,$2,$3,$4,$1,$2,$3,$4,$1,$2,$3,$4,$1,$2,$3,$4,$1,$2,$3,$4,$1,$2,$3,$4,$1,$2,$3,$4,$1,$2,$3,$4
	.word $5,$6,$7,$8,$5,$6,$7,$8,$5,$6,$7,$8,$5,$6,$7,$8,$5,$6,$7,$8,$5,$6,$7,$8,$5,$6,$7,$8,$5,$6,$7,$8
	.word $1,$2,$3,$4,$1,$2,$3,$4,$1,$2,$3,$4,$1,$2,$3,$4,$1,$2,$3,$4,$1,$2,$3,$4,$1,$2,$3,$4,$1,$2,$3,$4
	.word $5,$6,$7,$8,$5,$6,$7,$8,$5,$6,$7,$8,$5,$6,$7,$8,$5,$6,$7,$8,$5,$6,$7,$8,$5,$6,$7,$8,$5,$6,$7,$8
	.word $1,$2,$3,$4,$1,$2,$3,$4,$1,$2,$3,$4,$1,$2,$3,$4,$1,$2,$3,$4,$1,$2,$3,$4,$1,$2,$3,$4,$1,$2,$3,$4
	.word $5,$6,$7,$8,$5,$6,$7,$8,$5,$6,$7,$8,$5,$6,$7,$8,$5,$6,$7,$8,$5,$6,$7,$8,$5,$6,$7,$8,$5,$6,$7,$8
	.word $1,$2,$3,$4,$1,$2,$3,$4,$1,$2,$3,$4,$1,$2,$3,$4,$1,$2,$3,$4,$1,$2,$3,$4,$1,$2,$3,$4,$1,$2,$3,$4
	.word $5,$6,$7,$8,$5,$6,$7,$8,$5,$6,$7,$8,$5,$6,$7,$8,$5,$6,$7,$8,$5,$6,$7,$8,$5,$6,$7,$8,$5,$6,$7,$8

