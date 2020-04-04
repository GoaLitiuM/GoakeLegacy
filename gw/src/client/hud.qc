bool showscores;

Font font_engine;
Font font_main;
Font font_main_med;
Font font_main_big;
Font font_chat;
Font font_chat_bold;

void Hud_Init()
{
	font_engine = LoadFont("", 8);
	font_main = LoadFont("fonts/SairaCondensed-SemiBold.ttf", 16);
	font_main_med = LoadFont("fonts/SairaCondensed-SemiBold.ttf", 28);
	font_main_big = LoadFont("fonts/SairaCondensed-Black.ttf", 48);

	font_chat = LoadFont("fonts/Oxanium-Regular.ttf", 10);
	font_chat_bold = LoadFont("fonts/Oxanium-Bold.ttf", 10);
}

void Hud_Keys(float width, float height);
void Hud_Player(float width, float height);
void Hud_Scoreboard(float width, float height);
void Hud_Chat(float width, float height);
void Hud_Crosshair(float width, float height);

void Hud_Render(float width, float height, bool in_menu)
{
	getinputstate(clientcommandframe);

	if (showscores)
		Hud_Scoreboard(width, height);
	else
	{
		Hud_Keys(width, height);
		Hud_Player(width, height);
		Hud_Chat(width, height);
		Hud_Crosshair(width, height);
	}
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
	int playernum = player_localentnum;
	entity playerent = playernum == player_localnum ? local_player : getEntity(playernum);
	string left_str = itos(playerent.health);//itos(getplayerstat(playernum, STAT_HEALTH, EV_INTEGER));
	string right_str = itos(playerent.armorvalue);//itos(getplayerstat(playernum, STAT_ARMOR, EV_INTEGER));
	int weapon = getplayerstat(playernum, STAT_CURRENT_WEAPON, EV_INTEGER);
	int weapon_ammo = playerent.ammo[WEAPON_AMMO_INDEX(weapon)];
	string ammo_str = weapon == 0 ? "" : itos(weapon_ammo);

	// health
	DrawTextShadow(font_main_big, [width * (0.5-0.10), height - font_main_big.fontsize, 0], left_str, '1 1 1', 1,  4, 1.35, '0 0 0', 1);

	// armor
	{
		vector armor_col = '1 1 1';
		if (playerent.armortype == ARMOR_GREEN_ABSORB)
			armor_col = '0 1 0';
		else if (playerent.armortype == ARMOR_YELLOW_ABSORB)
			armor_col = '1 1 0';
		else if (playerent.armortype == ARMOR_RED_ABSORB)
			armor_col = '1 0 0';
		DrawTextShadow(font_main_big, [width * (0.5+0.10) - TextWidth(font_main_big, right_str, false), height - font_main_big.fontsize, 0], right_str, armor_col, 1,  4, 1.35, '0 0 0', 1);
	}

	// ammo
	float ammo_width = TextWidth(font_main_med, ammo_str, false);
	DrawTextShadow(font_main_med, [width*0.5 - ammo_width*0.5, height*0.75, 0], ammo_str, '1 1 1', 1,  4, 1.35, '0 0 0', 1);
}

void Hud_Scoreboard(float width, float height)
{
	int spacing = 12;
	int row = 0;
	float left = width*0.31;
	float top = (height*0.16);

	DrawText(font_main, [left, top + row*spacing, 0], "Connected players", '1 1 1', 1);
	DrawText(font_main, [left+230, top + row*spacing, 0], "Frags", '1 1 1', 1);
	DrawText(font_main, [left+270, top + row*spacing, 0], "Deaths", '1 1 1', 1);
	DrawText(font_main, [left+320, top + row*spacing, 0], "Ping PL", '1 1 1', 1);
	row++;

	DrawText(font_main, [left, top + row*spacing, 0], "-------------------------------------------------------------------------", '1 1 1', 1);
	row++;

	for (int i=0; i<32; i++)
	{
		string player_name = getplayerkeyvalue(i, "name");
		string player_frags = getplayerkeyvalue(i, "frags");
		string player_deaths = getplayerkeyvalue(i, "deaths");
		string player_ping = getplayerkeyvalue(i, "ping");
		string player_pl = getplayerkeyvalue(i, "pl");

		if (!player_name)
			continue;

		if (player_pl == "0")
			player_pl = "";

		DrawText(font_main, [left,		top + row*spacing, 0], player_name, '1 1 1', 1);
		DrawText(font_main, [left+230,	top + row*spacing, 0], player_frags, '1 1 1', 1);
		DrawText(font_main, [left+270,	top + row*spacing, 0], player_deaths, '1 1 1', 1);
		DrawText(font_main, [left+320,	top + row*spacing, 0], player_ping, '1 1 1', 1);
		DrawText(font_main, [left+350,	top + row*spacing, 0], player_pl, '1 1 1', 1);
		row++;
	}
}
