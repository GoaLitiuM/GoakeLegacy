void addRadialForceEntity(vector location, float force, float radius, entity target)
{
	if (target.solid == SOLID_CORPSE)
		return;

	local vector center = target.origin + ('0 0 1' * (target.maxs_z - target.mins_z) * 0.5);
	local float distance = vlen(center - location);
	if (distance > radius)
		return;

	local float multiplier = (radius-distance) / distance;
	if (multiplier < 0.0f)
		multiplier = 0.0f;
	else if (multiplier > 1.0f)
		multiplier = 1.0f;

	local vector direction = center - location;
	direction = normalize(direction);

	// apply the force to entity's velocity
	local vector addvel = (direction * force * multiplier);
	target.velocity = target.velocity + addvel;

	println(itos(vlen(addvel)), " tot: ", itos(vlen(target.velocity)));
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
