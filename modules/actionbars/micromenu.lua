local addonName, E = ...
local L = E.L

--if true then return end

local AB = E:Module("MicroButtons")
local hidenalpha = 0
local mover

local hiden = CreateFrame('Frame')
hiden:Hide()

E.MicroButtonsDataText = CreateFrame('Frame', nil, E.UIParent)
E.MicroButtonsDataText:Hide()
E.MicroButtonsDataText:SetScript('OnUpdate', function(self, elapsed)
	self.elapsed = self.elapsed + elapsed
	if self.elapsed < 5 then return end
	self.elapsed = 0
	self:Hide()
end)
E.MicroButtonsDataText:SetScript('OnShow', function(self)
	self.elapsed = 0
end)
E.MicroButtonsDataText:SetScript('OnHide', function(self)
	self.elapsed = 0
end)

local overFrame = false

local function OnEnter(self)
	E.MicroButtonsDataText.elapsed = 0
	mover:SetAlpha(1)
	overFrame = true
	
	if self._backdrop then
		self._backdrop._icon:SetAlpha(1)
	end
end

local function OnLeave(self)
	E.MicroButtonsDataText.elapsed = 0
	mover:SetAlpha(hidenalpha)
	overFrame = false
	
	if self._backdrop then
		self._backdrop._icon:SetAlpha(0.6)
	end
end

local function OnClick(self)
	
	if true then return end
	
	if self and self:GetName() == MICRO_BUTTONS[10] then
		C_Timer.After(0.2, function() 
			E.MicroButtonsDataText:Hide()
		end)
	else	
		E.MicroButtonsDataText:Hide()
	end
end

local function OnMouseUp(self)
	self._backdrop._icon:SetPoint('TOPLEFT', self._backdrop, 'TOPLEFT', 0, 0)
	self._backdrop._icon:SetPoint('BOTTOMRIGHT', self._backdrop, 'BOTTOMRIGHT', 0, 0)	
end

local function OnMouseDown(self)
	self._backdrop._icon:SetPoint('TOPLEFT', self._backdrop, 'TOPLEFT', 1, -1)
	self._backdrop._icon:SetPoint('BOTTOMRIGHT', self._backdrop, 'BOTTOMRIGHT', 1, -1)
end
	
function AB:HandleMicroButton(button, texture)
	assert(button, 'Invalid micro button name.')

	local pushed = button:GetPushedTexture()
	local normal = button:GetNormalTexture()
	local disabled = button:GetDisabledTexture()
	
	button:StripTextures()
	
	button:SetParent(AleaUI_MicroMover)
	button.Flash:SetTexture(nil)
	button:GetHighlightTexture():SetParent(hiden)

	local f = CreateFrame("Frame", nil, button)
--	f:SetFrameLevel(1)
--	f:SetFrameStrata("BACKGROUND")
	f:SetPoint("BOTTOMLEFT", button, "BOTTOMLEFT", 0, 0)
	f:SetPoint("TOPRIGHT", button, "TOPRIGHT", 0, 0)
	
	f._icon = f:CreateTexture()
	f._icon:SetSize(1,1)
	f._icon:SetDrawLayer('OVERLAY', 0)
	f._icon:SetPoint('TOPLEFT', f, 'TOPLEFT', 0, 0)
	f._icon:SetPoint('BOTTOMRIGHT', f, 'BOTTOMRIGHT', 0, 0)
	f._icon:SetTexture(texture)
	f._icon:SetAlpha(0.6)
	
	f._background = f:CreateTexture()
	f._background:SetSize(1,1)
	f._background:SetDrawLayer('OVERLAY', -1)
	f._background:SetAllPoints()
	f._background:SetColorTexture(24/255, 24/255, 29/255, 0.45)
	
	button._backdrop = f
	
	pushed:SetAlpha(0)
	normal:SetAlpha(0)
	
	if disabled then
		disabled:SetAlpha(0)
	end
	
	button:HookScript('OnMouseUp', OnMouseUp)
	button:HookScript('OnMouseDown', OnMouseDown)	
	button:HookScript("OnEnter", OnEnter)
	button:HookScript("OnLeave", OnLeave)
	button:HookScript('OnClick', OnClick)
end

function AB:MainMenuMicroButton_SetNormal()
	MainMenuBarPerformanceBar:SetPoint("TOPLEFT", MainMenuMicroButton, "TOPLEFT", 9, -36);
end

function AB:MainMenuMicroButton_SetPushed()
	MainMenuBarPerformanceBar:SetPoint("TOPLEFT", MainMenuMicroButton, "TOPLEFT", 8, -37);
end

function AB.UpdateMicroButtonsParent(parent)
	if parent ~= AleaUI_MicroMover then parent = AleaUI_MicroMover end
	
	for i=1, #MICRO_BUTTONS do
		_G[MICRO_BUTTONS[i]]:SetParent(AleaUI_MicroMover);
	end
end

local __buttons = {}
__buttons[10] = "StoreMicroButton"
for i=10, #MICRO_BUTTONS do
	__buttons[i + 1] = MICRO_BUTTONS[i]
end

local buttonTexture = {
	["CharacterMicroButton"] = 'char.tga',
	["SpellbookMicroButton"] = 'spell.tga',
	["TalentMicroButton"] = 'talent.tga',
	["AchievementMicroButton"] = 'ach.tga',
	["QuestLogMicroButton"] = 'quest.tga',
	["GuildMicroButton"] = 'guild.tga',
	["LFDMicroButton"] = 'lfg.tga',
	["EJMicroButton"] = 'journal.tga',
	["CollectionsMicroButton"] = 'pet.tga',
	["MainMenuMicroButton"] = 'help.tga',
	["HelpMicroButton"] = 'help.tga',
	["StoreMicroButton"] = 'shop.tga',
}	
	
	

function AB:UpdateMicroPositionDimensions()
	if not AleaUI_MicroMover then return; end
	local numRows = 1
	local prevButton = AleaUI_MicroMover
	for i=1, (#MICRO_BUTTONS) do
		local button = _G[__buttons[i]] or _G[MICRO_BUTTONS[i]]
		local lastColumnButton = i-( E.db.Frames["actionBarMover"].perrow or 11 );
		lastColumnButton = _G[__buttons[lastColumnButton]] or _G[MICRO_BUTTONS[lastColumnButton]]

		button:SetWidth(28)
		button:SetHeight(28)
		button:ClearAllPoints();

		
		--print(i, (i - 1), (i - 1) % ( E.db.Frames["actionBarMover"].perrow or 11 ), E.db.Frames["actionBarMover"].perrow)
		
		if prevButton == AleaUI_MicroMover then
			button:SetPoint("TOPLEFT", prevButton, "TOPLEFT", -0, 0)
		elseif (i - 1) % ( E.db.Frames["actionBarMover"].perrow or 11 ) == 0 then
			button:SetPoint('TOP', lastColumnButton, 'BOTTOM', 0, 28);	
			numRows = numRows + 1
		else
			button:SetPoint('LEFT', prevButton, 'RIGHT', -4, 0);
		end

		prevButton = button
	end

	AleaUI_MicroMover:SetWidth((((28 - 0.5) * (#MICRO_BUTTONS - 2)) - 3) / numRows)
	AleaUI_MicroMover:SetHeight((28) * numRows)

	if true then
		AleaUI_MicroMover:Show()
	else
		AleaUI_MicroMover:Hide()
	end		
	
	AB:CustomToggleMicroMenu()
end

function AB:UpdateMicroButtons()
	if ( GuildMicroButtonTabard ) then 
		GuildMicroButtonTabard:ClearAllPoints()
		GuildMicroButtonTabard:SetAlpha(0)
	end

	AB:UpdateMicroPositionDimensions()
end

function AB:CustomToggleMicroMenu()
	if E.db.Frames["actionBarMover"].enable == nil then
		E.db.Frames["actionBarMover"].enable = true
	end
	
	if E.db.Frames["actionBarMover"].enable then
		AleaUI_MicroMover:SetParent(E.UIParent)
	else
		AleaUI_MicroMover:SetParent(hiden)
	end

	if E.db.Frames["actionBarMover"].showOnEnter then
		hidenalpha = 0
	else
		hidenalpha = 1
	end
	
	if E.db.Frames["actionBarMover"].ByDataText then
		AleaUI_MicroMover:SetParent(E.MicroButtonsDataText)
		hidenalpha = 1
	end
	
	AleaUI_MicroMover:SetAlpha( overFrame and 1 or hidenalpha )
end

local function UpdateButtonTransparent()
	for i=1, #MICRO_BUTTONS do
		if ( _G[MICRO_BUTTONS[i]] ) then
		_G[MICRO_BUTTONS[i]]._backdrop._background:SetColorTexture(24/255, 24/255, 29/255, E.db.Frames["actionBarMover"].transparent and 0.45 or 0.9)
		end
	end
end

function AB:SetupMicroBar()
	mover = CreateFrame("Frame", "AleaUI_MicroMover", E.UIParent)
	mover:SetPoint("CENTER", E.UIParent, "CENTER", 0, 0)
	mover:SetSize(1,1)
	mover:EnableMouse(true)
	mover:SetAlpha(hidenalpha)
	mover:SetScript("OnEnter", OnEnter)
	mover:SetScript("OnLeave", OnLeave)	
		
	for i=1, #MICRO_BUTTONS do

		print(i, MICRO_BUTTONS[i], _G[MICRO_BUTTONS[i]]  )
		if ( _G[MICRO_BUTTONS[i]] ) then
			AB:HandleMicroButton(_G[MICRO_BUTTONS[i]], 'Interface\\AddOns\\AleaUI\\media\\'..(buttonTexture[MICRO_BUTTONS[i]] or 'help.tga' ) )
		end
	end

	MicroButtonPortrait:SetParent(hiden) --SetInside(CharacterMicroButton.backdrop)

--	hooksecurefunc('MainMenuMicroButton_SetPushed',AB.MainMenuMicroButton_SetPushed)
--	hooksecurefunc('MainMenuMicroButton_SetNormal',AB.MainMenuMicroButton_SetPushed)
	hooksecurefunc('UpdateMicroButtonsParent', AB.UpdateMicroButtonsParent)
	hooksecurefunc('MoveMicroButtons', AB.UpdateMicroPositionDimensions)

	if ( GuildMicroButtonTabard ) then 
	GuildMicroButtonTabard:Kill()
	end

	hooksecurefunc("UpdateMicroButtons",AB.UpdateMicroButtons)

	AB.UpdateMicroButtonsParent(mover)
	
	AB:MainMenuMicroButton_SetNormal()
	MainMenuBarPerformanceBar:SetParent(hiden)

	E:Mover(mover, "actionBarMover")
	
	AB:UpdateMicroPositionDimensions()
	
	UpdateButtonTransparent()
	
	E.numActonBars = ( E.numActonBars or 0 ) + 1
	
	E.GUI.args.actionbars.args.actionBarMover = {
		name = L["MicroButtons"],
		order = E.numActonBars,
		expand = true,
		type = "group",
		args = {}
	}
	
	E.GUI.args.actionbars.args.actionBarMover.args.unlock = {
		name = L['Unlock'],
		order = 2,
		type = "execute",
		set = function(self, value)
			E:UnlockMover("actionBarMover") 
		end,
		get = function(self)end
	}
	
	E.GUI.args.actionbars.args.actionBarMover.args.perrow = {
		name = L["Per Row"],
		order = 3,
		type = "slider",
		min = 1, max = 11, step = 1,
		set = function(self, value)
			E.db.Frames["actionBarMover"].perrow = value or 11				
			AB:UpdateMicroPositionDimensions()
		end,
		get = function(self) 
			return E.db.Frames["actionBarMover"].perrow or 11
		end
	}
	
	E.GUI.args.actionbars.args.actionBarMover.args.enable = {
		name = L["Enable"],
		order = 1,
		type = "toggle",
		set = function(self, value)
			E.db.Frames["actionBarMover"].enable = not E.db.Frames["actionBarMover"].enable
			AB:CustomToggleMicroMenu()
		end,
		get = function(self)
			return E.db.Frames["actionBarMover"].enable
		end
	}
	
	E.GUI.args.actionbars.args.actionBarMover.args.showOnEnter = {
		name = L["Show on mouse enter"],
		order = 2,
		type = "toggle",
		set = function(self, value)
			E.db.Frames["actionBarMover"].showOnEnter = not E.db.Frames["actionBarMover"].showOnEnter
			AB:CustomToggleMicroMenu()
		end,
		get = function(self)
			return E.db.Frames["actionBarMover"].showOnEnter
		end
	}
	
	E.GUI.args.actionbars.args.actionBarMover.args.ByDataText = {
		name = L['Control visibility by datatext'],
		order = 3,
		type = "toggle",
		set = function(self, value)
			E.db.Frames["actionBarMover"].ByDataText = not E.db.Frames["actionBarMover"].ByDataText
			AB:CustomToggleMicroMenu()
		end,
		get = function(self)
			return E.db.Frames["actionBarMover"].ByDataText
		end
	}
	
	E.GUI.args.actionbars.args.actionBarMover.args.Alpha = {
		name = L['Transparent'],
		order = 4,
		type = "toggle",
		set = function(self, value)
			E.db.Frames["actionBarMover"].transparent = not E.db.Frames["actionBarMover"].transparent
			UpdateButtonTransparent()
		end,
		get = function(self)
			return E.db.Frames["actionBarMover"].transparent
		end
	}
end

E:OnInit2(AB.SetupMicroBar)