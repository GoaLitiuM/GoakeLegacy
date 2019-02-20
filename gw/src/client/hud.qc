bool showscores;

void DrawHud(float width, float height, bool in_menu)
{
	local vector char_size = '8 8 0';
	local int spacing = 8;
	local float ups = floor(vlen([camera_velocity_x, camera_velocity_y, 0]));

	getinputstate(clientcommandframe);

	if (!showscores)
	{
		drawstring([spacing*1 + (width/2), (height*0.55)-spacing, 0], input_movevalues[0] > 0 ? "^" : "", char_size, '1 1 1', 1, 0);
		drawstring([spacing*1 + (width/2)+spacing, (height*0.55), 0], input_movevalues[1] > 0 != 0 ? ">" : "", char_size, '1 1 1', 1, 0);
		drawstring([spacing*1 + (width/2)-spacing, (height*0.55), 0], input_movevalues[1] < 0 != 0 ? "<" : "", char_size, '1 1 1', 1, 0);
		drawstring([spacing*1 + (width/2), (height*0.55)+spacing, 0], input_movevalues[0] < 0 != 0 ? "v" : "", char_size, '1 1 1', 1, 0);
		drawstring([spacing*1 + (width/2)+spacing, (height*0.55)-spacing, 0], input_buttons & BUTTON_JUMP ? "J" : "", char_size, '1 1 1', 1, 0);

		drawstring([spacing*1 + (width/2), (height*0.55)+spacing*2, 0], ftos(ups), char_size, '1 1 1', 1, 0);
	}

	if (showscores)
	{
		local int row = 0;
		local float left = 100;
		local float top = (height*0.2);

		drawstring([left, top + row*spacing, 0], "Connected players", char_size, '1 1 1', 1, 0);
		drawstring([left+200, top + row*spacing, 0], "Ping", char_size, '1 1 1', 1, 0);
		row++;

		drawstring([left, top + row*spacing, 0], "-----------------------------------------", char_size, '1 1 1', 1, 0);
		row++;

		for (int i=0; i<32; i++)
		{
			local string player_name = getplayerkeyvalue(i, "name");
			local string player_ping = getplayerkeyvalue(i, "ping");

			if (!player_name)
				break;

			drawstring([left, top + row*spacing, 0], strcat("  ", player_name), char_size, '1 1 1', 1, 0);
			drawstring([left+200	, top + row*spacing, 0], player_ping, char_size, '1 1 1', 1, 0);
			row++;
		}
	}
}
