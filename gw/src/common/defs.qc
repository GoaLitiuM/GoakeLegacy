#ifdef CSQC
// version of 'time' which is more suitable for prediction (time + ping)
#define svtime (time + ((clientcommandframe - servercommandframe) * (1.0f/maxfps)))
#else
#define svtime time
#endif

enum // entity types used in SendEntity and CSQC_Ent_Update
{
	SENDENTITY_PLAYER = 1,
	SENDENTITY_ROCKET,
	SENDENTITY_ITEM,
};

enum
{
	// player stats
	STAT_HEALTH,            // EV_FLOAT
	STAT_ARMOR,             // EV_FLOAT
	STAT_ARMOR_MULTIPLIER,	// EV_FLOAT
	STAT_CURRENT_WEAPON,	// EV_FLOAT
	STAT_NEXT_WEAPON,		// EV_FLOAT
	STAT_WEAPONS,           // EV_INTEGER
	STAT_ITEMS,             // EV_INTEGER
	STAT_EFFECTS,           // EV_INTEGER
	STAT_RELOAD_TIME,       // EV_FLOAT
	STAT_PROJECTILE_ID,		// EV_INTEGER

	// ammo stats
	STAT_AMMO_NONE,			// or STAT_AMMO_FIRST
	STAT_AMMO_SHELLS,   	// EV_INTEGER
	STAT_AMMO_NAILS, 	  	// EV_INTEGER
	STAT_AMMO_ROCKETS,   	// EV_INTEGER
	STAT_AMMO_CELLS,		// EV_INTEGER
	STAT_AMMO_BOLTS, 	  	// EV_INTEGER
	STAT_AMMO_LAST,

	// global stats
	STAT_AUTOJUMP = 128,    // EV_FLOAT
};

#define STAT_AMMO_FIRST STAT_AMMO_NONE

enum
{
	WEAPON_NONE = 0,

	WEAPON_MELEE,
	WEAPON_2,
	WEAPON_SHOTGUN,
	WEAPON_NAILGUN,
	WEAPON_GRENADE,
	WEAPON_ROCKET,
	WEAPON_LIGHTNING,
	WEAPON_CROSSBOW,
	WEAPON_9,
	WEAPON_10,
	WEAPON_11,
	WEAPON_12,

	WEAPON_LAST, // do not touch this
};

enum
{
	IMPULSE_WEAPON_LAST = WEAPON_LAST,	// not used, all the impulses before this are reserved

	IMPULSE_RESPAWN = 20,
	IMPULSE_RESPAWN_FORCED,
};

int WEAPON_AMMO_STAT(int weapon)
{
	if (weapon == WEAPON_SHOTGUN)
		return STAT_AMMO_SHELLS;
	else if (weapon == WEAPON_NAILGUN)
		return STAT_AMMO_NAILS;
	else if (weapon == WEAPON_ROCKET)
		return STAT_AMMO_ROCKETS;
	else if (weapon == WEAPON_LIGHTNING)
		return STAT_AMMO_CELLS;
	else if (weapon == WEAPON_CROSSBOW)
		return STAT_AMMO_BOLTS;
	return STAT_AMMO_NONE;
}

int WEAPON_AMMO_INDEX(int weapon)
{
	return WEAPON_AMMO_STAT(weapon) - STAT_AMMO_NONE;
}

int AMMO_MAX(int ammo_stat)
{
	if (ammo_stat == STAT_AMMO_ROCKETS)
		return ROCKET_MAX_AMMO;
	else if (ammo_stat == STAT_AMMO_CELLS)
		return LIGHTNING_MAX_AMMO;
	else if (ammo_stat == STAT_AMMO_BOLTS)
		return CROSSBOW_MAX_AMMO;
	return 9999;
}

#define WEAPON_BIT(x) (1 << x)
#define STAT_WEAPON(x) (STAT_AMMO_FIRST + x)
#define ALL_WEAPONS (-1)
#define AMMO_INFINITE (-1)

// FIXME
int WeaponRocket_Fire(vector forward);
int WeaponLightning_Fire(vector forward);
int WeaponCrossbow_Fire(vector forward);

// globals for global stats
float sv_autojump;
float maxfps;

// player
.float health;
.float health_max;			// maximum allowed health
.float health_softcap;		// softcap for regular health pickups
.float health_time;			// last health tick time
.int health_mega_left;	// how much picked up mega is left before it starts respawning
.entity health_mega_ent;	// last picked up mega
.float armortype;
.float armorvalue;
.float last_velocity_z;
.float last_pmove_flags;
.float reload_time;
.int weapon;
.int weapon_next;
.int weapons;
.int ammo[STAT_AMMO_LAST-STAT_AMMO_FIRST+1];
.float weapon_sound_loop_time;
.float death_time;
.bool spawn_wish;
.float event_flags;
.bool is_attacking;
.float landed_time;
.float race_start_time;
.bool race_started;
vector input_subframe_angles;
.int voted;

// projectiles
.int projectile_id;

// items
.bool itemclass;
.entity last_touched; // last entity who touched the item
.string pickup_sound;
.bool() touch2;
.int count;
.int ammo_stat;
.float respawn_time;

// item_armor*
#define armorvalue_min armorvalue
.float armorvalue_max;

// sound flags
const float SOUNDFLAG_PREDICT = 128;

// for debugging
#ifdef CSQC
#define CLSV "cl "
#else
#define CLSV "sv "
#endif

// SendFlag bits, first 8 bits are shared with all types of entities
#define SENDFLAGS_ORIGIN		0x0001
#define SENDFLAGS_ANGLES		0x0002
#define SENDFLAGS_VELOCITY		0x0004
#define SENDFLAGS_AVELOCITY		0x0008

#define SENDFLAGS_FLAGS			0x0010	//flags and pmove_flags
#define SENDFLAGS_JUMP			0x0020
#define SENDFLAGS_PHYSICS		0x0040	//movetype and solid
#define SENDFLAGS_RESERVED2		0x0080

const int SENDFLAGS_ALL =		(SENDFLAGS_ORIGIN | SENDFLAGS_ANGLES | SENDFLAGS_VELOCITY | SENDFLAGS_AVELOCITY | SENDFLAGS_FLAGS | SENDFLAGS_JUMP | SENDFLAGS_PHYSICS);

// player specific SendFlags
#define SENDFLAGS_PLAYER_INIT	0x0100

// item specific SendFlags
#define SENDFLAGS_ITEM_INIT		0x0100
#define SENDFLAGS_ITEM_ACTIVE	0x0200

// CSQC events
enum
{
	EVENT_LIGHTNING = 1,
	EVENT_PLAYER_ATTACK,
	EVENT_PLAYER_DEATH,
	EVENT_GAMEMODE_TIMER,
	EVENT_CALLVOTE,
	EVENT_CALLVOTE_PLAYERVOTE,
	EVENT_CALLVOTE_FINISHED,
};
