void Player_OnJump();

void Player_Init()
{
	self.classname = CLASS_PLAYER;
	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_WALK;
	self.view_ofs = VEC_OFFSET_EYES;

	setmodel(self, MDL_PLAYER);
	setsize(self, VEC_HULL_MIN, VEC_HULL_MAX);

	self.weapon_next = self.weapon;

	setorigin(self, self.origin);

	self.SendFlags |= SENDFLAGS_ALL;
}

void Player_Remove()
{
	self.model = 0;
	self.solid = SOLID_NOT;
	#ifdef CSQC
	self.predraw = noop_predraw;
	#endif

	setorigin(self, self.origin);

	self.SendFlags |= SENDFLAGS_ALL;
}

void Player_Spawn();
void Player_RequestRespawn()
{
	Player_Spawn();

#ifdef CSQC
	// unrelease these actions to prevent player firing as soon as they spawn
	localcmd("-attack; -jump");
#endif
}

void Player_PreTick()
{
	// needed for tracking player jumps and landing velocity
	self.last_jump_count = self.jump_count;
	self.last_jump_time = self.jump_time;
	self.last_velocity_z = self.velocity_z;
}

void Player_Physics()
{
	local vector old_input_movevalues = input_movevalues;
	local float old_input_buttons = input_buttons;
	local float old_input_impulse = input_impulse;

	if (self.health <= 0)
	{
		input_movevalues = '0 0 0';
		input_buttons = 0;
		input_impulse = 0;
	}

#ifdef SSQC
	local vector old_origin = self.origin;
	local vector old_velocity = self.velocity;
	local vector old_angles = self.angles;
	local float old_flags = self.flags;
	local float old_pmove_flags = self.pmove_flags;
	local float old_jump_time = self.jump_time;
	local float old_jump_count = self.jump_count;
#endif
	runstandardplayerphysics(self);

#ifdef SSQC
	// TODO: do these in PreThink
	if (self.origin != old_origin)
		self.SendFlags |= SENDFLAGS_ORIGIN;
	if (self.velocity != old_velocity)
		self.SendFlags |= SENDFLAGS_VELOCITY;
	if (self.velocity != old_angles)
		self.SendFlags |= SENDFLAGS_ANGLES;
	if (self.flags != old_flags || self.pmove_flags != old_pmove_flags)
		self.SendFlags |= SENDFLAGS_FLAGS;
	if (self.jump_time != old_jump_time || self.jump_count != old_jump_count)
		self.SendFlags |= SENDFLAGS_JUMP;
#endif

	if (self.health <= 0)
	{
		input_movevalues = old_input_movevalues;
		input_buttons = old_input_buttons;
		input_impulse = old_input_impulse;
	}
}

void Player_PostTick()
{
	local bool onground = (self.flags & FL_ONGROUND) != 0;

	if (self.health <= 0)
	{
		if (input_impulse == IMPULSE_RESPAWN || input_impulse == IMPULSE_RESPAWN_FORCED)
			Player_RequestRespawn();

		return;
	}
	else if (input_impulse == IMPULSE_RESPAWN_FORCED)
		Player_RequestRespawn();

	// handle the intent of switching weapons, may not happen until reload is finished
	if (input_impulse > 0 && input_impulse < WEAPON_LAST && self.weapon_next != input_impulse)
	{
		if (self.weapons & WEAPON_BIT(input_impulse))
			self.weapon_next = input_impulse;
		else
			print("player does not have that weapon\n");
	}

	// player landing sound
	if (onground && self.last_velocity_z < -300)
	{
		if (self.watertype == CONTENT_WATER)
			clientsound(self, CHAN_BODY, SND_JUMP_WATER, 1, ATTN_NORM, 0, SOUNDFLAG_FOLLOW);
		else if (self.last_velocity_z < -650)
			clientsound(self, CHAN_VOICE, SND_LAND_HARD, 1, ATTN_NORM, 0, SOUNDFLAG_FOLLOW);
		else
			clientsound(self, CHAN_VOICE, SND_LAND_SOFT, 1, ATTN_NORM, 0, SOUNDFLAG_FOLLOW);
	}

	// player wants to switch the weapon
	if (self.weapon_next != self.weapon)
	{
		if (!Player_IsReloading())
			self.weapon = self.weapon_next;
	}

	// player jump
	if (self.jump_count > self.last_jump_count || (self.jump_time > 0 && self.jump_time < self.last_jump_time))
		Player_OnJump();

	Player_WeaponTick();
}

void Player_OnJump()
{
	clientsound(self, CHAN_VOICE2, SND_JUMP, 1, ATTN_NORM, 0, SOUNDFLAG_FOLLOW);
}

void Player_OnDeath(entity source, entity sourcePlayer)
{
	self.solid = SOLID_NOT;
	self.movetype = MOVETYPE_TOSS;

	self.SendFlags |= SENDFLAGS_ALL;

#ifdef CSQC
	// unrelease these actions to prevent player firing as soon as they spawn
	localcmd("-attack; -jump");
#endif
}

void Player_TakeDamage(float damage, entity source)
{
	if ((int)damage <= 0)
		return;

	if (self.health <= 0)
		return;

	entity sourcePlayer = source.owner;
	if (sourcePlayer.classname != "player")
		sourcePlayer = world;

	self.health -= (int)damage;

	if (self.health <= 0)
		Player_OnDeath(source, sourcePlayer);
}
