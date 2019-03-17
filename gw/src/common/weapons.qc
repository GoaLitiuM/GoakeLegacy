void PlayerWeaponAttack();
void PlayerWeaponReload(float reloadtime);

bool PlayerIsReloading()
{
	return svtime < self.reload_time;
}

void PlayerWeaponTick()
{
	if (input_buttons & BUTTON_ATTACK != 0 && !PlayerIsReloading())
		PlayerWeaponAttack();
}

void PlayerWeaponAttack()
{
	local int ammo_consumed = 0;
	switch (self.weapon)
	{
		case WEAPON_ROCKET:
			ammo_consumed = WeaponRocketFire();
			break;
		case 0:
		default:
			break;
	}

	if (ammo_consumed != 0)
		self.ammo[WEAPON_AMMO_INDEX(self.weapon)] += ammo_consumed;
}

void PlayerWeaponReload(float reloadtime)
{
	self.reload_time = svtime + reloadtime;
}
