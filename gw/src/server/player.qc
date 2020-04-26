void Player_WeaponTick();

entity FindRandomSpawn()
{
	entity ent = world;

	int num_spawns = 0;
	while (true)
	{
		ent = find(ent, classname, "info_player_start");
		if (ent == world)
			break;
		num_spawns++;
	}

	if (num_spawns == 0)
	{
		println("Map does not have any spawn entities.");
		return world;
	}

	ent = world;
	int spawn = randomInt(1, num_spawns);
	while (spawn > 0)
	{
		ent = find(ent, classname, "info_player_start");
		if (ent == world)
			break;
		spawn--;
	}

	if (ent == world)
		println("No spawn found for player.");

	return ent;
}

float Player_SendEntity(entity ent, float send_flags)
{
	writeByte(MSG_ENTITY, SENDENTITY_PLAYER);
	writeInt(MSG_ENTITY, send_flags);
	if (send_flags & SENDFLAGS_ORIGIN)
		writeVector(MSG_ENTITY, self.origin);
	if (send_flags & SENDFLAGS_ANGLES)
		writeVector(MSG_ENTITY, self.angles);
	if (send_flags & SENDFLAGS_VELOCITY)
		writeVector(MSG_ENTITY, self.velocity);
	if (send_flags & SENDFLAGS_FLAGS)
	{
		writeInt(MSG_ENTITY, self.flags);
		writeByte(MSG_ENTITY, self.pmove_flags);
	}
	if (send_flags & SENDFLAGS_JUMP)
	{
		writeFloat(MSG_ENTITY, self.jump_time);
		writeFloat(MSG_ENTITY, self.jump_count);
	}

	return 1;
}

