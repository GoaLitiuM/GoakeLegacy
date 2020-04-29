void applyEntityDamage(entity target, float damage, entity source)
{
	if (target.classname == CLASS_PLAYER)
	{
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
		entity oldself = self;
		self = target;
		Player_ApplyForce(force, source);
		self = oldself;
	}
}

void addRadialDamageEntity(vector location, float damage, float radius, entity target, entity source, float power = 1.0f)
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

	applyEntityDamage(target, damage * multiplier, source);
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

void addRadialDamage(vector location, float damage, float radius, entity source = 0, entity ignored = 0, float power = 1.0f)
{
	entity ent;
	ent = findradius(location, radius);
	while (ent != world)
	{
		if (ent != ignored && ent != source && ent.movetype != MOVETYPE_NONE)
			addRadialDamageEntity(location, damage, radius, ent, source, power);
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
