local addonName, E = ...
local Skins = E:Module("Skins")
local _G = _G

local varName = 'merchantframe'
E.default_settings.skins[varName] = true

local default_background_color = Skins.default_background_color
local default_border_color = Skins.default_border_color
local default_font = Skins.default_font
local default_texture = Skins.default_texture

local default_button_background = Skins.default_button_background
local default_button_border 	= Skins.default_button_border
local default_border_color_dark = Skins.default_border_color_dark

local function Skin_MerchantFrame()
	if not E.db.skins.enableAll then return end
	if not E.db.skins[varName] then return end

	MerchantFrame:StripTextures()
	MerchantMoneyFrame:StripTextures()
	MerchantMoneyBg:SetAlpha(0)
	MerchantMoneyInset:SetAlpha(0)
	MerchantFrameInset:StripTextures()

	MerchantExtraCurrencyBg:SetAlpha(0)
	MerchantExtraCurrencyBgMiddle:SetAlpha(0)
	MerchantExtraCurrencyInset:SetAlpha(0)

	Skins.ThemeBackdrop('MerchantFrame')
	Skins.ThemeBackdrop('MerchantFrameInset')

	for i=1, 2 do
		Skins.ThemeTab('MerchantFrameTab'..i)
	end

	for i=1, 12 do
		Skins.MerchantItems('MerchantItem'..i)
	end

	Skins.MerchantItems('MerchantBuyBackItem', true)

	Skins.ThemeDropdown('MerchantFrameLootFilter')


	Skins.ThemeFrameRing('MerchantFrame')

	Skins.ThemeIconButton(MerchantPrevPageButton, true)
	Skins.ThemeIconButton(MerchantNextPageButton, true)
end

E:OnInit2(Skin_MerchantFrame)