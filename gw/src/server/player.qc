void PlayerWeaponTick();

entity FindRandomSpawn()
{
	local string type = ENT_PLAYER_SPAWN;

	local entity ent = world;
	for (int i = randomInt(1, ENT_PLAYER_SPAWN_COUNT); i > 0; i--)
	{
		ent = find(ent, classname, type);
		if (ent == world)
		{
			println("no spawn found for player.");
			break;
		}
	}
	return ent;
}

float PlayerSendEntity(entity ent, float send_flags)
{
	writeByte(MSG_ENTITY, 1);
	writeVector(MSG_ENTITY, self.origin);
	writeVector(MSG_ENTITY, self.angles);
	writeVector(MSG_ENTITY, self.velocity);
	writeFloat(MSG_ENTITY, self.flags);
	writeFloat(MSG_ENTITY, self.pmove_flags);
	writeFloat(MSG_ENTITY, self.jump_time);
	writeFloat(MSG_ENTITY, self.jump_count);
	return 1;
}

void PlayerSpawn()
{
	local entity spawn = FindRandomSpawn();

	self.health = self.max_health = 100;
	self.takedamage = DAMAGE_AIM;
	self.fixangle = 1;
	self.origin = spawn.origin;
	self.angles = spawn.angles;
	self.flags = FL_CLIENT;
	self.velocity = '0 0 0';
	self.SendEntity = PlayerSendEntity;

	self.weapon = WEAPON_ROCKET;
	self.weapons = ALL_WEAPONS;

	PlayerInit();
}

void PlayerPreThink()
{
    input_buttons = 0;
    input_buttons |= self.button0 * BUTTON_ATTACK;
    input_buttons |= self.button1 * BUTTON_USE;
    input_buttons |= self.button2 * BUTTON_JUMP;

	PlayerPreTick();
};

void PlayerPostThink()
{
	self.SendFlags = FULLSEND; // TODO: use bitmask for different types of update packets

	PlayerPostTick();
};
