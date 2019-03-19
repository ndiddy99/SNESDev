.segment "ZEROPAGE"
scratchpad: .res 16 ;"local variables" for subroutines
joypad: .res 2 
joypadBuf: .res 2 ;last frame's joypad input, useful for differentiating a press and a hold
scrollX: .res 2
scrollY: .res 2
scroll2X: .res 2
frameStatus: .res 1 ;0 if main loop is done executing
watchDog: .res 1 ;set to 0 at the start of main loop and incremented every vblank.
                 ;if it doesn't get reset within 64 frames, assume the game's crashed
;---scroll.asm---				 
scrollColumn: .res 2 ;last scroll column loaded
scrollScreenAddr: .res 2 ;pointer to "screen" that you're loading tiles from
scrollScreenNum: .res 2
scrollMirrorPtr: .res 2
scrollLock: .res 2 ;player x pos within screen that causes scrolling to lock
rScrollLim: .res 2

;---text.asm---
textQueueIndex: .res 2

;---player.asm---
playerX: .res 4 ;16.16 fixed
playerY: .res 4
playerXSpeed: .res 4
playerYSpeed: .res 4
playerMove: .res 2
playerSpriteX: .res 2
playerTileNum: .res 1
playerAnimTimer: .res 1
playerAnimMode: .res 1 ;16 bit to avoid constant accumulator size changing
playerAttrs: .res 1
playerState: .res 2

;---collision.asm---
collisionX: .res 4 ;these get block copied in
collisionY: .res 4
collisionXSpeed: .res 4
collisionYSpeed: .res 4
movementState: .res 2
;local variables
currBGTile: .res 2

;---entity.asm---
numObjects: .res 2
objectCursor: .res 2 ;where you are in the object list
objectIndex: .res 2 ;objectCursor * sizeof(object struct)
