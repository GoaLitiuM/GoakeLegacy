#define Font font_s*
struct font_s
{
	int index;
	string fontname;
	float fontsize;
	float blur;
	float outline;

	font_s* alt; // linked list of alternative fonts used by special effects like blurring
};

font_s fallbackfont = {0, "", 8, 0, 0, 0};

font_s* fontcache;
int fontcache_allocated_count;
int fontcache_count;

float TextWidth(Font font, string text, float usecolours);

Font LoadFontEx(Font oldfont, string fontname, float fontsize, float blur, float outline)
{
	int slot = -1;
	if (oldfont)
		slot = oldfont->index;

	if (fontcache_count == fontcache_allocated_count)
	{
		int alloc_size = fontcache_allocated_count * 2;
		if (alloc_size == 0)
			alloc_size = 16;

		font_s* ptr = memalloc(sizeof(font_s) * alloc_size);
		fontcache_allocated_count = alloc_size;
		if (fontcache)
		{
			for (int i=0; i<fontcache_count; i++)
				memcpy(&ptr[i], &fontcache[i], sizeof(font_s));

			memfree(fontcache);
		}
		fontcache = ptr;
	}

	if (blur < 0.1)
		blur = 0;
	if (outline < 0.1)
		outline = 0;

	string facename = "";
	int slashind = strstrofs(fontname, "/");
	int extind = strstrofs(fontname, ".");
	//slashind = max(slashind, 0);
	extind = (extind < 0 ? strlen(fontname) : extind);
	facename = substring(fontname, slashind+1, extind-slashind-1);
	string slotname = "";

	// encode blur and outline values to slotname
	if (strlen(facename) > 0)
		slotname = strcat(facename, ":b", ftos(blur), ":o", ftos(outline));

	string sizes = strcat(ftos(fontsize), " blur=", ftos(blur), " outline=", ftos(outline));
	slot = loadfont(slotname, fontname, sizes, (float)slot, 0, 0);
	if (slot < 0)
		return &fallbackfont;

	Font font;
	if (oldfont)
		font = oldfont;
	else
	{
		font = &fontcache[fontcache_count];
		fontcache_count++;
	}

	font->index = slot;
	font->fontname = fontname;
	font->fontsize = fontsize;
	font->blur = blur;
	font->outline = outline;
	font->alt = 0;

	// preload common font glyphs
	int prevfont = drawfont;
	TextWidth(font, "01234567890abcdefghijklmnopqrstuvwxyz-", false);
	drawfont = prevfont;

	return font;
}

Font LoadFont(string fontname, float fontsize)
{
	return LoadFontEx(0, fontname, fontsize, 0, 0);
}

void DrawTextShadow(Font font, vector position, string text, vector color, float alpha, float shadow_blur, float shadow_strength, vector shadow_color, float shadow_alpha)
{
	if (shadow_blur > 0 && shadow_strength > 0)
	{
		Font cur = font;

		// alt is a linked list of special fonts associated to the main font
		while (cur->alt && (cur->alt)->blur != shadow_blur)
			cur = cur->alt;
		if (!cur->alt)
			cur->alt = LoadFontEx(cur->alt, font->fontname, font->fontsize, shadow_blur, 0);

		Font alt = cur->alt;
		drawfont = alt->index;
		while (shadow_strength > 0)
		{
			float pass_strength = min(shadow_strength, 1);
			shadow_strength -= 1;

			drawstring(position, text, [alt->fontsize, alt->fontsize, alt->fontsize], shadow_color, shadow_alpha*pass_strength, 0);
		}
	}
	drawfont = font->index;
	drawstring(position, text, [font->fontsize, font->fontsize, font->fontsize], color, alpha, 0);
}

void DrawText(Font font, vector position, string text, vector color, float alpha)
{
	drawfont = font->index;
	drawstring(position, text, [font->fontsize, font->fontsize, font->fontsize], color, alpha, 0);
}

float TextWidth(Font font, string text, float usecolours)
{
	drawfont = font->index;
	return stringwidth(text, usecolours, [font->fontsize, font->fontsize, font->fontsize]);
}