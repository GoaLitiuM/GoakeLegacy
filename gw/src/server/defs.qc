#define writeFloat WriteFloat
#define writeByte WriteByte
#define writeEntity WriteEntity

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

void precache_player_model(string modelname) {}