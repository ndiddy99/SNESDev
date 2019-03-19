
;object list format (18 bytes or 12 hex per object):
; x pos (4 bytes)
; y pos (4 bytes)
; x speed (4 bytes)
; y speed (4 bytes)
; movement state (same format as playerMove) 2 bytes
; general state (what direction you're going, etc) 2 bytes
.define ObjectList $100 
.define OBJ_ENTRY_SIZE $12

;oam mirror defines
.define OamMirror $400
.define Oam2Mirror $600
 
.define TilemapMirror $700
.define TextQueue $B00
;format: 
; address to write to (word)
; text tile data
; zero terminator (word)
