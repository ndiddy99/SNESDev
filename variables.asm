.enum ;start at $10 because first 15 bytes are "scratchpad"
joypad = $10
joypadBuf = joypad+2 ;last frame's joypad input, useful for differentiating a press and a hold
scrollX = joypadBuf+2 
scrollY = scrollX+2 
scroll2X = scrollY+2
frameStatus ;0 if main loop is done executing
watchDog ;set to 0 at the start of main loop and incremented every vblank. if it doesn't get
		 ;reset within 64 frames, assume the game's crashed

;---scroll.asm---
scrollColumn ;last scroll column loaded
scrollScreenAddr=scrollColumn+2 ;pointer to "screen" that you're loading tiles from
scrollScreenNum=scrollScreenAddr+2
scrollMirrorPtr = scrollScreenNum+2
scrollLock = scrollMirrorPtr+2 ;player x pos within screen that causes scrolling to lock

;---text.asm---
textQueueIndex = scrollLock+2

;---player.asm---
playerX = textQueueIndex+2 ;16.16 fixed
playerY = playerX+4
playerSpriteX = playerY+4
playerXSpeed = playerSpriteX+2
playerYSpeed = playerXSpeed+4
playerBGTile = playerYSpeed+4

playerTileNum = playerBGTile+2
playerAnimTimer
playerAnimMode
playerAttrs
playerState ;16 bit to avoid constant accumulator size changing
movementState = playerState+2
.endenum