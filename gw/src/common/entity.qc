void applyEntityDamage(entity target, float damage, entity source)
{
	if (target.classname == "player")
	{
		local entity oldself = self;
		self = target;
		Player_TakeDamage(damage, source);
		self = oldself;
	}
}

void addRadialDamageEntity(vector location, float damage, float radius, entity target, entity source)
{
	local vector center = target.origin + ('0 0 1' * (target.maxs_z - target.mins_z) * 0.5);
	local float distance = vlen(center - location);
	if (distance > radius)
		return;

	local float multiplier = (radius-distance) / distance;
	if (multiplier <= 0.0f)
		return;
	else if (multiplier > 1.0f)
		multiplier = 1.0f;

	applyEntityDamage(target, damage * multiplier, source);
}

void addRadialForceEntity(vector location, float force, float radius, entity target)
{
	if (target.solid == SOLID_CORPSE)
		return;

	local vector center = target.origin + ('0 0 1' * (target.maxs_z - target.mins_z) * 0.5);
	local float distance = vlen(center - location);
	if (distance > radius)
		return;

	local float multiplier = (radius-distance) / distance;
	if (multiplier <= 0.0f)
		return;
	else if (multiplier > 1.0f)
		multiplier = 1.0f;

	local vector direction = center - location;
	direction = normalize(direction);

	// apply the force to entity's velocity
	target.velocity += direction * force * multiplier;
	target.SendFlags |= SENDFLAGS_VELOCITY;
}

void addRadialDamage(vector location, float damage, float radius, entity source = 0, entity ignored = 0)
{
	local entity ent;
	ent = findradius(location, radius);
	while (ent != world)
	{
		if (ent != ignored && ent != source)
			addRadialDamageEntity(location, damage, radius, ent, source);
		ent = ent.chain;
	}
}

void addRadialForce(vector location, float force, float radius, entity source = 0, entity ignored = 0)
{
	local entity ent;
	ent = findradius(location, radius);
	while (ent != world)
	{
		if (ent != ignored && ent != source)
			addRadialForceEntity(location, force, radius, ent);
		ent = ent.chain;
	}
}
