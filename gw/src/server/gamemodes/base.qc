// base gamemode to provide common codebase for other gamemodes

void BaseMod_Init()
{
}

void BaseMod_OnClientConnect(entity player)
{
	// TODO: restore old stats here in case the player disconnects from the server during the match
	forceinfokey(player, "frags", "0");
	forceinfokey(player, "deaths", "0");
}

void BaseMod_OnClientKill(entity player)
{
	Player_Kill(player);
}

void BaseMod_Tick()
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

bool BaseMod_OnPlayerRequestRespawn(entity player)
{
	return true;
}

void BaseMod_OnPlayerSpawn(entity player)
{
	entity spawn = FindRandomSpawn();
	player.origin = spawn.origin;
	player.angles = spawn.angles;
}

void BaseMod_OnPlayerInit(entity player)
{
	player.health = 100;
	player.armorvalue = 0;
	player.armortype = ARMOR_GREEN_ABSORB;
}

float BaseMod_OnPlayerTakeDamage(entity player, float damage, entity source)
{
	return damage;
}

vector BaseMod_OnPlayerApplyForce(entity player, vector force, entity source)
{
	return force;
}

void BaseMod_OnPlayerDeath(entity player, entity source)
{
	entity source_player = world;
	if (source.classname == CLASS_PLAYER)
		source_player = source;
	else
	{
		if (source.owner.classname == CLASS_PLAYER)
			source_player = source.owner;
	}

	// TODO: turn these into fields
	int deaths = stoi(infokey(player, "deaths"));
	deaths++;
	forceinfokey(player, "deaths", itos(deaths));

	if (source_player != world && source_player != player)
	{
		int source_frags = stoi(infokey(source_player, "frags"));
		source_frags++;
		forceinfokey(source_player, "frags", itos(source_frags));
	}

	writeByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	writeByte(MSG_MULTICAST, EVENT_PLAYER_DEATH);
	WriteEntity(MSG_MULTICAST, player);
	WriteEntity(MSG_MULTICAST, source_player);
	WriteEntity(MSG_MULTICAST, source);
	multicast(self.origin, MULTICAST_ALL_R);
}