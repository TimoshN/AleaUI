local Skins = AleaUI:Module("Skins")
local _G = _G

local default_background_color = Skins.default_background_color
local default_border_color = Skins.default_border_color
local default_font = Skins.default_font
local default_texture = Skins.default_texture

local default_button_background = Skins.default_button_background
local default_button_border 	= Skins.default_button_border
local default_border_color_dark = Skins.default_border_color_dark

local varName = 'pveframe'
AleaUI.default_settings.skins[varName] = true

local function Skin_PVEFrame()
	
	if not AleaUI.db.skins.enableAll then return end
	if not AleaUI.db.skins[varName] then return end

	LFGListFrame.ApplicationViewer:StripTextures()
	LFGListFrame.ApplicationViewer.Inset:StripTextures()
	LFGListFrame.ApplicationViewer.InfoBackground:SetTexCoord(unpack(AleaUI.media.texCoord))

	LFGListFrame.ApplicationViewer.NameColumnHeader:StripTextures()
	LFGListFrame.ApplicationViewer.RoleColumnHeader:StripTextures()
	LFGListFrame.ApplicationViewer.ItemLevelColumnHeader:StripTextures()

	LFGListFrame.CategorySelection.Inset:SetAlpha(0)


	Skins.ThemeScrollBar('LFGListApplicationViewerScrollFrameScrollBar')

	Skins.MassKillTexture('PVEFrame')

	PVEFrame:StripTextures()
	
	Skins.MassKillTexture('LFDParentFrame')
	
	LFDParentFrameInset:StripTextures()

	--Skins.MassKillTexture('RaidFinderFrame')
	RaidFinderFrame:StripTextures()
	RaidFinderFrameBottomInset:StripTextures()
	RaidFinderFrameRoleInset:StripTextures()
	RaidFinderFrameRoleInset.NineSlice:StripTextures()
	RaidFinderFrameBottomInset:SetAlpha(0)

	hooksecurefunc('LFGListCategorySelection_UpdateCategoryButtons', function()	
		for i=1, #LFGListFrame.CategorySelection.CategoryButtons do			
			LFGListFrame.CategorySelection.CategoryButtons[i].Label:SetFont(default_font, 12, 'NONE')
		end
	end)
	for i=1, #LFGListFrame.CategorySelection.CategoryButtons do		
		LFGListFrame.CategorySelection.CategoryButtons[i].Label:SetFont(default_font, 12, 'NONE')
	end
		
	Skins.ThemeIconButton(LFGListFrame.SearchPanel.RefreshButton, true)

	LFGListFrame.CategorySelection.Inset:StripTextures()
	LFGListFrame.SearchPanel.ResultsInset:StripTextures()

	Skins.ThemeFilterButton(LFGListFrame.SearchPanel.FilterButton)

	--LFGListFrame.CategorySelection.StartGroupButton.RightSeparator:SetAlpha(0)
	Skins.ThemeButton(LFGListFrame.CategorySelection.StartGroupButton)
--	LFGListFrame.CategorySelection.StartGroupButton:SetHeight(16)

	--LFGListFrame.CategorySelection.FindGroupButton.LeftSeparator:SetAlpha(0)
	Skins.ThemeButton(LFGListFrame.CategorySelection.FindGroupButton)
--	LFGListFrame.CategorySelection.FindGroupButton:SetHeight(16)

	--LFGListFrame.SearchPanel.BackButton.RightSeparator:SetAlpha(0)
	Skins.ThemeButton(LFGListFrame.SearchPanel.BackButton)
--	LFGListFrame.SearchPanel.BackButton:SetHeight(16)

	--LFGListFrame.SearchPanel.SignUpButton.LeftSeparator:SetAlpha(0)
	Skins.ThemeButton(LFGListFrame.SearchPanel.SignUpButton)
--	LFGListFrame.SearchPanel.SignUpButton:SetHeight(16)

	LFGListFrame.EntryCreation:StripTextures()
	LFGListFrame.EntryCreation.Inset:StripTextures()

	Skins.ThemeButton(LFGListFrame.EntryCreation.CancelButton)
	Skins.ThemeButton(LFGListFrame.EntryCreation.ListGroupButton)

	Skins.ThemeEditBox(LFGListFrame.EntryCreation.Name, true)
	Skins.ThemeEditBox(LFGListFrame.EntryCreation.ItemLevel.EditBox, true)
	Skins.ThemeEditBox(LFGListFrame.EntryCreation.VoiceChat.EditBox, true)

	Skins.ThemeCheckBox(LFGListFrame.EntryCreation.ItemLevel.CheckButton)
	Skins.ThemeCheckBox(LFGListFrame.EntryCreation.VoiceChat.CheckButton)
	
	Skins.ThemeButton(LFGListFrame.ApplicationViewer.RemoveEntryButton)
	Skins.ThemeButton(LFGListFrame.ApplicationViewer.EditButton)
	Skins.ThemeCheckBox(LFGListFrame.ApplicationViewer.AutoAcceptButton)
	
--	LFGListEntryCreationDescription:StripTextures()
--	Skins.ThemeBackdrop('LFGListEntryCreationDescription')
--	Skins.ThemeScrollBar('LFGListEntryCreationDescriptionScrollBar')
	Skins.ThemeScrollBar('LFDQueueFrameRandomScrollFrameScrollBar')
	Skins.ThemeScrollBar('LFDQueueFrameSpecificListScrollFrameScrollBar')
	
	Skins.ThemeDropdown('LFDQueueFrameTypeDropDown')
	Skins.ThemeDropdown('RaidFinderQueueFrameSelectionDropDown')


	Skins.ThemeDropdown('LFGListEntryCreationCategoryDropDown')
	Skins.ThemeDropdown('LFGListEntryCreationGroupDropDown')
	Skins.ThemeDropdown('LFGListEntryCreationActivityDropDown')

	LFGListApplicationDialog:StripTextures()
	Skins.ThemeBackdrop('LFGListApplicationDialog')
--	LFGListApplicationDialogDescription:StripTextures()
	Skins.ThemeBackdrop('LFGListApplicationDialogDescription')
	Skins.ThemeButton(LFGListApplicationDialog.SignUpButton)
	Skins.ThemeButton(LFGListApplicationDialog.CancelButton)

	Skins.ThemeButton(LFGListInviteDialog.AcknowledgeButton)
	
	Skins.ThemeBackdrop('LFGListInviteDialog')
	Skins.ThemeButton(LFGListInviteDialog.AcceptButton)
	Skins.ThemeButton(LFGListInviteDialog.DeclineButton)

	local border, parent = Skins.ThemeEditBox(LFGListFrame.SearchPanel.SearchBox)
	border:ClearAllPoints()
	border:SetPoint('TOPLEFT', parent, 'TOPLEFT', -3, 3)
	border:SetPoint('BOTTOMRIGHT', parent, 'BOTTOMRIGHT', 3, -3)


	Skins.ThemeScrollBar('LFGListSearchPanelScrollFrameScrollBar')

	Skins.ThemeBackdrop('PVEFrame')

	Skins.ThemeFrameRing('PVEFrame')

--	AleaUI:CreateBackdrop(LFDParentFrameInset, LFDParentFrameInset, default_border_color, default_background_color)

--	AleaUI:CreateBackdrop(PVEFrame, PVEFrameBlueBg, default_border_color, default_background_color)
	
--	AleaUI:CreateBackdrop(RaidFinderFrameBottomInset, RaidFinderFrameBottomInset, default_border_color, default_background_color)
	
	-- local blueTextureArtwork = CreateFrame('Frame', nil, PVEFrame)
	-- blueTextureArtwork:SetSize(1,1)
	-- blueTextureArtwork:SetAllPoints(PVEFrameBlueBg)
	
	-- AleaUI:CreateBackdrop(blueTextureArtwork, nil, default_border_color, default_background_color)
	
	-- blueTextureArtwork:SetUIBorderDrawLayer('BORDER', -1)
	-- blueTextureArtwork:SetUIBackgroundDrawLayer('BACKGROUND', -1)
	
	local LFDQueueFrameBorder = CreateFrame('Frame', nil, LFDQueueFrameRandom)
		LFDQueueFrameBorder:SetPoint('TOPRIGHT', LFDQueueFrame, 'TOPRIGHT', -5, -148)
		LFDQueueFrameBorder:SetSize(326, 253)
		LFDQueueFrameBorder:SetFrameLevel(LFDQueueFrame:GetFrameLevel()+10)
	--	SpecializationBorder:SetFrameStrata('HIGH')
		AleaUI:CreateBackdrop(LFDQueueFrameBorder, nil, { 0, 0, 0, 1 }, {0,0,0,0})
		LFDQueueFrameBorder:SetUIBorderDrawLayer('OVERLAY', 1)	
		LFDQueueFrameRandomScrollFrameScrollBar:SetFrameLevel(LFDQueueFrame:GetFrameLevel()+11)
		
	local RaidFinderFrameBorder = CreateFrame('Frame', nil, RaidFinderFrame)
		RaidFinderFrameBorder:SetPoint('TOPRIGHT', LFDQueueFrame, 'TOPRIGHT', -5, -148)
		RaidFinderFrameBorder:SetSize(326, 253)
		RaidFinderFrameBorder:SetFrameLevel(RaidFinderFrame:GetFrameLevel()+10)
	--	SpecializationBorder:SetFrameStrata('HIGH')
		AleaUI:CreateBackdrop(RaidFinderFrameBorder, nil, { 0, 0, 0, 1 }, {0,0,0,0})
		RaidFinderFrameBorder:SetUIBorderDrawLayer('OVERLAY', 1)
	
	RaidFinderQueueFrameBackground:ClearAllPoints()
	RaidFinderQueueFrameBackground:SetPoint('TOPLEFT', RaidFinderFrameBorder, 'TOPLEFT', -1, 1)
	RaidFinderQueueFrameBackground:SetSize(513, 257)
	
	PVEFrame.shadows:StripTextures()


	--LFDQueueFrameFindGroupButton_RightSeparator:SetAlpha(0)
	--LFDQueueFrameFindGroupButton_LeftSeparator:SetAlpha(0)	
	Skins.ThemeButton('LFDQueueFrameFindGroupButton')
	--LFDQueueFrameFindGroupButton:SetHeight(16)

	CreateFrame("Frame"):SetScript("OnUpdate", function(self, elapsed)
		if LFRBrowseFrame.timeToClear then
			LFRBrowseFrame.timeToClear = nil
		end
	end)

	for i=1, 1 do
		Skins.ThemeSpellButton('LFDQueueFrameRandomScrollFrameChildFrameItem'..i, true)
	end
	Skins.ThemeSpellButton('LFDQueueFrameRandomScrollFrameChildFrameMoneyReward', true)

	for i=1, 1 do
		Skins.ThemeSpellButton('RaidFinderQueueFrameScrollFrameChildFrameItem'..i, true)
	end
	Skins.ThemeSpellButton('RaidFinderQueueFrameScrollFrameChildFrameMoneyReward', true)


	--RaidFinderFrameFindRaidButton_RightSeparator:SetAlpha(0)
	--RaidFinderFrameFindRaidButton_LeftSeparator:SetAlpha(0)
	Skins.ThemeButton('RaidFinderFrameFindRaidButton')
	--RaidFinderFrameFindRaidButton:SetHeight(16)

	AleaUI:OnAddonLoad('Blizzard_ChallengesUI', function()
		ChallengesFrameInset:StripTextures()
		
		-- ChallengesFrame:HookScript('OnShow', function()
		-- 	blueTextureArtwork:Hide()
		-- end)
		-- ChallengesFrame:HookScript('OnHide', function()
		-- 	blueTextureArtwork:Show()
		-- end)
		
		-- if ChallengesFrame:IsVisible() then
		-- 	blueTextureArtwork:Hide()
		-- else
		-- 	blueTextureArtwork:Show()
		-- end
		
		-- AleaUI:CreateBackdrop(ChallengesFrame, ChallengesFrameInset, default_border_color, default_background_color)
		
	--	local texture = Skins.GetTextureObject('ChallengesFrameDetails', [[Interface\Common\bluemenu-vert]], 0.00781250, 0.00781250, 0, 1)
	--	texture:SetAlpha(0)
	end)

	for i=1, 3 do
		Skins.ThemeTab('PVEFrameTab'..i)
	end
end

AleaUI:OnInit2(Skin_PVEFrame)