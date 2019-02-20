// angles = [pitch, yaw, roll]
vector getForwardVector(vector angles)
{
	local vector old_forward = v_forward;
	local vector old_right = v_right;
	local vector old_up = v_up;

	makevectors(angles);

	local vector forward = v_forward;

	v_forward = old_forward;
	v_right = old_right;
	v_up = old_up;

	return forward;
}

float abs(float value)
{
	if (value >= 0)
		return value;
	return -value;
}

int sign(float value)
{
	if (value > 0)
		return 1;
	else if (value < 0)
		return -1;
	else
		return 0;
}

// returns random integer from given range (inclusive)
int randomInt(int first, int last)
{
	if (first == last)
		return first;

	return first + floor(random() * (last-first+1));
};
