void Race_Init()
{
}

void Race_OnClientConnect(entity player)
{
	// TODO: restore old stats here in case the player disconnects from the server during the match
	forceinfokey(player, "deaths", "0");
}

void Race_OnClientKill(entity player)
{
	Player_Kill(player);
	Player_Spawn();
}

void Race_Tick()
{
}

bool Race_OnPlayerRequestRespawn(entity player)
{
	return true;
}

void Race_OnPlayerSpawn(entity player)
{
	entity spawn = FindRandomSpawn();
	player.origin = spawn.origin;
	player.angles = spawn.angles;

	player.health = 100;
}

void Race_OnPlayerTakeDamage(entity player, entity source, float damage)
{
}

void Race_OnPlayerDeath(entity player, entity source)
{
}

#define GameMode_Race { "race", "Race", Race_Init, Race_Tick, Race_OnClientConnect, Race_OnClientKill, Race_OnPlayerRequestRespawn, Race_OnPlayerSpawn, Race_OnPlayerDeath }