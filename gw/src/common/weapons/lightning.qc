void WeaponLightning_SpawnLightning(vector pos, vector dir, entity player);

int WeaponLightning_Fire(vector forward)
{
	//vector forward = getForwardVector(getViewAngles());
	vector offset = self.view_ofs;

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
	vector start = self.owner.origin;
	vector offset = self.owner.view_ofs;

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

	vector forward = getForwardVector(self.angles);
	traceline(start + offset, (start + offset) + forward * (LIGHTNING_RANGE), MOVE_EVERYTHING | MOVE_ENTCHAIN, self);
	vector hit_pos = trace_endpos + (trace_plane_normal * 16);
	bool hit_player = false;
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
		vector newangles = vectoangles(forward);
		self.angles_x = newangles_x;
		self.angles_y = newangles_y;
	}

	float distance = vlen(hit_pos - start);
	float segment_length = 30;
	int segments = floor(distance/segment_length)+1;

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
	entity oldself = self;
	self = world; // HACK: dynamiclight_add has only one dynamic light slot per entity, but world has no limits

	// we want the light to not be too close to the walls so we trace the beam towards the actual hit position
	// TODO: we should do the trace with tracebox but Q1BSP does not like small bounding boxes
	forward = normalize(hit_pos - start);

	float light = dynamiclight_add(start + forward * distance, 50, '3 3 3');
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

void WeaponLightning_CreateLightningBeam(vector start, vector end, entity player)
{
	start += PLAYER_OFFSET_EYES;

	// re-use the previous beam
	entity beam;
	if (player.beam_ent != world)
		beam = player.beam_ent;
	else
		beam = spawn();

	setmodel(beam, MDL_BEAM);

	beam.owner = player;
	beam.classname = CLASS_LIGHTNING;
	beam.solid = SOLID_NOT;
	beam.movetype = MOVETYPE_NONE;
	beam.origin = start;
	setorigin(beam, beam.origin);
	beam.angles = vectoangles(normalize(end-start));
	beam.think = WeaponLightning_BeamDestroy;
	beam.nextthink = time + LIGHTNING_RELOAD;

	beam.effects |= EF_NOSHADOW | EF_FULLBRIGHT;
	beam.alpha = 0.4;

	setsize(beam, VEC_ORIGIN, VEC_ORIGIN);

	// player updates its own beam
	beam.predraw = BeamUpdate;
	if (player != local_player)
		beam.drawmask = MASK_ENGINE;
	else
		player.beam_ent = beam;
}
#endif

void WeaponLightning_SpawnLightning(vector pos, vector dir, entity player)
{
	traceline_lagged(pos, pos + dir * LIGHTNING_RANGE, /*MOVE_EVERYTHING |*/ MOVE_ENTCHAIN, player);
	vector hit_pos = trace_endpos;
	bool hit_something = false;

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
	msg_entity = world;
	writeEvent(MSG_MULTICAST, EVENT_LIGHTNING);
	writeVector(MSG_MULTICAST, pos);
	writeVector(MSG_MULTICAST, hit_pos);
	WriteEntity(MSG_MULTICAST, player);
	multicast(hit_pos, MULTICAST_PVS);

	if (hit_something)
		te_lightningblood(hit_pos);
#endif
}
