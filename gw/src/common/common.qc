#define SND_JUMPLAND "player/player_jumpland.wav"
#define SND_JUMPLAND_VARIANCE 0.07
#define SND_JUMPLAND_VOLUME 1.0
#define SND_JUMPLAND_JUMP_VOLUME 1.0
#define SND_JUMPLAND_LAND_VOLUME 0.65
#define SND_JUMPLAND_LAND_THRESHOLD -120
#define SND_JUMPLAND_LAND_HARD_VOLUME 0.9
#define SND_JUMPLAND_LAND_HARD_THRESHOLD -300

#define SND_WEAPON_ROCKET "weapons/sgun1.wav"
#define SND_WEAPON_LIGHTNING "weapons/lhit.wav"
#define SND_WEAPON_CROSSBOW "weapons/firebolt.wav"

#define SND_WEAPON_PICKUP "weapons/pkup.wav"
#define SND_ITEM_RESPAWN "items/itembk2.wav"

#define SPR_EXPLOSION "progs/s_explod.spr"

#define MDL_PLAYER "models/players/crash"
#define MDL_ROCKET "progs/missile.mdl"
#define MDL_BEAM "progs/bolt2.mdl"
#define MDL_ARROW "progs/arrow.mdl"

#define ENT_PLAYER_SPAWN "info_player_deathmatch"

#define CLASS_PLAYER "player"
#define CLASS_ROCKET "rocket"
#define CLASS_LIGHTNING "lightning"
#define CLASS_ARROW "arrow"

// player collision box and offsets
const vector VEC_ORIGIN = '0 0 0';
const vector VEC_OFFSET_EYES = '0 0 26';
const vector VEC_HULL_MIN = '-15 -15 -24';
const vector VEC_HULL_MAX = '15 15 32';

// custom voice channels
const float CHAN_VOICE2 = 4;

void Weapon_Init();
void RegisterStats();

void Common_Init()
{
	Weapon_Init();
	RegisterStats();
}

void noop() {};

void destroy() { remove(self); }

void println(... argc)
{
	for (float i=0; i<argc; i++)
		print(va_arg(i, string));
	print("\n");
}

#if 1
#define assert(EXPR) do { if (!(EXPR)) error("assertion falure\n"); } while(0)
#else
#define assert(EXPR) (void)0
#endif

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

void setAngles(entity ent, vector ang, float fix = 0)
{
	ent.angles = ang;
	if (fix != 0)
		ent.fixangle = fix;
}

// prediction friendly sound function
// client: the player who triggered this sound, may ignore this sound
void clientsound(entity ent, float chan, string samp, float vol, float atten, float speed = 0.0, float flags = 0, float timeofs = 0, entity client = 0)
{
#ifdef SSQC
	entity old = msg_entity;
	entity player = world;
	entity player_source = client;
	if (client == 0 || client.classname != CLASS_PLAYER)
		player_source = ent;
	if (player_source.classname != CLASS_PLAYER)
		player_source = ent.owner;

	while (1)
	{
		player = find(player, classname, CLASS_PLAYER);
		if (player == world)
			break;

		float player_flags = flags | SOUNDFLAG_UNICAST;
		if (player == player_source)
			player_flags |= SOUNDFLAG_PREDICT; // the player made this sound
		msg_entity = player;
		sound(ent, chan, samp, vol, atten, speed*100.0, player_flags, timeofs);
	}

	msg_entity = old;

#endif

#ifdef CSQC
	sound(ent, chan, samp, vol, atten, speed*100.0, flags, timeofs);
#endif
}
