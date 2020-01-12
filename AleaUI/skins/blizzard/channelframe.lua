local Skins = AleaUI:Module("Skins")
local _G = _G

local default_background_color = Skins.default_background_color
local default_border_color = Skins.default_border_color
local default_font = Skins.default_font
local default_texture = Skins.default_texture

local default_button_background = Skins.default_button_background
local default_button_border 	= Skins.default_button_border
local default_border_color_dark = Skins.default_border_color_dark

local buttons_name = Skins.buttons_name

local varName = 'channels'
AleaUI.default_settings.skins[varName] = true


local function LoadSkin()
    if not AleaUI.db.skins.enableAll then return end
	if not AleaUI.db.skins[varName] then return end
        
    
    ChannelFrame:StripTextures()
	Skins.ThemeBackdrop('ChannelFrame')
	
    ChannelFrame.NineSlice:StripTextures()

    ChannelFrame.RightInset.NineSlice:StripTextures()
    ChannelFrame.RightInset.Bg:SetAlpha(0)

    ChannelFrame.LeftInset.NineSlice:StripTextures()
    ChannelFrame.LeftInset.Bg:SetAlpha(0)

    ChannelFrameInset.NineSlice:StripTextures()
    ChannelFrame.Inset:StripTextures()

    Skins.ThemeScrollBar(ChannelFrame.ChannelRoster.ScrollFrame.scrollBar)

    Skins.ThemeButton(ChannelFrame.NewButton)
    Skins.ThemeButton(ChannelFrame.SettingsButton)


    CreateChannelPopup:StripTextures()
    Skins.ThemeBackdrop('CreateChannelPopup')
    CreateChannelPopup.BG:StripTextures()

    Skins.ThemeButton(CreateChannelPopup.OKButton)
    Skins.ThemeButton(CreateChannelPopup.CancelButton)

    Skins.ThemeEditBox(CreateChannelPopup.Name, false, 140, 20)
    Skins.ThemeEditBox(CreateChannelPopup.Password, false, 140, 20)

    --ChannelFrame.ChannelList.Child

    -- hooksecurefunc(ChannelFrame, 'Update', function(arg)
    --     print(self, arg)
    -- end)
end


AleaUI:OnInit(function()
	if _G["ChannelFrame"] then
		LoadSkin()
	else
		E:OnAddonLoad('Blizzard_Channels', LoadSkin)
	end
end)