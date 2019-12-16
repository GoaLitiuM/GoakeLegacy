// animation constants for Q3 player characters
enum
{
	BOTH_DEATH1,
	BOTH_DEAD1,
	BOTH_DEATH2,
	BOTH_DEAD2,
	BOTH_DEATH3,
	BOTH_DEAD3,
	TORSO_GESTURE,
	TORSO_ATTACK,
	TORSO_ATTACK2,
	TORSO_DROP,
	TORSO_RAISE,
	TORSO_STAND,
	TORSO_STAND2,
	LEGS_WALKCR,
	LEGS_WALK,
	LEGS_RUN,
	LEGS_BACK,
	LEGS_SWIM,
	LEGS_JUMP,
	LEGS_LAND,
	LEGS_JUMPB,
	LEGS_LANDB,
	LEGS_IDLE,
	LEGS_IDLECR,
	LEGS_TURN,

	NUMANIMS
};

// animation.cfg
struct AnimationFrame
{
	int startframe;
	int numframes; // can be negative!
	int loopframes;
	float frametime;
};

struct Model
{
	string name;
	AnimationFrame animations[NUMANIMS];
};

Model* models;
int models_count;
int models_allocated_count;

.int anim_model_index;
.int anim_index;
.float anim_time;
.float anim_frametime;
.int anim_loops; // how many times current animation is looped, -1 is infinite, 0 is stopped
.int anim_queued; // next animation in queue, to be played after frame2
.int anim_queued2; // next animation in queue, to be played after the loop finishes
.float anim_speed;
int Animation_GetNextFrame(int currentframe, int model, int animation)
{
	if (animation < 0 || animation >= NUMANIMS)
		return currentframe;

	AnimationFrame* animationFrame = &models[model]->animations[animation];

	// frames are played backwards when numframes is negative
	if (animationFrame->numframes > 0)
	{
		currentframe++;
		if (currentframe >= animationFrame->startframe + animationFrame->numframes)
			currentframe = animationFrame->startframe;
	}
	else if (animationFrame->numframes < 0)
	{
		currentframe--;
		if (currentframe < animationFrame->startframe)
			currentframe = animationFrame->startframe - animationFrame->numframes - 1;
	}
	return currentframe;
}

bool Model_AnimationIsPlaying(entity ent)
{
	if (ent.anim_loops == 0/* || ent.frame == ent.frame2*/)
		return false;
	return true;
}

void Model_PlayAnimation(entity ent, int animation, float speed, int repeats)
{
	if (animation < 0 || animation >= NUMANIMS)
	{
		println("invalid animation");
		return;
	}
	ent.anim_speed = speed;

	if (repeats > 0)
		ent.anim_loops = repeats;
	else
		ent.anim_loops = -1;

	// the animation is queued after frame2
	ent.anim_queued = animation;
	ent.anim_queued2 = animation;
}

// plays the animation after last one finishes
void Model_PlayAnimationNext(entity ent, int animation, float speed, int repeats)
{
	if (!Model_AnimationIsPlaying(ent))
	{
	}
	else if (ent.anim_index != animation)
	{
		ent.anim_speed = speed;
		if (repeats > 0)
			ent.anim_loops = repeats;
		else
			ent.anim_loops = -1;

		// queue the animation after loop ends
		ent.anim_queued2 = animation;
		return;
	}
	else if (ent.anim_queued2 != ent.anim_index)
		return; // do not queue if another animation is in queue


	Model_PlayAnimation(ent, animation, speed, repeats);
}

void Model_Animate(entity ent)
{
	if (ent.anim_index < 0 || ent.anim_index >= NUMANIMS)
		return;

	AnimationFrame* animation = &models[ent.anim_model_index]->animations[ent.anim_index];
	float anim_frametime = animation->frametime;

	if (anim_frametime == 0)
		return;

	ent.anim_time -= frametime * ent.anim_speed;
	while (ent.anim_time <= 0)
	{
		ent.anim_time += anim_frametime;
		ent.frame = ent.frame2;

		if (ent.anim_queued == ent.anim_index)
		{
			if (ent.anim_loops != 0)
			{
				int end_frame = animation->startframe + abs(animation->numframes) - 1;
				ent.frame2 = Animation_GetNextFrame(ent.frame2, ent.anim_model_index, ent.anim_index);
				if (ent.frame2 == end_frame) // last frame reached in loop
				{
					if (ent.anim_queued2 != ent.anim_index)
					{
						// transition to next animation after finishing this loop
						ent.anim_index = ent.anim_queued2;
						ent.anim_queued = ent.anim_queued2;
						ent.frame2 = models[ent.anim_model_index]->animations[ent.anim_queued2].startframe;
					}
					else if (ent.anim_loops > 0)
						ent.anim_loops--;
				}
			}
		}
		else
		{
			// transition to queued animation
			animation = &models[ent.anim_model_index]->animations[ent.anim_queued];
			ent.anim_index = ent.anim_queued;
			ent.anim_queued2 = ent.anim_queued;
			ent.frame2 = animation->startframe;
		}
	}

	if (anim_frametime > 0)
		ent.lerpfrac = (anim_frametime-ent.anim_time) / anim_frametime;
}

int GetModel(string modelname)
{
	// first model is a dummy, skip it
	for (int i=1; i<models_count; i++)
	{
		if (models[i].name == modelname)
			return i;
	}

	if (models_count == models_allocated_count)
	{
		int alloc_size = models_allocated_count * 2;
		if (alloc_size == 0)
			alloc_size = 2;

		Model* ptr = memalloc(sizeof(Model) * alloc_size);
		models_allocated_count = alloc_size;
		if (models)
		{
			for (int i=0; i<models_count; i++)
			{
				//memcpy(&ptr[i], &models[i], sizeof(Model);
				ptr[i].name = models[i].name;
				for (int j=0; j<NUMANIMS; j++)
				{
					ptr[i].animations[j].startframe = models[i].animations[j].startframe;
					ptr[i].animations[j].numframes = models[i].animations[j].numframes;
					ptr[i].animations[j].loopframes = models[i].animations[j].loopframes;
					ptr[i].animations[j].frametime = models[i].animations[j].frametime;
				}
				//ptr[i].animations = models[i].animations;
			}

			memfree(models);
		}
		else // insert dummy model data as first entry
			models_count++;
		models = ptr;
	}

	Model* model = &models[models_count];
	models_count++;

	// load model
	model->name = modelname;

	float cfgfile = fopen(strcat(modelname, "/animation.cfg"), FILE_READ);
	if (cfgfile < 0)
		error(strcat("failed to load ", modelname, "/animation.cfg"));

	int idx = 0;
	int leg_offset = 0;
	while (true)
	{
		string line = fgets(cfgfile);
		if not(line) // EOF
			break;
		else if (line == "")
			continue;

		tokenize(line);
		int chr = str2chr(line, 0);
		if (chr >= '0' && chr <= '9')
		{
			if (idx >= NUMANIMS)
				break;

			model->animations[idx].startframe = stoi(argv(0)) - leg_offset;
			model->animations[idx].numframes = stoi(argv(1));
			model->animations[idx].loopframes = stoi(argv(2));
			model->animations[idx].frametime = 1.0 / stoi(argv(3));

			// torso and leg animations share the same frames in the data
			if (idx == LEGS_WALKCR)
				leg_offset = model->animations[idx].startframe - model->animations[TORSO_GESTURE].startframe;

			idx++;
		}
	}
	fclose(cfgfile);

	return models_count-1;
}

void precache_player_model(string model)
{
	string lower = strcat(model, "/lower.md3");
	string upper = strcat(model, "/upper.md3");
	string head = strcat(model, "/head.md3");
	precache_model(lower);
	precache_model(upper);
	precache_model(head);
	GetModel(model); // preload animation data
}
