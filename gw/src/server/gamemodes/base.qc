// base gamemode to provide common codebase for other gamemodes

void BaseMode_Init()
{
}

int BaseMode_GetMinimumPlayers()
{
	return 1;
}

void BaseMode_OnClientConnect(entity player)
{
	// TODO: restore old stats here in case the player disconnects from the server during the match
	forceinfokey(player, "*frags", "0");
	forceinfokey(player, "*deaths", "0");
}

void BaseMode_OnClientDisconnect(entity player)
{
}

void BaseMode_OnClientKill(entity player)
{
	Player_Kill(player);
}

void BaseMode_OnStart()
{
	entity player = world;
	while (true)
	{
		player = find(player, classname, CLASS_PLAYER);
		if (player == world)
			break;

		// reset scores
		forceinfokey(player, "*frags", "0");
		forceinfokey(player, "*deaths", "0");

		if (strlen(infokey(player, "name")) == 0)
			continue;
		if (infokeyf(player, "*spectator") != 0)
			continue;

		// reinitialize players
		entity oldself = self;
		self = player;
		Player_Remove();
		Player_Init();
		self = oldself;
	}

	GameMode_ForceRespawnPlayers();

	// respawn all items
	entity item = world;
	while (true)
	{
		item = findfloat(item, itemclass, (bool)true);
		if (item == world)
			break;

		entity oldself = self;
		self = item;
		Item_SetActive(true);
		self = oldself;
	}
}

void BaseMode_OnEnd()
{
}

void BaseMode_Tick()
{
	entity player = world;
	while (1)
	{
		player = find(player, classname, CLASS_PLAYER);
		if (player == world)
			break;

		// revive dead players after a while
		if (Player_IsDead(player) && time - player.death_time > 4.0)
			GameMode_OnPlayerSpawn(player);
	}
}

bool BaseMode_OnPlayerRequestRespawn(entity player)
{
	return true;
}

void BaseMode_OnPlayerSpawn(entity player)
{
	entity spawn = Game_GetRandomSpawn();
	player.origin = spawn.origin;
	player.angles = spawn.angles;

	entity oldself = self;
	self = player;
	Player_Spawn();
	self = oldself;
}

void BaseMode_OnPlayerInit(entity player)
{
	player.health = 100;
	player.armorvalue = 0;
	player.armortype = ARMOR_GREEN_ABSORB;

	player.weapons = WEAPON_BIT(WEAPON_NAILGUN);
	player.weapon = WEAPON_NAILGUN;
	player.ammo[WEAPON_AMMO_INDEX(WEAPON_NAILGUN)] = 50;
}

float BaseMode_OnPlayerTakeDamage(entity player, float damage, entity source)
{
	return damage;
}

vector BaseMode_OnPlayerApplyForce(entity player, vector force, entity source)
{
	return force;
}

void BaseMode_OnPlayerDeath(entity player, entity source)
{
	entity source_player = world;
	if (source.classname == CLASS_PLAYER)
		source_player = source;
	else
	{
		if (source.owner.classname == CLASS_PLAYER)
			source_player = source.owner;
	}

	if (gamemode_state == GameModeState::Playing)
	{
		// TODO: turn these into fields
		int deaths = stoi(infokey(player, "*deaths"));
		deaths++;
		forceinfokey(player, "*deaths", itos(deaths));

		if (source_player != world && source_player != player)
		{
			int source_frags = stoi(infokey(source_player, "*frags"));
			source_frags++;
			forceinfokey(source_player, "*frags", itos(source_frags));
		}
	}

	writeEvent(MSG_MULTICAST, EVENT_PLAYER_DEATH);
	WriteEntity(MSG_MULTICAST, player);
	WriteEntity(MSG_MULTICAST, source_player);
	WriteEntity(MSG_MULTICAST, source);
	multicast(self.origin, MULTICAST_ALL_R);
}