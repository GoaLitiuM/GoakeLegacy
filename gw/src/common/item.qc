void Item_OnTouch();
void Item_StartDespawn();
void Item_OnDespawn();

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

		if (self.respawn_time < 0)
			Item_StartDespawn();
	}
	else
	{
		self.alpha = 0;
		self.solid = SOLID_NOT;

		if (self.respawn_time < 0)
			Item_OnDespawn();
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
	self.pickup_time = 0;

	self.itemclass = true;

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
	self.respawn_time = WEAPON_RESPAWN_TIME;
	Item_InitSimple(SND_WEAPON_PICKUP);
}

void Item_InitAmmo()
{
	self.respawn_time = ITEM_RESPAWN_TIME;
	Item_InitSimple(SND_AMMO_PICKUP);
}

void Item_InitArmor()
{
	self.respawn_time = ARMOR_RESPAWN_TIME;
	Item_InitSimple(SND_ARMOR_PICKUP);
}

#ifdef CSQC
void Item_Update(float isnew)
{
	float new_movetype = self.movetype;
	float new_respawn_time = self.respawn_time;
	float new_pickup_time = self.pickup_time;
	int new_count = self.count;
	int active = 0;

	int flags = readInt();
	if (flags & SENDFLAGS_ORIGIN)
		self.origin = readVector();
	if (flags & SENDFLAGS_PHYSICS)
		new_movetype = readFloat();
	if (flags & SENDFLAGS_ITEM_INIT)
	{
		self.classname = readString();
		new_respawn_time = readFloat();
		new_count = readInt();
	}
	if (flags & SENDFLAGS_ITEM_ACTIVE)
	{
		active = readByte();
		new_pickup_time = readFloat();
	}

	if (isnew)
	{
		void() class_func = externvalue(-2, strtolower(self.classname));
		if (class_func)
			class_func();
	}

	self.respawn_time = new_respawn_time;
	self.pickup_time = new_pickup_time;

	if (flags & SENDFLAGS_ITEM_ACTIVE)
		Item_SetActive(active != 0);

	self.movetype = new_movetype;
	self.count = new_count;
}
#else
float Item_SendEntity(entity player, float flags)
{
	writeByte(MSG_ENTITY, SENDENTITY_ITEM);
	writeInt(MSG_ENTITY, (int)flags);

	if (flags & SENDFLAGS_ORIGIN)
		writeVector(MSG_ENTITY, self.origin);
	if (flags & SENDFLAGS_PHYSICS)
		writeFloat(MSG_ENTITY, self.movetype);
	if (flags & SENDFLAGS_ITEM_INIT)
	{
		writeString(MSG_ENTITY, self.classname);
		writeFloat(MSG_ENTITY, self.respawn_time);
		writeInt(MSG_ENTITY, (int)self.count);
	}
	if (flags & SENDFLAGS_ITEM_ACTIVE)
	{
		writeByte(MSG_ENTITY, Item_IsActive());
		writeFloat(MSG_ENTITY, self.pickup_time);
	}
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
	if (self.respawn_time < 0) // item is set to despawn
		return;

	self.think = Item_OnRespawn;
	self.nextthink = time + self.respawn_time;
}

void Item_OnDespawn()
{
#ifdef SSQC
	remove(self);
#endif
}

void Item_StartDespawn()
{
	if (self.respawn_time >= 0)
		return;

	self.think = Item_OnDespawn;
	self.nextthink = time + -self.respawn_time; // negative values are for despawning
}

void Item_OnPickup(entity source)
{
	self.last_touched = source;

	Item_StartRespawn();
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

	if (time < self.pickup_time)
		return;

	if (self.touch2 && !self.touch2())
		return;

	Item_OnPickup(other);
}

void Item_SetTouch(bool() ontouch)
{
	self.touch2 = ontouch;
}