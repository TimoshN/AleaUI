local Skins = AleaUI:Module("Skins")
local _G = _G

local varName = 'lfgdungeonready'
AleaUI.default_settings.skins[varName] = true

local function Skin_LFGReadyCheck()
	if not AleaUI.db.skins.enableAll then return end
	if not AleaUI.db.skins[varName] then return end

	Skins.ThemeBackdrop('LFGDungeonReadyStatus')

	Skins.ThemeBackdrop('LFGDungeonReadyDialog')

	Skins.ThemeButton('LFGDungeonReadyDialogEnterDungeonButton')
	Skins.ThemeButton('LFGDungeonReadyDialogLeaveQueueButton')

end

AleaUI:OnInit2(Skin_LFGReadyCheck)