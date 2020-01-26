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

:: setup dependencies
SET "PKGCONFIG_PATH=%DEPS_ROOT%pkg-config.exe"

:: build
::SET "ZLIB_PATH=%DEPS_ROOT%zlib"
::SET "PNG_PATH=%DEPS_ROOT%libpng"
cd /D %DEPS_ROOT%freetype

rmdir /S /Q build64 > nul
mkdir build64
cd build64

cmake -G"Visual Studio 16 2019" -Ax64 -DFT_WITH_PNG=1 -DFT_WITH_ZLIB=1 -DPNG_PNG_INCLUDE_DIR="%INCLUDE_PATH%" -DPNG_LIBRARY_DEBUG="%LIB64_PATH%\libpng16_staticd.lib" -DPNG_LIBRARY_RELEASE="%LIB64_PATH%\libpng16_static.lib" -DZLIB_INCLUDE_DIR="%INCLUDE_PATH%" -DZLIB_LIBRARY_DEBUG="%LIB64_PATH%\zlibstaticd.lib" -DZLIB_LIBRARY_RELEASE="%LIB64_PATH%\zlibstatic.lib" ../

::msbuild freetype.vcxproj /p:Configuration=Debug /p:Platform=x64
msbuild freetype.vcxproj /p:Configuration=Release /p:Platform=x64

:: install

cd /D %DEPS_ROOT%

mkdir include\freetype > nul

copy /Y freetype\include\*.h include\
xcopy freetype\include\freetype include\freetype /Y /E /H /K /I

::copy /Y freetype\build64\Debug\*.lib lib64\
copy /Y freetype\build64\Release\*.lib lib64\
