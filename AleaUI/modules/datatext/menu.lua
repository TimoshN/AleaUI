local addonName, E = ...
local DT = E:Module('DataText')
local L = E.L

local function Click()
	if E.MicroButtonsDataText:IsShown() then
		E.MicroButtonsDataText:Hide()
	else
		E.MicroButtonsDataText:Show()
	end
end

local function OnEvent(self)
	self.text:SetText(L['Menu'])
end

DT:RegisterDatatext('Menu', { 'PLAYER_ENTERING_WORLD' }, OnEvent, nil, Click, nil)