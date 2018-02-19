@echo off
cd C:\snes
path=%path;.\tools
echo [objects] > temp.prj
echo main.obj >> temp.prj
wla-65816 -o main.asm main.obj
wlalink -vr temp.prj main.smc
del main.obj
del temp.prj
cd no$sns
no$sns.exe ..\main.smc