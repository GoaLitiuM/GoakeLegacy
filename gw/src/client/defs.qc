entity local_player;
vector camera_origin;
vector camera_origin_old;
vector camera_velocity;

// map entities
.string target;
.string targetname;
.vector mangle;
.string message;

// player entity
.float health;
.float watertype;
.float fixangle;
float fixanglefix;
float weapon_impulse;
.entity beam_ent;	// player's active lightning beam, updated in predraw

// teleport entity
.string targetname;
.string target;

// latest predicted values in client, should match the real values
.vector client_origin;
.vector client_velocity;
.vector client_angles;
.float client_flags;
.float client_pmove_flags;
.float client_jump_time;
.float client_jump_count;

// last received values from server, used with prediction
.vector server_origin;
.vector server_velocity;
.vector server_angles;
.float server_flags;
.float server_pmove_flags;
.float server_jump_time;
.float server_jump_count;

float noop_predraw() { return PREDRAW_NEXT; }

entity getEntity(float entitynum)
{
	local entity ent = nextent(world);
	while (ent != world)
	{
		if (ent.entnum == entitynum)
			break;
		ent = nextent(ent);
	}
	return ent;
}

#define readFloat readfloat
#define readByte readbyte
#define readEntityNum readentitynum

vector readVector()
{
	local vector vec;
	vec_x = readcoord();
	vec_y = readcoord();
	vec_z = readcoord();
	return vec;
}
vector readVectorFloat()
{
	local vector vec;
	vec_x = readFloat();
	vec_y = readFloat();
	vec_z = readFloat();
	return vec;
}
entity readEntity()
{
	return getEntity(readEntityNum());
}
