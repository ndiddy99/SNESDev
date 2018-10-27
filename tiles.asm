.segment "CODE"

TILE_HARD = $0 ; if player is ejected from tile
TILE_SOFT = $1 ; if player can walk into tile

TileAttrs:
.word TILE_SOFT ;$0
.word TILE_HARD	;$2 etc
.word TILE_SOFT