if not DuffTimer then DuffTimer = { } end

DuffTimer.wstrings = {}

--[[	Project: DuffTimer.	Project Author:  @project-author@ 
	Project Revision: @project-revision@	Project Version: @project-version@ 
	File Author: @file-author@	File Revision: @file-revision@   ]]

 --[===[@non-debug@ 
 
DuffTimer.wstrings[SystemData.Settings.Language.ENGLISH] = @localization(locale="enUS", format="lua_table", handle-unlocalized="english")@
DuffTimer.wstrings[SystemData.Settings.Language.FRENCH] = @localization(locale="frFR", format="lua_table", handle-unlocalized="english")@
DuffTimer.wstrings[SystemData.Settings.Language.GERMAN] = @localization(locale="deDE", format="lua_table", handle-unlocalized="english")@
DuffTimer.wstrings[SystemData.Settings.Language.ITALIAN] = @localization(locale="itIT", format="lua_table", handle-unlocalized="english")@
DuffTimer.wstrings[SystemData.Settings.Language.SPANISH] = @localization(locale="esES", format="lua_table", handle-unlocalized="english")@
DuffTimer.wstrings[SystemData.Settings.Language.KOREAN] = @localization(locale="koKR", format="lua_table", handle-unlocalized="english")@
DuffTimer.wstrings[SystemData.Settings.Language.S_CHINESE] = @localization(locale="zhCN", format="lua_table", handle-unlocalized="english")@
DuffTimer.wstrings[SystemData.Settings.Language.T_CHINESE] = @localization(locale="zhTW", format="lua_table", handle-unlocalized="english")@
DuffTimer.wstrings[SystemData.Settings.Language.JAPANESE] = @localization(locale="jaJP", format="lua_table", handle-unlocalized="english")@
DuffTimer.wstrings[SystemData.Settings.Language.RUSSIAN] = @localization(locale="ruRU", format="lua_table", handle-unlocalized="english")@

--@end-non-debug@]===]

 --@debug@
 
local wstrings = 
{
	MINTEXT = L"Minimum Text Scale",
	ADVOPTIONS = L"Advanced Options",
	ALL = L"All",
	APPLY = L"Apply",
	ATTACH = L"Attach to world object",
	BAR = L"Bar",
	BARALPHA = L"Bar Alpha",
	BGALPHA = L"Bar BGAlpha",
	BTYPE = L"Bar type",
	BUFF = L"Buff",
	CBO = L"Cast By Others",
	CBS = L"Cast By Self",
	CGROW = L"Column growth direction",
	CICONS = L"Maximum Columns",
	CLASSICCOLORS = L"Simplify Colors",
	DEBUFF = L"Debuff",
	DEFAULT = L"Default",
	DOWN = L"Down",
	DTOPTIONS = L"DuffTimer Options",
	DWIN = L"DuffTimer Win",
	ENABLE = L"Enable Window",
	EXPIRING = L"Expiring",
	FONT = L"Text Font",
	FRIEND = L"Friendly",
	FRTARGET = L"Friendly Target",
	GENSET = L"General Settings",
	GROUP = L"Group",
	HOST = L"Hostile",
	HOTARGET = L"Hostile Target",
	ICON = L"Icon",
	ICONALPHA = L"Icon Alpha",
	ICONBAR = L"IconBar",
	LEFT = L"Left",
	MAXDUR = L"Maximum Duration (secs)",
	MEMBER = L"Member",
	MINDUR = L"Minimum Duration (secs)",
	MOVELEFT = L"Move Left",
	MOVERIGHT = L"Move Right",
	NONE = L"None",
	NORMAL = L"Normal",
	PERM = L"Show Permanent Effects",
	PLAY = L"Player",
	REFRESH = L"Refresh Rate",
	REVERSE = L"Reverse",
	REVERT = L"Revert",
	RGROW = L"Row growth direction",
	RICONS = L"Maximum Rows",
	RIGHT = L"Right",
	RSORT = L"Reverse sort direction",
	SAVE = L"Save",
	SORT = L"Sort Order",
	TALPHA = L"Text alpha",
	TEST = L"Test",
	TEXTALPHA = L"Text Alpha",
	TEXTURE = L"Texture",
	TOOLTIP = L"Tooltip location",
	TT_ATTACH = L"Check to have window attach to target.  This has no effect on the player windows.",
	TT_BALPHA = L"Set the opacity of the bars.",
	TT_BGALPHA = L"Set the opacity of the bars backgrounds.",
	TT_CGROW = L"Setting this to the same or opposite direction as the rows will not look good.",
	TT_ENABLE = L"Uncheck to disable this window.",
	TT_HORTEX = L"Texture used for horizontal status bars.",
	TT_ICONALPHA = L"Set the opacity of the icons.",
	TT_MAX = L"Set to 0 for no maximum.",
	TT_MIN = L"Set to 0 for no minimum.",
	TT_REFRESH = L"Set the rate the refresh bars redraw.",
	TT_ROWS = L"Regardless of direction rows are filled first, then columns.",
	TT_SORT = L"Default - Cast by Player, Buff/Debuff, Duration.  Expiring - Soonest to expire first.",
	TT_TALPHA = L"Set the opacity of the text.",
	TT_TESTMODE = L"Toggle test mode.  Shows unsaved changes, toggle again to update.",
	TT_UNL = L"Set to 0 for unlimited.",
	TT_VERTEX = L"Texture used for vertical status bars.",
	TT_YWORLD = L"Vertical offset from world object.",
	UP = L"Up",
	WIN = L"Windows",
	WINDOWS = L"Number of separate buff windows.",
	WINTYPE = L"Window Type",
	["X"] = L"X:",
	XWORLD = L"Horizontal offset from world object.",
	["Y"] = L"Y:",
}

DuffTimer.wstrings[SystemData.Settings.Language.ENGLISH] = wstrings
DuffTimer.wstrings[SystemData.Settings.Language.FRENCH] = wstrings
DuffTimer.wstrings[SystemData.Settings.Language.GERMAN] = wstrings
DuffTimer.wstrings[SystemData.Settings.Language.ITALIAN] = wstrings
DuffTimer.wstrings[SystemData.Settings.Language.SPANISH] = wstrings
DuffTimer.wstrings[SystemData.Settings.Language.KOREAN] = wstrings
DuffTimer.wstrings[SystemData.Settings.Language.S_CHINESE] = wstrings
DuffTimer.wstrings[SystemData.Settings.Language.T_CHINESE] = wstrings
DuffTimer.wstrings[SystemData.Settings.Language.JAPANESE] = wstrings
DuffTimer.wstrings[SystemData.Settings.Language.RUSSIAN] = wstrings

--@end-debug@
 

