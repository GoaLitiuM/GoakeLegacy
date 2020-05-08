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

entity Game_GetRandomSpawn()
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
		return world;
	}

	ent = world;
	int spawn = randomInt(1, num_spawns);
	while (spawn > 0)
	{
		ent = find(ent, classname, "info_player_start");
		if (ent == world)
			break;
		spawn--;
	}

	if (ent == world)
		println("No spawn found for player.");

	return ent;
}