local Skins = AleaUI:Module("Skins")
local _G = _G

local varName = 'readycheck'
AleaUI.default_settings.skins[varName] = true

local function Skin_ReadyCheck()
	if not AleaUI.db.skins.enableAll then return end
	if not AleaUI.db.skins[varName] then return end

	_G['ReadyCheckFrame']:StripTextures()
	_G['ReadyCheckListenerFrame']:StripTextures()

	Skins.ThemeButton('ReadyCheckFrameYesButton')
	Skins.ThemeButton('ReadyCheckFrameNoButton')

	Skins.ThemeBackdrop('ReadyCheckListenerFrame')

	ReadyCheckPortrait:Kill()

	ReadyCheckFrameYesButton:ClearAllPoints()
	ReadyCheckFrameNoButton:ClearAllPoints()

	ReadyCheckFrameText:ClearAllPoints()

	ReadyCheckFrameText:SetPoint('CENTER', ReadyCheckFrame, 'CENTER', 0, 20)

	ReadyCheckFrameYesButton:SetPoint('RIGHT', ReadyCheckFrame, 'CENTER', 0, -20)
	ReadyCheckFrameNoButton:SetPoint('LEFT', ReadyCheckFrame, 'CENTER', 0, -20)

end

AleaUI:OnInit2(Skin_ReadyCheck)