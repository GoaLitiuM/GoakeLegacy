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

	self.classname = CLASS_PLAYER;
	self.health = self.max_health = 100;
	self.takedamage = DAMAGE_AIM;
	self.solid = SOLID_CORPSE;//SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_WALK;
	self.flags = FL_CLIENT;
	self.fixangle = 1;
	self.origin = spawn.origin;
	self.angles = spawn.angles;
	self.view_ofs = VEC_OFFSET_EYES;
	self.velocity = '0 0 0';

	self.weapon = WEAPON_ROCKET;
	self.weapons = ALL_WEAPONS;

	setmodel(self, MDL_PLAYER);
	setsize(self, VEC_HULL_MIN, VEC_HULL_MAX);

	self.SendEntity = PlayerSendEntity;

	PlayerInit();
}

void PlayerPreThink()
{
	PlayerPreTick();
};

void PlayerPostThink()
{
	self.SendFlags = FULLSEND; // TODO: use bitmask for different types of update packets

	PlayerPostTick();
};
