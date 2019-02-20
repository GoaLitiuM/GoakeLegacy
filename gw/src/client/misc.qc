int getKeyFromArg(int n)
{
	local string str = argv(n);
	if (str == "")
		return 0;
	if (str == "-1")
		return 0;

	return abs(stringtokeynum(str));
}
