.entity model_head;
.entity model_torso;
.entity model_legs;

float GetJumpOffset(float frame, float start_frame)
{
	switch (frame-start_frame)
	{
		case 0:
			return 8.0f;
		case 1:
			return 11.0f;

		case 2:
		case 7:
			return 13.0f;
		case 3:
		case 6:
			return 16.0f;
		case 4:
		case 5:
			return 18.0f;

		case 8:
			return 8.0f;
		case 9:
			return 3.0f;
	}
	return 0.0f;
}

void Model_SetPlayerModel(entity ent, string model)
{
	if (ent.model_legs == world)
	{
		ent.model_legs = spawn();
		ent.model_legs.owner = ent;
		ent.model_legs.solid = SOLID_NOT;
	}
	if (ent.model_torso == world)
	{
		ent.model_torso = spawn();
		ent.model_torso.owner = ent;
		ent.model_torso.solid = SOLID_NOT;
	}
	if (ent.model_head == world)
	{
		ent.model_head = spawn();
		ent.model_head.owner = ent;
		ent.model_head.solid = SOLID_NOT;
	}

	ent.anim_model_index = GetModel(model);
	ent.model_legs.anim_model_index = ent.anim_model_index;
	ent.model_torso.anim_model_index = ent.anim_model_index;
	ent.model_head.anim_model_index = ent.anim_model_index;

	string lower = strcat(model, "/lower.md3");
	string upper = strcat(model, "/upper.md3");
	string head = strcat(model, "/head.md3");

	string lower_skin = strcat(model, "/lower_color2.skin");
	string upper_skin = strcat(model, "/upper_color2.skin");
	string head_skin = strcat(model, "/head_color2.skin");

	setmodel(ent.model_legs, lower);
	loadcustomskin(lower_skin);
	setcustomskin(ent.model_legs, lower_skin);

	setmodel(ent.model_torso, upper);
	loadcustomskin(upper_skin);
	setcustomskin(ent.model_torso, upper_skin);

	setmodel(ent.model_head, head);
	loadcustomskin(head_skin);
	setcustomskin(ent.model_head, head_skin);

	setsize(ent.model_legs, '0 0 0', '0 0 0');
	setsize(ent.model_torso, '0 0 0', '0 0 0');
	setsize(ent.model_head, '0 0 0', '0 0 0');

	ent.model_torso.tag_index = gettagindex(ent.model_legs, "tag_torso");
	ent.model_head.tag_index = gettagindex(ent.model_torso, "tag_head");
}

void Player_InitModel()
{
	Model_SetPlayerModel(self, MDL_PLAYER);

	// ignore lighting
	self.model_legs.effects = EF_FULLBRIGHT;
	self.model_torso.effects = EF_FULLBRIGHT;
	self.model_head.effects = EF_FULLBRIGHT;

	// TODO: team colors
	vector forced_color = '1 1 1';
	if (self != local_player && cvar_string("cl_enemycolor") != "")
		forced_color = stov(cvar_string("cl_enemycolor"));

	self.model_legs.colormod = forced_color;
	self.model_torso.colormod = forced_color;
	self.model_head.colormod = forced_color;
}

void Player_Animate()
{
	entity legs = self.model_legs;
	entity torso = self.model_torso;
	entity head = self.model_head;

	if (legs == world || torso == world || head == world)
		return;

	vector playerpos = self.origin;
	entity player = self;

#if 0 // debugging, other players mimics the local player's animations
	player = findentity(world, entnum, player_localentnum);
	playerpos_z = player.origin_z;
#endif

	bool onground = (player.flags & FL_ONGROUND) != 0;
	float last_velocity = head.last_velocity_z;
	head.last_velocity_z = player.velocity_z;
	vector groundvel = [player.velocity_x, player.velocity_y, 0];
	float jumpvel = player.velocity_z;
	bool backing = false;

	// slowly turn legs towards player's movement/view direction
	{
		float legs_turnspeed = 720.0f * frametime;
		vector player_view_angle = getForwardVector(player.angles);
		vector new_angle = getForwardVector(legs.angles);

		vector target_angle;
		if (vlen(groundvel) > 0)
		{
			target_angle = normalize(groundvel);
			if (dotproduct(target_angle, player_view_angle) < -0.01f)
			{
				// running backwards, mirror the direction
				target_angle *= -1;
				backing = true;
			}

			// slightly bias towards forward direction to avoid legs turning backwards relative to torso
			new_angle = rotatevectovec(new_angle, player_view_angle, legs_turnspeed*0.01);
		}
		else
			target_angle = player_view_angle;

		new_angle = vectoangles(rotatevectovec(new_angle, target_angle, legs_turnspeed));
		legs.angles = [0, new_angle_y, 0];
		legs.origin = playerpos;
	}

	Model_Animate(legs);

	if (onground)
	{
		if (vlen(groundvel) > 0)
		{
			// attempt to synchronize the animation with movement by speeding it up
			float speed = min(320.0f, vlen(groundvel)) / 240.0f;
			if (speed < 0.2)
				speed = 0.2;

			if (backing)
				Model_PlayAnimation(legs, LEGS_BACK, speed, 0);
			else
				Model_PlayAnimation(legs, LEGS_RUN, speed, 0);
		}
		else if (onground && last_velocity < -120)
			Model_PlayAnimation(legs, LEGS_LANDB, 1, 1);
		else
		{
			if (legs.anim_index == LEGS_BACK || legs.anim_index == LEGS_RUN)
				Model_PlayAnimation(legs, LEGS_IDLE, 1, 0);
			else
				Model_PlayAnimationNext(legs, LEGS_IDLE, 1, 0);
		}
	}
	else
	{
		if (last_velocity <= 0 && jumpvel > 0)
			Model_PlayAnimation(legs, LEGS_JUMP, 1.0, 1);
	}

	{
		// a hack to root the jumping animation in place
		int start_frame = models[legs.anim_model_index]->animations[LEGS_JUMP].startframe;
		float frame_offset = GetJumpOffset(legs.frame, start_frame);
		float frame2_offset = GetJumpOffset(legs.frame2, start_frame);
		legs.origin_z -= lerp(frame_offset, frame2_offset, legs.lerpfrac);
	}


	torso.origin = rotatevectorsbytag2(legs.angles, legs, torso.tag_index);
	torso.angles_y = player.angles_y;
	torso.angles_x = player.angles_x*1.5; // torso follows the pitch angles

	Model_Animate(torso);

	bool melee_weapon = false;
	if (player.is_attacking)
		Model_PlayAnimation(torso, melee_weapon ? TORSO_ATTACK2 : TORSO_ATTACK, 1.0, 1);
	else
		Model_PlayAnimationNext(torso, melee_weapon ? TORSO_STAND2 : TORSO_STAND, 1.0, 0);


	head.origin = rotatevectorsbytag2(torso.angles, torso, head.tag_index);
	head.angles_y = torso.angles_y;
	head.angles_x = player.angles_x*3; // head should bend more

	Model_Animate(head);

	setorigin(legs, legs.origin);
	setorigin(torso, torso.origin);
	setorigin(head, head.origin);

	legs.renderflags = self.renderflags;
	torso.renderflags = self.renderflags;
	head.renderflags = self.renderflags;

	addentity(legs);
	addentity(torso);
	addentity(head);

	self.is_attacking = false;
}