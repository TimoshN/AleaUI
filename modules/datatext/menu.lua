local DT = AleaUI:Module('DataText')
local L = AleaUI.L

local function Click()
	if AleaUI.MicroButtonsDataText:IsShown() then
		AleaUI.MicroButtonsDataText:Hide()
	else
		AleaUI.MicroButtonsDataText:Show()
	end
end

local function OnEvent(self)
	self.text:SetText(L['Menu'])
end

DT:RegisterDatatext('Menu', { 'PLAYER_ENTERING_WORLD' }, OnEvent, nil, Click, nil)