float PlayerPreDraw();
void PlayerPreTick();
void PlayerPostTick();
void PlayerPrediction();

void PlayerUpdate(bool isnew)
{
	if (isnew)
	{
		if (self.entnum == player_localentnum)
			local_player = self;

		self.classname = CLASS_PLAYER;
		self.solid = SOLID_SLIDEBOX;
		self.predraw = PlayerPreDraw;
		self.drawmask = MASK_ENGINE;
		setmodel(self, MDL_PLAYER);
	}

	self.server_origin = readVector();
	self.server_angles = readVector();
	self.server_velocity = readVector();
	self.server_flags = readFloat();
	self.server_pmove_flags = readFloat();
	self.server_jump_time = readFloat();
	self.server_jump_count = readFloat();

	if (isnew)
	{
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

		if (self.entnum == player_localentnum)
		{
			// server tried to fixangle player before it was spawned...
			self.fixangle = fixanglefix;
			fixanglefix = 0;
		}

		UpdatePlayerStats(true);
		PlayerInit();
	}

	setsize(self, VEC_HULL_MIN, VEC_HULL_MAX);
}

float PlayerPreDraw()
{
	UpdatePlayerStats();
	UpdateGlobalStats(); // this is probably not the best place to update global stats

	if (self.entnum == player_localentnum)
	{
		self.movetype = MOVETYPE_WALK;
		PlayerPrediction();
		self.movetype = MOVETYPE_NONE; // disable physics calculation for player

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

int deltaframe;
vector origin_delta;
vector vel_delta;
vector angles_delta;
vector view_angles_old;
void PlayerPrediction()
{
	bool fullpred = cvar("cl_fullpred") != 0;

	local vector oldOrigin = self.origin;
	local vector oldVelocity = self.velocity;
	local vector oldAngles = self.angles;
	local float oldFlags = self.flags;
	local float oldMoveFlags = self.pmove_flags;
	local float oldJumpTime = self.jump_time;
	local float oldJumpCount = self.jump_count;

	// detect changes to entity state here, player state may have been modified by other entity (projectile for example)
	local vector origin_diff = self.origin - self.client_origin;
	local vector vel_diff = self.velocity - self.client_velocity;
	local vector angle_diff = self.angles - self.client_angles;
	if (vlen(origin_diff) > 0 || vlen(vel_diff) > 0 || vlen(angle_diff) > 0)
	{
		deltaframe = clientcommandframe;
		origin_delta = origin_diff;
		vel_delta = vel_diff;
		angles_delta = angle_diff;
	}

	// rewind to the last known confirmed state
	self.origin = self.server_origin;
	self.velocity = self.server_velocity;
	self.angles = self.server_angles;
	self.flags = self.server_flags;
	self.pmove_flags = self.server_pmove_flags;
	self.jump_time = self.server_jump_time;
	self.jump_count = self.server_jump_count;
	setorigin(self, self.origin);

	// ignore server fixangle request if prediction handled it earlier
	if (servercommandframe == deltaframe)
	{
		view_angles = view_angles_old;
		self.fixangle = 0;
		origin_delta = '0 0 0';
		vel_delta = '0 0 0';
		angles_delta = '0 0 0';
	}

	if (self.fixangle != 0)
	{
		self.fixangle = 0;
		input_angles = self.angles;
		view_angles = self.angles;
	}

	if (cvar("cl_nopred") == 0)
	{
		local int startframe = servercommandframe + 1;
		local int endframe = clientcommandframe;

		// find the latest complete frame, low framerate client might skip some frames
		local int currentframe = startframe;
		for (int i = endframe; i >= startframe; i--)
		{
			if (!getinputstate(i))
				continue;

			if (input_timelength == 0)
				continue;

			currentframe = i;
			break;
		}

		local vector oldViewAngles = view_angles;

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
				self.origin += origin_delta;
				self.velocity += vel_delta;
				self.angles += angles_delta;
				//view_angles += view_angles_delta;
			}

			if (i == currentframe)
			{
				// restore some of the data from previous iterations
				self.flags = oldFlags;
				self.pmove_flags = oldMoveFlags;
				//self.angles = oldAngles;
				self.jump_time = oldJumpTime;
				self.jump_count = oldJumpCount;

				if (fullpred)
				{
					self.fixangle = 0;

					PlayerPreTick();

					if (self.fixangle != 0)
					{
						self.fixangle = 0;
						input_angles = self.angles;
						view_angles = self.angles;
					}
				}
			}

			PlayerCustomPhysics(self);
			setorigin(self, self.origin);

			// detect fixangle changes from teleports during player movement
			if (self.fixangle != 0)
			{
				self.fixangle = 0;
				input_angles = self.angles;
				if (i == currentframe)
				{
					view_angles = self.angles;
					deltaframe = currentframe;
				}
			}

			if (i == currentframe && fullpred)
				PlayerPostTick();
		}
	}

	// smooth out movement in stairs
	camera_origin_old = camera_origin;
	const float step_size = 18;
	const float step_smooth_units = 100;
	const float step_threshold = step_size * 2;
	float step_delta = self.origin_z - camera_origin_old_z;
	bool smooth_step = self.flags & FL_ONGROUND != 0 && step_delta > 0 && step_delta <= step_threshold;

	if (smooth_step)
	{
		camera_origin_old_z += frametime * step_smooth_units;

		if (camera_origin_old_z > self.origin_z)
			camera_origin_old_z = self.origin_z;

		if (self.origin_z - camera_origin_old_z > step_size)
			camera_origin_old_z = self.origin_z - step_size;

		camera_origin_z += camera_origin_old_z - self.origin_z;
	}
	else
		camera_origin_old_z = self.origin_z;

	camera_origin = self.origin;
	camera_origin_z = camera_origin_old_z;
	camera_velocity = self.velocity;

	addentity(self);

	setviewprop(VF_CL_VIEWANGLES, view_angles);
	view_angles_old = view_angles;

	self.client_origin = self.origin;
	self.client_velocity = self.velocity;
	self.client_angles = self.angles;
	self.client_flags = self.flags;
	self.client_pmove_flags = self.pmove_flags;
	self.client_jump_time = self.jump_time;
	self.client_jump_count = self.jump_count;
}
