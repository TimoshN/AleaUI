local E = AleaUI
local OT = E:Module("ObjectivesTracker")
local Skins = E:Module("Skins")

local oldW = nil
local oldH = nil
	
local defaultHeight = math.max(300, E.screenheight*0.6) -- Высота
local defaultWidth = math.max(243, E.screenwidth*0.12)	 -- Ширина

local minWidth =  defaultWidth
local minHeight = defaultHeight*0.7

local maxWidth = defaultWidth*1.5
local maxHeight = defaultHeight*1.3
	
local defaults = {
	classColor = true,
	personalColor = false,
	color = { 0.8, 0.8, 0.2, 1 },
	
	setResizable = true,
	
	width = defaultWidth,
	height = defaultHeight,
	
	widthSize = 1,
	heightSize = 1,
	hideOnBossFights = true,
	hideOnBGorArena = true,
}

E.default_settings.objectFrame = defaults

local status = false

local WatchFrameHolder = CreateFrame("Frame", "WatchFrameHolder", E.UIParent)
WatchFrameHolder:SetWidth(130)
WatchFrameHolder:SetHeight(22)
WatchFrameHolder:Show()
WatchFrameHolder:SetClampedToScreen(true)

local WatchFrameUpdater = CreateFrame("Frame", "WatchFrameUpdater", E.UIParent)
WatchFrameUpdater:Show()
WatchFrameUpdater:SetScript('OnUpdate', function(self, elapsed)
	self.elapsed = ( self.elapsed or 0 ) + elapsed
	if self.elapsed < 1 then return end
	self.elapsed = 0
	local show = true

	if show and E.db.objectFrame.hideOnBossFights then
		for i=1, 5 do
			local unit = 'boss'..i		
			if UnitExists(unit) then
				WatchFrameHolder:Hide()
				show = false
				break
			end
		end
	end
	if show and E.db.objectFrame.hideOnBGorArena then
		for i=1, 5 do
			local unit = 'arena'..i		
			if UnitExists(unit) then
				WatchFrameHolder:Hide()
				show = false
				break
			end
		end	
	end
	
	if show and not WatchFrameHolder:IsShown() then
		WatchFrameHolder:Show()
	end
end)

local headerList = { 
	["QuestHeader"] = true,
	["AchievementHeader"] = true,
	["ScenarioHeader"] = true,
}

	
	--[==[
	SCENARIO_CONTENT_TRACKER_MODULE,
	AUTO_QUEST_POPUP_TRACKER_MODULE,
	QUEST_TRACKER_MODULE,
	BONUS_OBJECTIVE_TRACKER_MODULE,
	WORLD_QUEST_TRACKER_MODULE,
	ACHIEVEMENT_TRACKER_MODULE
					]==]	

	--[==[
		local currentMapId = C_ChallengeMode.GetActiveChallengeMapID();
		local zoneName, _, maxTime = C_ChallengeMode.GetMapInfo(currentMapId);
		
		-- Chest Timer
		local threeChestTime = maxTime * 0.6;
		local twoChestTime = maxTime * 0.8;

		local timeLeft3 = threeChestTime - timeCM;
		if timeLeft3 < 0 then
			timeLeft3 = 0;
		end

		local timeLeft2 = twoChestTime - timeCM;
		if timeLeft2 < 0 then
			timeLeft2 = 0;
		end
	]==]

local function Load()
		
	ObjectiveTrackerFrame:SetClampedToScreen(true)
	ObjectiveTrackerFrame:SetResizable(true)
	ObjectiveTrackerFrame:SetUserPlaced(true)
	ObjectiveTrackerFrame:SetMaxResize(maxWidth, maxHeight)
	ObjectiveTrackerFrame:SetMinResize(minWidth, minHeight)
		

	E:Mover(WatchFrameHolder, "watchFrameMover")
	
	
	
	ScenarioChallengeModeBlock:StripTextures()
	ScenarioChallengeModeBlock.StatusBar:SetStatusBarTexture([[Interface\AddOns\AleaUI\media\Minimalist.tga]])
	ScenarioChallengeModeBlock.Level:SetFont(STANDARD_TEXT_FONT, 14, 'NONE')
	E:SecureCreateBackdrop(ScenarioChallengeModeBlock.StatusBar, nil, {}, { 0, 0, 0, 1 }, { 0.2,0.2,0.7,0.4 }):SetUIBackgroundDrawLayer('BACKGROUND', -1)
	
	ScenarioChallengeModeBlock.StatusBar:SetStatusBarColor( 0.5, 0.5, 1, 1 )
	
	local sbwidth = ScenarioChallengeModeBlock.StatusBar:GetWidth()

	local sivlerwidth = sbwidth*0.4
	local copperrwidth = sbwidth*0.2
	
	
	
	--[==[
	ScenarioChallengeModeBlock.StatusBar.copper = ScenarioChallengeModeBlock.StatusBar:CreateTexture(nil, 'OVERLAY')
	ScenarioChallengeModeBlock.StatusBar.copper:SetPoint('TOPLEFT', ScenarioChallengeModeBlock.StatusBar, 'TOPLEFT', copperrwidth, 0)
	ScenarioChallengeModeBlock.StatusBar.copper:SetPoint('BOTTOMLEFT', ScenarioChallengeModeBlock.StatusBar, 'BOTTOMLEFT', copperrwidth, 0)
	ScenarioChallengeModeBlock.StatusBar.copper:SetWidth(2)
	ScenarioChallengeModeBlock.StatusBar.copper:SetColorTexture(184/255, 115/255, 51/255, 1)
	]==]
	
	ScenarioChallengeModeBlock.StatusBar.silver = ScenarioChallengeModeBlock.StatusBar:CreateTexture(nil, 'OVERLAY')
	ScenarioChallengeModeBlock.StatusBar.silver:SetPoint('TOPLEFT', ScenarioChallengeModeBlock.StatusBar, 'TOPLEFT', copperrwidth, 0)
	ScenarioChallengeModeBlock.StatusBar.silver:SetPoint('BOTTOMLEFT', ScenarioChallengeModeBlock.StatusBar, 'BOTTOMLEFT', copperrwidth, 0)
	ScenarioChallengeModeBlock.StatusBar.silver:SetWidth(2)
	ScenarioChallengeModeBlock.StatusBar.silver:SetColorTexture(192/255, 192/255, 192/255, 1)
	
	ScenarioChallengeModeBlock.StatusBar.gold = ScenarioChallengeModeBlock.StatusBar:CreateTexture(nil, 'OVERLAY')
	ScenarioChallengeModeBlock.StatusBar.gold:SetPoint('TOPLEFT', ScenarioChallengeModeBlock.StatusBar, 'TOPLEFT', sivlerwidth, 0)
	ScenarioChallengeModeBlock.StatusBar.gold:SetPoint('BOTTOMLEFT', ScenarioChallengeModeBlock.StatusBar, 'BOTTOMLEFT', sivlerwidth, 0)
	ScenarioChallengeModeBlock.StatusBar.gold:SetWidth(2)
	ScenarioChallengeModeBlock.StatusBar.gold:SetColorTexture(255/255, 215/255, 0, 1)
	
	
	ScenarioChallengeModeBlock.TimeLeftOther1 = ScenarioChallengeModeBlock:CreateFontString(nil, 'ARTWORK')
	ScenarioChallengeModeBlock.TimeLeftOther1:SetFont(STANDARD_TEXT_FONT, 14, 'OUTLINE')
	ScenarioChallengeModeBlock.TimeLeftOther1:SetPoint('TOP', ScenarioChallengeModeBlock.StatusBar.silver, 'BOTTOM', 0, -2)
	ScenarioChallengeModeBlock.TimeLeftOther1:SetJustifyH('LEFT')
	ScenarioChallengeModeBlock.TimeLeftOther1:SetShadowColor(0,0,0,1)
	
	ScenarioChallengeModeBlock.TimeLeftOther2 = ScenarioChallengeModeBlock:CreateFontString(nil, 'ARTWORK')
	ScenarioChallengeModeBlock.TimeLeftOther2:SetFont(STANDARD_TEXT_FONT, 14, 'OUTLINE')
	ScenarioChallengeModeBlock.TimeLeftOther2:SetPoint('TOP', ScenarioChallengeModeBlock.StatusBar.gold, 'BOTTOM', 0, -2)
	ScenarioChallengeModeBlock.TimeLeftOther2:SetJustifyH('RIGHT')
	ScenarioChallengeModeBlock.TimeLeftOther2:SetShadowColor(0,0,0,1)
	
	hooksecurefunc('Scenario_ChallengeMode_ShowBlock', function(timerID, elapsedTime, timeLimit)
		ScenarioChallengeModeBlock.TimeLeftOther1:SetText( '|cffc0c0c0'..SecondsToClock(timeLimit*0.2)..'|r' )
		ScenarioChallengeModeBlock.TimeLeftOther2:SetText( '|cffffd700'..SecondsToClock(timeLimit*0.4)..'|r' )
	end)
	
	--[==[
	
		 -- Chest Timer
		local threeChestTime = maxTime * 0.6;
		local twoChestTime = maxTime * 0.8;
		
		
		60 - 3 chest -- 40
		80 - 2 chest -- 20
		100 - 1 chest -- 40
		
	]==]
	
--	ObjectiveTrackerFrame.HeaderMenu.MinimizeButton:SetScale(1.6)
	ObjectiveTrackerFrame.HeaderMenu.MinimizeButton:StripTextures()
	ObjectiveTrackerFrame.HeaderMenu.MinimizeButton:StyleButton()
	
	local miniMizeButtonBackground = ObjectiveTrackerFrame.HeaderMenu.MinimizeButton:CreateTexture(nil, 'OVERLAY')
	miniMizeButtonBackground:SetColorTexture(0,0,0,1)
	miniMizeButtonBackground:SetAllPoints()
	
	local miniMizeButtonBackground = ObjectiveTrackerFrame.HeaderMenu.MinimizeButton:CreateFontString(nil, 'OVERLAY')
	miniMizeButtonBackground:SetFontObject(GameFontWhite)
	miniMizeButtonBackground:SetPoint('CENTER', ObjectiveTrackerFrame.HeaderMenu.MinimizeButton, 'CENTER', 0, -1)
	miniMizeButtonBackground:SetText('-')
	miniMizeButtonBackground:SetFont(STANDARD_TEXT_FONT, 20, 'NONE')
	
	local function UpdateMiniMizeButtonStatus()
		if ObjectiveTrackerFrame.collapsed then
			miniMizeButtonBackground:SetText('+')
		else
			miniMizeButtonBackground:SetText('-')
		end
	end
	
	hooksecurefunc('ObjectiveTracker_Collapse', UpdateMiniMizeButtonStatus)
	hooksecurefunc('ObjectiveTracker_Expand', UpdateMiniMizeButtonStatus)
	
	UpdateMiniMizeButtonStatus()
	
	ObjectiveTrackerFrame:SetFrameStrata('LOW')
	ObjectiveTrackerFrame:SetParent(WatchFrameHolder)
	ObjectiveTrackerFrame:ClearAllPoints()
	ObjectiveTrackerFrame:SetPoint('TOPRIGHT', WatchFrameHolder, 'TOPRIGHT', 0, 0)
	ObjectiveTrackerFrame.bg = ObjectiveTrackerFrame:CreateTexture(nil, "BACKGROUND", nil, 1)
	ObjectiveTrackerFrame.bg:SetPoint("TOPRIGHT", ObjectiveTrackerFrame, "TOPRIGHT", 5, 0)
	ObjectiveTrackerFrame.bg:SetPoint("BOTTOMLEFT", ObjectiveTrackerFrame, "BOTTOMLEFT", -30, -10)
	ObjectiveTrackerFrame.bg:SetColorTexture(1,1,1,0.2)	
	ObjectiveTrackerFrame.bg:Hide()
		
	ObjectiveTrackerBlocksFrame:SetFrameStrata('LOW')
		
	hooksecurefunc(ObjectiveTrackerFrame,"SetPoint",function(_,_,parent)
		if parent ~= WatchFrameHolder then
			ObjectiveTrackerFrame:ClearAllPoints()
			ObjectiveTrackerFrame:SetPoint('TOPRIGHT', WatchFrameHolder, 'TOPRIGHT', 0, 0)
		end
	end)
	hooksecurefunc(ObjectiveTrackerFrame,"SetParent",function(_,parent)
		if parent ~= WatchFrameHolder then
			ObjectiveTrackerFrame:SetParent(WatchFrameHolder)
		end
	end)
	
	local sizing = CreateFrame("Frame", nil, E.UIParent)
		sizing:SetSize(18, 18)
		sizing.isMouseDown = false
		sizing:SetMovable(true)
		sizing:SetFrameLevel(15)
		sizing:RegisterForDrag("LeftButton")
		sizing:SetPoint("BOTTOMLEFT", ObjectiveTrackerFrame, "BOTTOMLEFT", -30, -10)
		sizing:SetScript("OnDragStart", function(self)
			ObjectiveTrackerFrame:StartSizing("BOTTOMLEFT")
		end)
		sizing:SetScript("OnDragStop", function(self)
			ObjectiveTrackerFrame:StopMovingOrSizing() 
			ObjectiveTrackerFrame.bg:Hide()
			
			OT.SaveObjectTrackerSize()		
			
			self.isMouseDown = false
			self.bg:SetTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up") --0.4, 0.4, 0.4, 1)
		end)
		sizing:SetScript("OnEnter", function(self)
			ObjectiveTrackerFrame.bg:Show()
			self.bg:SetTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight") --0.4, 0.4, 0.4, 0.8)
		end)
		sizing:SetScript("OnLeave", function(self)
			if not self.isMouseDown then
				ObjectiveTrackerFrame.bg:Hide()
				self.bg:SetTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up") --0.4, 0.4, 0.4, 0.4)
			end
		end)
		sizing:SetScript("OnMouseUp", function(self)
			self.isMouseDown = false
			ObjectiveTrackerFrame.bg:Hide()
			self.bg:SetTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up") --0.4, 0.4, 0.4, 1)
		end)
		sizing:SetScript("OnMouseDown", function(self)
			self.isMouseDown = true
			self.bg:SetTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down") --0.4, 0.4, 0.4, 0.8)
		end)

		local sizing_bg = sizing:CreateTexture(nil, "BACKGROUND", nil, 1)
		sizing_bg:SetAllPoints()
		sizing_bg:SetTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up") --0.4, 0.4, 0.4, 0.4)	
		sizing.bg = sizing_bg
		E.SetTextureRotation(sizing.bg, 270)
		
	function OT.UpdateObjectTrackerSize()
		local temp1 = math.max(minWidth, math.min((defaultWidth*E.db.objectFrame.widthSize), maxWidth))
		local temp2 = math.max(minHeight, math.min((defaultHeight*E.db.objectFrame.heightSize), maxHeight))
	
		oldW = ceil(temp1)
		oldH = ceil(temp2)
		
		E.db.objectFrame.widthSize = oldW/defaultWidth
		E.db.objectFrame.heightSize = oldH/defaultHeight
	
		E.db.objectFrame.width = oldW
		E.db.objectFrame.height = oldH
		
		ObjectiveTrackerFrame:SetWidth(oldW)
		ObjectiveTrackerFrame:SetHeight(oldH)
		
	--	print('UpdateObjectTrackerSize', E.db.objectFrame.widthSize,  E.db.objectFrame.heightSize, E.db.objectFrame.width, E.db.objectFrame.height)
		if E.db.objectFrame.setResizable then
			sizing:Show()
		else
			sizing:Hide()
		end
	end
	
	OT.UpdateObjectTrackerSize()
	
	function OT.SaveObjectTrackerSize()		
		local width = ObjectiveTrackerFrame:GetWidth()
		local height = ObjectiveTrackerFrame:GetHeight()
		
		E.db.objectFrame.widthSize = width/defaultWidth
		E.db.objectFrame.heightSize = height/defaultHeight
	
		E.db.objectFrame.width = width
		E.db.objectFrame.height = height
	end
	
	ObjectiveTrackerFrame:HookScript('OnSizeChanged', function(self, w, h)	
		w = ceil(w)
		h = ceil(h)
		
		if oldW ~= w or oldH ~= h then
			oldW = w
			oldH = h
			
		--	print('OnSizeChanged', E.db.objectFrame.widthSize, E.db.objectFrame.heightSize, E.db.objectFrame.width, E.db.objectFrame.height)
			OT:UpdateUsedBlocksWidth('OnSizeChanged')
		else
		--	print('OnSizeChanged', 'Skip changes')
		end
	end)
	
	local function QuestItemButtonSkin(self)
		
		self:SetFrameLevel(10)
		self.HotKey:SetFont(E.media.default_font2, 18, 'OUTLINE')
		self.HotKey:SetText('x')
		
		self:SetNormalTexture(nil)
		self:SetPushedTexture(nil)
		
		self.icon:SetTexCoord(0.07, 0.93,  0.07, 0.93)
		self.icon:SetDrawLayer("OVERLAY")
		
		if not self._texture then
			self._texture = self:CreateTexture()
			self._texture:SetAllPoints(self)
			self._texture:SetDrawLayer("OVERLAY")
			self._texture:SetColorTexture(1, 1, 1, 0.3)
			
			self:SetHighlightTexture(self._texture)
		end
		
		if not self._bg then
			self._bg = self:CreateTexture()
			self._bg:SetOutside(self)
			self._bg:SetDrawLayer("BACKGROUND")
			self._bg:SetColorTexture(0, 0, 0, 1)
		end
	
		E:RegisterCooldown(self.Cooldown)
	end
	
	hooksecurefunc('QuestObjectiveItem_OnShow', QuestItemButtonSkin)
	hooksecurefunc('QuestObjectiveItem_OnHide', QuestItemButtonSkin)
	
	function OT:UpdateStyle()	
		local statusBar = self.Bar
		local IconBG 	= statusBar.IconBG
		local Icon		= statusBar.Icon
		local BarFrame 	= statusBar.BarFrame
		local BarFrame2 = statusBar.BarFrame2
		local BarFrame3 = statusBar.BarFrame3
		local BarBG		= statusBar.BarBG -- background
		local BorderLeft 	= statusBar.BorderLeft
		local BorderMid		= statusBar.BorderMid
		local BorderRight 	= statusBar.BorderRight
		
		if IconBG then
			IconBG:SetParent(E.hidenframe); IconBG:SetAlpha(0);
		end
		if BarFrame then
			BarFrame:SetParent(E.hidenframe); BarFrame:SetAlpha(0);
		end
		if BarFrame2 then
			BarFrame2:SetParent(E.hidenframe); BarFrame2:SetAlpha(0);
		end
		if BarFrame3 then
			BarFrame3:SetParent(E.hidenframe); BarFrame3:SetAlpha(0);
		end
		if BorderLeft then
			BorderLeft:SetParent(E.hidenframe); BorderLeft:SetAlpha(0);
		end
		if BorderMid then
			BorderMid:SetParent(E.hidenframe); BorderMid:SetAlpha(0);
		end
		if BorderRight then
			BorderRight:SetParent(E.hidenframe); BorderRight:SetAlpha(0);
		end
			
		statusBar:SetStatusBarTexture([[Interface\AddOns\AleaUI\media\Minimalist.tga]])
	
		if BarBG then
			BarBG:SetTexture([[Interface\AddOns\AleaUI\media\Minimalist.tga]])
			BarBG:SetVertexColor(32/255, 61/255, 116/255, 0.7)
		end
	end
	
	local function UpdateBarBGVertexColor(self, r, g, b, a)
		if r ~= 32/255 or g ~= 61/255 or b ~= 116/255 or a ~= 0.7 then
			self:SetVertexColor(32/255, 61/255, 116/255, 0.7)
		end
	end
	
	function OT:ThemeBar(progressBar, themeType)	
		local statusBar = progressBar.Bar
		local IconBG 	= statusBar.IconBG
		local Icon		= statusBar.Icon
		local BarFrame 	= statusBar.BarFrame
		local BarFrame2 = statusBar.BarFrame2
		local BarFrame3 = statusBar.BarFrame3
		local BarBG		= statusBar.BarBG -- background
		local BorderLeft 	= statusBar.BorderLeft
		local BorderMid		= statusBar.BorderMid
		local BorderRight 	= statusBar.BorderRight
			
		if not progressBar.skinned then
			progressBar.skinned = true
			statusBar:StripTextures()
			
			progressBar.themeType = themeType
			
			if IconBG then
				IconBG:SetParent(E.hidenframe); IconBG:SetAlpha(0);
			end
			if BarFrame then
				BarFrame:SetParent(E.hidenframe); BarFrame:SetAlpha(0);
			end
			if BarFrame2 then
				BarFrame2:SetParent(E.hidenframe); BarFrame2:SetAlpha(0);
			end
			if BarFrame3 then
				BarFrame3:SetParent(E.hidenframe); BarFrame3:SetAlpha(0);
			end			
			if BorderLeft then
				BorderLeft:SetParent(E.hidenframe); BorderLeft:SetAlpha(0);
			end
			if BorderMid then
				BorderMid:SetParent(E.hidenframe); BorderMid:SetAlpha(0);
			end
			if BorderRight then
				BorderRight:SetParent(E.hidenframe); BorderRight:SetAlpha(0);
			end
			
			
			statusBar:SetStatusBarTexture([[Interface\AddOns\AleaUI\media\Minimalist.tga]])
			if BarBG then
				BarBG:SetTexture([[Interface\AddOns\AleaUI\media\Minimalist.tga]])		
				BarBG:SetVertexColor(32/255, 61/255, 116/255, 0.7)
				hooksecurefunc(BarBG, 'SetVertexColor', UpdateBarBGVertexColor)			
			--	E:CreateBackdrop(statusBar, BarBG, { 0, 0, 0, 1 }, { 0, 0, 0, 0 }) --, background, size,step)	
				E:SecureCreateBackdrop(statusBar, BarBG, {}, { 0, 0, 0, 1 }, { 0, 0, 0, 0 })				
			end
			
			if progressBar.Bar.Icon then
			--	E:CreateBackdrop(progressBar, progressBar.Bar.Icon, { 0, 0, 0, 1 }, { 0, 0, 0, 0 }) --, background, size,step)				
				E:SecureCreateBackdrop(progressBar, progressBar.Bar.Icon, {}, { 0, 0, 0, 1 }, { 0, 0, 0, 0 })
			end
			if BorderLeft then
				E:SecureCreateBackdrop(statusBar, nil, {}, { 0, 0, 0, 1 }, { 21/255, 40/255, 76/255, 0.7 }):SetUIBackgroundDrawLayer('BACKGROUND', -1)
			end
			
			if statusBar.Starburst then
				statusBar.Starburst:SetParent(E.hidenframe); statusBar.Starburst:SetAlpha(0);
			end
			
			if statusBar.BarGlow then
				statusBar.BarGlow:SetParent(E.hidenframe); statusBar.BarGlow:SetAlpha(0);
			end
			
			if statusBar.Sheen then
				statusBar.Sheen:SetParent(E.hidenframe); statusBar.Sheen:SetAlpha(0);
			end
			
			if progressBar.Flare1 then progressBar.Flare1:SetParent(E.hidenframe);progressBar.Flare1:SetAlpha(0); end
			if progressBar.Flare2 then progressBar.Flare2:SetParent(E.hidenframe);progressBar.Flare2:SetAlpha(0); end
			if progressBar.SmallFlare1 then progressBar.SmallFlare1:SetParent(E.hidenframe);progressBar.SmallFlare1:SetAlpha(0); end
			if progressBar.SmallFlare2 then progressBar.SmallFlare2:SetParent(E.hidenframe);progressBar.SmallFlare2:SetAlpha(0); end
			if progressBar.FullBarFlare1 then progressBar.FullBarFlare1:SetParent(E.hidenframe);progressBar.FullBarFlare1:SetAlpha(0); end
			if progressBar.FullBarFlare2 then progressBar.FullBarFlare2:SetParent(E.hidenframe);progressBar.FullBarFlare2:SetAlpha(0); end
			
			progressBar:HookScript('OnShow', OT.UpdateStyle)
		end
		
	--	print('T', 'ThemeBar', themeType, progressBar.themeType)
	
		OT.UpdateStyle(progressBar)
	end
	
	ObjectiveTrackerFrame.HeaderMenu.Title:SetFont(E.media.default_font, 12,'NONE')
	ObjectiveTrackerFrame.HeaderMenu.Title:SetTextColor(1, 1, 1, 1)
	for frame in pairs(headerList) do
		ObjectiveTrackerBlocksFrame[frame]:StripTextures("ARTWORK")
		ObjectiveTrackerBlocksFrame[frame].Text:SetWordWrap(true)
		ObjectiveTrackerBlocksFrame[frame].Text:SetFont(E.media.default_font, 12,'NONE')
		ObjectiveTrackerBlocksFrame[frame].Text:SetTextColor(1, 1, 1, 1)
		ObjectiveTrackerBlocksFrame[frame]:SetFrameStrata('LOW')
	end
	
	BONUS_OBJECTIVE_TRACKER_MODULE.Header:StripTextures("ARTWORK")
	BONUS_OBJECTIVE_TRACKER_MODULE.Header.Text:SetWordWrap(true)
	BONUS_OBJECTIVE_TRACKER_MODULE.Header.Text:SetFont(E.media.default_font2, 14)
	BONUS_OBJECTIVE_TRACKER_MODULE.Header.Text:SetTextColor(1,1,1,1)
--	BONUS_OBJECTIVE_TRACKER_MODULE:SetFrameStrata('LOW')
	
	WORLD_QUEST_TRACKER_MODULE.Header:StripTextures("ARTWORK")
	WORLD_QUEST_TRACKER_MODULE.Header.Text:SetWordWrap(true)
	WORLD_QUEST_TRACKER_MODULE.Header.Text:SetFont(E.media.default_font2, 14)
	WORLD_QUEST_TRACKER_MODULE.Header.Text:SetTextColor(1,1,1,1)
--	WORLD_QUEST_TRACKER_MODULE:SetFrameStrata('LOW')
	
	local baseAlpha = 0.6
	local function ThemeRewardItem_OnShow(self)
		self.bgIcon:SetAlpha(0)
		self.bgText:SetAlpha(0)
		self.bgIcon.alpha = -1
	end
	local function ThemeRewardItem_OnUpdate(self, elapsed)
		self.bgIcon.alpha = self.bgIcon.alpha + elapsed
		
		local a = self.bgIcon.alpha 
	
		if a < 1 and a > 0 then
			self.bgIcon:SetAlpha(baseAlpha*a)
			self.bgText:SetAlpha(baseAlpha*a)
		elseif a > 2 then
			self.bgIcon:SetAlpha(baseAlpha*(3-a))
			self.bgText:SetAlpha(baseAlpha*(3-a))
		elseif a > 1 then
			self.bgIcon:SetAlpha(baseAlpha)
			self.bgText:SetAlpha(baseAlpha)
		else
			self.bgIcon:SetAlpha(0)
			self.bgText:SetAlpha(0)
		end		
	end
	local function ThemeRewardItem_OnHide(self)
		self.bgIcon:SetAlpha(0)
		self.bgText:SetAlpha(0)
		self.bgIcon.alpha = 0
	end
	
	function OT:ThemeRewardItem()
	
		self.Count:SetFont(E.media.default_font2, 12, 'OUTLINE')
		self.Label:SetFont(E.media.default_font2, 12, 'OUTLINE')
		self.ItemIcon:SetTexCoord(unpack(E.media.texCoord))
		
		local parent = self:GetParent()
	
		if not self.bgIcon then
			local bgIcon = self:CreateTexture()
			bgIcon:SetColorTexture(0,0,0,1)
			bgIcon:SetOutside(self.ItemIcon)
			bgIcon:SetDrawLayer('BORDER', 0)
			
			self:HookScript('OnShow', ThemeRewardItem_OnShow)
			self:HookScript('OnHide', ThemeRewardItem_OnHide)
			self:HookScript('OnUpdate', ThemeRewardItem_OnUpdate)

			local bgText = self:CreateTexture()
			bgText:SetColorTexture(0,0,0,1)
			bgText:SetPoint('TOPLEFT', self.ItemIcon, 'TOPRIGHT', 3, 0)
			bgText:SetPoint('BOTTOMLEFT', self.ItemIcon, 'BOTTOMRIGHT', 3, 0)
			bgText:SetSize(76, 76)
			bgText:SetDrawLayer('BORDER', 0)
			
			self.bgText = bgText
			self.bgIcon = bgIcon
			
			ThemeRewardItem_OnShow(self)
		end
		
		self.ItemOverlay:SetShown(false)
		self.ItemBorder:SetShown(false)
	end
	
	hooksecurefunc('BonusObjectiveTracker_AnimateReward', function(block)
		local rewardsFrame = ObjectiveTrackerBonusRewardsFrame;
	--	rewardsFrame:StripTextures()
		for i=1, #rewardsFrame.Rewards do
			OT.ThemeRewardItem(rewardsFrame.Rewards[i])
		end
	end)
	
	hooksecurefunc('ScenarioObjectiveTracker_AnimateReward', function()
		local rewardsFrame = ObjectiveTrackerScenarioRewardsFrame;
	--	rewardsFrame:StripTextures()
		for i=1, #rewardsFrame.Rewards do
			OT.ThemeRewardItem(rewardsFrame.Rewards[i])
		end
	end)
	
	local colorGradient = { '|cFFFF0000', '|cFFFF7a00', '|cFFFFFF00', '|cFF008000' }
	
	local stringHooked = {}
	
	local listOfModules = {		 
		SCENARIO_CONTENT_TRACKER_MODULE,
		AUTO_QUEST_POPUP_TRACKER_MODULE,
		QUEST_TRACKER_MODULE,
		BONUS_OBJECTIVE_TRACKER_MODULE,
		WORLD_QUEST_TRACKER_MODULE,
		ACHIEVEMENT_TRACKER_MODULE	
	}
	
	local tempFrame = CreateFrame('Frame')
	
	function OT:UpdateUsedBlocksWidth(reason)		
	
	--	print('OT:UpdateUsedBlocksWidth', reason)
		
		for i=1, #listOfModules do		
			for id, frame in pairs( listOfModules[i].usedBlocks ) do	
				
				local mod = 0
				if WORLD_QUEST_TRACKER_MODULE == listOfModules[i] then
					mod = 22
				end
				
				if frame:GetWidth()+mod ~=  ObjectiveTrackerFrame:GetWidth()+mod then
					frame:SetWidth( ObjectiveTrackerFrame:GetWidth()+mod )
					--[==[
					if not frame.bg_test then
						local bg_test = frame:CreateTexture()
						bg_test:SetColorTexture(0,0,0,0.2)
						bg_test:SetOutside(frame)
						bg_test:SetDrawLayer('BORDER', 0)
						frame.bg_test = bg_test
					end
					]==]			
				end
			end	
		end
		
		for frame in pairs(stringHooked) do

			local mod = 0

			if OT.IsHeader(frame) then
				mod = -30
			end
			
		--	print('Point:', frame:GetPoint())
		--	print('Parent:', frame:GetParent())
			
			if frame:GetWidth() ~=  ObjectiveTrackerFrame:GetWidth()+mod then	
				frame:SetWidth( ObjectiveTrackerFrame:GetWidth()+mod )	
			
				frame._hooker:SetWidth( ObjectiveTrackerFrame:GetWidth()-40)

				
				--[==[
				if not frame.bg_test then
					local bg_test = tempFrame:CreateTexture()
					bg_test:SetColorTexture(1,0,0,0.2)
					bg_test:SetOutside(frame)
					bg_test:SetDrawLayer('BORDER', 0)
					frame.bg_test = bg_test
				end
				]==]
			end
		end
	end
	
	
	function OT:UpdateStringWidth()	
	--	OT:UpdateUsedBlocksWidth('OT:UpdateStringWidth')		
	end
	
	local listOfModulesName = {		 
		'SCENARIO_CONTENT_TRACKER_MODULE',
		'AUTO_QUEST_POPUP_TRACKER_MODULE',
		'QUEST_TRACKER_MODULE',
		'BONUS_OBJECTIVE_TRACKER_MODULE',
		'WORLD_QUEST_TRACKER_MODULE',
		'ACHIEVEMENT_TRACKER_MODULE' }
		
	local function FindBlockForString(line)
		-- DEFAULT_OBJECTIVE_TRACKER_MODULE
		local lineParent = line:GetParent()
	
		if lineParent.module then
			for i=1, #listOfModules do
				if lineParent.module == listOfModules[i] then
					return listOfModulesName[i]..'- from module', lineParent, listOfModules[i]
				end
			end
		end

		if ScenarioObjectiveBlock and ScenarioObjectiveBlock.lines then
			for k,v in pairs(ScenarioObjectiveBlock.lines) do					
				if v.Text == line then
					return 'ScenarioObjectiveBlock-lines', lineParent, ScenarioObjectiveBlock
				end
			end
		end
		
		for i=1, #listOfModules do
			local tModule = listOfModules[i]
			
			for k,v in pairs(tModule.usedBlocks) do					
				for a,b in pairs(v.lines) do
					if b.Text == line then
						return listOfModulesName[i]..'-usedBlocks', lineParent, listOfModules[i]
					elseif b == lineParent then
						return listOfModulesName[i]..'-usedBlocks-P', lineParent, listOfModules[i]
					end
				end
			end
			for k,v in pairs(tModule.freeBlocks) do					
				for a,b in pairs(v.lines) do
					if b.Text == line then
						return listOfModulesName[i]..'-freeBlocks', lineParent, listOfModules[i]
					elseif b == lineParent then
						return listOfModulesName[i]..'-freeBlocks-P', lineParent, listOfModules[i]
					end
				end
			end
			for a,b in pairs(tModule.freeLines) do					
				if b.Text == line then
					return listOfModulesName[i]..'-freeLines', lineParent, listOfModules[i]
				elseif b == lineParent then
					return listOfModulesName[i]..'-freeLines-P', lineParent, listOfModules[i]
				end
			end
		end
		
		local tModule = DEFAULT_OBJECTIVE_TRACKER_MODULE
			
		for k,v in pairs(tModule.usedBlocks) do					
			for a,b in pairs(v.lines) do
				if b.Text == line then
					return 'DEFAULT_OBJECTIVE_TRACKER_MODULE-usedBlocks', lineParent, DEFAULT_OBJECTIVE_TRACKER_MODULE
				elseif b == lineParent then
					return 'DEFAULT_OBJECTIVE_TRACKER_MODULE-usedBlocks-P', lineParent, DEFAULT_OBJECTIVE_TRACKER_MODULE
				end
			end
		end
		for k,v in pairs(tModule.freeBlocks) do					
			for a,b in pairs(v.lines) do
				if b.Text == line then
					return 'DEFAULT_OBJECTIVE_TRACKER_MODULE-freeBlocks', lineParent, DEFAULT_OBJECTIVE_TRACKER_MODULE
				elseif b == lineParent then
					return 'DEFAULT_OBJECTIVE_TRACKER_MODULE-freeBlocks-P', lineParent, DEFAULT_OBJECTIVE_TRACKER_MODULE
				end
			end
		end
		for a,b in pairs(tModule.freeLines) do					
			if b.Text == line then
				return 'DEFAULT_OBJECTIVE_TRACKER_MODULE-freeLines', lineParent, DEFAULT_OBJECTIVE_TRACKER_MODULE
			elseif b == lineParent then
				return 'DEFAULT_OBJECTIVE_TRACKER_MODULE-freeLines-P', lineParent, DEFAULT_OBJECTIVE_TRACKER_MODULE
			end
		end
		
		return false, lineParent, nil
	end
	
	local function HandlerForObjectiveString(self, text)
	
		if not text then 
		--	print('Suppress text change')
			C_Timer.After(1, function()
		--		print('Suppress text change check', self:GetText(), self:IsShown())
				HandlerForObjectiveString(self, self:GetText() or 'NULL')
			end)
			return 
		end
		
		if stringHooked[self] ~= text then
		--	print('Update text', stringHooked[self], '->', text)
			
			stringHooked[self] = text
		
			local a1, a2, a3, a4 = string.find(text, '(%d+)/(%d+)')
			
			self._hooker.testText:SetText(text)
			self._hooker.testText:SetWidth(0)

			local width = ObjectiveTrackerFrame:GetWidth()-40
			
			local numLines = ceil(self._hooker.testText:GetStringWidth()/width)

			local lineHeight = 14*numLines

			self._hooker:SetHeight(lineHeight)
			
			if a3 and a4 then
				local currentValue = tonumber(a3)
				local maxValue = tonumber(a4)
				
				if currentValue and maxValue then
					local percent = currentValue/maxValue
					
					local color = colorGradient[4]
					
					if percent < 0.4 then
						color = colorGradient[1]
					elseif percent < 0.7 then
						color = colorGradient[2]
					elseif percent < 1 then
						color = colorGradient[3]
				--	elseif percent < 0.8 then
				--		color = colorGradient[4]
					end
					
					local pattern = format('%d/%d', currentValue, maxValue)
				
					local tempText = text:gsub(pattern, color..pattern..'|r')
					
					stringHooked[self] = tempText
					
					self:SetText(tempText)

				--	print('T', percent, currentValue, maxValue, color, pattern, text)
				end
			end
			
			OT:UpdateUsedBlocksWidth('HandlerForObjectiveString')
		end
	end
	
	local colorWhite = 1
	local colorWhiteHighlight = 1.3
	local classR, classG, classB = RAID_CLASS_COLORS[E.myclass].r, RAID_CLASS_COLORS[E.myclass].g, RAID_CLASS_COLORS[E.myclass].b
	local classRH, classGH, classBH = RAID_CLASS_COLORS[E.myclass].r, RAID_CLASS_COLORS[E.myclass].g, RAID_CLASS_COLORS[E.myclass].b
	
	if E.myclass == 'PRIEST' then
		colorWhite = 0.7
		colorWhiteHighlight = 1
		
		classR = 120/255
		classG = 153/255
		classB = 243/255
		
		classRH, classGH, classBH = classR, classG, classB
	elseif E.myclass == 'SHAMAN' then
		colorWhite = 1.3
		colorWhiteHighlight = 1.6
	end
	--[==[
	OBJECTIVE_TRACKER_COLOR["Header"].r = classR*colorWhite
	OBJECTIVE_TRACKER_COLOR["Header"].g = classG*colorWhite
	OBJECTIVE_TRACKER_COLOR["Header"].b = classB*colorWhite
	
	OBJECTIVE_TRACKER_COLOR["HeaderHighlight"].r = classRH*colorWhiteHighlight
	OBJECTIVE_TRACKER_COLOR["HeaderHighlight"].g = classGH*colorWhiteHighlight
	OBJECTIVE_TRACKER_COLOR["HeaderHighlight"].b = classBH*colorWhiteHighlight
	]==]
	
	local customColorText = { Header = {}, HeaderHighlight = {} }
	
	local function floorColor(dig)	
		return tonumber(format('%.2f', dig))	
	end
	
	customColorText["Header"].r = floorColor(classR*colorWhite)
	customColorText["Header"].g = floorColor(classG*colorWhite)
	customColorText["Header"].b = floorColor(classB*colorWhite)
	
	customColorText["HeaderHighlight"].r = floorColor(classRH*colorWhiteHighlight)
	customColorText["HeaderHighlight"].g = floorColor(classGH*colorWhiteHighlight)
	customColorText["HeaderHighlight"].b = floorColor(classBH*colorWhiteHighlight)

	
	local function IsHeader(self)
		local r,g,b = self:GetTextColor()
		
		r = floorColor(r)
		g = floorColor(g)
		b = floorColor(b)
		
		
		
		return ( floorColor(OBJECTIVE_TRACKER_COLOR["Header"].r) == r and 
					floorColor(OBJECTIVE_TRACKER_COLOR["Header"].g) == g and	
					floorColor(OBJECTIVE_TRACKER_COLOR["Header"].b) == b ) or			
			   ( floorColor(OBJECTIVE_TRACKER_COLOR["HeaderHighlight"].r) == r and 
					floorColor(OBJECTIVE_TRACKER_COLOR["HeaderHighlight"].g) == g and 
					floorColor(OBJECTIVE_TRACKER_COLOR["HeaderHighlight"].b) == b ) or
				( customColorText["Header"].r == r and 
					customColorText["Header"].g == g and 
					customColorText["Header"].b == b ) or
				( customColorText["HeaderHighlight"].r == r and 
					customColorText["HeaderHighlight"].g == g and 
					customColorText["HeaderHighlight"].b == b )
	end
	
	OT.IsHeader = IsHeader
	
	local function UpdateCustomTextColor(self, r,g,b,a)
		r = floorColor(r)
		g = floorColor(g)
		b = floorColor(b)
		
		
		if floorColor(OBJECTIVE_TRACKER_COLOR["Header"].r) == r and
			floorColor(OBJECTIVE_TRACKER_COLOR["Header"].g) == g and
			floorColor(OBJECTIVE_TRACKER_COLOR["Header"].b) == b then
			
			self:SetTextColor(customColorText["Header"].r, customColorText["Header"].g,customColorText["Header"].b)
		elseif floorColor(OBJECTIVE_TRACKER_COLOR["HeaderHighlight"].r) == r and
			floorColor(OBJECTIVE_TRACKER_COLOR["HeaderHighlight"].g) == g and
			floorColor(OBJECTIVE_TRACKER_COLOR["HeaderHighlight"].b) == b then
			
			self:SetTextColor(customColorText["HeaderHighlight"].r, customColorText["HeaderHighlight"].g,customColorText["HeaderHighlight"].b)
		elseif ( OBJECTIVE_TRACKER_COLOR["Normal"].r == r and
				 OBJECTIVE_TRACKER_COLOR["Normal"].g == g and
				 OBJECTIVE_TRACKER_COLOR["Normal"].b == b ) then
				 
		--	self:SetTextColor(OBJECTIVE_TRACKER_COLOR["Normal"].r, OBJECTIVE_TRACKER_COLOR["Normal"].g,OBJECTIVE_TRACKER_COLOR["Normal"].b)
		elseif ( OBJECTIVE_TRACKER_COLOR["NormalHighlight"].r == r and
				 OBJECTIVE_TRACKER_COLOR["NormalHighlight"].g == g and
				 OBJECTIVE_TRACKER_COLOR["NormalHighlight"].b == b ) then
		
		--	self:SetTextColor(OBJECTIVE_TRACKER_COLOR["NormalHighlight"].r, OBJECTIVE_TRACKER_COLOR["NormalHighlight"].g,OBJECTIVE_TRACKER_COLOR["NormalHighlight"].b)
		end
	end
	
	local function UpdateCustomFont(self, font, size, outline)
	
		if IsHeader(self) then			
			if font ~= E.media.default_font2 and size ~= 14 and outline ~= 'NONE' then
				self:SetFont(E.media.default_font2, 14)	
				self:SetShadowColor(0,0,0,1)
				self:SetShadowOffset(1, -1)
				
				self._hooker.testText:SetFont(E.media.default_font2, 12)	
			end
			
			self:SetWordWrap(false)
		else
			if font ~= E.media.default_font2 and size ~= 12 and outline ~= 'NONE' then
				self:SetFont(E.media.default_font2, 12)	
				self:SetShadowColor(0,0,0,1)
				self:SetShadowOffset(1, -1)
		
				self._hooker.testText:SetFont(E.media.default_font2, 12)	
			end
			
			self:SetWordWrap(true)
		end
	end
	
	function OT:OnSetStringText(fontString, text, useFullHeight, colorStyle, useHighlight)
		if colorStyle == OBJECTIVE_TRACKER_COLOR["Header"] then
		--	fontString:SetFont(E.media.default_font2, 14, 'NONE')				
			UpdateCustomTextColor(fontString, OBJECTIVE_TRACKER_COLOR["Header"].r, OBJECTIVE_TRACKER_COLOR["Header"].g, OBJECTIVE_TRACKER_COLOR["Header"].b)
		else
		--	fontString:SetFont(E.media.default_font2, 12, 'NONE')
		end
		
	--	OT.UpdateStringWidth(fontString)
		
		if not stringHooked[fontString] then
			stringHooked[fontString] = true
			
			local hooker = CreateFrame('Frame', nil, ObjectiveTrackerFrame)
			
			fontString._hooker = hooker

			hooker:SetSize(100, 12)
			
			if not hooker.testText then
				
				local testText = hooker:CreateFontString()			
				hooker.testText = testText
				hooker.testText:SetFont(E.media.default_font2, 12)	
			--	hooker.testText:SetWidth(120)
			--	hooker.testText:SetWordWrap(true)
				hooker.testText:Hide()
			end
					
			
	--		hooksecurefunc(fontString, 'SetFont', UpdateCustomFont)		
			
			
			local result, parent, modulel = FindBlockForString(fontString)

			fontString.owner = parent
		
			
			if modulel == WORLD_QUEST_TRACKER_MODULE or modulel == BONUS_OBJECTIVE_TRACKER_MODULE then
				fontString.isWorldQuestTrackerString = true
			elseif modulel == ScenarioObjectiveBlock then
				fontString.isScenatiotTrackerString = true
			end

			local offset = 0
			if fontString.isWorldQuestTrackerString then
				offset = 24
			elseif fontString.isScenatiotTrackerString then
				offset = 12
			end
			
			if IsHeader(fontString) then
				hooker:SetPoint('TOPLEFT', fontString:GetParent(), 'TOPLEFT', offset+0, 0)
			else
				hooker:SetPoint('TOPLEFT', fontString:GetParent(), 'TOPLEFT', offset+8, 0)
			end
	
			fontString:ClearAllPoints()
			fontString:SetAllPoints(hooker)
			
			hooksecurefunc(fontString, 'SetTextColor', UpdateCustomTextColor)	
			hooksecurefunc(fontString, 'SetText', HandlerForObjectiveString)
	
			hooksecurefunc(fontString, 'SetPoint', function(self, point1, parent, point2, x, y)
				local offset = 0
				if self.isWorldQuestTrackerString then
					offset = 24
				elseif self.isScenatiotTrackerString then
					offset = 12
				end
				
				fontString:ClearAllPoints()
				fontString:SetAllPoints(self._hooker)
			
				if IsHeader(self) then
					self._hooker:SetPoint('TOPLEFT', parent, 'TOPLEFT', offset+0, 0)
				else
					self._hooker:SetPoint('TOPLEFT', parent, 'TOPLEFT', offset+8, 0)
				end
			end)
			
			if fontString.owner then
				fontString.owner:StripTextures()
				fontString.owner:HookScript('OnShow', function(self)

					local offset = 0
					if fontString.isWorldQuestTrackerString then
						offset = 24
					elseif fontString.isScenatiotTrackerString then
						offset = 12
					end
					
					fontString:ClearAllPoints()
					fontString:SetAllPoints(hooker)
				
					if IsHeader(fontString) then
						hooker:SetPoint('TOPLEFT', fontString:GetParent(), 'TOPLEFT', offset+0, 0)
					else
						hooker:SetPoint('TOPLEFT', fontString:GetParent(), 'TOPLEFT', offset+8, 0)
					end
				end)
			end
			
			HandlerForObjectiveString(fontString, fontString:GetText())
		end
	end
	
	hooksecurefunc(DEFAULT_OBJECTIVE_TRACKER_MODULE, 'SetStringText', OT.OnSetStringText)
	
	hooksecurefunc(SCENARIO_TRACKER_MODULE, 'AddProgressBar', function(self, block, line, criteriaIndex)
		local progressBar = self.usedProgressBars[block] and self.usedProgressBars[block][line]

		if progressBar then
			
			OT:ThemeBar(progressBar, 'Scenario')
	
			
			progressBar.Bar.Icon:Hide();
			progressBar.Bar.IconBG:Hide();

			E:SecureCreateBackdrop(progressBar, progressBar.Bar.Icon):SetUIBorderAlpha(0)
			
			if (not criteriaIndex) then
				local rewardQuestID = select(10, C_Scenario.GetStepInfo());

				if (rewardQuestID ~= 0) then
					-- reward icon; try the first item
					local name, texture = GetQuestLogRewardInfo(1, rewardQuestID);
					-- artifact xp
					local artifactXP, artifactCategory = GetQuestLogRewardArtifactXP(rewardQuestID);
					if ( not texture and artifactXP > 0 ) then
						local name, icon = C_ArtifactUI.GetArtifactXPRewardTargetInfo(artifactCategory);
						texture = icon or "Interface\\Icons\\INV_Misc_QuestionMark";
					end
					-- currency
					if ( not texture and GetNumQuestLogRewardCurrencies(rewardQuestID) > 0 ) then
						_, texture = GetQuestLogRewardCurrencyInfo(1, rewardQuestID);
					end
					-- money?
					if ( not texture and GetQuestLogRewardMoney(rewardQuestID) > 0 ) then
						texture = "Interface\\Icons\\inv_misc_coin_02";
					end
					-- xp
					if ( not texture and GetQuestLogRewardXP(rewardQuestID) > 0 and UnitLevel("player") < MAX_PLAYER_LEVEL ) then
						texture = "Interface\\Icons\\xp_icon";
					end
					
				--	print('SCENARIO_TRACKER_MODULE', 'AddProgressBar', texture, name)
					
					if ( texture ) then
						progressBar.Bar.Icon:SetTexture(texture);
						progressBar.Bar.Icon:Show();
						progressBar.Bar.IconBG:Show();
						E:SecureCreateBackdrop(progressBar, progressBar.Bar.Icon):SetUIBorderAlpha(1)
						progressBar.Bar.BarGlow:SetAtlas("bonusobjectives-bar-glow-ring", true);
					end
				end
			end
		end
	end)
	hooksecurefunc(DEFAULT_OBJECTIVE_TRACKER_MODULE, 'AddProgressBar', function(self, block, line, questID)
		local progressBar = self.usedProgressBars[block] and self.usedProgressBars[block][line]

		if progressBar then
			OT:ThemeBar(progressBar, 'Default')		
		end
	end)
	
	hooksecurefunc(BONUS_OBJECTIVE_TRACKER_MODULE, 'AddProgressBar', function(self, block, line, questID, finished)
		local progressBar = self.usedProgressBars[block] and self.usedProgressBars[block][line]

		if progressBar then
		
			OT:ThemeBar(progressBar, 'BONUS_OBJECT')
			local _, texture;
			-- reward icon; try the first item
			local name, texture = GetQuestLogRewardInfo(1, questID);
			-- artifact xp
			local artifactXP, artifactCategory = GetQuestLogRewardArtifactXP(questID);
			if ( not texture and artifactXP > 0 ) then
				local name, icon = C_ArtifactUI.GetArtifactXPRewardTargetInfo(artifactCategory);
				texture = icon or "Interface\\Icons\\INV_Misc_QuestionMark";
			end
			-- currency
			if ( not texture and GetNumQuestLogRewardCurrencies(questID) > 0 ) then
				_, texture = GetQuestLogRewardCurrencyInfo(1, questID);
			end
			-- money?
			if ( not texture and GetQuestLogRewardMoney(questID) > 0 ) then
				texture = "Interface\\Icons\\inv_misc_coin_02";
			end
			-- xp
			if ( not texture and GetQuestLogRewardXP(questID) > 0 and UnitLevel("player") < MAX_PLAYER_LEVEL ) then
				texture = "Interface\\Icons\\xp_icon";
			end

		--	print('BONUS_OBJECTIVE_TRACKER_MODULE', 'AddProgressBar', texture, name)
			
			if not texture then			
				E:SecureCreateBackdrop(progressBar, progressBar.Bar.Icon):SetUIBorderAlpha(0)
			else
				E:SecureCreateBackdrop(progressBar, progressBar.Bar.Icon):SetUIBorderAlpha(1)
				progressBar.Bar.Icon:SetSize(17, 17)
				progressBar.Bar.Icon:SetMask(nil)
				progressBar.Bar.Icon:SetTexture(texture)
				progressBar.Bar.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
				progressBar.Bar.Icon:ClearAllPoints()
				progressBar.Bar.Icon:SetPoint("TOPLEFT", progressBar.Bar.BarBG, "TOPRIGHT", 3, 0)
			end			
		end
	end)	
	
	hooksecurefunc(WORLD_QUEST_TRACKER_MODULE, 'AddProgressBar', function(self, block, line, questID, finished)
		local progressBar = self.usedProgressBars[block] and self.usedProgressBars[block][line]

		if progressBar then
		
			OT:ThemeBar(progressBar, 'WORLD')
			
			-- reward icon; try the first item
			local name, texture = GetQuestLogRewardInfo(1, questID);
			-- artifact xp
			local artifactXP, artifactCategory = GetQuestLogRewardArtifactXP(questID);
			if ( not texture and artifactXP > 0 ) then
				local name, icon = C_ArtifactUI.GetArtifactXPRewardTargetInfo(artifactCategory);
				texture = icon or "Interface\\Icons\\INV_Misc_QuestionMark";
			end
			-- currency
			if ( not texture and GetNumQuestLogRewardCurrencies(questID) > 0 ) then
				_, texture = GetQuestLogRewardCurrencyInfo(1, questID);
			end
			-- money?
			if ( not texture and GetQuestLogRewardMoney(questID) > 0 ) then
				texture = "Interface\\Icons\\inv_misc_coin_02";
			end
			-- xp
			if ( not texture and GetQuestLogRewardXP(questID) > 0 and UnitLevel("player") < MAX_PLAYER_LEVEL ) then
				texture = "Interface\\Icons\\xp_icon";
			end
			
		--	print('WORLD_QUEST_TRACKER_MODULE', 'AddProgressBar', texture, name)
			
			if not progressBar.Bar.CustomIcon then
				progressBar.Bar.CustomIcon = progressBar.Bar:CreateTexture()
				progressBar.Bar.CustomIcon:SetSize(17,17)
				progressBar.Bar.CustomIcon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
				progressBar.Bar.CustomIcon:SetPoint("TOPLEFT", progressBar.Bar.BarBG, "TOPRIGHT", 3, 0)
			end
			
			if not texture then			
				E:SecureCreateBackdrop(progressBar, progressBar.Bar.Icon):SetUIBorderAlpha(0)
				progressBar.Bar.CustomIcon:SetAlpha(0)
			else
				progressBar.Bar.CustomIcon:SetAlpha(1)
				progressBar.Bar.CustomIcon:SetTexture(texture)
				
				E:SecureCreateBackdrop(progressBar, progressBar.Bar.Icon):SetUIBorderAlpha(1)
				progressBar.Bar.Icon:SetSize(17, 17)
				progressBar.Bar.Icon:SetMask(nil)
				progressBar.Bar.Icon:SetTexture(texture)
				progressBar.Bar.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
				progressBar.Bar.Icon:ClearAllPoints()
				progressBar.Bar.Icon:SetPoint("TOPLEFT", progressBar.Bar.BarBG, "TOPRIGHT", 3, 0)
				C_Timer.After(0.5, function()
					progressBar.Bar.Icon:SetTexture(texture)
				end)
			end			
		end
	end)
--	hooksecurefunc(WORLD_QUEST_TRACKER_MODULE, 'SetStringText', OT.OnSetStringText)	
	
end

if ( E.isClassic ) then 
	return 
end 

E:OnInit2(Load)
E:OnInit(function()
	OT.UpdateObjectTrackerSize()
	
	E.GUI.args.OBJTracker = {
		name = E.L['Objective Tracker'],
		type = "group",
		order = 4.9,
		args = {},
	}
	
	E.GUI.args.OBJTracker.args.Resizable = {
		name = E.L['Resizable'],
		type = 'toggle',
		order = 1,
		set = function()
			E.db.objectFrame.setResizable = not E.db.objectFrame.setResizable
			OT.UpdateObjectTrackerSize()
		end,
		get = function()
			return E.db.objectFrame.setResizable
		end,	
	}
	
	E.GUI.args.OBJTracker.args.Unlock = {
		name = E.L['Unlock'],
		type = 'execute',
		order = 2,
		set = function()
			E:UnlockMover('watchFrameMover')
		end,
		get = function()
			return 
		end,	
	}	
	
	E.GUI.args.OBJTracker.args.HideOnBossFight = {
		name = E.L['Hide on boss fights'],
		type = 'toggle',
		order = 2, width = 'full',
		set = function()
			E.db.objectFrame.hideOnBossFights = not E.db.objectFrame.hideOnBossFights
		end,
		get = function()
			return E.db.objectFrame.hideOnBossFights
		end,	
	}
	
	E.GUI.args.OBJTracker.args.hideOnBGorArena = {
		name = E.L['Hide on arena and battlegrounds'],
		type = 'toggle',
		order = 3, width = 'full',
		set = function()
			E.db.objectFrame.hideOnBGorArena = not E.db.objectFrame.hideOnBGorArena
		end,
		get = function()
			return E.db.objectFrame.hideOnBGorArena
		end,	
	}
	
end)