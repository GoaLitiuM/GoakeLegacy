void SpawnArrow(vector pos, vector dir, entity player);

void ArrowDestroy()
{
	self.model = 0;
	self.solid = SOLID_NOT;
	remove(self);
}

int WeaponCrossbowFire()
{
	local vector forward = getForwardVector(getViewAngles());
	local vector offset = self.view_ofs;

	clientsound(self, CHAN_WEAPON, SND_WEAPON_CROSSBOW, true, ATTN_NORM, 0, SOUNDFLAG_FOLLOW);

	SpawnArrow(((self.origin + (forward * 16)) + offset), forward, self);

	PlayerWeaponReload(CROSSBOW_RELOAD);

	return 1;
}

void ArrowOnTouch()
{
	//TODO: remove after 30 seconds or so
	if (other == self.owner)
		return;

	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		remove(self);
		return;
	}

#ifdef SSQC
	writeByte(MSG_BROADCAST, SVC_TEMPENTITY);
	writeByte(MSG_BROADCAST, TE_SUPERSPIKE);
	writeVector(MSG_BROADCAST, self.origin);
#endif

	local float damage = CROSSBOW_DAMAGE;
	local float force = CROSSBOW_FORCE;

	if (other.classname == CLASS_ARROW)
	{
		// allow projectiles to stack
	}
	else if (other != world)
	{
		local vector dir = normalize(self.velocity);
		other.velocity += dir * force;
		ArrowDestroy();
		return;
	}

	self.velocity = '0 0 0';
	self.movetype = MOVETYPE_NONE;
	self.geomtype = GEOMTYPE_BOX;
	self.solid = SOLID_BBOX;
	self.think = ArrowDestroy;
	self.nextthink = time + CROSSBOW_TIME;
	self.owner = world;
	self.touch = 0;

	setsize(self, '-8 -8 -8', '8 8 8');

	//TODO: support surfaces which do not allow arrows to stick into (arrow drops/vanishes instead)
}

void SpawnArrow(vector pos, vector dir, entity player)
{
	local entity arrow = spawn();
	arrow.owner = player;
	arrow.origin = pos;
	arrow.movetype = MOVETYPE_TOSS;
	arrow.solid = SOLID_BBOX;
	arrow.classname = CLASS_ARROW;
	arrow.velocity = (dir * CROSSBOW_SPEED);
	arrow.angles = vectoangles(dir);
	arrow.touch = ArrowOnTouch;

	arrow.effects |= EF_NOSHADOW | EF_FULLBRIGHT;
	setmodel(arrow, MDL_ARROW);

	setsize(arrow, VEC_ORIGIN, VEC_ORIGIN);

#ifdef CSQC
	arrow.drawmask = MASK_ENGINE;
#endif
}
