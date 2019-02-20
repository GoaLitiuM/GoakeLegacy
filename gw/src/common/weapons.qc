void SpawnRocket(vector pos, vector dir, entity player);

.bool shoot_once; // remove me
void PlayerWeaponTick()
{
	local bool attack = input_buttons & BUTTON_ATTACK != 0;
	if (attack && !self.shoot_once)
	{
		local vector forward = getForwardVector(getViewAngles());
		local vector offset = getViewOffsets();

        clientsound(self, CHAN_WEAPON, SND_WEAPON_RL, true, ATTN_NORM);

		SpawnRocket(((self.origin + (forward * 16)) + offset), forward, self);

        self.shoot_once = true;
	}
	else if (!attack)
		self.shoot_once = false;
}

void RocketTick() { }

void ApplyRadialForceEntity(vector location, float force, float radius, entity target)
{
	local vector center = target.origin + ((target.mins + target.maxs) * 0.5);
	local float distance = vlen(center - location);
	if (distance > radius)
		return;

	local float thickness = vlen(target.mins + target.maxs) * 0.5;
	local float multiplier = (radius-distance-thickness) / distance;

	if (multiplier < 0.0f)
		multiplier = 0.0f;
	else if (multiplier > 1.0f)
		multiplier = 1.0f;
	local vector direction = center - location;
	direction = normalize(direction);

	// apply the force to entity's velocity
	target.velocity = target.velocity + (direction * force * multiplier);
}

void ApplyRadialForce(vector location, float force, float radius, entity ignored)
{
	local entity ent;
	ent = findradius(location, radius);
	while (ent != world)
	{
		if (ent != ignored && ent != self)
			ApplyRadialForceEntity(location, force, radius, ent);
		ent = ent.chain;
	}
};

void ProjectileExplosionTick()
{
	if (self.frame >= 5)
	{
		remove(self);
		return;
	}
	self.frame += 0.5;
	self.nextthink = time + 0.05;
}

void ProjectileExplode(string model)
{
	remove(self);
	/*self.movetype = MOVETYPE_NONE;
	self.velocity = VEC_ORIGIN;
	self.solid = SOLID_NOT;

	self.touch = noop;
	setmodel(self, model);

	self.think = ProjectileExplosionTick;
	ProjectileExplosionTick();*/
}

void RocketOnTouch()
{
	//TODO: remove after 30 seconds or so
	if (other == self.owner)
		return;

	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		remove(self);
		return;
	}

	local float damage = ROCKET_DAMAGE;
	local float force = ROCKET_FORCE;
	local float radius = ROCKET_RADIUS;

	if (other != world)
		ApplyRadialForceEntity(self.origin, force, radius, other);

	ApplyRadialForce(self.origin, force, radius, other);

	self.origin = (self.origin - (8 * normalize(self.velocity)));

#ifdef SSQC
	writeByte(MSG_BROADCAST, SVC_TEMPENTITY);
	writeByte(MSG_BROADCAST, TE_EXPLOSION);
	writeVector(MSG_BROADCAST, self.origin);
#endif

	ProjectileExplode(SPR_EXPLOSION);
}

void SpawnRocket(vector pos, vector dir, entity player)
{
	local entity missile;

	missile = spawn();
	missile.owner = player;
	missile.movetype = MOVETYPE_FLYMISSILE;
	missile.solid = SOLID_BBOX;
	missile.classname = "missile";
	missile.velocity = dir * ROCKET_SPEED;
	missile.angles = vectoangles(dir);
	missile.touch = RocketOnTouch;
	missile.nextthink = (time + MOVETYPE_FLY);
	missile.think = RocketTick;
	setmodel(missile, MDL_ROCKET);
	setsize(missile, VEC_ORIGIN, VEC_ORIGIN);
	setorigin(missile, pos);

#ifdef CSQC
	missile.drawmask = MASK_ENGINE;
#endif
}
