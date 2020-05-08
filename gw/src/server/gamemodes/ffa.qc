int FFA_GetTimeLimit()
{
	return 10*60;
}

#define GameMode_FFA { "ffa", "Free For All", BaseMode_Init, BaseMode_Tick, BaseMode_GetMinimumPlayers, 0, FFA_GetTimeLimit, BaseMode_OnStart, BaseMode_OnEnd, BaseMode_OnClientConnect, BaseMode_OnClientDisconnect, BaseMode_OnClientKill, 0, 0, BaseMode_OnPlayerRequestRespawn, BaseMode_OnPlayerSpawn, BaseMode_OnPlayerInit, BaseMode_OnPlayerTakeDamage, BaseMode_OnPlayerApplyForce, BaseMode_OnPlayerDeath }