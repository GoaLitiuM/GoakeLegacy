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