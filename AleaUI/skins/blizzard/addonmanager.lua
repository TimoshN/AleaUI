local addonName, E = ...
local Skins = E:Module("Skins")
local _G = _G

local varName = 'addonmanager'
E.default_settings.skins[varName] = true

local function Skin_AddonManager()
	if not E.db.skins.enableAll then return end
	if not E.db.skins[varName] then return end
	
	AddonList:StripTextures()
	AddonListInset:StripTextures()
	Skins.ThemeBackdrop('AddonList')
	Skins.ThemeScrollBar('AddonListScrollFrameScrollBar')

	Skins.ThemeButton('AddonListEnableAllButton')
	Skins.ThemeButton('AddonListDisableAllButton')
	Skins.ThemeButton('AddonListOkayButton')
	Skins.ThemeButton('AddonListCancelButton')

	local temp1, parent1, temp, parent = Skins.ThemeDropdown('AddonCharacterDropDown')

	temp1:SetPoint("TOPLEFT", parent1, "TOPLEFT", 20, -2)
	temp1:SetPoint("BOTTOMRIGHT", parent1, "BOTTOMRIGHT", 108, 8)

	for i=1, 19 do
		local button = _G['AddonListEntry'..i..'Enabled']
		local name = _G['AddonListEntry'..i..'Title']
		local status = _G['AddonListEntry'..i..'Status']

		Skins.ThemeCheckBox(button)
		name:SetFont(Skins.default_font, Skins.default_font_size, 'NONE')
		status:SetFont(Skins.default_font, Skins.default_font_size, 'NONE')
	end

	Skins.ThemeCheckBox(AddonListForceLoad)
	Skins.SetAllFontString(AddonListForceLoad, Skins.default_font, Skins.default_font_size, 'NONE')

end

E:OnInit2(Skin_AddonManager)