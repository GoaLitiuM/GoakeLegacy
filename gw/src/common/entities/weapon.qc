bool Weapon_OnTouch()
{
	if (self.ammo_stat < STAT_AMMO_FIRST || self.ammo_stat >= STAT_AMMO_LAST)
		error(strcat("invalid ammo_stat number ", itos(self.ammo_stat)));

	// ammo component of the weapon
	int ammo_index = self.ammo_stat-STAT_AMMO_FIRST;
	if (!Ammo_OnTouch() && other.ammo[ammo_index] != AMMO_INFINITE)
		return false;

	// add the weapon
	return true;
}

void weapon_rocketlauncher()
{
	Item_InitWeapon();
	Item_SetTouch(Weapon_OnTouch);

	self.ammo_stat = STAT_AMMO_ROCKETS;
	if (self.count == 0)
		self.count = 5;
}

void weapon_crossbow()
{
	Item_InitWeapon();
	Item_SetTouch(Weapon_OnTouch);

	self.ammo_stat = STAT_AMMO_BOLTS;
	if (self.count == 0)
		self.count = 5;
}

void weapon_lightning()
{
	Item_InitWeapon();
	Item_SetTouch(Weapon_OnTouch);

	self.ammo_stat = STAT_AMMO_CELLS;
	if (self.count == 0)
		self.count = 20;
}