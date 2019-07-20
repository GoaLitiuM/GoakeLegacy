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

vector getUpVector(vector angles)
{
	local vector old_forward = v_forward;
	local vector old_right = v_right;
	local vector old_up = v_up;

	makevectors(angles);

	local vector up = v_up;

	v_forward = old_forward;
	v_right = old_right;
	v_up = old_up;

	return up;
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

	local const float biasfix = 0.5f/0x8000; // random() does not return 0 anymore
	return first + floor(((random() - biasfix) * 0x8000 / 0x7FFF) * (last-first+1));
};

// returns random value between 0 and 1 (inclusive)
inline float random2()
{
	return (random() * 0x8000) / 0x7FFF;
}

float randomFloat(float first, float last)
{
	if (first == last)
		return first;

	return first + random2() * (last-first);
}

float lerp(float a, float b, float t)
{
	return a * (1 - t) + b * t;
}

vector lerpvec(vector a, vector b, float t)
{
	return a * (1 - t) + b * t;
}
