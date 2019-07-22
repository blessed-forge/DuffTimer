if not DuffTimer then DuffTimer = { } end
if not DuffTimer then DuffTimer = { } end
--[[	Project: DuffTimer.	Project Author:  Thurwell	Project Date: 2009-05-09T04:47:09Z
	Project Revision: 129	Project Version: v2.2.3 
	File Author: Thurwell	File Revision: 129	File Date:	2009-05-09T04:47:09Z	]]

local T
if not T then T = DuffTimer.wstrings[SystemData.Settings.Language.active] end

DuffTimer.Fonts = { L"font_default_text_small",
L"font_alert_outline_half_large",L"font_alert_outline_tiny" ,L"font_chat_text_bold" ,L"font_chat_text_no_outline" ,L"font_clear_default",L"font_clear_small",
L"font_clear_small_bold" ,L"font_default_text",L"font_default_text_no_outline",L"font_heading_tiny_no_shadow" ,L"font_heading_rank" ,
L"font_heading_unitframe_con",L"font_journal_body" ,L"font_guild_MP_R_17", }

DuffTimer.WindowTypes = { 
	-- Order these the same as the edit boxes so that translation on the numbers is not necessary
	{ name=T.FRTARGET, buffType=GameData.BuffTargetType.TARGET_FRIENDLY, target="selffriendlytarget"},
	{ name=T.HOTARGET, buffType=GameData.BuffTargetType.TARGET_HOSTILE, target="selfhostiletarget"},
	{ name=T.PLAY, buffType=GameData.BuffTargetType.SELF},
	{ name=T.GROUP, buffType=GameData.BuffTargetType.GROUP_MEMBER_START+0}, 
	{ name=T.GROUP, buffType=GameData.BuffTargetType.GROUP_MEMBER_START+1}, 
	{ name=T.GROUP, buffType=GameData.BuffTargetType.GROUP_MEMBER_START+2}, 
	{ name=T.GROUP, buffType=GameData.BuffTargetType.GROUP_MEMBER_START+3}, 
	{ name=T.GROUP, buffType=GameData.BuffTargetType.GROUP_MEMBER_START+4}, 
	{ name=T.GROUP, buffType=GameData.BuffTargetType.GROUP_MEMBER_START+5}, 
}

DuffTimer.BarTypes = { "DuffTimer_Icon", "DuffTimer_IconBar", "DuffTimer_Bar", "DuffTimer_ReverseBar", }

DuffTimer.sort_parameters = {
	{    -- Default
		{ name="castByPlayer", reverse=false, },
		{ name="buff", reverse=false, },
		{ name="permanentUntilDispelled", reverse=false },
		{ name="duration", reverse=true, },
		{ name="name", reverse=true, },
	},
	{    -- Expiring
		{ name="permanentUntilDispelled", reverse=true },
		{ name="duration", reverse=false, },
		{ name="castByPlayer", reverse=false, },
		{ name="buff", reverse=false, },
	},
}
DuffTimer.reverse_sort_parameters = { }

local BarDefaults = {
	windowType = 3,
	worldAttach = false,
	maxRows = 0,
	showPermanent = true,
	minDuration = 0,
	enable = true,
	scale = 1,
	castByOthers = 1,
	rowGrowth = 4,
	reverseSort = false,
	tooltip = 2,
	sortOrder = 1,
	maxColumns = 1,
	worldY = 0,
	maxDuration = 0,
	columnGrowth = 2,
	castBySelf = 1,
	barType = 3,
	worldX = 0,
}

function DuffTimer.InitializeDefaults()
	if not DuffTimer.SavedSettings
	then
		if DuffTimerSettings.SavedSettings then DuffTimer.SavedSettings = DuffTimerSettings.SavedSettings
		else
			DuffTimer.SetDefaults()
		end
	end
	DuffTimer.InitializeDefaultBars()
	if not DuffTimer.SavedSettings.iconOpacity then DuffTimer.SavedSettings.iconOpacity = 1 end
	if not DuffTimer.SavedSettings.classicColors then DuffTimer.SavedSettings.classicColors = false end
	if not DuffTimer.SavedSettings.scaleText then DuffTimer.SavedSettings.scaleText = 0.5 end
	if not DuffTimer.SavedSettings.textOpacity then DuffTimer.SavedSettings.textOpacity = 1 end

end

function DuffTimer.InitializeDefaultBars()
	for k = 1, DuffTimer.SavedSettings.windows, 1 do
		if not DuffTimer.SavedSettings.Bar[k] then
			DuffTimer.SavedSettings.Bar[k] = DuffTimer.TableCopy(BarDefaults)
		end
	end
end

function DuffTimer.TableCopy(object)
	if (object == nil) then
		return nil
	end
	local lookup_table = {}
	local function _copy(object)
		if type(object) ~= "table" then
			return object
		elseif lookup_table[object] then
			return lookup_table[object]
		end
		local new_table = {}
		lookup_table[object] = new_table
		for index, value in pairs(object) do
			new_table[_copy(index)] = _copy(value)
		end
		return setmetatable(new_table, getmetatable(object))
	end
	return _copy(object)
end

function DuffTimer.SetDefaults()
	DuffTimer.SavedSettings = 
	{
		barBGOpacity = 0.5,
		classicColors = false,
		iconOpacity = 1,
		verticalTextureName = "squared_h_gradient2",
		barOpacity = 1,
		textOpacity = 1,
		font = 1,
		horizontalTextureName = "squared_h_gradient2",
		verticalTexture = 10,
		windows = 3,
		refreshRate = 0.1,
		horizontalTexture = 10,
		Bar = { DuffTimer.TableCopy(BarDefaults), DuffTimer.TableCopy(BarDefaults), DuffTimer.TableCopy(BarDefaults), },
	}
	DuffTimer.SavedSettings.Bar[1].windowType=1
	DuffTimer.SavedSettings.Bar[2].windowType=2
end