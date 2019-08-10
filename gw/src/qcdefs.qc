//#pragma warning disable F210
#pragma warning disable Q207
#pragma warning disable F319

#define bool int
#define true 1
#define false 0

#ifdef SSQC
const float MSG_BROADCAST = 0;    /* The byte(s) will be unreliably sent to all players. MSG_ constants are valid arguments to the Write* builtin family. */
const float MSG_ONE = 1;    /* The byte(s) will be reliably sent to the player specified in the msg_entity global. WARNING: in quakeworld servers without network preparsing enabled, this can result in illegible server messages (due to individual reliable messages being split between multiple backbuffers/packets). NQ has larger reliable buffers which avoids this issue, but still kicks the client. */
const float MSG_ALL = 2;    /* The byte(s) will be reliably sent to all players. */
const float MSG_INIT = 3;    /* The byte(s) will be written into the signon buffer. Clients will see these messages when they connect later. This buffer is only flushed on map changes, so spamming it _WILL_ result in overflows. */
#endif

const float FL_JUMPRELEASED = 4096;

// legacy effects
const float TE_SUPERSPIKE = 1;
const float TE_EXPLOSION = 3;
const float TE_LIGHTNING2 = 6;
const float TE_LIGHTNINGBLOOD = 13;

float SVC_TEMPENTITY = 23;

// input_buttons
#define BUTTON_ATTACK 1
#define BUTTON_JUMP 2
#define BUTTON_USE 4

//pmove flags. seperate from flags
#define PMF_JUMP_HELD 1
#define PMF_LADDER 2

int ModInt(int a, int b)
{
	return a - (b * (a/b));
}