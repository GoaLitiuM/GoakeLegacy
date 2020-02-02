void info_player_deathmatch()
{
}
void info_player_start() // for compatibility
{
	self.classname = "info_player_deathmatch";
}

void trigger_teleport()
{
	self.touch = TeleportOnTouch;
	self.solid = SOLID_TRIGGER;
	setmodel (self, self.model);
	self.movetype = MOVETYPE_NONE;
	self.modelindex = 0;
	self.model = "";
}
void info_teleport_destination()
{
}
void misc_teleporter_dest() // Q3 compatibility
{
}
void trigger_multiple()
{
}

void weapon_rocketlauncher()
{
	Item_Init("textures/simple_items/weapon_rocket");
	setsize(self, '-16 -16 -16', '16 16 16');
}