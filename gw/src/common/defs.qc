#ifdef CSQC
float svtime;
#endif
#ifdef SSQC
#define svtime time
#endif

enum
{
	// player stats
	STAT_HEALTH,            // EV_FLOAT
	STAT_ARMOR,             // EV_FLOAT
	STAT_CURRENT_WEAPON,	// EV_FLOAT
	STAT_WEAPONS,           // EV_INTEGER
	STAT_ITEMS,             // EV_INTEGER
	STAT_EFFECTS,           // EV_INTEGER
	STAT_RELOAD_TIME,       // EV_FLOAT

	// ammo stats
	STAT_AMMO_FIRST = 64,   // EV_INTEGER, used with STAT_WEAPON(weapon)

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

#define WEAPON_BIT(x) (1 << x)
#define STAT_WEAPON(x) (STAT_AMMO_FIRST + x)
#define ALL_WEAPONS (-1)

int WeaponRocketFire();

// globals for global stats
float sv_autojump;

// player
.float reload_time;
.float weapon;
.float weapon_next;
.int weapons;
.int ammo[WEAPON_LAST-1];
