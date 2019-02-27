// all the CSQC entry functions should be placed here

void CSQC_Init(float apilevel, string enginename, float engineversion)
{
	precache();

	HudInit();

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
	clearscene();

	setviewprop(VF_DRAWWORLD, 1);
	setviewprop(VF_DRAWCROSSHAIR, 1);

	addentities(MASK_ENGINE | MASK_VIEWMODEL);

	setviewprop(VF_ORIGIN, camera_origin + VEC_OFFSET_EYES);
	setviewprop(VF_ANGLES, view_angles);

	renderscene();

	DrawHud(width, height, !notmenu);
}

void CSQC_Ent_Update(float isnew)
{
	local float type = readByte();
	if (type == 1)
		PlayerUpdate(isnew != 0);
}

float CSQC_Event_Sound(float entnum, float channel, string soundname, float vol, float attenuation, vector pos, float pitchmod, float flags)
{
	// ignore sounds emitted from local player when full prediction is enabled
	if (channel != 0 && player_localentnum == entnum && cvar("cl_fullpred") != 0)
		return 1;
	return 0;
}

float CSQC_Parse_SetAngles(vector newangles, float wasdelta)
{
	if (self.entnum != local_player.entnum)
		self = local_player; // self entity is really inconsistent here
	if (self.entnum == 0)
		fixanglefix = 1; // player entity does not exist yet...

	self.fixangle = 1;

	// prediction overrides fixangle requests
	return cvar("cl_nopred") == 0;
}

void CSQC_WorldLoaded()
{
	// populate CSQC world with entities found in the map file
	while (1)
	{
		local string token = getentitytoken();
		if (token == "")
			break;
		else if (token != "{")
		{
			println("bad entity data");
			return;
		}

		local entity ent = spawn();
		local void() func = 0;
		local bool valid = false;
		while (1)
		{
			local string field = getentitytoken();
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

			local string value = getentitytoken();
			if (!value)
				break;

			if (field == "classname")
			{
				if (value == "trigger_teleport")
					func = trigger_teleport;
				else if (value == "info_teleport_destination")
					func = info_teleport_destination;
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
