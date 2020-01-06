@echo off
call vcvarsall.bat

pushd %CD%

cd ..\engine\shaders\

cl generatebuiltinsl.c

generatebuiltinsl.exe

del generatebuiltinsl.obj
del generatebuiltinsl.exe

popd