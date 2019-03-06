void precache_sounds()
{
	precache_sound(SND_JUMP);
	precache_sound(SND_JUMP_WATER);
	precache_sound(SND_LAND_SOFT);
	precache_sound(SND_LAND_HARD);

	precache_sound(SND_WEAPON_ROCKET);
};

void precache_models()
{
	precache_model(SPR_EXPLOSION);
	precache_model(MDL_PLAYER);
	precache_model(MDL_ROCKET);
};

void precache()
{
	precache_models();
	precache_sounds();
};
