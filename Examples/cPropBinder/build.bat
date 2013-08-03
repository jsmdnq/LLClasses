dmd -O -release -noboundscheck "FormBinding.d" "..\..\Lib\Release\LLClasses.lib" "..\Common\SimpleForm.d" -I"..\..\";"..\" -L/SUBSYSTEM:WINDOWS
del *.obj