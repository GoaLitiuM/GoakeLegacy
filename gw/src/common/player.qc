void PlayerOnJump();

void PlayerInit()
{
	self.classname = CLASS_PLAYER;
	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_WALK;
	self.view_ofs = VEC_OFFSET_EYES;

	setmodel(self, MDL_PLAYER);
	setsize(self, VEC_HULL_MIN, VEC_HULL_MAX);

	self.weapon_next = self.weapon;
}

void PlayerRemove()
{
	self.model = 0;
	self.solid = SOLID_NOT;
	#ifdef CSQC
	self.predraw = noop_predraw;
	#endif
}

float last_jump_count;
float last_jump_time;
float last_velocity_z;
void PlayerPreTick()
{
	// needed for tracking player jumps and landing velocity
	last_jump_count = self.jump_count;
	last_jump_time = self.jump_time;
	last_velocity_z = self.velocity_z;
}

void PlayerCustomPhysics()
{
	runstandardplayerphysics(self);
}

void PlayerPostTick()
{
	local bool onground = (self.flags & FL_ONGROUND) != 0;

	if (self.health <= 0)
		return;

	if (input_impulse > 0 && input_impulse < WEAPON_LAST && self.weapon_next != input_impulse)
	{
		if (self.weapons & WEAPON_BIT(input_impulse))
			self.weapon_next = input_impulse;
		else
			print("player does not have that weapon\n");
	}

	// player wants to switch the weapon
	if (self.weapon_next != self.weapon)
	{
		if (!PlayerIsReloading())
			self.weapon = self.weapon_next;
	}

	// player landing sound
	if (onground && last_velocity_z < -300)
	{
		if (self.watertype == CONTENT_WATER)
			clientsound(self, CHAN_BODY, SND_JUMP_WATER, 1, ATTN_NORM, 0, SOUNDFLAG_FOLLOW);
		else if (last_velocity_z < -650)
			clientsound(self, CHAN_VOICE, SND_LAND_HARD, 1, ATTN_NORM, 0, SOUNDFLAG_FOLLOW);
		else
			clientsound(self, CHAN_VOICE, SND_LAND_SOFT, 1, ATTN_NORM, 0, SOUNDFLAG_FOLLOW);
	}

	// player jump
	if (self.jump_count > last_jump_count || (self.jump_time > 0 && self.jump_time < last_jump_time))
		PlayerOnJump();

	PlayerWeaponTick();
}

void PlayerOnJump()
{
	clientsound(self, CHAN_VOICE2, SND_JUMP, 1, ATTN_NORM, 0, SOUNDFLAG_FOLLOW);
}
