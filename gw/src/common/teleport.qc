void TeleportOnTouch()
{
    if (other.classname != "player")
        return;

    local entity tele_target = find(world, targetname, self.target);
    if (!tele_target)
        return;

    local vector oo = other.origin;
    other.origin = tele_target.origin;
    setorigin(other, other.origin);

    local float speed = vlen(other.velocity);
    if (TELEPORT_MAX_VELOCITY > 0 && speed > TELEPORT_MAX_VELOCITY)
        speed = TELEPORT_MAX_VELOCITY;

    other.velocity = getForwardVector(tele_target.angles) * speed;
    other.velocity_z = 0;

    other.angles = tele_target.angles;
    setAngles(other, tele_target.angles, 3);

    other.flags = other.flags & ~FL_ONGROUND;
}
