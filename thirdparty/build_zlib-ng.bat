@echo off

:: setup build tools
where /Q cmake.exe
IF ERRORLEVEL 1 set "PATH=%PATH%;C:\Program Files\CMake\bin"
if not defined VCINSTALLDIR call "..\tools\vcvarsall.bat" x64

SET "DEPS_ROOT=%~dp0"
SET "INCLUDE_PATH=%DEPS_ROOT%include"
SET "LIB64_PATH=%DEPS_ROOT%lib64"

if not exist %INCLUDE_PATH% mkdir %INCLUDE_PATH%
if not exist %LIB64_PATH% mkdir %LIB64_PATH%

:: build
SET "ZLIB_PATH=%DEPS_ROOT%zlib-ng"
cd /D %ZLIB_PATH%

rmdir /S /Q build64 > nul
mkdir build64
cd build64

::cmake -G"Visual Studio 16 2019" -Ax64 -DCMAKE_C_FLAGS_RELEASE="/MT /O2 /Ob2 /DNDEBUG" -DZLIB_ENABLE_TESTS=0 -DZLIB_COMPAT=1 ../
cmake -G"Visual Studio 16 2019" -Ax64 -DZLIB_ENABLE_TESTS=0 -DZLIB_COMPAT=1 ../

::msbuild zlibstatic.vcxproj /p:Configuration=Debug /p:Platform=x64
msbuild zlibstatic.vcxproj /p:Configuration=Release /p:Platform=x64

:: install

cd /D %DEPS_ROOT%

copy /Y "%ZLIB_PATH%\*.h" include\
copy /Y "%ZLIB_PATH%\build64\*.h" include\
::copy zlib\*.c include\

::copy /Y zlib\build64\Debug\*.lib lib64\
copy /Y "%ZLIB_PATH%\build64\Release\*.lib" lib64\