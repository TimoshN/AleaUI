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

local varName = 'tradeskillframe'
E.default_settings.skins[varName] = true

local function TradeSkillFrameStyle_Legion()
	if not E.db.skins.enableAll then return end
	if not E.db.skins[varName] then return end

	TradeSkillFrame:StripTextures(true)
	TradeSkillFrame.RecipeInset:StripTextures()
	TradeSkillFrame.DetailsInset:StripTextures()
	
	Skins.ThemeBackdrop(TradeSkillFrame.RecipeInset)
	Skins.ThemeBackdrop(TradeSkillFrame.DetailsInset)
	
	Skins.ThemeBackdrop('TradeSkillFrame')
	Skins.ThemeFrameRing('TradeSkillFrame')
	
	TradeSkillFrame.RankFrame.BorderMid:Kill()
	TradeSkillFrame.RankFrame.BorderLeft:Kill()
	TradeSkillFrame.RankFrame.BorderRight:Kill()
	TradeSkillFrame.RankFrame.Background:Kill()
	
	TradeSkillFrame.RankFrame.Bar:SetTexture(default_texture)
	TradeSkillFrame.RankFrame.Bar:SetVertexColor(0.5, 0.5, 1, 1)
	TradeSkillFrame.RankFrame.Bar:SetDrawLayer('ARTWORK', 1)
	Skins.SetAllFontString(TradeSkillFrame.RankFrame, default_font, Skins.default_font_size, 'OUTLINE')	
	E:CreateBackdrop(TradeSkillFrame.RankFrame, nil, default_border_color, {0.2,0.2,0.7,0.4})
	
	TradeSkillFrame.RecipeList.scrollBar:StripTextures()
	TradeSkillFrame.DetailsFrame.ScrollBar:StripTextures()
	Skins.ThemeScrollBar(TradeSkillFrame.RecipeList.scrollBar)
	Skins.ThemeScrollBar(TradeSkillFrame.DetailsFrame.ScrollBar)

	Skins.ThemeFilterButton(TradeSkillFrame.FilterButton)
	
	Skins.ThemeUpperTabs(TradeSkillFrame.RecipeList.LearnedTab)
	Skins.ThemeUpperTabs(TradeSkillFrame.RecipeList.UnlearnedTab)
	
	TradeSkillFrame.RecipeList.LearnedTab:StripTextures()
	TradeSkillFrame.RecipeList.UnlearnedTab:StripTextures()
	
	Skins.ThemeButton(TradeSkillFrame.DetailsFrame.CreateAllButton)
	Skins.ThemeButton(TradeSkillFrame.DetailsFrame.CreateButton)
	Skins.ThemeButton(TradeSkillFrame.DetailsFrame.ExitButton)
	
	Skins.ThemeEditBox(TradeSkillFrame.SearchBox, true)
	
	-- Temp Fix??? for CreateMultipleInputBox Left Texture
	local CreateMultipleInputBox_Fix = {}
	Skins.GetTextureInterator(TradeSkillFrame.DetailsFrame.CreateMultipleInputBox, CreateMultipleInputBox_Fix)
	for k,v in pairs(CreateMultipleInputBox_Fix) do
		v:Kill()
	end
	--
	
	Skins.ThemeEditBox(TradeSkillFrame.DetailsFrame.CreateMultipleInputBox, true)
	
	Skins.ThemeIconButton(TradeSkillFrame.DetailsFrame.CreateMultipleInputBox.DecrementButton, true)
	Skins.ThemeIconButton(TradeSkillFrame.DetailsFrame.CreateMultipleInputBox.IncrementButton, true)
	
	
	local i = 1
	while true do
		local reagent = TradeSkillFrame.DetailsFrame.Contents['Reagent'..i]
		
		if not reagent then return end
		
		Skins.ThemeReagentItems(reagent, true)
		
		i= i+1
	end
	
	--Guild Crafters
	--[==[
	TradeSkillGuildFrame:StripTextures()
	Skins.ThemeBackdrop(TradeSkillGuildFrame)
	TradeSkillGuildFrame:SetPoint("BOTTOMLEFT", TradeSkillFrame, "BOTTOMRIGHT", 3, 19)
	TradeSkillGuildFrameContainer:StripTextures()
	Skins.ThemeBackdrop(TradeSkillGuildFrameContainer)
	]==]
end

E:OnAddonLoad('Blizzard_TradeSkillUI', TradeSkillFrameStyle_Legion)
