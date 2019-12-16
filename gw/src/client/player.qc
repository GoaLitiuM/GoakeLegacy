float Player_PreDraw();
void Player_PreTick();
void Player_PostTick();
void PlayerPrediction();
void PlayerPrediction_ApplyServerState();
void PlayerPrediction_Reset();

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

		Player_InitModel();
	}

	setsize(self, VEC_HULL_MIN, VEC_HULL_MAX);
}

float Player_PreDraw()
{
	if (self.entnum == player_localentnum)
	{
		PlayerPrediction();

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
