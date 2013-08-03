dmd -debug -unittest -w -wi "..\Tests\AllTests.d" "..\Lib\Unittest\LLClasses.lib" -I".." -of"..\Tests\AllTests.exe"
del "..\Tests\AllTests.obj"
"..\Tests\AllTests.exe"
pause