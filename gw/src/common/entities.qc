int ENT_PLAYER_SPAWN_COUNT;
void info_player_deathmatch()
{
    ENT_PLAYER_SPAWN_COUNT++;
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
void trigger_multiple()
{
}
