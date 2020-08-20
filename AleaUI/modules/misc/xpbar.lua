-- Config ----------------
--------------------------
local E = AleaUI
local L = E.L
local UF = E:Module("UnitFrames")

local defaults = {
	enableXP = true,
	enableRep = true,
	enableHonor = true,
	enableArtifact = true,
	minimize = false,
}

E.default_settings.xpbar = defaults


--Bar Height and Width
local barHeight, barWidth = 10, 275.5---Where you want the fame to be anchored
local barSpace = 3
--------AnchorPoint, AnchorTo, RelativePoint, xOffset, yOffset
local Anchor = { "TOP", UIParent, "TOP", -0.5 , -2 }

--Fonts
local showText = true -- Set to false to hide text
local mouseoverText = false -- Set to true to only show text on mouseover
local flags = "OUTLINE"

--Textures
local barTex = E.media.default_bar_texture1
local flatTex = E.media.default_bar_texture2
local colorize 
local overlay 
local CommaValue 

-----------------------------------------------------------
-- Don't edit past here unless you know what your doing! --
-----------------------------------------------------------
-- Tables ----------------
--------------------------
--'Hated', 'Hostile', 'Unfriendly', 'Neutral', 'Friendly', 'Honored', 'Revered', 'Exalted'

local FactionInfo = {
	[1] = {{ 170/255, 70/255,  70/255 }, L['Hated'], "FFaa4646"},
	[2] = {{ 170/255, 70/255,  70/255 }, L['Hostile'], "FFaa4646"},
	[3] = {{ 170/255, 70/255,  70/255 }, L['Unfriendly'], "FFaa4646"},
	[4] = {{ 200/255, 180/255, 100/255 }, L['Neutral'], "FFc8b464"},
	[5] = {{ 75/255,  175/255, 75/255 }, L['Friendly'], "FF4baf4b"},
	[6] = {{ 75/255,  175/255, 75/255 }, L['Honored'], "FF4baf4b"},
	[7] = {{ 75/255,  175/255, 75/255 }, L['Revered'], "FF4baf4b"},
	[8] = {{ 155/255,  255/255, 155/255 }, L['Exalted'],"FF9bff9b"},
}

local BFAReps = { 
	2157, 
	2158,
	2164, 
	2103, 
	2163, 
	2156,
	
	2159,
	2160,
	2162,
	2161,

	2391,
	2400,
	2373 
}

local BFARepsNames = {}



-- Functions -------------
--------------------------

function CommaValue(amount)
	local formatted = amount
	local k
	while true do  
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
		if (k==0) then
			break
		end
	end
	return formatted
end

function colorize(r)
	return FactionInfo[r][3]
end

local function IsMaxLevel()
	if UnitLevel("player") == MAX_PLAYER_LEVEL then
		return true
	end
end

-- Framework -------------
--------------------------

--Prefix for naming frames
local aName = "AleaUI_XPBar"

--Create Background and Border
local backdrop = CreateFrame("Frame", aName.."Backdrop", UIParent, BackdropTemplateMixin and 'BackdropTemplate')
backdrop:SetHeight(barHeight)
backdrop:SetWidth(barWidth)
backdrop:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
backdrop:SetBackdrop({
	bgFile = barTex, 
	edgeFile = barTex, 
	tile = false, tileSize = 0, edgeSize = 1, 
	insets = { left = -1, right = -1, top = -1, bottom = -1}
})
backdrop:SetBackdropColor(0, 0, 0)
backdrop:SetBackdropBorderColor(.2, .2, .2, 0)

overlay = backdrop:CreateTexture(nil, "BORDER", backdrop)
overlay:ClearAllPoints()
overlay:SetPoint("TOPLEFT", backdrop, "TOPLEFT", 1, -1)
overlay:SetPoint("BOTTOMRIGHT", backdrop, "BOTTOMRIGHT", -1, 1)
overlay:SetTexture(barTex)
overlay:SetVertexColor(.1,.1,.1)

--Create xp status bar
local xpBar = CreateFrame("StatusBar",  aName.."xpBar", backdrop, "TextStatusBar")
xpBar:SetWidth(barWidth)
xpBar:SetHeight(GetWatchedFactionInfo() and (barHeight) or barHeight)
xpBar:SetPoint("TOP", backdrop,"TOP", 0, 0)
xpBar:SetStatusBarTexture(barTex)local _, class = UnitClass("player") local color = RAID_CLASS_COLORS[class] local r, g, b = color.r, color.g, color.b 
xpBar:SetStatusBarColor(r, g, b)

xpBar.Text = xpBar:CreateFontString(aName.."ArtifactBarText", "OVERLAY")
xpBar.Text:SetFont(AleaUI.media.default_font, AleaUI.media.default_font_size, flags)
xpBar.Text:SetPoint("CENTER", xpBar, "CENTER", 0, 1)
xpBar.Text:SetAlpha(1)

--Create Rested XP Status Bar
local restedxpBar = CreateFrame("StatusBar", aName.."restedxpBar", backdrop, "TextStatusBar")
restedxpBar:SetHeight(GetWatchedFactionInfo() and (barHeight) or barHeight)
restedxpBar:SetWidth(barWidth)
restedxpBar:SetPoint("TOP", backdrop,"TOP", 0, 0)
restedxpBar:SetStatusBarTexture(barTex)
restedxpBar:Hide()

local artifactBar = CreateFrame("StatusBar",  aName.."ArtifactBar", backdrop, "TextStatusBar")
artifactBar:SetWidth(barWidth)
artifactBar:SetHeight(GetWatchedFactionInfo() and (barHeight) or barHeight)
artifactBar:SetPoint("BOTTOM",backdrop,"BOTTOM", 0, 0)
artifactBar:SetStatusBarTexture(barTex)
artifactBar:SetStatusBarColor(0.8, 0.8, 0)

artifactBar.Text = artifactBar:CreateFontString(aName.."ArtifactBarText", "OVERLAY")
artifactBar.Text:SetFont(AleaUI.media.default_font, AleaUI.media.default_font_size, flags)
artifactBar.Text:SetPoint("CENTER", artifactBar, "CENTER", 0, 1)
artifactBar.Text:SetAlpha(1)

artifactBar.background1 = artifactBar:CreateTexture(nil, 'BACKGROUND')
artifactBar.background1:SetColorTexture(0, 0, 0, 1)
artifactBar.background1:SetPoint('TOPLEFT', -1, 1)
artifactBar.background1:SetPoint('BOTTOMRIGHT', 1, -1)

artifactBar.background2 = artifactBar:CreateTexture(nil, 'BORDER')
artifactBar.background2:SetTexture(barTex)
artifactBar.background2:SetVertexColor(0.3, 0.3, 0, 1)
artifactBar.background2:SetPoint('TOPLEFT', 0, 0)
artifactBar.background2:SetPoint('BOTTOMRIGHT', 0, 0)

local honorBar = CreateFrame("StatusBar",  aName.."HonorBar", backdrop, "TextStatusBar")
honorBar:SetWidth(barWidth)
honorBar:SetHeight(GetWatchedFactionInfo() and (barHeight) or barHeight)
honorBar:SetPoint("BOTTOM",backdrop,"BOTTOM", 0, 0)
honorBar:SetStatusBarTexture(barTex)
honorBar:SetStatusBarColor(255/255, 156/255, 0)

honorBar.Text = honorBar:CreateFontString(aName.."ArtifactBarText", "OVERLAY")
honorBar.Text:SetFont(AleaUI.media.default_font, AleaUI.media.default_font_size, flags)
honorBar.Text:SetPoint("CENTER", honorBar, "CENTER", 0, 1)
honorBar.Text:SetAlpha(1)

honorBar.background1 = honorBar:CreateTexture(nil, 'BACKGROUND')
honorBar.background1:SetColorTexture(0, 0, 0, 1)
honorBar.background1:SetPoint('TOPLEFT', -1, 1)
honorBar.background1:SetPoint('BOTTOMRIGHT', 1, -1)

honorBar.background2 = honorBar:CreateTexture(nil, 'BORDER')
honorBar.background2:SetTexture(barTex)
honorBar.background2:SetVertexColor(255/255*0.3, 156/255*0.3, 0, 1)
honorBar.background2:SetPoint('TOPLEFT', 0, 0)
honorBar.background2:SetPoint('BOTTOMRIGHT', 0, 0)


--Create reputation status bar (Only used if not max level)
local repBar = CreateFrame("StatusBar", aName.."repBar", backdrop, "TextStatusBar")
repBar:SetWidth(barWidth)
repBar:SetHeight(IsMaxLevel() and barHeight-0 or 0)
repBar:SetPoint("BOTTOM",backdrop,"BOTTOM", 0, 0)
repBar:SetStatusBarTexture(barTex)

repBar.Text = repBar:CreateFontString(aName.."ArtifactBarText", "OVERLAY")
repBar.Text:SetFont(AleaUI.media.default_font, AleaUI.media.default_font_size, flags)
repBar.Text:SetPoint("CENTER", repBar, "CENTER", 0, 1)
repBar.Text:SetAlpha(1)

repBar.background1 = repBar:CreateTexture(nil, 'BACKGROUND')
repBar.background1:SetColorTexture(0, 0, 0, 1)
repBar.background1:SetPoint('TOPLEFT', -1, 1)
repBar.background1:SetPoint('BOTTOMRIGHT', 1, -1)

repBar.background2 = repBar:CreateTexture(nil, 'BORDER')
repBar.background2:SetTexture(barTex)
repBar.background2:SetVertexColor(0.3, 0.3, 0, 1)
repBar.background2:SetPoint('TOPLEFT', 0, 0)
repBar.background2:SetPoint('BOTTOMRIGHT', 0, 0)

--Create frame used for mouseover, clicks, and text
local mouseFrame = CreateFrame("Frame", aName.."mouseFrame", backdrop)
mouseFrame:SetPoint('TOP', backdrop, 'TOP', 0, 0)
mouseFrame:EnableMouse(true)

-- InActiveBattlefield() or IsInActiveWorldPVP()

-- Level Left Text

local LevelText = xpBar:CreateFontString(aName.."LevelText", "OVERLAY")
LevelText:SetFont(AleaUI.media.default_font, AleaUI.media.default_font_size, flags)
LevelText:SetPoint("RIGHT", xpBar, "LEFT", 0, -1)



--Set all frame levels (easier to see if organized this way)
backdrop:SetFrameLevel(0)
restedxpBar:SetFrameLevel(1)
repBar:SetFrameLevel(2)
xpBar:SetFrameLevel(2)
artifactBar:SetFrameLevel(2)
honorBar:SetFrameLevel(2)
mouseFrame:SetFrameLevel(3)


local paragonReputationText = backdrop:CreateFontString(nil, "OVERLAY")
paragonReputationText:SetFont(AleaUI.media.default_font2, AleaUI.media.default_font_size2, 'NONE')
paragonReputationText:SetPoint("TOPLEFT", mouseFrame, "BOTTOMLEFT", 0, -1)
paragonReputationText:SetText('Test test test\nTest Test\nteest test')
paragonReputationText:SetShadowColor(0,0,0,1)
paragonReputationText:SetShadowOffset(1, -1)
paragonReputationText:SetJustifyH('LEFT')
	
local attept = 3

local function updateStatus()
	if E.db.xpbar.minimize then
		barHeight = 4
		barSpace = 1
	else
		barHeight = 10
		barSpace = 3
	end
	paragonReputationText:SetText('')
	
	local xp, maxXP = UnitXP("player"), UnitXPMax("player")
	if maxXP == 0 then return end

	local restXP = GetXPExhaustion()
	local percXP = floor(xp/maxXP*100)
	
	local HeightStep = 0
	
	backdrop:SetHeight(barHeight)
	xpBar:SetHeight(barHeight)
	repBar:SetHeight(barHeight)
	artifactBar:SetHeight(barHeight)
	restedxpBar:SetHeight(barHeight)	
	honorBar:SetHeight(barHeight)	
	
	xpBar.Text:SetShown(not E.db.xpbar.minimize)
	repBar.Text:SetShown(not E.db.xpbar.minimize)
	artifactBar.Text:SetShown(not E.db.xpbar.minimize)
	honorBar.Text:SetShown(not E.db.xpbar.minimize)
	
	if IsMaxLevel() then
		xpBar:Hide()
		restedxpBar:Hide()

		if not GetWatchedFactionInfo() and not HasArtifactEquipped() and not C_AzeriteItem.FindActiveAzeriteItem() then
			backdrop:Hide()
		else
			backdrop:Show()
		end
		
		LevelText:SetText('')		
	elseif E.db.xpbar.enableXP then
		xpBar:Show()
		restedxpBar:Show()
		
		HeightStep = HeightStep + barHeight + barSpace
		
		if level ~= MAX_PLAYER_LEVEL then
			LevelText:SetText('|cff4baf4c'..UnitLevel('player'))
		end

		xpBar:SetMinMaxValues(min(0, xp), maxXP)
		xpBar:SetValue(xp)
			
		if restXP then
			restedxpBar:Show()
			
			local _, class = UnitClass("player") 
			local color = RAID_CLASS_COLORS[class] 
			local r, g, b = color.r, color.g, color.b	
			
			restedxpBar:SetStatusBarColor(r,g,b, 0.40)
			restedxpBar:SetMinMaxValues(min(0, xp), maxXP)
			restedxpBar:SetValue(xp+restXP)
			xpBar.Text:SetText(format("%s/%s (%s%%|cffb3e1ff+%d%%|r)",E:ShortValue(xp),E:ShortValue(maxXP), percXP, restXP/maxXP*100))
		else
			restedxpBar:Hide()
			xpBar.Text:SetText(format("%s/%s (%s%%)", E:ShortValue(xp), E:ShortValue(maxXP), percXP))
		end
	end
	
	if E.db.xpbar.enableArtifact and not E.isClassic and not C_ArtifactUI.IsEquippedArtifactMaxed() then

		local azeriteItemLocation = C_AzeriteItem.FindActiveAzeriteItem(); 
		
		if azeriteItemLocation then

			artifactBar.xp, artifactBar.totalLevelXP = C_AzeriteItem.GetAzeriteItemXPInfo(azeriteItemLocation);
			artifactBar.currentLevel = C_AzeriteItem.GetPowerLevel(azeriteItemLocation); 
			artifactBar.xpToNextLevel = artifactBar.totalLevelXP - artifactBar.xp; 

			artifactBar:Show()
			artifactBar:SetMinMaxValues(0, artifactBar.totalLevelXP)
			artifactBar:SetValue(artifactBar.xp)
			
			artifactBar.Text:SetText(format('%d/%d (%d%%)', artifactBar.xp, artifactBar.totalLevelXP, ( artifactBar.xp/artifactBar.totalLevelXP*100) ))
			
			artifactBar:SetPoint("BOTTOM",backdrop,"BOTTOM", 0, -HeightStep)
			
			HeightStep = HeightStep + barHeight + barSpace	
		else
			artifactBar:Hide()
		end
	else
		if UnitLevel('player') == 110 and attept > 0 then
			attept = attept - 1
			C_Timer.After(1, updateStatus)
		end
		
		artifactBar:Hide()
	end
	
	if E.db.xpbar.enableHonor and not E.isClassic  then
		
		local current = UnitHonor("player");
		local max = UnitHonorMax("player");

		local level = UnitHonorLevel("player");
  
		honorBar:Show()
	
		honorBar:SetMinMaxValues(0, max)
		honorBar:SetValue(current)
		
		honorBar.Text:SetText(format('%d/%d (%d%%)', current, max, (current/max*100) ))
	
		
		honorBar:SetPoint("BOTTOM",backdrop,"BOTTOM", 0, -HeightStep)
		
		HeightStep = HeightStep + barHeight + barSpace
	else
		honorBar:Hide()
	end
	
	if GetWatchedFactionInfo() and E.db.xpbar.enableRep then
		local name, rank, minRep, maxRep, value, factionID = GetWatchedFactionInfo()
		
		local left = maxRep-minRep
		
		if left == 0 then 
			minRep = 0
			value = 999
			maxRep = 1000
		end 

		if (C_Reputation.IsFactionParagon(factionID)) then
			local currentValue, threshold = C_Reputation.GetFactionParagonInfo(factionID);
		
			minRep, maxRep, value = 0, threshold, mod(currentValue, threshold);			
		end
			
		repBar:SetMinMaxValues(minRep, maxRep)
		repBar:SetValue(value)
		repBar:SetStatusBarColor(unpack(FactionInfo[rank][1]))
		
		if maxRep == 0 then
			repBar.Text:SetText('')
		else
			repBar.Text:SetText(format("%d / %d (%d%%)", value-minRep, maxRep-minRep, (value-minRep)/(maxRep-minRep + 0.001)*100))
		end
		
		repBar:Show()
		
		repBar:SetPoint("BOTTOM",backdrop,"BOTTOM", 0, -HeightStep)
		HeightStep = HeightStep + barHeight + barSpace
	else
		repBar:Hide()
	end
	
	--Setup Exp Tooltip
	
	mouseFrame:SetHeight(HeightStep)
	mouseFrame:SetWidth(barWidth)

	mouseFrame:SetScript("OnEnter", function()

		GameTooltip:SetOwner(mouseFrame, "ANCHOR_BOTTOMLEFT", -3, barHeight)
		GameTooltip:ClearLines()
		if not IsMaxLevel() then
		--	GameTooltip:AddLine(XP..":")
		--	GameTooltip:AddLine(string.format(L['Value']..': %s/%s (%d%%)', CommaValue(xp), CommaValue(maxXP), (xp/maxXP)*100))
			GameTooltip:AddLine(string.format(XP..': %s/%s (%d%%)', CommaValue(xp), CommaValue(maxXP), (xp/maxXP)*100))
			GameTooltip:AddLine(string.format(L['VALUE_LEFT']..': %s', CommaValue(maxXP-xp)))
			if restXP then
				GameTooltip:AddLine(string.format('|cffb3e1ff'..L['Rested']..': %s (%d%%)', CommaValue(restXP), restXP/maxXP*100))
			end
		end
		
		if ( not E.isClassic ) then
			local azeriteItemLocation = C_AzeriteItem.FindActiveAzeriteItem(); 

			if azeriteItemLocation then
				if not IsMaxLevel() then GameTooltip:AddLine(" ") end
				
				artifactBar.xp, artifactBar.totalLevelXP = C_AzeriteItem.GetAzeriteItemXPInfo(azeriteItemLocation);
				artifactBar.currentLevel = C_AzeriteItem.GetPowerLevel(azeriteItemLocation); 
				artifactBar.xpToNextLevel = artifactBar.totalLevelXP - artifactBar.xp; 

				local itemName, itemLink, _, _, _, _, _, _, _, itemIcon = GetItemInfo(158075)

				GameTooltip:AddLine(L['Artifact']..': '..format('|T%s:14:14:0:0:64:64:4:60:4:60|t', itemIcon or '')..(itemLink or '[Heart of Azeroth]')..' ['..artifactBar.currentLevel..']')
				GameTooltip:AddLine(string.format(L['Current']..': %d/%d (%d%%)', artifactBar.xp, (artifactBar.totalLevelXP), artifactBar.xp/artifactBar.totalLevelXP*100))
				GameTooltip:AddLine(string.format(L['VALUE_LEFT']..': %d', artifactBar.xpToNextLevel))
			end
			
			if E.db.xpbar.enableHonor then
				GameTooltip:AddLine(" ")
				GameTooltip:AddLine(PVP..'['..(UnitHonorLevel("player") or 0)..']')
				GameTooltip:AddLine(string.format(L['Value']..': %s/%s (%d%%)', CommaValue(UnitHonor("player")), CommaValue(UnitHonorMax("player")), (UnitHonor("player")/UnitHonorMax("player"))*100))
			end 
				
			if GetWatchedFactionInfo() then
				GameTooltip:AddLine(" ")

				local name, rank, minRep, maxRep, value, factionID = GetWatchedFactionInfo()
				
				local left = maxRep-minRep
				
				if left == 0 then 
					minRep = 0
					value = 999
					maxRep = 1000
				end 

				if (C_Reputation.IsFactionParagon(factionID)) then
					local currentValue, threshold = C_Reputation.GetFactionParagonInfo(factionID);
					minRep, maxRep, value = 0, threshold, mod(currentValue, threshold);			
				end

				GameTooltip:AddLine(string.format(L['Faction']..': %s', name))
				GameTooltip:AddLine(string.format(L['Reputation']..': |c'..colorize(rank)..'%s|r', FactionInfo[rank][2]))
				GameTooltip:AddLine(string.format(L['Value']..': %s/%s (%d%%)', CommaValue(value-minRep), CommaValue(maxRep-minRep), (value-minRep)/(maxRep-minRep)*100))
				GameTooltip:AddLine(string.format(L['VALUE_LEFT']..': %s', CommaValue(maxRep-value)))
			end
		
			local addSpance = false 

			for k,v in pairs(BFAReps) do
				if (C_Reputation.IsFactionParagon(v)) then

					if not addSpance then
						GameTooltip:AddLine(" ")
					end 
					addSpance = true 

					if not BFARepsNames[v] then
						for factionIndex = 1, GetNumFactions() do
							local name, description, standingID, barMin, barMax, barValue, atWarWith, canToggleAtWar, isHeader, isCollapsed, 
								hasRep, isWatched, isChild, factionID, hasBonusRepGain, canBeLFGBonus = GetFactionInfo(factionIndex);
						
							if ( factionID == v ) then
						
								BFARepsNames[v] = name
								break
							end
						end
					end
					
					local currentValue, threshold, rewardQuestID, hasRewardPending = C_Reputation.GetFactionParagonInfo(v);
					local minRep, maxRep, value = 0, threshold, mod(currentValue, threshold);		
					local color = ''
					
					if ( hasRewardPending ) then
						value = maxRep
						color = '|cFF00FF00'
					end
					
					GameTooltip:AddLine(string.format(color..BFARepsNames[v]..': %s/%s (%d%%)', CommaValue(value-minRep), CommaValue(maxRep-minRep), (value-minRep)/(maxRep-minRep)*100))
				end
			end
	
		end 

		GameTooltip:Show()
	end)
	mouseFrame:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)
	
	if ( not E.isClassic ) then
		local paragonHeader = true
		local paragonText = ''
		for factionIndex = 1, GetNumFactions() do
				local name, description, standingId, bottomValue, topValue, earnedValue, atWarWith, canToggleAtWar, isHeader, isCollapsed, hasRep, isWatched, isChild, factionID = GetFactionInfo(factionIndex)
				
				if hasRep or not isHeader and C_Reputation.IsFactionParagon(factionID) then

				local currentValue, threshold, rewardQuestID, hasRewardPending = C_Reputation.GetFactionParagonInfo(factionID);

				if hasRewardPending then
					if paragonHeader then
						paragonText = ''
					end
					
					paragonText = paragonText..'  '..name
				--	print("Faction: " .. name .. " - " .. earnedValue, hasRewardPending)   
				else         

				end     
			end
		end

		paragonReputationText:SetText(paragonText)
	end
end

-- Event Stuff -----------
--------------------------
local frame = CreateFrame("Frame",nil,UIParent)
--Event handling
frame:RegisterEvent("PLAYER_LEVEL_UP")
frame:RegisterEvent("PLAYER_XP_UPDATE")
frame:RegisterEvent("UPDATE_EXHAUSTION")
frame:RegisterEvent("CHAT_MSG_COMBAT_FACTION_CHANGE")
frame:RegisterEvent("UPDATE_FACTION")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")

if ( not E.isClassic ) then 
	frame:RegisterEvent("ARTIFACT_XP_UPDATE")
	frame:RegisterEvent("ARTIFACT_UPDATE")
	frame:RegisterEvent("ARTIFACT_CLOSE")
	--frame:RegisterUnitEvent("UNIT_INVENTORY_CHANGED", 'player')
	frame:RegisterEvent("AZERITE_ITEM_EXPERIENCE_CHANGED")
	frame:RegisterEvent("HONOR_XP_UPDATE");		
	frame:RegisterEvent("HONOR_LEVEL_UPDATE");
end 

frame:RegisterEvent("PLAYER_UPDATE_RESTING");
frame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
	
frame:SetScript("OnEvent", function()
	updateStatus()
	C_Timer.After(0.1, updateStatus)
end)

function AleaUI.UpdateXPBars()
	AleaUI:Mover(backdrop, "xpbarFrame", 276, 10)
	updateStatus()
end

local function InitXPBar()
	AleaUI:Mover(backdrop, "xpbarFrame", 276, 10)

	updateStatus()
	
	E.GUI.args.general.args.xpbar = {
		name = L['Xp, honor, artifact and reputation bars'],
		order = 5,
		type = 'group',
		embend = true,
		args = {},
	}

	E.GUI.args.general.args.xpbar.args.minimize = {
		name = L['Minimize'],
		order = 1,
		type = 'toggle', 
		set = function() 
			E.db.xpbar.minimize = not E.db.xpbar.minimize
		
			updateStatus()
		end,
		get = function()
			return E.db.xpbar.minimize
		end,
	}
	
	E.GUI.args.general.args.xpbar.args.unlock = {
		name = L['Unlock'],
		order = 1.1,
		type = "execute",
		set = function(self, value)
			E:UnlockMover("xpbarFrame") 
		end,
		get = function(self)end
	}
	
	E.GUI.args.general.args.xpbar.args.EnableXP = {
		name = L['Enable xp bar'],
		order = 2,
		type = 'toggle',
		set = function()
			E.db.xpbar.enableXP = not E.db.xpbar.enableXP
		end,
		get = function()
			return E.db.xpbar.enableXP
		end,
	}
	
	E.GUI.args.general.args.xpbar.args.EnableRep = {
		name = L['Enable reputation bar'],
		order = 3,
		type = 'toggle',
		set = function()
			E.db.xpbar.enableRep = not E.db.xpbar.enableRep
			updateStatus()
		end,
		get = function()
			return E.db.xpbar.enableRep
		end,
	}
	
	E.GUI.args.general.args.xpbar.args.EnableHonor = {
		name = L['Enable honor bar'],
		order = 4,
		type = 'toggle',
		set = function()
			E.db.xpbar.enableHonor = not E.db.xpbar.enableHonor
			updateStatus()
		end,
		get = function()
			return E.db.xpbar.enableHonor
		end,
	}

	E.GUI.args.general.args.xpbar.args.EnableArtifact = {
		name = L['Enable artifact bar'],
		order = 5,
		type = 'toggle',
		set = function()
			E.db.xpbar.enableArtifact = not E.db.xpbar.enableArtifact
			updateStatus()
		end,
		get = function()
			return E.db.xpbar.enableArtifact
		end,
	}

end

AleaUI:OnInit(InitXPBar)