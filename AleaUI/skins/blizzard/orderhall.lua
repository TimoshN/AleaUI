local addonName, E = ...
local Skins = E:Module("Skins")
local _G = _G

local varName = 'orderhall'
E.default_settings.skins[varName] = true

local orderhallAddon = "Blizzard_OrderHallUI"

local function StyleOrderhallWindow()
	_G["OrderHallCommandBar"]:Kill()
end

E:OnInit(function()
	
	if not E.db.skins.enableAll then return end
	if not E.db.skins[varName] then return end

	if _G["OrderHallCommandBar"] then
		StyleOrderhallWindow()
	else
		E:OnAddonLoad(orderhallAddon, StyleOrderhallWindow)
	end
end)