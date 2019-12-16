int getKeyFromArg(int n)
{
	local string str = argv(n);
	if (str == "")
		return 0;
	if (str == "-1")
		return 0;

	return abs(stringtokeynum(str));
}

vector rotatevectorsbytag2(vector angles, entity ent, float tagnum)
{
	vector old_forward = v_forward;
	vector old_right = v_right;
	vector old_up = v_up;

	makevectors(angles);

	vector ret = rotatevectorsbytag(ent, tagnum);

	v_forward = old_forward;
	v_right = old_right;
	v_up = old_up;

	return ret;
}