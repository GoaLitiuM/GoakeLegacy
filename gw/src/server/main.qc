// all the QuakeC entry functions should be placed here

void init(float prevprogs)
{
	LagCompensate_Snapshot(); // pre-allocates data
}

void worldspawn()
{
	precache();

	RegisterStats();
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
	PlayerSpawn();
};

void ClientConnect(float csqcactive)
{
	LagCompensate_AddPlayer(self);
};

void ClientDisconnect()
{
	LagCompensate_RemovePlayer(self);
	self.SendEntity = 0;
	PlayerRemove();
};

// client wants to (re)spawn
void PutClientInServer()
{
	PlayerSpawn();
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
	PlayerPhysics();
}
