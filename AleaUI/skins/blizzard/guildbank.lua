--Blizzard_GuildBankUI
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

local varName = 'guildbank'
E.default_settings.skins[varName] = true

local function Skin_GuildBank()
	if not E.db.skins.enableAll then return end
	if not E.db.skins[varName] then return end

	local function SkinTab(frame, tab)
		frame:DisableDrawLayer('BACKGROUND')
	
		local tab = _G[frame:GetName()..'Button']
		--[==[
		tab:DisableDrawLayer('BACKGROUND')
		tab:GetNormalTexture():SetTexCoord(unpack(E.media.texCoord))
		tab:GetNormalTexture():SetSize(20, 20)
		
		local icon = _G[frame:GetName()..'ButtonIconTexture']
		icon:SetTexCoord(unpack(E.media.texCoord))
		
		tab.pushed = true;
		
		local checked = tab:GetCheckedTexture()
		local step = 0.06
		checked:SetTexCoord(step, 1-step, step, 1-step)
		
		Skins.ThemeBackdrop(tab, icon)

		local point, relatedTo, point2, x, y = tab:GetPoint()
		tab:SetPoint(point, relatedTo, point2, 1, y)
		]==]
		
		Skins.ThemeItemButton(tab)
		
		local checked = tab:GetCheckedTexture()
		local step = 0.06
		checked:SetTexCoord(step, 1-step, step, 1-step)
	end

	--Skill Line Tabs
	for i=1, 8 do
		SkinTab(_G['GuildBankTab'..i])
	end
	
	GuildBankFrame:StripTextures()
	Skins.ThemeBackdrop('GuildBankFrame')
	
	for i=1, 4 do
		Skins.ThemeTab('GuildBankFrameTab'..i)
	end
	
	GuildBankMoneyFrameBackground:StripTextures()
	
	Skins.ThemeButton('GuildBankFrameWithdrawButton')
	Skins.ThemeButton('GuildBankFrameDepositButton')
	
	GuildBankFrameWithdrawButton:RePointHorizontal(-3)
	
	Skins.ThemeEditBox('GuildItemSearchBox', true)
	
	for col=1, 7 do
		_G['GuildBankColumn'..col]:StripTextures()
		for but=1, 14 do
			Skins.ThemeItemButton('GuildBankColumn'..col..'Button'..but)
		end
	end
	
	Skins.ThemeScrollBar('GuildBankTransactionsScrollFrameScrollBar')
	Skins.ThemeScrollBar('GuildBankInfoScrollFrameScrollBar')
end

E:OnAddonLoad('Blizzard_GuildBankUI', Skin_GuildBank)