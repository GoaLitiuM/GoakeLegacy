// all the QuakeC entry functions should be placed here

void init(float prevprogs)
{
	LagCompensate_Snapshot(); // pre-allocates data

	Common_Init();
}

void worldspawn()
{
	precache();
};

void() SetNewParms = {};

void() SetChangeParms = {};

// called for every entity before they are placed to the world
void CheckSpawn(void() func)
{
	if (func)
		func();
};

void ClientKill()
{
	// just respawn the client for now
	Player_Spawn();
};

void ClientConnect(float csqcactive)
{
	LagCompensate_AddPlayer(self);
};

void ClientDisconnect()
{
	LagCompensate_RemovePlayer(self);
	self.SendEntity = 0;
	Player_Remove();
};

// client wants to (re)spawn
void PutClientInServer()
{
	Player_Spawn();
};

void StartFrame()
{
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