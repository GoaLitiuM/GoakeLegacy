const float CHAT_SHOW_TIME = 10.0f;

struct ChatLine
{
	string timestamp;
	int time;
	string source;
	string msg;
};

ChatLine* chatlines;
int chatlines_allocated_count;
int chatlines_count;

void Chat_NewMessage(string timestamp, string source, string msg)
{
	if (chatlines_count == chatlines_allocated_count)
	{
		int alloc_size = chatlines_allocated_count * 2;
		if (alloc_size == 0)
			alloc_size = 100;

		ChatLine* ptr = memalloc(sizeof(ChatLine) * alloc_size);
		chatlines_allocated_count = alloc_size;
		if (chatlines)
		{
			for (int i=0; i<chatlines_count; i++)
				memcpy(&ptr[i], &chatlines[i], sizeof(ChatLine));

			memfree(chatlines);
		}
		chatlines = ptr;
	}

	ChatLine* line = &chatlines[chatlines_count];
	chatlines_count++;

	line->timestamp = timestamp;
	line->time = cltime;
	line->source = source;
	line->msg = msg;

	println(timestamp, " ", source, ": ", msg);
}

void Chat_OnPrint(string printmsg)
{
	int msg_start = strstrofs(printmsg, ":");
	int len = strlen(printmsg);

	string source = strdecolorize(substring(printmsg, 0, msg_start));
	string msg = substring(printmsg, msg_start + 2, len - (msg_start + 3));

	// FIXME: we can't possibly know the real time this message was sent
	string timestamp = strftime(1, "%H:%M:%S");

	Chat_NewMessage(timestamp, source, msg);
}

void Hud_Chat(float width, float height)
{
	int spacing = font_chat->fontsize;
	int linenum = 0;
	float left = 8;
	float top = (height*0.70);
	int padding = 2;
	int line_width = 230;
	int maxlines = 8;

	bool chat_open = getkeydest() == 1;

	int lines_total = 0;
	for (int i=0; i<chatlines_count; i++)
	{
		ChatLine* line = &chatlines[i];
		if (!chat_open && cltime > line->time+CHAT_SHOW_TIME)
			continue;
		lines_total++;
	}

	if (chat_open)
		lines_total++;
	if (lines_total == 0)
		return;

	if (lines_total > 0)
	{
		drawfill([left-padding, top-padding, 0], [line_width + 2*padding, (lines_total*spacing) + 2*padding, 0], [0, 0, 0], 0.66);

		for (int i=0; i<chatlines_count; i++)
		{
			ChatLine* line = &chatlines[i];
			if (!chat_open && cltime > line->time+CHAT_SHOW_TIME)
				continue;

			if (linenum >= maxlines)
				break;

			string timestamp_str = strcat(line->timestamp, " ");
			string source_str = line->source;
			string msg_str = strcat(": ", line->msg);

			float offset = 0.0f;

			DrawText(font_chat, [left + offset, top, 0], timestamp_str, '1 1 1', 1);
			offset += TextWidth(font_chat, timestamp_str, false);

			DrawText(font_chat_bold, [left + offset, top, 0], source_str, '1 1 1', 1);
			offset += TextWidth(font_chat_bold, source_str, false);

			DrawText(font_chat, [left + offset, top, 0], msg_str, '1 1 1', 1);

			linenum++;
			top += spacing;
		}
	}

	if (chat_open)
	{
		string chat_buffer = getchatbuffer();
		//int chat_bufferpos = getchatbufferpos();
		DrawText(font_chat, [left, top, 0], strcat(chat_team ? "TEAM" : "", "> ", chat_buffer), '1 1 1', 1);
	}
}