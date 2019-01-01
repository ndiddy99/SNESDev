.segment "CODE"

TILE_HARD = $0 ; if player is ejected from tile

TileAttrs: ;either "hard" aka eject or pointer to heightmap
.word TILE_HARD
.word TILE_HARD
.word HeightMap4
.word HeightMap6
.word HeightMap8
.word HeightMapA

ADD = $0
SUBTRACT = $1

AddSubTable: ;whether to add or subtract momentum depending on tile num
.word $0
.word $0
.word SUBTRACT
.word ADD
.word SUBTRACT
.word SUBTRACT

;if tile has momentum, needs to be more than PLAYER_ACCEL or else weird stuff happens
MomentumTable:
.word $0
.word $0
.word $6000
.word $6000
.word $4400
.word $4400

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

HeightMap6:
.word $10
.word $f
.word $e
.word $d
.word $c
.word $b
.word $a
.word $9
.word $8
.word $7
.word $6
.word $5
.word $4
.word $3
.word $2
.word $1

HeightMap8:
.word $1
.word $1
.word $2
.word $2
.word $3
.word $3
.word $4
.word $4
.word $5
.word $5
.word $6
.word $6
.word $7
.word $7
.word $8
.word $8

HeightMapA:
.word $9
.word $9
.word $a
.word $a
.word $b
.word $b
.word $c
.word $c
.word $d
.word $d
.word $e
.word $e
.word $f
.word $f
.word $10
.word $10