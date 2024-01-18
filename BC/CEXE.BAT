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
set exe_file=%source_file%.exe

REM Компиляция с помощью TASM
echo Compilling %asm_file%...
tasm /i\include /zi %asm_file%

REM Линковка с помощью TLINK
echo Linking %exe_file%...
tlink /vms %obj_file%, %exe_file%

REM Успешное завершение
echo Compilling is finished
goto :eof

:eof
@echo on
