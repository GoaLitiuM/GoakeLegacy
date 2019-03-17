// all the QuakeC entry functions should be placed here

void() main = {};

void() worldspawn =
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

void ClientConnect(float csqcactive) = {};

void ClientDisconnect()
{
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

void SV_RunClientCommand()
{
	PlayerCustomPhysics(self);
}
