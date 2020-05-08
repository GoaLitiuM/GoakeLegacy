float Player_PreDraw();
void Player_PreTick();
void Player_PostTick();
void PlayerPrediction();
void PlayerPrediction_ApplyServerState();
void PlayerPrediction_Reset();

void Player_Update(bool isnew)
{
	float server_solid = self.solid;
	float server_movetype = self.movetype;

	int send_flags = readInt();
	if (send_flags & SENDFLAGS_ORIGIN)
		self.server_origin = readVector();
	if (send_flags & SENDFLAGS_ANGLES)
		self.server_angles = readVector();
	if (send_flags & SENDFLAGS_VELOCITY)
		self.server_velocity = readVector();
	if (send_flags & SENDFLAGS_FLAGS)
	{
		self.server_flags = readInt();
		self.server_pmove_flags = readByte();
	}
	if (send_flags & SENDFLAGS_JUMP)
	{
		self.server_jump_time = readFloat();
		self.server_jump_count = readFloat();
	}

	if (send_flags & SENDFLAGS_PHYSICS)
	{
		server_solid = readFloat();
		server_movetype = readFloat();
	}
	if (isnew)
	{
		self.server_pred_origin = self.origin;
		self.server_pred_velocity = self.velocity;
		self.server_pred_angles = self.angles;

		self.playerclientframe = servercommandframe;
		self.playerserverframe = servercommandframe;

		send_flags |= SENDFLAGS_PLAYER_INIT; // just to make sure the player is reinitialized properly

		self.predraw = Player_PreDraw;
		self.drawmask = MASK_ENGINE;
		self.customphysics = noop;

		Player_InitModel();
	}

	if (send_flags & SENDFLAGS_PLAYER_INIT)
	{
		Player_Init();

		PlayerPrediction_ApplyServerState();
		PlayerPrediction_Reset();

		UpdatePlayerStats(self, true);
		UpdateGlobalStats(true);

		if (isnew && self.entnum == player_localentnum)
		{
			local_player = self;

			// server tried to fixangle player before it was spawned...
			self.fixangle = fixanglefix;
			fixanglefix = 0;

			camera_origin = self.origin + self.view_ofs;
		}
	}
	if (send_flags & SENDFLAGS_PHYSICS)
	{
		self.solid = server_solid;
		self.movetype = server_movetype;
	}

	self.server_time = time; // cltime?
}

void Player_UpdateCamera()
{
	entity target = self;
	camera_origin_old = camera_origin - target.view_ofs;

	// smooth out movement after stepping up
	const float step_size = serverkeyfloat("pm_stepheight", 18);
	const float step_smooth_units = 160;
	const float step_delta = target.origin_z - camera_origin_old_z;
	float step_z = camera_origin_old_z;

	if (target.flags & FL_ONGROUND != 0 && step_delta > 0 && step_delta <= step_size * 2)
	{
		// smoothing needs to be faster on slopes, otherwise it would look like player slightly sinks into the slope
		tracebox(target.current_origin, target.mins, target.maxs, target.current_origin + target.current_velocity * frametime, false, target);
		float d = -dotproduct(global_gravitydir, trace_plane_normal);

		float smoothing = step_smooth_units;
		if (d < 0.97 && d != 0)
			smoothing = step_smooth_units * 3;

		step_z += frametime * smoothing;
		step_z = min(step_z, target.origin_z);
	}
	else
		step_z = target.origin_z;

	camera_origin = [target.origin_x, target.origin_y, step_z] + target.view_ofs;
	camera_velocity = target.velocity;

	setviewprop(VF_CL_VIEWANGLES, view_angles);
}

float Player_PreDraw()
{
	if (self.entnum == player_localentnum)
	{
		if (Player_IsSpectator(self))
		{
			PlayerPrediction_ApplyServerState();
			Player_UpdateCamera();
			return PREDRAW_NEXT;
		}

		bool prediction = cvar("cl_nopred") == 0;
		if (prediction)
			PlayerPrediction();
		else
		{
			PlayerPrediction_ApplyServerState();
			UpdatePlayerStats(self, true);
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
		Player_Animate();
	}
	else
	{
		PlayerPrediction_ApplyServerState();

		// extrapolate
		float delta = time - self.server_time;

		self.origin = self.origin + (self.velocity*delta);
		self.angles = self.angles + (self.avelocity*delta);
		setorigin(self, self.origin);

		Player_Animate();
	}

	return PREDRAW_AUTOADD;
}
