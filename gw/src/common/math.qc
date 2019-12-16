// angles = [pitch, yaw, roll]

vector getForwardVector(vector angles)
{
	vector old_forward = v_forward;
	vector old_right = v_right;
	vector old_up = v_up;

	makevectors(angles);

	vector forward = v_forward;

	v_forward = old_forward;
	v_right = old_right;
	v_up = old_up;

	return forward;
}

vector geRightVector(vector angles)
{
	vector old_forward = v_forward;
	vector old_right = v_right;
	vector old_up = v_up;

	makevectors(angles);

	vector right = v_right;

	v_forward = old_forward;
	v_right = old_right;
	v_up = old_up;

	return right;
}

vector getUpVector(vector angles)
{
	vector old_forward = v_forward;
	vector old_right = v_right;
	vector old_up = v_up;

	makevectors(angles);

	vector up = v_up;

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

	const float biasfix = 0.5f/0x8000; // random() does not return 0 anymore
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

// vectoyaw but doesn't truncate the angle
float vectoyaw2(vector vec)
{
	float yaw;
	if (vec_y == 0 && vec_x == 0)
		yaw = 0;
	else
	{
		yaw = atan2(vec_y, vec_x) * 180 / M_PI;
		if (yaw < 0)
			yaw += 360;
	}
	return yaw;
}

// rotates vector towards target vector via shortest route
vector rotatevectovec(vector source, vector target, float degrees)
{
	if (source == target)
		return target;

	float ty = vectoyaw2(target);
	float ty2 = ty + 360;
	float sy = vectoyaw2(source);
	float sy2 = sy + 360;

	float delta = ty-sy;
	if (abs(ty-sy2) < abs(delta))
		delta = ty-sy2;
	if (abs(ty2-sy) < abs(delta))
		delta = ty2-sy;

	if (delta < 0)
	{
		delta += degrees;
		if (delta > 0)
			delta = 0;
	}
	else if (delta > 0)
	{
		delta -= degrees;
		if (delta < 0)
			delta = 0;
	}

	sy = ty-delta;
	if (sy < 0)
		sy += 360;

	return getForwardVector([0, sy, 0]);
}