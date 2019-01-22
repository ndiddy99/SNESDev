.enum ;start at $10 because first 15 bytes are "scratchpad"
joypad = $10
scrollX = joypad+2
scrollY = scrollX+2 
scroll2X = scrollY+2
frameStatus ;0 if main loop is done executing

;---scroll.asm---
scrollColumn ;last scroll column loaded
scrollScreenAddr=scrollColumn+2 ;pointer to "screen" that you're loading tiles from
scrollPtr = scrollScreenAddr+2 ;for copying scroll to vram in vblank

;---player.asm---
playerX = scrollPtr+2 ;16.16 fixed
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
playerDirection = movementState+2 ;0 = still, 1 = left, 2 = right
.endenum