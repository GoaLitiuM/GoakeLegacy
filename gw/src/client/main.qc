// all the CSQC entry functions should be placed here

void CSQC_Parse_Print(string printmsg, float printlvl)
{
	if (printlvl == PRINT_CHAT)
	{
		int chat_type = CHAT_TYPE_SYSTEM;
		if (strstrofs(printmsg, "You can't talk for ") == 0)
			chat_type = CHAT_TYPE_SPAM;
		else if (strstrofs(printmsg, ":") >= 0)
			chat_type = CHAT_TYPE_MESSAGE;

		if (chat_type == CHAT_TYPE_MESSAGE)
			Chat_OnPrint(printmsg);
		else
			Chat_SystemMessage(strdecolorize(strtrim(printmsg)), chat_type);
		return;
	}
	else if (printlvl == PRINT_HIGH)
	{
		if (strstrofs(printmsg, "You can't suicide for ") == 0)
		{
			Chat_SystemMessage(strdecolorize(strtrim(printmsg)), CHAT_TYPE_SPAM);
			return;
		}
	}

	print(printmsg);
}

void CSQC_Init(float apilevel, string enginename, float engineversion)
{
	precache();

	Common_Init();
	Hud_Init();
	Item_InitClient();
	Vote_Init();

	registercommand("ready", "Informs the server that the player is ready.");
	registercommand("unready", "Informs the server that the player is no longer ready.");
	registercommand("notready", "Informs the server that the player is no longer ready.");
	registercommand("toggleready", "Informs the server that the player is ready, toggling between the ready and not-ready state.");

	setlocaluserinfo(0, "ready", "0");
}

float CSQC_ConsoleCommand(string line)
{
	line = strtolower(strtrim(line));
	string key = "";

	// commands may have the triggering key appended at the end, parse it
	if (str2chr(line, 0) == '+' || str2chr(line, 0) == '-')
	{
		int last_space = -1;
		while (true)
		{
			int ind = strstrofs(line, " ", last_space+1);
			if (ind == -1)
				break;

			last_space = ind;
		}
		if (last_space >= 0)
		{
			key = substring(line, last_space+1, strlen(line)-last_space-1);
			line = substring(line, 0, last_space);
		}
	}

	tokenize(line);
	switch (argv(0))
	{
		case "+showscores":
			showscores = true;
			break;
		case "-showscores":
			showscores = false;
			break;

		case "messagemode":
			chat_team = false;
			return true;
		case "messagemode2":
			chat_team = true;
			return true;

		case "callvote":
			Vote_CallVote(strtrim(substring(line, 9, strlen(line)-9)));
			return true;
		case "vote":
			Vote_Vote(strtrim(substring(line, 5, strlen(line)-5)));
			return true;

		case "ready":
			setlocaluserinfo(0, "ready", "");
			setlocaluserinfo(0, "ready", "1");
			return true;
		case "notready":
		case "unready":
			setlocaluserinfo(0, "ready", "");
			setlocaluserinfo(0, "ready", "0");
			return true;
		case "toggleready":
			int ready = !(stof(getplayerkeyvalue(player_localnum, "ready")) != 0);
			setlocaluserinfo(0, "ready", "");	// server forced values does not get back to client unfortunately, just force the new value
			setlocaluserinfo(0, "ready", itos(ready));
			return true;
	}
	return false;
}

void CSQC_UpdateView(float width, float height, float notmenu)
{


	getinputstate(clientcommandframe);

	clearscene();
	setviewprop(VF_DRAWWORLD, 1);
	setviewprop(VF_DRAWCROSSHAIR, 0);

	setviewprop(VF_ORIGIN, camera_origin);
	setviewprop(VF_ANGLES, input_angles);

	addentities(MASK_ENGINE | MASK_VIEWMODEL);


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
		case SENDENTITY_ITEM:
			Item_Update(isnew != 0);
			break;
		case SENDENTITY_ROCKET:
			WeaponRocket_Update(isnew != 0);
			break;
		case SENDENTITY_NAIL:
			WeaponNailgun_Update(isnew != 0);
			break;
		case SENDENTITY_GRENADE:
			WeaponGrenade_Update(isnew != 0);
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
	int type = readByte();
	switch (type)
	{
		case EVENT_LIGHTNING:
			vector start = readVector();
			vector end = readVector();
			entity player = readEntity();

			WeaponLightning_CreateLightningBeam(start, end, player);
			break;
		case EVENT_PLAYER_ATTACK:
		{
			entity player = readEntity();
			player.is_attacking = true;
			break;
		}
		case EVENT_PLAYER_DEATH:
		{
			entity killed = readEntity();
			entity killer = readEntity();
			entity source = readEntity();
			string source_type = readString();

			if (killed.entnum == player_localentnum)
			{
				entity oldself = self;
				self = killed;
				Player_OnDeath(source);
				self = oldself;

				localcmd("-attack; -jump"); // unrelease these actions to prevent player respawning accidentally
			}

			string killed_name = infokey(killed, "name");
			string killer_name = killer ? infokey(killer, "name") : "";

			if (killer.entnum == killed.entnum)
			{
				if (source_type)
					Chat_SystemMessage(strcat(killed_name, " suicided"), CHAT_TYPE_DEATH);
				else
					Chat_SystemMessage(strcat(killed_name, " suicided with ", source.classname), CHAT_TYPE_DEATH);
			}
			else if (killer)
			{
				if (source_type)
					Chat_SystemMessage(strcat(killer_name, " fragged ", killed_name, " with ", source.classname), CHAT_TYPE_DEATH);
				else
					Chat_SystemMessage(strcat(killer_name, " fragged ", killed_name), CHAT_TYPE_DEATH);
			}
			else if (source_type)
				Chat_SystemMessage(strcat(killed_name, " got killed by ", source_type), CHAT_TYPE_DEATH);
			else
				Chat_SystemMessage(strcat(killed_name, " died mysteriously"), CHAT_TYPE_DEATH);

			break;
		}

		case EVENT_GAMEMODE_TIMER:
			gamemode_timeroffset = readFloat();
			break;
		case EVENT_GAMEMODE_CHANGED:
		{
			string old_mode = gamemode_name;
			gamemode_name = readString();
			gamemode_fullname = readString();
			gamemode_minimum_players = readByte();
			if (gamemode_name != old_mode)
				println("Game mode changed to: ", gamemode_fullname);
			break;
		}
		case EVENT_GAMEMODE_STATE:
			gamemode_state = (GameModeState)((__variant)((int)readByte()));
			if (gamemode_state == GameModeState::Countdown)
				Chat_SystemMessage("Game is starting in 5 seconds...");
			break;

		case EVENT_CALLVOTE:
			Vote_OnCallVote();
			break;
		case EVENT_CALLVOTE_PLAYERVOTE:
			Vote_OnPlayerVote();
			break;
		case EVENT_CALLVOTE_FINISHED:
			Vote_OnFinish();
			break;

		default:
			error(strcat("Unknown CSQC_Parse_Event type: ", itos(type)));
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
			println("Failed to parse entities: unexpected token '", token, "'");
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
				{
					dprintln("Failed to parse entity: missing classname");
					break;
				}
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

			switch (field)
			{
				case "classname":
					func = externvalue(-2, strtolower(value));
					ent.classname = strzone(value);
					break;
				case "origin":
					ent.origin = stov(value);
					break;
				case "angles":
					ent.angles = stov(value);
					break;
				case "angle":
					ent.angles = [0, stof(value), 0];
					break;
				case "mangle":
					ent.angles = stov(value);
					break;
				case "model":
					ent.model = value;
					break;
				default:
				{
					float fldid = findentityfield(field);
					if (fldid)
					{
						float fldtype = entityfieldtype(fldid);
						field_t fld = entityfieldref(fldid);

						switch (fldtype)
						{
							case EV_STRING:
								ent.fld = strzone(value);
								break;
							case EV_FLOAT:
								ent.fld = stof(value);
								break;
							case EV_VECTOR:
								ent.fld = stov(value);
								break;
							case EV_INTEGER:
								ent.fld = stoi(value);
								break;
							default:
								println("Invalid field type ", ftos(fldtype), " for field '", field, "'");
								break;
						}
					}
					else
						dprintln("Warning: Unsupported entity field '", field, "'");
					break;
				}
			}
		}

		if (!valid)
			remove(ent);
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

	if (Player_IsDead(self))
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