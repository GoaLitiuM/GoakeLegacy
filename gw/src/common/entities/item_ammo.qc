bool Ammo_OnTouch()
{
	if (self.ammo_stat < STAT_AMMO_FIRST || self.ammo_stat >= STAT_AMMO_LAST)
		error(strcat("invalid ammo_stat number ", itos(self.ammo_stat)));

	int ammo_count = abs(self.count);
	int ammo_index = self.ammo_stat-STAT_AMMO_FIRST;
	int max_ammo = AMMO_MAX(self.ammo_stat);
	if (other.ammo[ammo_index] >= max_ammo)
		return false;
	else if (other.ammo[ammo_index] == AMMO_INFINITE)
		return false;

	other.ammo[ammo_index] += ammo_count;
	if (other.ammo[ammo_index] > max_ammo)
		other.ammo[ammo_index] = max_ammo;
	return true;
}

void item_ammo_rockets()
{
	Item_InitAmmo();
	Item_SetTouch(Ammo_OnTouch);

	self.ammo_stat = STAT_AMMO_ROCKETS;
	if (self.count == 0)
		self.count = 5;
}

void item_ammo_lightning()
{
	Item_InitAmmo();
	Item_SetTouch(Ammo_OnTouch);

	self.ammo_stat = STAT_AMMO_CELLS;
	if (self.count == 0)
		self.count = 10;
}

void item_ammo_stakes()
{
	Item_InitAmmo();
	Item_SetTouch(Ammo_OnTouch);

	self.ammo_stat = STAT_AMMO_BOLTS;
	if (self.count == 0)
		self.count = 5;
}

void item_ammo_grenades()
{
	Item_InitAmmo();
	Item_SetTouch(Ammo_OnTouch);

	self.ammo_stat = STAT_AMMO_GRENADES;
	if (self.count == 0)
		self.count = 5;
}