// deltaframe is the client frame when a predictable event occured
// of which effects should be applied to predicted frames
// until the corrected frame is received from the server.
int deltaframe;
int lastframe;
vector origin_delta;
vector vel_delta;
vector angles_delta;
vector view_angles_delta;

void PlayerPrediction_RunPhysics(int startframe, int endframe, bool apply_deltas)
{
	// run player physics simulation for all the frames
	for (int i = startframe; i <= endframe; i++)
	{
		if (!getinputstate(i))
			continue;

		if (input_timelength == 0)
			break;

		// apply pending clientside changes here for the frame when it happened
		if (i == deltaframe && apply_deltas)
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
	bool fullpred = cvar("cl_fullpred") != 0;

	/*if (lastframe > 0)
	{
		self.flags = self.client_flags;
		self.pmove_flags = self.client_pmove_flags;
		self.jump_count = self.client_jump_count;
		self.jump_time = self.client_jump_time;
	}*/

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
		vector prev_origin = self.origin;
		vector prev_velocity = self.velocity;
		vector prev_angles = self.angles;

		Player_PostTick();

		// detect entity state changes during a client tick
		vector origin_diff = self.origin - prev_origin;
		vector vel_diff = self.velocity - prev_velocity;
		vector angle_diff = self.angles - prev_angles;
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
	origin_delta = '0 0 0';
	vel_delta = '0 0 0';
	angles_delta = '0 0 0';
	view_angles_delta = view_angles;

	self.current_origin = self.origin;
	self.current_velocity = self.velocity;
	self.current_angles = self.angles;
	self.current_flags = self.flags;
	self.current_pmove_flags = self.pmove_flags;
	self.current_jump_time = self.jump_time;
	self.current_jump_count = self.jump_count;

	lastframe = 0;
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

void PlayerPrediction_ApplyClientState()
{
	self.origin = self.client_origin;
	setorigin(self, self.origin);
	self.velocity = self.client_velocity;
	self.angles = self.client_angles;
	self.flags = self.client_flags;
	self.pmove_flags = self.client_pmove_flags;
	self.jump_time = self.client_jump_time;
	self.jump_count = self.client_jump_count;
}

void PlayerPrediction()
{
	// detect client-changes to the player entity's state caused by other entities
	vector origin_diff = self.origin - self.current_origin;
	vector vel_diff = self.velocity - self.current_velocity;
	vector angle_diff = self.angles - self.current_angles;
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

	// reset prediction when we receive the correct frame
	bool skip_stat_prediction = false;
	if (deltaframe > 0 && servercommandframe >= deltaframe)
	{
		PlayerPrediction_Reset();
		skip_stat_prediction = true;
	}
	if (self.health <= 0)
		skip_stat_prediction = true;

	UpdatePlayerStats(self, skip_stat_prediction);
	UpdateGlobalStats(true);

	int currentframe = clientcommandframe;

	// find the latest complete frame, low framerate client might skip some frames
	for (int i = clientcommandframe; i >= servercommandframe + 1; i--)
	{
		if (!getinputstate(i) || input_timelength == 0)
			continue;

		currentframe = i;
		break;
	}

	if (isdemo())
	{
		PlayerPrediction_ApplyServerState();
		currentframe = servercommandframe + 1;
	}
	else
	{
		bool pred_error = false;
		if (self.playerserverframe != servercommandframe)
		{
			// detect prediction errors by comparing against previously predicted server frame
			if (vlen(self.server_origin - self.server_pred_origin) > 0 ||
				vlen(self.server_velocity - self.server_pred_velocity) > 0 ||
				vlen(self.server_angles - self.server_pred_angles) > 0)
			{
				pred_error = true;
			}

			// predict next server frame for error detection
			PlayerPrediction_ApplyServerState();
			PlayerPrediction_RunPhysics(servercommandframe + 1, servercommandframe + 1, false);
			self.server_pred_origin = self.origin;
			self.server_pred_velocity = self.velocity;
			self.server_pred_angles = self.angles;

			self.playerserverframe = servercommandframe;
		}

		if (self.playerclientframe != currentframe || pred_error)
		{
			if (pred_error)
			{
				// prediction errors were detected, we need to simulate all frames after latest server frame again
				PlayerPrediction_ApplyServerState();
				self.playerclientframe = servercommandframe + 1;
				// TODO: apply catchup gradually to spread physics calculations along multiple frames to avoid hitchups and to teleporting around
			}
			else
				PlayerPrediction_ApplyClientState();

			PlayerPrediction_RunPhysics(self.playerclientframe, currentframe-1, !pred_error);
			self.playerclientframe = currentframe;

			self.client_origin = self.origin;
			self.client_velocity = self.velocity;
			self.client_angles = self.angles;
			self.client_flags = self.flags;
			self.client_pmove_flags = self.pmove_flags;
			self.client_jump_time = self.jump_time;
			self.client_jump_count = self.jump_count;
		}
		else if (self.playerclientframe == currentframe)
			PlayerPrediction_ApplyClientState();
	}

	PlayerPrediction_RunPhysicsAndTick(currentframe);

	// store these so we can detect clientside changes for later frames
	self.current_origin = self.origin;
	self.current_velocity = self.velocity;
	self.current_angles = self.angles;

	lastframe = clientcommandframe;
}
