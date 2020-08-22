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

local varName = 'artifactFrame'
E.default_settings.skins[varName] = true

E:OnAddonLoad('Blizzard_ArtifactUI', function()
	if not E.db.skins.enableAll then return end
	if not E.db.skins[varName] then return end

	ArtifactFrame.BorderFrame:StripTextures()
	
	local border = Skins.NewBackdrop(ArtifactFrame)
	border:SetBackdropColor(0, 0, 0, 0.2)
	border:SetBackdropBorderColor(default_border_color[1], default_border_color[2], default_border_color[3],1)
	border:SetPoint('TOPLEFT', ArtifactFrame, 'TOPLEFT', -1, 1)
	border:SetPoint('BOTTOMRIGHT', ArtifactFrame, 'BOTTOMRIGHT', 1, -2)
	
	ArtifactFrame.CloseButton:ClearAllPoints()
	ArtifactFrame.CloseButton:SetPoint('TOPRIGHT', ArtifactFrame, 'TOPRIGHT', 0, 0)
	
	ArtifactFrame.Background:ClearAllPoints()
	ArtifactFrame.Background:SetPoint('TOPLEFT', ArtifactFrame, 'TOPLEFT', 0, -1)
	ArtifactFrame.Background:SetPoint('BOTTOMRIGHT', ArtifactFrame, 'BOTTOMRIGHT', 0, -1)
	
--	ArtifactFrame.PerksTab.BackgroundBackShadow:ClearAllPoints()
--	ArtifactFrame.PerksTab.BackgroundBackShadow:SetAllPoints(ArtifactFrame.Background)
	
	ArtifactFrame.PerksTab.Model.BackgroundFront:ClearAllPoints()
	ArtifactFrame.PerksTab.Model.BackgroundFront:SetPoint('TOPLEFT', ArtifactFrame.PerksTab.Model, 'TOPLEFT', 0, 0)
	ArtifactFrame.PerksTab.Model.BackgroundFront:SetPoint('BOTTOMRIGHT', ArtifactFrame.PerksTab.Model, 'BOTTOMRIGHT', 0, -1)
	
	ArtifactFrame.PerksTab.BackgroundBack:ClearAllPoints()
	ArtifactFrame.PerksTab.BackgroundBack:SetAllPoints(ArtifactFrame.Background)
	
	for i=1, 2 do
		Skins.ThemeTab('ArtifactFrameTab'..i)
	end
	
	_G['ArtifactFrameTab1']:SetPoint("TOPLEFT", ArtifactFrame, "BOTTOMLEFT",11,-1)
end)
