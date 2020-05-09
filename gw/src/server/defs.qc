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
	WriteCoord(to, vec.x);
	WriteCoord(to, vec.y);
	WriteCoord(to, vec.z);
}
void writeVectorFloat(float to, vector vec)
{
	writeFloat(to, vec.x);
	writeFloat(to, vec.y);
	writeFloat(to, vec.z);
}

void writeEvent(float to, int event)
{
	writeByte(to, SVC_CGAMEPACKET);
	writeByte(to, event);
}

void precache_player_model(string modelname) {}