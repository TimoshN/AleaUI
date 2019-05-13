local Skins = AleaUI:Module("Skins")
local _G = _G

local default_background_color = Skins.default_background_color
local default_border_color = Skins.default_border_color
local default_font = Skins.default_font
local default_texture = Skins.default_texture

local default_button_background = Skins.default_button_background
local default_button_border 	= Skins.default_button_border
local default_border_color_dark = Skins.default_border_color_dark

local varName = 'communities'
AleaUI.default_settings.skins[varName] = true
	
AleaUI:OnAddonLoad('Blizzard_Communities', function()
	--if not AleaUI.db.skins.enableAll then return end
	--if not AleaUI.db.skins[varName] then return end

    CommunitiesFrame:StripTextures()
    CommunitiesFrame.MaximizeMinimizeFrame:StripTextures()

    CommunitiesFrame.PortraitOverlay:Kill()

    CommunitiesFrameCommunitiesList:StripTextures()
    CommunitiesFrameCommunitiesList.InsetFrame:StripTextures()
   -- Skins.MassKillTexture('CommunitiesFrameCommunitiesList')

    CommunitiesFrameCommunitiesList.Bg:SetAlpha(0)
    CommunitiesFrameCommunitiesList.FilligreeOverlay:StripTextures()
    CommunitiesFrameInset:StripTextures()

    CommunitiesFrame.Chat.InsetFrame:StripTextures()
    CommunitiesFrame.MemberList.InsetFrame:StripTextures()

    local temp = Skins.NewBackdrop(CommunitiesFrame)	
	temp:SetBackdropColor(default_background_color[1], default_background_color[2], default_background_color[3], 1)
    temp:SetBackdropBorderColor(default_border_color[1], default_border_color[2], default_border_color[3],1)
    
    Skins.ThemeScrollBar(CommunitiesFrameCommunitiesListListScrollFrame.ScrollBar)
    Skins.ThemeScrollBar(CommunitiesFrame.Chat.MessageFrame.ScrollBar)
    Skins.ThemeScrollBar(CommunitiesFrame.MemberList.ListScrollFrame.scrollBar)

    Skins.ThemeDropdown(CommunitiesFrame.StreamDropDownMenu)

    Skins.ThemeButton(CommunitiesFrame.InviteButton)

    Skins.ThemeEditBox(CommunitiesFrame.ChatEditBox) --, realSize, width, height)

    --[==[
	Skins.MassKillTexture('HonorFrame')
	
	Skins.ThemeDropdown('HonorFrameTypeDropDown')
	
	HonorFrame.Inset:StripTextures()
	HonorFrameBg:SetAlpha(0)
	HonorFrame.BonusFrame:StripTextures()
	HonorFrame.BonusFrame.ShadowOverlay:Hide()
	
	HonorFrameQueueButton_RightSeparator:SetAlpha(0)
	HonorFrameQueueButton_LeftSeparator:SetAlpha(0)
	
	Skins.ThemeButton('HonorFrameQueueButton')
	
	Skins.ThemeScrollBar('HonorFrameSpecificFrameScrollBar')

	PVPQueueFrame.HonorInset.CasualPanel:StripTextures()
	Skins.MassKillTexture('PVPQueueFrame')
	PVPQueueFrame.HonorInset:StripTextures()
	
	ConquestFrame:StripTextures()

    Skins.ThemeButton('ConquestJoinButton')
    ]==]
end)