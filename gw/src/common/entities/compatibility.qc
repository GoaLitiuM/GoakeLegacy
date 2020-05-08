#define REMAP_TO_ENTITY(X) do { self.classname = #X; X(); } while(0)

void info_player_deathmatch()
{
	REMAP_TO_ENTITY(info_player_start);
}

void misc_teleporter_dest() // Q3
{
	REMAP_TO_ENTITY(info_teleport_destination);
}

// remap Q1 items
void item_armor1()
{
	REMAP_TO_ENTITY(item_armor_green);
}

void item_armor2()
{
	REMAP_TO_ENTITY(item_armor_yellow);
}

void item_armorInv()
{
	REMAP_TO_ENTITY(item_armor_red);
}

#ifdef CSQC
static .float spawnflags; // QW
#endif

void item_health()
{
	if (self.spawnflags & 2) // 100hp
		REMAP_TO_ENTITY(item_health_mega);
	else if (self.spawnflags & 1) // 10hp, but close enough
		REMAP_TO_ENTITY(item_health_5);
	else
		REMAP_TO_ENTITY(item_health_25); // also Q3
}

void item_health_small() // Q3
{
	REMAP_TO_ENTITY(item_health_5);
}

void item_health_large() // Q3
{
	REMAP_TO_ENTITY(item_health_50);
}
void item_rockets()
{
	REMAP_TO_ENTITY(item_ammo_rockets);
}

void item_cells()
{
	REMAP_TO_ENTITY(item_ammo_lightning);
}

// remap Q3 items

void item_armor_body()
{
	REMAP_TO_ENTITY(item_armor_red);
}

void item_armor_combat()
{
	REMAP_TO_ENTITY(item_armor_yellow);
}

void item_armor_jacket()
{
	REMAP_TO_ENTITY(item_armor_green);
}

void ammo_slugs() // railgun ammo
{
	REMAP_TO_ENTITY(item_ammo_stakes);
}

// ammo_cells = nails

void ammo_lightning()
{
	REMAP_TO_ENTITY(item_ammo_lightning);
}

void ammo_rockets()
{
	REMAP_TO_ENTITY(item_ammo_rockets);
}

void weapon_railgun()
{
	REMAP_TO_ENTITY(weapon_crossbow);
}