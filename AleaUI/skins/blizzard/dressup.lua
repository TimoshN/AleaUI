local Skins = AleaUI:Module("Skins")

local varName = 'dressup'
AleaUI.default_settings.skins[varName] = true

local function Skin_DressUp()
	
	if not AleaUI.db.skins.enableAll then return end
	if not AleaUI.db.skins[varName] then return end

	DressUpFrame:StripTextures()
	Skins.ThemeFrameRing('DressUpFrame')

	DressUpFrameInset:StripTextures()

	Skins.ThemeButton(DressUpFrameResetButton)
	Skins.ThemeButton(DressUpFrameCancelButton)

	Skins.SetAllFontString(DressUpFrame, Skins.default_font, Skins.default_font_size, 'NONE')

	local backdrop = Skins.NewBackdrop(DressUpFrame)
	backdrop:SetFrameLevel(max((DressUpFrame:GetFrameLevel()-1), 1))
	backdrop:SetPoint('TOPLEFT', DressUpFrame, 'TOPLEFT', 5, 0)
	backdrop:SetPoint('BOTTOMRIGHT', DressUpFrameCancelButton, 'BOTTOMRIGHT', 5, -3)

	backdrop:SetBackdropColor(unpack(Skins.default_background_color))
	backdrop:SetBackdropBorderColor(unpack(Skins.default_border_color))
	
	MaximizeMinimizeFrame:StripTextures()

--	Skins.ThemeDropdown('DressUpFrameOutfitDropDown')
	
	local border, point = Skins.ThemeDropdown('DressUpFrameOutfitDropDown')
	border:SetPoint("TOPLEFT", point, "TOPLEFT", 18, -3)
	border:SetPoint("BOTTOMRIGHT", point, "BOTTOMRIGHT", -18, 0)
	
	if not WardrobeOutfitFrame.skinned then
		WardrobeOutfitFrame.skinned = true
		Skins.ThemeBackdrop('WardrobeOutfitFrame')
	end
	
	Skins.ThemeButton(DressUpFrameOutfitDropDown.SaveButton)
end

AleaUI:OnInit2(Skin_DressUp)