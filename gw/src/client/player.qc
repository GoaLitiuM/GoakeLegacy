float Player_PreDraw();
void Player_PreTick();
void Player_PostTick();
void PlayerPrediction();
void PlayerPrediction_ApplyServerState();
void PlayerPrediction_Reset();

void Player_Update(bool isnew)
{
	float send_flags = readFloat();
	if (send_flags & SENDFLAGS_PLAYER_EVENT_FLAGS)
		self.event_flags = readFloat();
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

			camera_origin = self.origin + self.view_ofs;
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

		Player_Init();
		self.event_flags &= PLAYER_EVENT_INIT;
		UpdatePlayerStats(true);
		UpdateGlobalStats(true);

		self.predraw = Player_PreDraw;
		self.drawmask = MASK_ENGINE;
		self.customphysics = noop;

		Player_InitModel();
	}

	if (self.event_flags & PLAYER_EVENT_INIT)
	{
		Player_Init();
		PlayerPrediction_ApplyServerState();
		PlayerPrediction_Reset();
		self.fixangle = 1;

		UpdatePlayerStats(true);
		UpdateGlobalStats(true);
	}

	self.event_flags = 0;
}

void Player_UpdateCamera()
{
	camera_origin_old = camera_origin - self.view_ofs;

	// smooth out movement after stepping up
	const float step_size = serverkeyfloat("pm_stepheight", 18);
	const float step_smooth_units = 160;
	const float step_delta = self.origin_z - camera_origin_old_z;
	float step_z = camera_origin_old_z;

	if (self.flags & FL_ONGROUND != 0 && step_delta > 0 && step_delta <= step_size * 2)
	{
		// smoothing needs to be faster on slopes, otherwise it would look like player slightly sinks into the slope
		tracebox(self.client_origin, self.mins, self.maxs, self.client_origin + self.client_velocity * frametime, false, self);
		float d = -dotproduct(global_gravitydir, trace_plane_normal);

		float smoothing = step_smooth_units;
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

float Player_PreDraw()
{
	if (self.entnum == player_localentnum)
	{
		bool prediction = cvar("cl_nopred") == 0;
		if (prediction)
			PlayerPrediction();
		else
		{
			PlayerPrediction_ApplyServerState();
			UpdatePlayerStats(true);
			UpdateGlobalStats(true);
		}

		Player_UpdateCamera();

		// draw attached beam entities (lightning gun)
		if (self.beam_ent != world)
		{
			entity oldself = self;
			self = self.beam_ent;
			if (self.predraw)
				self.predraw();
			self = oldself;
		}

		self.renderflags = RF_EXTERNALMODEL;
	}
	else
	{
		self.movetype = MOVETYPE_NONE;
		PlayerPrediction_ApplyServerState();
		Player_Animate();
	}

	return PREDRAW_AUTOADD;
}
