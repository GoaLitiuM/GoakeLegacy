#ifdef SSQC
void GameMode_OnPlayerSpawn(entity player);
void GameMode_OnPlayerInit(entity player);
bool GameMode_OnPlayerRequestRespawn(entity player);
float GameMode_OnPlayerTakeDamage(entity player, float damage, entity source);
vector GameMode_OnPlayerApplyForce(entity player, vector force, entity source);
void GameMode_OnPlayerDeath(entity player, entity source);
#endif

void Mega_OnExpire(entity item);

void Player_OnLand(float velocity);
void Player_OnJump();
void Player_TakeDamage(float damage, entity source);

bool Player_IsDead(entity player)
{
	return player.health <= 0;
}

bool Player_IsSpectator(entity player)
{
	return infokeyf(player, "*spectator") != 0;
}

bool Player_IsPlaying(entity player)
{
	if (strlen(infokey(player, "name")) == 0)
		return false;
	if (Player_IsSpectator(player))
		return false;
	return true;
}

void Player_Init()
{
	self.health = 100;
	self.health_max = 200;
	self.health_softcap = 100;
	self.armortype = ARMOR_GREEN_ABSORB;
	self.armorvalue = 0;
	self.armorvalue_max = 200;

	self.weapon = 0;
	self.weapons = 0;
	self.weapon_next = -1;

	self.classname = CLASS_PLAYER;
	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_WALK;
	self.view_ofs = PLAYER_OFFSET_EYES;

	setsize(self, PLAYER_SIZE_MIN, PLAYER_SIZE_MAX);

	self.spawn_wish = false;

#ifdef CSQC
	// prevent player from shooting and jumping accidentally after using these buttons to spawn
	localcmd("-attack; -jump");
#endif

	self.SendFlags |= SENDFLAGS_ALL;
	self.SendFlags |= SENDFLAGS_PLAYER_INIT;

	self.death_time = 0;

	for (int i=0; i<STAT_AMMO_LAST-STAT_AMMO_FIRST; i++)
		self.ammo[i] = 0;

#ifdef SSQC
	GameMode_OnPlayerInit(self);
#endif
}

void Player_Remove()
{
	self.solid = SOLID_NOT;
#ifdef CSQC
	self.predraw = noop_predraw;
#endif

	setorigin(self, self.origin);
	setmodel(self, 0);

	// force last picked up mega to spawn
	if (self.health_mega_ent)
		Mega_OnExpire(self.health_mega_ent);
}

void Player_Spawn()
{
	self.fixangle = 1;
	self.velocity = '0 0 0';
	setorigin(self, self.origin);
	self.oldorigin = self.origin; // in case the player becomes stuck, avoid moving back to death position
	Player_Init();
}

void Player_RequestRespawn()
{
	if (svtime - self.death_time < 1.0)
		return; // we do not want the player to respawn by their pre-death input

	self.spawn_wish = true;

#ifdef SSQC
	if (GameMode_OnPlayerRequestRespawn(self))
		GameMode_OnPlayerSpawn(self);
#endif
}

#ifdef SSQC
float Player_SendEntity(entity ent, float send_flags)
{
	writeByte(MSG_ENTITY, SENDENTITY_PLAYER);
	writeInt(MSG_ENTITY, send_flags);
	if (send_flags & SENDFLAGS_ORIGIN)
		writeVector(MSG_ENTITY, self.origin);
	if (send_flags & SENDFLAGS_ANGLES)
		writeVector(MSG_ENTITY, self.angles);
	if (send_flags & SENDFLAGS_VELOCITY)
		writeVector(MSG_ENTITY, self.velocity);
	if (send_flags & SENDFLAGS_FLAGS)
	{
		writeInt(MSG_ENTITY, self.flags);
		writeByte(MSG_ENTITY, self.pmove_flags);
	}
	if (send_flags & SENDFLAGS_JUMP)
	{
		writeFloat(MSG_ENTITY, self.jump_time);
		writeFloat(MSG_ENTITY, self.jump_count);
	}
	if (send_flags & SENDFLAGS_PHYSICS)
	{
		writeFloat(MSG_ENTITY, self.solid);
		writeFloat(MSG_ENTITY, self.movetype);
	}
	if (send_flags & SENDFLAGS_PLAYER_RELOAD)
		writeFloat(MSG_ENTITY, self.reload_time);

	return 1;
}
#endif

void Player_PreTick()
{
}

void Player_Physics()
{
#ifdef SSQC
	vector old_origin = self.origin;
	vector old_velocity = self.velocity;
	vector old_angles = self.last_angles;
	float old_flags = self.flags;
	float old_pmove_flags = self.pmove_flags;
	float old_jump_time = self.jump_time;
	float old_jump_count = self.jump_count;
#endif

	runstandardplayerphysics(self);

#ifdef SSQC
	if (self.origin != old_origin)
		self.SendFlags |= SENDFLAGS_ORIGIN;
	if (self.velocity != old_velocity)
		self.SendFlags |= SENDFLAGS_VELOCITY;
	if (self.angles != old_angles)
	{
		self.SendFlags |= SENDFLAGS_ANGLES;
		self.last_angles = self.angles; // angles are not updated during this frame
	}
	if (self.flags != old_flags || self.pmove_flags != old_pmove_flags)
		self.SendFlags |= SENDFLAGS_FLAGS;
	if (self.jump_time != old_jump_time || self.jump_count != old_jump_count)
		self.SendFlags |= SENDFLAGS_JUMP;
	if (self.solid != self.last_solid || self.movetype != self.last_movetype)
	{
		self.SendFlags |= SENDFLAGS_PHYSICS;
		self.last_solid = self.solid;
		self.last_movetype = self.movetype;
	}
#endif
}

void Player_PostTick()
{
	if (Player_IsSpectator(self))
	{
#ifdef CSQC
		if (self == local_player)
			return;
#endif
		return;
	}

	bool onground = (self.flags & FL_ONGROUND) != 0;
	bool jumped = (self.pmove_flags & PMF_JUMPED) != 0 && (self.last_pmove_flags & PMF_JUMPED) == 0;

	if (Player_IsDead(self))
	{
		if (input_impulse == IMPULSE_RESPAWN || input_impulse == IMPULSE_RESPAWN_FORCED)
			Player_RequestRespawn();

		return;
	}
	else if (input_impulse == IMPULSE_RESPAWN_FORCED)
		Player_RequestRespawn();

	self.death_time = svtime; // in case the client doesn't predict their death


	if (self.watertype == CONTENT_LAVA)
	{
		if (self.damage_time < time)
			self.damage_time = time;
	}
	else //if (self.watertype == CONTENT_EMPTY || self.watertype == 0)
		self.damage_time = 0;

	if (time-self.damage_time >= 0 && self.watertype == CONTENT_LAVA)
	{
		self.damage_time += LAVA_DAMAGE_RATE;
		Player_TakeDamage(LAVA_DAMAGE, world);
	}

	// health ticks down towards the softcap
	if (self.health > self.health_softcap || self.health_mega_ent != world)
	{
		while (time-self.health_time >= 0)
		{
			if (self.health > self.health_softcap)
				self.health = (int)(self.health-1);
			if (self.health_mega_left > 0)
				self.health_mega_left -= 1;

			if (self.health <= self.health_softcap && self.health_mega_left <= 0)
				break;

			self.health_time += HEALTH_DECAY_RATE;
		}

		// track mega health, and respawn it if the picked up health runs out
		if (self.health_mega_ent && self.health_mega_left <= 0)
			Mega_OnExpire(self.health_mega_ent);
	}

	// handle the intent of switching weapons, may not happen until reload is finished
	if (input_impulse > 0 && input_impulse < WEAPON_LAST && self.weapon_next != input_impulse)
	{
		if (self.weapons & WEAPON_BIT(input_impulse))
			self.weapon_next = input_impulse;
	}

	// player landing sound
	if (onground && self.last_velocity_z < SND_JUMPLAND_LAND_THRESHOLD)
	{
		Player_OnLand(self.last_velocity_z);
		self.landed_time = time;
	}

	// player wants to switch the weapon
	if (self.weapon_next >= 0 && self.weapon_next != self.weapon)
	{
		if (!Player_IsReloading())
			self.weapon = self.weapon_next;
	}

	// player jump
	if (jumped)
		Player_OnJump();

	Player_WeaponTick();

	self.last_velocity_z = self.velocity_z;
	self.last_pmove_flags = self.pmove_flags;
}

void Player_OnLand(float velocity)
{
	float landing_multiplier = SND_JUMPLAND_LAND_VOLUME;
	if (velocity < SND_JUMPLAND_LAND_HARD_THRESHOLD)
		landing_multiplier = SND_JUMPLAND_LAND_HARD_VOLUME;

	float pitch_variance = SND_JUMPLAND_VARIANCE != 0.0 ? randomFloat(1.0-SND_JUMPLAND_VARIANCE, 1.0+SND_JUMPLAND_VARIANCE) : 1.0;
	clientsound(self, CHAN_BODY, SND_JUMPLAND, SND_JUMPLAND_VOLUME*landing_multiplier, ATTN_NORM, pitch_variance, SOUNDFLAG_FOLLOW);
}

void Player_OnJump()
{
	// do not play again when player landed recently
	if (time - self.landed_time < 0.3)
		return;

	float pitch_variance = SND_JUMPLAND_VARIANCE != 0.0 ? randomFloat(1.0-SND_JUMPLAND_VARIANCE, 1.0+SND_JUMPLAND_VARIANCE) : 1.0;
	clientsound(self, CHAN_BODY, SND_JUMPLAND, SND_JUMPLAND_VOLUME*SND_JUMPLAND_JUMP_VOLUME, ATTN_NORM, pitch_variance, SOUNDFLAG_FOLLOW);
}

void Player_OnDeath(entity source)
{
	if (self.health_mega_ent)
		Mega_OnExpire(self.health_mega_ent);

	self.solid = SOLID_NOT;
	self.movetype = MOVETYPE_TOSS;
	self.death_time = svtime;
	self.spawn_wish = false;

	self.SendFlags |= SENDFLAGS_ALL;

#ifdef SSQC
	GameMode_OnPlayerDeath(self, source);
#endif
}

void Player_AddHealth(entity player, int hp, int max_hp)
{
	player.health += hp;
	if (player.health > max_hp)
		player.health = max_hp;
	if (player.health > player.health_max)
		player.health = player.health_max;

	player.health_time = time + HEALTH_DECAY_RATE;
	player.health = (int)ceil(player.health);
}

void Player_TakeDamage(float damage, entity source)
{
	if (Player_IsDead(self))
		return;

#ifdef SSQC
	damage = GameMode_OnPlayerTakeDamage(self, damage, source);
#endif

	if ((int)damage <= 0)
		return;

	entity sourcePlayer = source != world ? source.owner : world;
	if (sourcePlayer != world && sourcePlayer.classname != CLASS_PLAYER)
		sourcePlayer = world;

	if (sourcePlayer == self)
		damage *= DAMAGE_MULTIPLIER_SELF;

	if (self.health_mega_ent != world)
		self.health_mega_left -= (int)damage;

	float armor_damage = min(self.armorvalue, damage * self.armortype);
	damage = damage - armor_damage;

	self.health -= damage;
	self.armorvalue -= armor_damage;

	if (self.armorvalue <= 0)
		self.armortype = ARMOR_GREEN_ABSORB;

	if (Player_IsDead(self))
		Player_OnDeath(source);
}

void Player_ApplyForce(vector force, entity source)
{
#ifdef SSQC
	force = GameMode_OnPlayerApplyForce(self, force, source);
#endif
	if (vlen(force) == 0.0f)
		return;

	self.velocity += force;
	self.SendFlags |= SENDFLAGS_VELOCITY;
}

void Player_Kill(entity source)
{
	if (Player_IsDead(self))
		return;

	self.health = 0;
	self.armorvalue = 0;
	Player_OnDeath(source);
}
