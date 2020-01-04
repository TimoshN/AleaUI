local Skins = AleaUI:Module("Skins")
local _G = _G

local default_background_color = Skins.default_background_color
local default_border_color = Skins.default_border_color
local default_font = Skins.default_font
local default_texture = Skins.default_texture

local default_button_background = Skins.default_button_background
local default_button_border 	= Skins.default_button_border
local default_border_color_dark = Skins.default_border_color_dark

local varName = 'pvpframe'
AleaUI.default_settings.skins[varName] = true
	
AleaUI:OnAddonLoad('Blizzard_PVPUI', function()
	if not AleaUI.db.skins.enableAll then return end
	if not AleaUI.db.skins[varName] then return end

	Skins.MassKillTexture('HonorFrame')
	
	Skins.ThemeDropdown('HonorFrameTypeDropDown')
	
	HonorFrame.Inset:StripTextures()
	HonorFrame.Inset:SetAlpha(0)

	HonorFrameBg:SetAlpha(0)
	HonorFrame.BonusFrame:StripTextures()
	HonorFrame.BonusFrame.ShadowOverlay:Hide()
	
	--HonorFrameQueueButton_RightSeparator:SetAlpha(0)
	--HonorFrameQueueButton_LeftSeparator:SetAlpha(0)
	
	Skins.ThemeButton('HonorFrameQueueButton')
	
	Skins.ThemeScrollBar('HonorFrameSpecificFrameScrollBar')
	
--	HonorFrameQueueButton:SetHeight(16)

	--WarGamesFrame.RightInset:StripTextures()
	--WarGamesFrame.HorizontalBar:SetAlpha(0)
	--WarGamesFrameBg:SetAlpha(0)
	
	
	--_G['WarGamesFrameInfoScrollFrameScrollBar']:StripTextures()
	
	--Skins.ThemeScrollBar('WarGamesFrameScrollFrameScrollBar')
	--Skins.ThemeScrollBar('WarGamesFrameInfoScrollFrameScrollBar')
	
	--Skins.ThemeButton('WarGameStartButton')
	
	PVPQueueFrame.HonorInset.CasualPanel:StripTextures()
	PVPQueueFrame.HonorInset:StripTextures()
	PVPQueueFrame.HonorInset.NineSlice:StripTextures()

	Skins.MassKillTexture('PVPQueueFrame')
	
	ConquestFrame:StripTextures()
	ConquestFrame.Inset:StripTextures()
	ConquestFrame.Inset:SetAlpha(0)
	ConquestFrame.ShadowOverlay:SetAlpha(0)

	--ConquestFrame.RoleInset:StripTextures()
	--ConquestFrame.Inset:StripTextures()
	--ConquestFrame.ShadowOverlay:Hide()
	
	Skins.ThemeButton('ConquestJoinButton')
end)