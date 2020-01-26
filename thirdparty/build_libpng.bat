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
cd /D %DEPS_ROOT%libpng

rmdir /S /Q build64 > nul
mkdir build64
cd build64

::cmake -G"Visual Studio 16 2019" -Ax64 -DCMAKE_C_FLAGS_RELEASE="/MT /O2 /Ob2 /DNDEBUG" -DPNG_TESTS=0 -DPNG_BUILD_ZLIB=1 -DZLIB_INCLUDE_DIR="%INCLUDE_PATH%" -DZLIB_LIBRARY_DEBUG="%LIB64_PATH%\zlibstaticd.lib" -DZLIB_LIBRARY_RELEASE="%LIB64_PATH%\zlibstatic.lib" ../
cmake -G"Visual Studio 16 2019" -Ax64 -DPNG_TESTS=0 -DPNG_BUILD_ZLIB=1 -DZLIB_INCLUDE_DIR="%INCLUDE_PATH%" -DZLIB_LIBRARY_DEBUG="%LIB64_PATH%\zlibstaticd.lib" -DZLIB_LIBRARY_RELEASE="%LIB64_PATH%\zlibstatic.lib" ../

::msbuild png_static.vcxproj /p:Configuration=Debug /p:Platform=x64
msbuild png_static.vcxproj /p:Configuration=Release /p:Platform=x64

:: install

cd /D %DEPS_ROOT%

copy /Y libpng\*.h include\
copy /Y libpng\build64\*.h include\

::copy /Y libpng\build64\Debug\*.lib lib64\
copy /Y libpng\build64\Release\*.lib lib64\
