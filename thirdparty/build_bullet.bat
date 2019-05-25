@echo off

SET "DEPS_ROOT=%~dp0"

cd /D %DEPS_ROOT%bullet2

rmdir /S /Q build64 > nul
mkdir build64
cd build64

cmake -G"Visual Studio 16 2019" -Ax64 -DBUILD_BULLET2_DEMOS=0 -DBUILD_BULLET3=0 -DBUILD_CPU_DEMOS=0 -DBUILD_EXTRAS=0 -DBUILD_OPENGL3_DEMOS=0 -DBUILD_UNIT_TESTS=0 -DBULLET2_MULTITHREADING=1 -DUSE_MSVC_RUNTIME_LIBRARY_DLL=1 -DBUILD_CLSOCKET=0 -DBUILD_ENET=0 -DUSE_GLUT=0 -DUSE_GRAPHICAL_BENCHMARK=0 -DUSE_MSVC_INCREMENTAL_LINKING=1 ../

msbuild src/Bullet3Common/Bullet3Common.vcxproj /p:Configuration=Release /p:Platform=x64
msbuild src/BulletCollision/BulletCollision.vcxproj /p:Configuration=Release /p:Platform=x64
msbuild src/BulletDynamics/BulletDynamics.vcxproj /p:Configuration=Release /p:Platform=x64
msbuild src/BulletInverseDynamics/BulletInverseDynamics.vcxproj /p:Configuration=Release /p:Platform=x64
msbuild src/BulletSoftBody/BulletSoftBody.vcxproj /p:Configuration=Release /p:Platform=x64
msbuild src/LinearMath/LinearMath.vcxproj /p:Configuration=Release /p:Platform=x64

msbuild src/Bullet3Common/Bullet3Common.vcxproj /p:Configuration=RelWithDebInfo /p:Platform=x64
msbuild src/BulletCollision/BulletCollision.vcxproj /p:Configuration=RelWithDebInfo /p:Platform=x64
msbuild src/BulletDynamics/BulletDynamics.vcxproj /p:Configuration=RelWithDebInfo /p:Platform=x64
msbuild src/BulletInverseDynamics/BulletInverseDynamics.vcxproj /p:Configuration=RelWithDebInfo /p:Platform=x64
msbuild src/BulletSoftBody/BulletSoftBody.vcxproj /p:Configuration=RelWithDebInfo /p:Platform=x64
msbuild src/LinearMath/LinearMath.vcxproj /p:Configuration=RelWithDebInfo /p:Platform=x64

:: install

cd /D %DEPS_ROOT%

::mkdir include > nul

::copy /Y bullet2\src\*.h include\
::xcopy bullet2\src\freetype include\freetype /Y /E /H /K /I

::copy /Y freetype\build64\Debug\*.lib lib64\
copy /Y bullet2\build64\lib\Release\*.lib lib64\
