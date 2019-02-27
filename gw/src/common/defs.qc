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

enum
{
    // player stats
    STAT_HEALTH = 0,

    // global stats
    STAT_AUTOJUMP = 128,
};

// globals for global stats
float sv_autojump;

#define bool int
#define true 1
#define false 0

// player collision box and offsets
const vector VEC_ORIGIN = '0 0 0';
const vector VEC_OFFSET_EYES = '0 0 26';
const vector VEC_HULL_MIN = '-15 -15 -24';
const vector VEC_HULL_MAX = '15 15 32';

const float FL_JUMPRELEASED = 4096;

// custom voice channels
const float CHAN_VOICE2 = 4;

// legacy effects
const float TE_EXPLOSION = 3;

float SVC_TEMPENTITY = 23;

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
