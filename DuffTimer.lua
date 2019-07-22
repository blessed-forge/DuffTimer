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

local currentTime = 0
local duration = 0
local timeLeft = 0
local selfTargeted = false
local loaded = false
local TIMER_WINDOW_LENGTH = 40
local TIMER_WINDOW_HEIGHT = 18
DuffTimer.testMode = false
local T
if not T then T = DuffTimer.wstrings[SystemData.Settings.Language.active] end
-------------------------------------------------------------------

local effectTimes = { }

local function IsValidBuff( buffData ) -- Took this from EAs bufftracker
    return ( buffData ~= nil and buffData.effectIndex ~= nil and buffData.iconNum ~= nil and buffData.iconNum > 0 )
end

function DuffTimer.GetMaxDuration(buff)
	if DuffTimer.testMode then return 100 end
	if not effectTimes[buff.abilityId]
	then
		effectTimes[buff.abilityId] = buff.duration
	elseif
		buff.duration > effectTimes[buff.abilityId]
	then
		effectTimes[buff.abilityId] = buff.duration
	end
	return effectTimes[buff.abilityId]
end

function DuffTimer.OnInitialize()
	DuffTimer.LibSA = LibStub("LibSharedAssets")
	DuffTimer.LoadTextures()
	RegisterEventHandler(SystemData.Events.ENTER_WORLD, "DuffTimer.OnLoadingEnd")
	RegisterEventHandler(SystemData.Events.RELOAD_INTERFACE, "DuffTimer.OnReloadInterface")
end

function DuffTimer.OnReloadInterface()
	DuffTimer.OnLoadingEnd()
end

function DuffTimer.OnLoadingEnd()
	if loaded then
		DuffTimer.ResetAddon()
	else
		loaded = true
		DuffTimer.InitializeDefaults()
		DuffTimer.Settings = DuffTimer.TableCopy(DuffTimer.SavedSettings)
		DuffTimer.Options.Initialize()
		if ( LibSlash ) then
			LibSlash.RegisterSlashCmd("duff", function(input) DuffTimer.SlashHandler(input) end)
			LibSlash.RegisterSlashCmd("dufftimer", function(input) DuffTimer.SlashHandler(input) end)
		end
		RegisterEventHandler(  SystemData.Events.UPDATE_PROCESSED, "DuffTimer.OnUpdate")
		RegisterEventHandler(SystemData.Events.PLAYER_TARGET_UPDATED, "DuffTimer.OnTargetUpdated")
		RegisterEventHandler(SystemData.Events.PLAYER_EFFECTS_UPDATED, "DuffTimer.OnPlayerEffectsUpdated")
		RegisterEventHandler(SystemData.Events.PLAYER_TARGET_EFFECTS_UPDATED, "DuffTimer.OnTargetEffectsUpdated")
--[[
		RegisterEventHandler(SystemData.Events.GROUP_EFFECTS_UPDATED, "DuffTimer.OnGroupEffectsUpdated")
		RegisterEventHandler(SystemData.Events.GROUP_UPDATED, "DuffTimer.ResetGroupWindows")
		RegisterEventHandler(SystemData.Events.GROUP_PLAYER_ADDED, "DuffTimer.ResetGroupWindows")
		RegisterEventHandler(SystemData.Events.SCENARIO_GROUP_LEAVE, "DuffTimer.ResetGroupWindows")
		RegisterEventHandler(SystemData.Events.SCENARIO_GROUP_JOIN, "DuffTimer.ResetGroupWindows")
		RegisterEventHandler(SystemData.Events.SCENARIO_BEGIN, "DuffTimer.ResetGroupWindows")
		RegisterEventHandler(SystemData.Events.SCENARIO_END, "DuffTimer.ResetGroupWindows")
]]
		timeLeft = DuffTimer.Settings.refreshRate
		DuffTimer.Startup()
		DuffTimer.SavePositions()
		LayoutEditor.RegisterEditCallback( DuffTimer.LayoutEditorCallback )
		d("Dufftimer loaded")
	end
end

function DuffTimer.SlashHandler(input)
	local res = input:match("([a-z0-9]+)")
	if not res or res == "" then DuffTimer.Options.OnOptionsButton() end
	if res == "version" then  TextLogAddEntry("Chat", 1,L"DuffTimer Version: "..VERSION ) end
	if res == "reset" then  
		DuffTimer.testMode=false 
		DuffTimer.ResetAddon() 
	end
	if res == "resetxy" then  
		for k=1,DuffTimer.Settings.windows,1 do
			DuffTimer.Settings.Bar[k].dimensions = nil
			DuffTimer.SavedSettings.Bar[k].dimensions = nil
			DuffTimer.Options.Settings.Bar[k].dimensions = nil
			DuffTimer.ResetAddon() 
		end
	end
end

function DuffTimer.Startup()
	DuffTimer.Buffs = { }
	DuffTimer.BuffIndex = { }
	for k,windowType in ipairs(DuffTimer.WindowTypes) do
		DuffTimer.BuffIndex[windowType.buffType] = { }
	end
	if not DuffTimer.Targets then DuffTimer.Targets = { } end
	DuffTimer.Attaches = { }
	if not DuffTimer.testMode then DuffTimer.Settings = DuffTimer.TableCopy(DuffTimer.SavedSettings) end

	local group_bars = 0
	for k=1,DuffTimer.Settings.windows,1 do
		DuffTimer.Buffs[k] = { }
		if DuffTimer.Settings.Bar[k].enable then
			if DuffTimer.Settings.Bar[k].windowType==4 then
				if not DuffTimer.Settings.Bar[k].groupScale then DuffTimer.Settings.Bar[k].groupScale = { } end
				if not DuffTimer.Settings.Bar[k].groupAnchor then DuffTimer.Settings.Bar[k].groupAnchor = { } end
				DuffTimer.WindowSetup(k,k,1,DuffTimer.Settings.Bar[k].anchor, DuffTimer.Settings.Bar[k].scale, DuffTimer.Settings.Bar[k].dimensions)
				for i = 1, 4, 1 do
					group_bars = group_bars + 1
					DuffTimer.Buffs[DuffTimer.Settings.windows+group_bars] = { }
					DuffTimer.Settings.Bar[DuffTimer.Settings.windows+group_bars] = DuffTimer.TableCopy(DuffTimer.Settings.Bar[k])
					DuffTimer.Settings.Bar[DuffTimer.Settings.windows+group_bars].parent = k
					DuffTimer.Settings.Bar[DuffTimer.Settings.windows+group_bars].windowType = DuffTimer.Settings.Bar[k].windowType + i
					buffType = DuffTimer.WindowTypes[DuffTimer.Settings.Bar[k].windowType + i].buffType
					DuffTimer.WindowSetup(DuffTimer.Settings.windows+group_bars,k,i+1,
						DuffTimer.Settings.Bar[k].groupAnchor[buffType], DuffTimer.Settings.Bar[k].scale, DuffTimer.Settings.Bar[k].dimensions)
				end
				DuffTimer.Settings.windows = DuffTimer.Settings.windows + 4
			else
				DuffTimer.WindowSetup(k,k,nil,DuffTimer.Settings.Bar[k].anchor, DuffTimer.Settings.Bar[k].scale, DuffTimer.Settings.Bar[k].dimensions)
			end
		end
	end
	for windowsKey=1,DuffTimer.Settings.windows,1 do
		if DuffTimer.Settings.Bar[windowsKey].maxRows==0 or DuffTimer.Settings.Bar[windowsKey].maxColumns==0
		then
			DuffTimer.Settings.Bar[windowsKey].maxBars = math.huge
		else
			DuffTimer.Settings.Bar[windowsKey].maxBars = DuffTimer.Settings.Bar[windowsKey].maxRows*DuffTimer.Settings.Bar[windowsKey].maxColumns
		end
	end

	for k, windowType in ipairs(DuffTimer.WindowTypes) do
		DuffTimer.InitWindowType(windowType)
	end
end

function DuffTimer.WindowSetup(index, display, group, anchor, scale, dimensions)
	local resizeable = true
	CreateWindowFromTemplate("DuffTimer_Win"..index, "DuffTimer_Container", "Root")
	if DuffTimer.Settings.Bar[index].barType <= DuffTimer.Options.GetBarTypeCount() then
		CreateWindowFromTemplate("DuffTimer_SizeGuide", DuffTimer.BarTypes[DuffTimer.Settings.Bar[index].barType],"Root")
	else
		if Duffskin then
			if not Duffskin.CreateBar("DuffTimer_SizeGuide", DuffTimer.Settings.Bar[index].barType-DuffTimer.Options.GetBarTypeCount()) then return end
			resizeable = false
		else
			DuffTimer.Settings.Bar[index].barType = 1
			DuffTimer.SavedSettings.Bar[index].barType = 1
			CreateWindowFromTemplate("DuffTimer_SizeGuide", DuffTimer.BarTypes[DuffTimer.Settings.Bar[index].barType],"Root")
		end
	end
		
	WindowSetDimensions("DuffTimer_Win"..index, WindowGetDimensions("DuffTimer_SizeGuide"))
	DestroyWindow("DuffTimer_SizeGuide")

	WindowClearAnchors("DuffTimer_Win"..index)
	if not anchor then
		local screenX, screenY = GetScreenResolution()

		WindowAddAnchor("DuffTimer_Win"..index, "bottomleft", "Root", "bottom", 
			display*screenX/(DuffTimer.Settings.windows+1), -1*screenY/4)
	else
		if anchor then 
			WindowAddAnchor("DuffTimer_Win"..index, anchor.point, 
				anchor.window,anchor.relPoint,
				anchor.x, anchor.y)
		end
		if scale then WindowSetScale("DuffTimer_Win"..index, scale) end
		if dimensions then WindowSetDimensions("DuffTimer_Win"..index, dimensions.x, dimensions.y) end
	end
	local desc = T.DWIN..display..L" "..
		DuffTimer.WindowTypes[DuffTimer.Settings.Bar[index].windowType].name
	if group then desc = desc..L" "..T.MEMBER..L" "..group end
	LayoutEditor.RegisterWindow("DuffTimer_Win"..index,desc, desc, resizeable, resizeable, false, nil)

	if DuffTimer.Settings.Bar[index].worldAttach
	then
		CreateWindowFromTemplate("DuffTimer_Win"..index.."_Attach", "DuffTimer_Container", "Root")
	end
	return "DuffTimer_Win"..index
end

function DuffTimer.Shutdown()
	for _,v in ipairs(DuffTimer.Buffs) do
		for _,buff in ipairs(v) do
			DestroyWindow(buff.windowName)
		end
	end
	for k=1,DuffTimer.Settings.windows,1 do
		if DoesWindowExist("DuffTimer_Win"..k) then 
			LayoutEditor.UnregisterWindow("DuffTimer_Win"..k)
			DestroyWindow("DuffTimer_Win"..k) 			
		end
		if DoesWindowExist("DuffTimer_Win"..k.."_Attach")
		then
			if DuffTimer.Attaches[k] ~= nil then
				DetachWindowFromWorldObject("DuffTimer_Win"..k.."_Attach", DuffTimer.Attaches[k])
				DuffTimer.Attaches[k] = nil
			end
			DestroyWindow("DuffTimer_Win"..k.."_Attach")
		end
	end
	DuffTimer.Buffs = { }
	DuffTimer.BuffIndex = { }
	for k,windowType in ipairs(DuffTimer.WindowTypes) do
		DuffTimer.BuffIndex[windowType.buffType] = { }
	end
end

function DuffTimer.ResetAddon()
	DuffTimer.Shutdown()
	DuffTimer.Startup()
end

function DuffTimer.OnUpdate(elapsed)
	currentTime = currentTime + elapsed
	duration = duration + elapsed
	timeLeft = timeLeft - elapsed
	if timeLeft > 0 then
		return
	end
	timeLeft = DuffTimer.Settings.refreshRate
	if DuffTimer.testMode then return end
	DuffTimer.UpdateDurations()
	for k = 1, DuffTimer.Settings.windows, 1 do
		if DuffTimer.Settings.Bar[k].enable
		then
			DuffTimer.RefreshWindow(k)
		end
	end
	duration = 0
end

function DuffTimer.OnTargetUpdated(targetClassification, targetId, targetType)
	if DuffTimer.testMode then return end
	if targetClassification == "mouseovertarget" then return end
	-- Classification: selfhostiletarget,selffriendlytarget,mouseovertarget
	-- Type: 0 = No Target, 1 = Player, 2 = Player's Pet, 3 = Friendly PC, 4 = Friendly NPC/Pet, 5 = Hostile Player, 6 = Hostile NPC/Pet

	if DuffTimer.Targets[targetClassification] == targetId
	then 
		return 
	end
	DuffTimer.Targets[targetClassification] = targetId
	if targetId == GameData.Player.worldObjNum then
		selfTargeted = true
	else
		selfTargeted = false
	end
	for windowsKey=1,DuffTimer.Settings.windows,1 do
		if DuffTimer.Settings.Bar[windowsKey].enable and 
			DuffTimer.WindowTypes[DuffTimer.Settings.Bar[windowsKey].windowType].target == targetClassification and not
			(selfTargeted and DuffTimer.WindowTypes[DuffTimer.Settings.Bar[windowsKey].windowType].buffType == GameData.BuffTargetType.SELF)
		then
			DuffTimer.WorldAttach(windowsKey, targetId)
			DuffTimer.ResetWindow(windowsKey)
		end
	end
end

function DuffTimer.WorldAttach(windowsKey, targetId)
	if DuffTimer.Settings.Bar[windowsKey].worldAttach and DuffTimer.WindowTypes[DuffTimer.Settings.Bar[windowsKey].windowType].target
	then
		if DuffTimer.Attaches[windowsKey] ~= nil then
			DetachWindowFromWorldObject("DuffTimer_Win"..windowsKey.."_Attach", DuffTimer.Attaches[windowsKey])
			DuffTimer.Attaches[windowsKey] = nil
		end
		if targetType ~= 0 then
			AttachWindowToWorldObject("DuffTimer_Win"..windowsKey.."_Attach", targetId)
			DuffTimer.Attaches[windowsKey] = targetId
		end
	end
end

function DuffTimer.OnPlayerEffectsUpdated(updatedEffects, isFullList)
	DuffTimer.OnTargetEffectsUpdated( GameData.BuffTargetType.SELF, updatedEffects, isFullList )
end

function DuffTimer.OnGroupEffectsUpdated( updateType, updatedEffects, isFullList )
	if not IsWarBandActive() then
		DuffTimer.OnTargetEffectsUpdated(  updateType, updatedEffects, isFullList )
	end
end

function DuffTimer.AddNewEffect(effectIndex, buffData, updateType)
	DuffTimer.BuffIndex[updateType][effectIndex] = { }
	DuffTimer.BuffIndex[updateType][effectIndex].buffData = DuffTimer.TableCopy(buffData)
	DuffTimer.BuffIndex[updateType][effectIndex].duration = buffData.duration or 0
	DuffTimer.BuffIndex[updateType][effectIndex].long = { }
	DuffTimer.BuffIndex[updateType][effectIndex].maxDuration = DuffTimer.GetMaxDuration(buffData)
	local color = { }
	DuffTimer.BuffIndex[updateType][effectIndex].buffType, _, _, color.red, color.green, color.blue = DataUtils.GetAbilityTypeTextureAndColor(buffData)
	if DuffTimer.Settings.classicColors then
		DuffTimer.BuffIndex[updateType][effectIndex].buffRed =  buffData.typeColorRed or 128
		DuffTimer.BuffIndex[updateType][effectIndex].buffGreen =  buffData.typeColorGreen or 128
		DuffTimer.BuffIndex[updateType][effectIndex].buffBlue  =  buffData.typeColorBlue or 128
	else
		DuffTimer.BuffIndex[updateType][effectIndex].buffRed =  buffData.typeColorRed or color.red or 128
		DuffTimer.BuffIndex[updateType][effectIndex].buffGreen =  buffData.typeColorGreen or color.green or 128
		DuffTimer.BuffIndex[updateType][effectIndex].buffBlue  =  buffData.typeColorBlue or color.blue or 128
	end
	for windowsKey = 1, DuffTimer.Settings.windows,1 do
		if DuffTimer.Settings.Bar[windowsKey].enable and 
			DuffTimer.WindowTypes[DuffTimer.Settings.Bar[windowsKey].windowType].buffType == updateType
		then
			DuffTimer.AddNewEffectByWindow(windowsKey, effectIndex, updateType)
		end
	end
end

function DuffTimer.OnTargetEffectsUpdated( updateType, updatedEffects, isFullList )
	if ( updateType == GameData.BuffTargetType.TARGET_FRIENDLY and selfTargeted == true ) or not updatedEffects or DuffTimer.testMode
	then
		return
	end
	if isFullList then 
		for windowsKey = 1, DuffTimer.Settings.windows,1 do
			if DuffTimer.Settings.Bar[windowsKey].enable and DuffTimer.WindowTypes[DuffTimer.Settings.Bar[windowsKey].windowType].buffType == updateType then
				DuffTimer.ResetWindow(windowsKey) 
			end
		end
	end
	for effectIndex, buffData in pairs(updatedEffects) do
		if not IsValidBuff(buffData) then
			DuffTimer.RemoveEffect(effectIndex, updateType)
			continue
		end
		if DuffTimer.BuffIndex[updateType][effectIndex] then
			DuffTimer.UpdateExistingEffect(effectIndex, buffData, updateType)
		else
			DuffTimer.AddNewEffect(effectIndex, buffData, updateType)
		end
	end
end

function DuffTimer.UpdateExistingEffect(effectIndex, buffData, updateType)
	DuffTimer.BuffIndex[updateType][effectIndex].buffData = DuffTimer.TableCopy(buffData)
	if DuffTimer.BuffIndex[updateType][effectIndex].buffData.duration > DuffTimer.BuffIndex[updateType][effectIndex].duration and
		not DuffTimer.BuffIndex[updateType][effectIndex].buffData.permamentUntilDispelled 
	then
		DuffTimer.BuffIndex[updateType][effectIndex].duration = DuffTimer.BuffIndex[updateType][effectIndex].buffData.duration
		DuffTimer.BuffIndex[updateType][effectIndex].maxDuration = DuffTimer.GetMaxDuration(buffData)
	end
	for windowsKey = 1, DuffTimer.Settings.windows,1 do
		if DuffTimer.Settings.Bar[windowsKey].enable and 
			DuffTimer.WindowTypes[DuffTimer.Settings.Bar[windowsKey].windowType].buffType == updateType and
			not DoesWindowExist("DuffTimer_Bar_"..windowsKey.."_"..effectIndex)
		then
			DuffTimer.AddNewEffectByWindow(windowsKey, effectIndex, updateType)
		end
	end

end

function DuffTimer.InitWindowType(windowType)
	if DuffTimer.testMode then return end
	if windowType.target then 
		local targetId = TargetInfo:UnitEntityId(windowType.target)
		if targetId > .1 and target ~=  GameData.Player.worldObjNum then  
			for windowsKey = 1, DuffTimer.Settings.windows, 1 do
				if DuffTimer.Settings.Bar[windowsKey].enable and DuffTimer.Settings.Bar[windowsKey].worldAttach then
					DuffTimer.WorldAttach(windowsKey, targetId)
				end
			end
			for effectIndex, buffData in pairs(GetBuffs(windowType.buffType)) do
				DuffTimer.AddNewEffect(effectIndex,buffData, windowType.buffType)
			end
		end
	else
		for effectIndex, buffData in pairs(GetBuffs(windowType.buffType)) do
			DuffTimer.AddNewEffect(effectIndex,buffData, windowType.buffType)
		end
	end
end

function DuffTimer.AddNewEffectByWindow(windowsKey, effectIndex, updateType)
	if DoesWindowExist("DuffTimer_Bar_"..windowsKey.."_"..effectIndex) then
		return
	end
	buffData = DuffTimer.BuffIndex[updateType][effectIndex].buffData
	local castby
	if ( buffData.permanentUntilDispelled and not DuffTimer.Settings.Bar[windowsKey].showPermanent )
	then
		return
	end
	if ( buffData.castByPlayer )
	then
		castby = "castBySelf"
	else
		castby = "castByOthers"
	end
	if DuffTimer.Settings.Bar[windowsKey][castby] == 4 then return end
	if (DuffTimer.Settings.Bar[windowsKey][castby] == 1) or
		(DuffTimer.Settings.Bar[windowsKey][castby] == 2 and DuffTimer.BuffIndex[updateType][effectIndex].buffType ~= "Debuff-Frame") or
		(DuffTimer.Settings.Bar[windowsKey][castby] == 3 and DuffTimer.BuffIndex[updateType][effectIndex].buffType == "Debuff-Frame")
	then
		if ( DuffTimer.BuffIndex[updateType][effectIndex].duration > DuffTimer.Settings.Bar[windowsKey].maxDuration ) and ( DuffTimer.Settings.Bar[windowsKey].maxDuration > 0 )
		then
			DuffTimer.BuffIndex[updateType][effectIndex].long[windowsKey] = DuffTimer.Settings.Bar[windowsKey].maxDuration
			return
		end
		if DuffTimer.Settings.Bar[windowsKey].minDuration > .1 and DuffTimer.BuffIndex[updateType][effectIndex].duration < DuffTimer.Settings.Bar[windowsKey].minDuration
			and not buffData.permanentUntilDispelled
		then
			return
		end
		if DuffFilter and not DuffFilter.CheckFilter(windowsKey,effectIndex,updateType) then return end
		newBuff = { }
		newBuff.effectIndex = buffData.effectIndex
		local position = DuffTimer.FindPosition(windowsKey,effectIndex, updateType)
		table.insert(DuffTimer.Buffs[windowsKey], position, newBuff)
		DuffTimer.CreateBar(windowsKey,position, updateType)
		DuffTimer.RebuildAnchors(windowsKey)
	end
end

function DuffTimer.RemoveEffect(effectIndex, updateType)
	if not DuffTimer.BuffIndex[updateType][effectIndex] then return end
	for windowsKey = 1, DuffTimer.Settings.windows do
		if DuffTimer.WindowTypes[DuffTimer.Settings.Bar[windowsKey].windowType].buffType == updateType and 
			DoesWindowExist("DuffTimer_Bar_"..windowsKey.."_"..effectIndex) 
		then
			table.remove(DuffTimer.Buffs[windowsKey],WindowGetId("DuffTimer_Bar_"..windowsKey.."_"..effectIndex))
			DestroyWindow("DuffTimer_Bar_"..windowsKey.."_"..effectIndex)
			DuffTimer.RebuildAnchors(windowsKey)
		end
	end
	DuffTimer.BuffIndex[updateType][effectIndex] = nil
end

function DuffTimer.CreateBar(windowsKey, index, updateType)
	buff = DuffTimer.Buffs[windowsKey][index]
	buffData = DuffTimer.BuffIndex[updateType][buff.effectIndex].buffData
	buff.windowName = "DuffTimer_Bar_"..windowsKey.."_"..buffData.effectIndex
	if DoesWindowExist(buff.windowName) then return end
	if DuffTimer.Settings.Bar[windowsKey].barType <= DuffTimer.Options.GetBarTypeCount() then
		CreateWindowFromTemplate(buff.windowName, DuffTimer.BarTypes[DuffTimer.Settings.Bar[windowsKey].barType], "Root")
		WindowSetDimensions(buff.windowName, WindowGetDimensions("DuffTimer_Win"..windowsKey))
	else
		if Duffskin then
			if not Duffskin.CreateBar(buff.windowName, DuffTimer.Settings.Bar[windowsKey].barType-DuffTimer.Options.GetBarTypeCount()) then return end
		else
			return
		end
	end
	local barScale = WindowGetScale("DuffTimer_Win"..windowsKey)
	WindowSetScale(buff.windowName, barScale)
	WindowForceProcessAnchors(buff.windowName)
	WindowSetId( "DuffTimer_Bar_"..windowsKey.."_"..buffData.effectIndex, index)
	local texture, x, y = GetIconData(buffData.iconNum)
	
	local red = DuffTimer.BuffIndex[updateType][buff.effectIndex].buffRed
	local green = DuffTimer.BuffIndex[updateType][buff.effectIndex].buffGreen
	local blue = DuffTimer.BuffIndex[updateType][buff.effectIndex].buffBlue
	
	if DoesWindowExist(buff.windowName.."_StatusBar") and DoesWindowExist(buff.windowName.."_StatusBarBG") then
		buff.bgx,buff.bgy= WindowGetDimensions(buff.windowName.."_StatusBarBG")
		buff.anchor,_,_,_,_ = WindowGetAnchor(buff.windowName.."_StatusBar",1)
		local texture
		if buff.anchor == "bottom" or buff.anchor == "top" then
			texture = DuffTimer.Settings.verticalTexture
			buff.vertFill = true
		else
			texture = DuffTimer.Settings.horizontalTexture
			buff.vertFill = false
		end
		texture = DuffTimer.LibSA:GetMetadata(DuffTimer.textures[texture].name)
		if texture then
			DynamicImageSetTexture(buff.windowName.."_StatusBar", texture.name, 0, 0)
			if texture.size then
				DynamicImageSetTextureDimensions(buff.windowName.."_StatusBar", texture.size[1], texture.size[2])
			end
		end
		WindowSetTintColor(buff.windowName.."_StatusBar", red, green, blue)
		WindowSetAlpha(buff.windowName.."_StatusBarBG", DuffTimer.Settings.barBGOpacity)
		WindowSetAlpha(buff.windowName.."_StatusBar", DuffTimer.Settings.barOpacity)
		if buffData.permanentUntilDispelled then
			DuffTimer.PermStatusBarSet(buff, updateType)
			buff.updateBar=false
		else
			DuffTimer.StatusBarSet(buff, updateType)
			buff.updateBar=true
		end
	else
		buff.updateBar=false
	end
	if DoesWindowExist(buff.windowName.."_Border") then
		WindowSetTintColor(buff.windowName.."_Border", red, green, blue)
		WindowSetAlpha(buff.windowName.."_Border", DuffTimer.Settings.iconOpacity)
	end
	if DoesWindowExist(buff.windowName.."_Icon") then
		DynamicImageSetTexture(buff.windowName.."_Icon", texture, x, y)
		WindowSetAlpha(buff.windowName.."_Icon", DuffTimer.Settings.iconOpacity)
		if DuffTimer.Settings.Bar[windowsKey].tooltip == 2
		then 
			WindowSetHandleInput(buff.windowName, true)
			WindowSetHandleInput(buff.windowName.."_Icon", true)
			WindowRegisterCoreEventHandler(buff.windowName.."_Icon", "OnMouseOver", "DuffTimer.OnMouseOverIcon")
			WindowRegisterCoreEventHandler(buff.windowName.."_Icon", "OnRButtonUp", "DuffTimer.OnRButtonUpIcon")
		end
	end

	if DoesWindowExist(buff.windowName.."_BuffName") then
		DuffTimer.SetBarName(windowsKey,index, updateType)
	end
	
	if DoesWindowExist(buff.windowName.."_Timer") then
		buff.updateTimer = true
		local x,y=WindowGetDimensions(buff.windowName.."_Timer")
		local scale = x/TIMER_WINDOW_LENGTH
		if scale > 1 then scale = 1 end
		WindowSetDimensions(buff.windowName.."_Timer", TIMER_WINDOW_LENGTH, TIMER_WINDOW_HEIGHT)
		WindowSetScale(buff.windowName.."_Timer",scale * barScale)
		LabelSetFont(buff.windowName.."_Timer", WStringToString(DuffTimer.Fonts[DuffTimer.Settings.font]), 23)
		DuffTimer.SetBarTimer(windowsKey,index, updateType)
		WindowSetFontAlpha(buff.windowName.."_Timer", DuffTimer.Settings.textOpacity) 
	else
		buff.updateTimer = false
	end
	
	if DuffTimer.Settings.Bar[windowsKey].tooltip == 3
	then
		WindowSetHandleInput(buff.windowName, true)
		WindowRegisterCoreEventHandler(buff.windowName, "OnMouseOver", "DuffTimer.OnMouseOverIcon")
		WindowRegisterCoreEventHandler(buff.windowName, "OnRButtonUp", "DuffTimer.OnRButtonUpIcon")
	end
end


function DuffTimer.AnchorBar(index, windowsKey, position, anchorIndex)
	local windowName = DuffTimer.Buffs[windowsKey][index].windowName
	WindowSetId(windowName, index)
	if position > DuffTimer.Settings.Bar[windowsKey].maxBars
	then
		WindowSetShowing(windowName,false)
		return
	else
		WindowSetShowing(windowName,true)
	end

	-- Growth 1 = UP, 2=Left, 3=Right, 4 = Down
	local anchors = { {"topleft","bottomleft"}, {"bottomright","bottomleft"}, { "bottomleft", "bottomright" }, {"bottomleft","topleft"} }

	local location, anchorTo, point, relPoint
	local x=0
	local y=0
	WindowClearAnchors(windowName)
		
	if position == 1 then
		point = "center"
		relPoint = "center"
		if DuffTimer.Settings.Bar[windowsKey].worldAttach and DuffTimer.WindowTypes[DuffTimer.Settings.Bar[windowsKey].windowType].target
		then
			anchorTo = "DuffTimer_Win"..windowsKey.."_Attach"
			x = DuffTimer.Settings.Bar[windowsKey].worldX
			y = DuffTimer.Settings.Bar[windowsKey].worldY
		else
			anchorTo = "DuffTimer_Win"..windowsKey
		end
	else
		anchorTo = DuffTimer.Buffs[windowsKey][index+(1*anchorIndex)].windowName
		if (DuffTimer.Settings.Bar[windowsKey].maxRows > 0) and
			(not (math.fmod(position-1, DuffTimer.Settings.Bar[windowsKey].maxRows) > 0))
		then
			anchorTo = DuffTimer.Buffs[windowsKey][index + DuffTimer.Settings.Bar[windowsKey].maxRows*anchorIndex].windowName
			point, relPoint = unpack(anchors[DuffTimer.Settings.Bar[windowsKey].columnGrowth])
		else
			anchorTo = DuffTimer.Buffs[windowsKey][index+(1*anchorIndex)].windowName
			point, relPoint = unpack(anchors[DuffTimer.Settings.Bar[windowsKey].rowGrowth])
		end
	end
	WindowAddAnchor(windowName, relPoint, anchorTo, point, x, y)
end

function DuffTimer.RefreshWindow(windowsKey)
	updateType = DuffTimer.WindowTypes[DuffTimer.Settings.Bar[windowsKey].windowType].buffType
	for position,v in ipairs(DuffTimer.Buffs[windowsKey]) do
		if position >  DuffTimer.Settings.Bar[windowsKey].maxBars then return end
		if not DoesWindowExist("DuffTimer_Bar_"..windowsKey.."_"..v.effectIndex) or position > DuffTimer.Settings.Bar[windowsKey].maxBars then
			return
		end

		if v.updateTimer then
			DuffTimer.SetBarTimer(windowsKey, position, updateType)
		end
		if DuffTimer.Settings.Bar[windowsKey].minDuration > 0.1 and DuffTimer.BuffIndex[updateType][v.effectIndex].duration < DuffTimer.Settings.Bar[windowsKey].minDuration 
			and not DuffTimer.BuffIndex[updateType][v.effectIndex].buffData.permanentUntilDispelled  then
			table.remove(DuffTimer.Buffs[windowsKey],WindowGetId(v.windowName))
			DestroyWindow(v.windowName)
			DuffTimer.RebuildAnchors(windowsKey)
		end
		if v.updateBar then
			DuffTimer.StatusBarSet(v,updateType)
		end
	end
end

function DuffTimer.UpdateDurations()
	if not DuffTimer.BuffIndex then return end
	for _, windowType in ipairs(DuffTimer.WindowTypes) do
		for k,v in pairs(DuffTimer.BuffIndex[windowType.buffType]) do
			v.duration = v.duration - duration
			for key,maxDur in pairs(v.long) do
				if  maxDur >= v.duration then
					DuffTimer.AddNewEffectByWindow(key,k,windowType.buffType)
					v.long[key] = nil
				end
			end
		end
	end
end

function DuffTimer.ResetWindow(windowsKey)
	updateType = DuffTimer.WindowTypes[DuffTimer.Settings.Bar[windowsKey].windowType].buffType
	for k,v in ipairs(DuffTimer.Buffs[windowsKey]) do
		DuffTimer.BuffIndex[updateType][v.effectIndex] = nil
		DestroyWindow(v.windowName)
	end
	DuffTimer.Buffs[windowsKey] = { }
end

function DuffTimer.FormatTime(time)
	local timeLeft
	if time < 0 then
		timeLeft = "0.0"
	elseif time > 3600 then
		timeLeft = ("%.0f\h"):format(tostring((time/3600) + 0.5))
	elseif time > 60 then
		timeLeft = ("%.0f\m"):format(tostring((time/60) + 0.5))
	else
		timeLeft = ((DuffTimer.Settings.refreshRate > 0.1) and "%.0f\s" or "%.1f\s"):format(tostring(time))
	end
	return towstring(timeLeft)
end

function DuffTimer.RebuildAnchors(windowsKey)
	if DuffTimer.Settings.Bar[windowsKey].reverseSort then
		local position = 0
		for index = table.maxn(DuffTimer.Buffs[windowsKey]), 1, -1 do
			position = position + 1
			DuffTimer.AnchorBar(index, windowsKey,position, 1)
		end	
	else
		for index = 1, table.maxn(DuffTimer.Buffs[windowsKey]), 1 do
			DuffTimer.AnchorBar(index, windowsKey, index, -1)
		end
	end
end

function DuffTimer.FindPosition(windowsKey, effectIndex, updateType)
	local sort_order = DuffTimer.sort_parameters[DuffTimer.Settings.Bar[windowsKey].sortOrder]
	local par1, par2
	local function NumberFromBoolean (b)
            if (b)
            then
                return 0
            end
            return 1
        end
	
	local function CompareRC(buff1, buff2, sort_order, sort_column)
		if sort_column > table.maxn(sort_order) then return false end
		local par = sort_order[sort_column].name
		local rev = sort_order[sort_column].reverse
		local ptype = type(buff1.buffData[par])
		if par=="buff" then -- Special case, we need to use the buff-frame value isntead of isBuff or isDeBuff.
			par1 = buff1.buffType
			par2 = buff2.buffType
			if par1=="Neutral-Frame" then par1="Buff-Frame" end
			if par2=="Neutral-Frame" then par2="Buff-Frame" end
		elseif ptype == "boolean" then
			par1 = NumberFromBoolean (buff1.buffData[par] ) 
			par2 = NumberFromBoolean ( buff2.buffData[par] )
		elseif par == "duration" then 
			par1 = buff1.duration 
			par2 = buff2.duration
		elseif ptype == "number" or ptype == "string" or ptype == "wstring"  then
			par1 = buff1.buffData[par] 
			par2 = buff1.buffData[par]
		end
		if rev then
			local t = par1
			par1 = par2
			par2 = t
		end
		
		if par1 < par2 then return true
		elseif par1 > par2 then return false
		else return CompareRC(buff1, buff2, sort_order, sort_column+1)
		end
	end
	
	local buff1 = DuffTimer.BuffIndex[updateType][effectIndex]
	for k,v in ipairs(DuffTimer.Buffs[windowsKey]) do
		if CompareRC(buff1, DuffTimer.BuffIndex[updateType][v.effectIndex], sort_order, 1) then return k end
	end
	return table.maxn(DuffTimer.Buffs[windowsKey])+1
end

function DuffTimer.OnMouseOverIcon()
	if DuffTimer.testMode then return end
	local windowsKey, effectIndex = string.match(SystemData.ActiveWindow.name,"DuffTimer_Bar_([0-9]+)_([0-9]+)")
	windowsKey = tonumber(windowsKey)
	effectIndex = tonumber(effectIndex)
	updateType = DuffTimer.WindowTypes[DuffTimer.Settings.Bar[windowsKey].windowType].buffType
	Tooltips.CreateTextOnlyTooltip( SystemData.ActiveWindow.name, nil) 
	Tooltips.SetTooltipColorDef (1, 1, Tooltips.COLOR_HEADING)
	Tooltips.SetTooltipColorDef (1, 2, Tooltips.COLOR_HEADING)
	Tooltips.SetTooltipActionText (GetString (StringTables.Default.TEXT_R_CLICK_TO_REMOVE_EFFECT))
	Tooltips.SetTooltipText(1, 1, DuffTimer.BuffIndex[updateType][effectIndex].buffData.name)
	Tooltips.SetTooltipText(3, 1, DuffTimer.BuffIndex[updateType][effectIndex].buffData.effectText)
	Tooltips.SetTooltipText(1, 2, DataUtils.GetAbilityTypeText(DuffTimer.BuffIndex[updateType][effectIndex].buffData))
	Tooltips.Finalize()
	local tooltip_anchor = { RelativePoint = "top", RelativeTo = SystemData.ActiveWindow.name, Point = "bottom", XOffset = 0, YOffset = 20}
	Tooltips.AnchorTooltip(tooltip_anchor)
end

function DuffTimer.OnRButtonUpIcon()
	if DuffTimer.testMode then return end
	local windowsKey, effectIndex = string.match(SystemData.ActiveWindow.name,"DuffTimer_Bar_([0-9]+)_([0-9]+)")
	effectIndex = tonumber(effectIndex)
	windowsKey = tonumber(windowsKey)
	updateType = DuffTimer.WindowTypes[DuffTimer.Settings.Bar[windowsKey].windowType].buffType
	if DuffTimer.BuffIndex[updateType][effectIndex].buffData.castByPlayer  and updateType == GameData.BuffTargetType.SELF then
		RemoveEffect(effectIndex)
	end
end

function DuffTimer.PermStatusBarSet(buff, updateType)
	if DuffTimer.Settings.classicColors then
		x = 0
		y = 0
	else
		x = buff.bgx
		y = buff.bgy
	end
	WindowSetDimensions(buff.windowName.."_StatusBar", x, y)
end

function DuffTimer.StatusBarSet(buff, updateType)
	local buffIndex = DuffTimer.BuffIndex[updateType][buff.effectIndex]
	if not DoesWindowExist(buff.windowName.."_StatusBar") then return end
	local x,y
	if buff.vertFill then
		y = buff.bgy * buffIndex.duration / buffIndex.maxDuration
		x = buff.bgx
	else
		x = buff.bgx * buffIndex.duration / buffIndex.maxDuration
		y = buff.bgy
	end
	WindowSetDimensions(buff.windowName.."_StatusBar", x, y)
end

function DuffTimer.SavePositions()
	local anchor, scale, buffType, dimensions
	if not DuffTimer.Settings or not DuffTimer.SavedSettings then return end
	for k=1,DuffTimer.Settings.windows,1 do
		if DoesWindowExist("DuffTimer_Win"..k) then 
			scale = WindowGetScale("DuffTimer_Win"..k)
			buffType = DuffTimer.WindowTypes[DuffTimer.Settings.Bar[k].windowType].buffType
			dimensions = { }
			dimensions.x, dimensions.y = WindowGetDimensions("DuffTimer_Win"..k)
			anchor = { }
			anchor.point, anchor.relPoint, anchor.window,
				anchor.x, anchor.y = WindowGetAnchor("DuffTimer_Win"..k, 1)
			if buffType > GameData.BuffTargetType.GROUP_MEMBER_END 
				or buffType == GameData.BuffTargetType.GROUP_MEMBER_START
			then
				DuffTimer.SavedSettings.Bar[k].scale = scale
				DuffTimer.SavedSettings.Bar[k].anchor = DuffTimer.TableCopy(anchor)
				DuffTimer.Options.Settings.Bar[k].scale = scale	 
				DuffTimer.Options.Settings.Bar[k].anchor = DuffTimer.TableCopy(anchor)
				DuffTimer.SavedSettings.Bar[k].dimensions = DuffTimer.TableCopy(dimensions)
				DuffTimer.Options.Settings.Bar[k].dimensions = DuffTimer.TableCopy(dimensions)
			else
				if not DuffTimer.SavedSettings.Bar[DuffTimer.Settings.Bar[k].parent].groupAnchor then
					DuffTimer.SavedSettings.Bar[DuffTimer.Settings.Bar[k].parent].groupAnchor = { }
					DuffTimer.Options.Settings.Bar[DuffTimer.Settings.Bar[k].parent].groupAnchor = { }
				end
				DuffTimer.SavedSettings.Bar[DuffTimer.Settings.Bar[k].parent].groupAnchor[buffType] = DuffTimer.TableCopy(anchor)
				DuffTimer.Options.Settings.Bar[DuffTimer.Settings.Bar[k].parent].groupAnchor[buffType] = DuffTimer.TableCopy(anchor)
			end
		end
	end
end

function DuffTimer.LayoutEditorCallback()
	DuffTimer.SavePositions()
	if not DoesWindowExist("LayoutEditorWindow") or not WindowGetShowing("LayoutEditorWindow") then DuffTimer.ResetAddon() end
end

function DuffTimer.OnShutdown()
	DuffTimer.SavePositions()
end

function DuffTimer.SetBarTimer(windowsKey, index, updateType)
	local buff = DuffTimer.Buffs[windowsKey][index]
	local buffData = DuffTimer.BuffIndex[updateType][buff.effectIndex].buffData
	LabelSetText(buff.windowName.."_Timer", DuffTimer.FormatTime(DuffTimer.BuffIndex[updateType][buff.effectIndex].duration))
	WindowSetShowing(buff.windowName.."_Timer", not buffData.permanentUntilDispelled)
	
	if buffData.stackCount > 1 then
		LabelSetText(buff.windowName.."_Timer", L"x"..buffData.stackCount)
	else
		LabelSetText(buff.windowName.."_Timer", DuffTimer.FormatTime(DuffTimer.BuffIndex[updateType][buff.effectIndex].duration))
		WindowSetShowing(buff.windowName.."_Timer", not buffData.permanentUntilDispelled)
	end
end

function DuffTimer.SetBarName(windowsKey, index, updateType)
	local buff = DuffTimer.Buffs[windowsKey][index]
	local buffData = DuffTimer.BuffIndex[updateType][buff.effectIndex].buffData
	local barScale = WindowGetScale("DuffTimer_Win"..windowsKey)
	LabelSetText(buff.windowName.."_BuffName_Label", buffData.name)
	LabelSetFont(buff.windowName.."_BuffName_Label", WStringToString(DuffTimer.Fonts[DuffTimer.Settings.font]), 23)
	local nameX, nameY = WindowGetDimensions(buff.windowName.."_BuffName")
	WindowSetDimensions(buff.windowName.."_BuffName_Label",nameX,nameY)
		
	local function scaleName(count)
		if count > 4 then return end
		local lblX,lblY = LabelGetTextDimensions(buff.windowName.."_BuffName_Label")
		
		local scale = nameX / lblX
		if scale > 1 then scale = 1 end
		if scale < DuffTimer.Settings.scaleText then scale = DuffTimer.Settings.scaleText end
		WindowSetDimensions(buff.windowName.."_BuffName_Label", nameX/scale , TIMER_WINDOW_HEIGHT)
	
		WindowSetScale(buff.windowName.."_BuffName_Label", scale*barScale)
		local newLblX, newLblY = LabelGetTextDimensions(buff.windowName.."_BuffName_Label")
		if newLblX > lblX and scale < 1 and scale > DuffTimer.Settings.scaleText then scaleName(count+1) end
	end
	scaleName(1)
	WindowSetFontAlpha(buff.windowName.."_BuffName_Label", DuffTimer.Settings.textOpacity) 
end

function DuffTimer.TestMode(mode)
	if not mode then mode = not DuffTimer.testMode end
	if DuffTimer.testmode == mode and not mode then return end
	DuffTimer.testMode = mode
	if mode then
		-- Initiate test mode
		local abilityTable = GetAbilityTable(GameData.AbilityType.STANDARD)
		local abilityIndex = { }
		local abilityCount = 0
		DuffTimer.Shutdown()
		DuffTimer.Settings = DuffTimer.TableCopy(DuffTimer.Options.Settings)
		DuffTimer.Startup()
		for k,v in pairs(abilityTable) do 
			table.insert(abilityIndex,k)
			abilityCount = abilityCount + 1
		end
		for _,windowType in ipairs(DuffTimer.WindowTypes) do
			local buffType = windowType.buffType
			DuffTimer.BuffIndex[buffType] = { }
			for k,v in pairs(abilityTable) do 
				DuffTimer.BuffIndex[buffType][k] = { }
				DuffTimer.BuffIndex[buffType][k].effectIndex = k
				DuffTimer.BuffIndex[buffType][k].buffData = v
				DuffTimer.BuffIndex[buffType][k].buffData.effectIndex = k
				DuffTimer.BuffIndex[buffType][k].buffData.abilityId = k
				DuffTimer.BuffIndex[buffType][k].buffData.stackCount = 1
				DuffTimer.BuffIndex[buffType][k].buffData.duration = 100
				DuffTimer.BuffIndex[buffType][k].maxDuration = 100
				DuffTimer.BuffIndex[buffType][k].duration = math.random(100)
				DuffTimer.BuffIndex[buffType][k].buffType = "Buff-Frame"
				DuffTimer.BuffIndex[buffType][k].long = { }
				local color = { }
				DuffTimer.BuffIndex[buffType][k].buffType, _, _, color.red, color.green, color.blue = 
					DataUtils.GetAbilityTypeTextureAndColor(GetAbilityData(k))
				DuffTimer.BuffIndex[buffType][k].buffRed = v.typeColorRed or color.red or 128
				DuffTimer.BuffIndex[buffType][k].buffGreen = v.typeColorGreen or color.green or 128
				DuffTimer.BuffIndex[buffType][k].buffBlue = v.typeColorBlue or color.blue or 128
			end
		end
		for windowsKey = 1, DuffTimer.Settings.windows, 1 do
			if not DuffTimer.Settings.Bar[windowsKey].enable then continue end
			if DuffTimer.Settings.Bar[windowsKey].worldAttach then DuffTimer.Settings.Bar[windowsKey].worldAttach = false end
			if DuffTimer.Settings.Bar[windowsKey].maxRows >.1 and  DuffTimer.Settings.Bar[windowsKey].maxColumns > .1 then
				barCount =  DuffTimer.Settings.Bar[windowsKey].maxRows *  DuffTimer.Settings.Bar[windowsKey].maxColumns
			elseif  DuffTimer.Settings.Bar[windowsKey].maxRows <.1 and  DuffTimer.Settings.Bar[windowsKey].maxColumns > .1 then
				barCount = DuffTimer.Settings.Bar[windowsKey].maxColumns
			elseif DuffTimer.Settings.Bar[windowsKey].maxRows >.1 and  DuffTimer.Settings.Bar[windowsKey].maxColumns < .1 then
				barCount = DuffTimer.Settings.Bar[windowsKey].maxRows
			else
				barCount = 10 + math.random(5)
			end
			local nextAbility
			if abilityCount > barCount then
				nextAbility = math.random(abilityCount-barCount)
			else
				nextAbility = 1
			end
			for position=1,barCount,1 do
				newBuff = { }
				newBuff.effectIndex = abilityIndex[nextAbility]
				nextAbility = nextAbility+1
				if nextAbility < abilityCount then
					table.insert(DuffTimer.Buffs[windowsKey], position, newBuff)
					DuffTimer.CreateBar(windowsKey,position,DuffTimer.WindowTypes[DuffTimer.Settings.Bar[windowsKey].windowType].buffType)
				end
			end
			DuffTimer.RebuildAnchors(windowsKey)
		end
	else
		-- Terminate test mode
		DuffTimer.Shutdown()
		DuffTimer.Settings = DuffTimer.TableCopy(DuffTimer.SavedSettings)
		DuffTimer.Startup()
	end
end



function DuffTimer.ResetGroupWindows()
	local buffType
	for windowsKey = 1, DuffTimer.Settings.windows,1 do
		buffType = DuffTimer.WindowTypes[DuffTimer.Settings.Bar[windowsKey].windowType].buffType
		if buffType >= GameData.BuffTargetType.GROUP_MEMBER_START and buffType <= GameData.BuffTargetType.GROUP_MEMBER_END then
			DuffTimer.ResetWindow(windowsKey)
		end
	end
end

