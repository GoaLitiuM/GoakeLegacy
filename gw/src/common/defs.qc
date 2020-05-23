#ifdef CSQC
// version of 'time' which is more suitable for prediction (time + ping)
#define svtime (time + ((clientcommandframe - servercommandframe) * (1.0f/maxfps)))
#else
#define svtime time
#endif

enum // entity types used in SendEntity and CSQC_Ent_Update
{
	SENDENTITY_PLAYER = 1,
	SENDENTITY_ITEM,
	SENDENTITY_ROCKET,
	SENDENTITY_NAIL,
	SENDENTITY_GRENADE,
	SENDENTITY_STAKE,
};

// CSQC events
enum
{
	EVENT_LIGHTNING = 1,
	EVENT_PLAYER_ATTACK,
	EVENT_PLAYER_DEATH,
	EVENT_GAMEMODE_TIMER,
	EVENT_GAMEMODE_STATE,
	EVENT_GAMEMODE_CHANGED,
	EVENT_CALLVOTE,
	EVENT_CALLVOTE_PLAYERVOTE,
	EVENT_CALLVOTE_FINISHED,
};

// GameMode states
enum class GameModeState : int
{
	Inactive = 1,	// server is empty, gamemode does not tick
	Warmup,			// waiting for players to ready
	Countdown,		// everyone is ready, do a final countdown
	Playing,		// game is live
	EndScreen,		// game has ended, countdown and reset back to warmup
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

	// ammo stats
	STAT_AMMO_NONE,			// or STAT_AMMO_FIRST
	STAT_AMMO_SHELLS,   	// EV_INTEGER
	STAT_AMMO_NAILS, 	  	// EV_INTEGER
	STAT_AMMO_ROCKETS,   	// EV_INTEGER
	STAT_AMMO_CELLS,		// EV_INTEGER
	STAT_AMMO_BOLTS, 	  	// EV_INTEGER
	STAT_AMMO_GRENADES,		// EV_INTEGER
	STAT_AMMO_LAST,

	// global stats
	STAT_AUTOJUMP = 128,    // EV_FLOAT
};

#define STAT_AMMO_FIRST STAT_AMMO_NONE

enum
{
	WEAPON_NONE = 0,

	WEAPON_MELEE,
	WEAPON_NAILGUN,
	WEAPON_SHOTGUN,
	WEAPON_4,
	WEAPON_GRENADE,
	WEAPON_ROCKET,
	WEAPON_LIGHTNING,
	WEAPON_STAKE,
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
	else if (weapon == WEAPON_STAKE)
		return STAT_AMMO_BOLTS;
	else if (weapon == WEAPON_GRENADE)
		return STAT_AMMO_GRENADES;
	return STAT_AMMO_NONE;
}

int WEAPON_AMMO_INDEX(int weapon)
{
	return WEAPON_AMMO_STAT(weapon) - STAT_AMMO_NONE;
}

int AMMO_MAX(int ammo_stat)
{
	if (ammo_stat == STAT_AMMO_NAILS)
		return NAILGUN_MAX_AMMO;
	else if (ammo_stat == STAT_AMMO_ROCKETS)
		return ROCKET_MAX_AMMO;
	else if (ammo_stat == STAT_AMMO_CELLS)
		return LIGHTNING_MAX_AMMO;
	else if (ammo_stat == STAT_AMMO_BOLTS)
		return STAKE_MAX_AMMO;
	else if (ammo_stat == STAT_AMMO_GRENADES)
		return GRENADE_MAX_AMMO;
	return 9999;
}

#define WEAPON_BIT(x) (1 << x)
#define STAT_WEAPON(x) (STAT_AMMO_FIRST + x)
const int ALL_WEAPONS = WEAPON_BIT(WEAPON_NAILGUN) | WEAPON_BIT(WEAPON_GRENADE) | WEAPON_BIT(WEAPON_ROCKET) | WEAPON_BIT(WEAPON_LIGHTNING) | WEAPON_BIT(WEAPON_STAKE);
#define AMMO_INFINITE (-1)

#define COLOR(r, g, b) [r/255, g/255, b/255]

enum : string
{
	CLASS_NONE = "",
	CLASS_PLAYER = "player",
	CLASS_PLAYER_SPECTATOR = "player_spectator",
	CLASS_PLAYER_DISCONNECTED = "player_disconnected",
	CLASS_NAIL = "nail",
	CLASS_ROCKET = "rocket",
	CLASS_GRENADE = "grenade",
	CLASS_LIGHTNING = "lightning",
	CLASS_ARROW = "arrow",
};

enum : string
{
	CLASSTYPE_NONE = "",
	CLASSTYPE_PROJECTILE = "projectile",
	CLASSTYPE_PROJECTILE_SERVER = "projectile_server",
	CLASSTYPE_ITEM = "item",
};

// FIXME
int WeaponRocket_Fire(vector forward);
int WeaponLightning_Fire(vector forward);
int WeaponStake_Fire(vector forward);
int WeaponGrenade_Fire(vector forward);
int WeaponNailgun_Fire(vector forward);

// all entities
.string classtype; // like classname but broader

// globals for global stats
float sv_autojump;
float maxfps;

// player
.float health;
.float health_max;			// maximum allowed health
.float health_softcap;		// softcap for regular health pickups
.float health_time;			// last time when health ticked down
.float damage_time;			// last time when health ticked down by damaging effects
.int health_mega_left;	// how much picked up mega is left before it starts respawning
.entity health_mega_ent;	// last picked up mega
.float armortype;
.float armorvalue;
//.float armorvalue_max;
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
.bool is_attacking;
.float landed_time;
.float race_start_time;
.bool race_started;
vector input_subframe_angles;
.int voted;

// items
.entity last_touched; // last entity who touched the item
.string pickup_sound;
.bool() touch2;
.int count;			  // negative values are used by weapons dropped by player, bypassing the minimum pickup count
.int ammo_stat;
.float pickup_time;   // absolute time, after the item can be picked up
.float respawn_time;  // relative time, negative value is despawn time, which removes the item permanently

// item_armor*
#define armorvalue_min armorvalue
.float armorvalue_max;

// trigger_*
.int dmg;
.float pushforce; // .float speed

// gamemode
float gamemode_timeroffset;
GameModeState gamemode_state = GameModeState::Inactive;

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
#define SENDFLAGS_PLAYER_RELOAD	0x0200

// item specific SendFlags
#define SENDFLAGS_ITEM_INIT		0x0100
#define SENDFLAGS_ITEM_ACTIVE	0x0200
