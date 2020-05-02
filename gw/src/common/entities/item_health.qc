bool Health_OnTouch()
{
	if (other.health >= self.health_max || other.health >= other.health_max)
		return false;

	other.health += self.health;
	if (other.health > self.health_max)
		other.health = self.health_max;
	if (other.health > other.health_max)
		other.health = other.health_max;

	other.health_time = time + HEALTH_DECAY_RATE;
	return true;
}


void Mega_OnExpire(entity item)
{
	entity oldself = self;
	entity source = self;
	self = item;

	source.health_mega_ent = world;
	self.last_touched = world; // last player can't predict this anymore
	Item_StartRespawn();

	clientsound(source, CHAN_AUTO, SND_MEGA_EXPIRE, 1, ATTN_NORM, 0, SOUNDFLAG_FOLLOW, 0, source);

	self = oldself;
}

bool Mega_OnTouch()
{
	if (!Health_OnTouch())
		return false;

	if (other.health_mega_ent != world && other.health_mega_ent != self)
	{
		// player is currently under effect of other mega entity, force it to respawn
		Mega_OnExpire(other.health_mega_ent);
	}
	other.health_mega_ent = self;
	other.health_mega_left = self.health;

	Item_OnPickup(other);
	self.nextthink = time + self.health + self.respawn_time;
	return false; // we handled the pickup
}

void item_health_5()
{
	Item_InitSimple(SND_HEALTH_PICKUP);
	self.respawn_time = HEALTH_RESPAWN_TIME;

	Item_SetTouch(Health_OnTouch);
	self.health = 5;
	self.health_max = 200;
}

void item_health_25()
{
	Item_InitSimple(SND_HEALTH_PICKUP);
	self.respawn_time = HEALTH_RESPAWN_TIME;

	Item_SetTouch(Health_OnTouch);
	self.health = 25;
	self.health_max = 100;
}

void item_health_50()
{
	Item_InitSimple(SND_HEALTH_PICKUP);
	self.respawn_time = HEALTH_RESPAWN_TIME;

	Item_SetTouch(Health_OnTouch);
	self.health = 50;
	self.health_max = 100;
}

void item_health_mega()
{
	Item_InitSimple(SND_HEALTH_PICKUP);
	self.respawn_time = MEGA_RESPAWN_TIME;

	Item_SetTouch(Mega_OnTouch);
	self.health = 100;
	self.health_max = 200;
}