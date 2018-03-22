cd C:\snes
path=%path;.\tools
cd sound
tools\bass.exe main.asm -o sound.bin
cd..
ca65 -l main.lst main.asm
ld65 -C lorom.cfg -o out.smc main.o
del main.o
no$sns\higan\higan.exe c:\snes\out.smc