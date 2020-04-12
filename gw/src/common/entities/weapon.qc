bool Weapon_OnTouch()
{
	if (self.ammo_stat < STAT_AMMO_FIRST || self.ammo_stat >= STAT_AMMO_LAST)
		error(strcat("invalid ammo_stat number ", itos(self.ammo_stat)));

	if (other.ammo[self.ammo_stat-STAT_AMMO_FIRST] >= self.count)
		return false;

	other.ammo[self.ammo_stat-STAT_AMMO_FIRST] = self.count;
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