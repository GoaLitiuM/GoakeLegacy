void applyEntityDamage(entity target, float damage, entity source)
{
	if (target.classname == CLASS_PLAYER)
	{
		if (self.server_projectile && self.owner == target)
		{
			// client owned projectiles were predicted earlier
			return;
		}

		entity oldself = self;
		self = target;
		Player_TakeDamage(damage, source);
		self = oldself;
	}
}

void applyEntityForce(entity target, vector force, entity source)
{
	if (target.classname == CLASS_PLAYER)
	{
		if (self.server_projectile && self.owner == target)
		{
			// client owned projectiles were predicted earlier
			return;
		}

		entity oldself = self;
		self = target;
		Player_ApplyForce(force, source);

		// HACK: player does not get lifted off from the ground due to weird QW ramp physics,
		// so we need to slightly adjust the origin of the player to ignore these checks
		float rampvelocity = serverkeyfloat("pm_rampvelocity", stof(cvar_defstring("pm_rampvelocity")));
		if (target.flags & FL_ONGROUND && force.z > 0 && target.velocity.z < rampvelocity)
			target.origin.z += 1.0f;

		self = oldself;
	}
}

void addRadialDamageEntity(vector location, float damage, float radius, entity target, entity source, float power = 1.0f, float damage_min = 0.0f)
{
	vector center = target.origin + ('0 0 1' * (target.maxs_z - target.mins_z) * 0.5);
	float distance = vlen(center - location);
	if (distance > radius)
		return;

	float multiplier = (radius-distance) / distance;
	if (multiplier <= 0.0f)
		return;
	else if (multiplier > 1.0f)
		multiplier = 1.0f;

	if (power != 1.0f)
		multiplier = pow(multiplier, power);

	float final_damage = damage * multiplier;
	if (final_damage < damage_min)
		final_damage = damage_min;

	applyEntityDamage(target, final_damage, source);
}

void addRadialForceEntity(vector location, float force, float radius, entity target, entity source, float power = 1.0f)
{
	vector center = target.origin + ('0 0 1' * (target.maxs_z - target.mins_z) * 0.5);
	float distance = vlen(center - location);
	if (distance > radius)
		return;

	float multiplier = (radius-distance) / distance;
	if (multiplier <= 0.0f)
		return;
	else if (multiplier > 1.0f)
		multiplier = 1.0f;

	if (power != 1.0f)
		multiplier = pow(multiplier, power);

	vector direction = center - location;
	direction = normalize(direction);

	applyEntityForce(target, direction * force * multiplier, source);
}

void addRadialDamage(vector location, float damage, float radius, entity source = 0, entity ignored = 0, float power = 1.0f, float damage_min = 0.0f)
{
	entity ent;
	ent = findradius(location, radius);
	while (ent != world)
	{
		if (ent != ignored && ent != source && ent.movetype != MOVETYPE_NONE)
			addRadialDamageEntity(location, damage, radius, ent, source, power, damage_min);
		ent = ent.chain;
	}
}

void addRadialForce(vector location, float force, float radius, entity source = 0, entity ignored = 0, float power = 1.0f)
{
	entity ent;
	ent = findradius(location, radius);
	while (ent != world)
	{
		if (ent != ignored && ent != source && ent.movetype != MOVETYPE_NONE)
			addRadialForceEntity(location, force, radius, ent, source, power);
		ent = ent.chain;
	}
}
