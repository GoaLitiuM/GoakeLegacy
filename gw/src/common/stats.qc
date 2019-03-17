void RegisterFieldStat(int statnum, int stattype, .__variant fld);
void RegisterGlobalStat(int statnum, int stattype, __variant* ptr, string cvarname = "");

void RegisterStats()
{
	// register stats, maps fields to stats
	RegisterFieldStat(STAT_HEALTH, EV_FLOAT, health);
	RegisterFieldStat(STAT_CURRENT_WEAPON, EV_FLOAT, weapon);
	//RegisterFieldStat(STAT_NEXT_WEAPON, EV_FLOAT, weapon_next);
	RegisterFieldStat(STAT_WEAPONS, EV_INTEGER, weapons);
	RegisterFieldStat(STAT_RELOAD_TIME, EV_FLOAT, reload_time);

	for (int i=0; i<=STAT_AMMO_LAST-STAT_AMMO_NONE; i++)
		RegisterFieldStat(STAT_AMMO_NONE+i, EV_INTEGER, ammo[i]);

	// global stats are mapped to globals
	RegisterGlobalStat(STAT_AUTOJUMP, EV_FLOAT, &sv_autojump, "sv_autojump");
}

// attempt to emulate clientstat/globalstat in CSQC, and additionally maps cvars to variables
struct Stat
{
	int statnum;
	int stattype;

#ifdef CSQC
	.__variant fld;
	int value_int;
	float value_flt;
	string value_str;
#endif

	__variant* ptr;
	string cvarname;
};
Stat stats[256];
int stats_count;

#ifdef CSQC
void UpdatePlayerStats(bool forced = false)
{
	local int playernum;
	if (self.entnum == local_player.entnum)
		playernum = player_localnum;
	else
	{
		// TODO: figure out the player entity's player number
		playernum = 0;
	}

	if (self.entnum == local_player.entnum)
	{
		for (int i=0; i<stats_count; i++)
		{
			local Stat* stat = &stats[i];
			if (stat->ptr != 0)
				continue; // this is a global stat

			field_t __fld = stat->fld;
			local bool changed = forced;
			local int val_int = 0;
			local string val_str = 0;
			local float val_flt = 0;

			if (stat->stattype == EV_FLOAT)
			{
				val_flt = getplayerstat(playernum, stat->statnum, stat->stattype);
				changed |= stat.value_flt != val_flt;
			}
			else if (stat->stattype == EV_INTEGER)
			{
				val_int = getplayerstat(playernum, stat->statnum, stat->stattype);
				changed |= stat.value_int != val_int;
			}
			else if (stat->stattype == EV_STRING)
			{
				val_str = getplayerstat(playernum, stat->statnum, stat->stattype);
				changed |= stat.value_str != val_str;
			}
			else
				error("unsupported stattype");

			if (!changed)
				continue;

			if (stat->stattype == EV_FLOAT)
			{
				self.__fld = val_flt;
				stat->value_flt = val_flt;
			}
			else if (stat->stattype == EV_INTEGER)
			{
				self.__fld = val_int;
				stat->value_int = val_int;
			}
			else if (stat->stattype == EV_STRING)
			{
				self.__fld = val_str;
				stat->value_str = val_str;
			}
		}
	}
	else
	{
		// for other players, we forcefully update all the stats every frame
		for (int i=0; i<stats_count; i++)
		{
			local Stat* stat = &stats[i];
			if (stat->ptr != 0)
				continue; // this is a global stat

			field_t __fld = stat->fld;
			if (stat->stattype == EV_FLOAT)
				self.__fld = (float)getplayerstat(playernum, stat->statnum, stat->stattype);
			else if (stat->stattype == EV_INTEGER)
				self.__fld = (int)getplayerstat(playernum, stat->statnum, stat->stattype);
			else if (stat->stattype == EV_STRING)
				self.__fld = (string)getplayerstat(playernum, stat->statnum, stat->stattype);
			else
				error("unsupported stattype");
		}
	}
}
#endif

void UpdateGlobalStats(bool forced = false)
{
	// update global variables from cvar values or stats
	for (int i=0; i<stats_count; i++)
	{
		local Stat* stat = &stats[i];
		if (stat->ptr == 0)
			continue; // this is a field stat

		__variant* ptr = stat->ptr;
#ifdef CSQC
		local bool changed = forced;
		local int val_int = 0;
		local string val_str = 0;
		local float val_flt = 0;

		if (stat->stattype == EV_FLOAT)
		{
			val_flt = getstatf(stat->statnum);
			changed = stat.value_flt != val_flt;
		}
		else if (stat->stattype == EV_INTEGER)
		{
			val_int = getstati(stat->statnum);
			changed = stat.value_int != val_int;
		}
		else if (stat->stattype == EV_STRING)
		{
			val_str = getstats(stat->statnum);
			changed = stat.value_str != val_str;
		}
		else
			error("unsupported stattype");

		if (!changed)
			continue;

		if (stat->stattype == EV_FLOAT)
		{
			*ptr = val_flt;
			stat->value_flt = val_flt;
		}
		else if (stat->stattype == EV_INTEGER)
		{
			*ptr = val_int;
			stat->value_int = val_int;
		}
		else if (stat->stattype == EV_STRING)
		{
			*ptr = val_str;
			stat->value_str = val_str;
		}
#endif
#ifdef SSQC
		if (stat->cvarname == "")
			continue;

		if (stat->stattype == EV_FLOAT)
			*ptr = cvar(stat->cvarname);
		else if (stat->stattype == EV_INTEGER)
			*ptr = cvar(stat->cvarname);
		else if (stat->stattype == EV_STRING)
			*ptr = cvar_string(stat->cvarname);
		else
			error("unsupported stattype");
#endif
	}
}

void RegisterFieldStat(int statnum, int stattype, .__variant fld)
{
#ifdef CSQC
	stats[stats_count]->statnum = statnum;
	stats[stats_count]->stattype = stattype;
	stats[stats_count]->fld = fld;
	stats[stats_count]->ptr = 0;
	stats[stats_count]->cvarname = "";
	stats_count++;
#endif
#ifdef SSQC
	clientstat(statnum, stattype, fld);
#endif
}

void RegisterGlobalStat(int statnum, int stattype, __variant* ptr, string cvarname = "")
{
	local bool csqc = false;
#ifdef CSQC
	csqc = true;
#endif

	if (csqc || cvarname != "")
	{
		stats[stats_count]->statnum = statnum;
		stats[stats_count]->stattype = stattype;
		//stats[stats_count]->fld = 0;
		stats[stats_count]->ptr = ptr;
		stats[stats_count]->cvarname = cvarname;
		stats_count++;
	}
#ifdef SSQC
	pointerstat(statnum, stattype, ptr);
#endif
}
