.float last_velocity_z;
void PlayerPreTick()
{
	bool onground = (self.flags & FL_ONGROUND) != 0;
	bool jump_released = (self.flags & FL_JUMPRELEASED) != 0;

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

void PlayerPostTick()
{
	if (self.health <= 0)
		return;

	bool onground = (self.flags & FL_ONGROUND) != 0;

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
