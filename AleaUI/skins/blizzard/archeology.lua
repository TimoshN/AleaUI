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

local varName = 'archeology'
E.default_settings.skins[varName] = true

E:OnAddonLoad("Blizzard_ArchaeologyUI", function()
	
	if not E.db.skins.enableAll then return end
	if not E.db.skins[varName] then return end
	
	ArchaeologyFrame:StripTextures()
	ArchaeologyFrameInset:StripTextures()
	Skins.ThemeBackdrop(ArchaeologyFrame)	
	ArchaeologyFrame.portrait:SetAlpha(0)
	Skins.ThemeBackdrop(ArchaeologyFrameInset)
	Skins.ThemeButton(ArchaeologyFrameArtifactPageBackButton)
	
	ArchaeologyFrameRaceFilter:SetFrameLevel(ArchaeologyFrameRaceFilter:GetFrameLevel() + 2)
	
	Skins.ThemeDropdown(ArchaeologyFrameRaceFilter)

	Skins.ThemeIconButton(ArchaeologyFrameSummaryPagePrevPageButton, true)
	Skins.ThemeIconButton(ArchaeologyFrameSummaryPageNextPageButton, true)
	Skins.ThemeIconButton(ArchaeologyFrameCompletedPageNextPageButton, true)
	Skins.ThemeIconButton(ArchaeologyFrameCompletedPagePrevPageButton, true)

	ArchaeologyFrameRankBar:StripTextures()
	ArchaeologyFrameRankBar:SetStatusBarTexture(default_texture)
	ArchaeologyFrameRankBar:SetFrameLevel(ArchaeologyFrameRankBar:GetFrameLevel() + 2)
	Skins.ThemeBackdrop(ArchaeologyFrameRankBar)	
	
	ArchaeologyFrameArtifactPageSolveFrameStatusBar:StripTextures()
	ArchaeologyFrameArtifactPageSolveFrameStatusBar:SetStatusBarTexture(default_texture)
	ArchaeologyFrameArtifactPageSolveFrameStatusBar:SetStatusBarColor(0.7, 0.2, 0)
	ArchaeologyFrameArtifactPageSolveFrameStatusBar:SetFrameLevel(ArchaeologyFrameArtifactPageSolveFrameStatusBar:GetFrameLevel() + 2)
	Skins.ThemeBackdrop(ArchaeologyFrameArtifactPageSolveFrameStatusBar)	
	
	Skins.ThemeButton(ArchaeologyFrameArtifactPageSolveFrameSolveButton)
	
	for i=1, ARCHAEOLOGY_MAX_COMPLETED_SHOWN do
		local artifact = _G["ArchaeologyFrameCompletedPageArtifact"..i]

		if artifact then
			_G["ArchaeologyFrameCompletedPageArtifact"..i.."Border"]:Kill()
			_G["ArchaeologyFrameCompletedPageArtifact"..i.."Bg"]:Kill()
			_G["ArchaeologyFrameCompletedPageArtifact"..i.."Icon"]:SetTexCoord(unpack(E.media.texCoord))
			_G["ArchaeologyFrameCompletedPageArtifact"..i.."Icon"].backdrop = CreateFrame("Frame", nil, artifact)
			Skins.ThemeBackdrop(_G["ArchaeologyFrameCompletedPageArtifact"..i.."Icon"].backdrop)
			_G["ArchaeologyFrameCompletedPageArtifact"..i.."Icon"].backdrop:SetOutside(_G["ArchaeologyFrameCompletedPageArtifact"..i.."Icon"], 0, 0)
			_G["ArchaeologyFrameCompletedPageArtifact"..i.."Icon"].backdrop:SetFrameLevel(artifact:GetFrameLevel() - 2)
			_G["ArchaeologyFrameCompletedPageArtifact"..i.."Icon"]:SetDrawLayer("OVERLAY")
		end
	end

	ArchaeologyFrameArtifactPageIcon:SetTexCoord(unpack(E.media.texCoord))
	ArchaeologyFrameArtifactPageIcon.backdrop = CreateFrame("Frame", nil, ArchaeologyFrameArtifactPage)
	Skins.ThemeBackdrop(ArchaeologyFrameArtifactPageIcon.backdrop)	
	ArchaeologyFrameArtifactPageIcon.backdrop:SetOutside(ArchaeologyFrameArtifactPageIcon, 0, 0)
	ArchaeologyFrameArtifactPageIcon.backdrop:SetFrameLevel(ArchaeologyFrameArtifactPage:GetFrameLevel())
	ArchaeologyFrameArtifactPageIcon:SetParent(ArchaeologyFrameArtifactPageIcon.backdrop)
	ArchaeologyFrameArtifactPageIcon:SetDrawLayer("OVERLAY")

	ArcheologyDigsiteProgressBar:StripTextures()
	ArcheologyDigsiteProgressBar.FillBar:StripTextures()
	ArcheologyDigsiteProgressBar.FillBar:SetStatusBarTexture(default_texture)
	ArcheologyDigsiteProgressBar.FillBar:SetStatusBarColor(0.7, 0.2, 0)
	ArcheologyDigsiteProgressBar.FillBar:SetFrameLevel(ArchaeologyFrameArtifactPageSolveFrameStatusBar:GetFrameLevel() + 2)
	Skins.ThemeBackdrop(ArcheologyDigsiteProgressBar.FillBar)
	
	ArcheologyDigsiteProgressBar:ClearAllPoints()
	ArcheologyDigsiteProgressBar:SetPoint("TOP", UIParent, "TOP", 0, -400)
--	E:CreateMover(ArcheologyDigsiteProgressBar, "DigSiteProgressBarMover", L["Archeology Progress Bar"])


end)