dmd -w -debug -unittest "AllTests.d" "..\Lib\Unittest\LLClasses.lib" -I"..\"
del AllTests.obj
AllTests.exe
pause
