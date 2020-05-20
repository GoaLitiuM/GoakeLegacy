#ifdef CSQC
void ReadProjectile(float isnew, void(entity) init_func)
{
	self.origin = readVector();
	self.angles = readVector();
	self.velocity = readVector();
	self.owner = readEntity();

	if (isnew)
	{
		self.server_projectile = true;
		init_func(self);

		if (self.owner == local_player)
			self.drawmask = 0;
	}

	setorigin(self, self.origin);
}
#endif

#ifdef SSQC
void WriteProjectile(float chan, int type)
{
	writeByte(chan, type);
	writeVector(chan, self.origin);
	writeVector(chan, self.angles);
	writeVector(chan, self.velocity);
	writeEntity(chan, self.owner);
}
#endif