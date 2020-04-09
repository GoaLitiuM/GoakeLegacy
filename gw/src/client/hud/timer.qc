void Hud_Timer(float width, float height)
{
	int minutes = gamemode_time / 60;
	int seconds = gamemode_time % 60;
	string time_str = sprintf("%02i:%02i", minutes, seconds);
	DrawTextShadow(font_main_med, [width*0.5 - TextWidth(font_main_med, time_str, 0)*0.5, 2, 0], time_str, '1 1 1', 1,  4, 1.35, '0 0 0', 1);
}