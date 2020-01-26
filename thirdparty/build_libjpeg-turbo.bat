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

:: libjpeg-turbo dependencies setup
SET "NASM_PATH=%DEPS_ROOT%nasm\nasm.exe"

:: cmake scripts expects the path with forward slashes
SET "NASM_PATH=%NASM_PATH:\=/%"

:: build
cd /D %DEPS_ROOT%libjpeg-turbo

rmdir /S /Q build64 > nul
mkdir build64
cd build64

::cmake -G"Visual Studio 16 2019" -Ax64 -DCMAKE_C_FLAGS_RELEASE="/MT /O2 /Ob2 /DNDEBUG" -DCMAKE_ASM_NASM_COMPILER="%NASM_PATH%" -DWITH_JPEG8=1 -DREQUIRE_SIMD=1 -DWITH_CRT_DLL=1 ../
cmake -G"Visual Studio 16 2019" -Ax64 -DCMAKE_ASM_NASM_COMPILER="%NASM_PATH%" -DWITH_JPEG8=1 -DREQUIRE_SIMD=1 -DWITH_CRT_DLL=1 ../

::msbuild jpeg-static.vcxproj /p:Configuration=Debug /p:Platform=x64
msbuild jpeg-static.vcxproj /p:Configuration=Release /p:Platform=x64

:: install

cd /D %DEPS_ROOT%

copy /Y libjpeg-turbo\*.h include\
copy /Y libjpeg-turbo\build64\*.h include\

copy /Y libjpeg-turbo\build64\Release\*.lib lib64\