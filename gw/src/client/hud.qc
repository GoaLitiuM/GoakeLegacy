bool showscores;

Font font_engine;
Font font_main;
Font font_main_med;
Font font_main_big;
Font font_chat;
Font font_chat_bold;
Font font_info_title;
Font font_info_sub;

void Hud_Init()
{
	font_engine = LoadFont("", 8);
	font_main = LoadFont("fonts/SairaCondensed-SemiBold.ttf", 16);
	font_main_med = LoadFont("fonts/SairaCondensed-SemiBold.ttf", 28);
	font_main_big = LoadFont("fonts/SairaCondensed-Black.ttf", 48);

	font_info_title = LoadFont("fonts/SairaCondensed-Bold.ttf", 28);
	font_info_sub = LoadFont("fonts/SairaCondensed-Regular.ttf", 14);

	font_chat = LoadFont("fonts/Oxanium-Regular.ttf", 10);
	font_chat_bold = LoadFont("fonts/Oxanium-Bold.ttf", 10);

	registercommand("+showscores");
	registercommand("-showscores");
}

void Hud_Keys(float width, float height);
void Hud_Player(float width, float height);
void Hud_Timer(float width, float height);
void Hud_Scoreboard(float width, float height);
void Hud_Chat(float width, float height);
void Hud_Crosshair(float width, float height);
void Hud_State(float width, float height);

void Hud_Render(float width, float height, bool in_menu)
{
	if (cvar("cl_showhud") == 0)
		return;

	if (showscores || gamemode_state == GameModeState::EndScreen)
		Hud_Scoreboard(width, height);
	else
	{
		Hud_State(width, height);
		Hud_Keys(width, height);
		Hud_Player(width, height);
		Hud_Timer(width, height);
		Hud_Crosshair(width, height);
	}

	if (!showscores)
		Hud_Chat(width, height);
}

// movement indicators
void Hud_Keys(float width, float height)
{
	vector char_size = '12 12 0';
	int spacing = 12;

	float ups = vlen([camera_velocity_x, camera_velocity_y, 0]);
	ups = floor(ups);

	DrawTextShadow(font_engine, [spacing*1 + (width/2), (height*0.55)-spacing, 0], input_movevalues[0] > 0 ? "^" : "", '1 1 1', 1,  4, 1.35, '0 0 0', 1);
	DrawTextShadow(font_engine, [spacing*1 + (width/2)+spacing, (height*0.55), 0], input_movevalues[1] > 0 != 0 ? ">" : "", '1 1 1', 1,  4, 1.35, '0 0 0', 1);
	DrawTextShadow(font_engine, [spacing*1 + (width/2)-spacing, (height*0.55), 0], input_movevalues[1] < 0 != 0 ? "<" : "", '1 1 1', 1,  4, 1.35, '0 0 0', 1);
	DrawTextShadow(font_engine, [spacing*1 + (width/2), (height*0.55)+spacing, 0], input_movevalues[0] < 0 != 0 ? "v" : "", '1 1 1', 1,  4, 1.35, '0 0 0', 1);
	DrawTextShadow(font_engine, [spacing*1 + (width/2)+spacing, (height*0.55)-spacing, 0], input_buttons & BUTTON_JUMP ? "J" : "", '1 1 1', 1,  4, 1.35, '0 0 0', 1);
	DrawTextShadow(font_engine, [spacing*1 + (width/2)-spacing, (height*0.55)-spacing, 0], input_buttons & BUTTON_ATTACK ? "A" : "", '1 1 1', 1,  4, 1.35, '0 0 0', 1);
	//DrawTextShadow(font_chat, [spacing*1 + (width/2)+spacing, (height*0.55)+spacing, 0], input_buttons & BUTTON_CROUCH ? "C" : "", '1 1 1', 1,  4, 1.35, '0 0 0', 1);

	DrawTextShadow(font_main, [spacing*1 + (width/2), (height*0.55)+spacing*2, 0], ftos(ups), '1 1 1', 1,  4, 1.35, '0 0 0', 1);
}

// health, armor and ammo
void Hud_Player(float width, float height)
{
	entity playerent = player_localentnum == local_player.entnum ? local_player : getEntity(player_localentnum);
	string left_str = itos(playerent.health);
	string right_str = itos(playerent.armorvalue);
	int current_weapon = playerent.weapon;
	int weapon_ammo = playerent.ammo[WEAPON_AMMO_INDEX(current_weapon)];
	string ammo_str = (weapon_defs[current_weapon].ammo_consumption > 0 && weapon_ammo != AMMO_INFINITE) ? itos(weapon_ammo) : "-";

	int center_offset = 5;

	// health
	DrawTextShadow(font_main_big, [width*0.5 - TextWidth(font_main_big, left_str, false) - center_offset, height - font_main_big.fontsize, 0], left_str, '1 1 1', 1,  4, 1.35, '0 0 0', 1);

	// armor
	{
		vector armor_col = '1 1 1';
		if (playerent.armortype == ARMOR_GREEN_ABSORB)
			armor_col = '0 1 0';
		else if (playerent.armortype == ARMOR_YELLOW_ABSORB)
			armor_col = '1 1 0';
		else if (playerent.armortype == ARMOR_RED_ABSORB)
			armor_col = '1 0 0';
		DrawTextShadow(font_main_big, [width*0.5 + center_offset, height - font_main_big.fontsize, 0], right_str, armor_col, 1,  4, 1.35, '0 0 0', 1);
	}

	// ammo
	float ammo_width = TextWidth(font_main_med, ammo_str, false);
	DrawTextShadow(font_main_med, [width*0.5 - ammo_width*0.5, height*0.75, 0], ammo_str, '1 1 1', 1,  4, 1.35, '0 0 0', 1);
}

void Hud_Scoreboard(float width, float height)
{
	int offset_y = 0;
	float left = width*0.5 - 180;
	float top = (height*0.16);

	DrawText(font_main, [left, top + offset_y, 0], "Connected players", '1 1 1', 1);
	DrawText(font_main, [left+230, top + offset_y, 0], "Frags", '1 1 1', 1);
	DrawText(font_main, [left+270, top + offset_y, 0], "Deaths", '1 1 1', 1);
	DrawText(font_main, [left+320, top + offset_y, 0], "Ping PL", '1 1 1', 1);
	offset_y += 12;

	DrawText(font_main, [left, top + offset_y, 0], "-------------------------------------------------------------------------", '1 1 1', 1);
	offset_y += 12;

	for (int i=0; i<32; i++)
	{
		string player_name = getplayerkeyvalue(i, "name");
		string player_frags = getplayerkeyvalue(i, "*frags");
		string player_deaths = getplayerkeyvalue(i, "*deaths");
		string player_ping = getplayerkeyvalue(i, "ping");
		string player_pl = getplayerkeyvalue(i, "pl");

		if (!player_name)
			continue;

		if (player_pl == "0")
			player_pl = "";

		DrawText(font_main, [left,		top + offset_y, 0], player_name, '1 1 1', 1);
		DrawText(font_main, [left+230,	top + offset_y, 0], player_frags, '1 1 1', 1);
		DrawText(font_main, [left+270,	top + offset_y, 0], player_deaths, '1 1 1', 1);
		DrawText(font_main, [left+320,	top + offset_y, 0], player_ping, '1 1 1', 1);
		DrawText(font_main, [left+350,	top + offset_y, 0], player_pl, '1 1 1', 1);
		offset_y += font_main.fontsize;
	}
}

void Hud_State(float width, float height)
{
	bool warmup = gamemode_state == GameModeState::Warmup || gamemode_state == GameModeState::Countdown;
	float top = height*0.125;

	if (!warmup && gamemode_time >= 5.0)
		return;

	string gamemode_str = gamemode_fullname;
	float gamemode_width = TextWidth(font_info_title, gamemode_str, false);
	DrawTextShadow(font_info_title, [width*0.5 - gamemode_width*0.5, top, 0], gamemode_str, '1 1 1', 1,  2, 2, '0 0 0', 1);

	float offset_y = font_info_title.fontsize;

	if (warmup)
	{
		string warmup_str = strcat("Warmup, ", itos(Game_CountPlayersReady()), "/", itos(max(gamemode_minimum_players, Game_CountPlayers())), " players ready");
		float warmup_width = TextWidth(font_info_sub, warmup_str, false);
		DrawTextShadow(font_info_sub, [width*0.5 - warmup_width*0.5, top + offset_y, 0], warmup_str, '1 1 1', 1,  2, 2, '0 0 0', 1);

		offset_y += font_info_sub.fontsize;

		if (infokeyf(local_player, "ready") == 0)
		{
			string ready_key;
			tokenize(findkeysforcommand("toggleready"));
			if (argv(0) == "-1")
				ready_key = "(UNBOUND)";
			else
				ready_key = keynumtostring(stof(argv(0)));

			string ready_str = strcat("Press ", ready_key, " to ready up");
			float ready_width = TextWidth(font_info_sub, ready_str, false);
			DrawTextShadow(font_info_sub, [width*0.5 - ready_width*0.5, top + offset_y, 0], ready_str, '1 0.1 0.1', 1,  2, 2, '0 0 0', 1);
		}
	}
}