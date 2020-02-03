float Item_PreDraw();

trisoup_simple_vert_s* simple_item_verts;
int* simple_item_indices;

#define VectorMA(a,s,b,c) do{(c)[0] = (a)[0] + (s)*(b)[0];(c)[1] = (a)[1] + (s)*(b)[1];(c)[2] = (a)[2] + (s)*(b)[2];}while(0)

void Item_InitClient()
{
	simple_item_verts = memalloc(sizeof(trisoup_simple_vert_s) * 4);
	simple_item_indices = memalloc(sizeof(int) * 6);

	simple_item_indices[0] = 0;
	simple_item_indices[1] = 1;
	simple_item_indices[2] = 2;
	simple_item_indices[3] = 2;
	simple_item_indices[4] = 1;
	simple_item_indices[5] = 3;

	vec4 white = {1, 1, 1, 1};

	simple_item_verts[0].st[0] = 0;
	simple_item_verts[0].st[1] = 1;
	simple_item_verts[0].rgba = white;

	simple_item_verts[1].st[0] = 0;
	simple_item_verts[1].st[1] = 0;
	simple_item_verts[1].rgba = white;

	simple_item_verts[2].st[0] = 1;
	simple_item_verts[2].st[1] = 1;
	simple_item_verts[2].rgba = white;

	simple_item_verts[3].st[0] = 1;
	simple_item_verts[3].st[1] = 0;
	simple_item_verts[3].rgba = white;
}

float Item_PreDraw()
{
	if (self.alpha <= 0)
		return PREDRAW_NEXT;

	const float size = 20;
	const float z_offset = 8;

	vector point;
	vector vup = getUpVector(view_angles);
	vector vright = getRightVector(view_angles);

	trisoup_simple_vert_s* v = &simple_item_verts[0];
	VectorMA (self.origin, -size, vup, point);
	VectorMA (point, -size, vright, (float*)&v.xyz);
	v.xyz[2] += z_offset;
	v.rgba[3] = self.alpha;

	v++;
	VectorMA (self.origin, size, vup, point);
	VectorMA (point, -size, vright, (float*)&v.xyz);
	v.xyz[2] += z_offset;
	v.rgba[3] = self.alpha;

	v++;
	VectorMA (self.origin, -size, vup, point);
	VectorMA (point, size, vright, (float*)&v.xyz);
	v.xyz[2] += z_offset;
	v.rgba[3] = self.alpha;

	v++;
	VectorMA (self.origin, size, vup, point);
	VectorMA (point, size, vright, (float*)&v.xyz);
	v.xyz[2] += z_offset;
	v.rgba[3] = self.alpha;

	addtrisoup_simple(self.simple_texture, 0, simple_item_verts, simple_item_indices, 6);
	return PREDRAW_NEXT;
}