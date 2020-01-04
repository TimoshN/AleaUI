local Skins = AleaUI:Module("Skins")
local _G = _G

local default_background_color = Skins.default_background_color
local default_border_color = Skins.default_border_color
local default_font = Skins.default_font
local default_texture = Skins.default_texture

local default_button_background = Skins.default_button_background
local default_button_border 	= Skins.default_button_border
local default_border_color_dark = Skins.default_border_color_dark

local iconWidth = 32
local nameWidth = 200

local varName = 'lootframe'
AleaUI.default_settings.skins[varName] = true

local function Skin_LootFrame()
	if not AleaUI.db.skins.enableAll then return end
	if not AleaUI.db.skins[varName] then return end

	_G["LootFrame"]:StripTextures()	
	
	LootFramePortraitOverlay:Hide()

	_G["LootFrameInset"]:StripTextures()

	local artwork = CreateFrame('Frame', nil, _G["LootFrame"])
	artwork:SetSize(1,1)
	artwork:SetPoint('TOPLEFT', 0,-57)
	artwork:SetPoint('BOTTOMRIGHT', 0,0)
	AleaUI:CreateBackdrop(_G["LootFrame"], artwork,{0, 0, 0, 1}, {0, 0, 0, 0.8})

	for i=1, LootFrame:GetNumRegions() do
		local region = select(i, LootFrame:GetRegions());
		if(region:GetObjectType() == "FontString") then
			if(region:GetText() == ITEMS) then
				LootFrame.Title = region
			end
		end
	end

	LootFrame.Title:SetFont(default_font, 14, 'OUTLINE')
	LootFrame.Title:ClearAllPoints()
	LootFrame.Title:SetPoint("TOPLEFT", LootFrame, "TOPLEFT", 5, -40)
	LootFrame.Title:SetJustifyH("LEFT")
	LootFrame.Title:SetTextColor(1,1,1)


	LootFrameCloseButton:ClearAllPoints()
	LootFrameCloseButton:SetPoint("TOPRIGHT", LootFrame, "TOPRIGHT", 0, -30)

	LootFrameNext:SetFont(default_font, Skins.default_font_size, 'OUTLINE')
	LootFramePrev:SetFont(default_font, Skins.default_font_size, 'OUTLINE')

	local button = CreateFrame("Button", nil, LootFrame)	
	button:SetSize(20, 20)
	button:SetPoint("RIGHT", LootFrameCloseButton, "LEFT", -3, 0)
	button:SetScript("OnClick", function(self)
		
		local ind = 0
		
		for slot=1, LootFrame.numLootItems do
			local texture, item, quantity, currencyID, quality, locked, isQuestItem, questId, isActive = GetLootSlotInfo(slot);		

			if item then
				ind = ind + 1
				local sName, sLink, iRarity, iLevel, iMinLevel, sType, sSubType, iStackCount = GetItemInfo(item);
			
				if not sName then
					AleaUI.Message("#"..ind..". "..item.. ( iLevel and "(ilvl:"..iLevel..")" or ''), "PRINT")
				elseif sLink then
					AleaUI.Message("#"..ind..". "..sLink.. ( iLevel and "(ilvl:"..iLevel..")" or ''), "PRINT")
				end
			end
		end
	end)

	button.tx = button:CreateTexture(nil, "OVERLAY",1)
	button.tx:SetTexture("Interface\\Common\\VoiceChat-Speaker")
	button.tx:SetPoint("CENTER", button, "CENTER", 0, 0)
	button.tx:SetSize(16, 16)

	button.txon = button:CreateTexture(nil, "OVERLAY",1)
	button.txon:SetTexture("Interface\\Common\\VoiceChat-On")
	button.txon:SetPoint("CENTER", button, "CENTER", 0, 0)
	button.txon:SetSize(16, 16)

	button:SetScript("OnMouseDown", function(self)
		self.txon:SetPoint("CENTER", self, "CENTER", 1, -1)
		self.tx:SetPoint("CENTER", self, "CENTER", 1, -1)
	end)

	button:SetScript("OnMouseUp", function(self)
		self.txon:SetPoint("CENTER", self, "CENTER", 0, 0)
		self.tx:SetPoint("CENTER", self, "CENTER", 0, 0)
	end)

	local function SkinLootFrameButton(i)
		if _G["LootButton"..i] and not _G["LootButton"..i]._skinned then
			_G["LootButton"..i]._skinned =  true
			
			_G["LootButton"..i]:SetSize(28, 28)
			_G["LootButton"..i]:SetHitRectInsets(0, -127, 0, 0);
			_G["LootButton"..i.."NameFrame"]:Hide()
		
			_G["LootButton"..i]:StripTextures("Interface\\QuestFrame\\UI-QuestItemNameFrame")
			
			_G["LootButton"..i.."IconTexture"]:SetTexCoord(unpack(AleaUI.media.texCoord))
			
			AleaUI:CreateBackdrop(_G["LootButton"..i], _G["LootButton"..i.."IconTexture"], {0, 0, 0, 1}, {0.2, 0.2, 0.2, 1}, "BACKGROUND")
			
			local borderparent = CreateFrame("Frame", nil, _G["LootButton"..i])
			
			borderparent:SetPoint("TOPLEFT", _G["LootButton"..i.."IconTexture"], "TOPRIGHT", 2, 0)
			borderparent:SetPoint("BOTTOMLEFT", _G["LootButton"..i.."IconTexture"], "BOTTOMRIGHT", 2, 0)
			borderparent:SetPoint("RIGHT", _G["LootButton"..i.."NameFrame"], "RIGHT", -8, 0)

			_G["LootButton"..i].borderparent = borderparent
			
			AleaUI:CreateBackdrop(_G["LootButton"..i], borderparent, {0, 0, 0, 1}, {0.2, 0.2, 0.2, 0.8}, "BACKGROUND")
		
			_G["LootButton"..i]:GetHighlightTexture():SetTexture([[Interface\Buttons\WHITE8x8]])
			_G["LootButton"..i]:GetHighlightTexture():SetVertexColor(1, 1, 1, 0.3)
			
			_G["LootButton"..i..'Text']:SetFont(default_font, 12, 'OUTLINE')
			_G["LootButton"..i..'Text']:SetWidth(120)

			_G["LootButton"..i.."IconQuestTexture"]:SetTexCoord(0.07, 0.93, 0.07, 0.93)
			_G["LootButton"..i.."IconQuestTexture"]:SetTexture(TEXTURE_ITEM_QUEST_BANG)
			_G["LootButton"..i.."IconQuestTexture"]:SetAllPoints(_G["LootButton"..i])
		end
	end
	
	for i=1, LOOTFRAME_NUMBUTTONS do
		SkinLootFrameButton(i)
	end

	local darkness = 0.7

	hooksecurefunc("LootFrame_UpdateButton", function(index)
		local numLootItems = LootFrame.numLootItems;
		--Logic to determine how many items to show per page
		local numLootToShow = LOOTFRAME_NUMBUTTONS;
		local self = LootFrame;
		if( self.AutoLootTable ) then
			numLootItems = #self.AutoLootTable;
		end
		if ( numLootItems > LOOTFRAME_NUMBUTTONS ) then
			numLootToShow = numLootToShow - 1; -- make space for the page buttons
		end

		local button = _G["LootButton"..index];
		local slot = (numLootToShow * (LootFrame.page - 1)) + index;
		if(button and button:IsShown()) then
			local texture, item, quantity, currencyID, quality, locked, isQuestItem, questId, isActive;
			if(LootFrame.AutoLootTablLootFramee)then
				local entry = LootFrame.AutoLootTable[slot];
				if( entry.hide ) then
					button:Hide();
					return;
				else
					texture = entry.texture;
					item = entry.item;
					quantity = entry.quantity;
					quality = entry.quality;
					locked = entry.locked;
					isQuestItem = entry.isQuestItem;
					questId = entry.questId;
					isActive = entry.isActive;
				end
			else
				texture, item, quantity, currencyID, quality, locked, isQuestItem, questId, isActive = GetLootSlotInfo(slot);
			end

			if(texture) then
			--	button.customQuestTexture:Show()
				
				if ( questId and not isActive ) then
			--		button.customQuestTexture:Show()
					button.borderparent:SetUIBackgroundColor(230/255*darkness,191/255*darkness,51/255*darkness, 0.7)
				elseif ( questId or isQuestItem ) then
					button.borderparent:SetUIBackgroundColor(230/255*darkness,191/255*darkness,51/255*darkness, 0.7)			
				elseif ( quality > 1 ) then
					local r, g, b, hex = GetItemQualityColor(quality);
					button.borderparent:SetUIBackgroundColor(r*darkness*darkness, g*darkness*darkness, b*darkness*darkness, 0.7)
				else
					button.borderparent:SetUIBackgroundColor(0.1, 0.1, 0.1, 0.7)
				end
			end
		end
	end)
	
	-- Calculate base height of the loot frame
	local p, r, x, y = "TOP", "BOTTOM", 0, -4
	local buttonHeight = 28 + abs(y)
	local baseHeight = LootFrame:GetHeight() - (buttonHeight * LOOTFRAME_NUMBUTTONS)

	LootFrame.OverflowText = LootFrame:CreateFontString(nil, "OVERLAY", "GameFontRedSmall")
	local OverflowText = LootFrame.OverflowText

	OverflowText:SetPoint("TOP", LootFrame, "TOP", 0, -26)
	OverflowText:SetPoint("LEFT", LootFrame, "LEFT", 60, 0)
	OverflowText:SetPoint("RIGHT", LootFrame, "RIGHT", -8, 0)
	OverflowText:SetPoint("BOTTOM", LootFrame, "TOP", 0, -65)
	OverflowText:SetSize(1, 1)

	OverflowText:SetJustifyH("LEFT")
	OverflowText:SetJustifyV("TOP")

	OverflowText:SetText(AleaUI.L["Hit 50-mob limit! Take some, then re-loot for more."])

	OverflowText:Hide()

	local t = {}
	
	local function Test_GuidToID(guid)	
		if not guid then 
			return 0 
		else
			local id = guid:match("[^%-]+%-%d+%-%d+%-%d+%-%d+%-(%d+)%-%w+")
			return tonumber(id or 0)
		end
	end
	
	local function CalculateNumMobsLooted()
		wipe(t)

		for i = 1, GetNumLootItems() do
			for n = 1, select("#", GetLootSourceInfo(i)), 2 do
				local GUID, num = select(n, GetLootSourceInfo(i))
				
				if not t[GUID] then
			--		print('Loot GUIDs', GUID, Test_GuidToID(GUID), LootHelper.Cache_GetBossNameByID and LootHelper.Cache_GetBossNameByID(Test_GuidToID(GUID)) or 'NoAddon')
				end
				
				t[GUID] = true
			end
		end

		local n = 0
		for k, v in pairs(t) do
			n = n + 1
		end

		return n
	end

	
	local old_LootFrame_Show = LootFrame_Show
--	local LOOTFRAME_NUMBUTTONS = LOOTFRAME_NUMBUTTONS
	
	function LootFrame_Show(self, ...)
		local maxButtons = floor(UIParent:GetHeight()/28 * 0.7)
		
		local num = GetNumLootItems()

		
		if self.AutoLootTable then
			num = #self.AutoLootTable
		end

		self.AutoLootDelay = 0.4 + (num * 0.05)


		num = min(num, maxButtons)

		LootFrame:SetHeight(baseHeight + (num * buttonHeight))
		for i = 1, num do
			if i > LOOTFRAME_NUMBUTTONS then
				local button = _G["LootButton"..i]
				if not button then
					button = CreateFrame("Button", "LootButton"..i, LootFrame, "LootButtonTemplate", i)
					SkinLootFrameButton(i)
				end
				LOOTFRAME_NUMBUTTONS = i
			end
			if i > 1 then
				local button = _G["LootButton"..i]
				button:ClearAllPoints()
				button:SetPoint(p, "LootButton"..(i-1), r, x, y)
			end
		end

		if CalculateNumMobsLooted() >= 50 then
			OverflowText:Show()
		else
			OverflowText:Hide()
		end

		
		return old_LootFrame_Show(self, ...)
	end
	
--	hooksecurefunc('LootFrame_Show', AleaUI_LootFrame_Show)
	
	local la1, la2, la3, la4, la5
	hooksecurefunc(LootFrame, 'SetPoint', function(self, a1, a2, a3, a4, a5)
		if ( GetCVar("lootUnderMouse") == "1" ) then
		
			if a1 ~= la1 or a3 ~= la3 or a4 ~= la4 or a5 ~= la5 then
				self:Lower();
					
				local x, y = GetCursorPosition();
				x = x / self:GetEffectiveScale();
				y = y / self:GetEffectiveScale();

				local posX = x - 175;
				local posY = y + 25;
				
				if (self.numLootItems > 0) then
					posX = x - 40;
					posY = y + 55;
					posY = posY + 40;
				end

				if( posY < 350 ) then
					posY = 350;
				end
				
				posX = posX + 10
				posY = posY - 10
				
				la1 = "TOPLEFT"
				la2 = nil
				la3 = "BOTTOMLEFT"
				la4 = posX
				la5 = posY
				
		--		print(la1, la3, la4, la5)
				
				self:ClearAllPoints();
				self:SetPoint("TOPLEFT", nil, "BOTTOMLEFT", posX, posY);
				self:GetCenter();
				self:Raise();
			end
		end
	end)
end

AleaUI:OnInit2(Skin_LootFrame)