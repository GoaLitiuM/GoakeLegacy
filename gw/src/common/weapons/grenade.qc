void WeaponGrenade_SpawnGrenade(vector pos, vector dir, entity player);
void WeaponGrenade_OnTouch();
void WeaponGrenade_Explode(vector position, vector forward, entity ignored, entity target);

#ifdef SSQC
float WeaponGrenade_SendEntity(entity ent, float flags);
#endif

.float arm_time;
void WeaponGrenade_Init(entity grenade)
{
	grenade.movetype = MOVETYPE_BOUNCE;
	grenade.solid = SOLID_SLIDEBOX;

	grenade.classname = CLASS_GRENADE;
	grenade.effects |= EF_NOSHADOW | EF_FULLBRIGHT;
	grenade.touch = WeaponGrenade_OnTouch;
	grenade.bouncestop = 0.1/800.0;
	grenade.bouncefactor = 0.05;

	setmodel(grenade, MDL_GRENADE);
	setsize(grenade, '-1 -1 -1', '1 1 1');

#ifdef SSQC
	grenade.SendEntity = WeaponGrenade_SendEntity;
#endif
#ifdef CSQC
	grenade.drawmask = MASK_ENGINE;
#endif
}

int WeaponGrenade_Fire(vector forward)
{
	vector offset = self.view_ofs;

	WeaponGrenade_SpawnGrenade((self.origin + (forward * 16)) + offset, forward, self);

	clientsound(self, CHAN_WEAPON, SND_WEAPON_GRENADE, 1, ATTN_NORM, 0, SOUNDFLAG_FOLLOW);

	return 1;
}

void WeaponGrenade_SpawnGrenade(vector pos, vector dir, entity player)
{
	entity grenade = spawn();
	grenade.owner = player;
	grenade.velocity = dir * GRENADE_SPEED;
	grenade.angles = vectoangles(dir);
	grenade.origin = pos;
	grenade.arm_time = time + GRENADE_ARM_TIME;

	setorigin(grenade, grenade.origin);
	WeaponGrenade_Init(grenade);
}

#ifdef CSQC
void WeaponGrenade_Update(float isnew)
{
	self.origin = readVector();
	self.angles = readVector();
	self.velocity = readVector();
	self.owner = readEntity();

	if (isnew)
	{
		self.server_projectile = true;
		WeaponGrenade_Init(self);

		if (self.owner == local_player)
			self.drawmask = 0;
	}

	setorigin(self, self.origin);
}
#endif

#ifdef SSQC
float WeaponGrenade_SendEntity(entity ent, float flags)
{
	writeByte(MSG_ENTITY, SENDENTITY_GRENADE);
	writeVector(MSG_ENTITY, self.origin);
	writeVector(MSG_ENTITY, self.angles);
	writeVector(MSG_ENTITY, self.velocity);
	writeEntity(MSG_ENTITY, self.owner);
	return 1;
}
#endif

void WeaponGrenade_OnTouch()
{
	//TODO: remove after 30 seconds or so
	if (other == self.owner)
	{
		println("poink?");
		return;
	}

	if (time < self.arm_time)
		return; // bounce

	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		// projectile went out of bounds, just remove it
		remove(self);
		return;
	}

	WeaponGrenade_Explode(self.origin, normalize(self.velocity), self, other);

	remove(self);
}

void WeaponGrenade_Explode(vector position, vector forward, entity ignored, entity target)
{
	addRadialForce(position, GRENADE_FORCE, GRENADE_RADIUS, ignored, target);
	addRadialDamage(position, GRENADE_DAMAGE, GRENADE_RADIUS, ignored, target);

	if (target != world)
	{
		// direct hit with other entity, apply force and damage directly
		if (target.solid != SOLID_CORPSE)
		{
			vector dir = normalize(target.origin - position);
			target.velocity += dir * GRENADE_FORCE;
		}

		applyEntityDamage(other, GRENADE_DAMAGE, self);
	}

#ifdef SSQC
	writeByte(MSG_BROADCAST, SVC_TEMPENTITY);
	writeByte(MSG_BROADCAST, TE_EXPLOSION);
	writeVector(MSG_BROADCAST, position - (18 * forward));
#endif
}
