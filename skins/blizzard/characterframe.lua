local E = AleaUI
local Skins = E:Module("Skins")
local _G = _G

local default_background_color = Skins.default_background_color
local default_border_color = Skins.default_border_color
local default_font = Skins.default_font
local default_texture = Skins.default_texture

local default_button_background = Skins.default_button_background
local default_button_border 	= Skins.default_button_border
local default_border_color_dark = Skins.default_border_color_dark

local varName = 'characterframe'
E.default_settings.skins[varName] = true

local function SkinCharacterFrame()
	if not E.db.skins.enableAll then return end
	if not E.db.skins[varName] then return end

	Skins.MassKillTexture('CharacterFrame')	

	Skins.ThemeBackdrop('CharacterFrame')
	Skins.ThemeBackdrop('CharacterFrameInsetRight')

	Skins.ThemeFrameRing('CharacterFrame')
	
	CharacterStatsPane.ClassBackground:SetAlpha(0)
	CharacterLevelText:SetFont(default_font, Skins.default_font_size, 'OUTLINE')
	
--	_G['CharacterStatsPaneTop']:SetAlpha(0)
--	_G['CharacterStatsPaneBottom']:SetAlpha(0)

	_G['PaperDollTitlesPaneScrollBarTop']:SetAlpha(0)
	_G['PaperDollTitlesPaneScrollBarBottom']:SetAlpha(0)
	_G['PaperDollTitlesPaneScrollBarMiddle']:SetAlpha(0)

	_G['PaperDollEquipmentManagerPaneScrollBarTop']:SetAlpha(0)
	_G['PaperDollEquipmentManagerPaneScrollBarBottom']:SetAlpha(0)
	_G['PaperDollEquipmentManagerPaneScrollBarMiddle']:SetAlpha(0)

	_G['PaperDollInnerBorderRight']:SetAlpha(0)
	_G['PaperDollInnerBorderLeft']:SetAlpha(0)
	_G['PaperDollInnerBorderTop']:SetAlpha(0)
	_G['PaperDollInnerBorderBottomRight']:SetAlpha(0)
	_G['PaperDollInnerBorderBottomLeft']:SetAlpha(0)
	_G['PaperDollInnerBorderTopRight']:SetAlpha(0)
	_G['PaperDollInnerBorderTopLeft']:SetAlpha(0)


	Skins.ThemeButton('PaperDollEquipmentManagerPaneEquipSet')
	Skins.ThemeButton('PaperDollEquipmentManagerPaneSaveSet')

	for i=1, 3 do
		Skins.ThemeTab('CharacterFrameTab'..i)
	end

	for i=1, 15 do

		local statusbar = _G["ReputationBar"..i.."ReputationBar"]

		if statusbar then
			if not statusbar.styled then
				statusbar.styled = true
				Skins.ThemeStatusBar('ReputationBar'..i..'ReputationBar')	
			end
			_G["ReputationBar"..i.."FactionName"]:SetFont(default_font, Skins.default_font_size, 'NONE')
			_G["ReputationBar"..i.."Background"]:SetTexture(nil)
			_G["ReputationBar"..i.."ReputationBarHighlight1"]:SetTexture(nil)
			_G["ReputationBar"..i.."ReputationBarHighlight2"]:SetTexture(nil)
			_G["ReputationBar"..i.."ReputationBarAtWarHighlight1"]:SetTexture(nil)
			_G["ReputationBar"..i.."ReputationBarAtWarHighlight2"]:SetTexture(nil)
			_G["ReputationBar"..i.."ReputationBarLeftTexture"]:SetTexture(nil)
			_G["ReputationBar"..i.."ReputationBarRightTexture"]:SetTexture(nil)

		end
	end

	--Reputation
	local function UpdateFactionSkins()
		ReputationListScrollFrame:StripTextures()
		ReputationFrame:StripTextures(true)
		for i=1, GetNumFactions() do
			local statusbar = _G["ReputationBar"..i.."ReputationBar"]

			if statusbar then
				if not statusbar.styled then
					statusbar.styled = true
					Skins.ThemeStatusBar('ReputationBar'..i..'ReputationBar')	
				end
				_G["ReputationBar"..i.."FactionName"]:SetFont(default_font, Skins.default_font_size, 'NONE')
				_G["ReputationBar"..i.."Background"]:SetTexture(nil)
				_G["ReputationBar"..i.."ReputationBarHighlight1"]:SetTexture(nil)
				_G["ReputationBar"..i.."ReputationBarHighlight2"]:SetTexture(nil)
				_G["ReputationBar"..i.."ReputationBarAtWarHighlight1"]:SetTexture(nil)
				_G["ReputationBar"..i.."ReputationBarAtWarHighlight2"]:SetTexture(nil)
				_G["ReputationBar"..i.."ReputationBarLeftTexture"]:SetTexture(nil)
				_G["ReputationBar"..i.."ReputationBarRightTexture"]:SetTexture(nil)

			end
		end
		if not ReputationDetailFrame.styled then
			ReputationDetailFrame.styled = true
			ReputationDetailFrame:StripTextures()
			Skins.ThemeBackdrop(ReputationDetailFrame)
			
			Skins.ThemeCheckBox(ReputationDetailAtWarCheckBox)
			Skins.ThemeCheckBox(ReputationDetailInactiveCheckBox)
			Skins.ThemeCheckBox(ReputationDetailMainScreenCheckBox)
		end
		ReputationDetailFrame:SetPoint("TOPLEFT", ReputationFrame, "TOPRIGHT", 4, -28)
	end

	ReputationFrame:HookScript("OnShow", UpdateFactionSkins)
	hooksecurefunc("ExpandFactionHeader", UpdateFactionSkins)
	hooksecurefunc("CollapseFactionHeader", UpdateFactionSkins)
		

--	Skins.ThemeScrollBar('CharacterStatsPaneScrollBar')
	Skins.ThemeScrollBar('PaperDollTitlesPaneScrollBar')
	Skins.ThemeScrollBar('PaperDollEquipmentManagerPaneScrollBar')

	Skins.ThemeScrollBar('ReputationListScrollFrameScrollBar')
	Skins.ThemeScrollBar('TokenFrameContainerScrollBar')

	TokenFramePopup:StripTextures()
	Skins.ThemeBackdrop(TokenFramePopup)
	Skins.ThemeCheckBox(TokenFramePopupInactiveCheckBox)
	Skins.ThemeCheckBox(TokenFramePopupBackpackCheckBox)

	local function TokenFrame_UpdateCategory()
		if not TokenFrameContainer.buttons then return end
		
		for i=1, #TokenFrameContainer.buttons do
			local name = TokenFrameContainer.buttons[i]:GetName()
			
			if _G[name..'CategoryMiddle'] then
				_G[name..'CategoryMiddle']:SetAlpha(0)
				_G[name..'CategoryRight']:SetAlpha(0)
				_G[name..'CategoryLeft']:SetAlpha(0)
				
				if not TokenFrameContainer.buttons[i].customCategoryTexture then
					
					local tex = TokenFrameContainer.buttons[i]:CreateTexture()
					
					local a1, a2 = _G[name..'CategoryMiddle']:GetDrawLayer()
					
					tex:SetDrawLayer(a1, a2)
					tex:SetAllPoints()
					tex:SetTexture([[Interface\AddOns\AleaUI\media\Minimalist.tga]])
					tex:SetVertexColor(0.4, 0.4, 0.4, 1)
					
					TokenFrameContainer.buttons[i].customCategoryTexture = tex
				end
				
				if _G[name..'CategoryMiddle']:IsShown() then
					TokenFrameContainer.buttons[i].customCategoryTexture:Show()
				else
					TokenFrameContainer.buttons[i].customCategoryTexture:Hide()
				end
			end
		end
	
	end
	
	hooksecurefunc('TokenFrame_Update', TokenFrame_UpdateCategory)	
	TokenFrameContainerScrollBar:HookScript('OnValueChanged', TokenFrame_UpdateCategory)
	
	_G['ReputationListScrollFrame']:DisableDrawLayer('BACKGROUND')


	_G['PaperDollInnerBorderBottom']:SetAlpha(0)
	_G['PaperDollInnerBorderBottom2']:SetAlpha(0)

	PaperDollTitlesPane:HookScript("OnShow", function(self)
		for x, object in pairs(PaperDollTitlesPane.buttons) do
			object.BgTop:SetTexture(nil)
			object.BgBottom:SetTexture(nil)
			object.BgMiddle:SetTexture(nil)

			object.text:SetFont(default_font, Skins.default_font_size, 'NONE')
			if not object.text._hooked  then
				object.text._hooked  = true
				hooksecurefunc(object.text, "SetFont", function(self, font, fontSize, fontStyle)
					if font ~= default_font then
						self:SetFont(default_font, Skins.default_font_size, 'NONE')
					end
				end)
			end
		end
	end)
	--[==[
	Skins.ThemeItemButton('CharacterMainHandSlot', 'MainHand')
	Skins.ThemeItemButton('CharacterSecondaryHandSlot', 'SecondaryHand')
	Skins.ThemeItemButton('CharacterHeadSlot', 'Head')
	Skins.ThemeItemButton('CharacterNeckSlot', 'Neck')
	Skins.ThemeItemButton('CharacterShoulderSlot', 'Shoulder')
	Skins.ThemeItemButton('CharacterBackSlot', 'Chest')
	Skins.ThemeItemButton('CharacterChestSlot', 'Chest')
	Skins.ThemeItemButton('CharacterShirtSlot', 'Shirt')
	Skins.ThemeItemButton('CharacterTabardSlot', 'Tabard')
	Skins.ThemeItemButton('CharacterWristSlot', 'Wrists')
	Skins.ThemeItemButton('CharacterHandsSlot', 'Hands')
	Skins.ThemeItemButton('CharacterWaistSlot', 'Waist')
	Skins.ThemeItemButton('CharacterLegsSlot', 'Legs')
	Skins.ThemeItemButton('CharacterFeetSlot', 'Feet')
	Skins.ThemeItemButton('CharacterFinger0Slot', 'Finger')
	Skins.ThemeItemButton('CharacterFinger1Slot', 'Finger')
	Skins.ThemeItemButton('CharacterTrinket0Slot', 'Trinket')
	Skins.ThemeItemButton('CharacterTrinket1Slot', 'Trinket')
	]==]
	--[==[
	local itemListName = {
		'CharacterMainHandSlot',
		'CharacterSecondaryHandSlot',
		'CharacterHeadSlot',
		'CharacterNeckSlot',
		'CharacterShoulderSlot',
		'CharacterBackSlot',
		'CharacterChestSlot',
		'CharacterShirtSlot',
		'CharacterTabardSlot',
		'CharacterWristSlot',
		'CharacterHandsSlot',
		'CharacterWaistSlot',
		'CharacterLegsSlot',
		'CharacterFeetSlot',
		'CharacterFinger0Slot',
		'CharacterFinger1Slot',
		'CharacterTrinket0Slot',
		'CharacterTrinket1Slot',
	}
	]==]
	
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
		local icon = _G["Character"..slot.."IconTexture"]
		local cooldown = _G["Character"..slot.."Cooldown"]
		slot = _G["Character"..slot]
		slot:StripTextures()
		slot:StyleButton(false)
		slot.ignoreTexture:SetTexture([[Interface\PaperDollInfoFrame\UI-GearManager-LeaveItem-Transparent]])
	--	slot:SetTemplate("Default", true)
		icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
		icon:SetInside()
		
		E:CreateBackdrop(slot, slot, default_border_color, default_background_color)
		slot:SetUIBorderDrawLayer('ARTWORK')
	
	
	
		if(cooldown) then
			E:RegisterCooldown(cooldown)
		end
		
		hooksecurefunc(slot.IconBorder, 'SetVertexColor', function(self, r, g, b)
			self:GetParent():SetUIBackdropBorderColor(r, g, b)
			self:SetTexture("")
		end)
		hooksecurefunc(slot.IconBorder, 'Hide', function(self)
			self:GetParent():SetUIBackdropBorderColor(unpack(default_border_color))
		end)
		
	end
	
	--[==[
	local runOnShow = false
	CharacterFrame:HookScript('OnShow', function()
		if runOnShow then return end
		runOnShow = true
		
		for i=1, #slots do
		--	local whiteTexture = Skins.GetTextureObject(_G[itemListName[i]], [[Interface\Common\WhiteIconFrame]])
		--	if whiteTexture then whiteTexture:SetAlpha(0) end
			
			local pushed = Skins.GetTextureObject(_G["Character"..slots[i]..'Slot'], [[Interface\Buttons\UI-Quickslot-Depress]])
			if pushed then pushed:SetAlpha(0) end
			
			E:RegisterCooldown(_G["Character"..slots[i].."SlotCooldown"])
		end
	end)
	]==]
--	Skins.ThemeIconButton(CharacterFrameExpandButton, true)

	EquipmentFlyoutFrameHighlight:Kill()
	EquipmentFlyoutFrame.NavigationFrame:StripTextures()

	Skins.ThemeBackdrop(EquipmentFlyoutFrame.NavigationFrame)

	EquipmentFlyoutFrame.NavigationFrame:SetPoint("TOPLEFT", EquipmentFlyoutFrameButtons, "BOTTOMLEFT", 0, -1)
	EquipmentFlyoutFrame.NavigationFrame:SetPoint("TOPRIGHT", EquipmentFlyoutFrameButtons, "BOTTOMRIGHT", 0, -1)
	Skins.ThemeIconButton(EquipmentFlyoutFrame.NavigationFrame.PrevButton, true)
	Skins.ThemeIconButton(EquipmentFlyoutFrame.NavigationFrame.NextButton, true)

	local function SkinItemFlyouts()
		--Because EquipmentFlyout_Show seems to run as OnUpdate, prevent re-skinning the frames over and over.
		if (not EquipmentFlyoutFrameButtons.isSkinned) or 
			(EquipmentFlyoutFrameButtons.bg2 and not EquipmentFlyoutFrameButtons.bg2.isSkinned) or 
			(EquipmentFlyoutFrameButtons.bg3 and not EquipmentFlyoutFrameButtons.bg3.isSkinned) or 
			(EquipmentFlyoutFrameButtons.bg4 and not EquipmentFlyoutFrameButtons.bg4.isSkinned) then
			
			EquipmentFlyoutFrameButtons:StripTextures()
			Skins.SetTemplate(EquipmentFlyoutFrame.NavigationFrame, 'ALPHADARK')
			EquipmentFlyoutFrameButtons.isSkinned = true
			if EquipmentFlyoutFrameButtons.bg2 then EquipmentFlyoutFrameButtons.bg2.isSkinned = true end
			if EquipmentFlyoutFrameButtons.bg3 then EquipmentFlyoutFrameButtons.bg3.isSkinned = true end
			if EquipmentFlyoutFrameButtons.bg4 then EquipmentFlyoutFrameButtons.bg4.isSkinned = true end
		end

		local i = 1
		local button = _G["EquipmentFlyoutFrameButton"..i]

		while button do
			if not button.isHooked then
				local icon = _G["EquipmentFlyoutFrameButton"..i.."IconTexture"]
				Skins.ThemeItemButton(button)
			--	button:GetNormalTexture():SetTexture(nil)

				if not button.backdrop then
					local backdrop = Skins.NewBackdrop(button)
					Skins.SetTemplate(backdrop, 'DARK')
					backdrop:SetAllPoints()			
					button.backdrop = backdrop
				end

				icon:SetInside()
				icon:SetTexCoord(unpack(E.media.texCoord))
				button.isHooked = true
			end

			i = i + 1
			button = _G["EquipmentFlyoutFrameButton"..i]
		end
	end

	hooksecurefunc('EquipmentFlyout_CreateButton', function()
		for i=1, #EquipmentFlyoutFrame.buttons do
			local button = EquipmentFlyoutFrame.buttons[i]
			
			local icon = _G[button:GetName().."IconTexture"]
			Skins.ThemeItemButton(button)
			if not button.backdrop then
				local backdrop = Skins.NewBackdrop(button)
				Skins.SetTemplate(backdrop, 'DARK')
				backdrop:SetAllPoints()			
				button.backdrop = backdrop
			end

			icon:SetInside()
			icon:SetTexCoord(unpack(E.media.texCoord))		
		end
	end)
	
	hooksecurefunc('EquipmentFlyout_UpdateItems', function()
	
		if not EquipmentFlyoutFrameButtons.isSkinned then
			EquipmentFlyoutFrameButtons:StripTextures()
			Skins.SetTemplate(EquipmentFlyoutFrame.NavigationFrame, 'ALPHADARK')
			EquipmentFlyoutFrameButtons.isSkinned = true
		end
		
		for i=1, 10 do
			if EquipmentFlyoutFrameButtons['bg'..i] then
				EquipmentFlyoutFrameButtons['bg'..i]:SetAlpha(0)
			end
		end
	end)
	
	local themed = true

	PaperDollEquipmentManagerPane:HookScript("OnShow", function(self)
		for x, object in pairs(PaperDollEquipmentManagerPane.buttons) do
			object.BgTop:SetTexture(nil)
			object.BgBottom:SetTexture(nil)
			object.BgMiddle:SetTexture(nil)
			object.icon:SetSize(36, 36)
			--object.Check:SetTexture(nil)
			object.icon:SetTexCoord(unpack(E.media.texCoord))

			--Making all icons the same size and position because otherwise BlizzardUI tries to attach itself to itself when it refreshes
			object.icon:SetPoint("LEFT", object, "LEFT", 4, 0)
			hooksecurefunc(object.icon, "SetPoint", function(self, point, attachTo, anchorPoint, xOffset, yOffset, isForced)
				if isForced ~= true then
					self:SetPoint("LEFT", object, "LEFT", 4, 0, true)
				end
			end)


			hooksecurefunc(object.icon, "SetSize", function(self, width, height)
				if width == 30 or height == 30 then
					self:SetSize(36, 36)
				end
			end)
		end
		
		if themed then
			themed = false
			GearManagerDialogPopup:StripTextures()
			Skins.ThemeBackdrop(GearManagerDialogPopup)
			GearManagerDialogPopup:SetPoint("LEFT", PaperDollFrame, "RIGHT", 4, 0)
			GearManagerDialogPopupScrollFrame:StripTextures()
			Skins.ThemeScrollBar(GearManagerDialogPopupScrollFrameScrollBar)
			Skins.ThemeEditBox(GearManagerDialogPopupEditBox,true)
			Skins.ThemeButton(GearManagerDialogPopupOkay)
			Skins.ThemeButton(GearManagerDialogPopupCancel)

			for i=1, NUM_GEARSET_ICONS_SHOWN do
				local button = _G["GearManagerDialogPopupButton"..i]
				local icon = button.icon

				if button then
					local checked = button:GetCheckedTexture()
					local step = 0.06
					checked:SetTexCoord(step, 1-step, step, 1-step)

					local highlight = button:GetHighlightTexture()
					highlight:SetAllPoints(icon)
					highlight:SetColorTexture(1, 1, 1, 0.2)
					
					icon:SetTexCoord(unpack(E.media.texCoord))
					
					local background = Skins.GetTextureObject(button, [[Interface\Buttons\UI-EmptySlot-Disabled]])
					background:SetColorTexture(0, 0, 0, 1)
					background:SetOutside(icon)
					
					icon:SetTexCoord(unpack(E.media.texCoord))
					_G["GearManagerDialogPopupButton"..i.."Icon"]:SetTexture(nil)

					icon:SetInside()
					button:SetFrameLevel(button:GetFrameLevel() + 2)
					if not button.backdrop then
						local backdrop = Skins.NewBackdrop(button)
						Skins.SetTemplate(backdrop, 'BORDERED')
						backdrop:SetAllPoints()
						button.backdrop = backdrop
					end
				end
			end
		end
	end)

end

E:OnInit2(SkinCharacterFrame)