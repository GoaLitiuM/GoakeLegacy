struct GameMode
{
	string name;
	string fullname;

	void() init;
	void() tick;

	// called when new player connects
	void(entity player) onClientConnect;

	// called when new player disconnects
	void(entity player) onClientDisconnect;

	// called when player uses 'kill' command
	void(entity player) onClientKill;

	// called when player wants to respawn, return true if player is allowed to respawn
	bool(entity player) onPlayerRequestRespawn;

	// called when player needs to be spawned on world
	void(entity player) onPlayerSpawn;

	// called when player needs to be initialized, usually right after spawning
	void(entity player) onPlayerInit;

	// called when player takes damage, return final damage the player should receive
	float(entity player, float damage, entity source) onPlayerTakeDamage;

	// called when player is pushed by a force, return final force the player should receive
	vector(entity player, vector force, entity source) onPlayerApplyForce;

	// called when player dies
	void(entity player, entity source) onPlayerDeath;
};

GameMode* gamemodes;
int gamemodes_count;
int gamemodes_allocated_count;

GameMode* gamemode;
string last_gamemode;

float gamemode_timeroffset;
bool gamemode_initialized;
int gamemode_players;

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

void GameMode_SetMode(string mode)
{
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
}

void GameMode_SetFragLimit(int fraglimit)
{
	cvar_setf("gm_fraglimit", itof(fraglimit));
}

void GameMode_SetTimeLimit(int timelimit)
{
	cvar_setf("gm_timelimit", itof(timelimit));
}

string GameMode_GetMode()
{
	return cvar_string("gm_mode");
}

int GameMode_GetFragLimit()
{
	return (int)cvar("gm_fraglimit");
}

int GameMode_GetTimeLimit()
{
	return (int)cvar("gm_timelimit");
}

void GameMode_Init()
{
	gamemode_timeroffset = time;
	if (gamemode->init)
		gamemode->init();

	if (gamemode_initialized)
	{
		// reinitialize players
		entity player = world;
		while (true)
		{
			player = find(player, classname, CLASS_PLAYER);
			if (player == world)
				break;

			entity oldself = self;
			self = player;
			Player_Init();
			self = oldself;
		}

		// reset timer
		writeByte(MSG_ALL, SVC_CGAMEPACKET);
		writeByte(MSG_ALL, EVENT_GAMEMODE_TIMER);
		writeFloat(MSG_ALL, gamemode_timeroffset);
	}

	gamemode_initialized = true;
}

void GameMode_OnClientConnect(entity player)
{
	if (gamemode->onClientConnect)
		gamemode->onClientConnect(player);

	gamemode_players++;

	if (!gamemode_initialized)
		GameMode_Init();

	msg_entity = player;
	writeByte(MSG_ONE, SVC_CGAMEPACKET);
	writeByte(MSG_ONE, EVENT_GAMEMODE_TIMER);
	writeFloat(MSG_ONE, gamemode_timeroffset);
}

void GameMode_OnClientDisconnect(entity player)
{
	if (gamemode->onClientDisconnect)
		gamemode->onClientDisconnect(player);

	gamemode_players--;
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

void GameMode_OnPlayerInit(entity player)
{
	if (gamemode->onPlayerInit)
	{
		entity oldself = self;
		self = player;
		gamemode->onPlayerInit(player);
		self = oldself;
	}
}

float GameMode_OnPlayerTakeDamage(entity player, float damage, entity source)
{
	if (gamemode->onPlayerTakeDamage)
	{
		entity oldself = self;
		self = player;
		damage = gamemode->onPlayerTakeDamage(player, damage, source);
		self = oldself;
	}

	return damage;
}

vector GameMode_OnPlayerApplyForce(entity player, vector force, entity source)
{
	if (gamemode->onPlayerApplyForce)
	{
		entity oldself = self;
		self = player;
		force = gamemode->onPlayerApplyForce(player, force, source);
		self = oldself;
	}

	return force;
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
	if (mode != last_gamemode) // gamemode changed
	{
		GameMode_SetMode(mode);
		if (gamemode_initialized)
			GameMode_Init();
	}

	if (!gamemode_initialized)
		return;

	if (gamemode->tick)
		gamemode->tick();
}
