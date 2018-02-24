.bank 1 slot 0
.org 0
.section "TileData"
BGPalette:
	.INCBIN ".\art\bg.clr"
	
SpritePalette:
	.INCBIN ".\art\larry.clr"

LarryTiles:
	.define NUM_LARRY_TILES $E
	.define LARRY_OFFSET $20
	.INCBIN ".\art\larry.pic"
BGTiles:
	.dsb 32,$0
	.incbin ".\art\bg.pic"

.ends