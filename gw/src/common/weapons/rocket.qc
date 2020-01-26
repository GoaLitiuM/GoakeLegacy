void WeaponRocket_SpawnRocket(vector pos, vector dir, entity player);
void WeaponRocket_OnTouch();
void WeaponRocket_Explode(vector position, vector forward, entity ignored, entity target);

#ifdef SSQC
float WeaponRocket_SendEntity(entity ent, float flags);
#endif

void WeaponRocket_Init(entity missile)
{
	missile.movetype = MOVETYPE_FLYMISSILE;
	missile.solid = SOLID_BBOX;
	missile.classname = CLASS_ROCKET;
	missile.effects |= EF_NOSHADOW | EF_FULLBRIGHT;
	missile.touch = WeaponRocket_OnTouch;

	setmodel(missile, MDL_ROCKET);
	setsize(missile, VEC_ORIGIN, VEC_ORIGIN);

#ifdef SSQC
	missile.SendEntity = WeaponRocket_SendEntity;
#endif
#ifdef CSQC
	missile.drawmask = MASK_ENGINE;
#endif
}

int WeaponRocket_Fire()
{
	local vector forward = getForwardVector(getViewAngles());
	local vector offset = self.view_ofs;

	WeaponRocket_SpawnRocket((self.origin + (forward * 16)) + offset, forward, self);

	clientsound(self, CHAN_WEAPON, SND_WEAPON_ROCKET, 1, ATTN_NORM, 0, SOUNDFLAG_FOLLOW);

	return 1;
}

void WeaponRocket_SpawnRocket(vector pos, vector dir, entity player)
{
	local entity missile = spawn();
	missile.owner = player;
	missile.velocity = dir * ROCKET_SPEED;
	missile.angles = vectoangles(dir);
	missile.projectile_id = player.projectile_id;
	missile.origin = pos;

	setorigin(missile, missile.origin);
	WeaponRocket_Init(missile);
}

#ifdef CSQC
void WeaponRocket_Update(float isnew)
{
	self.origin = readVector();
	self.angles = readVector();
	self.velocity = readVector();
	self.owner = readEntity();
	local int pid = readFloat();


	self.projectile_id = pid;
}
#endif

#ifdef SSQC
float WeaponRocket_SendEntity(entity ent, float flags)
{
	writeByte(MSG_ENTITY, 2);
	writeVector(MSG_ENTITY, self.origin);
	writeVector(MSG_ENTITY, self.angles);
	writeVector(MSG_ENTITY, self.velocity);
	writeEntity(MSG_ENTITY, self.owner);
	writeFloat(MSG_ENTITY, self.projectile_id);
	return 1;
}
#endif

void WeaponRocket_OnTouch()
{
	//TODO: remove after 30 seconds or so
	if (other == self.owner)
		return;

	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		// projectile went out of bounds, just remove it
		remove(self);
		return;
	}

	WeaponRocket_Explode(self.origin, normalize(self.velocity), self, other);

	remove(self);
}

void WeaponRocket_Explode(vector position, vector forward, entity ignored, entity target)
{
	addRadialForce(position, ROCKET_FORCE, ROCKET_RADIUS, ignored, target);
	addRadialDamage(position, ROCKET_DAMAGE, ROCKET_RADIUS, ignored, target);

	if (target != world)
	{
		// direct hit with other entity, apply force and damage directly
		if (target.solid != SOLID_CORPSE)
		{
			local vector dir = normalize(target.origin - position);
			target.velocity += dir * ROCKET_FORCE;
		}

		applyEntityDamage(other, ROCKET_DAMAGE, self);
	}

#ifdef SSQC
	writeByte(MSG_BROADCAST, SVC_TEMPENTITY);
	writeByte(MSG_BROADCAST, TE_EXPLOSION);
	writeVector(MSG_BROADCAST, position - (18 * forward));
#endif
}
