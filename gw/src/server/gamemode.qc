struct GameMode
{
	string name;
	string fullname;

	void() init;
	void() tick;

	// called when new player connects
	void(entity player) onClientConnect;

	// called when player uses 'kill' command
	void(entity player) onClientKill;

	// called when player wants to respawn, return true if player is allowed to respawn
	bool(entity player) onPlayerRequestRespawn;

	// called when player (re)spawns
	void(entity player) onPlayerSpawn;

	// called when player takes damage, return final damage the player should receive
	float(entity player, float damage, entity source) onPlayerTakeDamage;

	// called when player dies
	void(entity player, entity source) onPlayerDeath;
};

GameMode* gamemodes;
int gamemodes_count;
int gamemodes_allocated_count;

GameMode* gamemode;
string last_gamemode;

// usage: GameMode_Register({name, fullname, init, tick, ...});
#define GameMode_Register(X) GameMode_Register_internal((GameMode)X)

void GameMode_Register_internal(GameMode gm)
{
	if (gamemodes_count == gamemodes_allocated_count)
	{
		int oldsize = gamemodes_allocated_count;
		gamemodes_allocated_count += 8;

		GameMode* newgamemodes = memalloc(sizeof(GameMode) * gamemodes_allocated_count);
		if (oldsize > 0)
		{
			memcpy(newgamemodes, gamemodes, sizeof(GameMode) * oldsize);
			memfree(gamemodes);
		}
		gamemodes = newgamemodes;
	}

	GameMode* slot = gamemodes + gamemodes_count;
	memcpy(slot, &gm, sizeof(GameMode));

	gamemodes_count++;
}

void GameMode_Init()
{
	string mode = strtolower(cvar_string("gm_mode"));

	if (gamemodes_count == 0)
	{
		// register dummy game mode
		#define GameMode_NULL { "null", "" }
		GameMode_Register(GameMode_NULL);
		mode = "";
	}

	gamemode = 0;
	for (int i=0; i<gamemodes_count; i++)
	{
		if (gamemodes[i].name == mode)
		{
			gamemode = &gamemodes[i];
			break;
		}
	}

	if (gamemode)
		println("Current game mode: ", gamemode.fullname);
	else
	{
		println("Failed to change game mode, unknown mode: ", mode);
		gamemode = &gamemodes[0];
	}

	last_gamemode = gamemode->name;
	cvar_set("gm_mode", gamemode->name);

	if (gamemode->init)
		gamemode->init();
}

void GameMode_OnClientConnect(entity player)
{
	if (gamemode->onClientConnect)
		gamemode->onClientConnect(player);
}

void GameMode_OnClientKill(entity player)
{
	if (gamemode->onClientKill)
		gamemode->onClientKill(player);
}

bool GameMode_OnPlayerRequestRespawn(entity player)
{
	bool allow_spawning = false;
	if (gamemode->onPlayerRequestRespawn)
	{
		entity oldself = self;
		self = player;
		allow_spawning = gamemode->onPlayerRequestRespawn(player);
		self = oldself;
	}
	return allow_spawning;
}

void GameMode_OnPlayerSpawn(entity player)
{
	if (gamemode->onPlayerSpawn)
	{
		entity oldself = self;
		self = player;
		gamemode->onPlayerSpawn(player);
		self = oldself;
	}
}

float GameMode_OnPlayerTakeDamage(entity player, float damage, entity source)
{
	if (gamemode->onPlayerDeath)
	{
		entity oldself = self;
		self = player;
		damage = gamemode->onPlayerTakeDamage(player, damage, source);
		self = oldself;
	}

	return damage;
}

void GameMode_OnPlayerDeath(entity player, entity source)
{
	if (gamemode->onPlayerDeath)
	{
		entity oldself = self;
		self = player;
		gamemode->onPlayerDeath(player, source);
		self = oldself;
	}
}

void GameMode_Tick()
{
	string mode = strtolower(cvar_string("gm_mode"));
	if (mode != last_gamemode)
	{
		// gamemode changed
		println("Game mode will be applied after map change");
		last_gamemode = mode;
	}

	if (gamemode->tick)
		gamemode->tick();
}
