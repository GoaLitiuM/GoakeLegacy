@echo off

SET "DEPS_ROOT=%~dp0"
SET "NASM_PATH=%DEPS_ROOT%nasm\nasm.exe"
:: cmake scripts expects the path with forward slashes
SET "NASM_PATH=%NASM_PATH:\=/%"

cd /D %DEPS_ROOT%libjpeg-turbo

rmdir /S /Q build64 > nul
mkdir build64
cd build64

cmake -G"Visual Studio 15 2017 Win64" -DCMAKE_ASM_NASM_COMPILER="%NASM_PATH%" -DWITH_JPEG8=1 -DREQUIRE_SIMD=1 -DWITH_CRT_DLL=1 ../

::msbuild jpeg-static.vcxproj /p:Configuration=Debug /p:Platform=x64
msbuild jpeg-static.vcxproj /p:Configuration=Release /p:Platform=x64

:: install

cd /D %DEPS_ROOT%

copy /Y libjpeg-turbo\*.h include\
copy /Y libjpeg-turbo\build64\*.h include\

copy /Y libjpeg-turbo\build64\Release\*.lib lib64\