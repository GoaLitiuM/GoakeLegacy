//#pragma warning disable F210
#pragma warning disable Q207
#pragma warning disable F319

#define bool int
#define true 1
#define false 0

const float FL_JUMPRELEASED = 4096;

// legacy effects
const float TE_SUPERSPIKE = 1;
const float TE_EXPLOSION = 3;
const float TE_LIGHTNING2 = 6;
const float TE_LIGHTNINGBLOOD = 13;

float SVC_TEMPENTITY = 23;

#define FULLSEND 0xFFFFFF

// input_buttons
#define BUTTON_ATTACK 1
#define BUTTON_JUMP 2
#define BUTTON_USE 4

//pmove flags. seperate from flags
#define PMF_JUMP_HELD 1
#define PMF_LADDER 2
