;---oam pt 2 write masks---

.define SPRITE3_MASK %00111111
.define SPRITE2_MASK %11001111
.define SPRITE1_MASK %11110011
.define SPRITE0_MASK %11111100

;oam mirror defines
.define OamMirror $400
.define Oam2Mirror $600

.define BG2ScrollTable $620
;object list format:
; x pos (byte)
; y pos (byte)
; attributes (byte)
; status (0=still, 1 = moving, 2 = ready to despawn, etc) (byte)
; pointer to "handler" function
.define EntityList $630  
.define TilemapMirror $700
.define TextQueue $B00
;format: 
; address to write to (word)
; text tile data
; zero terminator (word)
