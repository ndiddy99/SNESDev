cd C:\snes
path=%path;.\tools
ca65 main.asm
ld65 -C lorom.cfg -o out.smc main.o
del main.o
cd no$sns
no$sns.exe ..\out.smc