dmd -w -debug -unittest "VolStream.d" "..\Lib\Unittest\LLClasses.lib" -I"..\"
del VolStream.obj
VolStream.exe -"E"
pause
