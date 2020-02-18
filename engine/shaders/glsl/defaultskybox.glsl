!!permu FOG
!!samps reflectcube
!!cvardf r_skyfog=0.5
!!cvard4 r_glsl_skybox_orientation=0 0 0 0
#include "sys/defs.h"
#include "sys/fog.h"

//simple shader for simple skyboxes.

varying vec3 pos;
#ifdef VERTEX_SHADER
mat3 rotateAroundAxis(vec4 axis) //xyz axis, with angle in w
{
#define skyang axis.w*(3.14/180.0)*e_time
	axis.xyz = normalize(axis.xyz);
	float s = sin(skyang);
	float c = cos(skyang);
	float oc = 1.0 - c;

	return mat3(oc * axis.x * axis.x + c, oc * axis.x * axis.y - axis.z * s, oc * axis.z * axis.x + axis.y * s,
			oc * axis.x * axis.y + axis.z * s, oc * axis.y * axis.y + c, oc * axis.y * axis.z - axis.x * s,
			oc * axis.z * axis.x - axis.y * s, oc * axis.y * axis.z + axis.x * s, oc * axis.z * axis.z + c);
}
void main ()
{
	pos = v_position.xyz - e_eyepos;

	if (r_glsl_skybox_orientation.xyz != vec3(0.0))
		pos = pos*rotateAroundAxis(r_glsl_skybox_orientation);

	gl_Position = ftetransform();
}
#endif
#ifdef FRAGMENT_SHADER
void main ()
{
	vec4 skybox = textureCube(s_reflectcube, pos);
	gl_FragColor = vec4(mix(skybox.rgb, fog3(skybox.rgb), float(r_skyfog)), 1.0);
}
#endif
