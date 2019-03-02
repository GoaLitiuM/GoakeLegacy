void UpdateStat(__variant* ptr, int statnum, int stattype, string cvarname);

#ifdef SSQC
void RegisterStats()
{
	// register stats, maps fields to stats
	clientstat(STAT_HEALTH, EV_INTEGER, health);

	// global stats are mapped to globals
	pointerstat(STAT_AUTOJUMP, EV_FLOAT, &sv_autojump);
}
#endif

#ifdef CSQC
void UpdatePlayerStats()
{
	local int playernum;
	if (self.entnum == local_player.entnum)
		playernum = player_localnum;
	else
	{
		// TODO: figure out the player entity's player number
		playernum = 0;
	}

	self.health = getplayerstat(playernum, STAT_HEALTH, EV_INTEGER);
}
#endif

void UpdateGlobalStats()
{
	// update global variables from cvar values or stats
	UpdateStat(&sv_autojump, STAT_AUTOJUMP, EV_FLOAT, "sv_autojump");
}

void UpdateStat(__variant* ptr, int statnum, int stattype, string cvarname)
{
#ifdef SSQC
	if (stattype == EV_STRING)
		*ptr = cvar_string(cvarname);
	else if (stattype == EV_FLOAT)
		*ptr = cvar(cvarname);
	else if (stattype == EV_INTEGER)
		*ptr = cvar(cvarname);
	else
		error(strcat("Unsupported stattype for SSQC::UpdateStat: ", ftos(stattype), ".\n"));
#endif
#ifdef CSQC
	if (stattype == EV_STRING)
		*ptr = getstats(statnum);
	else if (stattype == EV_FLOAT)
		*ptr = getstatf(statnum);
	else if (stattype == EV_INTEGER)
		*ptr = getstati(statnum);
	else
		error(strcat("Unsupported stattype for CSQC::UpdateStat: ", ftos(stattype), ".\n"));
#endif
}
