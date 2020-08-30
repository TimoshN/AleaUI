local addonName, E = ...
local Skins = E:Module("Skins")

local _G = _G

local default_background_color = Skins.default_background_color
local default_border_color = Skins.default_border_color
local default_font = Skins.default_font
local default_texture = Skins.default_texture

local default_button_background = Skins.default_button_background
local default_button_border 	= Skins.default_button_border
local default_border_color_dark = Skins.default_border_color_dark

local ITEM_LEVEL_PATTERN = ITEM_LEVEL:gsub('%%d', '(%%d+)')
local ITEM_UPGRADE_TOOLTIP_FORMAT_PATTERN = ITEM_UPGRADE_TOOLTIP_FORMAT:gsub('%%d', '(%%d+)')

local varName = 'inspect'
E.default_settings.skins[varName] = true

local function InitInspect()
	if not E.db.skins.enableAll then return end
	if not E.db.skins[varName] then return end

	local Updater

	local countToTotalIlvl = {
		[1] = true,
		[2] = true,
		[3] = true,
		[15] = true,
		[5] = true,
		[9] = true,
		
		[10] = true,
		[6] = true,
		[7] = true,
		[8] = true,
		[11] = true,
		[12] = true,
		[13] = true,
		[14] = true,
		
		[16] = true,
		[18] = true,
		
		[17] = false, -- offhand
	}
	local buttonList = {
		'InspectMainHandSlot', 'MainHand', true, 			--1
		'InspectSecondaryHandSlot', 'SecondaryHand', true, 	--2
		'InspectHeadSlot', 'Head', true, 					--3
		'InspectNeckSlot', 'Neck', true, 					--4
		'InspectShoulderSlot', 'Shoulder', true, 			--5
		'InspectBackSlot', 'Chest', true,  					--6
		'InspectChestSlot', 'Chest', true, 					--7
		'InspectShirtSlot', 'Shirt', false, 				--8
		'InspectTabardSlot', 'Tabard', false, 				--9
		'InspectWristSlot', 'Wrists', true,					--10
		'InspectHandsSlot', 'Hands', true, 					--11
		'InspectWaistSlot', 'Waist', true, 					--12
		'InspectLegsSlot', 'Legs', true, 					--13
		'InspectFeetSlot', 'Feet', true, 					--14
		'InspectFinger0Slot', 'Finger', true, 				--15
		'InspectFinger1Slot', 'Finger', true, 				--16
		'InspectTrinket0Slot', 'Trinket', true, 			--17
		'InspectTrinket1Slot', 'Trinket', true, 			--18
	}
	
	local Artifacts = {
		[127829] = 577, -- Havoc DH
		[128832] = 581, -- Vengeance DH

		[128402] = 250, -- Blood DK
		[128292] = 251, -- Frost DK
		[128403] = 252, -- Unholy DK

		[128858] = 102, -- Balance Druid
		[128860] = 103, -- Feral Druid
		[128821] = 104, -- Guardian Druid
		[128306] = 105, -- Restoration Druid

		[128861] = 253, -- Beast Mastery Hunter
		[128826] = 254, -- Marksmanship Hunter
		[128808] = 255, -- Survival Hunter

		[127857] = 62, -- Arcane Mage
		[128820] = 63, -- Fire Mage
		[128862] = 64, -- Frost Mage

		[128938] = 268, -- Brewmaster Monk
		[128937] = 270, -- Mistweaver Monk
		[128940] = 269, -- Windwalker Monk

		[128823] = 65, -- Holy Paladin
		[128866] = 66, -- Protection Paladin
		[120978] = 70, -- Retribution Paladin

		[128868] = 256, -- Discipline Priest
		[128825] = 257, -- Holy Priest
		[128827] = 258, -- Shadow Priest

		[128870] = 259, -- Assassination Rogue
		[128872] = 260, -- Outlaw Rogue
		[128476] = 261, -- Subtlety Rogue

		[128935] = 262, -- Elemental Shaman
		[128819] = 263, -- Enhancement Shaman
		[128911] = 264, -- Restoration Shaman

		[128942] = 265, -- Affliction Warlock
		[128943] = 266, -- Demonology Warlock
		[128941] = 267, -- Destruction Warlock

		[128910] = 71, -- Arms Warrior
		[128908] = 72, -- Fury Warrior
		[128289] = 73, -- Protection Warrior	
	}

	local function GetItemID(link)		
		if link then			
			return tonumber(link:match("item:(%d+):")) or false
		end
		
		return false
	end
	
	local function GetTotalItemLvl(self, elapsed)
		self.elapsed = ( self.elapsed or 0 ) + elapsed
		if (self.elapsed) < 0.5 then return end
		self.elapsed = 0
		
		local unit = InspectFrame.unit
		local total = 0
		local hide = true
		
		self.attept = self.attept + 1
		
		local itemLevelList = {}
		
		for id, enabled in pairs(countToTotalIlvl) do
			
			local itemLevel, itemUpgrade, itemUpgradeTotal = E.GetItemItemLevel( unit, id )
			
			if itemLevel then			
				itemLevelList[id] = itemLevel
			
				local buttonList_id2 = 1
				
				for i = 1, #buttonList/3 do
		
					if buttonList[buttonList_id2+2] and _G[buttonList[buttonList_id2]]:GetID() == id then			
						_G[buttonList[buttonList_id2]].ilvl:SetText( format( ( itemUpgrade and '%d\n%d/%d' or '%d' ), itemLevel, itemUpgrade, itemUpgradeTotal))	
					end
					
					buttonList_id2 = buttonList_id2 + 3
				end
			else
				hide = false
			end
		end
		
		if self.attept == 5 then
			self:Hide()
		end
		
		local searchForArtifactID 
	
		if GetItemID(GetInventoryItemLink(unit, 16)) and Artifacts[GetItemID(GetInventoryItemLink(unit, 16)) or 0] then
			searchForArtifactID = 16 --GetInventoryItemID(unit, 16)
		elseif GetItemID(GetInventoryItemLink(unit, 17)) and Artifacts[GetItemID(GetInventoryItemLink(unit, 17)) or 0] then
			searchForArtifactID = 17 --GetInventoryItemID(unit, 17)
		elseif GetItemID(GetInventoryItemLink(unit, 18)) and Artifacts[GetItemID(GetInventoryItemLink(unit, 18))or 0] then
			searchForArtifactID = 18 --GetInventoryItemID(unit, 18)
		end

		for id, enabled in pairs(countToTotalIlvl) do
			if itemLevelList[id] then			
				if id == 17 or id == 16 or id == 18 then
					if searchForArtifactID == id  then
						total = total + ( itemLevelList[id] or 0 )
					end					
				else
					total = total + itemLevelList[id]
				end
			end
		end 

		local relics = nil

		local relicItemLink = GetInventoryItemLink(unit, searchForArtifactID);
		
		if relicItemLink then
			local _, _, itemRarity = GetItemInfo(relicItemLink)
			if itemRarity == 6 then
			   relics = relicItemLink
			end		
		end
		
		if relics then
			local _, relicLink1 = GetItemGem(relics, 1)
			local _, relicLink2 = GetItemGem(relics, 2)
			local _, relicLink3 = GetItemGem(relics, 3)
			
		--	print(relicLink1 and relicLink1:gsub('|', '||'))
		--	print(relicLink2 and relicLink2:gsub('|', '||'))
		--	print(relicLink3 and relicLink3:gsub('|', '||'))
			
			if relicLink1 then
				InspectFrame.AleaUIRelicList[1].link = relicLink1
				InspectFrame.AleaUIRelicList[1]:Show()
				InspectFrame.AleaUIRelicList[1].icon:SetTexture((select(5, GetItemInfoInstant(relicLink1))))
			end
			if relicLink2 then
				InspectFrame.AleaUIRelicList[2].link = relicLink2
				InspectFrame.AleaUIRelicList[2]:Show()
				InspectFrame.AleaUIRelicList[2].icon:SetTexture((select(5, GetItemInfoInstant(relicLink2))))
			end
			if relicLink3 then
				InspectFrame.AleaUIRelicList[3].link = relicLink3
				InspectFrame.AleaUIRelicList[3]:Show()
				InspectFrame.AleaUIRelicList[3].icon:SetTexture((select(5, GetItemInfoInstant(relicLink3))))
			end
		end
		
		InspectFrame.tilvl:SetText('ILvL:'..ceil(total/15))
	end
	
	Updater = CreateFrame('Frame', nil, InspectFrame)
	Updater:SetScript('OnUpdate', GetTotalItemLvl)
	Updater:Hide()
	
	InspectFrame:HookScript('OnShow', function()
	
		local buttonList_id = 1
	
		for i=1, #buttonList/3 do
			if _G[buttonList[buttonList_id]].ilvl then			
				_G[buttonList[buttonList_id]].ilvl:SetText('')
			end		
			_G[buttonList[buttonList_id]]:SetUIBackdropBorderColor(0,0,0,1);
			buttonList_id = buttonList_id + 3
		end
		
		InspectFrame.tilvl:SetText('')
		
		for i=1, #InspectFrame.AleaUIRelicList do
			InspectFrame.AleaUIRelicList[i]:Hide()
			InspectFrame.AleaUIRelicList[i].link = nil
		end
		
		Updater.attept = 0
		Updater:Show()
	end)
	
	InspectFrame.tilvl = InspectPaperDollItemsFrame:CreateFontString(nil, "ARTWORK", "GameFontWhite")
	InspectFrame.tilvl:SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE")
	InspectFrame.tilvl:SetPoint("BOTTOMLEFT", InspectFrame, "BOTTOMLEFT", 3, 2)


	_G['InspectFrame']:StripTextures()
	_G['InspectFrameInset']:StripTextures()

	InspectModelFrameBorderBottom2:SetAlpha(0)
	
	
	InspectModelFrameBorderBottom:SetAlpha(0)
	InspectModelFrameBorderBottomRight:SetAlpha(0)
	InspectModelFrameBorderBottomLeft:SetAlpha(0)
	InspectModelFrameBorderRight:SetAlpha(0)
	InspectModelFrameBorderLeft:SetAlpha(0)
	InspectModelFrameBorderTop:SetAlpha(0)
	InspectModelFrameBorderTopRight:SetAlpha(0)
	InspectModelFrameBorderTopLeft:SetAlpha(0)
	
	Skins.ThemeBackdrop('InspectFrame')
	Skins.ThemeFrameRing('InspectFrame')
	
	for i=1, 4 do
		Skins.ThemeTab('InspectFrameTab'..i)
	end
	
	-- frame.items[i].ilvl:SetText( format( ( itemUpgrade and '%d\n%d/%d' or '%d' ), itemLevelFull, itemUpgrade, itemUpgradeTotal))	
	
	local buttonList_id = 1
	
	for i=1, #buttonList/3 do
		if buttonList[buttonList_id+2] then			
			_G[buttonList[buttonList_id]].ilvl = _G[buttonList[buttonList_id]]:CreateFontString(nil, "ARTWORK", "GameFontWhite")
			_G[buttonList[buttonList_id]].ilvl:SetFont(E.media.default_font2, 12, "OUTLINE")
			_G[buttonList[buttonList_id]].ilvl:SetPoint("BOTTOMRIGHT", _G[buttonList[buttonList_id]], "BOTTOMRIGHT")
		end		
		buttonList_id = buttonList_id + 3
	end
	
	local slots = {
		"HeadSlot",
		"NeckSlot",
		"ShoulderSlot",
		"BackSlot",
		"ChestSlot",
		"ShirtSlot",
		"TabardSlot",
		"WristSlot",
		"HandsSlot",
		"WaistSlot",
		"LegsSlot",
		"FeetSlot",
		"Finger0Slot",
		"Finger1Slot",
		"Trinket0Slot",
		"Trinket1Slot",
		"MainHandSlot",
		"SecondaryHandSlot",
	}
	for _, slot in pairs(slots) do
		local icon = _G["Inspect"..slot.."IconTexture"]
		slot = _G["Inspect"..slot]
		slot:StripTextures()
		slot:StyleButton(false)
	--	slot.ignoreTexture:SetTexture([[Interface\PaperDollInfoFrame\UI-GearManager-LeaveItem-Transparent]])
	--	slot:SetTemplate("Default", true)
		slot:SetFrameLevel(slot:GetFrameLevel() + 2)
		icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
		icon:SetInside()
		
		E:CreateBackdrop(slot, slot, default_border_color, default_background_color)
		slot:SetUIBorderDrawLayer('ARTWORK')

		hooksecurefunc(slot.IconBorder, 'SetVertexColor', function(self, r, g, b)
			self:GetParent():SetUIBackdropBorderColor(r, g, b)
			self:SetTexture("")
		end)
		hooksecurefunc(slot.IconBorder, 'Hide', function(self)
			self:GetParent():SetUIBackdropBorderColor(unpack(default_border_color))
		end)
		
	end

	InspectFrame.AleaUIRelicList = {}
	
	for i=1, 3 do
		local f = CreateFrame('Frame', nil, InspectPaperDollItemsFrame)
		f:SetSize(22, 22)
		f:SetPoint('BOTTOMRIGHT', InspectFrame, 'BOTTOMRIGHT',  - 108 + ( 24 * i ), 5)
		f:SetScript('OnEnter', function(self)
			if self.link then
				GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
				GameTooltip:SetHyperlink(self.link)
			else
				GameTooltip:Hide()
			end
		end)
		f:SetScript('OnLeave', function(self)
			GameTooltip:Hide()
		end)
		
		f.icon = f:CreateTexture()
		f.icon:SetAllPoints()
		f.icon:SetColorTexture(1, 1, 1, 1)
		f.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
		
		InspectFrame.AleaUIRelicList[i] = f
	end
	
	Skins.ThemeButton(InspectPaperDollFrame.ViewButton)
end

E:OnInit2(function()
	if InspectFrame_Show then
		C_Timer.After(2, InitInspect)
	else
		E:OnAddonLoad('Blizzard_InspectUI', InitInspect)
	end
end)