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

local varName = 'collectionjournal'
E.default_settings.skins[varName] = true

local function SkinCollectionUI()
	if not E.db.skins.enableAll then return end
	if not E.db.skins[varName] then return end
	
	--if true then return end
	
	_G['CollectionsJournal']:StripTextures()
	
	MountJournal.RightInset:StripTextures()
	MountJournal.LeftInset:StripTextures()
	
	MountJournal.MountCount:StripTextures()
	PetJournal.PetCount:StripTextures()
	
	_G['PetJournalLeftInset']:StripTextures()
	_G['PetJournalRightInset']:StripTextures()	
	_G["HeirloomsJournal"]:StripTextures()
	_G["ToyBox"]:StripTextures()
	
	ToyBox.iconsFrame:StripTextures()
	ToyBox.iconsFrame.NineSlice:StripTextures()

	HeirloomsJournal.iconsFrame:StripTextures()
	HeirloomsJournal.iconsFrame.NineSlice:StripTextures()

	_G['PetJournalPetCardInset']:StripTextures()
	
	PetJournalTutorialButton:Kill()
	
	Skins.MassKillTexture("MountJournal")	
	Skins.MassKillTexture("PetJournal")	
	Skins.MassKillTexture("ToyBox")	
	Skins.MassKillTexture("HeirloomsJournal")	
	
	MountJournalIcon:SetTexCoord(unpack(E.media.texCoord))
	
	--MountJournalSummonRandomFavoriteButton:SetTexCoord(0.07, 0.93, 0.07, 0.93)
	
	Skins.ThemeSpellButton(MountJournalSummonRandomFavoriteButton)
	Skins.ThemeSpellButton(PetJournalHealPetButton)
	
	for i=1, 12 do
		local button = _G['PetJournalListScrollFrameButton'..i]
	
		button.icon:SetTexCoord(unpack(E.media.texCoord))
	--	_G['PetJournalListScrollFrameButton'..i..'PetTypeIcon']:SetTexCoord(0.02, 0.98, 0.07, 0.93)
		button.selectedTexture:SetTexCoord(0.02, 0.98, 0.07, 0.93)
	end
	
	for i=1, 12 do
		local button = _G['MountJournalListScrollFrameButton'..i]
		
		if ( button ) then
			button.icon:SetTexCoord(unpack(E.media.texCoord))
			button.background:SetTexCoord(unpack(E.media.texCoord))
			button.selectedTexture:SetTexCoord(0.02, 0.98, 0.07, 0.93)
		end
	end

	Skins.ThemeDropdown('HeirloomsJournalClassDropDown')

	Skins.ThemeFilterButton('HeirloomsJournalFilterButton')
	Skins.ThemeFilterButton('ToyBoxFilterButton')
	Skins.ThemeFilterButton('PetJournalFilterButton')
	Skins.ThemeFilterButton('MountJournalFilterButton')
	
	Skins.ThemeScrollBar('MountJournalListScrollFrameScrollBar')
	Skins.ThemeScrollBar('PetJournalListScrollFrameScrollBar')
	
	Skins.ThemeBackdrop('CollectionsJournal')
	Skins.ThemeFrameRing('CollectionsJournal')
	
	Skins.ThemeBackdrop(MountJournal.MountDisplay)
--	Skins.ThemeBackdrop('ToyBox')
	Skins.ThemeBackdrop('MountJournal')
	Skins.ThemeBackdrop('PetJournal')
--	Skins.ThemeBackdrop('HeirloomsJournal')
	
	for i=1, 5 do
		Skins.ThemeTab('CollectionsJournalTab'..i)
	end
	
	Skins.ThemeEditBox('PetJournalSearchBox', true)
	Skins.ThemeEditBox('MountJournalSearchBox', true)
	Skins.ThemeEditBox('HeirloomsJournalSearchBox', true)
	Skins.ThemeEditBox(ToyBox.searchBox, true)
	
	Skins.ThemeButton('MountJournalMountButton')
	Skins.ThemeButton('PetJournalSummonButton')
	Skins.ThemeButton('PetJournalFindBattle')
	
	ToyBox.progressBar.border:Kill()
	ToyBox.progressBar:SetStatusBarTexture(default_texture)
	E:CreateBackdrop(ToyBox.progressBar, nil, default_border_color, {0,0,0,1})
	Skins.SetAllFontString(ToyBox.progressBar, default_font, Skins.default_font_size, 'OUTLINE')
	
	HeirloomsJournal.progressBar.border:Kill()
	HeirloomsJournal.progressBar:SetStatusBarTexture(default_texture)
	E:CreateBackdrop(HeirloomsJournal.progressBar, nil, default_border_color, {0,0,0,1})
	Skins.SetAllFontString(HeirloomsJournal.progressBar, default_font, Skins.default_font_size, 'OUTLINE')
	
	
	Skins.ThemeIconButton(ToyBox.PagingFrame.PrevPageButton, true)
	Skins.ThemeIconButton(ToyBox.PagingFrame.NextPageButton, true)
	Skins.ThemeIconButton(HeirloomsJournal.PagingFrame.PrevPageButton, true)
	Skins.ThemeIconButton(HeirloomsJournal.PagingFrame.NextPageButton, true)
	
	Skins.ThemeIconButton(MountJournal.MountDisplay.ModelScene.RotateLeftButton, true)
	Skins.ThemeIconButton(MountJournal.MountDisplay.ModelScene.RotateRightButton, true)
	
	----------------------
	-- Wardrobe
	----------------------
	
	Skins.MassKillTexture('WardrobeCollectionFrame')	
	
	Skins.ThemeFilterButton(WardrobeCollectionFrame.FilterButton)
	Skins.ThemeEditBox(WardrobeCollectionFrameSearchBox, true)
	
	--WardrobeCollectionFrame.progressBar.borderMid:Kill()
	--WardrobeCollectionFrame.progressBar.borderRight:Kill()
	--WardrobeCollectionFrame.progressBar.borderLeft:Kill()
	WardrobeCollectionFrame.progressBar.border:Kill()
	
	WardrobeCollectionFrame.progressBar:SetStatusBarTexture(default_texture)
	E:CreateBackdrop(WardrobeCollectionFrame.progressBar, nil, default_border_color, {0,0,0,1})
	Skins.SetAllFontString(WardrobeCollectionFrame.progressBar, default_font, Skins.default_font_size, 'OUTLINE')
	
	Skins.ThemeIconButton(WardrobeCollectionFrame.ItemsCollectionFrame.PagingFrame.PrevPageButton, true)
	Skins.ThemeIconButton(WardrobeCollectionFrame.ItemsCollectionFrame.PagingFrame.NextPageButton, true)
	
	Skins.ThemeDropdown(WardrobeCollectionFrameWeaponDropDown)
	
	for i=1, 2 do
		Skins.ThemeUpperTabs(_G["WardrobeCollectionFrameTab"..i])
	end
	
	WardrobeCollectionFrame.ItemsCollectionFrame:StripTextures()
	WardrobeCollectionFrame.ItemsCollectionFrame.NineSlice:StripTextures()

	Skins.SetTemplate(WardrobeCollectionFrame.ItemsCollectionFrame, 'DARK')
	
	Skins.MassKillTexture('WardrobeFrame')
	Skins.ThemeBackdrop('WardrobeFrame')
	Skins.ThemeFrameRing('WardrobeFrame')
	
	WardrobeCollectionFrame.SetsCollectionFrame.LeftInset:SetAlpha(0)
	WardrobeCollectionFrame.SetsCollectionFrame.RightInset:SetAlpha(0)
	
	Skins.SetTemplate(WardrobeCollectionFrame.SetsCollectionFrame.DetailsFrame, 'DARK')
	
	local detailsFrameBG = Skins.NewBackdrop(WardrobeCollectionFrame.SetsCollectionFrame.DetailsFrame)
	detailsFrameBG:SetFrameLevel(1)--WardrobeCollectionFrame.SetsCollectionFrame.DetailsFrame:GetFrameLevel()-2)
	Skins.SetTemplate(detailsFrameBG, 'DARK')
	WardrobeCollectionFrame.SetsCollectionFrame.Model:SetFrameLevel(5)
	
	Skins.ThemeScrollBar('WardrobeCollectionFrameScrollFrameScrollBar')
	Skins.ThemeFilterButton('WardrobeSetsCollectionVariantSetsButton')
	
	--WardrobeCollectionFrame.SetsTransmogFrame:StripTextures()
	Skins.ThemeIconButton(WardrobeCollectionFrame.SetsTransmogFrame.PagingFrame.PrevPageButton, true)
	Skins.ThemeIconButton(WardrobeCollectionFrame.SetsTransmogFrame.PagingFrame.NextPageButton, true)
	
	WardrobeCollectionFrame.SetsTransmogFrame:StripTextures()
	Skins.SetTemplate(WardrobeCollectionFrame.SetsTransmogFrame, 'DARK')
	
	local border, point = Skins.ThemeDropdown('WardrobeOutfitDropDown')
	border:SetPoint("TOPLEFT", point, "TOPLEFT", 18, -3)
	border:SetPoint("BOTTOMRIGHT", point, "BOTTOMRIGHT", -18, 0)
	
	Skins.ThemeButton(WardrobeOutfitDropDown.SaveButton)
	Skins.ThemeButton(WardrobeTransmogFrame.ApplyButton)
	
	Skins.MassKillTexture('WardrobeTransmogFrame')
	
	WardrobeTransmogFrame.MoneyMiddle:Kill()
	WardrobeTransmogFrame.MoneyRight:Kill()
	WardrobeTransmogFrame.MoneyLeft:Kill()
	
	if not WardrobeOutfitFrame.skinned then
		WardrobeOutfitFrame.skinned = true
		Skins.ThemeBackdrop('WardrobeOutfitFrame')
	end
end

E:OnAddonLoad('Blizzard_Collections', SkinCollectionUI)