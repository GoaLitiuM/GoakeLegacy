// all the QuakeC entry functions should be placed here

void() main = {};

void() worldspawn =
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

void ClientKill() = {};

void ClientConnect(float csqcactive) = {};

void ClientDisconnect() = {};

// client wants to (re)spawn
void PutClientInServer()
{
	PlayerSpawn();
};

void StartFrame() { }

void SV_RunClientCommand()
{
	PlayerCustomPhysics(self);
}
