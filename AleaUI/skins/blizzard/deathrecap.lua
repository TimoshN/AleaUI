local addonName, E = ...
local Skins = E:Module("Skins")

local default_background_color = Skins.default_background_color
local default_border_color = Skins.default_border_color
local default_font = Skins.default_font
local default_texture = Skins.default_texture

local default_button_background = Skins.default_button_background
local default_button_border 	= Skins.default_button_border
local default_border_color_dark = Skins.default_border_color_dark

local varName = 'deathrecap'
E.default_settings.skins[varName] = true

E:OnAddonLoad('Blizzard_DeathRecap', function()
	if not E.db.skins.enableAll then return end
	if not E.db.skins[varName] then return end

	DeathRecapFrame:StripTextures()
	
	Skins.ThemeBackdrop(DeathRecapFrame)
	Skins.ThemeButton(DeathRecapFrame.CloseButton)
	
	for i=1, 5 do
	
		
		DeathRecapFrame['Recap'..i].SpellInfo.Icon:SetTexCoord(unpack(E.media.texCoord))
		DeathRecapFrame['Recap'..i].SpellInfo.IconBorder:Kill()
		
		
		local border = Skins.NewBackdrop(DeathRecapFrame['Recap'..i].SpellInfo, DeathRecapFrame['Recap'..i].SpellInfo.Icon)
		Skins.SetTemplate(border, 'BORDERED')
		
	end
	
end)