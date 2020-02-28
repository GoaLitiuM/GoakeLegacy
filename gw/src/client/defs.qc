entity local_player;
vector camera_origin;
vector camera_origin_old;
vector camera_velocity;

// map entities
.string target;
.string targetname;
.vector mangle;
.string message;

// items
.string simple_texture;

// player entity
.float health;
.float watertype;
.float fixangle;
.vector view_ofs;
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
.int client_flags;
.int client_pmove_flags;
.float client_jump_time;
.float client_jump_count;

// last received values from server, used with prediction
.vector server_origin;
.vector server_velocity;
.vector server_angles;
.int server_flags;
.int server_pmove_flags;
.float server_jump_time;
.float server_jump_count;

.float server_time; // last known time the player was updated, used with extrapolation

// not used by client
.float SendFlags;

float noop_predraw() { return PREDRAW_NEXT; }

entity getEntity(float entitynum)
{
	entity ent = nextent(world);
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
#define readShort readshort
#define readInt readint
#define readEntityNum readentitynum
#define readString readstring

vector readVector()
{
	vector vec;
	vec_x = readcoord();
	vec_y = readcoord();
	vec_z = readcoord();
	return vec;
}
vector readVectorFloat()
{
	vector vec;
	vec_x = readFloat();
	vec_y = readFloat();
	vec_z = readFloat();
	return vec;
}
entity readEntity()
{
	return getEntity(readEntityNum());
}

#define traceline_lagged traceline
