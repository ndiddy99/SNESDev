.segment "CODE"

TILE_HARD = $0 ; if player is ejected from tile

TileAttrs: ;either "hard" aka eject or pointer to heightmap
.word TILE_HARD
.word TILE_HARD
.word HeightMap4

HeightMap4: ;height map for tile 4
.word $1
.word $2
.word $3
.word $4
.word $5
.word $6
.word $7
.word $8
.word $9
.word $a
.word $b
.word $c
.word $d
.word $e
.word $f
.word $10
