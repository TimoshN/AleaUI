local addonName, E = ...
local Skins = E:Module("Skins")
local _G = _G
local default_background_color = Skins.default_background_color
local default_border_color = Skins.default_border_color
local default_font = Skins.default_font
local default_texture = Skins.default_texture

local default_button_background = Skins.default_button_background
local default_button_border 	= Skins.default_button_border
local default_border_color_dark = Skins.default_border_color_dark

Skins.ThemeBackdrop('GameMenuFrame')
	
GameMenuFrame.Header:StripTextures()

E:CreateBackdrop(GameMenuFrame, GameMenuFrame.Header, default_border_color, default_background_color, 'ARTWORK', 1)

Skins.GetFontSting(GameMenuFrame.Header, MAINMENU_BUTTON):SetFont(default_font, Skins.default_font_size, 'NONE')

GameMenuFrame.Header:SetSize(110, 35)
GameMenuFrame.Header:SetUIBackgroundDrawLayer('ARTWORK')
GameMenuFrame.Header:SetUIBorderDrawLayer('ARTWORK')

Skins.ThemeButton('GameMenuButtonHelp')

if (not E.isClassic) then 
Skins.ThemeButton('GameMenuButtonStore')
Skins.ThemeButton('GameMenuButtonWhatsNew')
end 

Skins.ThemeButton('GameMenuButtonOptions')
Skins.ThemeButton('GameMenuButtonUIOptions')
Skins.ThemeButton('GameMenuButtonKeybindings')
Skins.ThemeButton('GameMenuButtonMacros')
Skins.ThemeButton('GameMenuButtonAddons')
Skins.ThemeButton('GameMenuButtonRatings')
Skins.ThemeButton('GameMenuButtonLogout')

Skins.ThemeButton('GameMenuButtonQuit')
Skins.ThemeButton('GameMenuButtonContinue')

local AleaUIMenuButton = CreateFrame('Button', 'AleaUIMenuButton', GameMenuFrame, "GameMenuButtonTemplate")
AleaUIMenuButton:SetPoint('BOTTOM', GameMenuButtonOptions, 'TOP', 0, 1)
AleaUIMenuButton:SetScript('OnClick', function(self)
	HideUIPanel(GameMenuFrame);
	AleaUI_GUI:Open('AleaUI')
	PlaySound(SOUNDKIT and SOUNDKIT.IG_MAINMENU_OPTION or "igMainMenuOption");
end)
AleaUIMenuButton:SetText('AleaUI')

Skins.ThemeButton(AleaUIMenuButton)

hooksecurefunc(GameMenuButtonOptions, 'SetPoint', function(self, to, frame, from, x, y)
	if to ~= "TOP" or from ~= 'BOTTOM' or x ~= 0 or y ~= -28 then
		self:SetPoint("TOP", frame, "BOTTOM", 0, -28)
	end
end)