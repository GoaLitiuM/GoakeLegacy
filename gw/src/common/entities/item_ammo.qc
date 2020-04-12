bool Ammo_OnTouch()
{
	if (self.ammo_stat < STAT_AMMO_FIRST || self.ammo_stat >= STAT_AMMO_LAST)
		error(strcat("invalid ammo_stat number ", itos(self.ammo_stat)));

	int max_ammo = AMMO_MAX(self.ammo_stat);
	if (other.ammo[self.ammo_stat-STAT_AMMO_FIRST] >= max_ammo)
		return false;

	other.ammo[self.ammo_stat-STAT_AMMO_FIRST] += self.count;
	if (other.ammo[self.ammo_stat-STAT_AMMO_FIRST] > max_ammo)
		other.ammo[self.ammo_stat-STAT_AMMO_FIRST] = max_ammo;

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