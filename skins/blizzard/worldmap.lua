local Skins = AleaUI:Module("Skins")
local _G = _G

local default_background_color = Skins.default_background_color
local default_border_color = Skins.default_border_color
local default_font = Skins.default_font
local default_texture = Skins.default_texture

local default_button_background = Skins.default_button_background
local default_button_border 	= Skins.default_button_border
local default_border_color_dark = Skins.default_border_color_dark

local varName = 'worldmap'
AleaUI.default_settings.skins[varName] = true

local function Skin_WorldMap()
	if not AleaUI.db.skins.enableAll then return end
	if not AleaUI.db.skins[varName] then return end

	_G['WorldMapFrame']:StripTextures()
	WorldMapFrame.BorderFrame:StripTextures()
	WorldMapFrame.BorderFrame.NineSlice:StripTextures()
	--WorldMapFrame.BorderFrame.Inset:StripTextures()

	_G['QuestScrollFrame']:StripTextures()
	
	
	WorldMapFrame.NavBar:StripTextures()
	WorldMapFrame.NavBar.overlay:StripTextures()
	--Skins.ThemeBackdrop('WorldMapFrameNavBar')
	--[==[
	local sizeUpPoints = { "BOTTOMLEFT", 'WorldMapScrollFrame', 'TOPLEFT', 0 , 0 }
	local sizeDownPoints = { "BOTTOMLEFT", 'WorldMapScrollFrame', 'TOPLEFT', 0 , 0 }
	
	local defaultPoint = sizeUpPoints

	local WorldMapFrameNavBar_BG = WorldMapFrameNavBar:CreateTexture()
	WorldMapFrameNavBar_BG:SetPoint('TOPLEFT', WorldMapFrameNavBar, 'TOPLEFT', -1, -1)
	WorldMapFrameNavBar_BG:SetPoint('BOTTOMRIGHT', WorldMapScrollFrame, 'TOPRIGHT', 0, 1)
	WorldMapFrameNavBar_BG:SetColorTexture(0,0,0,1)
	
	local WorldMapFrame_BG = WorldMapScrollFrame:CreateTexture()
	WorldMapFrame_BG:SetOutside()
	WorldMapFrame_BG:SetColorTexture(0,0,0,1)

	WorldMapFrameNavBar:ClearAllPoints()
	WorldMapFrameNavBar:SetPoint(defaultPoint[1], _G[defaultPoint[2]], defaultPoint[3], defaultPoint[4], defaultPoint[5])

	hooksecurefunc(WorldMapFrameNavBar, 'SetPoint', function(self, point, parent, anchor, xpos, ypos)
		if ( point ~= defaultPoint[1] ) or 
		   ( parent ~= _G[defaultPoint[2]] ) or
		   ( anchor ~= defaultPoint[3] ) or 
		   ( xpos ~= defaultPoint[4] ) or
		   ( ypos ~= defaultPoint[5] ) then
			
			WorldMapFrameNavBar:ClearAllPoints()
			WorldMapFrameNavBar:SetPoint(defaultPoint[1], _G[defaultPoint[2]], defaultPoint[3], defaultPoint[4], defaultPoint[5])

		end
	end)
	]==]

	Skins.ThemeScrollBar('QuestScrollFrameScrollBar')
	Skins.ThemeBackdrop('WorldMapFrame')	

	Skins.ThemeButton(QuestMapFrame.DetailsFrame.BackButton)

	QuestMapFrame.DetailsFrame.AbandonButton:StripTextures()
	Skins.ThemeButton(QuestMapFrame.DetailsFrame.AbandonButton)

	QuestMapFrame.DetailsFrame.ShareButton:StripTextures()
	Skins.ThemeButton(QuestMapFrame.DetailsFrame.ShareButton)

	QuestMapFrame.DetailsFrame.TrackButton:StripTextures()
	Skins.ThemeButton(QuestMapFrame.DetailsFrame.TrackButton)
		
	QuestMapFrame.VerticalSeparator:Hide()
	
	Skins.ThemeScrollBar('QuestMapDetailsScrollFrameScrollBar')
	
	local QuestScrollFrame_BG = QuestScrollFrame:CreateTexture()
	QuestScrollFrame_BG:SetDrawLayer('BACKGROUND', -1)
	QuestScrollFrame_BG:SetOutside(QuestScrollFrame.Background)
	QuestScrollFrame_BG:SetColorTexture(0,0,0,1)
	
	local hiden = CreateFrame('Frame')
	hiden:Hide()
	
	WorldMapFrame.BorderFrame.Tutorial:SetParent(hiden)
--	WorldMapFrameTutorialButton:HookScript('OnShow', WorldMapFrameTutorialButton.Hide)
	
--	WorldMapFrameTutorialButton.Ring:Kill()
--	WorldMapFrameTutorialButtonRingPulse:Kill()
--	WorldMapFrameTutorialButton:GetHighlightTexture():Kill()

--	Skins.ThemeIconButton(WorldMapFrame.UIElementsFrame.OpenQuestPanelButton, true, a1,a2,a3,a4, 0.18)
--	Skins.ThemeIconButton(WorldMapFrame.UIElementsFrame.CloseQuestPanelButton, true, a1,a2,a3,a4, 0.18)

	local rewardFrames = {
		['MoneyFrame'] = true,
		['XPFrame'] = true,
	--	['SpellFrame'] = false,
		['HonorFrame'] = true,
		['SkillPointFrame'] = true, -- this may have extra textures.. need to check on it when possible
	}

	local hookedFrames = {}
		
	local function HandleReward(frame)

		if not hookedFrames[frame] and frame.Name then
			hookedFrames[frame] = true
			
			frame.NameFrame:SetAlpha(0)
			frame.Icon:SetTexCoord(unpack(AleaUI.media.texCoord))
			
			AleaUI:CreateBackdrop(frame, frame.Icon, default_border_color, { 0, 0, 0, 0 })

			local temp = CreateFrame('Frame', nil, frame)
			temp:EnableMouse(false)
			temp:SetSize(100, 40)
			temp:SetPoint('TOPLEFT', frame.Icon, 'TOPRIGHT', 3, 0)
			temp:SetPoint('BOTTOMLEFT', frame.Icon, 'BOTTOMRIGHT', 3, 0)

			frame.Name:SetFont(default_font, Skins.default_font_size)
			
			AleaUI:CreateBackdrop(frame, temp, default_border_color, { 0, 0, 0, 0.3 })

		end
		if frame.Count then
			frame.Count:ClearAllPoints()
			frame.Count:SetPoint("BOTTOMRIGHT", frame.Icon, "BOTTOMRIGHT", 2, 0)
			if(frame.CircleBackground) then
				frame.CircleBackground:SetAlpha(0)
				frame.CircleBackgroundGlow:SetAlpha(0)
			end
		end		
	end

	for frame, obj in pairs(MapQuestInfoRewardsFrame) do
		if frame and type(obj) == 'table' then
			HandleReward(obj)
		end
	end

	hooksecurefunc('QuestInfo_GetRewardButton', function(rewardsFrame, index)
		local button = MapQuestInfoRewardsFrame.RewardButtons[index]
		if(button) then
			HandleReward(button)
		end
	end)
	--[==[
	function WorldMapFrame.UIElementsFrame.BountyBoard.GetDisplayLocation(self)
		if InCombatLockdown() then
			print('BountyBoard - Skip Update GetDisplayLocation')
			return
		end
	 
		return WorldMapBountyBoardMixin.GetDisplayLocation(self)
	end
	 
	function WorldMapFrame.UIElementsFrame.ActionButton.GetDisplayLocation(self, useAlternateLocation)
		if InCombatLockdown() then
			print('ActionButton - Skip Update GetDisplayLocation')
			return
		end
	 
		return WorldMapActionButtonMixin.GetDisplayLocation(self, useAlternateLocation)
	end
	 
	function WorldMapFrame.UIElementsFrame.ActionButton.Refresh(self)
		if InCombatLockdown() then
			print('ActionButton - Skip Update Refresh')
			return
		end
	 
		WorldMapActionButtonMixin.Refresh(self)
	end
	]==]
	
	local function StyleNavButton(frame, index)
		frame:StripTextures()
		
		
		if frame.Text then
			frame.Text:SetFont(Skins.default_font, Skins.default_font_size, 'NONE')
		elseif frame:GetName() then
			_G[frame:GetName()..'Text']:SetFont(Skins.default_font, Skins.default_font_size, 'NONE')
		end

		local temp = Skins.ThemeButtonBackdrop(frame)
		
		if index == 1 then
			temp:SetPoint('TOPLEFT', frame, 'TOPLEFT', 0, 0)
			temp:SetPoint('BOTTOMRIGHT', frame, 'BOTTOMRIGHT', -20, 0)
		else
			temp:SetPoint('TOPLEFT', frame, 'TOPLEFT', 10, 0)
			temp:SetPoint('BOTTOMRIGHT', frame, 'BOTTOMRIGHT', -0, 0)
		end
	end
	
	local styled = {}
	local function StyleForNavButtons(self)
		if self ~= WorldMapFrame.NavBar then return end
		
	--	print('Home', 1, _G[self:GetName().."HomeButton"])
		
		if not styled[_G["WorldMapFrameHomeButton"]] then
			styled[_G["WorldMapFrameHomeButton"]] = true
			
			
			StyleNavButton(_G["WorldMapFrameHomeButton"], 1)
		end
		
		local numbutton = 2
		
		for i=1, #self.navList do
			if not styled[ self.navList[i] ] then
				styled[ self.navList[i] ] = true
				StyleNavButton(self.navList[i])
			end
		end
		
		--[==[
		while ( _G[self:GetName().."Button".. numbutton] ) do
			
			if not styled[_G[self:GetName().."Button".. numbutton]] then
				styled[_G[self:GetName().."Button".. numbutton]] = true
				StyleNavButton(_G[self:GetName().."Button".. numbutton])
			end

			numbutton = numbutton + 1
		end		
		]==]
	end
	
	
	
	hooksecurefunc('NavBar_Initialize', StyleForNavButtons)	
	hooksecurefunc('NavBar_AddButton', StyleForNavButtons)
	
	--Skins.ThemeDropdown('WorldMapLevelDropDown')
end

AleaUI:OnInit2(Skin_WorldMap)