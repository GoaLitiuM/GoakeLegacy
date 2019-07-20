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

	setorigin(self, self.origin);
}

void PlayerRemove()
{
	self.model = 0;
	self.solid = SOLID_NOT;
	#ifdef CSQC
	self.predraw = noop_predraw;
	#endif

	setorigin(self, self.origin);
}

void PlayerSpawn();
void PlayerRequestRespawn()
{
	PlayerSpawn();

#ifdef CSQC
	// unrelease these actions to force player to release the keys in order to request respawning
	localcmd("-attack; -jump");
#endif
}

void PlayerPreTick()
{
	// needed for tracking player jumps and landing velocity
	self.last_jump_count = self.jump_count;
	self.last_jump_time = self.jump_time;
	self.last_velocity_z = self.velocity_z;
}

void PlayerPhysics()
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

	runstandardplayerphysics(self);

	if (self.health <= 0)
	{
		input_movevalues = old_input_movevalues;
		input_buttons = old_input_buttons;
		input_impulse = old_input_impulse;
	}
}

void PlayerPostTick()
{
	local bool onground = (self.flags & FL_ONGROUND) != 0;

	if (self.health <= 0)
	{
		if (input_impulse == IMPULSE_RESPAWN || input_impulse == IMPULSE_RESPAWN_FORCED)
			PlayerRequestRespawn();

		return;
	}
	else if (input_impulse == IMPULSE_RESPAWN_FORCED)
		PlayerRequestRespawn();

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
		if (!PlayerIsReloading())
			self.weapon = self.weapon_next;
	}

	// player jump
	if (self.jump_count > self.last_jump_count || (self.jump_time > 0 && self.jump_time < self.last_jump_time))
		PlayerOnJump();

	PlayerWeaponTick();
}

void PlayerOnJump()
{
	clientsound(self, CHAN_VOICE2, SND_JUMP, 1, ATTN_NORM, 0, SOUNDFLAG_FOLLOW);
}

void PlayerOnDeath(entity source, entity sourcePlayer)
{
	self.solid = SOLID_NOT;
	self.movetype = MOVETYPE_TOSS;

#ifdef CSQC
	// unrelease these actions to force player to release the keys in order to request respawning
	localcmd("-attack; -jump");
#endif
}

void PlayerTakeDamage(float damage, entity source)
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
		PlayerOnDeath(source, sourcePlayer);
}
