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
	STAT_NEXT_WEAPON,		// EV_FLOAT
	STAT_WEAPONS,           // EV_INTEGER
	STAT_ITEMS,             // EV_INTEGER
	STAT_EFFECTS,           // EV_INTEGER
	STAT_RELOAD_TIME,       // EV_FLOAT

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

int WeaponRocketFire();
int WeaponLightningFire();
int WeaponCrossbowFire();

enum
{
	EVENT_LIGHTNING = 1,
};

// globals for global stats
float sv_autojump;

// player
.float reload_time;
.float weapon;
.float weapon_next;
.int weapons;
.int ammo[WEAPON_LAST-1];
.float weapon_sound_loop_time;
