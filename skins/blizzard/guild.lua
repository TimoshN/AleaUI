local Skins = AleaUI:Module("Skins")
local _G = _G

local default_background_color = Skins.default_background_color
local default_border_color = Skins.default_border_color
local default_font = Skins.default_font
local default_texture = Skins.default_texture

local default_button_background = Skins.default_button_background
local default_button_border 	= Skins.default_button_border
local default_border_color_dark = Skins.default_border_color_dark

local varName = 'guild'
AleaUI.default_settings.skins[varName] = true

AleaUI:OnAddonLoad('Blizzard_GuildUI', function()
	if not AleaUI.db.skins.enableAll then return end
	if not AleaUI.db.skins[varName] then return end

	for i=1, 3 do	
		Skins.ThemeUpperTabs(_G['GuildInfoFrameTab'..i])
	end
	
	_G['GuildFrame']:StripTextures()
	_G['GuildFrameInset']:StripTextures()
	
	GuildFrame.NineSlice:StripTextures()
	GuildFrameInset.NineSlice:StripTextures()


	Skins.ThemeBackdrop('GuildFrame')
	
	for i=1, 5 do
		Skins.ThemeTab('GuildFrameTab'..i)
	end
	
	Skins.ThemeScrollBar('GuildLogScrollFrameScrollBar')
	
	GuildLogContainer:StripTextures()
	Skins.ThemeBackdrop('GuildLogContainer')
	
	GuildLogFrame:StripTextures()
	Skins.ThemeBackdrop('GuildLogFrame')
	
	for i=1, 4 do
		_G["GuildRosterColumnButton"..i]:StripTextures(true)
	end
	
	GuildNewsBossModel:StripTextures()
	GuildNewsBossModelTextFrame:StripTextures()		
	Skins.ThemeBackdrop('GuildNewsBossModel')
	Skins.ThemeBackdrop('GuildNewsBossModelTextFrame')
	GuildNewsBossModelTextFrame:ClearAllPoints()
	GuildNewsBossModelTextFrame:SetPoint('TOP', GuildNewsBossModel, 'BOTTOM')
	GuildNewsBossModel:SetPoint("TOPLEFT", GuildFrame, "TOPRIGHT", 4, -43)
	
	GuildInfoFrameInfo:StripTextures()
	
	GuildNewsFiltersFrame:StripTextures()
	Skins.ThemeBackdrop('GuildNewsFiltersFrame')
	
	for i, name in pairs({ 'GuildAchievement', 'Achievement', 'DungeonEncounter', 'EpicItemLooted', 'EpicItemPurchased', 'EpicItemCrafted', 'LegendaryItemLooted' }) do
		Skins.ThemeCheckBox(GuildNewsFiltersFrame[name])
	end
	
	for i=1, GuildLogFrame:GetNumChildren() do
		local child = select(i, GuildLogFrame:GetChildren())
		if child:GetName() == "GuildLogFrameCloseButton" and child:GetWidth() < 33 then
			
		elseif child:GetName() == "GuildLogFrameCloseButton" then
			Skins.ThemeButton(child)
		end
	end
	
	GuildMemberDetailFrame:StripTextures()
	Skins.ThemeBackdrop('GuildMemberDetailFrame')
	Skins.ThemeDropdown(GuildMemberRankDropdown)
	
	Skins.ThemeButton('GuildMemberRemoveButton')
	Skins.ThemeButton('GuildMemberGroupInviteButton')
	
	GuildMemberNoteBackground:StripTextures()
	GuildMemberOfficerNoteBackground:StripTextures()
	
	GuildMemberGroupInviteButtonText:SetWordWrap(true)
	GuildMemberGroupInviteButtonText:SetFont(default_font, Skins.default_font_size, 'NONE')
	
	Skins.ThemeFrameRing('GuildFrame')
	
	Skins.ThemeScrollBar('GuildNewsContainerScrollBar')
	Skins.ThemeScrollBar('GuildRosterContainerScrollBar')
	Skins.ThemeScrollBar('GuildRewardsContainerScrollBar')
	Skins.ThemeScrollBar('GuildInfoDetailsFrameScrollBar')
	
	Skins.ThemeButton('GuildRecruitmentInviteButton')
	Skins.ThemeButton('GuildRecruitmentMessageButton')
	Skins.ThemeButton('GuildRecruitmentDeclineButton')
	
	Skins.ThemeButton('GuildControlButton')
	Skins.ThemeButton('GuildViewLogButton')
	Skins.ThemeButton('GuildAddMemberButton')
	
--	GuildAddMemberButton:ClearAllPoints()
--	GuildAddMemberButton:SetPoint('BOTTOMLEFT', GuildFrame, 'BOTTOMLEFT', 7, 4)
	GuildAddMemberButton:SetWidth(GuildAddMemberButton:GetWidth()-3)

--	GuildViewLogButton:ClearAllPoints()
--	GuildViewLogButton:SetPoint('LEFT', GuildAddMemberButton, 'RIGHT', 3, 0)
	GuildViewLogButton:SetWidth(GuildViewLogButton:GetWidth()-7)

--	GuildControlButton:ClearAllPoints()
--	GuildControlButton:SetPoint('LEFT', GuildViewLogButton, 'RIGHT', 3, 0)
	GuildControlButton:SetWidth(GuildControlButton:GetWidth()+8)



	--_G['GuildControlButton_LeftSeparator']:SetAlpha(0)
	--_G['GuildAddMemberButton_RightSeparator']:SetAlpha(0)
	
	for i=1, 9 do
		local button = _G["GuildPerksContainerButton"..i]
		button:DisableDrawLayer("BACKGROUND")
		button:DisableDrawLayer("BORDER")

		button.icon:SetTexCoord(unpack(AleaUI.media.texCoord))
		
		local backdrop = Skins.NewBackdrop(button)
		Skins.SetTemplate(backdrop, 'ALPHADARK')
		backdrop:SetPoint('TOPLEFT', button.icon, 'TOPLEFT', 0, 0)
		backdrop:SetPoint('BOTTOMRIGHT', button, 'BOTTOMRIGHT', 0, 2)
		
		backdrop:SetFrameLevel(button:GetFrameLevel()-1)
		
		local backdrop = Skins.NewBackdrop(button, button.icon)
		Skins.SetTemplate(backdrop, 'BORDERED')
		backdrop:SetOutside(button.icon)
	end
	
	for i=1, 8 do
		local button = _G["GuildRewardsContainerButton"..i]
		button:StripTextures()

		if button.icon then
			button.icon:SetTexCoord(unpack(AleaUI.media.texCoord))
			button.icon:ClearAllPoints()
			button.icon:SetPoint("TOPLEFT", 2, -2)
			button.icon:SetDrawLayer('ARTWORK', 1)
			Skins.ThemeBackdrop(button)
			
			local temp = Skins.NewBackdrop(button, button.icon)
			temp:SetBackdropColor(0, 0, 0, 0)
			
		--	button.icon:SetParent(temp)
		end
	end
	
	Skins.ThemeDropdown('GuildRosterViewDropdown')
	
	GuildFactionBar:StripTextures()
	GuildFactionBar.progress:SetTexture(default_texture)
	
	local bg = CreateFrame('Frame', nil, GuildFactionBar)
	bg:SetPoint('LEFT', GuildFactionBar, "LEFT", 0, 0)
	bg:SetPoint('RIGHT', GuildFactionBar, "RIGHT", 0, 0)
	bg:SetPoint('TOP', GuildFactionBar.progress, "TOP", 0, 0)
	bg:SetPoint('BOTTOM', GuildFactionBar.progress, "BOTTOM", 0, 0)
	
	AleaUI:CreateBackdrop(GuildFactionBar, bg, default_border_color, {0,0,0,0})
	
	Skins.ThemeCheckBox(GuildRosterShowOfflineButton)
	
		
	local frame1 = Skins.NewBackdrop(GuildInfoFrameInfo)
	frame1:SetFrameLevel(1)--WardrobeCollectionFrame.SetsCollectionFrame.DetailsFrame:GetFrameLevel()-2)
	frame1:SetSize(100, 20)
	frame1:SetPoint('TOPLEFT', GuildInfoMOTD, 'TOPLEFT', -12, 5)
	frame1:SetPoint('BOTTOMRIGHT', GuildInfoMOTD, 'BOTTOMRIGHT', 23, -5)
	Skins.SetTemplate(frame1, 'DARK')
	
	local frame2 = Skins.NewBackdrop(GuildInfoFrameInfo)
	frame2:SetFrameLevel(1)--WardrobeCollectionFrame.SetsCollectionFrame.DetailsFrame:GetFrameLevel()-2)
	frame2:SetSize(100, 20)
	frame2:SetPoint('TOPLEFT', GuildInfoDetailsFrame, 'TOPLEFT', -12, 5)
	frame2:SetPoint('BOTTOMRIGHT', GuildInfoDetailsFrame, 'BOTTOMRIGHT', 23, -8)
	Skins.SetTemplate(frame2, 'DARK')
end)