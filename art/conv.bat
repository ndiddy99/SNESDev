path=%path;C:\Program Files\ImageMagick-7.0.8-Q16

..\tools\pcx2snes -n -s16 -c16 -o16 player
..\tools\pcx2snes -n -s16 -c16 -o16 enemy1
..\tools\pcx2snes -n -s16 -c16 -o16 bgtiles
..\tools\pcx2snes -n -s8 -c16 -o16 bg2tiles
..\tools\pcx2snes -n -s8 -c4 -o4 font

magick bgtiles.pcx bgtiles.bmp
pause