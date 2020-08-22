local addonName, E = ...
local Skins = E:Module("Skins")
local _G = _G

local varName = 'lfgdungeonready'
E.default_settings.skins[varName] = true

local function Skin_LFGReadyCheck()
	if not E.db.skins.enableAll then return end
	if not E.db.skins[varName] then return end

	Skins.ThemeBackdrop('LFGDungeonReadyStatus')

	Skins.ThemeBackdrop('LFGDungeonReadyDialog')

	Skins.ThemeButton('LFGDungeonReadyDialogEnterDungeonButton')
	Skins.ThemeButton('LFGDungeonReadyDialogLeaveQueueButton')

end

E:OnInit2(Skin_LFGReadyCheck)