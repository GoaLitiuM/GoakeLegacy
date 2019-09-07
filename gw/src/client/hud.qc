bool showscores;
int font_hud;
int font_hud_big;
int font_engine;

const float TEXT_BIG_SIZE = 32.0f;

void Hud_Init()
{
	font_engine = loadfont("", "", "8", -1, 0, 0);
	font_hud = loadfont("", "fonts/FantasqueSansMono-Bold.ttf", "16", -1, 0, 0);
	font_hud_big = loadfont("", "fonts/FantasqueSansMono-Bold.ttf", ftos(TEXT_BIG_SIZE), -1, 0, 0);
	drawfont = font_hud;
}

void DrawHud(float width, float height, bool in_menu)
{
	local vector char_size = '12 12 0';
	local int spacing = 12;
	local float ups = floor(vlen([camera_velocity_x, camera_velocity_y, 0]));

	getinputstate(clientcommandframe);

	// movement indicators
	if (!showscores)
	{
		drawfont = font_engine;
		drawstring([spacing*1 + (width/2), (height*0.55)-spacing, 0], input_movevalues[0] > 0 ? "^" : "", '8 8 0', '1 1 1', 1, 0);
		drawstring([spacing*1 + (width/2)+spacing, (height*0.55), 0], input_movevalues[1] > 0 != 0 ? ">" : "", '8 8 0', '1 1 1', 1, 0);
		drawstring([spacing*1 + (width/2)-spacing, (height*0.55), 0], input_movevalues[1] < 0 != 0 ? "<" : "", '8 8 0', '1 1 1', 1, 0);
		drawstring([spacing*1 + (width/2), (height*0.55)+spacing, 0], input_movevalues[0] < 0 != 0 ? "v" : "", '8 8 0', '1 1 1', 1, 0);
		drawstring([spacing*1 + (width/2)+spacing, (height*0.55)-spacing, 0], input_buttons & BUTTON_JUMP ? "J" : "", '8 8 0', '1 1 1', 1, 0);
		drawfont = font_hud;

		drawstring([spacing*1 + (width/2), (height*0.55)+spacing*2, 0], ftos(ups), char_size, '1 1 1', 1, 0);
	}

	// scoreboard
	if (showscores)
	{
		local int row = 0;
		local float left = 100;
		local float top = (height*0.2);

		drawstring([left, top + row*spacing, 0], "Connected players", char_size, '1 1 1', 1, 0);
		drawstring([left+200, top + row*spacing, 0], "Ping/PL", char_size, '1 1 1', 1, 0);
		row++;

		drawstring([left, top + row*spacing, 0], "-----------------------------------------", char_size, '1 1 1', 1, 0);
		row++;

		for (int i=0; i<32; i++)
		{
			local string player_name = getplayerkeyvalue(i, "name");
			local string player_ping = getplayerkeyvalue(i, "ping");
			local string player_pl = getplayerkeyvalue(i, "pl");

			if (!player_name)
				continue;

			drawstring([left, top + row*spacing, 0], strcat("  ", player_name), char_size, '1 1 1', 1, 0);
			drawstring([left+200	, top + row*spacing, 0], player_ping, char_size, '1 1 1', 1, 0);
			drawstring([left+230	, top + row*spacing, 0], player_pl, char_size, '1 1 1', 1, 0);
			row++;
		}
	}

	// the rest of the hud
	if (!showscores)
	{
		local int playernum = player_localnum;
		local string left_str = itos(getplayerstat(playernum, STAT_HEALTH, EV_INTEGER));
		local string right_str = itos(getplayerstat(playernum, STAT_ARMOR, EV_INTEGER));
		local int weapon = getplayerstat(playernum, STAT_CURRENT_WEAPON, EV_INTEGER);
		local string ammo_str = weapon == 0 ? "" : itos(getplayerstat(playernum, WEAPON_AMMO_STAT(weapon), EV_INTEGER));
		drawfont = font_hud_big;

		drawstring([width * (0.5-0.10), height - TEXT_BIG_SIZE, 0], left_str, '1 1 1' * TEXT_BIG_SIZE, '1 1 1', 1, 0);
		drawstring([width * (0.5+0.10) - stringwidth(right_str, 0, '1 1 1' * TEXT_BIG_SIZE), height - TEXT_BIG_SIZE, 0], right_str, '1 1 1' * TEXT_BIG_SIZE, '1 1 1', 1, 0);

		drawfont = font_hud;

		drawstring([width * (0.5), height - TEXT_BIG_SIZE*3, 0], ammo_str, '1 1 1' * TEXT_BIG_SIZE, '1 1 1', 1, 0);
	}
}
