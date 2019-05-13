local Skins = AleaUI:Module("Skins")
local _G = _G

local default_background_color = Skins.default_background_color
local default_border_color = Skins.default_border_color
local default_font = Skins.default_font
local default_texture = Skins.default_texture

local default_button_background = Skins.default_button_background
local default_button_border 	= Skins.default_button_border
local default_border_color_dark = Skins.default_border_color_dark

local varName = 'voidstorage'
AleaUI.default_settings.skins[varName] = true

local function Skin_VoidStorage()
	if not AleaUI.db.skins.enableAll then return end
	if not AleaUI.db.skins[varName] then return end

	_G['VoidStorageBorderFrame']:StripTextures()
	Skins.ThemeBackdrop('VoidStorageBorderFrame')
	VoidStorageBorderFrame.Bg:Kill()	
	VoidStorageFrame:StripTextures()
	
	VoidStorageDepositFrame:StripTextures()
	Skins.ThemeBackdrop('VoidStorageDepositFrame')
	
	VoidStorageWithdrawFrame:StripTextures()
	Skins.ThemeBackdrop('VoidStorageWithdrawFrame')
	
	VoidStorageStorageFrame:StripTextures()
	Skins.ThemeBackdrop('VoidStorageStorageFrame')
	
	for i=1, 80 do		
		Skins.ThemeItemButton('VoidStorageStorageButton'..i)		
	end
	
	for i=1, 9 do
		Skins.ThemeItemButton('VoidStorageDepositButton'..i)
		Skins.ThemeItemButton('VoidStorageWithdrawButton'..i)
	end
	
	VoidStorageCostFrame:StripTextures()
--	Skins.ThemeBackdrop('VoidStorageStorageFrame')
	Skins.ThemeButton('VoidStorageTransferButton')
	
	-- VoidItemSearchBox
	
	Skins.ThemeEditBox('VoidItemSearchBox', true, width, height)
	
	local function SkinTab(tab)
		tab:DisableDrawLayer('BACKGROUND')
		tab:GetNormalTexture():SetTexCoord(unpack(AleaUI.media.texCoord))
		tab:GetNormalTexture():SetSize(20, 20)
	
		tab.pushed = true;
		
		local checked = tab:GetCheckedTexture()
		local step = 0.06
		checked:SetTexCoord(step, 1-step, step, 1-step)
		
		Skins.ThemeBackdrop(tab)

		local point, relatedTo, point2, x, y = tab:GetPoint()
		tab:SetPoint(point, relatedTo, point2, 1, y)
	end

	--Skill Line Tabs
	for i=1, 2 do
		SkinTab(VoidStorageFrame['Page'..i])
	end
	
	
	--[==[
	_G['ItemSocketingFrame']:StripTextures()
	_G['ItemSocketingFrameInset']:StripTextures()
	Skins.ThemeBackdrop('ItemSocketingFrame')
	Skins.ThemeFrameRing('ItemSocketingFrame')

	Skins.ThemeButton('ItemSocketingSocketButton')
	
	Skins.ThemeScrollBar('ItemSocketingScrollFrameScrollBar')
	
	Skins.ThemeBackdrop('ItemSocketingScrollFrame')

	ItemSocketingFrame:HookScript('OnShow', function()	
		for i=1, 3 do
			local button = _G['ItemSocketingSocket'..i]		
			
			if button and not button.hooked then			
				button.hooked = true
				Skins.ThemeSocket('ItemSocketingSocket'..i)
			end
		end
	end)
	]==]
end

AleaUI:OnAddonLoad('Blizzard_VoidStorageUI', Skin_VoidStorage)
