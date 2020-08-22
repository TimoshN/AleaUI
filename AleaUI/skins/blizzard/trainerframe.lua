﻿local AddOn, E = ...
local Skins = E:Module("Skins")
local _G = _G

local default_background_color = Skins.default_background_color
local default_border_color = Skins.default_border_color
local default_font = Skins.default_font
local default_texture = Skins.default_texture

local default_button_background = Skins.default_button_background
local default_button_border 	= Skins.default_button_border
local default_border_color_dark = Skins.default_border_color_dark

local varName = 'trainerFrame'
E.default_settings.skins[varName] = true

E:OnAddonLoad('Blizzard_TrainerUI', function()
	if not E.db.skins.enableAll then return end
	if not E.db.skins[varName] then return end

	ClassTrainerFrame:StripTextures()
	ClassTrainerFrameInset:StripTextures()
	ClassTrainerFrameBottomInset:StripTextures()
	Skins.ThemeBackdrop('ClassTrainerFrame')
	
	Skins.ThemeStatusBar('ClassTrainerStatusBar')
	
	Skins.ThemeButton('ClassTrainerTrainButton')
	Skins.ThemeDropdown('ClassTrainerFrameFilterDropDown')	
	
	Skins.ThemeFrameRing('ClassTrainerFrame')
	
	Skins.ThemeScrollBar(ClassTrainerScrollFrameScrollBar)
end)
