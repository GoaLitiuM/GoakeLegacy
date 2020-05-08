void precache_sounds()
{
	precache_sound(SND_JUMPLAND);

	precache_sound(SND_WEAPON_NAILGUN);
	precache_sound(SND_WEAPON_ROCKET);
	precache_sound(SND_WEAPON_LIGHTNING);
	precache_sound(SND_WEAPON_CROSSBOW);

	precache_sound(SND_ITEM_RESPAWN);
	precache_sound(SND_ARMOR_PICKUP);
	precache_sound(SND_AMMO_PICKUP);
	precache_sound(SND_HEALTH_PICKUP);
	precache_sound(SND_WEAPON_PICKUP);
	precache_sound(SND_MEGA_EXPIRE);
};

void precache_models()
{
	precache_model(SPR_EXPLOSION);
	precache_model(MDL_NAIL);
	precache_model(MDL_ROCKET);
	precache_model(MDL_BEAM);
	precache_model(MDL_ARROW);

	precache_player_model(MDL_PLAYER);
};

void precache()
{
	precache_models();
	precache_sounds();
};
