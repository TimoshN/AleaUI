local E = AleaUI
local L = E.L
local AM = E:Module("Alerts")

if ( E.isClassic ) then 
	return 
end 

local defaults = {
	enable = true,
	growUp = true,
	showInCombat = true,
	texture = E.media.default_bar_texture_name2,
	fadeTime = 4,
	
	width = 350,
	height = 20,

	colors = {
		["ACH"] 			= {215/255, 174/255, 0, 1},
		["ITEM"] 			= { 61/255, 156/255, 153/255, 1},
		["LFG"] 			= { 0, 149/255, 215/255, 1},
		["MONEY"] 			= {97/255, 79/255, 0, 1},
		["CRITERIA"]		= {129/255, 110/255, 152/255, 1},
		["GARRISON"]		= {5/255, 50/255, 14/255, 1},
		["GARRISON_FOLLOW"]	= {5/255, 50/255, 14/255, 1},	
		['RESORCES'] 		= {5/255, 50/255, 14/255, 1},
		["GARRISON_BUILD"] 	= {200/255, 10/255, 10/255, 1},
		["NEW_RECIPE"]		= { 153/255, 0, 153/255, 1},
		['QUEST']   		= { 215/255, 174/255, 0, 1},
		['XP']				= { 0, 149/255, 215/255, 1},
	},
}

E.default_settings.alerts = defaults


local MAX_ACHIEVEMENT_ALERTS = 2;
local LOOT_WON_ALERT_FRAMES = {};
local MONEY_WON_ALERT_FRAMES = {};
local DELAYED_ACHIEVEMENT_ALERTS = {};
local ACHIEVEMENT_ID_INDEX = 1;
local OLD_ACHIEVEMENT_INDEX = 2;
local MAX_QUEUED_ACHIEVEMENT_TOASTS = 6;

	
local events = {
	'ACHIEVEMENT_EARNED',
	'LFG_COMPLETION_REWARD',
	'CRITERIA_EARNED',
	"GUILD_CHALLENGE_COMPLETED",
	"CHALLENGE_MODE_COMPLETED",
	"LOOT_ITEM_ROLL_WON",
	"SHOW_LOOT_TOAST",
	"PET_BATTLE_CLOSE",
	"STORE_PRODUCT_DELIVERED",
	"GARRISON_BUILDING_ACTIVATABLE",
	"GARRISON_MISSION_FINISHED",
	"GARRISON_FOLLOWER_ADDED",
	"SHOW_LOOT_TOAST_UPGRADE",
	'SHOW_PVP_FACTION_LOOT_TOAST',
	
	"NEW_RECIPE_LEARNED",
	"SHOW_LOOT_TOAST_LEGENDARY_LOOTED",
	
	"SCENARIO_COMPLETED",	
	"QUEST_LOOT_RECEIVED",
	
	"GARRISON_RANDOM_MISSION_ADDED",
	
	'SKILL_LINES_CHANGED',
}	


local garrison_icons = {
	["GarrMission_MissionIcon-Combat"] = {0.39,0.51,0.13,0.25},
	
	[" "] = { 0.13,0.25,0.25,0.39 },
}

local alertsName = {
	["ACH"] 				= L['Achievements'],
	["ITEM"] 				= L['Item'],
	["LFG"] 				= L['LFG'],
	["MONEY"] 				= L['Money'],
	["CRITERIA"]			= L['Criteria'],
	["GARRISON"]			= L['Mission complete'],
	["GARRISON_FOLLOW"]		= L['New follower'],
	["GARRISON_BUILD"] 		= L['Build complete'],
	['RESORCES'] 			= L['Resorces'],
	["NEW_RECIPE"] 			= L['New recipe'],
	['QUEST'] 	 			= L['Quests'],
	['XP']					= XP,
}


local colors = {
	["ACH"] 		= {215/255, 174/255, 0, 1},
	["ITEM"] 		= { 61/255, 156/255, 153/255, 1},
	["LFG"] 		= { 0, 149/255, 215/255, 1},
	["MONEY"] 		= {97/255, 79/255, 0, 1},
	["CRITERIA"]	= {129/255, 110/255, 152/255, 1},
	["TEST"]		= {1, 1, 0, 1},
	["GARRISON"]	= {5/255, 50/255, 14/255, 1},
	["GARRISON_FOLLOW"]	= {5/255, 50/255, 14/255, 1},	
	['RESORCES'] 		= {5/255, 50/255, 14/255, 1},
	["GARRISON_BUILD"] 	= {200/255, 10/255, 10/255, 1},
	["NEW_RECIPE"]		= { 153/255, 0, 153/255, 1},
	['QUEST']   		= { 215/255, 174/255, 0, 1},
	['XP']				= { 0, 149/255, 215/255, 1},
}

local ItemQualityTable

do
	ItemQualityTable = {}
	for i = 0, 7 do
	  local r, g, b, hex = GetItemQualityColor(i);
	  ItemQualityTable[i] = { r = r, g = g, b = b, hex = hex }
	end
end

local gametooltip = CreateFrame("GameTooltip", "AleaUIAlertsGameToolTip", nil, "GameTooltipTemplate"); -- Tooltip name cannot be nil	
gametooltip:SetBackdrop({ bgFile = "Interface/Tooltips/UI-Tooltip-Background", edgeFile = nil})
gametooltip:SetBackdropColor(0,0,0,0.7)
gametooltip:SetBackdropBorderColor(0,0,0,1)
gametooltip:SetScale(0.7)
gametooltip:Show();gametooltip:Hide()

local mover = CreateFrame("Frame", nil, AleaUI.UIParent)
mover:SetSize(350,20)
mover:SetPoint("CENTER", AleaUI.UIParent, "CENTER", 0,0)

local alerts_frames = {}
local alerts_frames_used = {}

function AM:SortAlertFrames()
	for i,frame in ipairs(alerts_frames_used) do
		frame:ClearAllPoints()
	end

	for i,frame in ipairs(alerts_frames_used) do
		if E.db.alerts.growUp then
			frame:SetPoint("BOTTOM", mover, "TOP", 0, (E.db.alerts.height+5)*(i-1))
		else
			frame:SetPoint("TOP", mover, "BOTTOM", 0, -(E.db.alerts.height+5)*(i-1))
		end
	end
end

function AM:UpdateSettings()
	AM:SortAlertFrames()
	
	for i, frame in ipairs(alerts_frames) do
		frame.background:SetTexture(E:GetTexture(E.db.alerts.texture))
	end
	
	for i, frame in ipairs(alerts_frames_used) do
		frame.background:SetTexture(E:GetTexture(E.db.alerts.texture))
	end
	
end

local function OnShow_Tolltip(self)
	
	if self.tolltip then
	
		gametooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT")
		gametooltip:SetHyperlink(self.tolltip)
		
		gametooltip:Show()

	elseif self.item_tolltip then
		
		gametooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT")
		gametooltip:SetHyperlink(self.item_tolltip)
		
		gametooltip:Show()
	
	elseif self.followerID then
	
		local link = C_Garrison.GetFollowerLink(self.followerID);
		if ( link ) then
			GarrisonFollowerTooltip:ClearAllPoints();
			GarrisonFollowerTooltip:SetPoint("BOTTOM", self, "TOP");
			
			GarrisonShipyardFollowerTooltip:ClearAllPoints()
			GarrisonShipyardFollowerTooltip:SetPoint("BOTTOM", self, "TOP");
			
			local _, garrisonFollowerID, quality, level, itemLevel, ability1, ability2, ability3, ability4, trait1, trait2, trait3, trait4 = strsplit(":", link);
			GarrisonFollowerTooltip_Show(tonumber(garrisonFollowerID), false, tonumber(quality), tonumber(level), 0, 0, tonumber(itemLevel), tonumber(ability1), tonumber(ability2), tonumber(ability3), tonumber(ability4), tonumber(trait1), tonumber(trait2), tonumber(trait3), tonumber(trait4));
		end
	elseif self.tradeSkillID and self.recipeID then
	
	
	end
end

local missTexture = GetSpellTexture(202)
local removeItemsDuplicates = {}


function ALEAUI_GetAlertFrame(used, tag, text, icon, id, point, reuse)
	if not E.db.alerts.enable then return end
	
	if used == 'ITEM' then 
		if ( removeItemsDuplicates[id] and removeItemsDuplicates[id] > GetTime() ) then 
			return
		end

		
		removeItemsDuplicates[id] = GetTime() + 5
	end

	if not E.db.alerts.showInCombat and InCombatLockdown() then
		return
	end
	
	if #alerts_frames_used > 10 then
		return
	end
	
	local f
	local reused = false
	
	if reuse == 'REUSE' then
		for i=1, #alerts_frames_used do
			if alerts_frames_used[i].tag == tag then
				f = alerts_frames_used[i]
				reused = true
				break
			end
		end
	end
	
	f = f or tremove(alerts_frames) or AM:CreateAlertFrame()

	f:SetSize(E.db.alerts.width, E.db.alerts.height)
	f.icon:SetSize(E.db.alerts.height, E.db.alerts.height)
	f.background:SetPoint("TOPLEFT", f, "TOPLEFT", E.db.alerts.height+3, 0)
	
	--f.text:SetMaxLines(ceil(600/E.db.alerts.width))
	
	
	f.elapsed = 0
	f:SetAlpha(1)
	f:Show()
	
	f.tolltip = nil
	f.item_tolltip = nil
	f.followerID = nil
	f.tradeSkillID = nil
	f.recipeID = nil
	
	f.tag = tag
	
	f.background:SetTexture(E:GetTexture(E.db.alerts.texture))
	f.background:SetVertexColor(unpack(E.db.alerts.colors[used] or colors[used]))
	f.icon.texture:SetTexCoord(0,1,0,1)
	
--	f.text:SetFont(AleaUI.media.default_font, AleaUI.media.default_font_size-4, "OUTLINE")
	
	icon = icon or missTexture
	
--	text = used..'-'..tag..'\n'..text
	
	if used == "LFG" then
		f.text:SetText(text)
		f.icon.texture:SetTexture("Interface\\LFGFrame\\LFGIcon-"..icon)
	elseif used == 'QUEST' then
		f.text:SetText(text)
		f.icon.texture:SetTexture('Interface\\GossipFrame\\AvailableQuestIcon')
	elseif used == 'XP' then
		f.text:SetText(text)
		f.icon.texture:SetTexture("Interface\\Icons\\xp_icon")
		f.icon.texture:SetTexCoord(unpack(AleaUI.media.texCoord))
	elseif used == "ITEM" then
		
		f.text:SetText(text)
		f.icon.texture:SetTexture(icon)
		f.icon.texture:SetTexCoord(unpack(AleaUI.media.texCoord))
		f.item_tolltip = id
	elseif used == "MONEY" then
		
		f.text:SetText(text)
		f.icon.texture:SetTexture(icon)
		f.icon.texture:SetTexCoord(unpack(AleaUI.media.texCoord))
		
	elseif used == 'RESORCES' then
	
		f.text:SetText(text)
		f.icon.texture:SetTexture(icon)
		f.icon.texture:SetTexCoord(unpack(AleaUI.media.texCoord))
	
	elseif used == "GARRISON" or used == "GARRISON_BUILD" then
	
		local filename, width, height, left, right, top, bottom, tilesHoriz, tilesVert = GetAtlasInfo(icon)
	
	
		f.text:SetText(text)
		
		f.icon.texture:SetTexture(filename)
		f.icon.texture:SetTexCoord(left, right, top, bottom)
	elseif used == "GARRISON_FOLLOW" then
		local filename, width, height, left, right, top, bottom, tilesHoriz, tilesVert = GetAtlasInfo(icon)
	
	
		f.text:SetText(text)
		
		f.icon.texture:SetTexture(filename)
		f.icon.texture:SetTexCoord(left, right, top, bottom)
		f.followerID = id
	elseif used == "ACH" or used == "CRITERIA" then
		if point and point > 0 then
			f.text:SetText("("..point..") "..text)
		else
			f.text:SetText(text)
		end	
		f.tolltip = GetAchievementLink(id)
		f.icon.texture:SetTexture(icon)
		f.icon.texture:SetTexCoord(unpack(AleaUI.media.texCoord))
	elseif used == "NEW_RECIPE" then
		
		f.text:SetText(text)
		f.icon.texture:SetTexture(icon)
		f.icon.texture:SetTexCoord(unpack(AleaUI.media.texCoord))
		f.tradeSkillID = id
		f.recipeID = point
	else
		
		local itemname, itemlink = GetItemInfo(64998)
		f.icon.texture:SetTexCoord(unpack(AleaUI.media.texCoord))
		f.item_tolltip = itemlink
		f.icon.texture:SetTexture("Interface\\Icons\\spell_shadow_shadowwordpain")
		
		if text then
			f.text:SetText(text)
		else
			f.text:SetText("TEST ALERT "..( itemname or " NO NAME"))
		end
	end

	if not reused then
		table.insert(alerts_frames_used, f)
	end
	
	if E.db.alerts.hideOnSameTime then
		for i=1, #alerts_frames_used do
			alerts_frames_used[i].elapsed = 0
			alerts_frames_used[i]:SetAlpha(1)
		end
	end
	
	AM:SortAlertFrames()
	
	return f
end

function AM:RemoveAlertFrame(frame1)	
	for i,frame in ipairs(alerts_frames_used) do
	
		if frame == frame1 then
			table.insert(alerts_frames, table.remove(alerts_frames_used, i))
			return AM:SortAlertFrames()			
		end
	end
end


function AM:CreateAlertFrame()
	
	local f = CreateFrame("Frame", nil, AleaUI.UIParent)
	f:SetSize(E.db.alerts.width, E.db.alerts.height)
	
	f:SetFrameStrata("HIGH")
	
	f.background = f:CreateTexture(nil, "BACKGROUND")

	f.background:SetPoint("TOPLEFT", f, "TOPLEFT", E.db.alerts.height+3, 0)
	f.background:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 0, 0)
	f.background:SetTexture(E:GetTexture(E.db.alerts.texture))
	f.background:SetColorTexture(0.2, 0.2, 0.2, 0.7)
	
	f.icon = CreateFrame("Frame", nil, f)
	f.icon:SetPoint("TOPLEFT", f, "TOPLEFT", -1, 0)
	f.icon:SetSize(E.db.alerts.height, E.db.alerts.height)
	f.icon.f = f

	E:CreateBackdrop(f.icon, nil, {0,0,0,1}, {0.2,0.2,0.2,1})
	
	f.icon.texture = f.icon:CreateTexture(nil, "ARTWORK")
	f.icon.texture:SetTexCoord(unpack(AleaUI.media.texCoord))
	f.icon.texture:SetAllPoints()
	f.icon.texture:SetTexture("Interface\\Icons\\spell_shadow_shadowwordpain")
	
	f.text = f:CreateFontString(nil, "OVERLAY")
	f.text:SetFontObject(GameFontWhite)
	f.text:SetFont(AleaUI.media.default_font, AleaUI.media.default_font_size, "OUTLINE")
	f.text:SetSize(0,0)
--	f.text:SetJustifyH("MIDDLE")
--	f.text:SetJustifyV('TOP')
	f.text:SetPoint("LEFT", f.background, "LEFT", -5, 0)
	f.text:SetPoint("RIGHT", f, "RIGHT", 5, 0)
	f.text:SetText("TEST")
	f.text:SetWordWrap(true)
--	f.text:SetMaxLines(2)
	
	E:CreateBackdrop(f, f.background, {0,0,0,1}, {0,0,0,0})

	f.elapsed = 0
	
	f:SetScript("OnUpdate", function(self, elapsed)
	
		if self.ismouseover then return end
		
		self.elapsed = self.elapsed + elapsed
		
		if self.elapsed > E.db.alerts.fadeTime then
			
			local alpha = self:GetAlpha()-elapsed
	
			if alpha <= 0 then
				self:Hide()
				self:SetAlpha(1)		
				self.elapsed = 0			
				AM:RemoveAlertFrame(self)
			else
				self:SetAlpha(self:GetAlpha()-elapsed)
			end
		else
			self:SetAlpha(1)
		end
	end)
	
	f:SetScript("OnEnter", function(self)
		self.elapsed = 0
		self:SetAlpha(1)
		
		if E.db.alerts.hideOnSameTime then
			for i=1, #alerts_frames_used do
				alerts_frames_used[i].elapsed = 0
				alerts_frames_used[i]:SetAlpha(1)
			end
		end
	
		OnShow_Tolltip(self)
		
		self.ismouseover = true
	end)
	f:SetScript("OnShow", function(self)
		self.elapsed = 0
		self:SetAlpha(1)
		if E.db.alerts.hideOnSameTime then
			for i=1, #alerts_frames_used do
				alerts_frames_used[i].elapsed = 0
				alerts_frames_used[i]:SetAlpha(1)
			end
		end
	end)
	f:SetScript("OnLeave", function(self)
		self.elapsed = 0
		self:SetAlpha(1)
		
		if E.db.alerts.hideOnSameTime then
			for i=1, #alerts_frames_used do
				alerts_frames_used[i].elapsed = 0
				alerts_frames_used[i]:SetAlpha(1)
			end
		end
		
		gametooltip:Hide()
		GarrisonFollowerTooltip:Hide()
		GarrisonShipyardFollowerTooltip:Hide()		
		self.ismouseover = false
	end)
	
	f.icon:SetScript("OnEnter", function(self)
		self.f.elapsed = 0
		self.f:SetAlpha(1)
		
		if E.db.alerts.hideOnSameTime then
			for i=1, #alerts_frames_used do
				alerts_frames_used[i].elapsed = 0
				alerts_frames_used[i]:SetAlpha(1)
			end
		end
		
		OnShow_Tolltip(self.f)
		self.f.ismouseover = true
	end)

	f.icon:SetScript("OnLeave", function(self)
		self.f.elapsed = 0
		self.f:SetAlpha(1)
		
		if E.db.alerts.hideOnSameTime then
			for i=1, #alerts_frames_used do
				alerts_frames_used[i].elapsed = 0
				alerts_frames_used[i]:SetAlpha(1)
			end
		end
		
		gametooltip:Hide()
		GarrisonFollowerTooltip:Hide()
		GarrisonShipyardFollowerTooltip:Hide()		
		self.f.ismouseover = false
	end)
	
	return f
end

function AM:SHOW_PVP_FACTION_LOOT_TOAST(event, ...)
	local typeIdentifier, itemLink, quantity, specID, sex, isPersonal, lessAwesome = ...;
	if ( typeIdentifier == "item" ) then
		local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture = GetItemInfo(itemLink);
		local color = ItemQualityTable[itemRarity];
		local r, g, b = color and color.r or 1, color and color.g or 1, color and color.b or 1
		
		local itemLevel = GetDetailedItemLevelInfo(itemLink)

		if ( itemLevel ) then 
			itemLevel = '('.. tostring(itemLevel) ..')'
		else
			itemLevel = ''
		end

		ALEAUI_GetAlertFrame("ITEM", 'PVP1', E.RGBToHex(r*255, g*255, b*255)..itemName..itemLevel, itemTexture, itemLink, 0)
	elseif ( typeIdentifier == "money" ) then
	--	MoneyWonAlertFrame_ShowAlert(quantity);
		
		ALEAUI_GetAlertFrame("MONEY", 'PVP1', E.RGBToHex(237, 183, 19)..GetMoneyString(quantity), "Interface\\Icons\\INV_Misc_Coin_02", 0, 0)
	elseif ( typeIdentifier == "currency" ) then	
		local name, amount, texturePath, earnedThisWeek, weeklyMax, totalMax, isDiscovered = GetCurrencyInfo(itemLink)
		ALEAUI_GetAlertFrame("RESORCES", 'PVP1', E.RGBToHex(255, 255, 255)..name..'('..quantity..')', texturePath, 0, 0)
	end
end

function AM:ACHIEVEMENT_EARNED(event, achievementID, alreadyEarned)
	print(event, achievementID, alreadyEarned)
	
	local _, name, points, completed, month, day, year, description, flags, icon, rewardText, isGuildAch, wasEarnedByMe, earnedBy = GetAchievementInfo(achievementID);
	
--	print(GetAchievementInfo(achievementID))
	
	ALEAUI_GetAlertFrame("ACH", 'ACHIVEMENT1', name, icon, achievementID, points)
end

function AM:CRITERIA_EARNED(event, achievementID, criteriaID)
	
	if criteriaID and type(criteriaID) == 'string' then
		local _, name, points, completed, month, day, year, description, flags, icon, rewardText, isGuildAch, wasEarnedByMe, earnedBy = GetAchievementInfo(achievementID);
		
		ALEAUI_GetAlertFrame("CRITERIA", 'CRITERIA1', criteriaID, icon, achievementID, 0)
		
	else
		local criteriaString, criteriaType, completed, quantity, reqQuantity, charName, flags, assetID, quantityString, criteriaID, eligible =  GetAchievementCriteriaInfoByID(achievementID, criteriaID);
		local _, name, points, completed, month, day, year, description, flags, icon, rewardText, isGuildAch, wasEarnedByMe, earnedBy = GetAchievementInfo(achievementID);
		
	--	print(GetAchievementCriteriaInfoByID(achievementID, criteriaID))
		
		ALEAUI_GetAlertFrame("CRITERIA", 'CRITERIA2', criteriaString.." ("..quantity.."/"..reqQuantity..")", icon, achievementID, 0)
	
	end
end

function AM:LFG_COMPLETION_REWARD(...)
	local name, typeID, subtypeID, textureFilename, moneyBase, moneyVar, experienceBase, experienceVar, numStrangers, numRewards= GetLFGCompletionReward();
	local alertName = name
	
	local moneyAmount = moneyBase + moneyVar * numStrangers;	
	local experienceGained = experienceBase + experienceVar * numStrangers;
	
	if ( C_Scenario.IsInScenario() ) then
		local _, _, _, _, hasBonusStep, isBonusStepComplete = C_Scenario.GetInfo();
	
		if ( hasBonusStep and isBonusStepComplete ) then
			alertName = alertName.." "..SCENARIO_BONUS_LABEL
		end

		if moneyAmount > 0 then
			ALEAUI_GetAlertFrame("MONEY", 'LFG-Complete1', E.RGBToHex(237, 183, 19)..GetMoneyString(moneyAmount), "Interface\\Icons\\INV_Misc_Coin_02", 0, 0)
		end	
		if experienceGained > 0 and UnitLevel("player") < MAX_PLAYER_LEVEL then
			ALEAUI_GetAlertFrame("XP",  'LFG-Complete1', E.RGBToHex(255, 255, 255)..XP..":"..E.NumCompress(experienceGained))
		end
		
		ALEAUI_GetAlertFrame("LFG",  'LFG-Complete1', alertName, textureFilename, 0, 0)
		
	else
		if moneyAmount > 0 then
			ALEAUI_GetAlertFrame("MONEY",  'LFG-Complete2', E.RGBToHex(237, 183, 19)..GetMoneyString(moneyAmount), "Interface\\Icons\\INV_Misc_Coin_02", 0, 0)
		end
		if experienceGained > 0 and UnitLevel("player") < MAX_PLAYER_LEVEL then
			ALEAUI_GetAlertFrame("XP",  'LFG-Complete2', E.RGBToHex(255, 255, 255)..XP..":"..E.NumCompress(experienceGained))
		end
		
		ALEAUI_GetAlertFrame("LFG",  'LFG-Complete2', alertName, textureFilename, 0, 0)		
	end
end

local GCC_tex = "Interface\\Icons\\achievement_bg_wineos_underxminutes"
function AM:GUILD_CHALLENGE_COMPLETED(event, ...)
	local challengeType, count, max1 = ...
	ALEAUI_GetAlertFrame("MONEY", 'GUILD-Challenge-Complete1', format("%s %s %d/%d", L['Guild challenge'], _G["GUILD_CHALLENGE_TYPE"..challengeType], count, max1) , GCC_tex, 0,0)	
end

function AM:CHALLENGE_MODE_COMPLETED(...)	
	local mapID, level, time, onTime, keystoneUpgradeLevels = C_ChallengeMode.GetCompletionInfo();
	local name, _, timeLimit = C_ChallengeMode.GetMapUIInfo(mapID);
	
	if name then
		ALEAUI_GetAlertFrame("MONEY", 'Challenge-Complete1', name..'('..level..')', GCC_tex, 0,0)		
	else
		local name1 = GetInstanceInfo()
		
		if name1 then
			
			ALEAUI_GetAlertFrame("MONEY", 'Challenge-Complete1', name1..'('..(level or '??')..')', GCC_tex, 0,0)	
		end
		
	--	print('T', mapID, level, time, onTime, keystoneUpgradeLevels, name, _, timeLimit)
	--	print('T1', name1)
	end
end

function AM:LOOT_ITEM_ROLL_WON(event, itemLink, quantity, rollType, roll)
	local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture = GetItemInfo(itemLink);
	local color = ItemQualityTable[itemRarity];
	local r, g, b = color and color.r or 1, color and color.g or 1, color and color.b or 1

	local itemLevel = GetDetailedItemLevelInfo(itemLink)

	if ( itemLevel ) then 
		itemLevel = '('.. tostring(itemLevel) ..')'
	else
		itemLevel = ''
	end

	ALEAUI_GetAlertFrame("ITEM", 'LootItemRollWon', E.RGBToHex(r*255, g*255, b*255)..itemName..itemLevel, itemTexture, itemLink, 0)
end
function AM:SHOW_LOOT_TOAST(event, typeIdentifier, itemLink, quantity, _4, _5, _6, source)

	if ( typeIdentifier == "item" ) then
		
		local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture = GetItemInfo(itemLink);
		local color = ItemQualityTable[itemRarity];
		local r, g, b = color and color.r or 1, color and color.g or 1, color and color.b or 1
		
		local quantityStr = ''
		if quantity and quantity > 1 then
			quantityStr = ' |cffffffffx'..quantity
		end
		
		local itemLevel = GetDetailedItemLevelInfo(itemLink)

		if ( itemLevel ) then 
			itemLevel = '('.. tostring(itemLevel) ..')'
		else
			itemLevel = ''
		end

		ALEAUI_GetAlertFrame("ITEM", 'ShowLootToast1', E.RGBToHex(r*255, g*255, b*255)..itemName..itemLevel..quantityStr, itemTexture, itemLink, 0)
		
	elseif ( typeIdentifier == "money" ) then
		
		ALEAUI_GetAlertFrame("MONEY", 'ShowLootToast2', E.RGBToHex(237, 183, 19)..GetMoneyString(quantity), "Interface\\Icons\\INV_Misc_Coin_02", 0, 0)
		
	elseif ( typeIdentifier == "currency" and source == 10 and itemLink:match("currency:824") ) then
		local name, amount, texturePath, earnedThisWeek, weeklyMax, totalMax, isDiscovered = GetCurrencyInfo(824)
		
		ALEAUI_GetAlertFrame("RESORCES", 'ShowLootToast3', E.RGBToHex(255, 255, 255)..name..' |cffffffffx'..quantity, texturePath, 0, 0)
	end
end

function AM:PET_BATTLE_CLOSE(...)

end

function AM:STORE_PRODUCT_DELIVERED(event, icon)	
	ALEAUI_GetAlertFrame("MONEY", 'StoreDelivered1', L['Product delivered'], icon, 0, 0)
end

function AM:SHOW_LOOT_TOAST_UPGRADE(event, ...)	
	local itemLink, quantity, specID, sex, baseQuality, isPersonal = ...;
	local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture = GetItemInfo(itemLink);
	local color = ItemQualityTable[itemRarity];
	local r, g, b = color and color.r or 1, color and color.g or 1, color and color.b or 1
--	ALEAUI_GetAlertFrame("ITEM", 'LootToastUpgrade1', E.RGBToHex(r*255, g*255, b*255)..itemName.."("..tostring(itemLevel)..")" , itemTexture, itemLink, 0)
end

function AM:GARRISON_BUILDING_ACTIVATABLE(event, name)
	ALEAUI_GetAlertFrame("GARRISON_BUILD", 'GarrisonBuild1', L["Building"].." "..name.." "..L["complete."], "GarrMission_MissionIcon-Combat", 0, 0)
end

function AM:GARRISON_MISSION_FINISHED(event, ...)
	local missionInfo
	
	if InCombatLockdown() then return end
	
	if E.IsLegion then
		local missionIndex, missionID = ...
		missionInfo = C_Garrison.GetBasicMissionInfo(missionID);
	else
		local missionID = ...
		missionInfo = C_Garrison.GetBasicMissionInfo(missionID);
	end
	
	ALEAUI_GetAlertFrame("GARRISON", 'GarrisonMissionFinished1', L['Mission']..' "'..missionInfo.name..'" '.. L["complete."], missionInfo.typeAtlas, 0, 0)
end

function AM:GARRISON_FOLLOWER_ADDED(event, ...)
	local followerID, name, class, level, quality, isUpgraded, texPrefix, followerType = ...;
	
	local color = ITEM_QUALITY_COLORS[quality] or { r = 0, g = 1, b = 0 };
	
	if (followerType == LE_FOLLOWER_TYPE_SHIPYARD_6_2 ) then
		ALEAUI_GetAlertFrame("GARRISON_FOLLOW", 'GarrisonFollowerAdded2',AleaUI.RGBToHex(color.r*255, color.g*255, color.b*255)..L['New ship']..' "'..name..'"', "GarrMission_MissionIcon-Combat", followerID, 0)
	else
		ALEAUI_GetAlertFrame("GARRISON_FOLLOW", 'GarrisonFollowerAdded1', AleaUI.RGBToHex(color.r*255, color.g*255, color.b*255)..L['New follower']..' "'..name..'"', "GarrMission_MissionIcon-Combat", followerID, 0)
	end
end

function AM:NEW_RECIPE_LEARNED(event, recipeID)
	local tradeSkillID, skillLineName = C_TradeSkillUI.GetTradeSkillLineForRecipe(recipeID);
	if tradeSkillID then
		local recipeName = GetSpellInfo(recipeID);
		if recipeName then

			local rank = GetSpellRank(recipeID);

			local name = rank and rank > 1 and UPGRADED_RECIPE_LEARNED_TITLE or NEW_RECIPE_LEARNED_TITLE

			local rankTexture = NewRecipeLearnedAlertFrame_GetStarTextureFromRank(rank);
			if rankTexture then
				name = name..' '..format("%s %s", recipeName, rankTexture)
			else
				name = name..' '..recipeName
			end

			ALEAUI_GetAlertFrame('NEW_RECIPE', 'NewRecipeLearned1', name, C_TradeSkillUI.GetTradeSkillTexture(tradeSkillID), tradeSkillID, recipeID)
		end
	end

end

function AM:SHOW_LOOT_TOAST_LEGENDARY_LOOTED(event, ...)
	local itemLink = ...;

	local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture = GetItemInfo(itemLink);
	local color = ItemQualityTable[itemRarity];
	local r, g, b = color and color.r or 1, color and color.g or 1, color and color.b or 1

	ALEAUI_GetAlertFrame("ITEM", 'LegendaryItem1', E.RGBToHex(r*255, g*255, b*255)..itemName, itemTexture, itemLink, 0)
end
	
function AM:SCENARIO_COMPLETED(event, ...)
	
	local scenarioName, currentStage, numStages, flags, hasBonusStep, isBonusStepComplete, _, xp, money, scenarioType, areaName = C_Scenario.GetInfo();
	
	if scenarioType == LE_SCENARIO_TYPE_LEGION_INVASION then
		
		if true then return end
		
		local alertName = L['Quest complete']
		
		if scenarioName then
			alertName = L['Complete']..' "'..scenarioName..'"'
		elseif areaName then
			alertName = L['Complete']..' "'..areaName..'"'
		end
		
		if money > 0 then
			ALEAUI_GetAlertFrame("MONEY", 'SCENARIO_COMPLETED1',E.RGBToHex(237, 183, 19)..GetMoneyString(money), "Interface\\Icons\\INV_Misc_Coin_02", 0, 0)
		end
		if xp > 0 and UnitLevel("player") < MAX_PLAYER_LEVEL then
			ALEAUI_GetAlertFrame("XP", 'SCENARIO_COMPLETED1',E.RGBToHex(255, 255, 255)..XP..":"..E.NumCompress(xp))
		end
			
			
		if rewardItemLink then
			local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture = GetItemInfo(rewardItemLink);
			local color = itemRarity and ItemQualityTable[itemRarity] or false
			local r, g, b = color and color.r or 1, color and color.g or 1, color and color.b or 1
			
			local _, _, _, _, textureInstant = GetItemInfoInstant(rewardItemLink);
			
			local itemLevel = GetDetailedItemLevelInfo(rewardItemLink)

			if ( itemLevel ) then 
				itemLevel = '('.. tostring(itemLevel) ..')'
			else
				itemLevel = ''
			end

			ALEAUI_GetAlertFrame("ITEM", 'SCENARIO_COMPLETED1',E.RGBToHex(r*255, g*255, b*255)..(itemName or L['Item received'])..itemLevel, itemTexture or textureInstant, rewardItemLink, 0)
		end
		
	--	ALEAUI_GetAlertFrame('QUEST', 'SCENARIO_COMPLETED1', alertName)
	else
		local alertName = L['Scenario complete']
		if scenarioName then
			alertName = L['Complete']..'"'..scenarioName..'"'
		elseif areaName then
			alertName = L['Complete']..'"'..areaName..'"'
		end
		
	--	ALEAUI_GetAlertFrame('QUEST', 'SCENARIO_COMPLETED2', alertName)
	end
end	

function AM:QUEST_LOOT_RECEIVED(event, ...)
	local questID, rewardItemLink = ...;
	
	if QuestUtils_IsQuestWorldQuest(questID) then
	--	WorldQuestCompleteAlertSystem:AddAlert(questID, rewardItemLink);	
		local isInArea, isOnMap, numObjectives, taskName, displayAsObjective = GetTaskInfo(questID);
		local icon = WorldQuestCompleteAlertFrame_GetIconForQuestID(questID);
		local money = GetQuestLogRewardMoney(questID);
		local xp = GetQuestLogRewardXP(questID);
		
		local alertName = taskName and L['Complete']..' "'..taskName..'"' or L['Quest complete']

		if money > 0 then
			ALEAUI_GetAlertFrame("MONEY", 'QUEST_LOOT_RECEIVED1', E.RGBToHex(237, 183, 19)..GetMoneyString(money), "Interface\\Icons\\INV_Misc_Coin_02", 0, 0)
		end
		if xp > 0 and UnitLevel("player") < MAX_PLAYER_LEVEL then
			ALEAUI_GetAlertFrame("XP", 'QUEST_LOOT_RECEIVED1', E.RGBToHex(255, 255, 255)..XP..":"..E.NumCompress(xp))
		end
		for currencyIndex = 1, GetNumQuestLogRewardCurrencies(questID) do
			local name, texture, count = GetQuestLogRewardCurrencyInfo(currencyIndex, questID);

			ALEAUI_GetAlertFrame("RESORCES", 'QUEST_LOOT_RECEIVED1', E.RGBToHex(255, 255, 255)..name..'('..count..')', texture, 0, 0)			
		end
		
		if rewardItemLink then
			local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture = GetItemInfo(rewardItemLink);
			local color = itemRarity and ItemQualityTable[itemRarity] or false
			local r, g, b = color and color.r or 1, color and color.g or 1, color and color.b or 1
			
			local _, _, _, _, textureInstant = GetItemInfoInstant(rewardItemLink);
			
		--	ALEAUI_GetAlertFrame("ITEM", 'QUEST_LOOT_RECEIVED1', E.RGBToHex(r*255, g*255, b*255)..(itemName or 'Предмет получен'), itemTexture or textureInstant, rewardItemLink, 0)
		end
	
	--	ALEAUI_GetAlertFrame('QUEST', 'QUEST_LOOT_RECEIVED1', alertName)
	else
		local scenarioName, currentStage, numStages, flags, hasBonusStep, isBonusStepComplete, _, xp, money, scenarioType, areaName = C_Scenario.GetInfo();
		local isInArea, isOnMap, numObjectives, taskName, displayAsObjective = GetTaskInfo(questID);
		
		
		local alertName = L['Quest complete']
		
	--	print('QUEST_LOOT_RECEIVED', 'QuestID', questID, 'TaskName', taskName)
		
		if scenarioName then
			alertName = L['Complete']..' "'..scenarioName..'"'
		elseif areaName then
			alertName = L['Complete']..' "'..areaName..'"'
		end
	
		if money > 0 then
			ALEAUI_GetAlertFrame("MONEY", 'QUEST_LOOT_RECEIVED2', E.RGBToHex(237, 183, 19)..GetMoneyString(money), "Interface\\Icons\\INV_Misc_Coin_02", 0, 0)
		end
		if xp > 0 and UnitLevel("player") < MAX_PLAYER_LEVEL then
			ALEAUI_GetAlertFrame("XP", 'QUEST_LOOT_RECEIVED2', E.RGBToHex(255, 255, 255)..XP..":"..E.NumCompress(xp))
		end
			
			
		if rewardItemLink then
			local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture = GetItemInfo(rewardItemLink);
			local color = itemRarity and ItemQualityTable[itemRarity] or false
			local r, g, b = color and color.r or 1, color and color.g or 1, color and color.b or 1
			
			local _, _, _, _, textureInstant = GetItemInfoInstant(rewardItemLink);
			
			local itemLevel = GetDetailedItemLevelInfo(rewardItemLink)

			if ( itemLevel ) then 
				itemLevel = '('.. tostring(itemLevel) ..')'
			else
				itemLevel = ''
			end

			ALEAUI_GetAlertFrame("ITEM", 'QUEST_LOOT_RECEIVED2', E.RGBToHex(r*255, g*255, b*255)..(itemName or L['Item received'])..itemLevel, itemTexture or textureInstant, rewardItemLink, 0)
		end
		
	--	ALEAUI_GetAlertFrame('QUEST', 'QUEST_LOOT_RECEIVED2', alertName)
	end
end	

function AM:QUEST_TURNED_IN(event, ...)
	local questID = ...;
	if QuestUtils_IsQuestWorldQuest(questID) then
	--	WorldQuestCompleteAlertSystem:AddAlert(questID, rewardItemLink);	
		local isInArea, isOnMap, numObjectives, taskName, displayAsObjective = GetTaskInfo(questID);
		local icon = WorldQuestCompleteAlertFrame_GetIconForQuestID(questID);

		local alertName = taskName and L['Complete']..' "'..taskName..'"' or L['Quest complete']

		ALEAUI_GetAlertFrame('QUEST', 'QUEST_TURNED_IN', alertName)
	end
end

function AM:GARRISON_RANDOM_MISSION_ADDED(event, missionID)
	local missionInfo = C_Garrison.GetBasicMissionInfo(missionID);

	if not missionInfo then
		print('Cant get GetBasicMissionInfo for', missionID)
	else 
		local level = missionInfo.level
		local iLevel = "(" .. missionInfo.iLevel .. ")"
		local isRare = missionInfo.isRare
		local name = missionInfo.name
		
		ALEAUI_GetAlertFrame('QUEST', 'GARRISON_RANDOM_MISSION_ADDED1', L['Complete']..' "'..name..'"')
	end
end

local proffLastValue = {}


local function AlertProfessionUp(id)
	if not id then return end
	
	local name, texture, rank, maxRank, numSpells, spelloffset, skillLine, rankModifier, specializationIndex, specializationOffset = GetProfessionInfo(id);
	
	if proffLastValue[id] and proffLastValue[id] ~= rank then
		proffLastValue[id] = rank
		
		ALEAUI_GetAlertFrame('NEW_RECIPE', 'AlertProfessionUp1-ID:'..id, format('%s (%d/%d)', name, rank, maxRank), texture, nil, nil, 'REUSE')
	else
		proffLastValue[id] = rank
	end
end

function AM:SKILL_LINES_CHANGED(event)
	local prof1, prof2, arch, fish, cook, firstAid = GetProfessions();
	
	AlertProfessionUp(prof1)
	AlertProfessionUp(prof2)
	AlertProfessionUp(arch)
	AlertProfessionUp(fish)
	AlertProfessionUp(cook)
	AlertProfessionUp(firstAid)
end



function AM:UpdateSize()


end

local function InitAlertMover()
	E:Mover(mover, "alertMover")
	
	AM:Register(events)	
 
--	ScenarioAlertFrame1.Show = ScenarioAlertFrame1.Hide
--	ScenarioAlertFrame1:Hide()
	AM:UpdateSettings()
	
	AlertFrame:UnregisterEvent("ACHIEVEMENT_EARNED")
	AlertFrame:UnregisterEvent("CRITERIA_EARNED")
	AlertFrame:UnregisterEvent("LFG_COMPLETION_REWARD")
	AlertFrame:UnregisterEvent("GUILD_CHALLENGE_COMPLETED")
	AlertFrame:UnregisterEvent("CHALLENGE_MODE_COMPLETED")
	AlertFrame:UnregisterEvent("LOOT_ITEM_ROLL_WON")
	AlertFrame:UnregisterEvent("SHOW_LOOT_TOAST")
	AlertFrame:UnregisterEvent("STORE_PRODUCT_DELIVERED")
	AlertFrame:UnregisterEvent("SHOW_LOOT_TOAST_UPGRADE")
	
	AlertFrame:UnregisterEvent("SHOW_PVP_FACTION_LOOT_TOAST")
	
	AlertFrame:UnregisterEvent("GARRISON_BUILDING_ACTIVATABLE")
	AlertFrame:UnregisterEvent("GARRISON_MISSION_FINISHED")
	AlertFrame:UnregisterEvent("GARRISON_FOLLOWER_ADDED")
	
	AlertFrame:UnregisterEvent("NEW_RECIPE_LEARNED")
	AlertFrame:UnregisterEvent("SHOW_LOOT_TOAST_LEGENDARY_LOOTED")
	
	AlertFrame:UnregisterEvent("SCENARIO_COMPLETED")
	AlertFrame:UnregisterEvent("QUEST_LOOT_RECEIVED")
	
		
	AlertFrame:UnregisterEvent("QUEST_TURNED_IN")
	
	AlertFrame:UnregisterEvent("GARRISON_RANDOM_MISSION_ADDED")
	
end

if AlertFrameMixin then
	hooksecurefunc(AlertFrameMixin, "OnLoad", function(self)

		self:UnregisterEvent("ACHIEVEMENT_EARNED")
		self:UnregisterEvent("CRITERIA_EARNED")
		self:UnregisterEvent("LFG_COMPLETION_REWARD")
		self:UnregisterEvent("GUILD_CHALLENGE_COMPLETED")
		self:UnregisterEvent("CHALLENGE_MODE_COMPLETED")
		self:UnregisterEvent("LOOT_ITEM_ROLL_WON")
		self:UnregisterEvent("SHOW_LOOT_TOAST")
		self:UnregisterEvent("STORE_PRODUCT_DELIVERED")
		self:UnregisterEvent("SHOW_LOOT_TOAST_UPGRADE")
		
		self:UnregisterEvent("SHOW_PVP_FACTION_LOOT_TOAST")
		
		self:UnregisterEvent("GARRISON_BUILDING_ACTIVATABLE")
		self:UnregisterEvent("GARRISON_MISSION_FINISHED")
		self:UnregisterEvent("GARRISON_FOLLOWER_ADDED")
		
		self:UnregisterEvent("NEW_RECIPE_LEARNED")
		self:UnregisterEvent("SHOW_LOOT_TOAST_LEGENDARY_LOOTED")

		self:UnregisterEvent("SCENARIO_COMPLETED")
		self:UnregisterEvent("QUEST_LOOT_RECEIVED")
		self:UnregisterEvent("QUEST_TURNED_IN")
		
		self:UnregisterEvent("GARRISON_RANDOM_MISSION_ADDED")
		
		self:HookScript('OnEvent', function(...)
			print(...)
		end)
	end)
else
	hooksecurefunc("AlertFrame_OnLoad", function(self)

		AlertFrame:UnregisterEvent("ACHIEVEMENT_EARNED")
		AlertFrame:UnregisterEvent("CRITERIA_EARNED")
		AlertFrame:UnregisterEvent("LFG_COMPLETION_REWARD")
		AlertFrame:UnregisterEvent("GUILD_CHALLENGE_COMPLETED")
		AlertFrame:UnregisterEvent("CHALLENGE_MODE_COMPLETED")
		AlertFrame:UnregisterEvent("LOOT_ITEM_ROLL_WON")
		AlertFrame:UnregisterEvent("SHOW_LOOT_TOAST")
		AlertFrame:UnregisterEvent("STORE_PRODUCT_DELIVERED")
		AlertFrame:UnregisterEvent("SHOW_LOOT_TOAST_UPGRADE")
		
		AlertFrame:UnregisterEvent("SHOW_PVP_FACTION_LOOT_TOAST")
		
		AlertFrame:UnregisterEvent("GARRISON_BUILDING_ACTIVATABLE")
		AlertFrame:UnregisterEvent("GARRISON_MISSION_FINISHED")
		AlertFrame:UnregisterEvent("GARRISON_FOLLOWER_ADDED")
		
		AlertFrame:UnregisterEvent("NEW_RECIPE_LEARNED")
		AlertFrame:UnregisterEvent("SHOW_LOOT_TOAST_LEGENDARY_LOOTED")
		
		AlertFrame:UnregisterEvent("SCENARIO_COMPLETED")
		AlertFrame:UnregisterEvent("QUEST_LOOT_RECEIVED")
		
		AlertFrame:UnregisterEvent("QUEST_TURNED_IN")
		
		AlertFrame:UnregisterEvent("GARRISON_RANDOM_MISSION_ADDED")
	
	
	end)
end

if ( BonusRollMoneyWonFrame ) then 
	BonusRollMoneyWonFrame:Kill()
end 

if ( MoneyWonAlertFrame_SetUp ) then 
	hooksecurefunc('MoneyWonAlertFrame_SetUp', function(self, rewardQuantity)
		self:Hide()
		self.animIn:Stop()
		ALEAUI_GetAlertFrame("MONEY", nil, E.RGBToHex(237, 183, 19)..GetMoneyString(rewardQuantity), "Interface\\Icons\\INV_Misc_Coin_02", 0, 0)
		AlertFrame:UpdateAnchors();
	end)
end 

if ( BonusRollLootWonFrame ) then 
	BonusRollLootWonFrame:Kill()
end 

if ( LootWonAlertFrame_SetUp ) then
	hooksecurefunc('LootWonAlertFrame_SetUp', function(self, rewardLink, rewardQuantity, rollType, roll, rewardSpecID, isCurrency, showFactionBG, lootSource, lessAwesome, isUpgraded)
		self:Hide()
		self.animIn:Stop()
		
		local itemName, itemHyperLink, itemRarity, itemTexture, itemLevel, _
		local color;
		local r, g, b
		
		if (isCurrency == true) then
			itemName, _, itemTexture, _, _, _, _, itemRarity = GetCurrencyInfo(rewardLink);
			if ( lootSource == LOOT_SOURCE_GARRISON_CACHE ) then
				itemName = format(GARRISON_RESOURCES_LOOT, rewardQuantity);
			else
				itemName = format(CURRENCY_QUANTITY_TEMPLATE, rewardQuantity, itemName);
			end
			itemHyperLink = rewardLink;		
		else
			itemName, itemHyperLink, itemRarity, _, _, _, _, _, _, itemTexture = GetItemInfo(rewardLink);

			itemLevel = GetDetailedItemLevelInfo(rewardLink)

			if ( itemLevel ) then 
				itemLevel = '('.. tostring(itemLevel) ..')'
			end
		end
		
		color = ItemQualityTable[itemRarity];
		r, g, b = color and color.r or 1, color and color.g or 1, color and color.b or 1
		
		if not itemName then 
			AlertFrame:UpdateAnchors();
			return 
		end
		
		ALEAUI_GetAlertFrame("ITEM", nil, E.RGBToHex(r*255, g*255, b*255)..itemName..(itemLevel or '') , itemTexture, rewardLink, 0)
		
		AlertFrame:UpdateAnchors();
	end)
end 

E:OnInit2(InitAlertMover)

E.GUI.args.general.args.alerts = {
	name = L['Alerts'],
	order = 5,
	type = 'group',
	embend = true,
	args = {},
}

E.GUI.args.general.args.alerts.args.Enable = {
	name = L['Enable'],
	order = 0.1,
--	width = 'full',
	type = 'toggle',
	set = function()
		E.db.alerts.enable = not E.db.alerts.enable
	end,
	get = function()
		return E.db.alerts.enable
	end,
}

E.GUI.args.general.args.alerts.args.Unlock = {
	name = L['Unlock'],
	order = 0.2,
--	width = 'full',
	type = 'execute',
	set = function()
		E:UnlockMover('alertMover') 
	end,
	get = function()
		return
	end,
}

E.GUI.args.general.args.alerts.args.width = {
	name = L['Width'],
	order = 0.3,
	type = 'slider',
	min = 5, max = 600, step = 1,
	set = function(info, value)
		E.db.alerts.width = value
	end,
	get = function(info)
		return E.db.alerts.width
	end,
}

E.GUI.args.general.args.alerts.args.height = {
	name = L['Height'],
	order = 0.4,
	type = 'slider',
	min = 5, max = 300, step = 1,
	set = function(info, value)
		E.db.alerts.height = value
	end,
	get = function(info)
		return E.db.alerts.height
	end,
}

E.GUI.args.general.args.alerts.args.growUp = {
	name = L['Grow up'],
	order = 1,
	type = 'toggle',
	set = function()
		E.db.alerts.growUp = not E.db.alerts.growUp
		
		AM:UpdateSettings()
	end,
	get = function()
		return E.db.alerts.growUp
	end,
}

E.GUI.args.general.args.alerts.args.showInCombat = {
	name = L['Show in combat'],
	order = 2,
	type = 'toggle',
	set = function()
		E.db.alerts.showInCombat = not E.db.alerts.showInCombat
	end,
	get = function()
		return E.db.alerts.showInCombat
	end,
}

E.GUI.args.general.args.alerts.args.hideOnSameTime = {
	name = L['Hide on same time'],
	order = 2.5,
	type = 'toggle', width = 'full',
	set = function()
		E.db.alerts.hideOnSameTime = not E.db.alerts.hideOnSameTime
	end,
	get = function()
		return E.db.alerts.hideOnSameTime
	end,
}

E.GUI.args.general.args.alerts.args.texture = {
	name = L['Texture'],
	order = 3,
	type = 'statusbar',
	values = E.GetTextureList,
	set = function(info, value)
		E.db.alerts.texture = value
		
		AM:UpdateSettings()
	end,
	get = function()
		return E.db.alerts.texture
	end,
}

E.GUI.args.general.args.alerts.args.fadeTime = {
	name = L['Fade time'],
	order = 4,
	type = 'slider',
	min = 4, max = 40, step = 1,
	set = function(info, value)
		E.db.alerts.fadeTime = value
	end,
	get = function(info)
		return E.db.alerts.fadeTime
	end,
}

E.GUI.args.general.args.alerts.args.colors = {
	name = L['Colors'],
	order = 5,
	type = 'group',
	embend = true,
	args = {},
}
for k,v in pairs(alertsName) do	
	E.GUI.args.general.args.alerts.args.colors.args[k] = {
		name = v,
		order = 1,
		type = "color",
		set = function(self, r,g,b)
			E.db.alerts.colors[k] = { r, g, b, 1 }
		end,
		get = function(self)
			return E.db.alerts.colors[k][1], E.db.alerts.colors[k][2], E.db.alerts.colors[k][3], 1
		end,
	}	
end