void RaceStart_OnTouch();
void RaceCheckpoint_OnTouch();
void RaceEnd_OnTouch();

void race_start()
{
	setmodel(self, self.model);
	self.model = "";
	self.modelindex = 0;

	self.solid = SOLID_TRIGGER;
	self.movetype = MOVETYPE_NONE;
	self.touch = RaceStart_OnTouch;
}

void race_checkpoint()
{
	setmodel(self, self.model);
	self.model = "";
	self.modelindex = 0;

	self.solid = SOLID_TRIGGER;
	self.movetype = MOVETYPE_NONE;
	self.touch = RaceCheckpoint_OnTouch;
}

void race_end()
{
	setmodel(self, self.model);
	self.model = "";
	self.modelindex = 0;

	self.solid = SOLID_TRIGGER;
	self.movetype = MOVETYPE_NONE;
	self.touch = RaceEnd_OnTouch;
}

void RaceStart_OnTouch()
{
	if (other.classname != CLASS_PLAYER)
		return;

	if (!other.race_started || time-other.race_start_time > 1)
	{
#ifdef CSQC
		Chat_SystemMessage("Race Started...", CHAT_TYPE_RACE);
#else
		println(CLSV, "Race started...");
#endif
	}

	other.race_start_time = time;
	other.race_started = true;
}

void RaceCheckpoint_OnTouch()
{
	if (other.classname != CLASS_PLAYER)
		return;

	if (!other.race_started)
		return;
}

void RaceEnd_OnTouch()
{
	if (other.classname != CLASS_PLAYER)
		return;

	if (!other.race_started)
		return;

	float race_time = time - other.race_start_time;
	other.race_started = false;

#ifdef CSQC
	Chat_SystemMessage(strcat("Time: ", ftos(race_time), "s"), CHAT_TYPE_RACE);
#else
	println(CLSV, "Time: ", ftos(race_time), "s");
#endif
}