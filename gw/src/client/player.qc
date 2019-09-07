float Player_PreDraw();
void Player_PreTick();
void Player_PostTick();
void PlayerPrediction();

void Player_Spawn()
{
	Player_Init();
}

void Player_Update(bool isnew)
{
	local float send_flags = readFloat();
	if (send_flags & SENDFLAGS_ORIGIN)
		self.server_origin = readVector();
	if (send_flags & SENDFLAGS_ANGLES)
		self.server_angles = readVector();
	if (send_flags & SENDFLAGS_VELOCITY)
		self.server_velocity = readVector();
	if (send_flags & SENDFLAGS_FLAGS)
	{
		self.server_flags = readFloat();
		self.server_pmove_flags = readFloat();
	}
	if (send_flags & SENDFLAGS_JUMP)
	{
		self.server_jump_time = readFloat();
		self.server_jump_count = readFloat();
	}

	if (isnew)
	{
		if (self.entnum == player_localentnum)
		{
			local_player = self;

			// server tried to fixangle player before it was spawned...
			self.fixangle = fixanglefix;
			fixanglefix = 0;
		}

		// reset values for prediction
		self.origin = self.server_origin;
		self.velocity = self.server_velocity;
		self.angles = self.server_angles;
		self.flags = self.server_flags;
		self.pmove_flags = self.server_pmove_flags;
		self.jump_time = self.server_jump_time;
		self.jump_count = self.server_jump_count;
		setorigin(self, self.origin);

		self.client_origin = self.origin;
		self.client_velocity = self.velocity;
		self.client_angles = self.angles;
		self.client_flags = self.flags;
		self.client_pmove_flags = self.pmove_flags;
		self.client_jump_time = self.jump_time;
		self.client_jump_count = self.jump_count;

		UpdatePlayerStats(true);
		Player_Init();

		self.predraw = Player_PreDraw;
		self.drawmask = MASK_ENGINE;
		self.customphysics = noop;
	}

	setsize(self, VEC_HULL_MIN, VEC_HULL_MAX);
}

float Player_PreDraw()
{
	if (self.entnum == player_localentnum)
	{
		PlayerPrediction();

		if (self.beam_ent != world)
		{
			local entity oldself = self;
			self = self.beam_ent;
			if (self.predraw)
				self.predraw();
			self = oldself;
		}

		self.renderflags = RF_EXTERNALMODEL;
		return PREDRAW_NEXT;
	}
	else
	{
		self.movetype = MOVETYPE_NONE;
		self.origin = self.server_origin;
		self.velocity = self.server_velocity;
		self.angles = self.server_angles;
		self.flags = self.server_flags;
		self.pmove_flags = self.server_pmove_flags;
		self.jump_time = self.server_jump_time;
		self.jump_count = self.server_jump_count;
		setorigin(self, self.origin);
		return PREDRAW_AUTOADD;
	}
}

// deltaframe is the client frame when a predictable event occured
// of which effects should be applied to predicted frames
// until the corrected frame is received from the server.
int deltaframe;
int lastframe;
vector origin_delta;
vector vel_delta;
vector angles_delta;
vector view_angles_delta;

void PlayerPrediction_RunPhysics(int startframe, int endframe)
{
	// run player physics simulation for all the frames
	for (int i = startframe; i <= endframe; i++)
	{
		if (!getinputstate(i))
			continue;

		if (input_timelength == 0)
			break;

		// apply pending clientside changes here for the frame when it happened
		if (i == deltaframe)
		{
			self.origin = origin_delta;
			self.velocity = vel_delta;
			self.angles += angles_delta;
			setorigin(self, self.origin);
		}

		Player_Physics();
		setorigin(self, self.origin);

		// detect fixangle changes from teleports during player movement
		if (self.fixangle != 0)
		{
			self.fixangle = 0;
			input_angles = self.angles;
		}
	}
}

void PlayerPrediction_RunPhysicsAndTick(int frame)
{
	local bool fullpred = cvar("cl_fullpred") != 0;

	if (!getinputstate(frame) || input_timelength == 0)
		return;

	if (frame == deltaframe)
	{
		self.origin = origin_delta;
		self.velocity = vel_delta;
		self.angles += angles_delta;
		setorigin(self, self.origin);
	}

	if (fullpred)
	{
		self.fixangle = 0;

		Player_PreTick();

		if (self.fixangle != 0)
		{
			self.fixangle = 0;
			input_angles = self.angles;
			view_angles = self.angles;
		}
	}

	Player_Physics();
	setorigin(self, self.origin);

	// detect fixangle changes from teleports during player movement
	if (self.fixangle != 0)
	{
		self.fixangle = 0;
		input_angles = self.angles;

		// apply fixangle to view and mark the delta down
		view_angles = self.angles;

		deltaframe = frame+1;
		origin_delta = self.origin;
		vel_delta = self.velocity;
		view_angles_delta = self.angles;
	}

	if (fullpred)
	{
		local vector prev_origin = self.origin;
		local vector prev_velocity = self.velocity;
		local vector prev_angles = self.angles;

		Player_PostTick();

		// detect entity state changes during a client tick
		local vector origin_diff = self.origin - prev_origin;
		local vector vel_diff = self.velocity - prev_velocity;
		local vector angle_diff = self.angles - prev_angles;
		if (vlen(origin_diff) > 0 || vlen(vel_diff) > 0 || vlen(angle_diff) > 0)
		{
			deltaframe = frame;
			origin_delta = self.origin;
			vel_delta = self.velocity;
			angles_delta = angle_diff;
			view_angles_delta = view_angles;
		}
	}
}

void PlayerPrediction_Reset()
{
	deltaframe = 0;
	self.fixangle = 0;
	origin_delta = '0 0 0';
	vel_delta = '0 0 0';
	angles_delta = '0 0 0';
	view_angles_delta = view_angles;
}

void PlayerPrediction_UpdateCamera()
{
	camera_origin_old = camera_origin - self.view_ofs;

	// smooth out movement after stepping up
	const float step_size = serverkeyfloat("pm_stepheight", 18);
	const float step_smooth_units = 160;
	local float step_z = camera_origin_old_z;
	local float step_delta = self.origin_z - camera_origin_old_z;

	if (self.flags & FL_ONGROUND != 0 && step_delta > 0 && step_delta <= step_size * 2)
	{
		// smoothing needs to be faster on slopes, otherwise it would look like player slightly sinks into the slope
		tracebox(self.client_origin, self.mins, self.maxs, self.client_origin + self.client_velocity * frametime, false, self);
		local float d = -dotproduct(global_gravitydir, trace_plane_normal);

		local float smoothing = step_smooth_units;
		if (d < 0.97 && d != 0)
			smoothing = step_smooth_units * 3;

		step_z += frametime * smoothing;
		step_z = min(step_z, self.origin_z);
	}
	else
		step_z = self.origin_z;

	camera_origin = [self.origin_x, self.origin_y, step_z] + self.view_ofs;
	camera_velocity = self.velocity;

	setviewprop(VF_CL_VIEWANGLES, view_angles);
}

void PlayerPrediction_ApplyServerState()
{
	self.origin = self.server_origin;
	setorigin(self, self.origin);
	self.velocity = self.server_velocity;
	self.angles = self.server_angles;
	self.flags = self.server_flags;
	self.pmove_flags = self.server_pmove_flags;
	self.jump_time = self.server_jump_time;
	self.jump_count = self.server_jump_count;
}

void PlayerPrediction()
{
	local bool prediction = cvar("cl_nopred") == 0;
	local bool predict_stats = prediction;

	// detect client-local changes to the player entity's state caused by other entities
	local vector origin_diff = self.origin - self.client_origin;
	local vector vel_diff = self.velocity - self.client_velocity;
	local vector angle_diff = self.angles - self.client_angles;
	if (vlen(origin_diff) > 0 || vlen(vel_diff) > 0 || vlen(angle_diff) > 0)
	{
		deltaframe = lastframe;
		origin_delta = self.origin;
		vel_delta = self.velocity;
		angles_delta = angle_diff;
		view_angles_delta = view_angles;
	}

	if (self.fixangle != 0)
	{
		self.fixangle = 0;
		input_angles = self.server_angles;

		// view angles shouldn't be adjusted from delta values when player respawns
		if (deltaframe > 0)
			view_angles = self.server_angles + (view_angles - view_angles_delta);
		else
			view_angles = self.server_angles;
	}

	// rewind to the last known confirmed state
	PlayerPrediction_ApplyServerState();

	// reset prediction when we receive the correct frame
	if (deltaframe > 0 && servercommandframe >= deltaframe)
	{
		PlayerPrediction_Reset();
		predict_stats = false;
	}

	UpdatePlayerStats(!predict_stats);
	UpdateGlobalStats(!predict_stats);

	if (prediction)
	{
		local int currentframe = clientcommandframe;

		// find the latest complete frame, low framerate client might skip some frames
		for (int i = clientcommandframe; i >= servercommandframe + 1; i--)
		{
			if (!getinputstate(i) || input_timelength == 0)
				continue;

			currentframe = i;
			break;
		}

		// simulation starts after the last verified frame
		PlayerPrediction_RunPhysics(servercommandframe + 1, currentframe - 1);

		PlayerPrediction_RunPhysicsAndTick(currentframe);
	}

	PlayerPrediction_UpdateCamera();

	addentity(self);

	// store these so we can detect clientside changes for later frames
	self.client_origin = self.origin;
	self.client_velocity = self.velocity;
	self.client_angles = self.angles;
	self.client_flags = self.flags;
	self.client_pmove_flags = self.pmove_flags;
	self.client_jump_time = self.jump_time;
	self.client_jump_count = self.jump_count;

	lastframe = clientcommandframe;
}
