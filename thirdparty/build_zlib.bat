@echo off

SET "DEPS_ROOT=%~dp0"
SET "ZLIB_PATH=%DEPS_ROOT%zlib"

cd /D %ZLIB_PATH%

rmdir /S /Q build64 > nul
mkdir build64
cd build64

cmake -G"Visual Studio 15 2017 Win64" ../

::msbuild zlibstatic.vcxproj /p:Configuration=Debug /p:Platform=x64
msbuild zlibstatic.vcxproj /p:Configuration=Release /p:Platform=x64

:: install

cd /D %DEPS_ROOT%

copy /Y zlib\*.h include\
copy /Y zlib\build64\*.h include\
::copy zlib\*.c include\

::copy /Y zlib\build64\Debug\*.lib lib64\
copy /Y zlib\build64\Release\*.lib lib64\