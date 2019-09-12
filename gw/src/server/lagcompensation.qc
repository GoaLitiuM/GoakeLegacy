struct entity_lagged_state
{
	vector origin;
	vector origin_last; // latest origin is stored here during the tracing
};

struct entity_lagged_frame
{
	entity_lagged_state* player_states;
};

// frames are stored in a circular buffer, oldest data gets overwritten by latest data
entity_lagged_frame* lagged_frames;
int lagged_frames_count;
entity* lagged_entities;
int lagged_entities_count;
int lagged_next_frame; // frame which will receive the next snapshot

void LagCompensate_AddPlayerIndex(entity ent, int index)
{
	lagged_entities[index] = ent;

	// clear previous frame data
	for (int i=0; i<lagged_frames_count; i++)
		lagged_frames[i].player_states[index].origin = ent.origin;
}

// start tracking the player entity
void LagCompensate_AddPlayer(entity ent)
{
	if (ent == world)
		return;

	for (int i=0; i<lagged_entities_count; i++)
	{
		if (lagged_entities[i] != world)
			continue;

		LagCompensate_AddPlayerIndex(ent, i);
		return;
	}

	error("LagCompensate_AddPlayer failed");
}

void LagCompensate_RemovePlayerIndex(int index)
{
	lagged_entities[index] = world;
}

void LagCompensate_RemovePlayer(entity ent)
{
	for (int i=0; i<lagged_entities_count; i++)
	{
		if (lagged_entities[i] != ent)
			continue;

		LagCompensate_RemovePlayerIndex(i);
		return;
	}

	error("LagCompensate_RemovePlayer failed");
}

void LagCompensate_NextFrame()
{
	if (lagged_frames_count <= 0)
		return;

	lagged_next_frame++;
	lagged_next_frame = lagged_next_frame % lagged_frames_count;
}

void LagCompensate_Snapshot()
{
	int maxplayers = (int)serverkeyfloat("sv_maxclients", 1);
	if (maxplayers > lagged_entities_count) // growth only array due to players sticking around after maxclients changes
	{
		entity* old_lagged_entities = lagged_entities;
		int old_lagged_entities_count = lagged_entities_count;

		lagged_entities = memalloc(sizeof(entity) * maxplayers);
		lagged_entities_count = maxplayers;

		for (int i=0; i<lagged_entities_count; i++)
			lagged_entities[i] = world;

		if (old_lagged_entities_count > 0)
		{
			for (int i=0; i<old_lagged_entities_count; i++)
			{
				if (old_lagged_entities[i] != world)
					LagCompensate_AddPlayerIndex(old_lagged_entities[i], i);
			}

			for (int i=0; i<lagged_frames_count; i++)
			{
				// TODO: preserve old frame data
				memfree(lagged_frames[i].player_states);
				lagged_frames[i].player_states = memalloc(sizeof(entity_lagged_state) * lagged_entities_count);
				for (int j=0; j<lagged_entities_count; j++)
					lagged_frames[i].player_states[j].origin = lagged_entities[j].origin;
			}

			memfree(old_lagged_entities);
			old_lagged_entities_count = 0;
		}
	}

	int maxping = cvar("sv_lagcompensate_maxping");
	int lagcompensate = cvar("sv_lagcompensate");
	if (lagcompensate == 0 || maxping <= 0)
		return;

	int maxframes = floor(maxping*0.001f*maxfps);
	if (maxframes > 1024)
	{
		println("LagCompensate_Snapshot: tried to allocate too many frames: ", itos(maxframes));
		maxframes = 1024;
	}

	if (maxframes != lagged_frames_count)
	{
		// TODO: preserve old frame data
		if (lagged_frames_count > 0)
		{
			for (int i=0; i<lagged_frames_count; i++)
				memfree(lagged_frames[i].player_states);
			memfree(lagged_frames);
			lagged_frames_count = 0;
		}

		if (maxframes > 0)
		{
			lagged_frames = memalloc(sizeof(entity_lagged_frame) * maxframes);
			lagged_frames_count = maxframes;

			for (int i=0; i<lagged_frames_count; i++)
			{
				lagged_frames[i].player_states = memalloc(sizeof(entity_lagged_state) * lagged_entities_count);
				for (int j=0; j<lagged_entities_count; j++)
					lagged_frames[i].player_states[j].origin = lagged_entities[j].origin;
			}
		}

		// since we are not preserving the old data, reset this pointer
		lagged_next_frame = 0;
	}

	entity_lagged_frame* lagged_frame = &lagged_frames[lagged_next_frame];
	for (int i=0; i<lagged_entities_count; i++)
	{
		entity ent = lagged_entities[i];
		if (ent == world)
			continue;

		entity_lagged_state* lagged_state = &lagged_frame.player_states[i];
		lagged_state->origin = ent.origin;
	}

	LagCompensate_NextFrame();
}

// traceline with reconciliation support, ent is the player
void traceline_lagged(vector v1, vector v2, float flags, entity ent)
{
	if (cvar("sv_lagcompensate") == 0)
	{
		traceline(v1, v2, flags, ent);
		return;
	}

	int backtrack_frames = floor(infokeyf(ent, "ping")*0.001f*maxfps);
	if (backtrack_frames > lagged_frames_count)
		backtrack_frames = lagged_frames_count; // prevent wrapping around the buffer
	else if (backtrack_frames == 0)
	{
		// no latency, just run the regular trace instead
		traceline(v1, v2, flags, ent);
		return;
	}

	int client_frame = lagged_next_frame - backtrack_frames;
	if (client_frame < 0)
		client_frame += lagged_frames_count;

	entity_lagged_frame* lagged_frame = &lagged_frames[client_frame];

	// move players back in time to the client's latest frame
	for (int i=0; i<lagged_entities_count; i++)
	{
		entity lagent = lagged_entities[i];
		if (lagent == world)
			continue;

		lagged_frame->player_states[i].origin_last = lagent.origin;
		if (ent == lagent)
			continue; // do not move the shooter

		lagent.origin = lagged_frame->player_states[i].origin;
		setorigin(lagent, lagent.origin);
	}

	// run the trace
	traceline(v1, v2, flags, ent);

	// restore old state
	for (int i=0; i<lagged_entities_count; i++)
	{
		entity lagent = lagged_entities[i];
		if (lagent == world)
			continue;

		lagent.origin = lagged_frame->player_states[i].origin_last;
		setorigin(lagent, lagent.origin);
	}
}