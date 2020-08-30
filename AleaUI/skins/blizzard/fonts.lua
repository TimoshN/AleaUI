local addonName, E = ...

local function FixFontShadow(obj)
	local x, y = obj:GetShadowOffset()
	if y > -2 and y < 0 then
		obj:SetShadowOffset(x, -2)
	end
end
	
local function SetFont(obj, font, size, style, r, g, b, sr, sg, sb, sox, soy)
	if not obj then E.print('Unable to find font object'); return; end 
	
	obj:SetFont(font, size, style or "")
	if sr and sg and sb then obj:SetShadowColor(sr, sg, sb) end
	if sox and soy then obj:SetShadowOffset(sox, soy) end
	if r and g and b then obj:SetTextColor(r, g, b)
	elseif r then obj:SetAlpha(r) end
	
--	FixFontShadow(obj)
end

function E:UpdateBlizzardFont()
	
	local ZONE		 = E.media.default_font2
	local COMBAT	 = E.media.default_font2
	local EDITBOX	 = E.media.default_font2
	local NORMAL     = E.media.default_font2
	local NUMBER     = E.media.default_font2
	local NAMES		 = E.media.default_font2
	local MONOCHROME = ''
	
	--setglobal('UIDROPDOWNMENU_DEFAULT_TEXT_HEIGHT',12)
	setglobal('CHAT_FONT_HEIGHTS',{6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20})


	UNIT_NAME_FONT     = E.media.default_font2
	DAMAGE_TEXT_FONT   = E.media.default_font2
	setglobal('STANDARD_TEXT_FONT', NORMAL)

	-- Base fonts
	--SetFont(NumberFontNormal,					LSM:Fetch('font', 'ElvUI Pixel'), 10, 'MONOCHROMEOUTLINE', 1, 1, 1, 0, 0, 0)
	SetFont(GameTooltipHeader,                  NORMAL, E.media.default_font_size2)
	SetFont(NumberFont_OutlineThick_Mono_Small, NUMBER, E.media.default_font_size2, "OUTLINE")
	SetFont(SystemFont_Shadow_Large_Outline,	NUMBER, 20, "OUTLINE")
	SetFont(NumberFont_Outline_Huge,            NUMBER, 28, MONOCHROME.."THICKOUTLINE", 28)
	SetFont(NumberFont_Outline_Large,           NUMBER, 15, MONOCHROME.."OUTLINE")
	SetFont(NumberFont_Outline_Med,             NUMBER, E.media.default_font_size2*1.1, "OUTLINE")
	SetFont(NumberFont_Shadow_Med,              NORMAL, E.media.default_font_size2) --chat editbox uses this
	SetFont(NumberFont_Shadow_Small,            NORMAL, E.media.default_font_size2)
	SetFont(QuestFont,                          NORMAL, E.media.default_font_size2)
	SetFont(QuestFont_Large,                    NORMAL, 14)
	SetFont(SystemFont_Large,                   NORMAL, 15)
	SetFont(GameFontNormalMed3,					NORMAL, 15)
	SetFont(SystemFont_Shadow_Huge1,			NORMAL, 20, MONOCHROME.."OUTLINE") -- Raid Warning, Boss emote frame too
	SetFont(SystemFont_Med1,                    NORMAL, E.media.default_font_size2)
	SetFont(SystemFont_Med3,                    NORMAL, E.media.default_font_size2*1.1)
	SetFont(SystemFont_OutlineThick_Huge2,      NORMAL, 20, MONOCHROME.."THICKOUTLINE")
	SetFont(SystemFont_Outline_Small,           NUMBER, E.media.default_font_size2, "OUTLINE")
	SetFont(SystemFont_Shadow_Large,            NORMAL, 15)
	SetFont(SystemFont_Shadow_Med1,             NORMAL, E.media.default_font_size2)
	SetFont(SystemFont_Shadow_Med3,             NORMAL, E.media.default_font_size2*1.1)
	SetFont(SystemFont_Shadow_Outline_Huge2,    NORMAL, 20, MONOCHROME.."OUTLINE")
	SetFont(SystemFont_Shadow_Small,            NORMAL, E.media.default_font_size2*0.9)
	SetFont(SystemFont_Small,                   NORMAL, E.media.default_font_size2)
	SetFont(SystemFont_Tiny,                    NORMAL, E.media.default_font_size2)
	SetFont(Tooltip_Med,                        NORMAL, E.media.default_font_size2)
	SetFont(Tooltip_Small,                      NORMAL, E.media.default_font_size2)
	SetFont(ZoneTextString,						NORMAL, 32, MONOCHROME.."OUTLINE")
	SetFont(SubZoneTextString,					NORMAL, 25, MONOCHROME.."OUTLINE")
	SetFont(PVPInfoTextString,					NORMAL, 22, MONOCHROME.."OUTLINE")
	SetFont(PVPArenaTextString,					NORMAL, 22, MONOCHROME.."OUTLINE")
	SetFont(CombatTextFont,                     COMBAT, 32, "OUTLINE") -- number here just increase the font quality.
	--	FixFontShadow(CombatTextFont)
	
	SetFont(FriendsFont_Normal, 				NORMAL, E.media.default_font_size2)
	SetFont(FriendsFont_Small, 					NORMAL, E.media.default_font_size2)
	SetFont(FriendsFont_Large, 					NORMAL, E.media.default_font_size2)
	SetFont(FriendsFont_UserText, 				NORMAL, E.media.default_font_size2)
	
	SetFont(ChatBubbleFont, 					NORMAL, 12)
	SetFont(SystemFont_NamePlateFixed,			NORMAL, 10, "OUTLINE")
end