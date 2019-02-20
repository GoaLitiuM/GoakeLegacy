//#pragma warning disable F210
#pragma warning disable Q207
#pragma warning disable F319

#define SND_JUMP "player/plyrjmp8.wav"
#define SND_JUMP_WATER "player/h2ojump.wav"
#define SND_LAND_SOFT "player/land.wav"
#define SND_LAND_HARD "player/land2.wav"
#define SND_WEAPON_RL "weapons/sgun1.wav"

#define SPR_EXPLOSION "progs/s_explod.spr"

#define MDL_PLAYER "progs/player.mdl"
#define MDL_ROCKET "progs/missile.mdl"

#define ENT_PLAYER_SPAWN "info_player_deathmatch"

#define bool int
#define true 1
#define false 0

// player collision box and offsets
vector VEC_ORIGIN = '0 0 0';
vector VEC_OFFSET_EYES = '0 0 26';
vector VEC_HULL_MIN = '-15 -15 -24';
vector VEC_HULL_MAX = '15 15 32';

const float FL_JUMPRELEASED = 4096;

// custom voice channels
const float CHAN_VOICE2 = 4;
/*
// items
float	IT_AXE					= 4096;
float	IT_SHOTGUN				= 1;
float	IT_SUPER_SHOTGUN		= 2;
float	IT_NAILGUN				= 4;
float	IT_SUPER_NAILGUN		= 8;
float	IT_GRENADE_LAUNCHER		= 16;
float	IT_ROCKET_LAUNCHER		= 32;
float	IT_LIGHTNING			= 64;
float	IT_EXTRA_WEAPON			= 128;

float	IT_SHELLS				= 256;
float	IT_NAILS				= 512;
float	IT_ROCKETS				= 1024;
float	IT_CELLS				= 2048;

float	IT_ARMOR1				= 8192;
float	IT_ARMOR2				= 16384;
float	IT_ARMOR3				= 32768;
float	IT_SUPERHEALTH			= 65536;

float	IT_KEY1					= 131072;
float	IT_KEY2					= 262144;

float	IT_INVISIBILITY			= 524288;
float	IT_INVULNERABILITY		= 1048576;
float	IT_SUIT					= 2097152;
float	IT_QUAD					= 4194304;

*/
float   TE_SPIKE                = 0;
float   TE_SUPERSPIKE   = 1;
float   TE_GUNSHOT              = 2;
float   TE_EXPLOSION    = 3;
float   TE_TAREXPLOSION = 4;
float   TE_LIGHTNING1   = 5;
float   TE_LIGHTNING2   = 6;
float   TE_WIZSPIKE             = 7;
float   TE_KNIGHTSPIKE  = 8;
float   TE_LIGHTNING3   = 9;
float   TE_LAVASPLASH   = 10;
float   TE_TELEPORT             = 11;
float   TE_BLOOD                = 12;
float   TE_LIGHTNINGBLOOD = 13;

float SVC_TEMPENTITY    = 23;

#define FULLSEND 0xFFFFFF

void noop() {};

void println(... argc)
{
    for (int i=0; i<argc; i++)
        print(va_arg(i, string));
    print("\n");
}

// input_buttons
#define BUTTON_ATTACK 1
#define BUTTON_JUMP 2
#define BUTTON_USE 4

//pmove flags. seperate from flags
#define PMF_JUMP_HELD 1
#define PMF_LADDER 2

string vtos2(vector vec)
{
    local vector vec2 = [floor(vec_x), floor(vec_y), floor(vec_z)];
    return strcat("'", ftos(vec2_x), " ", ftos(vec2_y), " ", ftos(vec2_z), "'");
}

vector getViewAngles(entity ent = 0)
{
#ifdef CSQC
    return view_angles;
#else
    if (ent == 0)
        return self.v_angle;
    else
        return ent.v_angle;
#endif
}

void setViewAngles(entity ent, vector ang)
{
#ifdef CSQC
    //if (ent == self)
        view_angles = ang;
#else
    if (ent == 0)
        self.v_angle = ang;
    else
        ent.v_angle = ang;
#endif
}

vector getViewOffsets()
{
#ifdef CSQC
    //return view_angles;
    // maybe?
    //local vector origin_offset = getproperty(VF_ORIGIN); // view origin including the offset
    return VEC_OFFSET_EYES;
    //return origin_offset - self.origin;
#else
    return self.view_ofs;
#endif
}

void setAngles(entity ent, vector ang, float fix = 0)
{
    ent.angles = ang;
    if (fix != 0)
        ent.fixangle = fix;
}

// prediction friendly sound function
void clientsound(entity e, float chan, string samp, float vol, float atten, float speedpct = 0, float flags = 0, float timeofs = 0)
{
#ifdef SSQC
    local entity old = msg_entity;
	local entity player = world;
	while (1)
	{
		player = find(player, classname, "player");
		if (player == world)
			break;

        //if (player != e)
        {
            msg_entity = player;
            sound(e, chan, samp, vol, atten, speedpct, flags | SOUNDFLAG_UNICAST, timeofs);
        }
	}

    msg_entity = old;

#endif

#ifdef CSQC
    sound(e, chan, samp, vol, atten, speedpct, flags, timeofs);
#endif
}
