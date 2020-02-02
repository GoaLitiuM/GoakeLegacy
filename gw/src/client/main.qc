// all the CSQC entry functions should be placed here

void CSQC_Init(float apilevel, string enginename, float engineversion)
{
	precache();

	Common_Init();
	Hud_Init();
	Item_InitDraw();

	registercommand("+showscores");
	registercommand("-showscores");
}

float CSQC_ConsoleCommand(string cmd)
{
	cmd = strtolower(strtrim(cmd));
	local string key = "";

	// commands may have the triggering key appended at the end, parse it
	if (str2chr(cmd, 0) == '+' || str2chr(cmd, 0) == '-')
	{
		local int last_space = -1;
		while (true)
		{
			local int ind = strstrofs(cmd, " ", last_space+1);
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
	// calculate the delay to the server for svtime
	float delay = (clientcommandframe - servercommandframe) * (1.0f/maxfps);
	svtime = time + delay;

	clearscene();

	setviewprop(VF_DRAWWORLD, 1);
	setviewprop(VF_DRAWCROSSHAIR, 1);

	addentities(MASK_ENGINE | MASK_VIEWMODEL);

	setviewprop(VF_ORIGIN, camera_origin);
	setviewprop(VF_ANGLES, view_angles);

	renderscene();

	DrawHud(width, height, !notmenu);
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

		default:
			error(strcat("unknown entity type in CSQC_Ent_Update: ", ftos(type)));
	}
}

void CSQC_Ent_Remove()
{
	if (self.classname == CLASS_PLAYER)
		Player_Remove();
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
	bool pred = cvar("cl_nopred") == 0;

	// ignore sounds emitted from local player when full prediction is enabled
	if (pred && (flags & SOUNDFLAG_PREDICT))
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
					self = ent;
					func();
					self = world;
					valid = true;
					break;
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

float CSQC_InputEvent(float evtype, float scanx, float chary, float devid)
{
	switch(evtype)
	{
	case IE_KEYDOWN:
	{
		// weapon impulses may get lost in some rare cases (high framerate, other impulses during the same frame...),
		// so we handle weapon commands here in case the input_impulse misses the request.
		local string bind = strtolower(getkeybind(scanx));
		local int weapon_str_index = strstrofs(bind, "weapon ");
		if (weapon_str_index >= 0)
		{
			weapon_str_index += 7; //'weapon '

			local string str;
			local int end = strstrofs(bind, ";", weapon_str_index);
			if (end >= 0)
				str = substring(bind, weapon_str_index, end-1-weapon_str_index);
			else
				str = substring(bind, weapon_str_index, 2);

			local int weap = stoi(strtrim(str));
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
