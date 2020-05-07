void Hud_WeaponRack(float width, float height)
{
	Font ammo_font = font_main;
	float rack_height = 20;
	float cell_width = 45;
	float icon_size = rack_height;
	float left = width*0.5;
	float top = height - rack_height;
	float padding = 0;


	int num_weapons = 0;
	for (int i=WEAPON_NONE+1; i<WEAPON_LAST; i++)
	{
		if (!(self.weapons & WEAPON_BIT(i)))
			continue;

		num_weapons++;
	}

	float total_width = num_weapons*cell_width;
	left -= total_width*0.5;
	drawfill([left-padding, top-padding, 0], [total_width + 2*padding, rack_height + 2*padding, 0], [0, 0, 0], 0.66);

	float offset_x = padding;
	for (int i=WEAPON_NONE+1; i<WEAPON_LAST; i++)
	{
		if (!(self.weapons & WEAPON_BIT(i)))
			continue;

		Weapon* weapon_def = &weapon_defs[i];
		int weapon_ammo = self.ammo[WEAPON_AMMO_INDEX(i)];

		string weapon_texture = strcat("textures/simple_items/", weapon_def.entname);

		drawpic([left+offset_x, top, 0], weapon_texture, [icon_size, icon_size, 0], [1, 1, 1], 1.0);

		string ammo_str = (weapon_defs[i].ammo_consumption > 0 && weapon_ammo != AMMO_INFINITE) ? itos(weapon_ammo) : "-";
		float ammo_width = TextWidth(ammo_font, ammo_str, false);
		float ammo_height = (int)(0.75*ammo_font.fontsize); //...
		float ammo_x = icon_size+((cell_width-icon_size)*0.5) - ammo_width*0.5;
		float ammo_y = (rack_height-ammo_height)*0.5;

		DrawTextShadow(ammo_font, [left+offset_x+ammo_x, top+ammo_y, 0], ammo_str, '1 1 1', 1,  4, 1.35, '0 0 0', 1);

		offset_x += cell_width;
	}
}