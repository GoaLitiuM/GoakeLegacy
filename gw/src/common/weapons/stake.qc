
void WeaponStake_StakeOnTouch();

void WeaponStake_SpawnStake(vector pos, vector dir, entity player)
{
	entity stake = spawn();
	stake.owner = player;

	stake.movetype = MOVETYPE_TOSS;
	stake.solid = SOLID_SLIDEBOX;
	stake.classname = CLASS_ARROW;
	stake.velocity = dir * STAKE_SPEED;
	stake.angles = vectoangles(dir);
	stake.touch = WeaponStake_StakeOnTouch;

	stake.effects |= EF_NOSHADOW | EF_FULLBRIGHT;
	stake.colormod = COLOR(160, 124, 0);

	stake.origin = pos;
	setorigin(stake, pos);

#ifdef CSQC
	stake.drawmask = MASK_ENGINE;
	stake.forceshader = shaderforname("stakeshader", "{\nprogram defaultsprite\ndiffusemap \"$whiteimage\"\n}");
#endif

	setmodel(stake, MDL_ARROW);
	setsize(stake, VEC_ORIGIN, VEC_ORIGIN);
}

void WeaponStake_StakeDestroy()
{
	self.model = 0;
	self.solid = SOLID_NOT;
	remove(self);
}

int WeaponStake_Fire(vector forward)
{
	vector offset = self.view_ofs;

	clientsound(self, CHAN_WEAPON, SND_WEAPON_STAKE, 1, ATTN_NORM, 0, SOUNDFLAG_FOLLOW);

	WeaponStake_SpawnStake(((self.origin + (forward * 16)) + offset), forward, self);

	return 1;
}

void WeaponStake_StakeOnTouch()
{
	//TODO: remove after 30 seconds or so
	if (other == self.owner)
		return;
	else if (other.solid == SOLID_CORPSE)
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

	if (other.classname == CLASS_ARROW)
	{
		// allow projectiles to stack
	}
	else if (other != world)
	{
		//applyEntityForce(other, normalize(other.origin - position) * STAKE_FORCE, self);
		applyEntityForce(other, normalize(self.velocity) * STAKE_FORCE, self);
		applyEntityDamage(other, STAKE_DAMAGE, self);

		WeaponStake_StakeDestroy();
		return;
	}

	self.velocity = '0 0 0';
	self.movetype = MOVETYPE_NONE;
	self.geomtype = GEOMTYPE_BOX;
	self.solid = SOLID_BBOX;
	self.think = WeaponStake_StakeDestroy;
	self.nextthink = time + STAKE_STAY_TIME;
	self.owner = world;
	self.touch = 0;

	setsize(self, '-8 -8 -8', '8 8 8');

	//TODO: support surfaces which do not allow stakes to stick into (stake drops/vanishes instead)
}
