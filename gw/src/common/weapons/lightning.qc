void WeaponLightning_SpawnLightning(vector pos, vector dir, entity player);

int WeaponLightning_Fire(vector forward)
{
	//local vector forward = getForwardVector(getViewAngles());
	local vector offset = self.view_ofs;

	if (svtime - self.weapon_sound_loop_time > 0.5)
	{
		clientsound(self, CHAN_WEAPON, SND_WEAPON_LIGHTNING, 1, ATTN_NORM, 0, SOUNDFLAG_FOLLOW);
		self.weapon_sound_loop_time = svtime;
	}

	WeaponLightning_SpawnLightning(((self.origin + (forward * 16)) + offset), forward, self);

	return 1;
}

#ifdef CSQC
float BeamUpdate()
{
	// track the owner's position and aim
	local vector start = self.owner.origin;
	local vector offset = self.owner.view_ofs;

	if (self.owner == local_player)
	{
		//self.angles = view_angles;
		self.angles_x = view_angles_x;
		self.angles_y = view_angles_y;
	}
	else
	{
		// we don't know the exact aim angle of other players, so only update yaw from player model
		self.angles_y = self.owner.angles_y;
		//self.angles_z = self.owner.angles_z;
	}

	// rotation effect
	self.angles_z += 4444*frametime;

	local vector forward = getForwardVector(self.angles);
	traceline(start + offset, (start + offset) + forward * (LIGHTNING_RANGE), MOVE_EVERYTHING | MOVE_ENTCHAIN, self);
	local vector hit_pos = trace_endpos + (trace_plane_normal * 16);
	local bool hit_player = false;
	for (entity ent = trace_ent; ent != world; ent = ent.chain)
	{
		if (ent.classname == CLASS_PLAYER && ent != self.owner)
		{
			hit_player = true;
			break;
		}
	}

	if (self.owner == local_player)
	{
		// face the beam towards the hit location
		forward = normalize(trace_endpos - start);
		local vector newangles = vectoangles(forward);
		self.angles_x = newangles_x;
		self.angles_y = newangles_y;
	}

	local float distance = vlen(hit_pos - start);
	local float segment_length = 30;
	local int segments = floor(distance/segment_length)+1;

	// try to not blind the other player with our shaft
	if (hit_player)
		segments -= 2;

	if (segments < 1)
		segments = 1;

	for (int i=0; i<segments; i++)
	{
		self.origin = start + forward * segment_length * i;
		setorigin(self, self.origin);
		addentity(self);
	}

	// lights
	local entity oldself = self;
	self = world; // HACK: dynamiclight_add has only one dynamic light slot per entity, but world has no limits

	// we want the light to not be too close to the walls so we trace the beam towards the actual hit position
	// TODO: we should do the trace with tracebox but Q1BSP does not like small bounding boxes
	forward = normalize(hit_pos - start);

	local float light = dynamiclight_add(start + forward * distance, 50, '3 3 3');
	dynamiclight_set(light, LFIELD_FLAGS, dynamiclight_get(light, LFIELD_FLAGS) | LFLAG_NOSHADOWS);
	self = oldself;

	return PREDRAW_NEXT;
}

void WeaponLightning_BeamDestroy()
{
	if (self.owner.beam_ent == self)
		self.owner.beam_ent = world;

	remove(self);
}

void WeaponLightning_CreateLightningBeam()
{
	local entity parent = readEntity();
	local vector orig = readVector() - PLAYER_OFFSET_EYES;
	local vector end = readVector();

	// re-use the previous beam
	local entity beam;
	if (parent.beam_ent != world)
		beam = parent.beam_ent;
	else
		beam = spawn();

	setmodel(beam, MDL_BEAM);

	beam.owner = parent;
	beam.classname = CLASS_LIGHTNING;
	beam.solid = SOLID_NOT;
	beam.movetype = MOVETYPE_NONE;
	beam.origin = orig;
	setorigin(beam, beam.origin);
	beam.angles = vectoangles(normalize(end-orig));
	beam.think = WeaponLightning_BeamDestroy;
	beam.nextthink = time + LIGHTNING_RELOAD;

	beam.effects |= EF_NOSHADOW | EF_FULLBRIGHT;
	beam.alpha = 0.4;

	setsize(beam, VEC_ORIGIN, VEC_ORIGIN);

	// local player updates its own beam
	beam.predraw = BeamUpdate;
	if (parent != local_player)
		beam.drawmask = MASK_ENGINE;
	else
		parent.beam_ent = beam;
}
#endif

void WeaponLightning_SpawnLightning(vector pos, vector dir, entity player)
{
	traceline_lagged(pos, pos + dir * LIGHTNING_RANGE, /*MOVE_EVERYTHING |*/ MOVE_ENTCHAIN, player);
	local vector hit_pos = trace_endpos;
	local bool hit_something = false;

	for (entity ent = trace_ent; ent != world; ent = ent.chain)
	{
		if (ent.classname != CLASS_PLAYER)
			continue;

		applyEntityDamage(ent, LIGHTNING_DAMAGE, player);

		//hit_pos = ent.origin;
		hit_something = true;

		// apply force to the player
		ent.velocity = ent.velocity + (dir * LIGHTNING_FORCE);
		break;
	}

#ifdef SSQC
	writeEvent(MSG_MULTICAST, EVENT_LIGHTNING);
	WriteEntity(MSG_MULTICAST, player);
	writeVector(MSG_MULTICAST, pos);
	writeVector(MSG_MULTICAST, hit_pos);

	if (hit_something)
	{
		WriteByte (MSG_MULTICAST, SVC_TEMPENTITY);
		WriteByte (MSG_MULTICAST, TE_LIGHTNINGBLOOD);
		writeVector(MSG_MULTICAST, hit_pos);
	}
	multicast (hit_pos, MULTICAST_PVS);
#endif
}
