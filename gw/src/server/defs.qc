.vector last_angles;
.float last_solid;
.float last_movetype;

#define writeFloat WriteFloat
#define writeByte WriteByte
#define writeShort WriteShort
#define writeInt WriteInt
#define writeEntity WriteEntity
#define writeString WriteString

void writeVector(float to, vector vec)
{
	WriteCoord(to, vec_x);
	WriteCoord(to, vec_y);
	WriteCoord(to, vec_z);
}
void writeVectorFloat(float to, vector vec)
{
	writeFloat(to, vec_x);
	writeFloat(to, vec_y);
	writeFloat(to, vec_z);
}

void writeEvent(float to, int event)
{
	writeByte(to, SVC_CGAMEPACKET);
	writeByte(to, event);
}

void precache_player_model(string modelname) {}