.enum ;start at $10 because first 15 bytes are "scratchpad"
joypad = $10
scrollX = joypad+2
scrollY = scrollX+2 
scroll2X = scrollY+2
frameStatus

;---player.asm---
playerX = frameStatus+1 ;16.16 fixed
playerY = playerX+4
playerXSpeed = playerY+4
playerYSpeed = playerXSpeed+4

playerTileNum = playerYSpeed+4
playerAnimTimer
playerAnimMode
playerAttrs
playerState ;16 bit to avoid constant accumulator size changing
movementState = playerState+2
.endenum