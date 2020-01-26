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
cd /D %DEPS_ROOT%libogg

rmdir /S /Q build64 > nul
mkdir build64
cd build64



::cmake -G"Visual Studio 16 2019" -Ax64 -DCMAKE_C_FLAGS_RELEASE="/MT /O2 /Ob2 /DNDEBUG" -DBUILD_TESTING=0 -DPNG_BUILD_ZLIB=1 -DZLIB_INCLUDE_DIR="%INCLUDE_PATH%" -DZLIB_LIBRARY_DEBUG="%LIB64_PATH%\zlibstaticd.lib" -DZLIB_LIBRARY_RELEASE="%LIB64_PATH%\zlibstatic.lib" ../
cmake -G"Visual Studio 16 2019" -Ax64 -DBUILD_TESTING=0 -DPNG_BUILD_ZLIB=1 -DZLIB_INCLUDE_DIR="%INCLUDE_PATH%" -DZLIB_LIBRARY_DEBUG="%LIB64_PATH%\zlibstaticd.lib" -DZLIB_LIBRARY_RELEASE="%LIB64_PATH%\zlibstatic.lib" ../

::msbuild png_static.vcxproj /p:Configuration=Debug /p:Platform=x64
msbuild ogg.vcxproj /p:Configuration=Release /p:Platform=x64





:: build script for libogg-1.3.3 and older:

::cd /D libogg
::cd win32

:: upgrade solution files
::rmdir /S /Q VS2017 > nul
::xcopy VS2015 VS2017 /E /H /K /I > nul
::cd VS2017

:: we have to manually wait for the upgrade process to finish because devenv is a GUI process
::devenv.exe libogg_dynamic.sln /Upgrade
::devenv.exe libogg_static.sln /Upgrade

::echo Upgrading solution files...
::goto check

:::wait
::ping -n 2 127.0.0.1 > nul

:::check
:: we upgrade two solution files so we wait for the second log to appear
::if not exist UpgradeLog2.htm GOTO wait

:::build
::echo Upgrade done?

::rmdir /S /Q x64 > nul

::::msbuild libogg_static.vcxproj /p:Configuration=Debug /p:Platform=x64
::msbuild libogg_static.vcxproj /p:Configuration=Release /p:Platform=x64

:: install

cd /D %DEPS_ROOT%

mkdir include\ogg > nul

copy /Y libogg\include\ogg\*.h include\ogg\

copy /Y libogg\build64\Release\ogg.lib lib64\libogg_static.lib
::copy /Y libogg\win32\VS2017\x64\Release\*.lib lib64\
::copy /Y libogg\win32\VS2017\x64\Release\*.pdb lib64\
