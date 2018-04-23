.enum ;start at $10 because first 15 bytes are "scratchpad"
scrollX = $10
scrollY = scrollX+2 ;12
scroll2X = scrollY+2 ;14
playerHSpeed = scroll2X+2 ;16
spriteX = playerHSpeed+2 ;18
spriteY = spriteX+2 ;1a
playerX = spriteY+2;like sprite x but "relative to tilemap" ;1c
playerY = playerX+2 ;1e
playerTileOffset = playerY+2 ;20
playerTileNum = playerTileOffset+2 ;22
collision
playerAttrs = collision+2
playerVSpeed
playerState
movementState
frameStatus
.endenum

;---joypad---

.define JOY_B $80
.define JOY_Y $40
.define JOY_SELECT $20
.define JOY_START $10
.define JOY_UP $8
.define JOY_DOWN $4
.define JOY_LEFT $2
.define JOY_RIGHT $1

;---oam pt 2 write masks---

.define SPRITE3_MASK %00111111
.define SPRITE2_MASK %11001111
.define SPRITE1_MASK %11110011
.define SPRITE0_MASK %11111100

;oam mirror defines
.define OamMirror $400
.define Oam2Mirror $600
.define TilemapMirror $2000

.define BG2ScrollTable $620
;object list format:
; x pos (byte)
; y pos (byte)
; attributes (byte)
; status (0=still, 1 = moving, 2 = ready to despawn, etc) (byte)
; pointer to "handler" function
.define EntityList $630  
