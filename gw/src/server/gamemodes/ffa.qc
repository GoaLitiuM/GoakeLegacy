void FFA_Init()
{
}

void FFA_OnClientConnect(entity player)
{
	// TODO: restore old stats here in case the player disconnects from the server during the match
	forceinfokey(player, "deaths", "0");
}

void FFA_OnClientKill(entity player)
{
	Player_Kill(player);
}

void FFA_Tick()
{
	entity player = world;
	while (1)
	{
		player = find(player, classname, CLASS_PLAYER);
		if (player == world)
			break;

		// revive dead players after a while
		if (player.health <= 0 && time - player.death_time > 4.0)
			GameMode_OnPlayerRequestRespawn(player);
	}
}

bool FFA_OnPlayerRequestRespawn(entity player)
{
	return true;
}

void FFA_OnPlayerSpawn(entity player)
{
	entity spawn = FindRandomSpawn();
	player.origin = spawn.origin;
	player.angles = spawn.angles;

	player.health = 100;
	player.armorvalue = 0;
	player.armortype = ARMOR_GREEN_ABSORB;
}

void FFA_OnPlayerDeath(entity player, entity source)
{
	entity source_player = world;
	if (source.classname == CLASS_PLAYER)
		source_player = source;
	else
	{
		if (source.owner.classname == CLASS_PLAYER)
			source_player = source.owner;
	}

	// TODO: turn this into a field
	int deaths = stoi(infokey(player, "deaths"));
	deaths++;
	forceinfokey(player, "deaths", itos(deaths));

	if (source_player != world && source_player != player)
		source_player.frags++;
}

#define GameMode_FFA { "ffa", "Free For All", FFA_Init, FFA_Tick, FFA_OnClientConnect, FFA_OnClientKill, FFA_OnPlayerRequestRespawn, FFA_OnPlayerSpawn, FFA_OnPlayerDeath }