// all the QuakeC entry functions should be placed here

void init(float prevprogs)
{
	LagCompensate_Snapshot(); // pre-allocates data

	Common_Init();

	GameMode_Register(GameMode_FFA);
	GameMode_Register(GameMode_Race);
	GameMode_SetMode(strtolower(cvar_string("gm_mode")));
}

void worldspawn()
{
	precache();
}

void() SetNewParms = {};

void() SetChangeParms = {};

// called for every entity before they are placed to the world
void CheckSpawn(void() func)
{
	if (func)
		func();
}

void ClientKill()
{
	GameMode_OnClientKill(self);
}

void ClientConnect(float csqcactive)
{
	self.SendEntity = Player_SendEntity;
	LagCompensate_AddPlayer(self);
	GameMode_OnClientConnect(self);
}

void ClientDisconnect()
{
	GameMode_OnClientDisconnect(self);
	self.SendEntity = 0;
	LagCompensate_RemovePlayer(self);
	Player_Remove();
}

// client wants to (re)spawn
void PutClientInServer()
{
	GameMode_OnPlayerSpawn(self);
}

void StartFrame()
{
	GameMode_Tick();
	UpdateGlobalStats();
}

float phys_timer;
void EndFrame()
{
	float ticktime = 1.0f/maxfps;

	// HACK: workaround for listenserver ticking for each rendered frame
	phys_timer += frametime;
	if (phys_timer >= ticktime)
	{
		phys_timer -= ticktime;
		LagCompensate_Snapshot();
	}

	Vote_Tick();
}

void SV_RunClientCommand()
{
	Player_Physics();
}

void PlayerPreThink()
{
    input_buttons = 0;
    input_buttons |= self.button0 * BUTTON_ATTACK;
    input_buttons |= self.button1 * BUTTON_USE;
    input_buttons |= self.button2 * BUTTON_JUMP;

	Player_PreTick();
}

void PlayerPostThink()
{
	Player_PostTick();
}