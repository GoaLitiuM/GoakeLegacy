void TeleportOnTouch()
{
	if (other.classname != "player")
		return;

	local entity tele_target = find(world, targetname, self.target);
	if (!tele_target)
		return;

	local vector offset = '0 0 22';
	other.origin = tele_target.origin + offset;
	setorigin(other, other.origin);

	// try to snap the player to the floor
	tracebox(other.origin, other.mins, other.maxs, other.origin - offset*2, 1, other);
	other.origin = trace_endpos;
	setorigin(other, other.origin);

	local float speed = vlen(other.velocity);
	//if (TELEPORT_MAX_VELOCITY > 0 && speed > TELEPORT_MAX_VELOCITY)
		speed = TELEPORT_MAX_VELOCITY;

	other.velocity = getForwardVector(tele_target.angles) * speed;
	other.velocity_z = 0;

	other.angles = tele_target.angles;
	setAngles(other, tele_target.angles, 3);

	other.flags = other.flags & ~FL_ONGROUND;
}
