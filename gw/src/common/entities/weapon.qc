bool Weapon_OnTouch()
{
	if (self.ammo_stat < STAT_AMMO_FIRST || self.ammo_stat >= STAT_AMMO_LAST)
		error(strcat("invalid ammo_stat number ", itos(self.ammo_stat)));

	bool picked = false;
	if (!(other.weapons & self.weapons))
	{
		other.weapons |= self.weapons;
		picked = true;
	}

	// ammo component of the weapon
	int ammo_index = self.ammo_stat-STAT_AMMO_FIRST;
	int prev_ammo = other.ammo[ammo_index];
	if (other.ammo[ammo_index] < self.count)
	{
		// weapons only replenish ammo up to the initial ammo count
		picked |= Ammo_OnTouch();
		if (other.ammo[ammo_index] > self.count)
			other.ammo[ammo_index] = self.count;
	}

	return picked;
}

void weapon_nailgun()
{
	Item_InitWeapon();
	Item_SetTouch(Weapon_OnTouch);

	self.weapons = WEAPON_BIT(WEAPON_NAILGUN);
	self.ammo_stat = STAT_AMMO_ROCKETS;
	if (self.count == 0)
		self.count = 50;
}

void weapon_rocketlauncher()
{
	Item_InitWeapon();
	Item_SetTouch(Weapon_OnTouch);

	self.weapons = WEAPON_BIT(WEAPON_ROCKET);
	self.ammo_stat = STAT_AMMO_ROCKETS;
	if (self.count == 0)
		self.count = 5;
}

void weapon_crossbow()
{
	Item_InitWeapon();
	Item_SetTouch(Weapon_OnTouch);

	self.weapons = WEAPON_BIT(WEAPON_CROSSBOW);
	self.ammo_stat = STAT_AMMO_BOLTS;
	if (self.count == 0)
		self.count = 5;
}

void weapon_lightning()
{
	Item_InitWeapon();
	Item_SetTouch(Weapon_OnTouch);

	self.weapons = WEAPON_BIT(WEAPON_LIGHTNING);
	self.ammo_stat = STAT_AMMO_CELLS;
	if (self.count == 0)
		self.count = 20;
}