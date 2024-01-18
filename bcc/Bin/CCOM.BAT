@echo off
REM Проверка наличия параметра (названия файла без расширения)
if "%1"=="" goto not_name_file

goto :con1
:not_name_file
echo Need file name
goto :eof

:con1
REM Задание переменных
set source_file=%1
set asm_file=%source_file%.asm
set obj_file=%source_file%.obj
set com_file=%source_file%.com

REM Компиляция с отладочной информацией с помощью TASM
echo Compilling %asm_file%...
tasm /zi %asm_file%

REM Линковка с отладочной информацией с помощью TLINK
echo Linking %com_file%...
tlink /tvms %obj_file%, %com_file%

REM Успешное завершение
echo Compilling is finished
goto :eof

:eof
@echo on
