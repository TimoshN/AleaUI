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

local varName = 'encounterjournal'
E.default_settings.skins[varName] = true

local function EncounterJournalStyle()
	if not E.db.skins.enableAll then return end
	if not E.db.skins[varName] then return end

	_G['EncounterJournal']:StripTextures()
	
	EncounterJournalInset.NineSlice:StripTextures()

	local defaultPoint = "TOPLEFT"
	local defaultParent = EncounterJournal
	local defaultAnchor = 'TOPLEFT'
	local defaultXpos = 3 
	local defaultYpos = -30

	Skins.ThemeBackdrop('EncounterJournal')	
	_G['EncounterJournalInset']:StripTextures()
	
	_G['EncounterJournalNavBar']:StripTextures()
	_G['EncounterJournalNavBar'].overlay:StripTextures()

	Skins.ThemeEditBox('EncounterJournalSearchBox', true) --, realSize, width, height)
	
	Skins.ThemeDropdown('EncounterJournalInstanceSelectTierDropDown')
	
	Skins.ThemeButton(EncounterJournalSuggestFrame.Suggestion1.button)
	Skins.ThemeButton(EncounterJournalSuggestFrame.Suggestion2.centerDisplay.button)
	Skins.ThemeButton(EncounterJournalSuggestFrame.Suggestion3.centerDisplay.button)
	
	Skins.ThemeScrollBar('EncounterJournalInstanceSelectScrollFrameScrollBar')
	Skins.ThemeScrollBar('EncounterJournalEncounterFrameInfoBossesScrollFrameScrollBar')
	Skins.ThemeScrollBar('EncounterJournalEncounterFrameInfoOverviewScrollFrameScrollBar')
	Skins.ThemeScrollBar('EncounterJournalEncounterFrameInstanceFrameLoreScrollFrameScrollBar')
	Skins.ThemeScrollBar('EncounterJournalEncounterFrameInfoLootScrollFrameScrollBar')
	Skins.ThemeScrollBar('EncounterJournalEncounterFrameInfoDetailsScrollFrameScrollBar')
	
	--[==[
	EncounterJournalNavBar:ClearAllPoints()
	EncounterJournalNavBar:SetPoint(defaultPoint, defaultParent, defaultAnchor, defaultXpos, defaultYpos)

	hooksecurefunc(EncounterJournalNavBar, 'SetPoint', function(self, point, parent, anchor, xpos, ypos)
		if ( point ~= defaultPoint ) or 
		   ( parent ~= defaultParent ) or
		   ( anchor ~= defaultAnchor ) or 
		   ( xpos ~= defaultXpos ) or
		   ( ypos ~= defaultYpos ) then
			
			EncounterJournalNavBar:ClearAllPoints()
			EncounterJournalNavBar:SetPoint(defaultPoint, defaultParent, defaultAnchor, defaultXpos, defaultYpos)

		end
	end)
	]==]
	
	Skins.ThemeIconButton(EncounterJournalSuggestFramePrevButton)
	Skins.ThemeIconButton(EncounterJournalSuggestFrameNextButton)
	
	
	local function StyleNavButton(frame, index)
		frame:StripTextures()
		
		_G[frame:GetName()..'Text']:SetFont(Skins.default_font, Skins.default_font_size, 'NONE')
		
		local temp = Skins.ThemeButtonBackdrop(frame)
		
		if index == 1 then
			temp:SetPoint('TOPLEFT', frame, 'TOPLEFT', 0, 0)
			temp:SetPoint('BOTTOMRIGHT', frame, 'BOTTOMRIGHT', -20, 0)
		else
			temp:SetPoint('TOPLEFT', frame, 'TOPLEFT', 10, 0)
			temp:SetPoint('BOTTOMRIGHT', frame, 'BOTTOMRIGHT', -0, 0)
		end
	end
	
	local styled = {}
	local function StyleForNavButtons(self)
		if self:GetName() ~= 'EncounterJournalNavBar' then return end

		if not styled[_G[self:GetName().."HomeButton"]] then
			styled[_G[self:GetName().."HomeButton"]] = true			
			StyleNavButton(_G[self:GetName().."HomeButton"], 1)
		end
		
		local numbutton = 2
		while ( _G[self:GetName().."Button".. numbutton] ) do
			
			if not styled[_G[self:GetName().."Button".. numbutton]] then
				styled[_G[self:GetName().."Button".. numbutton]] = true
				StyleNavButton(_G[self:GetName().."Button".. numbutton], numbutton)
			end

			numbutton = numbutton + 1
		end		
	end

	hooksecurefunc('NavBar_Initialize', StyleForNavButtons)	
	hooksecurefunc('NavBar_AddButton', StyleForNavButtons)
	
	StyleForNavButtons(_G['EncounterJournalNavBar'])
end
E:OnAddonLoad('Blizzard_EncounterJournal', EncounterJournalStyle)
