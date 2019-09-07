struct Weapon
{
	string name;
	float reload_time;

	int() attack; // returns: ammo consumed
	void() tick; // optional
	float() reload; // optional, returns: reload time
};
Weapon* weapon_defs;
int weapons_allocated_count;

void Weapon_Init()
{
	weapons_allocated_count = WEAPON_LAST;
	weapon_defs = memalloc(sizeof(Weapon) * weapons_allocated_count);

	weapon_defs[WEAPON_ROCKET] = (Weapon){ "Rocket Launcher", ROCKET_RELOAD, WeaponRocket_Fire, 0, 0 };
	weapon_defs[WEAPON_LIGHTNING] = (Weapon){ "Lightning Gun", LIGHTNING_RELOAD, WeaponLightning_Fire, 0, 0 };
	weapon_defs[WEAPON_CROSSBOW] = (Weapon){ "Crossbow", CROSSBOW_RELOAD, WeaponCrossbow_Fire, 0, 0 };
}

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

	if (weapon_defs[self.weapon].tick != 0)
		weapon_defs[self.weapon].tick();
}

void Player_WeaponAttack()
{
	local int ammo_consumed = 0;
	if (weapon_defs[self.weapon].attack != 0)
		ammo_consumed = weapon_defs[self.weapon].attack();

	if (ammo_consumed != 0)
	{
		self.ammo[WEAPON_AMMO_INDEX(self.weapon)] += ammo_consumed;
		self.projectile_id++;

		local float reload_time = weapon_defs[self.weapon].reload_time;
		if (weapon_defs[self.weapon].reload != 0)
			reload_time = weapon_defs[self.weapon].reload();

		Player_WeaponReload(reload_time);
	}
}

void Player_WeaponReload(float reloadtime)
{
	self.reload_time = svtime + reloadtime;
}
