void Race_OnClientKill(entity player)
{
	BaseMod_OnClientKill(player);
	Player_Spawn();
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

#define GameMode_Race { "race", "Race", BaseMod_Init, BaseMod_Tick, BaseMod_OnClientConnect, 0, Race_OnClientKill, BaseMod_OnPlayerRequestRespawn, BaseMod_OnPlayerSpawn, BaseMod_OnPlayerInit, Race_OnPlayerTakeDamage, Race_OnPlayerApplyForce, Race_OnPlayerDeath }