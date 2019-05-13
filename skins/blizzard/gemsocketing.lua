local Skins = AleaUI:Module("Skins")
local _G = _G

local default_background_color = Skins.default_background_color
local default_border_color = Skins.default_border_color
local default_font = Skins.default_font
local default_texture = Skins.default_texture

local default_button_background = Skins.default_button_background
local default_button_border 	= Skins.default_button_border
local default_border_color_dark = Skins.default_border_color_dark

local varName = 'gemsocketing'
AleaUI.default_settings.skins[varName] = true

local function Skin_GemSocketings()
	if not AleaUI.db.skins.enableAll then return end
	if not AleaUI.db.skins[varName] then return end

	_G['ItemSocketingFrame']:StripTextures()
	_G['ItemSocketingFrameInset']:StripTextures()
	Skins.ThemeBackdrop('ItemSocketingFrame')
	Skins.ThemeFrameRing('ItemSocketingFrame')

	Skins.ThemeButton('ItemSocketingSocketButton')
	
	Skins.ThemeScrollBar('ItemSocketingScrollFrameScrollBar')
	
	Skins.ThemeBackdrop('ItemSocketingScrollFrame')

	ItemSocketingFrame:HookScript('OnShow', function()	
		for i=1, 3 do
			local button = _G['ItemSocketingSocket'..i]		
			
			if button and not button.hooked then			
				button.hooked = true
				Skins.ThemeSocket('ItemSocketingSocket'..i)
			end
		end
	end)
end

AleaUI:OnAddonLoad('Blizzard_ItemSocketingUI', Skin_GemSocketings)
