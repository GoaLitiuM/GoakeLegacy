void Player_WeaponAttack();
void Player_WeaponReload(float reloadtime);

bool Player_IsReloading()
{
	return svtime < self.reload_time;
}

void Player_WeaponTick()
{
	if (input_buttons & BUTTON_ATTACK != 0 && !Player_IsReloading())
		Player_WeaponAttack();
}

void Player_WeaponAttack()
{
	local int ammo_consumed = 0;
	switch (self.weapon)
	{
		case WEAPON_ROCKET:
			ammo_consumed = WeaponRocketFire();
			break;
		case WEAPON_LIGHTNING:
			ammo_consumed = WeaponLightningFire();
			break;
		case WEAPON_CROSSBOW:
			ammo_consumed = WeaponCrossbowFire();
			break;
		case 0:
		default:
			break;
	}

	if (ammo_consumed != 0)
	{
		self.ammo[WEAPON_AMMO_INDEX(self.weapon)] += ammo_consumed;
		self.projectile_id++;
	}
}

void Player_WeaponReload(float reloadtime)
{
	self.reload_time = svtime + reloadtime;
}
