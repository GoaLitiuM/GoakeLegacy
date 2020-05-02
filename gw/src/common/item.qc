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
	self.SendFlags |= SENDFLAGS_ITEM_ACTIVE;
#endif
}

bool Item_IsActive()
{
	return self.solid != SOLID_NOT;
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
	self.pvsflags = PVSF_USEPHS; // players can hear items respawn
	self.SendFlags |= SENDFLAGS_ORIGIN | SENDFLAGS_ITEM_INIT;
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
	self.respawn_time = WEAPON_RESPAWN_TIME;
}

void Item_InitAmmo()
{
	Item_InitSimple(SND_AMMO_PICKUP);
	self.respawn_time = ITEM_RESPAWN_TIME;
}

void Item_InitArmor()
{
	Item_InitSimple(SND_ARMOR_PICKUP);
	self.respawn_time = ARMOR_RESPAWN_TIME;
}

#ifdef CSQC
void Item_Update(float isnew)
{
	int active = 0;
	int flags = readInt();
	if (flags & SENDFLAGS_ORIGIN)
		self.origin = readVector();
	if (flags & SENDFLAGS_ITEM_INIT)
		self.classname = readString();
	if (flags & SENDFLAGS_ITEM_ACTIVE)
		active = readByte();

	if (isnew)
	{
		void() class_func = externvalue(-2, strtolower(self.classname));
		if (class_func)
			class_func();
	}

	if (flags & SENDFLAGS_ITEM_ACTIVE)
		Item_SetActive(active != 0);
}
#else
float Item_SendEntity(entity player, float flags)
{
	writeByte(MSG_ENTITY, SENDENTITY_ITEM);
	writeInt(MSG_ENTITY, (int)flags);

	if (flags & SENDFLAGS_ORIGIN)
		writeVector(MSG_ENTITY, self.origin);
	if (flags & SENDFLAGS_ITEM_INIT)
		writeString(MSG_ENTITY, self.classname);
	if (flags & SENDFLAGS_ITEM_ACTIVE)
		writeByte(MSG_ENTITY, Item_IsActive());
	return 1;
}
#endif

void Item_OnRespawn()
{
	Item_SetActive(true);

	if (self.respawn_time > 1) // instantly spawning items should not make any noise
		clientsound(self, CHAN_ITEM, SND_ITEM_RESPAWN, 1, ATTN_NORM, 0, 0, 0, self.last_touched);
}

void Item_StartRespawn()
{
	self.think = Item_OnRespawn;
	self.nextthink = time + self.respawn_time;
}

void Item_OnPickup(entity source)
{
	self.last_touched = source;

	Item_StartRespawn();
	Item_SetActive(false);

	clientsound(source, CHAN_ITEM, self.pickup_sound, 1, ATTN_NORM, 0, SOUNDFLAG_FOLLOW, 0, source);
}

void Item_Touched(entity source)
{
	if (self.touch2 && !self.touch2())
		return;

	Item_OnPickup(source);
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