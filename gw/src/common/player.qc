void PlayerInit()
{
	self.weapon_next = self.weapon;
}

void PlayerPreTick()
{
	if (input_impulse > 0 && input_impulse < WEAPON_LAST && self.weapon != input_impulse)
	{
		if (self.weapons & WEAPON_BIT(input_impulse))
			self.weapon_next = input_impulse;
		else
			print("player does not have that weapon\n");
	}

	// player wants to switch the weapon
	if (self.weapon_next != self.weapon && self.weapon_next >= 0)
	{
		if (!PlayerIsReloading())
		{
			self.weapon = self.weapon_next;
			self.weapon_next = -1;
		}
	}

	local bool onground = (self.flags & FL_ONGROUND) != 0;
	local bool jump_released = (self.flags & FL_JUMPRELEASED) != 0;

	if (input_buttons & BUTTON_JUMP)
	{
		if (sv_autojump > 0 && (self.jump_time == 0 || self.jump_time > sv_autojump))
			jump_released = true;

		if (onground && jump_released)
		{
			clientsound(self, CHAN_VOICE2, SND_JUMP, 1, ATTN_NORM, 0, SOUNDFLAG_FOLLOW);
			self.flags = self.flags & ~FL_JUMPRELEASED;
		}
	}
	else
		self.flags |= FL_JUMPRELEASED;
}

.float last_velocity_z;
void PlayerPostTick()
{
	if (self.health <= 0)
		return;

	local bool onground = (self.flags & FL_ONGROUND) != 0;

	if ((self.last_velocity_z < -300) && onground)
	{
		if (self.watertype == CONTENT_WATER)
			clientsound(self, CHAN_BODY, SND_JUMP_WATER, 1, ATTN_NORM, 0, SOUNDFLAG_FOLLOW);
		else if (self.last_velocity_z < -650)
			clientsound(self, CHAN_VOICE, SND_LAND_HARD, 1, ATTN_NORM, 0, SOUNDFLAG_FOLLOW);
		else
			clientsound(self, CHAN_VOICE, SND_LAND_SOFT, 1, ATTN_NORM, 0, SOUNDFLAG_FOLLOW);

		self.last_velocity_z = 0;
	}

	if (!onground)
		self.last_velocity_z = self.velocity_z;

	PlayerWeaponTick();
}

void PlayerCustomPhysics(entity player)
{
	runstandardplayerphysics(player);
}

void PlayerRemove()
{
	self.model = 0;
	self.solid = SOLID_NOT;
	#ifdef CSQC
	self.predraw = noop_predraw;
	#endif
}
