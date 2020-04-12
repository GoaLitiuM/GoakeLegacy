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

// remap Q1 items

void item_armor1()
{
	self.classname = "item_armor_green";
	item_armor_green();
}

void item_armor2()
{
	self.classname = "item_armor_yellow";
	item_armor_yellow();
}

void item_armorInv()
{
	self.classname = "item_armor_red";
	item_armor_red();
}