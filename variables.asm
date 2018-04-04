.enum ;start at $10 because first 15 bytes are "scratchpad"
scrollX = $10
scrollY = scrollX+2 ;12
playerHSpeed = scrollY+2 ;14
spriteX = playerHSpeed+2 ;16
spriteY = spriteX+2 ;18
playerX = spriteY+2;like sprite x but "relative to tilemap" ;1a
playerY = playerX+2 ;1c
playerTileOffset = playerY+2 ;1e
playerTileNum = playerTileOffset+2 ;20
collision
playerAnimDelay
playerAttrs
playerVSpeed
playerState
movementState
.endenum