bool Player_IsPlaying(entity player);

int Game_CountClients()
{
	int total_clients = 0;
	entity player = world;
	while (true)
	{
		player = find(player, classname, CLASS_PLAYER);
		if (player == world)
			break;

		total_clients++;
	}

	return total_clients;
}

int Game_CountPlayers()
{
	int total_players = 0;
	entity player = world;
	while (true)
	{
		player = find(player, classname, CLASS_PLAYER);
		if (player == world)
			break;

		if (!Player_IsPlaying(player))
			continue;

		total_players++;
	}

	return total_players;
}

int Game_CountPlayersReady()
{
	int ready_players = 0;
	entity player = world;
	while (true)
	{
		player = find(player, classname, CLASS_PLAYER);
		if (player == world)
			break;

		if (!Player_IsPlaying(player))
			continue;

		if (infokeyf(player, "ready") != 0)
			ready_players++;
	}

	return ready_players;
}

entity Game_GetPlayerWithMostFrags()
{
	entity leader = world;
	int leader_frags = -99999;

	entity player = world;
	while (true)
	{
		player = find(player, classname, CLASS_PLAYER);
		if (player == world)
			break;

		if (!Player_IsPlaying(player))
			continue;

		int player_frags = infokeyf(player, "*frags");
		if (player_frags > leader_frags)
		{
			leader_frags = player_frags;
			leader = player;
		}
		else if (player_frags == leader_frags)
			leader = world; // tie, nobody should win
	}

	return leader;
}

int spawns_blocked = 0;
entity Game_GetRandomSpawn(entity player, entity skip_spawn = 0)
{
	entity ent = world;

	int num_spawns = 0;
	while (true)
	{
		ent = find(ent, classname, "info_player_start");
		if (ent == world)
			break;
		num_spawns++;
	}

	if (num_spawns == 0)
	{
		println("Map does not have any spawn entities.");
		spawns_blocked = 0;
		return world;
	}

	if (skip_spawn != world)
		num_spawns--;

	ent = world;
	int spawn = randomInt(1, num_spawns);
	while (spawn > 0)
	{
		ent = find(ent, classname, "info_player_start");
		if (ent == world)
			break;
		if (skip_spawn != world && ent == skip_spawn)
			continue;
		spawn--;
	}

	if (ent == world)
	{
		println("No spawn found for player.");
		spawns_blocked = 0;
		return world;
	}

	vector check_origin = ent.origin + '0 0 0.1';
	vector check_min = PLAYER_SIZE_MIN;
	vector check_max = PLAYER_SIZE_MAX;
	tracebox(check_origin, check_min, check_max, check_origin + '0 0 0.1', 0, player);

	if (/*trace_startsolid ||*/ trace_allsolid || trace_ent != world)
	{
		dprintln("Entity ", trace_ent.classname, " is blocking a spawn");

		if (spawns_blocked > 50)
		{
			println("Warning, no free spawn found for player.");
			spawns_blocked = 0;
			return ent;
		}
		spawns_blocked++;
		return Game_GetRandomSpawn(player, ent);
	}

	spawns_blocked = 0;
	return ent;
}

void Game_DropPlayerWeapon(entity player)
{
	Weapon* weapon_def = &weapon_defs[player.weapon];
	void() weapon_func = externvalue(-2, strtolower(weapon_def.entname));

	if (!weapon_func)
	{
		println("Player tried dropping unknown weapon: '", weapon_def.entname, "'");
		return;
	}

	int ammo_index = WEAPON_AMMO_INDEX(player.weapon);
	int player_ammo = player.ammo[ammo_index];

	if (player_ammo <= 0)
		return;

	entity dropped_weapon = spawn();
	dropped_weapon.classname = weapon_def.entname;
	dropped_weapon.origin = player.origin;
	setorigin(dropped_weapon, dropped_weapon.origin);

	{
		entity oldself = self;
		self = dropped_weapon;

		if (weapon_func)
			weapon_func();

		dropped_weapon.respawn_time = -WEAPON_DESPAWN_TIME;
		Item_SetActive(true);

		self = oldself;
	}

	int drop_count = dropped_weapon.count;
	if (player_ammo < drop_count)
		drop_count = player_ammo; // prevent abuse

	dropped_weapon.movetype = MOVETYPE_TOSS;
	dropped_weapon.count = -drop_count; // always adds ammo
	dropped_weapon.pickup_time = time + 1;

	if (!Player_IsDead(player))
	{
		int weapon_bit = WEAPON_BIT(player.weapon);

		player.weapons &= ~weapon_bit;
		player.ammo[ammo_index] = 0;
	}
}