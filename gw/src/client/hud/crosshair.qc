void Hud_DrawCross(vector pos, vector offset, float size, float gap, vector color, float alpha)
{
	if (gap > 0)
	{
		drawline(1, [pos.x-size, pos.y+offset.y, 0], [pos.x-gap, pos.y+offset.y, 0], color, alpha);
		drawline(1, [pos.x+gap, pos.y+offset.y, 0], [pos.x+size, pos.y+offset.y, 0], color, alpha);

		drawline(1, [pos.x+offset.x, pos.y-size, 0], [pos.x+offset.x, pos.y-gap, 0], color, alpha);
		drawline(1, [pos.x+offset.x, pos.y+gap, 0], [pos.x+offset.x, pos.y+size, 0], color, alpha);
	}
	else
	{
		drawline(1, [pos.x-size, pos.y+offset.y, 0], [pos.x+size, pos.y+offset.y, 0], color, alpha);
		drawline(1, [pos.x+offset.x, pos.y-size, 0], [pos.x+offset.x, pos.y+size, 0], color, alpha);
	}
}

void Hud_Crosshair(float width, float height)
{
	float x = width*0.5f;
	float y = height*0.5f;
	vector size = getviewprop(VF_SCREENPSIZE);
	vector vsize = getviewprop(VF_SIZE);
	float pixelscale = vsize.x/size.x;

	// TODO: cvar these
	vector crosshair_color = [255, 255, 255];
	float crosshair_alpha = 1.0f;
	int crosshair_size = 10;
	int crosshair_thickness = 2;
	int crosshair_gap = 4;

	// TODO: render the crosshair to texture first so it can be reused

	Hud_DrawCross([x, y, 0], [0, 0, 0], crosshair_size, crosshair_gap, crosshair_color, crosshair_alpha);

	for (int i=1; i<crosshair_thickness; i++)
	{
		float p = i * pixelscale;

		Hud_DrawCross([x, y, 0], [p, p, 0], crosshair_size, crosshair_gap, crosshair_color, crosshair_alpha);
		Hud_DrawCross([x, y, 0], [-p, -p, 0], crosshair_size, crosshair_gap, crosshair_color, crosshair_alpha);
	}
}