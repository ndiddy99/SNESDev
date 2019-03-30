;playerState
.enum
STATE_DECEL
STATE_RIGHT_HELD 
STATE_LEFT_HELD
.endenum
;moveState
.enum
MOVE_STATE_NORMAL
MOVE_STATE_SLOPE ;when player is on slope
MOVE_STATE_JUMPING
MOVE_STATE_FALLING ;like jumping but without the jumping frame
.endenum

;object list format (18 bytes or 12 hex per object):
; x pos (4 bytes)
; y pos (4 bytes)
; x speed (4 bytes)
; y speed (4 bytes)
; movement state (same format as playerMove) 2 bytes
; general state (what direction you're going, etc) 2 bytes
; handler function pointer 2 bytes
.define ObjectList $100 
.define OBJ_ENTRY_SIZE $14

;oam mirror defines
.define OamMirror $400
.define Oam2Mirror $600
 
.define TilemapMirror $700
.define TextQueue $B00
;format: 
; address to write to (word)
; text tile data
; zero terminator (word)

