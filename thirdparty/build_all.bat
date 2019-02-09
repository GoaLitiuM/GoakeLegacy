@echo off

pushd

SET "VSPATH=C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\"

if not defined VCINSTALLDIR call "%VSPATH%\vcvarsall.bat" x64

where /Q cmake.exe
IF ERRORLEVEL 1 set "PATH=%PATH%;C:\Program Files\CMake\bin"

SET "DEPS_ROOT=%~dp0"
SET "INCLUDE_PATH=%DEPS_ROOT%include"
SET "LIB64_PATH=%DEPS_ROOT%lib64"

if not exist %INCLUDE_PATH% mkdir %INCLUDE_PATH%
if not exist %LIB64_PATH% mkdir %LIB64_PATH%

cd /D %~dp0

call build_zlib.bat
call build_libpng.bat
call build_libvorbis.bat
call build_libogg.bat
call build_libjpeg-turbo.bat
call build_freetype.bat

popd

pause