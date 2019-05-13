local Skins = AleaUI:Module("Skins")
local _G = _G

local default_background_color = Skins.default_background_color
local default_border_color = Skins.default_border_color
local default_font = Skins.default_font
local default_texture = Skins.default_texture

local default_button_background = Skins.default_button_background
local default_button_border 	= Skins.default_button_border
local default_border_color_dark = Skins.default_border_color_dark

local varName = 'questframe'
AleaUI.default_settings.skins[varName] = true

local questTextureList = {
--	['QuestLogPopupDetailFrameBg'] = true,
	['QuestLogPopupDetailFrameTitleBg'] = true,
	['QuestLogPopupDetailFramePortrait'] = true,
	['QuestLogPopupDetailFramePortraitFrame'] = true,
	['QuestLogPopupDetailFrameTopRightCorner'] = true,
	['QuestLogPopupDetailFrameTopLeftCorner'] = true,
	['QuestLogPopupDetailFrameTopBorder'] = true,
	['QuestLogPopupDetailFrameTopTileStreaks'] = true,
	['QuestLogPopupDetailFrameBotLeftCorner'] = true,
	['QuestLogPopupDetailFrameBotRightCorner'] = true,
	['QuestLogPopupDetailFrameBottomBorder'] = true,
	['QuestLogPopupDetailFrameLeftBorder'] = true,
	['QuestLogPopupDetailFrameRightBorder'] = true,
	['QuestLogPopupDetailFrameBtnCornerLeft'] = true,
	['QuestLogPopupDetailFrameBtnCornerRight'] = true,
	['QuestLogPopupDetailFrameButtonBottomBorder'] = true,
--	['QuestLogPopupDetailFrameBg'] = true,
}

local function Skin_QuestFrame()
	if not AleaUI.db.skins.enableAll then return end
	if not AleaUI.db.skins[varName] then return end

	_G['QuestFrame']:StripTextures()
	_G['QuestFrameInset']:StripTextures()
	_G['QuestProgressScrollFrame']:StripTextures()
	_G['QuestDetailScrollFrame']:StripTextures()
	_G['QuestRewardScrollFrame']:StripTextures()
	_G['QuestNPCModel']:StripTextures()
	_G['GossipFrameBg']:SetAlpha(0)
	_G['GossipFrameInset']:StripTextures()
	_G['GossipGreetingScrollFrame']:StripTextures()
	_G['QuestGreetingScrollFrame']:StripTextures()
	_G['QuestNPCModelTextFrame']:StripTextures()

	for i=1, _G['GossipFrame']:GetNumRegions() do
		local region = select(i, _G['GossipFrame']:GetRegions())
		if region and region:GetObjectType() == "Texture" then
			if region:GetName() and region:GetName() == 'GossipFrameBg' then
				
			elseif region:GetName() and region:GetName():find('Material') then
			
			elseif region:GetTexture() ~= "Interface\\QuestFrame\\QuestBG" then
				region:SetTexture(nil)
			end
		end
	end
	
	for i=1, _G['QuestLogPopupDetailFrame']:GetNumRegions() do
		local region = select(i, _G['QuestLogPopupDetailFrame']:GetRegions())
		if region and region:GetObjectType() == "Texture" then
			if region:GetName() and region:GetName() == 'QuestLogPopupDetailFrameBg' then
				
			elseif region:GetName() and region:GetName():find('Material') then
			
			elseif region:GetTexture() ~= "Interface\\QuestFrame\\QuestBG" then
				region:SetTexture(nil)
			end
		end
	end
	
	
	_G['QuestLogPopupDetailFrameInset']:StripTextures()

	QuestNPCModel:SetPoint("TOPLEFT", QuestLogDetailFrame, "TOPRIGHT", 4, -34)
	hooksecurefunc("QuestFrame_ShowQuestPortrait", function(parentFrame, portraitDisplayID, mountPortraitDisplayID, text, name, x, y)
		QuestNPCModel:ClearAllPoints();
		QuestNPCModel:SetPoint("TOPLEFT", parentFrame, "TOPRIGHT", x + 8, y);
	end)
		
	Skins.ThemeBackdrop('QuestFrame')
	Skins.ThemeBackdrop('GossipFrame')
	Skins.ThemeBackdrop('QuestFrameInset')
	Skins.ThemeBackdrop('QuestNPCModel')
	Skins.ThemeBackdrop('GossipFrameInset')
	Skins.ThemeBackdrop('QuestLogPopupDetailFrame')
	Skins.ThemeBackdrop('QuestLogPopupDetailFrameInset')
	Skins.ThemeBackdrop('QuestNPCModelTextFrame')
	Skins.ThemeFrameRing('GossipFrame')
	Skins.ThemeFrameRing('QuestFrame')

	local temp = CreateFrame("Frame", nil, QuestNPCModel)
	temp:SetPoint('TOPLEFT', QuestNPCModel, 'BOTTOMLEFT', 0, 0)
	temp:SetPoint('TOPRIGHT', QuestNPCModel, 'BOTTOMRIGHT', 0, 0)
	temp:SetSize(20,20)
	temp:SetFrameStrata('LOW')
	Skins.ThemeBackdrop(temp)

	temp:SetUIBackgroundDrawLayer('BORDER', -1)

	_G['QuestNPCModelNameText']:SetFont(default_font, Skins.default_font_size)
	_G['QuestNPCModelNameText']:SetDrawLayer('OVERLAY')

	Skins.ThemeScrollBar('QuestProgressScrollFrameScrollBar')
	Skins.ThemeScrollBar('QuestDetailScrollFrameScrollBar')
	Skins.ThemeScrollBar('QuestRewardScrollFrameScrollBar')
	Skins.ThemeScrollBar('GossipGreetingScrollFrameScrollBar')
	Skins.ThemeScrollBar('QuestGreetingScrollFrameScrollBar')

	local initSkin = true

	hooksecurefunc('QuestLogPopupDetailFrame_Update', function()
		if initSkin and QuestLogPopupDetailFrame.ScrollFrame.ScrollBar then
			--QuestLogPopupDetailScrollFrameScrollBar		
			initSkin = false
			QuestLogPopupDetailFrame.ScrollFrame:StripTextures()	
			Skins.ThemeScrollBar(QuestLogPopupDetailFrame.ScrollFrame.ScrollBar)
		end
	end)

	Skins.ThemeButton('QuestLogPopupDetailFrameAbandonButton')
	Skins.ThemeButton('QuestLogPopupDetailFrameShareButton')
	Skins.ThemeButton('QuestLogPopupDetailFrameTrackButton')

	Skins.ThemeButton('QuestFrameCompleteButton')
	Skins.ThemeButton('QuestFrameGoodbyeButton')
	Skins.ThemeButton('QuestFrameGreetingGoodbyeButton')
	Skins.ThemeButton('QuestFrameAcceptButton')
	Skins.ThemeButton('QuestFrameDeclineButton')
	Skins.ThemeButton('QuestFrameCompleteQuestButton')
	Skins.ThemeButton('GossipFrameGreetingGoodbyeButton')
	
	if QuestFrameDetailPanel.IgnoreButton then
		Skins.ThemeButton(QuestFrameDetailPanel.IgnoreButton)
	end
	if QuestFrameProgressPanel.IgnoreButton then
		Skins.ThemeButton(QuestFrameProgressPanel.IgnoreButton)
	end
	
	QuestInfoItemHighlight:StripTextures()
	AleaUI:CreateBackdrop(QuestInfoItemHighlight, QuestInfoItemHighlight, {1, 1, 0, 1 }, { 0, 0, 0, 0 })
	QuestInfoItemHighlight:SetUIBackdropBorderColor(1, 1, 0)
	QuestInfoItemHighlight:SetUIBackgroundColor(0, 0, 0, 0)
	QuestInfoItemHighlight:SetSize(142, 40)

	hooksecurefunc("QuestInfoItem_OnClick", function(self)
		QuestInfoItemHighlight:ClearAllPoints()
		QuestInfoItemHighlight:SetOutside(self.Icon)
		
		QuestInfoItemHighlight.selecterItem = self
		self.Name:SetTextColor(1, 1, 0)

		local parent = self:GetParent()
		for i=1, #parent.RewardButtons do
			local questItem = QuestInfoRewardsFrame.RewardButtons[i]
			if(questItem ~= self) then
				questItem.Name:SetTextColor(1, 1, 1)
			end
		end
	end)

	do
		local function QuestInfoItemHighlight_handler(self)
			if self.selecterItem then
				self.selecterItem.Name:SetTextColor(1, 1, 1)
				self.selecterItem = nil
			end
		end
		
		QuestInfoItemHighlight:HookScript('OnShow', QuestInfoItemHighlight_handler)	
		QuestInfoItemHighlight:HookScript('OnHide', QuestInfoItemHighlight_handler)	
	end

	--01:27:00 T SetTexture Interface\ContainerFrame\UI-Icon-QuestBang Interface\ContainerFrame\UI-Icon-QuestBang

	for i=1, 6 do
		Skins.ThemeQuestItem('QuestProgressItem'..i)
	end

	local hookedFrames = {}

	local function ScanForNewItemRewards()
		local i = 1
		while true do
			local name =  'QuestInfoRewardsFrameQuestInfoItem'..i
			
			if not _G[name] then return end
			if not hookedFrames[name] then
				hookedFrames[name] = true
				Skins.ThemeQuestItem(name)
			end
			
			i= i+1
		end	
	end

	_G['QuestFrame']:HookScript('OnShow', ScanForNewItemRewards)
	_G['QuestInfoRewardsFrame']:HookScript('OnShow', ScanForNewItemRewards)

	AleaUI:OnAddonLoad('Blizzard_QuestChoice', function()

		if WarboardQuestChoiceFrameOption1 then
			Skins.ThemeButton(WarboardQuestChoiceFrameOption1.OptionButtonsContainer.OptionButton)
		end

		if WarboardQuestChoiceFrameOption2 then
			Skins.ThemeButton(WarboardQuestChoiceFrameOption2.OptionButtonsContainer.OptionButton)
		end

	--	print('T', QuestChoiceFrameOption3.OptionButton,QuestChoiceFrameOption4.OptionButton)
		
		if WarboardQuestChoiceFrameOption3 then
			Skins.ThemeButton(WarboardQuestChoiceFrameOption3.OptionButtonsContainer.OptionButton)
		end
		if WarboardQuestChoiceFrameOption4 then
			Skins.ThemeButton(WarboardQuestChoiceFrameOption4.OptionButtonsContainer.OptionButton)
		end
	end)

end

AleaUI:OnInit2(Skin_QuestFrame)