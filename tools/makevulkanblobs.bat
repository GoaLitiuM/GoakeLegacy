@echo off
call vcvarsall.bat

pushd %CD%

cd ..\engine\shaders\

cl makevulkanblob.c

makevulkanblob.exe vulkan\fixedemu.glsl vulkanblobs\fixedemu.fvb
makevulkanblob.exe vulkan\q3terrain.glsl vulkanblobs\q3terrain.fvb
makevulkanblob.exe vulkan\altwater.glsl vulkanblobs\altwater.fvb
makevulkanblob.exe vulkan\bloom_blur.glsl vulkanblobs\bloom_blur.fvb
makevulkanblob.exe vulkan\bloom_filter.glsl vulkanblobs\bloom_filter.fvb
makevulkanblob.exe vulkan\bloom_final.glsl vulkanblobs\bloom_final.fvb
makevulkanblob.exe vulkan\colourtint.glsl vulkanblobs\colourtint.fvb
makevulkanblob.exe vulkan\crepuscular_opaque.glsl vulkanblobs\crepuscular_opaque.fvb
makevulkanblob.exe vulkan\crepuscular_rays.glsl vulkanblobs\crepuscular_rays.fvb
makevulkanblob.exe vulkan\crepuscular_sky.glsl vulkanblobs\crepuscular_sky.fvb
makevulkanblob.exe vulkan\depthonly.glsl vulkanblobs\depthonly.fvb
makevulkanblob.exe vulkan\default2d.glsl vulkanblobs\default2d.fvb
makevulkanblob.exe vulkan\defaultadditivesprite.glsl vulkanblobs\defaultadditivesprite.fvb
makevulkanblob.exe vulkan\defaultskin.glsl vulkanblobs\defaultskin.fvb
makevulkanblob.exe vulkan\defaultsky.glsl vulkanblobs\defaultsky.fvb
makevulkanblob.exe vulkan\defaultskybox.glsl vulkanblobs\defaultskybox.fvb
makevulkanblob.exe vulkan\defaultfill.glsl vulkanblobs\defaultfill.fvb
makevulkanblob.exe vulkan\defaultsprite.glsl vulkanblobs\defaultsprite.fvb
makevulkanblob.exe vulkan\defaultwall.glsl vulkanblobs\defaultwall.fvb
makevulkanblob.exe vulkan\defaultwarp.glsl vulkanblobs\defaultwarp.fvb
makevulkanblob.exe vulkan\defaultgammacb.glsl vulkanblobs\defaultgammacb.fvb
makevulkanblob.exe vulkan\drawflat_wall.glsl vulkanblobs\drawflat_wall.fvb
makevulkanblob.exe vulkan\wireframe.glsl vulkanblobs\wireframe.fvb
makevulkanblob.exe vulkan\itemtimer.glsl vulkanblobs\itemtimer.fvb
makevulkanblob.exe vulkan\lpp_depthnorm.glsl vulkanblobs\lpp_depthnorm.fvb
makevulkanblob.exe vulkan\lpp_light.glsl vulkanblobs\lpp_light.fvb
makevulkanblob.exe vulkan\lpp_wall.glsl vulkanblobs\lpp_wall.fvb
makevulkanblob.exe vulkan\postproc_fisheye.glsl vulkanblobs\postproc_fisheye.fvb
makevulkanblob.exe vulkan\postproc_panorama.glsl vulkanblobs\postproc_panorama.fvb
makevulkanblob.exe vulkan\postproc_laea.glsl vulkanblobs\postproc_laea.fvb
makevulkanblob.exe vulkan\postproc_stereographic.glsl vulkanblobs\postproc_stereographic.fvb
makevulkanblob.exe vulkan\postproc_equirectangular.glsl vulkanblobs\postproc_equirectangular.fvb
makevulkanblob.exe vulkan\postproc_ascii.glsl vulkanblobs\postproc_ascii.fvb
makevulkanblob.exe vulkan\fxaa.glsl vulkanblobs\fxaa.fvb
makevulkanblob.exe vulkan\underwaterwarp.glsl vulkanblobs\underwaterwarp.fvb
makevulkanblob.exe vulkan\menutint.glsl vulkanblobs\menutint.fvb
makevulkanblob.exe vulkan\terrain.glsl vulkanblobs\terrain.fvb
makevulkanblob.exe vulkan\rtlight.glsl vulkanblobs\rtlight.fvb

del temp.frag
del temp.tmp
del temp.vert

del makevulkanblob.obj
del makevulkanblob.exe

popd