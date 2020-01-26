#ifdef CSQC
float svtime; // version of 'time' which is more suitable for prediction (time + ping)
#else
#define svtime time
#endif

enum
{
	// player stats
	STAT_HEALTH,            // EV_FLOAT
	STAT_ARMOR,             // EV_FLOAT
	STAT_CURRENT_WEAPON,	// EV_FLOAT
	STAT_NEXT_WEAPON,		// EV_FLOAT
	STAT_WEAPONS,           // EV_INTEGER
	STAT_ITEMS,             // EV_INTEGER
	STAT_EFFECTS,           // EV_INTEGER
	STAT_RELOAD_TIME,       // EV_FLOAT
	STAT_PROJECTILE_ID,		// EV_FLOAT

	// ammo stats
	STAT_AMMO_NONE,
	STAT_AMMO_SHELLS,   	// EV_INTEGER
	STAT_AMMO_NAILS, 	  	// EV_INTEGER
	STAT_AMMO_ROCKETS,   	// EV_INTEGER
	STAT_AMMO_CELLS,		// EV_INTEGER
	STAT_AMMO_BOLTS, 	  	// EV_INTEGER
	STAT_AMMO_LAST,

	// global stats
	STAT_AUTOJUMP = 128,    // EV_FLOAT
};

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
	else if (weapon == WEAPON_GRENADE || weapon == WEAPON_ROCKET)
		return STAT_AMMO_ROCKETS;
	else if (weapon == WEAPON_LIGHTNING)
		return STAT_AMMO_CELLS;
	else if (weapon == WEAPON_CROSSBOW)
		return STAT_AMMO_BOLTS;
	else
		return STAT_AMMO_NONE;
}

int WEAPON_AMMO_INDEX(int weapon)
{
	return WEAPON_AMMO_STAT(weapon) - STAT_AMMO_NONE;
}

#define WEAPON_BIT(x) (1 << x)
#define STAT_WEAPON(x) (STAT_AMMO_FIRST + x)
#define ALL_WEAPONS (-1)

int WeaponRocket_Fire();
int WeaponLightning_Fire();
int WeaponCrossbow_Fire();

// globals for global stats
float sv_autojump;
float maxfps;

// player
.float last_velocity_z;
.float last_pmove_flags;
.float reload_time;
.float weapon;
.float weapon_next;
.int weapons;
.int ammo[WEAPON_LAST-1];
.float weapon_sound_loop_time;
.float death_time;
.bool spawn_wish;
.float event_flags;
.bool is_attacking;
.float landed_time;

// projectiles
.int projectile_id;

// items
.entity last_touched; // last entity who touched the item

// sound flags
const float SOUNDFLAG_PREDICT = 128;

// for debugging
#ifdef CSQC
#define CLSV "cl "
#else
#define CLSV "sv "
#endif

// SendFlag bits, shared with all types of entities
#define SENDFLAGS_ORIGIN		0x000001
#define SENDFLAGS_ANGLES		0x000002
#define SENDFLAGS_VELOCITY		0x000004
#define SENDFLAGS_AVELOCITY		0x000008

#define SENDFLAGS_FLAGS			0x000010
#define SENDFLAGS_JUMP			0x000020
#define SENDFLAGS_RESERVED1		0x000040
#define SENDFLAGS_RESERVED2		0x000080

#define SENDFLAGS_ALL			0xFFFFFF
#define SENDFLAGS_PHYSICS		(SENDFLAGS_ORIGIN || SENDFLAGS_ANGLES || SENDFLAGS_VELOCITY)

// player specific SendFlags
#define SENDFLAGS_PLAYER_EVENT_FLAGS	0x000100

// SENDFLAGS_PLAYER_EVENT_FLAGS events
#define PLAYER_EVENT_INIT		0x000001	// player respawns

// CSQC events
enum
{
	EVENT_LIGHTNING = 1,
	EVENT_PLAYER_ATTACK = 2,
};
