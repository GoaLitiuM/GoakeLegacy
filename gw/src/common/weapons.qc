struct Weapon
{
	string name;
	float reload_time;
	int ammo_consumption; // how much ammo is used when fired

	// called when player intents to fire the weapon, returns: ammo consumed, or 0 when firing failed
	int(vector) attack;

	// optional, called every tick
	void() tick;

	// optional, returns: reload time
	float() reload;
};
Weapon* weapon_defs;
int weapons_allocated_count;

void Weapon_Init()
{
	weapons_allocated_count = WEAPON_LAST;
	weapon_defs = memalloc(sizeof(Weapon) * weapons_allocated_count);

	weapon_defs[WEAPON_ROCKET] = (Weapon){ "Rocket Launcher", ROCKET_RELOAD, 1, WeaponRocket_Fire, 0, 0 };
	weapon_defs[WEAPON_LIGHTNING] = (Weapon){ "Lightning Gun", LIGHTNING_RELOAD, 1, WeaponLightning_Fire, 0, 0 };
	weapon_defs[WEAPON_CROSSBOW] = (Weapon){ "Crossbow", CROSSBOW_RELOAD, 1, WeaponCrossbow_Fire, 0, 0 };
}

void Player_WeaponAttack(vector angle);
void Player_WeaponReload(float reloadtime);

bool Player_IsReloading()
{
	return svtime < self.reload_time;
}

void Player_WeaponTick()
{
	if (input_buttons & BUTTON_ATTACK != 0 && !Player_IsReloading())
	{
#ifdef CSQC
		input_subframe_angles = attack_angle; // FIXME
#endif
		vector player_angle = getForwardVector(input_subframe_angles);

		// TODO: server-side verify the angle
		Player_WeaponAttack(player_angle);
	}

	if (weapon_defs[self.weapon].tick != 0)
		weapon_defs[self.weapon].tick();
}

void Player_WeaponAttack(vector angle)
{
	Weapon* weapon_def = &weapon_defs[self.weapon];
	int* weapon_ammo = &self.ammo[WEAPON_AMMO_INDEX(self.weapon)];

	if (!(self.weapons & WEAPON_BIT(self.weapon)))
		return; // player does not have this weapon

	if (*weapon_ammo == AMMO_INFINITE || *weapon_ammo >= weapon_def->ammo_consumption)
	{}	// enough ammo to fire
	else
		return;

	int ammo_consumed = 0;
	if (weapon_def->attack != 0)
		ammo_consumed = weapon_def->attack(angle);

	if (ammo_consumed != 0)
	{
		if (weapon_def->ammo_consumption > 0 && *weapon_ammo > 0)
		{
			*weapon_ammo -= ammo_consumed;
			if (*weapon_ammo < 0)
				*weapon_ammo = 0;
		}
		self.projectile_id++;

		float reload_time = weapon_def->reload_time;
		if (weapon_def->reload != 0)
			reload_time = weapon_def->reload();

		Player_WeaponReload(reload_time);
	}

#ifdef SSQC
	writeByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	writeByte(MSG_MULTICAST, EVENT_PLAYER_ATTACK);
	WriteEntity(MSG_MULTICAST, self);
	multicast(self.origin, MULTICAST_PVS);
#endif
	self.is_attacking = true; // drives animations
}

void Player_WeaponReload(float reloadtime)
{
	self.reload_time = svtime + reloadtime;
}
