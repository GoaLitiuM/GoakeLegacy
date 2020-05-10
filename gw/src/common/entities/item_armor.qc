bool Armor_OnTouch()
{
	float new_armorvalue = self.armorvalue_min;
	if (other.armorvalue >= self.armorvalue_min)
		new_armorvalue = self.armorvalue_max;

	// pick up the armor if it offers more protection
	if (other.armorvalue * other.armortype >= new_armorvalue * self.armortype)
		return false;

	other.armorvalue = new_armorvalue;
	other.armortype = self.armortype;

	return true;
}

void item_armor_green()
{
	Item_InitArmor();
	Item_SetTouch(Armor_OnTouch);
	self.armorvalue_min = ARMOR_GREEN_MIN;
	self.armorvalue_max = ARMOR_GREEN_MAX;
	self.armortype = ARMOR_GREEN_ABSORB;
}

void item_armor_yellow()
{
	Item_InitArmor();
	Item_SetTouch(Armor_OnTouch);
	self.armorvalue_min = ARMOR_YELLOW_MIN;
	self.armorvalue_max = ARMOR_YELLOW_MAX;
	self.armortype = ARMOR_YELLOW_ABSORB;
}

void item_armor_red()
{
	Item_InitArmor();
	Item_SetTouch(Armor_OnTouch);
	self.armorvalue_min = ARMOR_RED_MIN;
	self.armorvalue_max = ARMOR_RED_MAX;
	self.armortype = ARMOR_RED_ABSORB;
}

bool ArmorShard_OnTouch()
{
	if (other.armorvalue >= self.armorvalue_max || other.armorvalue >= other.armorvalue_max)
		return false;

	other.armorvalue += self.count;
	if (other.armorvalue > self.armorvalue_max)
		other.armorvalue = self.armorvalue_max;
	if (other.armorvalue > other.armorvalue_max)
		other.armorvalue = other.armorvalue_max;
	return true;
}

void item_armor_shard()
{
	self.respawn_time = ARMOR_RESPAWN_TIME;
	Item_InitSimple(SND_HEALTH_PICKUP);

	Item_SetTouch(ArmorShard_OnTouch);
	self.armorvalue_min = 0;
	self.armorvalue_max = 200;
	self.armortype = 0;
	self.count = 5;
}