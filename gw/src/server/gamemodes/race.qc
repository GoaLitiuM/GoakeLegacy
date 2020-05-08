int Race_GetMinimumPlayers()
{
	return 0; // skips warmup
}

void Race_OnPlayerInit(entity player)
{
	player.health = 100;
	player.armorvalue = 0;
	player.armortype = ARMOR_GREEN_ABSORB;

	player.solid = SOLID_CORPSE;

	for (int i=0; i<WEAPON_LAST; i++)
		self.ammo[WEAPON_AMMO_INDEX(i)] = AMMO_INFINITE;
}

void Race_OnClientKill(entity player)
{
	BaseMode_OnClientKill(player);
	GameMode_OnPlayerSpawn(player);
}

float Race_OnPlayerTakeDamage(entity player, float damage, entity source)
{
	return 0;
}

vector Race_OnPlayerApplyForce(entity player, vector force, entity source)
{
	if (source.owner == player)
		return force;
	return [0, 0, 0];
}

void Race_OnPlayerDeath(entity player, entity source)
{
}

#define GameMode_Race { "race", "Race", BaseMode_Init, BaseMode_Tick, Race_GetMinimumPlayers, 0, 0, BaseMode_OnStart, BaseMode_OnEnd, BaseMode_OnClientConnect, 0, Race_OnClientKill, 0, 0, BaseMode_OnPlayerRequestRespawn, BaseMode_OnPlayerSpawn, Race_OnPlayerInit, Race_OnPlayerTakeDamage, Race_OnPlayerApplyForce, Race_OnPlayerDeath }