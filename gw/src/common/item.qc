void Item_OnTouch();

#ifdef CSQC
float Item_PreDraw();
#endif

void Item_Init(string texture)
{
	self.alpha = 1;
	self.solid = SOLID_TRIGGER;
	self.touch = Item_OnTouch;
	//self.flags = FL_ITEM;

#ifdef CSQC
	self.predraw = Item_PreDraw;
	self.drawmask = MASK_ENGINE;
	self.simple_texture = texture;
#endif
}

void Item_Respawn()
{
	bool is_weapon = strstrofs(strtolower(self.classname), "weapon_") == 0;
	float respawn_time = is_weapon ? WEAPON_RESPAWN_TIME : ITEM_RESPAWN_TIME;

	self.alpha = 1;
	self.solid = SOLID_TRIGGER;

	if (respawn_time > 1)
		clientsound(self, CHAN_ITEM, SND_ITEM_RESPAWN, 1, ATTN_NORM, 0, 0, 0, self.last_touched);
}

void Item_OnTouch()
{
	if (other.classname != CLASS_PLAYER)
		return;

	self.alpha = 0;
	self.solid = SOLID_NOT;
	self.think = Item_Respawn;
	self.nextthink = time + 1;
	self.last_touched = other;

	clientsound(self, CHAN_ITEM, "weapons/pkup.wav", 1, ATTN_NORM, 0, 0, 0, self.last_touched);
}