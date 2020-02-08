void Teleport_OnTouch();

void trigger_teleport()
{
	self.touch = Teleport_OnTouch;
	self.solid = SOLID_TRIGGER;
	setmodel (self, self.model);
	self.movetype = MOVETYPE_NONE;
	self.modelindex = 0;
	self.model = "";
}
void info_teleport_destination()
{
}
void misc_teleporter_dest() // Q3 compatibility
{
}

void Teleport_OnTouch()
{
	if (other.classname != CLASS_PLAYER)
		return;

	entity tele_target = find(world, targetname, self.target);
	if (!tele_target)
		return;

	vector offset = '0 0 24';
	other.origin = tele_target.origin + offset;
	setorigin(other, other.origin);

	// try to snap the player to the floor
	tracebox(other.origin, other.mins, other.maxs, other.origin - offset*2, 1, other);
	other.origin = trace_endpos;
	setorigin(other, other.origin);

	float speed = vlen(other.velocity);
	//if (TELEPORT_MAX_VELOCITY > 0 && speed > TELEPORT_MAX_VELOCITY)
		speed = TELEPORT_MAX_VELOCITY;

	other.velocity = getForwardVector(tele_target.angles) * speed;
	other.velocity_z = 0;

	other.angles = tele_target.angles;
	setAngles(other, tele_target.angles, 3);

	other.flags = other.flags & ~FL_ONGROUND;
}
