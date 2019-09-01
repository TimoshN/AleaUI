

local hooksecurefunc, select, UnitBuff, UnitDebuff, UnitAura, UnitGUID, GetGlyphSocketInfo, tonumber, strfind =
      hooksecurefunc, select, UnitBuff, UnitDebuff, UnitAura, UnitGUID, GetGlyphSocketInfo, tonumber, strfind

local UnitIsTappedByAllThreatList = UnitIsTappedByAllThreatList or function() return false end
local UnitIsTapped = UnitIsTapped or UnitIsTappedByAllThreatList
local UnitIsTappedByPlayer = UnitIsTappedByPlayer or UnitIsTappedByAllThreatList

local E = AleaUI
local L = E.L

local UF = E:Module("UnitFrames")
local IS = E:Module("ItemStore")
local Skins = E:Module("Skins")

local formatstring = E.ShortValue

local types = {
    spell       = "|cFFCA3C3CID:|r",
    item        = "|cFFCA3C3CID:|r",
    glyph       = "|cFFCA3C3CID:|r",
    unit        = "|cFFCA3C3CID:|r",
    quest       = "|cFFCA3C3CID:|r",
    talent      = "|cFFCA3C3CID:|r",
    achievement = "|cFFCA3C3CID:|r",
    ability     = "|cFFCA3C3CID:|r"
}

local function addLine(tooltip, id, type)
    local found = false
    for i = 1,15 do
        local frame = _G[tooltip:GetName() .. "TextLeft" .. i]
        local text
        if frame then text = frame:GetText() end
        if text and text == type then found = true break end
    end

    if not found then
        tooltip:AddDoubleLine(type, "|cffffffff" .. id)
        tooltip:Show()
    end
end

-- All types, primarily for linked tooltips
local function onSetHyperlink(self, link)
    local type, id = string.match(link,"^(%a+):(%d+)")
    if not type or not id then return end
    if type == "spell" or type == "enchant" or type == "trade" then
        addLine(self, id, types.spell)
    elseif type == "glyph" then
        addLine(self, id, types.glyph)
    elseif type == "talent" then
        addLine(self, id, types.talent)
    elseif type == "quest" then
        addLine(self, id, types.quest)
    elseif type == "achievement" then
        addLine(self, id, types.achievement)
    elseif type == "item" then
        addLine(self, id, types.item)
    end
end

local function OnSetUnitAura(self, ...)
	local _, _, _, _, _, _, caster, _, _, id, canApplyAura, isBossDebuff, isCastByPlayer, val1, val2, val3= UnitAura(...)
	if id then
		if caster then
			local name = UnitName(caster)
			local _, class = UnitClass(caster)
			local color = RAID_CLASS_COLORS[class]
			self:AddDoubleLine(("|cFFCA3C3C%s|r %d"):format(ID, id), format("|c%s%s|r", color.colorStr, name))
		else
			self:AddLine(("|cFFCA3C3C%s|r %d"):format(ID, id))
		end
		if E.db.unitframes.mouseEvents and self:GetOwner() and self:GetOwner().aleaUI then
			self:AddLine("    ")
			self:AddLine(("|cFFCA3C3C%s|r %s"):format(L["Right-click"], L[" to blacklist this aura"]))
			self:AddLine(("|cFFCA3C3C%s|r %s"):format(L["Shift + right-click"], L[" to whitelist this aura"]))
		end		
		self:Show()
	end	
end

local function OnSetUnitBuff(self, ...)
	local _, _, _, _, _, _, _, caster, _, _, id, canApplyAura, isBossDebuff, isCastByPlayer, val1, val2, val3= UnitBuff(...)
	if id then
		if caster then
			local name = UnitName(caster)
			local _, class = UnitClass(caster)
			local color = RAID_CLASS_COLORS[class]
			self:AddDoubleLine(("|cFFCA3C3C%s|r %d"):format(ID, id), format("|c%s%s|r", color.colorStr, name))
		else
			self:AddLine(("|cFFCA3C3C%s|r %d"):format(ID, id))
		end
		if E.db.unitframes.mouseEvents and self:GetOwner().aleaUI then
			self:AddLine("    ")
			self:AddLine(("|cFFCA3C3C%s|r %s"):format(L["Right-click"], L[" to blacklist this aura"]))
			self:AddLine(("|cFFCA3C3C%s|r %s"):format(L["Shift + right-click"], L[" to whitelist this aura"]))
		end
		self:Show()
	end	
end

local function OnSetUnitDebuff(self, ...)
	local _, _, _, _, _, _, _, caster, _, _, id, canApplyAura, isBossDebuff, isCastByPlayer, val1, val2, val3= UnitDebuff(...)
	if id then
		if caster then
			local name = UnitName(caster)
			local _, class = UnitClass(caster)
			local color = RAID_CLASS_COLORS[class]
			self:AddDoubleLine(("|cFFCA3C3C%s|r %d"):format(ID, id), format("|c%s%s|r", color.colorStr, name))
		else
			self:AddLine(("|cFFCA3C3C%s|r %d"):format(ID, id))
		end
		
		if E.db.unitframes.mouseEvents and self:GetOwner().aleaUI then
			self:AddLine("    ")
			self:AddLine(("|cFFCA3C3C%s|r %s"):format(L["Right-click"], L[" to blacklist this aura"]))
			self:AddLine(("|cFFCA3C3C%s|r %s"):format(L["Shift + right-click"], L[" to whitelist this aura"]))
		end			
		self:Show()
	end	
end

hooksecurefunc(GameTooltip, "SetUnitBuff", OnSetUnitBuff)
hooksecurefunc(GameTooltip, "SetUnitDebuff", OnSetUnitDebuff)
hooksecurefunc(GameTooltip, "SetUnitAura", OnSetUnitAura)

GameTooltip:HookScript("OnTooltipSetSpell", function(self)
    local id = select(2, self:GetSpell())
    if id then addLine(self, id, types.spell) end
end)

-- NPCs
GameTooltip:HookScript("OnTooltipSetUnit", function(self)
    if C_PetBattles and C_PetBattles.IsInBattle() then return end
	
    local unit = select(2, self:GetUnit())
    if unit then
        local guid = UnitGUID(unit) or ""
		local id   = tonumber(guid:match("-(%d+)-%x+$"), 10)
        if id and guid:match("%a+") ~= "Player" then addLine(GameTooltip, id, types.unit) end
    end
end)

GameTooltip:HookScript("OnShow", function(self)
	if InCombatLockdown() and E.db.disableTooltipInCombat then
		self:Hide()
	end
end)
	
-- Items
hooksecurefunc("SetItemRef", function(link, ...)
    local id = tonumber(link:match("spell:(%d+)"))
    if id then addLine(ItemRefTooltip, id, types.item) end
end)

local match = string.match
local strsplit = strsplit

local function GameTooltip_OnTooltipSetItem(tooltip)
	local _, link = tooltip:GetItem()
	if not link then return; end
	
	local itemString = match(link, "|Hitem[%-?%d:]+")

	if itemString then
		local _, itemId = strsplit(":", itemString)

		--From idTip: http://www.wowinterface.com/downloads/info17033-idTip.html
		if itemId == "0" and TradeSkillFrame ~= nil and TradeSkillFrame:IsVisible() then
			if (GetMouseFocus():GetName()) == "TradeSkillSkillIcon" then
				itemId = GetTradeSkillItemLink(TradeSkillFrame.selectedSkill):match("item:(%d+):") or nil
			else
				for i = 1, 8 do
					if (GetMouseFocus():GetName()) == "TradeSkillReagent"..i then
						itemId = GetTradeSkillReagentItemLink(TradeSkillFrame.selectedSkill, i):match("item:(%d+):") or nil
						break
					end
				end
			end
		end
	end
end

GameTooltip:HookScript("OnTooltipSetItem", GameTooltip_OnTooltipSetItem)

local function attachItemTooltip(self)
    local name, link = self:GetItem()
	if not link then return; end

	local recipeID = TradeSkillFrame and TradeSkillFrame.RecipeList:GetSelectedRecipeID() or false
	
	if recipeID then	
		local numReagents = C_TradeSkillUI.GetRecipeNumReagents(recipeID)
		for reagentId = 1, numReagents do
		
			if GetMouseFocus() == TradeSkillFrame.DetailsFrame.Contents.Reagents[reagentId] then
				local reagentName = C_TradeSkillUI.GetRecipeReagentInfo(recipeID, reagentId)
				local _, reagentLink = GetItemInfo(reagentName)
				
				if reagentLink then
					link = reagentLink
				end
			end
		end
	end
	
	local itemId = GetItemInfoFromHyperlink(link)
	
	itemId = tonumber(itemId or '')
	
	if itemId and itemId > 0 then 
	--	print('T', _G[self:GetName()..'TextLeft1']:GetText())

		local name2 = _G[self:GetName()..'TextLeft1']:GetText()
		local texture = select(10, GetItemInfo(link)) 
		
		if not texture then
			texture = select(5, GetItemInfoInstant(link))
		end
		
		if texture and ( name2 and not string.find(name2, '|T') or not name2 ) then
			_G[self:GetName()..'TextLeft1']:SetText(format("\124T%s:%d:%d:0:0:64:64:4:60:4:60\124t %s", texture, 20, 20, (name2 or name)))	
		end
		
		addLine(self, itemId, types.item) 		
		if IS and IS.SearchItem then IS:SearchItem(itemId, self) end
	end
end

--GameTooltip:SetRecipeReagentItem(self.selectedRecipeID, reagentButton.reagentIndex);


GameTooltip:HookScript("OnTooltipSetItem", attachItemTooltip)
ItemRefTooltip:HookScript("OnTooltipSetItem", attachItemTooltip)
ItemRefShoppingTooltip1:HookScript("OnTooltipSetItem", attachItemTooltip)
ItemRefShoppingTooltip2:HookScript("OnTooltipSetItem", attachItemTooltip)
ShoppingTooltip1:HookScript("OnTooltipSetItem", attachItemTooltip)
ShoppingTooltip2:HookScript("OnTooltipSetItem", attachItemTooltip)

-- Achievement Frame Tooltips
local f = CreateFrame("frame")
f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", function(_, _, what)
    if what == "Blizzard_AchievementUI" then
        for i,button in ipairs(AchievementFrameAchievementsContainer.buttons) do
            button:HookScript("OnEnter", function()
                GameTooltip:SetOwner(button, "ANCHOR_NONE")
                GameTooltip:SetPoint("TOPLEFT", button, "TOPRIGHT", 0, 0)
                addLine(GameTooltip, button.id, types.achievement)
                GameTooltip:Show()
            end)
            button:HookScript("OnLeave", function()
                GameTooltip:Hide()
            end)
        end
    end
end)

-- Pet battle buttons
if ( PetBattleAbilityButton_OnEnter ) then
	hooksecurefunc("PetBattleAbilityButton_OnEnter", function(self)
		local petIndex = C_PetBattles.GetActivePet(LE_BATTLE_PET_ALLY);
		if ( self:GetEffectiveAlpha() > 0 ) then
			local id = select(1, C_PetBattles.GetAbilityInfo(LE_BATTLE_PET_ALLY, petIndex, self:GetID()));
			if id then
				local oldText = PetBattlePrimaryAbilityTooltip.Description:GetText(id);
				PetBattlePrimaryAbilityTooltip.Description:SetText(oldText .. "\r\r" .. types.ability .. "|cffffffff " .. id .. "|r")
			end
		end
	end)
end 

-- Pet battle auras
if ( PetBattleAura_OnEnter ) then 
	hooksecurefunc("PetBattleAura_OnEnter", function(self)
		local parent = self:GetParent();
		local id = select(1, C_PetBattles.GetAuraInfo(parent.petOwner, parent.petIndex, self.auraIndex))
		if id then
			local oldText = PetBattlePrimaryAbilityTooltip.Description:GetText(id);
			PetBattlePrimaryAbilityTooltip.Description:SetText(oldText .. "\r\r" .. types.ability .. "|cffffffff " .. id .. "|r")
		end
	end)
end 
--[[
local tt_ = CreateFrame("Frame")
tt_:RegisterEvent("MODIFIER_STATE_CHANGED")
tt_:SetScript("OnEvent", function(self, event, key)
	if((key == "LSHIFT" or key == "RSHIFT") and UnitExists("mouseover")) then
		GameTooltip:SetUnit('mouseover')
	end
end)
]]
--GameTooltip:Show()
--GameTooltip:Hide()

local hookedFrames = {}


hooksecurefunc("HealthBar_OnValueChanged", function(self, value)
	
	if ( not hookedFrames[self] ) then
		return
	end

	local mi, ma = self:GetMinMaxValues()

	if ma <= 1 then
		self._stfs:SetText(format('%.1f%%', value*100))
	else
		self._stfs:SetText(formatstring(nil, value)..'/'..formatstring(nil, ma))
	end
	
	self:SetStatusBarColor(self._color_r or 0.6, self._color_g or 0.6, self._color_b or 0.6)
end)

function Skins:StyleTooltipsCustom(frame)
	local f = _G[frame] or frame
	if not f or type(f) == 'string' then 
		error('Unknown '..tostring(frame or 'nil'))
		return 
	end
	
	if f.tooltipStyled then
		return
	end

	
	f.tooltipStyled = true
	
	local name = f:GetName()

	local border = CreateFrame("Frame", nil, f)
	border:SetAllPoints()
	border:SetFrameLevel(f:GetFrameLevel()-1)
	f:SetBackdrop(nil) --{edgeSize = 0})
	f:SetBackdropColor(0.1,0.1,0.1,0)
	f:SetBackdropBorderColor(0,0,0,0)
	
	--[==[
	f.SetBackdropBorderColor = function(self)
		print(self:GetName())
	end
	]==]
	
	hooksecurefunc(f, 'SetBackdrop', function(self, a)
		if ( a ~= nil ) then
			self:SetBackdrop(nil)
		end
	end)
	
	hooksecurefunc(f, 'SetBackdropBorderColor', function(self,r,g,b,a)
		if ( r==1 and g==1 and b==1 ) then
			self:SetBackdropBorderColor(0,0,0,0)
		end
	end)
	
	AleaUI:CreateBackdrop(border, border, {0,0,0,1}, {0.1,0.1,0.1,0.8})

	if f.BorderTopLeft then	f.BorderTopLeft:SetAlpha(0) end
	if f.BorderTopRight then	f.BorderTopRight:SetAlpha(0) end
	if f.BorderBottomRight then	f.BorderBottomRight:SetAlpha(0) end
	if f.BorderBottomLeft then	f.BorderBottomLeft:SetAlpha(0) end
	if f.BorderTop then	f.BorderTop:SetAlpha(0) end
	if f.BorderRight then	f.BorderRight:SetAlpha(0) end
	if f.BorderBottom then	f.BorderBottom:SetAlpha(0) end
	if f.BorderLeft then	f.BorderLeft:SetAlpha(0) end
	if f.Background then	f.Background:SetAlpha(0) end
	if f.BackdropFrame then
		
		border:ClearAllPoints()
		border:SetPoint('TOPLEFT', f, 'TOPLEFT', 0, 0)
		border:SetPoint('BOTTOMRIGHT',f.BackdropFrame, 'BOTTOMRIGHT', 0, 0)
		
		f.BackdropFrame:SetAlpha(0) 
	end
	
	if _G[name.."StatusBar"] then
		AleaUI:CreateBackdrop(_G[name.."StatusBar"], nil, {0,0,0,1}, {0.1,0.1,0.1,0})
		
		_G[name.."StatusBar"]:SetPoint("TOPLEFT", f, "BOTTOMLEFT", 0, -3)
		_G[name.."StatusBar"]:SetPoint("TOPRIGHT", f, "BOTTOMRIGHT", 0, -3)
		_G[name.."StatusBar"]:SetStatusBarTexture("Interface\\AddOns\\AleaUI\\media\\Minimalist")
		
		local stfs = _G[name.."StatusBar"]:CreateFontString(nil, "ARTWORK", "GameFontNormal", 1)
		stfs:SetFont(AleaUI.media.default_font2, 12, "OUTLINE")
		stfs:SetTextColor(1,1,1)
		stfs:SetPoint("CENTER", _G[name.."StatusBar"], "CENTER")
		
		_G[name.."StatusBar"]._stfs = stfs

		hookedFrames[ _G[name.."StatusBar"] ] = true

		--[==[
			GameTooltipStatusBar._color_r = 0.6
		GameTooltipStatusBar._color_g = 0.6
		GameTooltipStatusBar._color_b = 0.6
		
		GameTooltipStatusBar:SetStatusBarColor(0.6, 0.6, 0.6)
		
		]==]
	end		
end

for i, frame in ipairs({ 
	--'WorldMapTooltip', 
	"GameTooltip", 
	"ItemRefTooltip", 
	"ItemRefShoppingTooltip1", 
	"ItemRefShoppingTooltip2", 
	"ShoppingTooltip1", 
	"ShoppingTooltip2", 
	'GarrisonFollowerTooltip', 
	'GarrisonShipyardFollowerTooltip'}) do
	
	print(pcall(Skins.StyleTooltipsCustom, Skins, frame) )	
end

hooksecurefunc('GameTooltip_ShowCompareItem', function(self, anchorFrame)
	if not self then return end
	
	local shoppingTooltip1, shoppingTooltip2 = unpack(self.shoppingTooltips);
	
	Skins:StyleTooltipsCustom(shoppingTooltip1)
	Skins:StyleTooltipsCustom(shoppingTooltip2)
end)

do
	
	local myparent = CreateFrame("Frame", "AleaUIGameToolTipMopver", AleaUI.UIParent)
	myparent:SetSize(50, 20)

	local function MoveTT_OnShow(tooltip, parent)
		local p1, p2, p3, p4, p5, p6 = E:GetRelativePoint(myparent)
	
		tooltip:SetOwner(myparent, "ANCHOR_NONE")
		tooltip:ClearAllPoints()
		tooltip:SetPoint(p3..p4, myparent, p3..p4, 0, 0)		
	end

	AleaUI:OnInit2(function()
		AleaUI:Mover(myparent, "GameTooltipMover")
		hooksecurefunc("GameTooltip_SetDefaultAnchor", MoveTT_OnShow)
	end)
end

do
	local borders_ = { 'BorderTopLeft', 'BorderTopRight', 'BorderBottomRight', 'BorderBottomLeft', 'BorderTop', 'BorderRight', 'BorderBottom', 'BorderLeft', 'Background' }
	local function SkinTooltipBorder(name)	
		if not _G[name] then return end	
		local border = CreateFrame("Frame", nil, _G[name])
		border:SetAllPoints()
		border:SetFrameLevel(_G[name]:GetFrameLevel()-1)
		AleaUI:CreateBackdrop(border, border, {0,0,0,1}, {0.1,0.1,0.1,0.8})		
		for i, namePart in ipairs(borders_) do		
			if _G[name][namePart] then	
				_G[name][namePart]:SetTexture('')
				_G[name][namePart]:SetAlpha(0)
			end
		end
	end


	SkinTooltipBorder('QueueStatusFrame')

end

local function RemoveTrashLines(tt)
	for i=3, tt:NumLines() do
		local tiptext = _G["GameTooltipTextLeft"..i]
		local linetext = tiptext:GetText()

		if(linetext:find(PVP) or linetext:find(FACTION_ALLIANCE) or linetext:find(FACTION_HORDE)) then
			tiptext:SetText(nil)
			tiptext:Hide()
		end
	end
end

local function GetLevelLine(tt, offset)
	for i=offset, tt:NumLines() do
		local tipLine = _G["GameTooltipTextLeft"..i]
		local tipText = tipLine:GetText() and tipLine:GetText():lower()
		if tipText and ( tipText:find('уровня') or tipText:find(LEVEL:lower()) ) then
			return tipLine
		end
	end
end

local classification = {
	worldboss = format("|cffAF5050 %s|r", BOSS),
	rareelite = format("|cffAF5050+ %s|r", ITEM_QUALITY3_DESC),
	elite = "|cffAF5050+|r",
	rare = format("|cffAF5050 %s|r", ITEM_QUALITY3_DESC)
}

local function Custom_OnTooltipSetUnit(tt)
	local unit = select(2, tt:GetUnit())

	if(not unit) then
		local GMF = GetMouseFocus()
		if(GMF and GMF:GetAttribute("unit")) then
			unit = GMF:GetAttribute("unit")
		end
		if(not unit or not UnitExists(unit)) then
			return
		end
	end

	RemoveTrashLines(tt) --keep an eye on this may be buggy
	local level = UnitLevel(unit)
	local isShiftKeyDown = IsShiftKeyDown()

	local color
	if(UnitIsPlayer(unit)) then
		local localeClass, class = UnitClass(unit)
		local name, realm = UnitName(unit)
		local guildName, guildRankName, _, guildRealm = GetGuildInfo(unit)
		local pvpName = UnitPVPName(unit)
		local relationship = UnitRealmRelationship(unit);
		if not localeClass or not class then return; end
		color = RAID_CLASS_COLORS[class]

		if false and (pvpName) then
			name = pvpName
		end

		if(realm and realm ~= "") then
			if(isShiftKeyDown) then
				name = name.."-"..realm
			elseif(relationship == LE_REALM_RELATION_COALESCED) then
				name = name..FOREIGN_SERVER_LABEL
			elseif(relationship == LE_REALM_RELATION_VIRTUAL) then
				name = name..INTERACTIVE_SERVER_LABEL
			end
		end
		
		local status = ''
		
		if(UnitIsAFK(unit)) then
			status = '[|cffff0000AFK|r]'
		elseif(UnitIsDND(unit)) then
			status = '[|cffff0000DND|r]'
		end

		GameTooltipTextLeft1:SetFormattedText("|c%s%s|r%s", color.colorStr, name, status)

		local lineOffset = 2
		if(guildName) then
			if(guildRealm and isShiftKeyDown) then
				guildName = guildName.."-"..guildRealm
			end

			if(true) then
				GameTooltipTextLeft2:SetText(("<|cff00ff10%s|r> [|cff00ff10%s|r]"):format(guildName, guildRankName))
			else
				GameTooltipTextLeft2:SetText(("<|cff00ff10%s|r>"):format(guildName))
			end
			lineOffset = 3
		end


		local levelLine = GetLevelLine(tt, lineOffset)
		if(levelLine) then
			local diffColor = GetQuestDifficultyColor(level)
			local race, englishRace = UnitRace(unit)
			local _, factionGroup = UnitFactionGroup(unit)
			if(factionGroup and englishRace == "Pandaren") then
				race = factionGroup.." "..race
			end
			levelLine:SetFormattedText("|cff%02x%02x%02x%s|r %s |c%s%s|r", diffColor.r * 255, diffColor.g * 255, diffColor.b * 255, level > 0 and level or "??", race or '', color.colorStr, localeClass)
		end
	else
		if(UnitIsTapped(unit) and not UnitIsTappedByPlayer(unit)) then
			color = TAPPED_COLOR
		else
			color = FACTION_BAR_COLORS[UnitReaction(unit, "player")]
		end

		local levelLine = GetLevelLine(tt, 2)
		if(levelLine) then
			local isPetWild, isPetCompanion = UnitIsWildBattlePet and UnitIsWildBattlePet(unit), UnitIsBattlePetCompanion and UnitIsBattlePetCompanion(unit);
			local creatureClassification = UnitClassification(unit)
			local creatureType = UnitCreatureType(unit)
			local pvpFlag = ""
			local diffColor
			if(isPetWild or isPetCompanion) then
				level = UnitBattlePetLevel(unit)

				local teamLevel = C_PetJournal.GetPetTeamAverageLevel();
				if(teamLevel) then
					diffColor = GetRelativeDifficultyColor(teamLevel, level);
				else
					diffColor = GetQuestDifficultyColor(level)
				end
			else
				diffColor = GetQuestDifficultyColor(level)
			end

			if(UnitIsPVP(unit)) then
				pvpFlag = format(" (%s)", PVP)
			end

			levelLine:SetFormattedText("|cff%02x%02x%02x%s|r%s %s%s", diffColor.r * 255, diffColor.g * 255, diffColor.b * 255, level > 0 and level or "??", classification[creatureClassification] or "", creatureType or "", pvpFlag)
		end
	end

	if(color) then
		GameTooltipStatusBar._color_r = color.r
		GameTooltipStatusBar._color_g = color.g
		GameTooltipStatusBar._color_b = color.b
		
		GameTooltipStatusBar:SetStatusBarColor(color.r, color.g, color.b)
	else
		GameTooltipStatusBar._color_r = 0.6
		GameTooltipStatusBar._color_g = 0.6
		GameTooltipStatusBar._color_b = 0.6
		
		GameTooltipStatusBar:SetStatusBarColor(0.6, 0.6, 0.6)
	end

end

GameTooltip:HookScript("OnTooltipSetUnit", Custom_OnTooltipSetUnit)