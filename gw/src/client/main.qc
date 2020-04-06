// all the CSQC entry functions should be placed here

void CSQC_Parse_Print(string printmsg, float printlvl)
{
	if (printlvl == 3) // PRINT_CHAT
		Chat_OnPrint(printmsg);
	else
		print(printmsg);
}

void CSQC_Init(float apilevel, string enginename, float engineversion)
{
	precache();

	Common_Init();
	Hud_Init();
	Item_InitClient();

	registercommand("+showscores");
	registercommand("-showscores");
}

float CSQC_ConsoleCommand(string cmd)
{
	cmd = strtolower(strtrim(cmd));
	string key = "";

	// commands may have the triggering key appended at the end, parse it
	if (str2chr(cmd, 0) == '+' || str2chr(cmd, 0) == '-')
	{
		int last_space = -1;
		while (true)
		{
			int ind = strstrofs(cmd, " ", last_space+1);
			if (ind == -1)
				break;

			last_space = ind;
		}
		if (last_space >= 0)
		{
			key = substring(cmd, last_space+1, strlen(cmd)-last_space-1);
			cmd = substring(cmd, 0, last_space);
		}
	}

	if (cmd == "+showscores")
		showscores = true;
	else if (cmd == "-showscores")
		showscores = false;
	return 0;
}

void CSQC_UpdateView(float width, float height, float notmenu)
{

	clearscene();

	setviewprop(VF_DRAWWORLD, 1);
	setviewprop(VF_DRAWCROSSHAIR, 0);

	addentities(MASK_ENGINE | MASK_VIEWMODEL);

	setviewprop(VF_ORIGIN, camera_origin);
	setviewprop(VF_ANGLES, view_angles);

	renderscene();

	Hud_Render(width, height, !notmenu);
}

void CSQC_Ent_Update(float isnew)
{
	float type = readByte();
	switch (type)
	{
		case SENDENTITY_PLAYER:
			Player_Update(isnew != 0);
			break;
		case SENDENTITY_ROCKET:
			WeaponRocket_Update(isnew != 0);
			break;
		case SENDENTITY_ITEM:
			Item_Update(isnew != 0);
			break;

		default:
			error(strcat("unknown entity type in CSQC_Ent_Update: ", ftos(type)));
	}
}

void CSQC_Ent_Remove()
{
	if (self.classname == CLASS_PLAYER)
		Player_Remove();
	else
		remove(self);
}

void CSQC_Parse_Event()
{
	float type = readByte();
	if (type == EVENT_LIGHTNING)
		WeaponLightning_CreateLightningBeam();
	else if (type == EVENT_PLAYER_ATTACK)
	{
		entity player = readEntity();
		player.is_attacking = true;
	}
}

float CSQC_Event_Sound(float entnum, float channel, string soundname, float vol, float attenuation, vector pos, float pitchmod, float flags)
{
	// this sound was predicted by local player, ignore it
	if ((flags & SOUNDFLAG_PREDICT) && cvar("cl_nopred") == 0 && cvar("cl_fullpred") != 0)
		return 1;
	return 0;
}

float CSQC_Parse_SetAngles(vector newangles, float wasdelta)
{
	if (self.entnum != local_player.entnum)
		self = local_player; // self entity is really inconsistent here

	if (self.entnum == 0)
		fixanglefix = 1; // player entity does not exist yet...
	else
		self.fixangle = 1;

	// prediction overrides fixangle requests
	return cvar("cl_nopred") == 0;
}

void CSQC_WorldLoaded()
{
	// populate CSQC world with entities found in the map file
	while (1)
	{
		string token = getentitytoken();
		if (token == "")
			break;
		else if (token != "{")
		{
			println("bad entity data");
			return;
		}

		entity ent = spawn();
		void() func = 0;
		bool valid = false;
		while (1)
		{
			string field = getentitytoken();
			if (!field)
				break;

			if (field == "}")
			{
				if (!ent.classname)
					break;
				if (func)
				{
					// items and weapons should not exist in CSQC world
					string class_name = strtolower(ent.classname);
					bool is_item = strstrofs(class_name, "weapon_") == 0 || strstrofs(class_name, "item_") == 0;
					if (!is_item)
					{
						self = ent;
						func();
						self = world;
						valid = true;
						break;
					}
				}

				if (ent.classname != "")
					strunzone(ent.classname);
				if (ent.message != "")
					strunzone(ent.message);
				remove(ent);
				valid = true;
				break;
			}

			string value = getentitytoken();
			if (!value)
				break;

			if (field == "classname")
			{
				func = externvalue(-2, strtolower(value));
				ent.classname = strzone(value);
			}
			else if (field == "targetname")
				ent.targetname = strzone(value);
			else if (field == "target")
				ent.target = strzone(value);
			else if (field == "origin")
				ent.origin = stov(value);
			else if (field == "angles")
				ent.angles = stov(value);
			else if (field == "angle")
				ent.angles = [0, stof(value), 0];
			else if (field == "mangle")
				ent.angles = stov(value);
			else if (field == "model")
				ent.model = value;
			else if (field == "message")
				ent.message = strzone(value);
		}

		if (!valid)
		{
			remove(ent);
			println("bad entity data");
			return;
		}
	}
}


bool had_attack;
bool had_released;
bool attacking;

bool IsAttackKey(float scanx)
{
	string bind = strtolower(getkeybind(scanx));
	if (strstrofs(bind, "+attack") >= 0)
		return true;
	return false;
}

float CSQC_InputEvent(float evtype, float scanx, float chary, float devid)
{
	switch(evtype)
	{
	case IE_KEYUP:
	{
		if (IsAttackKey(scanx))
			attacking = false;
		break;
	}
	case IE_KEYDOWN:
	{
		if (IsAttackKey(scanx))
		{
			// flush latest viewangles to CSQC
			float seat = getviewprop(VF_ACTIVESEAT);
			setviewprop(VF_ACTIVESEAT, -1);
			setviewprop(VF_ACTIVESEAT, seat);

			input_subframe_angles = getviewprop(VF_CL_VIEWANGLES);
			attack_angle = input_subframe_angles;
			had_attack = true;
			attacking = true;
			break;
		}

		// weapon impulses may get lost in some rare cases (high framerate, other impulses during the same frame...),
		// so we handle weapon commands here in case the input_impulse misses the request.
		string bind = strtolower(getkeybind(scanx));
		int weapon_str_index = strstrofs(bind, "weapon ");
		if (weapon_str_index >= 0)
		{
			weapon_str_index += 7; //'weapon '

			string str;
			int end = strstrofs(bind, ";", weapon_str_index);
			if (end >= 0)
				str = substring(bind, weapon_str_index, end-1-weapon_str_index);
			else
				str = substring(bind, weapon_str_index, 2);

			int weap = stoi(strtrim(str));
			if (weap > 0)
				weapon_impulse = weap;
		}
		break;
	}

	default:
		break;
	}

	return 0;
}

void CSQC_Input_Frame()
{
	if (cvar("cl_subframe_input") != 0)
	{
		if (had_attack)
		{
			input_subframe_angles = attack_angle;
			had_attack = false;
			had_released = false;
		}
		else
		{
			if (input_buttons & BUTTON_ATTACK)
			{
				// flush latest viewangles to CSQC
				float seat = getviewprop(VF_ACTIVESEAT);
				setviewprop(VF_ACTIVESEAT, -1);
				setviewprop(VF_ACTIVESEAT, seat);

				vector ang = getviewprop(VF_CL_VIEWANGLES);
				if (!had_released)
				{
					input_subframe_angles = attack_angle;
					had_released = true;
				}
				else
				{
					attack_angle = ang;
					input_subframe_angles = ang;
				}
			}
		}
	}
	else
	{
		float seat = getviewprop(VF_ACTIVESEAT);
		setviewprop(VF_ACTIVESEAT, -1);
		setviewprop(VF_ACTIVESEAT, seat);

		input_subframe_angles = getviewprop(VF_CL_VIEWANGLES);
		attack_angle = input_subframe_angles;
	}

	// ensure input_impulse handles weapon switching properly
	if (weapon_impulse != 0)
	{
		input_impulse = weapon_impulse;
		weapon_impulse = 0;
	}

	if (self.health <= 0)
	{
		if (input_buttons & BUTTON_ATTACK != 0 || input_buttons & BUTTON_JUMP != 0)
			input_impulse = IMPULSE_RESPAWN;
	}
}

void CSQC_RendererRestarted(string rendererdescription)
{
	if (models)
	{
		memfree(models);
		models = 0;
		models_count = 0;
		models_allocated_count = 0;
	}

	precache();

	// TODO: apply for non-player characters as well
	entity ent = world;
	while (true)
	{
		ent = find(ent, classname, CLASS_PLAYER);
		if (ent == world)
			break;

		entity oldself = self;
		self = ent;
		Player_InitModel();
		self = oldself;
	}
}