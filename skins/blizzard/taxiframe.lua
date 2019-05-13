local AddOn, E = ...
local Skins = E:Module("Skins")
local _G = _G

local default_background_color = Skins.default_background_color
local default_border_color = Skins.default_border_color
local default_font = Skins.default_font
local default_texture = Skins.default_texture

local default_button_background = Skins.default_button_background
local default_button_border 	= Skins.default_button_border
local default_border_color_dark = Skins.default_border_color_dark

local varName = 'taxiFrame'
AleaUI.default_settings.skins[varName] = true

AleaUI:OnAddonLoad('Blizzard_FlightMap', function()
	if not AleaUI.db.skins.enableAll then return end
	if not AleaUI.db.skins[varName] then return end

	FlightMapFrame.BorderFrame:StripTextures()
	Skins.ThemeBackdrop('FlightMapFrame')
end)
