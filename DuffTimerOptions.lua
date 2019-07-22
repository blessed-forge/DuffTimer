if not DuffTimer then DuffTimer = { } end
if not DuffTimer then DuffTimer = { } end
--[[	Project: DuffTimer.	Project Author:  Thurwell	Project Date: 2009-05-09T04:47:09Z
	Project Revision: 129	Project Version: v2.2.3 
	File Author: Thurwell	File Revision: 129	File Date:	2009-05-09T04:47:09Z	]]

 --@non-debug@ 
 local VERSION =  L"v2.2.3"
 --@end-non-debug@
 
 --[===[@debug@
 local VERSION =  L"Debug" 
 --@end-debug@]===]

DuffTimer.Options = {}

local VPWindowName = "DuffTimerOptions"

local T
if not T then T = DuffTimer.wstrings[SystemData.Settings.Language.active] end
local tab_list = {  }
local contextId = nil
local tabWindowAnchor
local ADV_DIM = { 350, 300 }
local GENERAL_ADV_DIM = { 350, 375 }
local LAST_BUTTON = "DuffTimerOptions_GeneralTabScroll_Adv_scaleText"
local addon_buttons = { }
DuffTimer.textures = { }
local bar_types = { T.ICON, T.ICONBAR, T.NORMAL, T.REVERSE, }

local options = {
	["refresh"] = {type="editbox", var="refreshRate", func=nil, label=T.REFRESH, tooltip=T.TT_REFRESH, tabs={ 1 }, mask=L"%.2f", min = 0, max = 10, round = 2 },
	["alpha"] = {type="slider", var="barOpacity", func=nil, label=T.BARALPHA, tooltip=T.TT_BALPHA, tabs={ 1 }, mult=1, mask=L"%.2f"},
	["BGalpha"] = {type="slider", var="barBGOpacity", func=nil, label=T.BGALPHA, tooltip=T.TT_BGALPHA, tabs={ 1 }, mult=1, mask=L"%.2f"},
	["textAlpha"] = {type="slider", var="textOpacity", func=nil, label=T.TALPHA, tooltip=T.TT_TALPHA, tabs={ 1 }, mult=1, mask=L"%.2f"},
	["iconAlpha"] = {type="slider", var="iconOpacity", func=nil, label=T.ICONALPHA, tooltip=T.TT_ICONALPHA, tabs={ 1 }, mult=1, mask=L"%.2f"},
	["windows"] = {type="editbox", var="windows", func=nil, label=T.WIN, tooltip=T.WINDOWS, tabs={ 1, }, min=1,max=9, round=0, mask=L"%.0f"},
	["Adv_font"] = {type="combo", var="font", func=nil, label=T.FONT, tooltip=nil, tabs={ 1, }, values = DuffTimer.Fonts, },
	["Adv_horizontalTexture"] = {type="combo", var="horizontalTexture", func=nil, label=T.TEXTURE, tooltip=T.TT_HORTEX, tabs={ 1, }, values = { 1, }, },
	["Adv_verticalTexture"] = {type="combo", var="verticalTexture", func=nil, label=T.TEXTURE, tooltip=T.TT_VERTEX, tabs={ 1, }, values = { 1, }, },
	["Adv_classicColors"] = {type="check", var="classicColors", func=nil, label=T.CLASSICCOLORS, tooltip=nil, tabs={1,}, },
	["Adv_scaleText"] = {type="editbox", var="scaleText", func=nil, label=T.MINTEXT, tooltip=nil, tabs={1,}, mask=L"%.2f", min=0.1, round=2 },
	["enable"] = {type="check", var="enable", func=nil, label=T.ENABLE, tooltip=T.TT_ENABLE, tabs=nil, },
	["windowType"] = {type="combo", var="windowType", func=nil, label=T.WINTYPE, tooltip=nil, tabs=nil, values = {T.FRIEND, T.HOST, T.PLAY, --[[T.GROUP,]]  }, },
	["barType"] = {type="combo", var="barType", func="onBarType", label=T.BTYPE, tooltip=nil, tabs=nil, values = bar_types, },
	["castBySelf"] = {type="combo", var="castBySelf", func=nil, label=T.CBS, tooltip=nil, tabs=nil, values = {T.ALL, T.BUFF, T.DEBUFF, T.NONE }, },
	["castByOthers"] = {type="combo", var="castByOthers", func=nil, label=T.CBO, tooltip=nil, tabs=nil, values = {T.ALL, T.BUFF, T.DEBUFF, T.NONE }, },
	["rowGrowth"] = {type="combo", var="rowGrowth", func=nil, label=T.RGROW, tooltip=T.TT_ROWS, tabs=nil, values = {T.DOWN, T.LEFT, T.RIGHT, T.UP, }, },
	["maxRows"] = {type="editbox",var="maxRows", func=nil, label=T.RICONS, tooltip=T.TT_UNL, tabs=nil, mask=L"%.0f", min=0, round=0 },
	["maxDuration"] = {type="editbox",var="maxDuration", func=nil, label=T.MAXDUR, tooltip=T.TT_MAX, tabs=nil, mask=L"%.0f", min=0, round=0 },
	["showPermanent"] = {type="check", var="showPermanent", func=nil, label=T.PERM, tooltip=nil, tabs=nil, },
	["Adv_columnGrowth"] = {type="combo", var="columnGrowth", func=nil, label=T.CGROW, tooltip=T.TT_CGROW, tabs=nil, values = { T.DOWN, T.LEFT, T.RIGHT, T.UP, }, },
	["Adv_maxColumns"] = {type="editbox",var="maxColumns", func=nil, label=T.CICONS, tooltip=T.TT_UNL, tabs=nil, mask=L"%.0f", min=0, round=0 },
	["Adv_minDuration"] = {type="editbox",var="minDuration", func=nil, label=T.MINDUR, tooltip=T.TT_MIN, tabs=nil, mask=L"%.0f", min=0, round=0 },
	["Adv_tooltip"] = {type="combo", var="tooltip", func=nil, label=T.TOOLTIP, tooltip=nil, tabs=nil, values = { T.NONE, T.ICON, T.BAR, }, },
	["Adv_sortOrder"] = {type="combo", var="sortOrder", func=nil, label=T.SORT, tooltip=T.TT_SORT, tabs=nil, values = { T.DEFAULT, T.EXPIRING, }, },
	["Adv_reverseSort"] = {type="check", var="reverseSort", func=nil, label=T.RSORT, tooltip=nil, tabs=nil, },
	["Adv_worldAttach"] = {type="check", var="worldAttach", func=nil, label=T.ATTACH, tooltip=T.TT_ATTACH, tabs=nil, },
	["Adv_worldX"] = {type="editbox",var="worldX", func=nil, label=L"X:", tooltip=T.XWORLD, tabs=nil, mask=L"%.0f", round=0 },
	["Adv_worldY"] = {type="editbox",var="worldY", func=nil, label=L"Y:", tooltip=T.TT_YWORLD, tabs=nil, mask=L"%.0f", round=0 },
}

local reverting = false

function DuffTimer.Options.Initialize()
	local tab, setting
	CreateWindow(VPWindowName, false)
	DuffTimer.texturelist = DuffTimer.LibSA:GetTextureList("statusbar")
	local textureNames = { }
	DuffTimer.textures = { }
	for k,v in ipairs(DuffTimer.texturelist) do
		local metadata = DuffTimer.LibSA:GetMetadata(v)
		if metadata and metadata.displayname and metadata.name and metadata.size then
			local newtex = { }
			newtex.displayName = metadata.displayname
			newtex.name = v
			table.insert(DuffTimer.textures,newtex)
		end
	end
	
	local function tsort(table1, table2) return table1.displayName < table2.displayName end
	table.sort(DuffTimer.textures, tsort)
	for k,v in ipairs(DuffTimer.textures) do
		textureNames[k] = StringToWString(v.displayName)
		if v.name == DuffTimer.SavedSettings.horizontalTextureName then
			DuffTimer.Settings.horizontalTexture = k
			DuffTimer.SavedSettings.horizontalTexture = k
		end
		if v.name == DuffTimer.SavedSettings.verticalTextureName then
			DuffTimer.Settings.verticalTexture = k
			DuffTimer.SavedSettings.verticalTexture = k
		end
	end
	if DuffTimer.Settings.horizontalTexture > table.maxn(DuffTimer.textures) then DuffTimer.Settings.horizontalTexture = 1 end
	if DuffTimer.Settings.verticalTexture > table.maxn(DuffTimer.textures) then DuffTimer.Settings.verticalTexture = 1 end
	
	options.Adv_horizontalTexture.values = textureNames
	options.Adv_verticalTexture.values = textureNames
	
	DuffTimer.Options.Settings = DuffTimer.TableCopy(DuffTimer.SavedSettings)	
	
	LabelSetText(VPWindowName.."TitleBarText", T.DTOPTIONS)
	LabelSetText(VPWindowName.."version",VERSION)
	ButtonSetText(VPWindowName.."_ApplyButton", T.APPLY )
	ButtonSetText(VPWindowName.."_SaveButton", T.SAVE )
	ButtonSetText(VPWindowName.."_RevertButton", T.REVERT )
	ButtonSetText(VPWindowName.."_TestButton", T.TEST )

	DuffTimer.Options.BuildTabs()
	DuffTimer.Options.CreateAddonButtons()
	DuffTimer.Options.InitializeOptions()
end


function DuffTimer.Options.InitializeOptions()
	reverting = true
	for key,value in pairs(options) do 
		local tabList = value.tabs
		if not tabList then tabList = {} for k=1,DuffTimer.Options.Settings.windows,1 do table.insert(tabList,k+1)  end end
		for _,tabIndex in ipairs(tabList) do
			tab = DuffTimer.tabs[tabIndex]
			LabelSetText(VPWindowName.."_"..tab.scroll.."_"..key.."_lbl", value.label)
			if tab.windowsKey then
				setting = DuffTimer.Options.Settings.Bar[tab.windowsKey][value.var]
			else
				setting = DuffTimer.Options.Settings[value.var]
			end
			if value.type == "editbox"
			then
				TextEditBoxSetText(VPWindowName.."_"..tab.scroll.."_"..key.."_ebx", wstring.format(value.mask,setting))
			end
			if value.type == "check"
			then
				ButtonSetPressedFlag(VPWindowName.."_"..tab.scroll.."_"..key.."_chk", setting)
	    		end
			if value.type == "combo"
			then
				ComboBoxClearMenuItems(VPWindowName.."_"..tab.scroll.."_"..key.."_cmb")
				for _,opt in ipairs(value.values) do
					ComboBoxAddMenuItem(VPWindowName.."_"..tab.scroll.."_"..key.."_cmb", opt)
				end
				ComboBoxSetSelectedMenuItem(VPWindowName.."_"..tab.scroll.."_"..key.."_cmb",setting)
			end
			if value.type == "slider"
			then
				SliderBarSetCurrentPosition(VPWindowName.."_"..tab.scroll.."_"..key.."_sld", setting)
				LabelSetText(VPWindowName.."_"..tab.scroll.."_"..key.."_val", wstring.format(value.mask,setting))
			end
		end
	end
	reverting = false
end

function DuffTimer.Options.BuildTabs()
	if DuffTimer.tabs then
		if table.maxn(DuffTimer.tabs) > DuffTimer.Options.Settings.windows then
			for k = DuffTimer.Options.Settings.windows + 2, table.maxn(DuffTimer.tabs), 1 do
				local oldTab = VPWindowName.."_"..DuffTimer.tabs[k].button
				if DoesWindowExist(oldTab) then DestroyWindow(oldTab) end
				oldTab = VPWindowName.."_"..DuffTimer.tabs[k].window
				if DoesWindowExist(oldTab) then DestroyWindow(oldTab) end
			end
		end
	end
	local active = nil
	
	if DuffTimer.tabs then 
		for k,v in ipairs(DuffTimer.tabs) do 
			if v.active then active = k end
		end
		DuffTimer.tabs = { DuffTimer.tabs[1] }
	else
		DuffTimer.tabs = { { text=T.GENSET, button="GeneralButton", 
			window="GeneralTab", scroll= "GeneralTabScroll", active=true, windowsKey=nil } }
	end
	tab_list = { }
	local tabWindowAnchor, lasttab
	for k = 1, DuffTimer.Options.Settings.windows, 1 do 
		table.insert(tab_list, k+1)
		table.insert(DuffTimer.tabs, {
			text = k..L": ",
			button = "Win"..k.."Button",
			window = "Win"..k.."Tab",
			scroll = "Win"..k.."TabScroll",
			active = false,
			windowsKey = k
		})
	end
	if active then DuffTimer.tabs[active].active = true end
	for k,v in ipairs(DuffTimer.tabs) do
		if not DoesWindowExist(VPWindowName.."_"..v.button) then
			CreateWindowFromTemplate(VPWindowName.."_"..v.button, VPWindowName.."_TabButton", VPWindowName)
			WindowSetId(VPWindowName.."_"..v.button, k-1)
			if k==1 then
				WindowAddAnchor( VPWindowName.."_"..v.button, "topleft", VPWindowName, "topleft", 5, 42 )
			else
				if k==6 then
					WindowAddAnchor( VPWindowName.."_"..v.button, "bottomleft", 
						VPWindowName.."_"..DuffTimer.tabs[k-5].button, "topleft", 0, 0 )
				else
					WindowAddAnchor( VPWindowName.."_"..v.button, "topright", 
						VPWindowName.."_"..DuffTimer.tabs[k-1].button, "topleft", 0, 0 )
				end
			end
			ButtonSetPressedFlag(VPWindowName.."_"..v.button,v.active)
		end
		lasttab = VPWindowName.."_"..v.button
	end
	if table.maxn(DuffTimer.tabs) > 5 then
		tabWindowAnchor = VPWindowName.."_"..DuffTimer.tabs[6].button
	else
		tabWindowAnchor = VPWindowName.."_"..DuffTimer.tabs[1].button
	end
	for k=1,9,1 do	if DoesWindowExist(VPWindowName.."_InactiveTab"..k) then DestroyWindow(VPWindowName.."_InactiveTab"..k) end end
	if DuffTimer.Options.Settings.windows > 1 and DuffTimer.Options.Settings.windows < 4 then
		for k=DuffTimer.Options.Settings.windows+1, 4, 1 do
			CreateWindowFromTemplate(VPWindowName.."_InactiveTab"..k, VPWindowName.."_TabButton", VPWindowName)
			WindowAddAnchor( VPWindowName.."_InactiveTab"..k, "bottomright", 
					lasttab, "bottomleft", 0, 0 )
			lasttab = VPWindowName.."_InactiveTab"..k
			ButtonSetDisabledFlag(lasttab, true)
			WindowSetId(VPWindowName.."_InactiveTab"..k, 0)
		end
	elseif DuffTimer.Options.Settings.windows > 4 and DuffTimer.Options.Settings.windows < 9 then
		for k=DuffTimer.Options.Settings.windows+1, 9, 1 do
			CreateWindowFromTemplate(VPWindowName.."_InactiveTab"..k, VPWindowName.."_TabButton", VPWindowName)
			WindowAddAnchor( VPWindowName.."_InactiveTab"..k, "bottomright", 
					lasttab, "bottomleft", 0, 0 )
			lasttab = VPWindowName.."_InactiveTab"..k
			ButtonSetDisabledFlag(lasttab, true)
			WindowSetId(VPWindowName.."_InactiveTab"..k, 0)
		end
	end
	
	DuffTimer.Options.TabNames()
	for k,v in ipairs(DuffTimer.tabs) do
		if not DoesWindowExist(VPWindowName.."_"..v.window) then
			if k == 1 then
				CreateWindowFromTemplate(VPWindowName.."_"..v.window, VPWindowName.."_GeneralTab_Template", VPWindowName)
			else
				CreateWindowFromTemplate(VPWindowName.."_"..v.window, VPWindowName.."_WinTab", VPWindowName)
			end
			WindowSetId(VPWindowName.."_"..v.scroll.."_AdvHeader", k)
			ButtonSetText(VPWindowName.."_"..v.scroll.."_AdvHeaderText", T.ADVOPTIONS)
			DuffTimer.Options.SetAdvWindow(k)
		end
		WindowClearAnchors(VPWindowName.."_"..v.window)
		WindowAddAnchor(VPWindowName.."_"..v.window, "bottomleft", tabWindowAnchor, "topleft", 0, 5)
		WindowAddAnchor(VPWindowName.."_"..v.window, "topright", "DuffTimerOptions_ButtonBackground", "bottomright", -6, 5)
		WindowSetShowing(VPWindowName.."_"..v.window, v.active)
	end
end

function DuffTimer.Options.TabNames()
	for k,v in pairs(DuffTimer.tabs) do
		if v.windowsKey then
			ButtonSetText(VPWindowName.."_"..v.button, 
				v.text..DuffTimer.WindowTypes[DuffTimer.Options.Settings.Bar[v.windowsKey].windowType].name)
		else
			ButtonSetText(VPWindowName.."_"..v.button, v.text)
		end
	end
end

function DuffTimer.Options.OnLButtonUp()
	if reverting then return end
	local option_name = SystemData.ActiveWindow.name
	local tabKey = DuffTimer.Options.GetActiveTabKey()
	local windowsKey = DuffTimer.tabs[tabKey].windowsKey
	if option_name == nil then return end
	option_name, _ = string.gsub(option_name, "_chk", "")
	option_name, _ = string.gsub(option_name, VPWindowName.."_","")
	option_name, _ = string.gsub(option_name, DuffTimer.tabs[tabKey].scroll.."_","")
	value = options[option_name]
	if not windowsKey then
		val = not DuffTimer.Options.Settings[options[option_name].var]
		DuffTimer.Options.Settings[options[option_name].var] = val
	else
		val = not DuffTimer.Options.Settings.Bar[windowsKey][options[option_name].var]
		DuffTimer.Options.Settings.Bar[windowsKey][options[option_name].var] = val
	end
	ButtonSetPressedFlag(SystemData.ActiveWindow.name, val)
	if value.func then DuffTimer.Options[value.func]() end
end

function DuffTimer.Options.OnSelChanged(choiceIndex)
	if reverting then return end
	local option_name = SystemData.ActiveWindow.name
	local tabKey = DuffTimer.Options.GetActiveTabKey()
	local windowsKey = DuffTimer.tabs[tabKey].windowsKey
	if option_name == nil then return end
	option_name, _ = string.gsub(option_name, "_cmb", "")
	option_name, _ = string.gsub(option_name, VPWindowName.."_","")
	option_name, _ = string.gsub(option_name, DuffTimer.tabs[tabKey].scroll.."_","")
	value = options[option_name]
	if not windowsKey then
		DuffTimer.Options.Settings[value.var] = choiceIndex
	else
		DuffTimer.Options.Settings.Bar[windowsKey][value.var] = choiceIndex
	end
	ComboBoxSetSelectedMenuItem(SystemData.ActiveWindow.name,choiceIndex)
	if value.func then DuffTimer.Options[value.func]() end
end

function DuffTimer.Options.GetEditBoxText(option_name, tabKey)
	local old_value
	local windowsKey = DuffTimer.tabs[tabKey].windowsKey
	value = options[option_name]
	edit_text = TextEditBoxGetText(VPWindowName.."_"..DuffTimer.tabs[tabKey].scroll.."_"..option_name.."_ebx")
	if not edit_text then return end
	edit_number = tonumber(edit_text)
	if edit_number==nil then edit_number=0 end
	if value.round then edit_number = math.floor(edit_number*10^value.round)/10^value.round end
	if value.min then
		if edit_number < value.min then edit_number = value.min end
	end
	if value.max then
		if edit_number > value.max then edit_number = value.max end
	end
	if not windowsKey then
		old_value = DuffTimer.Options.Settings[value.var]
		DuffTimer.Options.Settings[value.var] = edit_number
	else
		old_value = DuffTimer.Options.Settings.Bar[windowsKey][value.var]
		DuffTimer.Options.Settings.Bar[windowsKey][value.var] = edit_number
	end
	TextEditBoxSetText(VPWindowName.."_"..DuffTimer.tabs[tabKey].scroll.."_"..option_name.."_ebx", wstring.format(value.mask,edit_number))
	if value.func and edit_number ~= old_value then DuffTimer.Options[value.func]() end
end

function DuffTimer.Options.OnEditBoxChanged()
	if reverting then return end
	local option_name = SystemData.ActiveWindow.name
	local tabKey = DuffTimer.Options.GetActiveTabKey()
	local windowsKey = DuffTimer.tabs[tabKey].windowsKey
	if option_name == nil then return end
	option_name, _ = string.gsub(option_name, "_ebx", "")
	option_name, _ = string.gsub(option_name, VPWindowName.."_","")
	option_name, _ = string.gsub(option_name, DuffTimer.tabs[tabKey].scroll.."_","")
	DuffTimer.Options.GetEditBoxText(option_name, tabKey)
end

function DuffTimer.Options.OnLButtonUpTab()
	local windowName = SystemData.ActiveWindow.name
	if string.match(windowName,"Inactive") then return end
	windowName, _ = string.gsub(windowName, VPWindowName.."_","")
	for k,v in pairs(DuffTimer.tabs) do
		if v.button == windowName
		then
			ButtonSetPressedFlag(VPWindowName.."_"..v.button,true)
			v.active=true
			WindowSetShowing(VPWindowName.."_"..v.window,true)
		else
			ButtonSetPressedFlag(VPWindowName.."_"..v.button,false)
			v.active = false
			WindowSetShowing(VPWindowName.."_"..v.window,false)
		end
	end
end

function DuffTimer.Options.OnRButtonUpTab()
	contextId = WindowGetId( SystemData.ActiveWindow.name )
	if contextId==0 then return end
	EA_Window_ContextMenu.CreateContextMenu("DuffTimerOptions_TabMove")
	EA_Window_ContextMenu.AddMenuItem(T.MOVELEFT, DuffTimer.Options.OnTabLeft, (contextId==1 ), true)
	EA_Window_ContextMenu.AddMenuItem(T.MOVERIGHT, DuffTimer.Options.OnTabRight, ( contextId == DuffTimer.Options.Settings.windows ), true)
	EA_Window_ContextMenu.Finalize()
end

function DuffTimer.Options.GetActiveTabKey()
	for k,v in pairs(DuffTimer.tabs) do
		if v.active then return k end
	end
end

function DuffTimer.Options.OnSliderChange()
	if reverting then return end
	local slider_name = SystemData.ActiveWindow.name
	local tabKey = DuffTimer.Options.GetActiveTabKey()
	local windowsKey = DuffTimer.tabs[tabKey].windowsKey
	if slider_name == nil then return end
	slider_name, _ = string.gsub(slider_name, "_sld", "")
	slider_name, _ = string.gsub(slider_name, VPWindowName.."_","")
	slider_name, _ = string.gsub(slider_name, DuffTimer.tabs[tabKey].scroll.."_","")
	value = options[slider_name]
	val = SliderBarGetCurrentPosition(SystemData.ActiveWindow.name)* value.mult
	if not windowsKey then
		DuffTimer.Options.Settings[value.var] = val
	else
		DuffTimer.Options.Settings.Bar[windowsKey][value.var] = val
	end
	LabelSetText(VPWindowName.."_"..DuffTimer.tabs[tabKey].scroll.."_"..slider_name.."_val", wstring.format(value.mask,val))
	if value.func then DuffTimer.Options[value.func]() end
end

function DuffTimer.Options.OnMouseOver()	
	local option_name = SystemData.ActiveWindow.name
	local tabKey = DuffTimer.Options.GetActiveTabKey()
	local windowsKey = DuffTimer.tabs[tabKey].windowsKey
	if option_name == nil then return end
	option_name, _ = string.gsub(option_name, "_lbl", "")
	option_name, _ = string.gsub(option_name, VPWindowName.."_","")
	option_name, _ = string.gsub(option_name, DuffTimer.tabs[tabKey].scroll.."_","")
	if options[option_name].tooltip == nil then return end
	Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name )
	Tooltips.SetTooltipText( 1, 1, options[option_name].tooltip )
	Tooltips.Finalize()
	Tooltips.AnchorTooltip( Tooltips.ANCHOR_WINDOW_LEFT )
end

function DuffTimer.Options.OnSaveButton()
	DuffTimer.Options.Apply()
	DuffTimer.Options.OnOptionsButton()
end

function DuffTimer.Options.OnOptionsButton()
	WindowSetShowing(VPWindowName, not WindowGetShowing(VPWindowName))
	if DuffTimer.testMode then DuffTimer.TestMode(false) end
	if not WindowGetShowing(VPWindowName) then
		if DoesWindowExist("DuffskinOptions") then WindowSetShowing("DuffskinOptions",false) end
		if DoesWindowExist("DuffFilterOptions") then WindowSetShowing("DuffFilterOptions",false) end
	end
end

function DuffTimer.Options.Apply()
	for key,value in pairs(options) do 
		local tabList = value.tabs
		if not tabList then tabList = {} for k=1,DuffTimer.SavedSettings.windows,1 do table.insert(tabList,k+1)  end end
		for _,tabIndex in ipairs(tabList) do
			tab = DuffTimer.tabs[tabIndex]
			if value.type == "editbox"
			then
				DuffTimer.Options.GetEditBoxText(key, tabIndex)
			end
		end
	end
	local windowsChanged = not (DuffTimer.SavedSettings.windows == DuffTimer.Options.Settings.windows)
	DuffTimer.Shutdown()

	DuffTimer.SavedSettings = DuffTimer.TableCopy(DuffTimer.Options.Settings)
	DuffTimer.SavedSettings.horizontalTextureName = DuffTimer.LibSA:GetMetadata(DuffTimer.textures[DuffTimer.SavedSettings.horizontalTexture].name).name
	DuffTimer.SavedSettings.verticalTextureName = DuffTimer.LibSA:GetMetadata(DuffTimer.textures[DuffTimer.SavedSettings.verticalTexture].name).name
	if windowsChanged then
		DuffTimer.InitializeDefaultBars()
		DuffTimer.Options.Settings = DuffTimer.TableCopy(DuffTimer.SavedSettings)
		DuffTimer.Options.BuildTabs()
		reverting = true
		DuffTimer.Options.InitializeOptions()
		reverting = false
	else
		DuffTimer.Options.TabNames()
	end
	if DuffTimer.testMode then 
		DuffTimer.TestMode(true)
	else
		DuffTimer.Startup() 
	end
end

function DuffTimer.Options.OnRevertButton()
	DuffTimer.Options.Settings = DuffTimer.TableCopy(DuffTimer.SavedSettings)
	DuffTimer.Options.InitializeOptions()
	DuffTimer.Options.TabNames()
end

function DuffTimer.Options.OnTestButton()
	DuffTimer.TestMode()
end

function DuffTimer.Options.OnTabLeft()
	DuffTimer.Options.TabSwap(contextId-1, contextId)
end

function DuffTimer.Options.OnTabRight()
	local windowId = WindowGetId( SystemData.ActiveWindow.name )
	DuffTimer.Options.TabSwap(contextId,contextId+1)
end

function DuffTimer.Options.TabSwap(tab1, tab2)
	local temp = DuffTimer.TableCopy(DuffTimer.Options.Settings.Bar[tab1])
	DuffTimer.Options.Settings.Bar[tab1] = DuffTimer.TableCopy(DuffTimer.Options.Settings.Bar[tab2])
	DuffTimer.Options.Settings.Bar[tab2] = DuffTimer.TableCopy(temp)
	DuffTimer.Options.InitializeOptions()
	DuffTimer.Options.TabNames()
end

function DuffTimer.Options.OnTestButtonToolTip()
	Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name, nil) 
	Tooltips.SetTooltipText(1, 1, T.TT_TESTMODE)
	Tooltips.Finalize()
	Tooltips.AnchorTooltip(Tooltips.ANCHOR_WINDOW_BOTTOM)
end

function DuffTimer.Options.Reset()
	DuffTimer.SavedSettings = nil
	DuffTimer.Settings = nil
	DuffTimer.Options.Settings = nil
	DuffTimerSettings.SavedSettings = nil
end

function DuffTimer.Options.ToggleAdvOptions()
	local tab = SystemData.ActiveWindow.name
	local tabId = WindowGetId(tab)
	DuffTimer.Options.SetAdvWindow(tabId)
end

function DuffTimer.Options.SetAdvWindow(tabId)
	local windowName, DIM, rect
	if tabId == 1 then
		DIM = GENERAL_ADV_DIM
	else
		DIM = ADV_DIM
	end
	windowName = VPWindowName.."_"..DuffTimer.tabs[tabId].scroll.."_Adv"
	local showing = not WindowGetShowing(windowName)
	WindowSetShowing(windowName, showing)
	if showing then
		WindowSetDimensions(windowName, unpack(DIM))
		WindowSetShowing(windowName.."HeaderPlus", false)
		WindowSetShowing(windowName.."HeaderMinus", true)
	else
		WindowSetDimensions(windowName, 0,0)
		WindowSetShowing(windowName.."HeaderPlus", true)
		WindowSetShowing(windowName.."HeaderMinus", false)
	end
	ScrollWindowUpdateScrollRect(  VPWindowName.."_"..DuffTimer.tabs[tabId].window )
end

function DuffTimer.Options.onBarType()
	local tabKey = DuffTimer.Options.GetActiveTabKey()
	local windowsKey = DuffTimer.tabs[tabKey].windowsKey
	if not windowsKey then return end
	if DuffTimer.Options.Settings.Bar[windowsKey].barType ~= DuffTimer.SavedSettings.Bar[windowsKey].barType then
		DuffTimer.Options.Settings.Bar[windowsKey].dimensions = nil
	end
end

function DuffTimer.Options.AddButton(windowName, labelText)
	table.insert(addon_buttons, {name=windowName, text=labelText} )
end

function DuffTimer.Options.CreateAddonButtons()
	local last_button = LAST_BUTTON
	for k, v in ipairs(addon_buttons) do
		CreateWindow(v.name,true)
		WindowSetParent(v.name,"DuffTimerOptions_GeneralTabScroll_Adv")
		WindowClearAnchors(v.name)
		WindowAddAnchor(v.name, "bottomleft", last_button, "topleft", 0, 5)
		ButtonSetText(v.name,v.text)
		last_button = v.name
	end
end

function DuffTimer.Options.GetBarTypeCount()
	return table.maxn(bar_types)
end

function DuffTimer.Options.AddBarTypes(barTable)
	local tbl = DuffTimer.TableCopy(bar_types)
	for k, v in ipairs(barTable) do
		table.insert(tbl, v)
	end
	options.barType.values = DuffTimer.TableCopy(tbl)
end

function DuffTimer.Options.RemoveBarType(index)
	local i = index + DuffTimer.Options.GetBarTypeCount()
	for k = 1,DuffTimer.SavedSettings.windows,1 do
		if DuffTimer.SavedSettings.Bar[k].barType >= i then
			DuffTimer.SavedSettings.Bar[k].barType = DuffTimer.SavedSettings.Bar[k].barType - 1
			DuffTimer.Options.Settings.Bar[k].barType = DuffTimer.SavedSettings.Bar[k].barType
		end
	end
end