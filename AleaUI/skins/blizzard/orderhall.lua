local Skins = AleaUI:Module("Skins")
local _G = _G

local varName = 'orderhall'
AleaUI.default_settings.skins[varName] = true

local orderhallAddon = "Blizzard_OrderHallUI"

local function StyleOrderhallWindow()
	_G["OrderHallCommandBar"]:Kill()
end

AleaUI:OnInit(function()
	
	if not AleaUI.db.skins.enableAll then return end
	if not AleaUI.db.skins[varName] then return end

	if _G["OrderHallCommandBar"] then
		StyleOrderhallWindow()
	else
		AleaUI:OnAddonLoad(orderhallAddon, StyleOrderhallWindow)
	end
end)