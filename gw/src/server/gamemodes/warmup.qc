void Warmup_OnPlayerInit(entity player)
{
	player.health = 100;
	player.armorvalue = 150;
	player.armortype = ARMOR_YELLOW_ABSORB;

	self.weapons = ALL_WEAPONS;
	for (int i=0; i<WEAPON_LAST; i++)
		self.ammo[WEAPON_AMMO_INDEX(i)] = AMMO_INFINITE;
}

float Warmup_OnPlayerTakeDamage(entity player, float damage, entity source)
{
	if (source == player || source.owner == player)
		return 0;
	return damage;
}

#define GameMode_Warmup { "warmup", "Warmup", BaseMode_Init, BaseMode_Tick, BaseMode_GetMinimumPlayers, 0, 0, BaseMode_OnStart, BaseMode_OnEnd, BaseMode_OnClientConnect, 0, BaseMode_OnClientKill, BaseMode_OnPlayerRequestRespawn, BaseMode_OnPlayerSpawn, Warmup_OnPlayerInit, Warmup_OnPlayerTakeDamage, BaseMode_OnPlayerApplyForce, BaseMode_OnPlayerDeath }