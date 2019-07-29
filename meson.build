project('goake', 'c', 'cpp')

win = import('windows')

c_args = [
  #'-Wstrict-prototypes',
  #'-Wold-style-definition',
  #'-Wold-style-declaration',
  #'-Wvla',
  #'-Wdeclaration-after-statement',

  #debug
  #'-fstack-protector-strong',
  #'-std=gnu89',
]

c_args += [
  '-DCONFIG_FILE_NAME=config_goake.h',
]

if get_option('buildtype') == 'debug'
  c_args += '-DDEBUG'
endif

client_c_args = [
  '-DGLQUAKE',
  '-DVKQUAKE',
  '-DD3D9QUAKE',
  '-DD3D11QUAKE',
]

server_c_args = '-DSERVERONLY'

includes = [
  include_directories('engine/common'),
  include_directories('engine/client'),
  include_directories('engine/qclib'),
  include_directories('engine/gl'),
  include_directories('engine/server'),
  include_directories('engine'),
]

# icon file for Windows
resource_files = [
  win.compile_resources('engine/client/winquake.rc', include_directories: includes, args: c_args)
] 

arch_src_files = [
  resource_files,
  'engine/common/sys_win_threads.c',
  'engine/common/net_ssl_winsspi.c',
  'engine/common/fs_win32.c',
  'engine/client/cd_win.c',
  'engine/client/in_win.c',
  'engine/client/snd_al.c',
  'engine/client/snd_directx.c',
  'engine/client/snd_wasapi.c',
  'engine/client/snd_win.c',
  'engine/client/snd_xaudio.c',
  'engine/client/sys_win.c',

  'engine/gl/gl_vidnt.c',

  'engine/d3d/d3d_backend.c',
  'engine/d3d/d3d_image.c',
  'engine/d3d/d3d_shader.c',
  'engine/d3d/d3d11_backend.c',
  'engine/d3d/d3d11_image.c',
  'engine/d3d/d3d11_shader.c',
  'engine/d3d/d3d8_backend.c',
  'engine/d3d/d3d8_image.c',
  'engine/d3d/vid_d3d.c',
  'engine/d3d/vid_d3d11.c',
  'engine/d3d/vid_d3d8.c',
]

common_src_files = [
  #these files are common to both server-only and client+server builds.
  'engine/common/cmd.c',
  'engine/common/com_mesh.c',
  'engine/common/common.c',
  'engine/common/crc.c',
  'engine/common/cvar.c',
  'engine/common/fs.c',
  'engine/common/fs_dzip.c',
  'engine/common/fs_pak.c',
  'engine/common/fs_stdio.c',
  'engine/common/fs_xz.c',
  'engine/common/fs_vpk.c',
  'engine/common/fs_zip.c',
  'engine/common/gl_q2bsp.c',
  'engine/common/huff.c',
  'engine/common/log.c',
  'engine/common/mathlib.c',
  'engine/common/md4.c',
  'engine/common/net_chan.c',
  'engine/common/net_ice.c',
  'engine/common/net_wins.c',
  'engine/common/plugin.c',
  'engine/common/pmove.c',
  'engine/common/pmovetst.c',
  'engine/common/pr_bgcmd.c',
  'engine/common/q1bsp.c',
  'engine/common/q2pmove.c',
  'engine/common/q3common.c',
  'engine/common/qvm.c',
  'engine/common/sha1.c',
  'engine/common/translate.c',
  'engine/common/zone.c',

  #sigh
  'engine/client/pr_skelobj.c',
  'engine/client/m_download.c',
  'engine/client/net_master.c',

  #these are here because of hitmodel etc
  'engine/gl/gl_heightmap.c',
  'engine/gl/gl_hlmdl.c',
  'engine/gl/gl_model.c',

  'engine/server/net_preparse.c',
  'engine/server/pr_cmds.c',
  'engine/server/pr_lua.c',
  'engine/server/pr_q1qvm.c',
  'engine/server/savegame.c',
  'engine/server/sv_ccmds.c',
  'engine/server/sv_chat.c',
  'engine/server/sv_cluster.c',
  'engine/server/sv_demo.c',
  'engine/server/sv_ents.c',
  'engine/server/sv_init.c',
  'engine/server/sv_main.c',
  'engine/server/sv_master.c',
  'engine/server/sv_move.c',
  'engine/server/sv_mvd.c',
  'engine/server/sv_nchan.c',
  'engine/server/sv_phys.c',
  'engine/server/sv_rankin.c',
  'engine/server/sv_send.c',
  'engine/server/sv_sql.c',
  'engine/server/sv_user.c',
#	'engine/server/svhl_game.c',
#	'engine/server/svhl_phys.c',
#	'engine/server/svhl_world.c',
  'engine/server/svq2_ents.c',
  'engine/server/svq2_game.c',
  'engine/server/svq3_game.c',
  'engine/server/world.c',

  'engine/qclib/comprout.c',
  'engine/qclib/hash.c',
  'engine/qclib/initlib.c',
  'engine/qclib/pr_edict.c',
  'engine/qclib/pr_exec.c',
  'engine/qclib/pr_multi.c',
  'engine/qclib/qcc_cmdlib.c',
  'engine/qclib/qcc_pr_comp.c',
  'engine/qclib/qcc_pr_lex.c',
#	'engine/qclib/decomp.c',
#	'engine/qclib/packager.c',
#	'engine/qclib/pr_x86.c',
#	'engine/qclib/qccgui.c',
#	'engine/qclib/qccguiqt.cpp',
#	'engine/qclib/qccguistuff.c',
#	'engine/qclib/qcctui.c',
  'engine/qclib/qccmain.c',
  'engine/qclib/qcd_main.c',
  'engine/qclib/qcdecomp.c',

  'engine/http/httpclient.c',
]

client_src_files = [
  'engine/client/cl_cam.c',
  'engine/client/cl_cg.c',
  'engine/client/cl_demo.c',
  'engine/client/cl_ents.c',
  'engine/client/cl_ignore.c',
  'engine/client/cl_input.c',
  'engine/client/cl_main.c',
  'engine/client/cl_parse.c',
  'engine/client/cl_pred.c',
  'engine/client/cl_screen.c',
  'engine/client/cl_tent.c',
  'engine/client/cl_ui.c',
#	'engine/client/clhl_game.c',
  'engine/client/clq2_cin.c',
  'engine/client/clq2_ents.c',
  'engine/client/clq3_parse.c',
  'engine/client/console.c',
  'engine/client/fragstats.c',
  'engine/client/image.c',
  'engine/client/in_generic.c',
  'engine/client/keys.c',
  'engine/client/m_items.c',
  'engine/client/m_master.c',
  'engine/client/m_mp3.c',
  'engine/client/m_multi.c',
  'engine/client/m_options.c',
  'engine/client/m_script.c',
  'engine/client/m_native.c',
  'engine/client/m_single.c',
  'engine/client/menu.c',
  'engine/client/p_classic.c',
  'engine/client/p_null.c',
  'engine/client/p_script.c',
  'engine/client/pr_clcmd.c',
  'engine/client/pr_csqc.c',
  'engine/client/pr_menu.c',
  'engine/client/r_2d.c',
  'engine/client/r_d3.c',
  'engine/client/r_part.c',
  'engine/client/r_partset.c',
  'engine/client/r_surf.c',
  'engine/client/renderer.c',
  'engine/client/renderque.c',
  'engine/client/roq_read.c',
  'engine/client/sbar.c',
  'engine/client/skin.c',
  'engine/client/snd_dma.c',
  'engine/client/snd_mem.c',
  'engine/client/snd_mix.c',
  'engine/client/snd_mp3.c',
  'engine/client/snd_ov.c',
  'engine/client/textedit.c',
  'engine/client/valid.c',
  'engine/client/vid_headless.c',
  'engine/client/view.c',
  'engine/client/wad.c',
  'engine/client/zqtp.c',


  #These are generic renderer files
  'engine/gl/gl_alias.c',
  'engine/gl/gl_font.c',
  'engine/gl/gl_ngraph.c',
  'engine/gl/gl_rlight.c',
  'engine/gl/gl_shader.c',
  'engine/gl/gl_shadow.c',
  'engine/gl/gl_warp.c',
  'engine/gl/ltface.c',

  #These are GL-specific, but can be left even if no gl is supported.
  'engine/gl/gl_backend.c',
  'engine/gl/gl_bloom.c',
  'engine/gl/gl_draw.c',
  'engine/gl/gl_rmain.c',
  'engine/gl/gl_rmisc.c',
  'engine/gl/gl_rsurf.c',
  'engine/gl/gl_screen.c',
  'engine/gl/gl_vidcommon.c',
  'engine/gl/glmod_doom.c',

  'engine/vk/vk_backend.c',
  'engine/vk/vk_init.c',
]

server_src_files = [
  resource_files,
  'engine/common/sys_win_threads.c',
  'engine/common/net_ssl_winsspi.c',
  'engine/common/fs_win32.c',
  'engine/server/sv_sys_win.c',
]

fteq3bot_src_files = [
  'engine/botlib/be_aas_bspq3.c',
  'engine/botlib/be_aas_entity.c',
  'engine/botlib/be_aas_move.c',
  'engine/botlib/be_aas_routealt.c',
  'engine/botlib/be_ai_char.c',
  'engine/botlib/be_ai_goal.c',
  'engine/botlib/be_ai_weight.c',
  'engine/botlib/l_crc.c',
  'engine/botlib/l_memory.c',
  'engine/botlib/l_struct.c',
  'engine/botlib/be_aas_cluster.c',
  'engine/botlib/be_aas_file.c',
  'engine/botlib/be_aas_optimize.c',
  'engine/botlib/be_aas_route.c',
  'engine/botlib/be_ai_chat.c',
  'engine/botlib/be_ai_move.c',
  'engine/botlib/be_ea.c',
  'engine/botlib/l_libvar.c',
  'engine/botlib/l_precomp.c',
  'engine/botlib/be_aas_debug.c',
  'engine/botlib/be_aas_main.c',
  'engine/botlib/be_aas_reach.c',
  'engine/botlib/be_aas_sample.c',
  'engine/botlib/be_ai_gen.c',
  'engine/botlib/be_ai_weap.c',
  'engine/botlib/be_interface.c',
  'engine/botlib/l_log.c',
  'engine/botlib/l_script.c',
  'engine/botlib/standalone.c',
]

deps = [
  #dependency('zlib'),
  #dependency('gnutls'),
  #dependency('alsa'),
  #dependency('x11'),
  #dependency('opengl'),
  #meson.get_compiler('c').find_library('dl', required : false),
  #meson.get_compiler('c').find_library('m', required : false),
  #meson.get_compiler('c').find_library('ole32', required : true),
  #meson.get_compiler('c').find_library('gdi32', required : true),
  meson.get_compiler('c').find_library('wsock32', required : true),
  meson.get_compiler('c').find_library('ws2_32', required : true),
  meson.get_compiler('c').find_library('winmm', required : true),
]

bullet = declare_dependency(
  include_directories: include_directories('thirdparty/bullet2/src'),
  link_args: [
    '../thirdparty/lib64/BulletCollision.lib',
	  '../thirdparty/lib64/BulletDynamics.lib',
	  '../thirdparty/lib64/LinearMath.lib',
	  '../thirdparty/lib64/BulletSoftBody.lib',
  ])
if not bullet.found()
  bullet = dependency('bullet', required: false)
endif
if bullet.found()
  c_args += ['-DUSE_INTERNAL_BULLET', '-D_ALLOW_KEYWORD_MACROS']
  common_src_files += 'plugins/bullet/bulletplug.cpp'
  deps += bullet
endif

png = declare_dependency(
  include_directories: include_directories('thirdparty/include'),
  link_args: '../thirdparty/lib64/libpng16_static.lib')
if not png.found()
  png = dependency('png', required: false)
endif
if png.found()
  deps += png
else
  c_args += '-DNO_PNG'
endif

jpeg = declare_dependency(
  include_directories: include_directories('thirdparty/include'),
  link_args: '../thirdparty/lib64/jpeg-static.lib')
if not jpeg.found()
  jpeg = dependency('jpeg', required: false)
endif
if jpeg.found()
  deps += jpeg
else
  c_args += '-DNO_JPEG'
endif

ogg = declare_dependency(include_directories: include_directories('thirdparty/include'))
if not ogg.found()
  ogg = dependency('ogg', required: false)
endif

vorbisfile = declare_dependency(
  include_directories: include_directories('thirdparty/include'),
  link_args: '../thirdparty/lib64/libvorbisfile_static.lib')
if not vorbisfile.found()
  vorbisfile = dependency('vorbisfile', required: false)
endif

if ogg.found() and vorbisfile.found()
  deps += ogg
  deps += vorbisfile
else
  c_args += '-DNO_OGG'
endif

freetype = declare_dependency(
  include_directories: [
    include_directories('thirdparty/include/freetype'),
    include_directories('thirdparty/include')
  ],
  link_args: '../thirdparty/lib64/freetype.lib')
if not freetype.found()
  freetype = dependency('freetype', required: false)
endif
if freetype.found()
  deps += freetype
  c_args += '-DFREETYPE_STATIC'
else
  c_args += '-DNO_FREETYPE'
endif

zlib = declare_dependency(
  include_directories: include_directories('thirdparty/include'),
  link_args: '../thirdparty/lib64/zlibstatic.lib')
if not zlib.found()
  zlib = dependency('zlib', required: false)
endif
if zlib.found()
  deps += zlib
else
  c_args += '-DNO_ZLIB'
endif

linker_args = []
#if get_option('buildtype') == 'debug'
#  linker_args = ['/nodefaultlib:libcmt', '/nodefaultlib:msvcrt', '/nodefaultlib:msvcrtd']
#else
linker_args = ['/nodefaultlib:msvcrtd', '/nodefaultlib:libcmt', '/nodefaultlib:libcmtd', '/MAP']
#endif

out = join_paths('..', 'out')

executable(join_paths(out, 'goake'),
  sources: [common_src_files, arch_src_files, client_src_files],
  include_directories: includes,
  dependencies: deps,
  c_args: [client_c_args, c_args],
  cpp_args: [client_c_args, c_args],
  link_args: linker_args,
  gui_app: true
)

executable(join_paths(out, 'goake-sv'),
  sources: [common_src_files, server_src_files],
  include_directories: includes,
  dependencies: deps,
  c_args: [server_c_args, c_args],
  cpp_args: [server_c_args, c_args],
  link_args: linker_args
)

executable(join_paths(out, 'fteqcc'),
  sources: [
    'engine/qclib/qcctui.c',
    'engine/qclib/comprout.c',
    'engine/qclib/hash.c',
    'engine/qclib/qcc_cmdlib.c',
    'engine/qclib/qcc_pr_comp.c',
    'engine/qclib/qcc_pr_lex.c',
    'engine/qclib/qccmain.c',
    'engine/qclib/qcd_main.c',
  ],
  include_directories: includes,
  dependencies: deps,
  c_args: [c_args],
  link_args: linker_args
)
