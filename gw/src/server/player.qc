void Player_WeaponTick();

entity FindRandomSpawn()
{
	entity ent = world;
	int index = 0;
	int spawn = 1;
	string ent_type = ENT_PLAYER_SPAWN;

	while (index < spawn)
	{
		ent = find(ent, classname, ent_type);
		if (ent == world)
		{
			if (ent_type == ENT_PLAYER_SPAWN)
			{
				ent_type = "info_player_start";
				continue;
			}
			break;
		}

		index++;
	}

	if (ent == world)
		println("no spawn found for player.");

	return ent;
}

float Player_SendEntity(entity ent, float send_flags)
{
	writeByte(MSG_ENTITY, 1);
	writeFloat(MSG_ENTITY, send_flags);
	if (send_flags & SENDFLAGS_ORIGIN)
		writeVector(MSG_ENTITY, self.origin);
	if (send_flags & SENDFLAGS_ANGLES)
		writeVector(MSG_ENTITY, self.angles);
	if (send_flags & SENDFLAGS_VELOCITY)
		writeVector(MSG_ENTITY, self.velocity);
	if (send_flags & SENDFLAGS_FLAGS)
	{
		writeFloat(MSG_ENTITY, self.flags);
		writeFloat(MSG_ENTITY, self.pmove_flags);
	}
	if (send_flags & SENDFLAGS_JUMP)
	{
		writeFloat(MSG_ENTITY, self.jump_time);
		writeFloat(MSG_ENTITY, self.jump_count);
	}
	return 1;
}

void Player_Spawn()
{
	local entity spawn = FindRandomSpawn();

	self.health = self.max_health = 100;
	self.takedamage = DAMAGE_AIM;
	self.fixangle = 1;
	self.origin = spawn.origin;
	self.angles = spawn.angles;
	self.flags = FL_CLIENT;
	self.velocity = '0 0 0';
	self.SendEntity = Player_SendEntity;

	self.weapon = WEAPON_ROCKET;
	self.weapons = ALL_WEAPONS;

	Player_Init();
}
