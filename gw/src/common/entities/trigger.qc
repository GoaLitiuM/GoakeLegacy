void TriggerHurt_OnTouch()
{
	if (self.dmg > 0)
		applyEntityDamage(other, (float)self.dmg, self);
}

void trigger_hurt()
{
	self.touch = TriggerHurt_OnTouch;
	self.solid = SOLID_TRIGGER;
	setmodel (self, self.model);
	self.movetype = MOVETYPE_NONE;
	self.modelindex = 0;
	self.model = "";
}

void TriggerPush_OnTouch()
{
	if (self.pushforce > 0)
	{
		vector force;
		if (self.angles == '0 -1 0')
			force = '0 0 1';
		else if (self.angles == '0 -2 0')
			force = '0 0 -1';
		else
		{
			makevectors(self.angles);
			force = v_forward;
		}

		other.velocity = '0 0 0';
		force = force * self.pushforce * 10;
		applyEntityForce(other, force, self);
	}
}

static .float speed; // QW

void trigger_push()
{
	self.pushforce = self.speed;

	self.touch = TriggerPush_OnTouch;
	self.solid = SOLID_TRIGGER;
	setmodel (self, self.model);
	self.movetype = MOVETYPE_NONE;
	self.modelindex = 0;
	self.model = "";
}