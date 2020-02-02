void Player_WeaponTick();

entity FindRandomSpawn()
{
	entity ent = world;

	int num_spawns = 0;
	string ent_type = ENT_PLAYER_SPAWN;

	while (true)
	{
		ent = find(ent, classname, ent_type);
		if (ent == world)
		{
			if (num_spawns == 0 && ent_type == ENT_PLAYER_SPAWN)
			{
				ent_type = "info_player_start";
				continue;
			}
			break;
		}
		num_spawns++;
	}

	ent_type = ENT_PLAYER_SPAWN;
	int index = 0;
	int spawn = randomInt(1, num_spawns);
	while (index < spawn)
	{
		ent = find(ent, classname, ent_type);
		if (ent == world)
		{
			if (num_spawns == 0 && ent_type == ENT_PLAYER_SPAWN)
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
	writeByte(MSG_ENTITY, SENDENTITY_PLAYER);
	writeFloat(MSG_ENTITY, send_flags);
	if (send_flags & SENDFLAGS_PLAYER_EVENT_FLAGS)
		writeFloat(MSG_ENTITY, self.event_flags);
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

	self.event_flags = 0;
	return 1;
}

