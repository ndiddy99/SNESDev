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