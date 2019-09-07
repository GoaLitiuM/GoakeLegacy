void WeaponRocket_SpawnRocket(vector pos, vector dir, entity player);

int WeaponRocket_Fire()
{
	local vector forward = getForwardVector(getViewAngles());
	local vector offset = self.view_ofs;

	clientsound(self, CHAN_WEAPON, SND_WEAPON_ROCKET, true, ATTN_NORM, 0, SOUNDFLAG_FOLLOW);

	WeaponRocket_SpawnRocket(((self.origin + (forward * 16)) + offset), forward, self);

	Player_WeaponReload(ROCKET_RELOAD);

	return 1;
}

void WeaponRocket_ProjectileExplosionTick()
{
	if (self.frame >= 5)
	{
		remove(self);
		return;
	}
	self.frame += 0.5;
	self.nextthink = time + 0.05;
}

void WeaponRocket_ProjectileExplode(string model)
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

void WeaponRocket_RocketOnTouch()
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
	{
		local vector dir = normalize(other.origin - self.origin);
		other.velocity += dir * force;
	}

	addRadialForce(self.origin, force, radius, other);

	self.origin = (self.origin - (18 * normalize(self.velocity)));

#ifdef SSQC
	writeByte(MSG_BROADCAST, SVC_TEMPENTITY);
	writeByte(MSG_BROADCAST, TE_EXPLOSION);
	writeVector(MSG_BROADCAST, self.origin);
#endif

	WeaponRocket_ProjectileExplode(SPR_EXPLOSION);
}

void WeaponRocket_SpawnRocket(vector pos, vector dir, entity player)
{
	local entity missile;

	missile = spawn();
	missile.owner = player;
	missile.movetype = MOVETYPE_FLYMISSILE;
	missile.solid = SOLID_BBOX;
	missile.classname = "missile";
	missile.velocity = dir * ROCKET_SPEED;
	missile.angles = vectoangles(dir);
	missile.touch = WeaponRocket_RocketOnTouch;
	missile.nextthink = (time + MOVETYPE_FLY);
	missile.effects |= EF_NOSHADOW | EF_FULLBRIGHT;
	setmodel(missile, MDL_ROCKET);
	setsize(missile, VEC_ORIGIN, VEC_ORIGIN);
	setorigin(missile, pos);

#ifdef CSQC
	missile.drawmask = MASK_ENGINE;
#endif
}
