.enum ;start at $10 because first 15 bytes are "scratchpad"
scrollX = $10
scrollY = scrollX+2 ;12
scroll2X = scrollY+2 ;14
playerHSpeed = scroll2X+2 ;16
spriteX = playerHSpeed+2 ;18
spriteY = spriteX+2 ;2a
playerX = spriteY+2;like sprite x but "relative to tilemap" ;1c
playerY = playerX+2 ;1e
playerTileOffset = playerY+2 ;20
playerTileNum = playerTileOffset+2 ;22
collision
playerAnimDelay = collision+2
playerAttrs
playerVSpeed
playerState
movementState
.endenum