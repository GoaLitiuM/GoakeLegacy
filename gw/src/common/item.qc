void Item_OnTouch();

#ifdef CSQC
float Item_PreDraw();
#else
float Item_SendEntity(entity player, float flags);
#endif

void Item_SetActive(bool active)
{
	if (active)
	{
		self.alpha = 1;
		self.solid = SOLID_TRIGGER;
	}
	else
	{
		self.alpha = 0;
		self.solid = SOLID_NOT;
	}

#ifdef SSQC
	self.SendFlags = 1 + (active ? 1 : 0);
#endif
}

void Item_Init(string texture, string sound)
{
#ifdef CSQC
	self.predraw = Item_PreDraw;
	self.drawmask = MASK_ENGINE;
	self.simple_texture = texture;
#endif
#ifdef SSQC
	self.SendEntity = Item_SendEntity;
	self.SendFlags = 0;
#endif

	self.touch = Item_OnTouch;
	self.touch2 = 0;
	self.pickup_sound = sound;

	Item_SetActive(true);
}

void Item_InitSimple(string sound)
{
	string texture = strcat("textures/simple_items/", self.classname);
	Item_Init(texture, sound);
	setsize(self, '-16 -16 -16', '16 16 24'); // items should be slightly taller to make them easier to pickup
}

void Item_InitWeapon()
{
	Item_InitSimple(SND_WEAPON_PICKUP);
}

void Item_InitAmmo()
{
	Item_InitSimple(SND_AMMO_PICKUP);
}

void Item_InitArmor()
{
	Item_InitSimple(SND_ARMOR_PICKUP);
}

#ifdef CSQC
void Item_Update(float isnew)
{
	self.origin = readVector();
	float active = readFloat();
	self.classname = readString();

	if (isnew)
	{
		void() class_func = externvalue(-2, strtolower(self.classname));
		if (class_func)
			class_func();
	}

	Item_SetActive(active != 0);
}
#else
float Item_SendEntity(entity player, float flags)
{
	float active = (flags-1) != 0;

	writeByte(MSG_ENTITY, SENDENTITY_ITEM);

	writeVector(MSG_ENTITY, self.origin);
	writeFloat(MSG_ENTITY, active);
	writeString(MSG_ENTITY, self.classname);
	return 1;
}
#endif

void Item_Respawn()
{
	bool is_weapon = strstrofs(strtolower(self.classname), "weapon_") == 0;
	float respawn_time = is_weapon ? WEAPON_RESPAWN_TIME : ITEM_RESPAWN_TIME;

	Item_SetActive(true);

	if (respawn_time > 1)
		clientsound(self, CHAN_ITEM, SND_ITEM_RESPAWN, 1, ATTN_NORM, 0, 0, 0, self.last_touched);
}

void Item_Touched(entity source)
{
	if (self.touch2 && !self.touch2())
		return;

	bool is_weapon = strstrofs(strtolower(self.classname), "weapon_") == 0;
	float respawn_time = is_weapon ? WEAPON_RESPAWN_TIME : ITEM_RESPAWN_TIME;
	if (respawn_time <= 0)
		respawn_time = 1;

	self.last_touched = source;
	self.think = Item_Respawn;
	self.nextthink = time + respawn_time;

	Item_SetActive(false);

	clientsound(source, CHAN_ITEM, self.pickup_sound, 1, ATTN_NORM, 0, SOUNDFLAG_FOLLOW, 0, source);
}

void Item_OnTouch()
{
	if (other.classname != CLASS_PLAYER)
		return;

#ifdef CSQC
	if (cvar("cl_fullpred") == 0)
		return;
#endif

	Item_Touched(other);
}

void Item_SetTouch(bool() ontouch)
{
	self.touch2 = ontouch;
}