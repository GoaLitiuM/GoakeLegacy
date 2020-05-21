struct GameMode
{
	string name;
	string fullname;

	// called when gamemode is first initialized
	void() init;

	// called every tick
	void() tick;

	// returns minimum number of players required for playing this gamemode, return 0 to skip warmup
	int() getMinimumPlayers;

	// returns frag limit for the game mode, can be overridden by cvar
	int() getFragLimit;

	// returns time limit for the game mode, can be overridden by cvar
	int() getTimeLimit;

	// called when gamemode is about start after all players were ready
	void() onStart;

	// called when win conditions were met (fraglimit, timelimit...)
	void() onEnd;

	// called when new player connects to the server
	void(entity player) onClientConnect;

	// called when new player disconnects from the server
	void(entity player) onClientDisconnect;

	// called when player uses 'kill' command
	void(entity player) onClientKill;

	// called when player joins the game, return if player is allowed to join
	bool(entity player) onJoin;

	// called when player starts spectating
	void(entity player) onSpectate;

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

GameMode* gamemode;			// currently active gamemode
GameMode* gamemode_warmup;	// mode during warmup period
GameMode* gamemode_pending;	// the real gamemode which will be activated after warmup
string last_gamemode; 		// for latching the cvar
float gamemode_time;
float gamemode_transition_time;
int gamemode_players;		// number of connected players

const float gamemode_warmup_transition = 5;
const float gamemode_endscreen_transition = 10;

// usage: GameMode_Register({name, fullname, init, tick, ...});
#define GameMode_Register(X) GameMode_Register_internal((GameMode)X)

void GameMode_Register_internal(GameMode gm);
string GameMode_GetPendingModeName();
string GameMode_GetWarmupModeName();
GameMode* GameMode_FindMode(string mode);
void GameMode_SetState(GameModeState newstate);
void GameMode_OverrideMode(GameMode* new_gamemode);
void GameMode_OnPlayerSpawn(entity player);
int GameMode_GetMinimumPlayers();
void GameMode_ResetTimer();
GameMode* GameMode_GetPendingMode();
void GameMode_OnJoin(entity player);
void GameMode_OnSpectate(entity player);

bool Player_IsPlaying(entity player);

int Game_CountPlayersReady();
int Game_CountPlayers();
int Game_CountClients();
entity Game_GetPlayerWithMostFrags();

void GameMode_Init()
{
	GameMode_ResetTimer();

	if (gamemodes_count == 0)
	{
		// register dummy game mode
		#define GameMode_NULL { "null", "" }
        GameMode_Register(GameMode_NULL);
	}

	gamemode_warmup = GameMode_FindMode(GameMode_GetWarmupModeName());
	if (!gamemode_warmup)
	{
		println("Invalid warmup game mode: ", GameMode_GetWarmupModeName());
		cvar_set("gm_warmupmode", cvar_defstring("gm_warmupmode"));
		gamemode_warmup = GameMode_FindMode(GameMode_GetWarmupModeName());
	}
	gamemode_pending = GameMode_FindMode(GameMode_GetPendingModeName());
	if (!gamemode_pending)
	{
		println("Invalid game mode: ", GameMode_GetPendingModeName());
		cvar_set("gm_mode", cvar_defstring("gm_mode"));
		gamemode_pending = GameMode_FindMode(GameMode_GetPendingModeName());
	}

	GameMode_OverrideMode(gamemode_pending);
	GameMode_SetState(GameModeState::Inactive);
}

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

GameMode* GameMode_FindMode(string mode)
{
	for (int i=0; i<gamemodes_count; i++)
	{
		if (gamemodes[i].name == mode)
			return &gamemodes[i];
	}
	return 0;
}

void GameMode_BroadcastGameMode(entity target)
{
	float msg_type = MULTICAST_ALL_R;
	if (target != world)
	{
		msg_entity = target;
		msg_type = MULTICAST_ONE_R_NOSPECS;
	}
	else if (gamemode_players <= 0)
		return;

	GameMode* current_mode = GameMode_GetPendingMode();
	writeEvent(MSG_MULTICAST, EVENT_GAMEMODE_CHANGED);
	writeString(MSG_MULTICAST, current_mode->name);
	writeString(MSG_MULTICAST, current_mode->fullname);
	writeByte(MSG_MULTICAST, GameMode_GetMinimumPlayers());
	multicast('0 0 0', msg_type);
}

void GameMode_BroadcastGameState(entity target)
{
	float msg_type = MULTICAST_ALL_R;
	if (target != world)
	{
		msg_entity = target;
		msg_type = MULTICAST_ONE_R_NOSPECS;
	}
	else if (gamemode_players <= 0)
		return;

	writeEvent(MSG_MULTICAST, EVENT_GAMEMODE_STATE);
	writeByte(MSG_MULTICAST, (int)(__variant)gamemode_state);
	multicast('0 0 0', msg_type);
}

void GameMode_BroadcastGameTime(entity target)
{
	float msg_type = MULTICAST_ALL_R;
	if (target != world)
	{
		msg_entity = target;
		msg_type = MULTICAST_ONE_R_NOSPECS;
	}
	else if (gamemode_players <= 0)
		return;

	writeEvent(MSG_MULTICAST, EVENT_GAMEMODE_TIMER);
	writeFloat(MSG_MULTICAST, gamemode_timeroffset);
	multicast('0 0 0', msg_type);
}

int GameMode_GetFragLimit()
{
	int fraglimit = (int)cvar("gm_fraglimit");
	if (!fraglimit && gamemode->getFragLimit)
		fraglimit = gamemode->getFragLimit();
	if (fraglimit < 0)
		fraglimit = 0;
	return fraglimit;
}

void GameMode_SetFragLimit(int fraglimit)
{
	cvar_setf("gm_fraglimit", itof(fraglimit));
}

int GameMode_GetTimeLimit()
{
	int timelimit = (int)cvar("gm_timelimit");
	if (!timelimit && gamemode->getTimeLimit)
		timelimit = gamemode->getTimeLimit();
	if (timelimit < 0)
		timelimit = 0;
	return timelimit;
}

void GameMode_SetTimeLimit(int timelimit)
{
	cvar_setf("gm_timelimit", itof(timelimit));
}

string GameMode_GetWarmupModeName()
{
	return strtolower(cvar_string("gm_warmupmode"));
}

string GameMode_GetPendingModeName()
{
	return strtolower(cvar_string("gm_mode"));
}

string GameMode_GetCurrentModeName()
{
	return gamemode->name;
}

GameMode* GameMode_GetPendingMode()
{
	if (gamemode_state == GameModeState::Warmup || gamemode_state == GameModeState::Countdown)
		return gamemode_pending;
	else
		return gamemode;
}

void GameMode_SetMode(GameMode* new_gamemode)
{
	GameMode* old_gamemode = GameMode_GetPendingMode();
	GameMode_OverrideMode(new_gamemode);
	gamemode_pending = gamemode;

	if (gamemode)
	{
		cvar_set("gm_mode", strtolower(gamemode->name));
		last_gamemode = strtolower(gamemode->name);
	}

	GameMode_BroadcastGameMode(world);

	if (GameMode_GetMinimumPlayers() == 0)
		GameMode_SetState(GameModeState::Playing);
	else
		GameMode_SetState(GameModeState::Warmup);
}

void GameMode_SetNextMode(GameMode* new_gamemode)
{
	GameMode* old_gamemode = gamemode_pending;
	gamemode_pending = new_gamemode;

	if (GameMode_GetMinimumPlayers() == 0 && gamemode_state != GameModeState::Playing)
		GameMode_SetMode(gamemode_pending);
	else
		GameMode_BroadcastGameMode(world);
}

void GameMode_OnInit()
{
	GameMode_ResetTimer();

	if (gamemode->init)
		gamemode->init();
}

int GameMode_GetMinimumPlayers()
{
	int minimum_players = 2;
	GameMode* mode = GameMode_GetPendingMode();
	if (mode->getMinimumPlayers)
		minimum_players = mode->getMinimumPlayers();

	if (minimum_players < 0)
		return 0;
	return minimum_players;
}

void GameMode_OnStart()
{
	if (gamemode->onStart)
		gamemode->onStart();
}

void GameMode_OnEnd()
{
	if (gamemode->onEnd)
		gamemode->onEnd();

	GameMode_OverrideMode(gamemode_warmup);
}

void GameMode_ResetTimer()
{
	gamemode_timeroffset = time;
	gamemode_time = 0;

	GameMode_BroadcastGameTime(world);
}

void GameMode_OverrideMode(GameMode* new_gamemode)
{
	gamemode = new_gamemode;
	GameMode_OnInit();
}

void GameMode_ForceRespawnPlayers()
{
	entity player = world;
	while (true)
	{
		player = find(player, classname, CLASS_PLAYER);
		if (player == world)
			break;

		if (!Player_IsPlaying(player))
			continue;

		GameMode_OnPlayerSpawn(player);
	}
}

void GameMode_SetState(GameModeState newstate)
{
	GameModeState oldstate = gamemode_state;
	gamemode_state = newstate;
	switch (newstate)
	{
		case GameModeState::Inactive:
		{
			if (gamemode_players)
			{
				GameMode_SetState(GameModeState::Warmup);
				return;
			}
			break;
		}
		case GameModeState::Warmup:
		{
			if (oldstate != GameModeState::Countdown)
				GameMode_ForceRespawnPlayers();

			GameMode_OverrideMode(gamemode_warmup);
			break;
		}
		case GameModeState::Countdown:
		{
			GameMode_ResetTimer();
			gamemode_transition_time = time + gamemode_warmup_transition;
			break;
		}
		case GameModeState::Playing:
		{
			GameMode_OverrideMode(gamemode_pending);
			GameMode_OnStart();
			break;
		}
		case GameModeState::EndScreen:
		{
			gamemode_transition_time = time + gamemode_endscreen_transition;
			GameMode_OnEnd();
			break;
		}
	}

	if (gamemode_state != oldstate)
		GameMode_BroadcastGameState(world);
}

void GameMode_Finish(entity player_winner)
{
	GameMode_SetState(GameModeState::EndScreen);
}

void GameMode_OnClientConnect(entity player)
{
	gamemode_players = Game_CountClients();

	if (gamemode_state == GameModeState::Inactive)
		GameMode_SetState(GameModeState::Warmup);

	if (gamemode->onClientConnect)
		gamemode->onClientConnect(player);

	GameMode_OnJoin(player);

	forceinfokey(player, "ready", "0");

	GameMode_BroadcastGameTime(player);
	GameMode_BroadcastGameState(player);
	GameMode_BroadcastGameMode(player);
}

void GameMode_OnClientDisconnect(entity player)
{
	if (gamemode->onClientDisconnect)
		gamemode->onClientDisconnect(player);

	gamemode_players = Game_CountClients();

	// HACK: player entities are not completely removed from the server,
	// separate disconnected players from other players.
	self.classname = CLASS_PLAYER_DISCONNECTED;
}

void GameMode_OnClientKill(entity player)
{
	if (gamemode->onClientKill)
		gamemode->onClientKill(player);
}

void GameMode_OnSpectatorConnect(entity player)
{
	gamemode_players = Game_CountClients();
	GameMode_OnSpectate(player);
}

void GameMode_OnSpectatorDisconnect(entity player)
{
	gamemode_players = Game_CountClients();
}

void GameMode_OnJoin(entity player)
{
	bool joined = true;
	if (gamemode->onJoin)
		joined = gamemode->onJoin(player);

	if (!joined)
	{
		//TODO: prevent player from joining, assign to spectator instead
	}
}

void GameMode_OnSpectate(entity player)
{
	self.classname = CLASS_PLAYER_SPECTATOR;
	self.movetype = MOVETYPE_NOCLIP;
	self.SendFlags |= SENDFLAGS_ALL;
	self.dimension_seen = 0; // this player is not networked

	if (gamemode->onSpectate)
		gamemode->onSpectate(player);
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

	if (gamemode_state == GameModeState::Playing)
	{
		int fraglimit = GameMode_GetFragLimit();
		if (fraglimit > 0)
		{
			entity killer = world;
			if (source.classname == CLASS_PLAYER)
				killer = source;
			else
			{
				if (source.owner.classname == CLASS_PLAYER)
					killer = source.owner;
			}

			if (killer != world)
			{
				int killer_frags = infokeyf(killer, "*frags");
				if (killer_frags >= fraglimit)
				{
					GameMode_Finish(killer);
					return;
				}
			}
		}
	}
}

void GameMode_OnTick()
{
	if (gamemode->tick)
		gamemode->tick();
}

bool GameMode_AllPlayersReady()
{
	int minimum_players = GameMode_GetMinimumPlayers();
	if (minimum_players == 0)
		return true;

	int ready_players = Game_CountPlayersReady();
	int total_players = Game_CountPlayers();
	if (total_players < minimum_players)
		return false;
	if (ready_players < total_players)
		return false;
	return true;
}

void GameMode_ResetReadyPlayers()
{
	entity player = world;
	while (true)
	{
		player = find(player, classname, CLASS_PLAYER);
		if (player == world)
			break;

		if (!Player_IsPlaying(player))
			continue;

		forceinfokey(player, "ready", "0");
	}
}

void GameMode_TickWarmup()
{
	if (GameMode_AllPlayersReady())
		GameMode_SetState(GameModeState::Countdown);
}

void GameMode_TickCountdown()
{
	if (!GameMode_AllPlayersReady())
	{
		GameMode_SetState(GameModeState::Warmup);
		return;
	}

	if (time >= gamemode_transition_time)
		GameMode_SetState(GameModeState::Playing);
}

void GameMode_TickPlaying()
{
	int timelimit = GameMode_GetTimeLimit();
	if (timelimit > 0 && gamemode_time >= timelimit)
	{
		//TODO: overtime
		entity winner = Game_GetPlayerWithMostFrags();
		GameMode_Finish(winner);
		return;
	}
}

void GameMode_TickEndScreen()
{
	if (time >= gamemode_transition_time)
	{
		GameMode_ResetReadyPlayers();
		GameMode_SetState(GameModeState::Warmup);
	}
}

void GameMode_Tick()
{
	string mode = GameMode_GetPendingModeName();
	if (mode != last_gamemode)
	{
		GameMode* new_gamemode = GameMode_FindMode(mode);
		if (new_gamemode)
		{
			if (gamemode_state != GameModeState::Playing)
				GameMode_SetMode(new_gamemode);
			else
			{
				GameMode_SetNextMode(new_gamemode);
				println("Game mode will be changed for next round or map");
			}

			last_gamemode = mode;
		}
		else
		{
			println("Invalid game mode: ", mode);
			cvar_set("gm_mode", last_gamemode);
		}
	}

	gamemode_time = time - gamemode_timeroffset;

	if (gamemode_state == GameModeState::Inactive)
		return;

	GameMode_OnTick();

	switch (gamemode_state)
	{
		case GameModeState::Inactive:
			break; // wait players to connect
		case GameModeState::Playing:
			GameMode_TickPlaying();
			break;
		case GameModeState::Warmup:
			GameMode_TickWarmup();
			break;
		case GameModeState::Countdown:
			GameMode_TickCountdown();
			break;
		case GameModeState::EndScreen:
			GameMode_TickEndScreen();
			break;
	}
}