local addonName, E = ...
local Skins = E:Module("Skins")
local _G = _G
local L = E.L

local error = function(...)

	print(debugstack(2), ...)
end 

E.default_settings.skins = {
	enableAll = true,
}
E.default_settings.skins_custom = {

}

Skins.buttons_name = { "◄", "▲", "▼", "►" }
local buttons_name = Skins.buttons_name

Skins.default_background_color = { 0.1,0.1,0.1,0.8 }
Skins.default_border_color = {0,0,0,1}
Skins.default_font = E.media.default_font2
Skins.default_texture = E.media.default_bar_texture1

Skins.default_button_background = { 0.1,0.1,0.1,0.9 }
Skins.default_button_border 	= { 0.4,0.4,0.4,1 }
Skins.default_border_color_dark = { 0.3,0.3,0.3,1 }

local default_background_color = Skins.default_background_color
local default_border_color = Skins.default_border_color
local default_font = Skins.default_font
local default_texture = Skins.default_texture

local default_button_background = Skins.default_button_background
local default_button_border 	= Skins.default_button_border
local default_border_color_dark = Skins.default_border_color_dark
 
local default_font_size = 12
Skins.default_font_size = default_font_size
 
local unusedOverlayGlows = {}
local numOverlayGlows = 0

local HidenParent = CreateFrame('Frame')
HidenParent:Hide()
local default_backdrop = { 
	bgFile = [[Interface\Buttons\WHITE8x8]], 
	edgeFile =	[[Interface\Buttons\WHITE8x8]],
	edgeSize = 1,
}
	
local function OverlayGlowAnimOutFinished(animGroup)
  local overlay = animGroup:GetParent()
  local frame = overlay:GetParent()
  overlay:Hide()
  tinsert(unusedOverlayGlows, overlay)
  frame._aleauioverlay = nil
end

Skins.OverlayGlowAnimOutFinished = OverlayGlowAnimOutFinished

local function OverlayGlow_OnHide(self)
  if self.animOut:IsPlaying() then
    self.animOut:Stop()
    OverlayGlowAnimOutFinished(self.animOut)
  end
end

local function GetOverlayGlow()
  local overlay = tremove(unusedOverlayGlows)
  if not overlay then
   numOverlayGlows = numOverlayGlows + 1
    overlay = CreateFrame("Frame", "AleaUIGlow"..numOverlayGlows, UIParent, "AleaUISpellActivationAlert")
    overlay.animOut:SetScript("OnFinished", OverlayGlowAnimOutFinished)
    overlay:SetScript("OnHide", OverlayGlow_OnHide)
  end
  return overlay
end

local glow_spacing = 0.2

local function ShowOverlayGlow(frame)
  if frame._aleauioverlay then
    if frame._aleauioverlay.animOut:IsPlaying() then
      frame._aleauioverlay.animOut:Stop()
      frame._aleauioverlay.animIn:Play()
    end
  elseif frame:IsVisible() then
    local overlay = GetOverlayGlow()
    local frameWidth, frameHeight = frame:GetSize()
    overlay:SetParent(frame)
    overlay:ClearAllPoints()
    overlay:SetSize(frameWidth * 1.4, frameHeight * 1.4)
    overlay:SetPoint("TOPLEFT", frame, "TOPLEFT", -frameWidth * glow_spacing, frameHeight * glow_spacing)
    overlay:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", frameWidth * glow_spacing, -frameHeight * glow_spacing)
    overlay.animIn:Play()
	
	frame._aleauioverlay = overlay
  end
end

Skins.ShowOverlayGlow = ShowOverlayGlow

local function HideOverlayGlow(frame)
  if frame._aleauioverlay then
    if frame._aleauioverlay.animIn:IsPlaying() then
      frame._aleauioverlay.animIn:Stop()
    end
    if frame:IsVisible() then
      frame._aleauioverlay.animOut:Play()
    else
      OverlayGlowAnimOutFinished(frame._aleauioverlay.animOut)
    end
  end
end

Skins.HideOverlayGlow = HideOverlayGlow

function Skins.ThemeBackdrop(frame)
	local f = _G[frame] or frame
	if not f or type(f) == 'string' then 
		error('Unknown '..tostring(frame or 'nil'))
		return 
	end
	
	Skins.SetAllFontString(f, default_font, default_font_size, 'NONE')
	
	if not f.themedbackdrop then
		f.themedbackdrop = true
		f:SetBackdrop({})
		f:SetBackdropColor(0,0,0,0)
		f:SetBackdropBorderColor(0,0,0,0)
		
		
		E:CreateBackdrop(f, f, default_border_color, default_background_color)
		
		f:SetUIBackgroundDrawLayer('BACKGROUND', -1)
	end
	
	if ( f.TitleBg ) then 
		f.TitleBg:Kill()
	end

	if f.BorderFrame then
		if f.BorderFrame.NineSlice then
			f.BorderFrame.NineSlice:StripTextures()

			f.BorderFrame.NineSlice.TopLeftCorner:Kill()
			f.BorderFrame.NineSlice.TopRightCorner:Kill()

			f.BorderFrame.NineSlice.BottomLeftCorner:Kill()
			f.BorderFrame.NineSlice.BottomRightCorner:Kill()

			f.BorderFrame.NineSlice.TopEdge:Kill()
			f.BorderFrame.NineSlice.BottomEdge:Kill()
			f.BorderFrame.NineSlice.LeftEdge:Kill()
			f.BorderFrame.NineSlice.RightEdge:Kill()
		end
	else 		
		if f.NineSlice then
			f.NineSlice:StripTextures()

			f.NineSlice.TopLeftCorner:Kill()
			f.NineSlice.TopRightCorner:Kill()

			f.NineSlice.BottomLeftCorner:Kill()
			f.NineSlice.BottomRightCorner:Kill()

			f.NineSlice.TopEdge:Kill()
			f.NineSlice.BottomEdge:Kill()
			f.NineSlice.LeftEdge:Kill()
			f.NineSlice.RightEdge:Kill()
		end
	end 

	if ( f.Border ) then 

		f.Border.Bg:Kill()
		f.Border.TopEdge:Kill()
		f.Border.BottomEdge:Kill()
		f.Border.LeftEdge:Kill()
		f.Border.RightEdge:Kill()

		f.Border.TopLeftCorner:Kill()
		f.Border.TopRightCorner:Kill()

		f.Border.BottomLeftCorner:Kill()
		f.Border.BottomRightCorner:Kill()
	end
end


local function OnEnterButtonBorder(self)
	self.modborder:SetUIBackdropBorderColor(1, 1, 1, 1)
end

local function OnLeaveButtonBorder(self)
	
	self.modborder:SetUIBackdropBorderColor(self.modborder.r, self.modborder.g, self.modborder.b, self.modborder.a)
end

function Skins.ThemeButtonBackdrop(frame, point)
	local f = _G[frame] or frame
	if not f or type(f) == 'string' then 
		error('Unknown '..tostring(frame or 'nil'))
		return 
	end
	
	local temp = f.modborder or CreateFrame('Frame', nil, f)
	f:SetFrameLevel(f:GetFrameLevel()+3)
	temp:SetFrameLevel(max((f:GetFrameLevel()-1), 0))
	temp:EnableMouse(false)
	--temp:SetBackdrop(default_backdrop)
	--temp:SetBackdropColor(default_background_color[1], default_background_color[2], default_background_color[3], 1)
	--temp:SetBackdropBorderColor(default_border_color_dark[1], default_border_color_dark[2], default_border_color_dark[3], default_border_color_dark[4])

	temp:SetOutside(point or f)
		
	E:CreateBackdrop(temp, nil, default_border_color_dark, default_background_color)
	
	if not f.modborder then
	
		temp.r = default_border_color_dark[1]
		temp.g = default_border_color_dark[2]
		temp.b = default_border_color_dark[3]
		temp.a = default_border_color_dark[4]
		
		Skins.HandleScript(f, 'OnEnter', OnEnterButtonBorder)	
		Skins.HandleScript(f, 'OnLeave', OnLeaveButtonBorder)	
	end
	
	f.modborder = temp

	return temp
end

function Skins.ChangeButtonBorder(frame, color)
	local f = _G[frame] or frame
	if not f or type(f) == 'string' then 
		error('Unknown '..tostring(frame or 'nil'))
		return 
	end
	if not f.modborder then return end
	
	if color == 'DARK' then
		f.modborder.r = 0
		f.modborder.g = 0
		f.modborder.b = 0
		f.modborder.a = 1
	else
		f.modborder.r = default_border_color_dark[1]
		f.modborder.g = default_border_color_dark[2]
		f.modborder.b = default_border_color_dark[3]
		f.modborder.a = default_border_color_dark[4]
	end
	
	f.modborder:SetBackdropBorderColor(f.modborder.r, f.modborder.g, f.modborder.b, f.modborder.a)
end

function Skins.NewBackdrop(frame, point, color)
	local f = _G[frame] or frame
	if not f or type(f) == 'string' then 
		error('Unknown '..tostring(frame or 'nil'))
		return 
	end
	
	
	local temp = CreateFrame('Frame', nil, f)
	temp:EnableMouse(false)
	temp:SetFrameLevel(max((f:GetFrameLevel()-1), 0))
	temp:SetBackdrop(default_backdrop)
	temp:SetBackdropColor(default_background_color[1], default_background_color[2], default_background_color[3], default_background_color[4])
	temp:SetBackdropBorderColor(default_border_color_dark[1], default_border_color_dark[2], default_border_color_dark[3], default_border_color_dark[4])
	
	temp:SetAllPoints(point or f)
	
	return temp
end

function Skins.SetTemplate(frame, template)
	local f = _G[frame] or frame
	if not f or type(f) == 'string' then 
		error('Unknown '..tostring(frame or 'nil'))
		return 
	end
	
	f:SetBackdrop(default_backdrop)

	if template == 'DARK' or not template then
		f:SetBackdropColor(default_background_color[1], default_background_color[2], default_background_color[3], default_background_color[4])
		f:SetBackdropBorderColor(default_border_color[1], default_border_color[2], default_border_color[3],default_border_color[4])
	elseif template == 'GREY' then
		f:SetBackdropColor(default_background_color[1], default_background_color[2], default_background_color[3], default_background_color[4])
		f:SetBackdropBorderColor(default_border_color_dark[1], default_border_color_dark[2], default_border_color_dark[3], default_border_color_dark[4])
	elseif template == 'ALPHADARK' then
		f:SetBackdropColor(default_background_color[1], default_background_color[2], default_background_color[3], 0.4)
		f:SetBackdropBorderColor(default_border_color[1], default_border_color[2], default_border_color[3],default_border_color[4])
	elseif template == 'ALPHAGREY' then
		f:SetBackdropColor(default_background_color[1], default_background_color[2], default_background_color[3], 0.4)
		f:SetBackdropBorderColor(default_border_color_dark[1], default_border_color_dark[2], default_border_color_dark[3], default_border_color_dark[4])
	elseif template == 'BORDERED' then
		f:SetBackdropColor(default_background_color[1], default_background_color[2], default_background_color[3], 0)
		f:SetBackdropBorderColor(default_border_color[1], default_border_color[2], default_border_color[3],1)
	end
	
end

function Skins.GetFontSting(frame, text)
local f = _G[frame] or frame
	if not f or type(f) == 'string' then 
		error('Unknown '..tostring(frame or 'nil'))
		return 
	end
	
	for i=1, f:GetNumRegions() do
		local region = select(i, f:GetRegions());
		if(region:GetObjectType() == "FontString") then
			if text then
				if(region:GetText() == text) then
					return region
				end
			else
				return region
			end
		end
	end
end


function Skins.SetAllFontString(frame, font, size, flags)
	local f = _G[frame] or frame
	if not f or type(f) == 'string' then 
		error('Unknown '..tostring(frame or 'nil'))
		return 
	end

	for i=1, f:GetNumRegions() do
		local region = select(i, f:GetRegions());
		local objType = region:GetObjectType()
		if(objType == "FontString") then
			region:SetFont(font, size, flags)
			region:SetShadowOffset(1, -1)
			region:SetShadowColor(0, 0, 0, 1)
		end
	end
end


function Skins.ThemeEditBox(frame, realSize, width, height)
	local f = _G[frame] or frame
	if not f or type(f) == 'string' then 
		error('Unknown '..tostring(frame or 'nil'))
		return 
	end
	
	local name = f:GetName()
	
	if name then
	
		if _G[f:GetName()..'Left'] then
			_G[f:GetName()..'Left']:SetTexture('')
		end
		
		if _G[f:GetName()..'Right'] then
			_G[f:GetName()..'Right']:SetTexture('')
		end
		
		if _G[f:GetName()..'Mid'] then
			_G[f:GetName()..'Mid']:SetTexture('')
		end
		
		if _G[f:GetName()..'Middle'] then
			_G[f:GetName()..'Middle']:SetTexture('')
		end
	end
	
	if f.Middle then
		f.Middle:SetAlpha(0)
		f.Middle:SetParent(HidenParent)
	end
	if f.Left then
		f.Left:SetAlpha(0)
		f.Left:SetParent(HidenParent)
	end
	if f.Right then
		f.Right:SetAlpha(0)
		f.Right:SetParent(HidenParent)
	end
	
	if f.Mid then
		f.Mid:SetAlpha(0)
		f.Mid:SetParent(HidenParent)
	end
	
	local bg = f:CreateTexture(nil, 'BACKGROUND')
	bg:SetColorTexture(0.05,0.05,0.05,0.9)
	
	local temp = CreateFrame('Frame', nil, f)
	temp:SetFrameLevel(f:GetFrameLevel()+1)
	temp:EnableMouse(false)
	temp:SetBackdrop(default_backdrop)
	temp:SetBackdropColor(0.05,0.05,0.05,0)
	temp:SetBackdropBorderColor(default_button_border[1], default_button_border[2], default_button_border[3], default_button_border[4])
	
	bg:SetAllPoints(temp)
	
	if width then
		temp:SetPoint('TOPLEFT', f, 'TOPLEFT', -2, -1)
		temp:SetSize(width, height or 18)
	elseif realSize then
		temp:SetPoint('TOPLEFT', f, 'TOPLEFT', -2, -1)
		temp:SetPoint('BOTTOMRIGHT', f, 'BOTTOMRIGHT', -2, 1)
	else
		temp:SetPoint('TOPLEFT', f, 'TOPLEFT', -3, -5)
		temp:SetPoint('BOTTOMRIGHT', f, 'BOTTOMRIGHT', 3, 5)
	end
	
	return temp, f
end

function Skins.ThemeButton(frame)
	local f = _G[frame] or frame
	if not f or type(f) == 'string' then 
		error('Unknown '..tostring(frame or 'nil'))
		return 
	end
	
	local name = f:GetName()
	
	f:StripTextures()
	
	if f.Left then f.Left:Hide() end
	if f.Right then f.Right:Hide() end
	if f.Middle then f.Middle:Hide() end
	
	if name and _G[name..'_LeftSeparator'] then
		_G[name..'_LeftSeparator']:SetAlpha(0)
	end
	
	if name and _G[name..'_RightSeparator'] then
		_G[name..'_RightSeparator']:SetAlpha(0)
	end
	
	if name and _G[name..'Border'] then
		_G[name..'Border']:SetAlpha(0)
	end
	
	if f.LeftSeparator then f.LeftSeparator:SetAlpha(0) end	
	if f.RightSeparator then f.RightSeparator:SetAlpha(0) end
	
	if f.SetNormalTexture then f:SetNormalTexture('') end
	
	if f.SetPushedTexture then f:SetPushedTexture('') end
	
	if f.SetDisabledTexture then
		f:SetDisabledTexture('')
	end

	if f.Flash then
		f.Flash:SetAlpha(0)
	end
	
	local temp = Skins.ThemeButtonBackdrop(f)
	
	
	temp:SetInside(f)

	if f.GetHighlightTexture then
		f:GetHighlightTexture():SetTexture('')
	--	f:GetHighlightTexture():SetVertexColor(0.2, 0.2, 0.2, 1)
	end
	
	Skins.SetAllFontString(frame, default_font, default_font_size, 'OUTLINE')
	
	return temp, f
end

function Skins.ThemeStatusBar(frame)
	local f = _G[frame] or frame
	if not f or type(f) == 'string' then 
		error('Unknown '..tostring(frame or 'nil'))
		return 
	end
	
	local name = f:GetName()
	
	f:SetStatusBarTexture(default_texture)
	f:SetStatusBarColor(0, 1, 0, 1)
	f:SetHeight(12)
	
	Skins.SetAllFontString(frame, default_font, default_font_size, 'NONE')
	
	if _G[name..'BGMiddle'] then _G[name..'BGMiddle']:SetAlpha(0) end
	if _G[name..'BGRight'] then _G[name..'BGRight']:SetAlpha(0) end
	if _G[name..'BGLeft'] then _G[name..'BGLeft']:SetAlpha(0) end
	if _G[name..'Middle'] then _G[name..'Middle']:SetAlpha(0) end
	if _G[name..'Right'] then _G[name..'Right']:SetAlpha(0) end
	if _G[name..'Left'] then _G[name..'Left']:SetAlpha(0) end
	if _G[name..'LeftTexture'] then _G[name..'LeftTexture']:SetAlpha(0) end
	if _G[name..'RightTexture'] then _G[name..'RightTexture']:SetAlpha(0) end
	
	if _G[name..'Rank'] then
		_G[name..'Rank']:ClearAllPoints()
		_G[name..'Rank']:SetPoint('BOTTOM', f, 'BOTTOM', 0, 1)
	end
	
	local temp = CreateFrame('Frame', nil, f)
	temp:SetFrameLevel(f:GetFrameLevel()-1)
	temp:EnableMouse(false)
	temp:SetBackdrop(default_backdrop)
	temp:SetBackdropColor(default_background_color[1], default_background_color[2], default_background_color[3], default_background_color[4])
	temp:SetBackdropBorderColor(default_border_color[1], default_border_color[2], default_border_color[3], default_border_color[4])
	temp:SetPoint('TOPLEFT', f, 'TOPLEFT', -1, 1)
	temp:SetPoint('BOTTOMRIGHT', f, 'BOTTOMRIGHT', 1, -1)
	
end

function Skins.HandleScript(frame, script, func)	
	if frame:GetScript(script) then
		frame:HookScript(script,func)
	else
		frame:SetScript(script,func)
	end
end

function Skins.ThemeTab(frame, lowerTop)
	local f = _G[frame] or frame
	if not f or type(f) == 'string' then 
		error('Unknown '..tostring(frame or 'nil'))
		return 
	end
	
	local name = f:GetName()
	
	f:StripTextures()

	local text = _G[name..'Text']
	text:SetFont(default_font, default_font_size-1, 'NONE')
	text:SetShadowOffset(1, -1)
	text:SetShadowColor(0, 0, 0, 1)
	
	local temp = CreateFrame('Frame', nil, f)
	temp:SetFrameLevel(f:GetFrameLevel()-1)
	temp:EnableMouse(false)
	temp:SetBackdrop(default_backdrop)
	temp:SetBackdropColor(default_background_color[1], default_background_color[2], default_background_color[3], default_background_color[4])
	temp:SetBackdropBorderColor(default_border_color[1], default_border_color[2], default_border_color[3], default_border_color[4])
	temp:SetPoint('TOP', f, 'TOP', 0, lowerTop or -1)
	
	temp:SetPoint('BOTTOMLEFT', text, 'BOTTOMLEFT', -11, -7)
	temp:SetPoint('BOTTOMRIGHT', text, 'BOTTOMRIGHT', 11, -7)
	
	return temp
end

local massKillVariation = {
	'Bg',
	'InsetBottomBorder',
	'InsetBotRightCorner',
	'InsetBotRightCorner',
	'InsetBotLeftCorner',
	'InsetLeftBorder',
	'InsetTopLeftCorner',
	'InsetTopRightCorner', 'InsetInsetTopRightCorner',
	'InsetRightBorder',
	'InsetBg',
	'LeftInset', 
	'LeftInsetBg', 
	'LeftInsetInsetLeftBorder',
	'InsetTopBorder',
	'TalentsBg', 
	'BtnCornerRight', 'RightBorder', 
	'BtnCornerLeft', 'LeftBorder',
	'ButtonBottomBorder', 'BottomBorder',
	'BotRightCorner', 'BotLeftCorner', 'InsetBackground', --'BRCorner', 'BLCorner',
	'InsetInsetBottomBorder', 'InsetInsetLeftBorder', 'InsetInsetRightBorder', 'InsetInsetBotLeftCorner','InsetInsetBotRightCorner',
	'TopBorder', 'InsetInsetTopBorder', 'TopRightCorner', 'TitleBg',
	'TopTileStreaks',
	'InsetTopRightCorner',
	'InsetRightInsetBottomBorder', 'InsetRightBg','InsetRightInsetLeftBorder','InsetRightInsetBotLeftCorner',
	'InsetRightInsetRightBorder', 'InsetRightInsetBotRightCorner', 
	'InsetRightInsetTopRightCorner', 'InsetLeftInsetTopLeftCorner','InsetRightInsetTopBorder','InsetRightInsetTopLeftCorner', 
	'LeftInsetInsetBottomBorder', 'RoleBackground',
	'BottomInsetInsetLeftBorder',
	'BottomInsetInsetBottomBorder',
	'BottomInsetInsetBotLeftCorner','BottomInsetInsetTopLeftCorner','BottomInsetInsetTopRightCorner','BottomInsetInsetBotRightCorner',
	'RoleInsetBg','RoleInset', 'RoleInsetInsetBottomBorder','RoleInsetInsetLeftBorder','RoleInsetInsetRightBorder',
}

function Skins.MassKillTexture(globName, ...)	
	
	if select(1, ...) then
		for i=1, select('#', ...) do
			local name = select(i, ...)
			if _G[globName..name] then
				_G[globName..name]:SetAlpha(0)
			end
		end
	
	else
		for i, name in pairs(massKillVariation) do
			if _G[globName..name] then
				_G[globName..name]:SetAlpha(0)
			end
		end
	end

	local f = _G[globName]

	if f and f.NineSlice then
		f.NineSlice:StripTextures()

		f.NineSlice.TopLeftCorner:SetTexture(nil)
		f.NineSlice.TopRightCorner:SetTexture(nil)

		f.NineSlice.BottomLeftCorner:SetTexture(nil)
		f.NineSlice.BottomRightCorner:SetTexture(nil)
	end

	f = _G[globName..'Inset']

	if f and f.NineSlice then
		f.NineSlice:StripTextures()

		f.NineSlice.TopLeftCorner:SetTexture(nil)
		f.NineSlice.TopRightCorner:SetTexture(nil)

		f.NineSlice.BottomLeftCorner:SetTexture(nil)
		f.NineSlice.BottomRightCorner:SetTexture(nil)
	end
end

local function ScrollBar_FindUpButton(f)
	for i, frame in pairs({ f:GetChildren() }) do
		if frame and frame:GetName() and frame:GetName():find('UpButton') then
			f._ScrollUpButton = frame
			return frame
		end
	end
end

local function ScrollBar_FindDownButton(f)
	for i, frame in pairs({ f:GetChildren() }) do
		if frame and frame:GetName() and frame:GetName():find('DownButton') then
			f._ScrollDownButton = frame
			return frame
		end
	end
end
function Skins.ThemeScrollBar(frame)
	local f = _G[frame] or frame
	if not f or type(f) == 'string' then 
		print('Unknown ThemeScrollBar: '..tostring(frame or 'nil'))
		return 
	end
	
	local name = f:GetName()

	
	if name and _G[name..'Top'] then _G[name..'Top']:SetAlpha(0) end
	if name and _G[name..'Bottom'] then _G[name..'Bottom']:SetAlpha(0) end
	if name and _G[name..'Middle'] then _G[name..'Middle']:SetAlpha(0) end
	
	if not f:GetParent().StripTextures then
		print(f:GetParent():GetName())	
	else
		f:GetParent():StripTextures()
	end
	
	f:StripTextures()
	
	local topBtn = name and _G[name..'ScrollUpButton'] or f.ScrollUpButton or f.ScrollUp or ScrollBar_FindUpButton(f)
	local botBtn = name and _G[name..'ScrollDownButton'] or f.ScrollDownButton or f.ScrollDown or ScrollBar_FindDownButton(f)
	local slideBtn = name and _G[name..'ThumbTexture'] or f.ThumbTexture or f.thumbTexture
--	f:DisableDrawLayer('BACKGROUND')
	
	topBtn:SetNormalTexture('')
	topBtn:SetPushedTexture('')
	topBtn:SetDisabledTexture('')
	
	botBtn:SetNormalTexture('')
	botBtn:SetPushedTexture('')
	botBtn:SetDisabledTexture('')
	
	--[==[
	topBtn.arrow = topBtn:CreateFontString()
	topBtn.arrow:SetPoint('CENTER', topBtn, 'CENTER', 3, 0)
	topBtn.arrow:SetFont("Fonts\\ARIALN.TTF", 12, "OUTLINE")
	topBtn.arrow:SetJustifyH("CENTER")
	topBtn.arrow:SetJustifyV("CENTER")
	topBtn.arrow:SetText(buttons_name[2])
	topBtn.arrow:SetTextColor(0.8, 0.8, 0, 1)
	
	botBtn.arrow = botBtn:CreateFontString()
	botBtn.arrow:SetPoint('CENTER', botBtn, 'CENTER', 3, 0)
	botBtn.arrow:SetFont("Fonts\\ARIALN.TTF", 12, "OUTLINE")
	botBtn.arrow:SetJustifyH("CENTER")
	botBtn.arrow:SetJustifyV("CENTER")
	botBtn.arrow:SetText(buttons_name[3])
	botBtn.arrow:SetTextColor(0.8, 0.8, 0, 1)
	]==]

	topBtn.icon = topBtn:CreateTexture(nil, 'ARTWORK')
	topBtn.icon:SetSize(13, 13)
	topBtn.icon:SetPoint('CENTER')
	topBtn.icon:SetTexture([[Interface\Buttons\SquareButtonTextures]])
	topBtn.icon:SetTexCoord(0.01562500, 0.20312500, 0.01562500, 0.20312500)
	
	botBtn.icon = botBtn:CreateTexture(nil, 'ARTWORK')
	botBtn.icon:SetSize(13, 13)
	botBtn.icon:SetPoint('CENTER')
	botBtn.icon:SetTexture([[Interface\Buttons\SquareButtonTextures]])
	botBtn.icon:SetTexCoord(0.01562500, 0.20312500, 0.01562500, 0.20312500)
	
	SquareButton_SetIcon(topBtn, 'UP')
	SquareButton_SetIcon(botBtn, 'DOWN')
	
	Skins.NewBackdrop(f, topBtn)
	Skins.NewBackdrop(f, botBtn)
	
	local border = Skins.NewBackdrop(f, slideBtn)
	
	if not slideBtn then
		print('Error on hook scroll')
	else
		hooksecurefunc(slideBtn, 'Show', function(self)
			border:Show()
		end)
		hooksecurefunc(slideBtn, 'Hide', function(self)
			border:Hide()
		end)
	end
	
	border:ClearAllPoints()
	border:SetPoint('TOPLEFT', slideBtn, 'TOPLEFT', 2, -2)
	border:SetPoint('BOTTOMRIGHT', slideBtn, 'BOTTOMRIGHT', -2, 2)
	
	local backborder = Skins.NewBackdrop(f)
	backborder:ClearAllPoints()
	
	backborder:SetPoint('TOPLEFT', topBtn, 'TOPLEFT', 0, 0)
	backborder:SetPoint('TOPRIGHT', topBtn, 'TOPRIGHT', 0, 0)
	
	backborder:SetPoint('BOTTOMLEFT', botBtn, 'BOTTOMLEFT', 0, 0)
	backborder:SetPoint('BOTTOMRIGHT', botBtn, 'BOTTOMRIGHT', 0, 0)
	
	Skins.HandleScript(topBtn, 'OnMouseDown', function(self)
		if self:IsEnabled() then
			self.icon:SetPoint("CENTER", -1, -1);
		end
	end)

	Skins.HandleScript(topBtn, 'OnMouseUp', function(self)
		self.icon:SetPoint("CENTER", 0, 0);
	end)
			
	Skins.HandleScript(topBtn, 'OnDisable', function(self)
	--	self.arrow:SetTextColor(0.3, 0.3, 0.3, 1)
		SetDesaturation(self.icon, true);
		self.icon:SetAlpha(0.5);
	end)	
	Skins.HandleScript(topBtn, 'OnEnable', function(self)
	--	self.arrow:SetTextColor(0.8, 0.8, 0, 1)
		SetDesaturation(self.icon, false);
		self.icon:SetAlpha(1.0);
	end)
	
	Skins.HandleScript(botBtn, 'OnDisable', function(self)
	--	self.arrow:SetTextColor(0.3, 0.3, 0.3, 1)
		SetDesaturation(self.icon, true);
		self.icon:SetAlpha(0.5);
	end)	
	Skins.HandleScript(botBtn, 'OnEnable', function(self)
	--	self.arrow:SetTextColor(0.8, 0.8, 0, 1)
		SetDesaturation(self.icon, false);
		self.icon:SetAlpha(1.0);
	end)
	
	Skins.HandleScript(topBtn, 'OnShow', function(self)
		if self:IsEnabled() then
	--		self.arrow:SetTextColor(0.8, 0.8, 0, 1)
			SetDesaturation(self.icon, false);
			self.icon:SetAlpha(1.0);
		else
	--		self.arrow:SetTextColor(0.3, 0.3, 0.3, 1)
			SetDesaturation(self.icon, true);
			self.icon:SetAlpha(0.5);
		end
	end)
	
	Skins.HandleScript(botBtn, 'OnShow', function(self)
		if self:IsEnabled() then
	--		self.arrow:SetTextColor(0.8, 0.8, 0, 1)
			SetDesaturation(self.icon, false);
			self.icon:SetAlpha(1.0);
		else
	--		self.arrow:SetTextColor(0.3, 0.3, 0.3, 1)
			SetDesaturation(self.icon, true);
			self.icon:SetAlpha(0.5);
		end
	end)
	
end

function Skins.ThemeFrameRing(frame)
	--[==[
		<Texture name="$parentRing" parentKey="ring" file="Interface\TalentFrame\spec-filagree" setAllPoints="true">
			<TexCoords left="0.00390625" right="0.27734375" top="0.48437500" bottom="0.75781250"/>	
		</Texture>
	]==]

	local f = _G[frame] or frame
	if not f or type(f) == 'string' then 
		error('Unknown '..tostring(frame or 'nil'))
		return 
	end
	
	local name = f:GetName()

	local portrait = _G[name..'Portrait']
	local portraitFrame = _G[name..'PortraitFrame']
	local icon = _G[name..'Icon']
	
	--[[
	portraitFrame:SetTexture("Interface\\TalentFrame\\spec-filagree")
	portraitFrame:SetTexCoord(0.00390625, 0.27734375, 0.48437500, 0.75781250)
	portraitFrame:SetSize(74, 74)

	portraitFrame:SetVertexColor(0,0,0,1)
	
	portraitFrame:SetPoint('TOPLEFT', f, 'TOPLEFT', -12, 14)
	]]

	if icon then
		icon:SetAlpha(0)
		icon:Kill()
		icon:SetSize(1,1)
	end
	
	if portrait then
		portrait:SetAlpha(0)
		portrait:Kill()
		portrait:SetSize(1,1)
	end
	if portraitFrame then
		portraitFrame:SetAlpha(0)
		portraitFrame:SetSize(1,1)
		portraitFrame:Kill()
	end
end

function Skins.GetTextureObject(frame, name, TexCoords1, TexCoords2, TexCoords3, TexCoords4)
	local f = _G[frame] or frame
	if not f or type(f) == 'string' then 
		error('Unknown '..tostring(frame or 'nil'))
		return 
	end
	
	for i=1, f:GetNumRegions() do
		local region = select(i, f:GetRegions());
		if(region:GetObjectType() == "Texture") then
			local realT = region:GetTexture()
		
			if name and realT and type(realT) == 'string' and realT:lower() == name:lower() then		
				if TexCoords1 then				
					local a1, a2, a3, a4 = region:GetTexCoord()		
					if a1 == TexCoords1 and a3 == TexCoords2 and a2 == TexCoords3 and a4 == TexCoords4 then
						return region
					end
				else
					return region
				end
			end
		end
	end    
end

function Skins.GetTextureInterator(frame, args)
	local f = _G[frame] or frame
	if not f or type(f) == 'string' then 
		error('Unknown '..tostring(frame or 'nil'))
		return 
	end
	
	for i=1, f:GetNumRegions() do
		local region = select(i, f:GetRegions());
		if(region:GetObjectType() == "Texture") then
			args[i] = region
		end
	end  	
end

function Skins.GetAllTextureObject(frame, name, TexCoords1, TexCoords2, TexCoords3, TexCoords4)
	local f = _G[frame] or frame
	if not f or type(f) == 'string' then 
		error('Unknown '..tostring(frame or 'nil'))
		return 
	end
	
	for i=1, f:GetNumRegions() do
		local region = select(i, f:GetRegions());
		if(region:GetObjectType() == "Texture") then
			local realT = region:GetTexture()
			
			if name and realT and realT:lower() == name:lower() then		
				if TexCoords1 then				
					local a1, a2, a3, a4 = region:GetTexCoord()		
					if a1 == TexCoords1 and a3 == TexCoords2 and a2 == TexCoords3 and a4 == TexCoords4 then
						return region
					end
				else
					return region
				end
			end
		end
	end 
		
	for k,v in pairs({f:GetChildren()}) do
		for i=1, v:GetNumRegions() do
			local region = select(i, v:GetRegions());
			if(region:GetObjectType() == "Texture") then
				local realT = region:GetTexture()
				
				if name and realT and type(realT) == 'string' and realT:lower() == name:lower() then		
					if TexCoords1 then				
						local a1, a2, a3, a4 = region:GetTexCoord()		
						if a1 == TexCoords1 and a3 == TexCoords2 and a2 == TexCoords3 and a4 == TexCoords4 then
							return region
						end
					else
						return region
					end
				end
			end
		end  
	end
end

local function ThemeItemButton_OnShowHook(self)
	if self.runOnShow_AUI then return end
	self.runOnShow_AUI = true
		
--	local whiteTexture = Skins.GetTextureObject(self, [[Interface\Common\WhiteIconFrame]])
--	if whiteTexture then whiteTexture:SetAlpha(0) end
	
	local pushed = Skins.GetTextureObject(self, [[Interface\Buttons\UI-Quickslot-Depress]])
	if pushed then pushed:SetAlpha(0) end
end

function Skins.ThemeItemButton(frame, name2)
	local f = _G[frame] or frame
	if not f or type(f) == 'string' then 
		error('Unknown '..tostring(frame or 'nil'))
		return 
	end
	
	local name = f:GetName()
	
	local normalTexture = _G[name..'NormalTexture']

	local iconTexture = _G[name..'IconTexture']

	local border = _G[name..'Frame']
	
	if border then
		border:SetAlpha(0)
	end
	
	E:CreateBackdrop(f, f, default_border_color, default_background_color)
	f:SetUIBorderDrawLayer('ARTWORK')
	--[==[
	local icon_border = _G[name..'IconBorder'] or f.IconBorder
	
	if icon_border then
		icon_border:SetTexture(nil)
		hooksecurefunc(icon_border, "SetVertexColor", function(self, r,g,b,a)
			self._temp = self._temp or {}
			self._temp[1] = r
			self._temp[2] = g
			self._temp[3] = b
			f:SetUIBackdropBorderColor(r,g,b,a)
		end)
		hooksecurefunc(icon_border, "Show", function(self)
			if self._temp then
				f:SetUIBackdropBorderColor(self._temp[1], self._temp[2], self._temp[3],self._temp[4])
			end
		end)
		hooksecurefunc(icon_border, "Hide", function(self)
			if self._temp then
				f:SetUIBackdropBorderColor(self._temp[1], self._temp[2], self._temp[3],0)
			end
		end)
	end
	]==]
	
	iconTexture:SetTexCoord(unpack(E.media.texCoord))
	
	local highlight = f:GetHighlightTexture()
	highlight:SetAllPoints(iconTexture)
	highlight:SetColorTexture(1, 1, 1, 0.2)
				
	local normalBorder = Skins.GetTextureObject(f, [[Interface\Buttons\UI-Quickslot2]])
	
	if normalBorder then
		normalBorder:Hide()
		normalBorder:SetAlpha(0)
	end
	
	local pushed = f:GetPushedTexture()
	if pushed then
		pushed:SetAlpha(0)
	end
	
	f:HookScript('OnShow', ThemeItemButton_OnShowHook)
	f:HookScript('OnHide', ThemeItemButton_OnShowHook)

	f:StripTextures2([[Interface\CharacterFrame\Char-Paperdoll-Parts]])
	if name2 then
		local artwowrkSlot = Skins.GetTextureObject(f, [[interface\paperdoll\UI-PaperDoll-Slot-]]..name2..'.blp')

		if artwowrkSlot then
			artwowrkSlot:SetTexCoord(unpack(E.media.texCoord))
		else
			print('No artwork for '..name.. ' '..name2)
		end
	end
end


function Skins.ThemeSpellButton(frame, removeBg)
	local f = _G[frame] or frame
	if not f or type(f) == 'string' then 
		error('Unknown '..tostring(frame or 'nil'))
		return 
	end
	
	local name = f:GetName()

	_G[name..'IconTexture']:SetTexCoord(unpack(E.media.texCoord))
	_G[name..'IconTexture']:SetResize(-2)
	
	if _G[name..'NameFrame'] then
		_G[name..'NameFrame']:SetAlpha(0)
	end
	if _G[name..'SpellName'] then
		_G[name..'SpellName']:SetFont(default_font, default_font_size, 'NONE')
		_G[name..'SpellName']:SetShadowOffset(1, -1)
		_G[name..'SpellName']:SetShadowColor(0, 0, 0, 1)
	end
	if _G[name..'Name'] then
		_G[name..'Name']:SetFont(default_font, default_font_size, 'NONE')
		_G[name..'Name']:SetShadowOffset(1, -1)
		_G[name..'Name']:SetShadowColor(0, 0, 0, 1)
	end
	if _G[name..'Slot'] then
		_G[name..'Slot']:SetAlpha(0)
	end
	
	if _G[name..'Border'] then
		_G[name..'Border']:SetAlpha(0)
	end
	
	if _G[name..'NormalTexture'] then
		_G[name..'NormalTexture']:SetAlpha(0)
		_G[name..'NormalTexture']:SetTexture(nil)
	end
	
	if _G[name.."Highlight"] then
		_G[name.."Highlight"]:SetColorTexture(1, 1, 1, 0.3)
		_G[name.."Highlight"]:ClearAllPoints()
		_G[name.."Highlight"]:SetAllPoints(_G[name..'IconTexture'])
	end
	
	if f.GetCheckedTexture then
		local checked = f:GetCheckedTexture()
		local step = 0.06
		
		if checked then
			checked:SetTexCoord(step, 1-step, step, 1-step)
		end
	end
	
	if f.shine then
		f.shine:ClearAllPoints()
		f.shine:SetPoint('TOPLEFT', f, 'TOPLEFT', -3, 3)
		f.shine:SetPoint('BOTTOMRIGHT', f, 'BOTTOMRIGHT', 3, -3)
	end
	
	local artwowrkSlot = Skins.GetTextureObject(f, [[Interface\Buttons\UI-Quickslot-Depress]])
	if artwowrkSlot then
		artwowrkSlot:SetTexture(nil)
	end
	
	E:CreateBackdrop(f, _G[name..'IconTexture'], default_border_color, ( removeBg and { 0, 0, 0, 0 } or default_background_color ) )
end

function Skins.MerchantItems(frame, skipPoint)
	local f = _G[frame] or frame
	if not f or type(f) == 'string' then 
		error('Unknown '..tostring(frame or 'nil'))
		return 
	end
	
	local name = f:GetName()
	
	local SlotTexture = _G[name..'SlotTexture']
	local NameFrame = 	_G[name..'NameFrame']
	local NameFs = 		_G[name..'Name']
	
	
	local ItemButtom = _G[name..'ItemButton']
	local MoneyFrame = _G[name..'MoneyFrame']
	local AltCurrencyFrame = _G[name..'AltCurrencyFrame']
	
	
	local IconTexture = _G[name..'ItemButtonIconTexture']	
	local Count =  _G[name..'ItemButtonCount']
	local Stock =  _G[name..'ItemButtonStock']
	local SearchOverlay =  _G[name..'ItemButtonSearchOverlay']
	
	
	local IconBorder = ItemButtom.IconBorder
	
	local normalTexture =  _G[name..'ItemButtonNormalTexture']
	
	ItemButtom:StripTextures()
	
	if ItemButtom:GetHighlightTexture() then
		ItemButtom:GetHighlightTexture():SetColorTexture(1,1,1,0.2)
	end

	
	SlotTexture:SetAlpha(0)
	IconBorder:SetAlpha(0)
	normalTexture:SetAlpha(0)
	normalTexture:SetResize(-26)
	SlotTexture:SetTexCoord(unpack(E.media.texCoord))
	normalTexture:SetTexCoord(unpack(E.media.texCoord))
	IconTexture:SetTexCoord(unpack(E.media.texCoord))
	
	NameFrame:SetAlpha(0)
	
	local temp = CreateFrame('Frame', nil, ItemButtom)
	temp:EnableMouse(false)
	
	if skipPoint then
		temp:SetSize(100, 38)
		temp:SetPoint('TOPLEFT', normalTexture, 'TOPRIGHT', 5, 1)
	else
		temp:SetSize(100, 48)
		temp:SetPoint('TOPLEFT', normalTexture, 'TOPRIGHT', 5, 3)
	end

	E:CreateBackdrop(f, temp, default_border_color, { 0, 0, 0, 0.3 })
	temp:SetUIBackgroundDrawLayer('BACKGROUND', -1)
	
	E:CreateBackdrop(f, IconTexture, default_border_color, { 0, 0, 0, 0.5 })

end


function Skins.ThemeReagentItems(frame)
	local f = _G[frame] or frame
	if not f or type(f) == 'string' then 
		error('Unknown '..tostring(frame or 'nil'))
		return 
	end
	
	local name = f:GetName()

	local NameFrame = 	name and _G[name..'NameFrame'] or f.NameFrame
	local NameFs = 		name and _G[name..'Name']	 or f.Name
	local IconTexture = name and _G[name..'IconTexture'] or f.Icon
	
	local Count =  name and _G[name..'Count'] or f.Count

	IconTexture:SetTexCoord(unpack(E.media.texCoord))
	
	NameFrame:SetAlpha(0)
	
	local temp = CreateFrame('Frame', nil, f)
	temp:EnableMouse(false)
	

	temp:SetSize(100, 40)
	temp:SetPoint('TOPLEFT', IconTexture, 'TOPRIGHT', 3, 0)
	temp:SetPoint('BOTTOMLEFT', IconTexture, 'BOTTOMRIGHT', 3, 0)

	E:CreateBackdrop(f, temp, default_border_color, { 0, 0, 0, 0.3 })
	temp:SetUIBackgroundDrawLayer('BACKGROUND', -1)
	
	E:CreateBackdrop(f, IconTexture, default_border_color, { 0, 0, 0, 0 })

end

function Skins.ThemeQuestItem(frame)
	local f = _G[frame] or frame
	if not f or type(f) == 'string' then 
		error('Unknown '..tostring(frame or 'nil'))
		return 
	end
	
	local name = f:GetName()
	
	local IconTexture = _G[name..'IconTexture']
	IconTexture:SetTexCoord(unpack(E.media.texCoord))
	
	E:CreateBackdrop(f, IconTexture, default_border_color, { 0, 0, 0, 0 })
	
	local nameFrame = _G[name..'NameFrame']
	nameFrame:SetAlpha(0)
	
	local temp = CreateFrame('Frame', nil, f)
	temp:EnableMouse(false)
	temp:SetSize(100, 40)
	temp:SetPoint('TOPLEFT', IconTexture, 'TOPRIGHT', 3, 0)
	temp:SetPoint('BOTTOMLEFT', IconTexture, 'BOTTOMRIGHT', 3, 0)
	
	local Name = _G[name..'Name']
	Name:SetFont(default_font, default_font_size, 'NONE')
	Name:SetShadowOffset(1, -1)
	Name:SetShadowColor(0, 0, 0, 1)
	
	E:CreateBackdrop(f, temp, default_border_color, { 0, 0, 0, 0.3 })
end

function Skins.ThemeMailItem(frame)
	
	local f = _G[frame] or frame
	if not f or type(f) == 'string' then 
		error('Unknown '..tostring(frame or 'nil'))
		return 
	end
	
	local name = f:GetName()
	
	f:StripTextures()
	
	local IconTexture = _G[name..'IconTexture']
	IconTexture:SetTexCoord(unpack(E.media.texCoord))
	
	
	local NormalTexture = _G[name..'NormalTexture']
	NormalTexture:SetTexture(nil)
	
	local count = _G[name..'Count']
	count:SetFont(default_font, default_font_size, 'OUTLINE')
	count:SetShadowOffset(1, -1)
	count:SetShadowColor(0, 0, 0, 1)
	
	if f:GetHighlightTexture() then	
		f:GetHighlightTexture():SetColorTexture(1,1,1,0.2)
	end
	
	local iconBorder = f.IconBorder
	iconBorder:SetAlpha(0)
	hooksecurefunc(iconBorder, 'SetVertexColor', function(self, r,g,b,a)
		IconTexture:SetUIBackdropBorderColor(r,g,b)
	end)
	
	E:CreateBackdrop(f, IconTexture, default_border_color, { 0, 0, 0, 0 })
end


function Skins.ThemeFilterButton(frame)
	local f = _G[frame] or frame
	if not f or type(f) == 'string' then 
		error('Unknown '..tostring(frame or 'nil'))
		return 
	end
	
	local name = f:GetName()

	f.TopLeft:SetAlpha(0)
	f.TopRight:SetAlpha(0)
	f.BottomLeft:SetAlpha(0)
	f.BottomRight:SetAlpha(0)
	f.TopMiddle:SetAlpha(0)
	f.MiddleLeft:SetAlpha(0)
	f.MiddleRight:SetAlpha(0)
	f.BottomMiddle:SetAlpha(0)
	f.MiddleMiddle:SetAlpha(0)
	
	Skins.SetAllFontString(f, default_font, default_font_size, 'NONE')
	
	local temp = CreateFrame("Frame", nil, f)
	temp:SetPoint("TOPLEFT", f, "TOPLEFT", 3, -3)
	temp:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -3, 3)
	
	E:CreateBackdrop(f, temp, default_button_border, { 0, 0, 0, 0.3 })
end

function Skins.ThemeDropdown(frame)
	local f = _G[frame] or frame
	if not f or type(f) == 'string' then 
		error('Unknown '..tostring(frame or 'nil'))
		return 
	end
	
	local name = f:GetName()
	
	f:StripTextures()
	
	local temp1 = CreateFrame("Frame", nil, f)
	temp1:SetPoint("TOPLEFT", f, "TOPLEFT", 18, -3)
	temp1:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -18, 8)
	
	E:CreateBackdrop(f, temp1, default_button_border, { 0, 0, 0, 1 })
	
	Skins.SetAllFontString(f, default_font, default_font_size, 'NONE')

	local btn = name and _G[name..'Button']
	
	if ( btn ) then
		btn:StripTextures()
		btn:SetNormalTexture('')
		btn:SetPushedTexture('')
		btn:SetHighlightTexture('')
		btn:SetDisabledTexture('')

		local temp = Skins.ThemeButtonBackdrop(btn)
		temp:SetInside(nil, 4, 4)

		btn.icon = btn:CreateTexture(nil, 'ARTWORK')
		btn.icon:SetSize(13, 13)
		btn.icon:SetPoint('CENTER')
		btn.icon:SetTexture([[Interface\Buttons\SquareButtonTextures]])
		btn.icon:SetTexCoord(0.01562500, 0.20312500, 0.01562500, 0.20312500)
		
		SquareButton_SetIcon(btn, 'DOWN')
		
		Skins.HandleScript(btn, 'OnDisable', function(self)
			SetDesaturation(self.icon, true);
			self.icon:SetAlpha(0.5);
		end)	
		Skins.HandleScript(btn, 'OnEnable', function(self)
			SetDesaturation(self.icon, false);
			self.icon:SetAlpha(1.0);
		end)
		
		Skins.HandleScript(btn, 'OnMouseDown', function(self)
			if self:IsEnabled() then
				self.icon:SetPoint("CENTER", -1, -1);
			end
		end)
		
		Skins.HandleScript(btn, 'OnMouseUp', function(self)
			self.icon:SetPoint("CENTER", 0, 0);
		end)
		
		Skins.HandleScript(btn, 'OnShow', function(self)
			if self:IsEnabled() then
				SetDesaturation(self.icon, false);
				self.icon:SetAlpha(1.0);
			else
				SetDesaturation(self.icon, true);
				self.icon:SetAlpha(0.5);
			end
		end)
		
	end
	
	return temp1, f, temp, btn
end
	--Tab Regions
local tabs = {
	"LeftDisabled",
	"MiddleDisabled",
	"RightDisabled",
	"Left",
	"Middle",
	"Right",
}
function Skins.ThemeUpperTabs(tab)

	if not tab then return end
	for _, object in pairs(tabs) do
		if tab:GetName() then
			local tex = _G[tab:GetName()..object]
			if tex then
				tex:SetTexture(nil)
			end
		end
	end
	tab:GetHighlightTexture():SetTexture(nil)
	tab.backdrop = CreateFrame("Frame", nil, tab)
	
	Skins.SetTemplate(tab.backdrop, 'GREY')
	
	tab.backdrop:SetFrameLevel(tab:GetFrameLevel() - 1)
	tab.backdrop:SetPoint("TOPLEFT", 3, -8)
	tab.backdrop:SetPoint("BOTTOMRIGHT", -6, 0)
end

function Skins.ThemeIconButton(frame, ignoreRepoin, a1,a2,a3,a4, stepper, left, resize, right)
	local f = _G[frame] or frame
	if not f or type(f) == 'string' then 
		error('Unknown '..tostring(frame or 'nil'))
		return 
	end
	
	local name = f:GetName()

	--[[
	local normalTexute = f:GetNormalTexture():GetTexture()
	local pushedTexute = f:GetPushedTexture():GetTexture()
	local disabledTexute 
	if f.GetDisabledTexture and f:GetDisabledTexture() then
		disabledTexute = f:GetDisabledTexture():GetTexture()
	end
	]]
	
	local Border = Skins.GetTextureObject(f, [[Interface\Buttons\UI-PageButton-Background]])
	if Border then
		Border:SetAlpha(0)
		Border:SetTexture(nil)
	end
	
	local aa1 = a1 or .28
	local aa2 = a2 or .72
	local aa3 = a3 or .28
	local aa4 = a4 or .72
	
	if stepper then	
		aa1 = stepper
		aa2 = 1-stepper
		aa3 = stepper
		aa4 = 1-stepper	
	end
	
--	f:GetNormalTexture():SetTexture(normalTexute)
	f:GetNormalTexture():SetTexCoord(aa1, aa2, aa3, aa4)
--	f:GetPushedTexture():SetTexture(pushedTexute)
	f:GetPushedTexture():SetTexCoord(aa1, aa2, aa3, aa4)
	
	if f.GetDisabledTexture and f:GetDisabledTexture() then
	--	f:GetDisabledTexture():SetTexture(disabledTexute)
		f:GetDisabledTexture():SetTexCoord(aa1, aa2, aa3, aa4)
		f:GetDisabledTexture():SetInside(nil, 3, 3)
	end
	
	f:GetHighlightTexture():SetTexture(nil)
	
	f:GetNormalTexture():SetInside(nil, 3, 3)
	f:GetPushedTexture():SetInside(nil, 3, 3)

	local bg = f:CreateTexture(nil, 'BACKGROUND',nil, -1)
	bg:SetAllPoints(f)
	bg:SetColorTexture(0,0,0,1)
	
	Skins.ThemeButtonBackdrop(f)
	
	resize = resize or 0.7
	
	local size1, size2 = f:GetSize()
	frame:SetSize(size1*resize, size2*resize)
	
	local step = size1*(1-resize)
	
	Skins.SetAllFontString(f, default_font, default_font_size, 'NONE')
	
	if ignoreRepoin == true then
	
	elseif type(ignoreRepoin) == 'number' then
		local a1, a2, a3, a4, a5 = frame:GetPoint()
		frame:SetPoint(a1, a2, a3, a4+(left or 0), a5+ignoreRepoin)
	else
		local a1, a2, a3, a4, a5 = frame:GetPoint()
		frame:SetPoint(a1, a2, a3, a4+(left or 0), a5+step)
	end
end

function Skins.ThemeCheckBox(frame, noBackdrop)
	assert(frame, 'does not exist.')
	frame:StripTextures()
	if noBackdrop then
		Skins.ThemeButtonBackdrop(frame)
		frame:SetSize(16, 16)
	else
		local backdrop = Skins.ThemeButtonBackdrop(frame)	
		backdrop:SetInside(nil, 4, 4)
	end
	
	Skins.SetAllFontString(frame, default_font, default_font_size, 'NONE')
	
	if frame.SetCheckedTexture then
		frame:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check")
		if noBackdrop then
			frame:GetCheckedTexture():SetInside(nil, -4, -4)
		end
	end

	if frame.SetDisabledTexture then
		frame:SetDisabledTexture("Interface\\Buttons\\UI-CheckBox-Check-Disabled")
		if noBackdrop then
			frame:GetDisabledTexture():SetInside(nil, -4, -4)
		end
	end

	frame:HookScript('OnDisable', function(self)
		if not self.SetDisabledTexture then return; end
		if self:GetChecked() then
			self:SetDisabledTexture("Interface\\Buttons\\UI-CheckBox-Check-Disabled")
		else
			self:SetDisabledTexture("")
		end
	end)
	
	if frame.SetNormalTexture then
		hooksecurefunc(frame, "SetNormalTexture", function(self, texPath)
			if texPath ~= "" then
				self:SetNormalTexture("");
			end
		end)
	end
	if frame.SetPushedTexture then
		hooksecurefunc(frame, "SetPushedTexture", function(self, texPath)
			if texPath ~= "" then
				self:SetPushedTexture("");
			end
		end)
	end
	if frame.SetHighlightTexture then
		hooksecurefunc(frame, "SetHighlightTexture", function(self, texPath)
			if texPath ~= "" then
				self:SetHighlightTexture("");
			end
		end)
	end
end

function Skins.ThemeSocket(frame)
	local f = _G[frame] or frame
	if not f or type(f) == 'string' then 
		error('Unknown '..tostring(frame or f or 'nil'))
		return 
	end
	
	local name = f:GetName()
	
	local left = _G[name..'Left']
	
	if left then
		left:SetAlpha(0)
	end
	
	local right = _G[name..'Right']
	
	if right then
		right:SetAlpha(0)
	end

end


do
	TaxiFrame:StripTextures()
	Skins.ThemeBackdrop('TaxiFrame')
end

do
	Skins.ThemeButton(BankFramePurchaseButton)

	if ( ReagentBankFrameUnlockInfoPurchaseButton ) then 
	Skins.ThemeButton(ReagentBankFrameUnlockInfoPurchaseButton)
	Skins.ThemeButton(ReagentBankFrame.DespositButton)
	end
end


do	
	StackSplitFrame:StripTextures()
	Skins.ThemeBackdrop(StackSplitFrame)
--	Skins.ThemeButton(StackSplitOkayButton)
--	Skins.ThemeButton(StackSplitCancelButton)
end

do
	Skins.ThemeScrollBar(AleaUIChatScrollFrameScrollBar)
	Skins.ThemeScrollBar(AleaUIChatLogsScrollFrameScrollBar)
end


do
	if ( LossOfControlFrame ) then 
		--/run LossOfControlFrame.fadeTime = 2000; LossOfControlFrame_SetUpDisplay(LossOfControlFrame, true, 'CONFUSE', 2094, 'Disoriented', [[Interface\Icons\Spell_Shadow_MindSteal]], GetTime(), 7.9950003623962, 8, 0, 5, 2)
		local IconBackdrop = Skins.NewBackdrop(LossOfControlFrame, LossOfControlFrame.Icon)
		Skins.SetTemplate(IconBackdrop, 'BORDERED')
		IconBackdrop:SetOutside(LossOfControlFrame.Icon)

		LossOfControlFrame.Icon:SetTexCoord(.1, .9, .1, .9)
		LossOfControlFrame:StripTextures()
		LossOfControlFrame.AbilityName:ClearAllPoints()
		LossOfControlFrame:SetSize(LossOfControlFrame.Icon:GetWidth() + 50, LossOfControlFrame.Icon:GetWidth() + 50)
		
		
		local iconParent = CreateFrame('Frame', nil, LossOfControlFrame)
		iconParent:SetFrameLevel(LossOfControlFrame:GetFrameLevel()+10)
		
		LossOfControlFrame.Icon:SetParent(iconParent)
		IconBackdrop:SetParent(iconParent)
		
		LossOfControlFrame.Cooldown:SetParent(iconParent)
		LossOfControlFrame.Cooldown:SetFrameLevel(LossOfControlFrame:GetFrameLevel()+6)
		LossOfControlFrame.Cooldown:ClearAllPoints()
		LossOfControlFrame.Cooldown:SetPoint('TOPLEFT', LossOfControlFrame.Icon, 'TOPLEFT', -5, 5)
		LossOfControlFrame.Cooldown:SetPoint('BOTTOMRIGHT', LossOfControlFrame.Icon, 'BOTTOMRIGHT', 5, -5)
		LossOfControlFrame.Cooldown:SetSwipeTexture([[Interface\Buttons\WHITE8x8]])
		LossOfControlFrame.Cooldown:SetSwipeColor(10/255, 197/255*0.8, 210/255*0.8, 0.9)
		
		local CooldownBackdrop = Skins.NewBackdrop(LossOfControlFrame.Cooldown, LossOfControlFrame.Cooldown)
		Skins.SetTemplate(CooldownBackdrop, 'DARK')
		CooldownBackdrop:SetOutside(LossOfControlFrame.Cooldown)
		
		
		local font = E.media.default_font
		hooksecurefunc("LossOfControlFrame_SetUpDisplay", function(self, animate, locType, spellID, text, iconTexture, startTime, timeRemaining, duration, lockoutSchool, priority, displayType)
			self.Icon:ClearAllPoints()
			self.Icon:SetPoint("CENTER", self, "CENTER", 0, 0)
			
			self.AbilityName:ClearAllPoints()
			self.AbilityName:SetPoint("BOTTOM", self, 0, -10)
			self.AbilityName.scrollTime = nil;
			self.AbilityName:SetFont(font, 20, 'OUTLINE')
			
			self.TimeLeft.NumberText:ClearAllPoints()
			self.TimeLeft.NumberText:SetPoint("BOTTOM", self, 4, -34)
			self.TimeLeft.NumberText.scrollTime = nil;
			self.TimeLeft.NumberText:SetFont(font, 20, 'OUTLINE')

			self.TimeLeft.SecondsText:ClearAllPoints()
			self.TimeLeft.SecondsText:SetPoint("BOTTOM", self, 0, -54)
			self.TimeLeft.SecondsText.scrollTime = nil;
			self.TimeLeft.SecondsText:SetFont(font, 20, 'OUTLINE')

			-- always stop shake animation on start
			if self.Anim:IsPlaying() then
				self.Anim:Stop()
			end
		end)
	end
end

do
	hooksecurefunc('SetItemButtonQuality', function(button, quality, itemIDOrLink)
		--[==[
		if itemIDOrLink and IsArtifactRelicItem(itemIDOrLink) then
			button.IconBorder:SetAlpha(1);
			button.IconBorder:SetTexCoord(0.03, 0.97, 0.03, 0.97)
			button.IconBorder:SetDrawLayer('OVERLAY', 1)
			
			local w = button:GetWidth()
			
			if floor(button:GetHeight()+0.5) == floor(w+0.5) then
				button.IconBorder:SetSize(w-1, w-1)
			else
				button.IconBorder:SetAlpha(0);
			end
		else
		]==]
			button.IconBorder:SetAlpha(0);
	--	end
		
		if button.SetUIBackdropBorderColor then		
			if quality then
				if quality >= LE_ITEM_QUALITY_COMMON and BAG_ITEM_QUALITY_COLORS[quality] then
					button:SetUIBackdropBorderColor(BAG_ITEM_QUALITY_COLORS[quality].r, BAG_ITEM_QUALITY_COLORS[quality].g, BAG_ITEM_QUALITY_COLORS[quality].b);
				else
					button:SetUIBackdropBorderColor(0,0,0,1);
				end
			else
				button:SetUIBackdropBorderColor(0,0,0,1);
			end
		end		
	end)
end

do
	E:OnInit(function()

		Skins.SetTemplate(BNToastFrame, 'DARK')
		BNToastFrame.CloseButton:StripTextures()
		
		BNToastFrameGlowFrame:Kill()
		
		local closetext = BNToastFrame:CreateFontString(nil, 'OVERLAY')
		closetext:SetPoint('CENTER', BNToastFrame.CloseButton, 'CENTER', 0, 0)
		closetext:SetFont(STANDARD_TEXT_FONT, 12)
		closetext:SetText('x')
		
		local onEnter = BNToastFrame:CreateTexture(nil, 'OVERLAY')
		onEnter:SetSize(12,12)
		onEnter:SetPoint('CENTER', BNToastFrame.CloseButton, 'CENTER', -2, -2)
		onEnter:SetColorTexture(1, 1, 1, 0.3)
		
		BNToastFrame.CloseButton:SetHighlightTexture(onEnter)
		
		Skins.SetAllFontString(BNToastFrame, default_font, default_font_size, 'NONE')
		
		
		E:Mover(BNToastFrame, 'AleaUIBNToastFrameMover')
		hooksecurefunc(BNToastFrame,'SetPoint', function(self, point1, anchor1, secondaryPoint1, x1, y1)		
			local point, anchor, secondaryPoint, x, y = E.GetFrameOpts('AleaUIBNToastFrameMover')
			if point ~= point1 or
				secondaryPoint1 ~= secondaryPoint or x ~= x1 or y ~= y1 then				
				E:Mover(self, 'AleaUIBNToastFrameMover')
			end
		end)
	end)
end

do
	E:OnInit(function()
		-- QuickJoinToastButton
		if ( not QuickJoinToastButton ) then
			return 
		end 
		
		local border = Skins.NewBackdrop(QuickJoinToastButton)
		border:ClearAllPoints()
		border:SetPoint('TOPLEFT', QuickJoinToastButton, 'TOPLEFT', 3, -1)
		border:SetPoint('BOTTOMRIGHT', QuickJoinToastButton, 'BOTTOMRIGHT', -3, -1)
		
		Skins.SetTemplate(border, 'DARK')
		
	--	QuickJoinToastButton.FriendsButton:Show()
	
		local texture = QuickJoinToastButton:CreateTexture(nil, 'BORDER')
		texture:SetPoint('CENTER', QuickJoinToastButton)
		texture:SetTexture([[Interface\FriendsFrame\UI-Toast-ToastIcons]])
		texture:SetSize(30,32)
		texture:SetTexCoord(0,0.25,0.5,1)
		texture.SetPoint = E.noop
		texture.SetTexture = E.noop
		texture.SetVertexColor = E.noop
		texture.SetTexCoord = E.noop
		
		QuickJoinToastButton.FriendsButton:SetTexture(texture)
		QuickJoinToastButton.FriendsButton:SetAlpha(0)
		
			local quickJoinTexture = QuickJoinToastButton:CreateTexture(nil, 'ARTWORK')
				quickJoinTexture:SetPoint('CENTER', QuickJoinToastButton)
				quickJoinTexture:SetSize(30,32)
				quickJoinTexture:SetTexture("Interface\\LFGFrame\\BattlenetWorking1.blp");
				quickJoinTexture:SetTexCoord(0.1, 0.9, 0.1, 0.9);
	
				quickJoinTexture.SetPoint = E.noop
				quickJoinTexture.SetTexture = E.noop
				quickJoinTexture.SetVertexColor = E.noop
				quickJoinTexture.SetTexCoord = E.noop
				quickJoinTexture:SetAlpha(0)
		
		QuickJoinToastButton.QueueButton:SetTexture(quickJoinTexture)
		QuickJoinToastButton.QueueButton.SetAtlas = E.noop
		QuickJoinToastButton.QueueButton:SetAlpha(0)
		
		local FlashingLayerTexture = QuickJoinToastButton:CreateTexture(nil, 'ARTWORK')
				FlashingLayerTexture:SetPoint('CENTER', QuickJoinToastButton)
				FlashingLayerTexture:SetSize(30,32)
				FlashingLayerTexture:SetTexture([[Interface\Buttons\WHITE8x8]]);
				FlashingLayerTexture:SetVertexColor(1, 1, 0, 0.4)
	
				FlashingLayerTexture.SetPoint = E.noop
				FlashingLayerTexture.SetTexture = E.noop
				FlashingLayerTexture.SetVertexColor = E.noop
				FlashingLayerTexture.SetTexCoord = E.noop
				FlashingLayerTexture:SetAlpha(0)
				
		QuickJoinToastButton.FlashingLayer:SetTexture(FlashingLayerTexture)
		QuickJoinToastButton.FlashingLayer.SetAtlas = E.noop
		QuickJoinToastButton.FlashingLayer:SetAlpha(0)
	
		QuickJoinToastButton.Toast:SetPoint('LEFT', QuickJoinToastButton, 'RIGHT', 0, -1)
		QuickJoinToastButton.Toast2:SetPoint('LEFT', QuickJoinToastButton, 'RIGHT', 0, -1)
		
		QuickJoinToastButton.Toast.Background:SetTexture([[Interface\Buttons\WHITE8x8]])
		QuickJoinToastButton.Toast.Background:SetVertexColor(0, 0, 0, 0.8)
		QuickJoinToastButton.Toast.Background:SetDrawLayer('BORDER', -1)
		--QuickJoinToastButton.Toast.Background:SetIgnoreParentAlpha(true)
		QuickJoinToastButton.Toast.Background:SetAlpha(0)

		QuickJoinToastButton.Toast2.Background:SetTexture([[Interface\Buttons\WHITE8x8]])
		QuickJoinToastButton.Toast2.Background:SetVertexColor(0, 0, 0, 0.8)
		QuickJoinToastButton.Toast2.Background:SetDrawLayer('BORDER', -1)
		--QuickJoinToastButton.Toast2.Background:SetIgnoreParentAlpha(true)
		QuickJoinToastButton.Toast2.Background:SetAlpha(0)

		QuickJoinToastButton.Toast.Line:SetTexture([[Interface\Buttons\WHITE8x8]])
		QuickJoinToastButton.Toast.Line:SetVertexColor(1, 1, 1, 0.3)
		QuickJoinToastButton.Toast.Line:SetAlpha(0)
		QuickJoinToastButton.Toast.Line:SetDrawLayer('BORDER', -2)
		
		QuickJoinToastButton.Toast2.Line:SetTexture([[Interface\Buttons\WHITE8x8]])
		QuickJoinToastButton.Toast2.Line:SetVertexColor(1, 1, 1, 0.3)
		QuickJoinToastButton.Toast2.Line:SetAlpha(0)
		QuickJoinToastButton.Toast2.Line:SetDrawLayer('BORDER', -2)
	end)

end

do	
	if ( StatusTrackingBarManager ) then
		StatusTrackingBarManager:Kill()
		StatusTrackingBarManager:GetParent().OnStatusBarsUpdated = function()end
	end
end

do

	
	local function Skin_TotemFrame()
		
		local global_height = 140
		local button;
		local prev;
		
		local function UpdateTotemBarButtons()
			local buttonSize = max(16, floor((global_height-8)/MAX_TOTEMS))
			local button = nil
			local prev = nil
		
			for i=1, MAX_TOTEMS do
				button = _G["TotemFrameTotem"..i];
				
				button:ClearAllPoints()
				button:SetParent(UIParent)
				
			
				button:SetSize(buttonSize,buttonSize)
				
				if not prev then
					button:SetPoint('BOTTOMLEFT', ChatFrame1, 'BOTTOMRIGHT', 10, 0)
				else
					button:SetPoint('BOTTOM', prev, 'TOP', 0, 3)
				end
				
				prev = button
			end	
		end
	
		for i=1, MAX_TOTEMS do
			button = _G["TotemFrameTotem"..i];
			
			button:ClearAllPoints()
			button:SetParent(UIParent)
			
			button:SetSize(32,32)
			button:StripTextures()
			
			_G["TotemFrameTotem"..i..'Icon']:SetAllPoints()
			
						
			_G["TotemFrameTotem"..i..'IconTexture']:SetTexCoord(unpack(E.media.texCoord))
					
			local background = button:CreateTexture()			
			background:SetColorTexture(0,0,0,1)
			background:SetOutside(button)
			background:SetDrawLayer('BACKGROUND', 0)
			
			for f, child in pairs({ button:GetChildren() }) do
				if f == 2 then 
					child:StripTextures()
				elseif f == 1 then

				end
			end
			
			button.duration:Kill()
			
			if not prev then
				button:SetPoint('BOTTOMLEFT', UIParent, 'BOTTOMLEFT', 450, 2)
			else
				button:SetPoint('LEFT', prev, 'RIGHT', 5, 0)
			end
			
			_G["TotemFrameTotem"..i..'IconCooldown'].SizeOverride = 0.6
			
			E:RegisterCooldown(_G["TotemFrameTotem"..i..'IconCooldown'])
			
			
			prev = button
		end
		
		
		ChatFrame1:HookScript('OnSizeChanged', function(_, width, height)
			global_height = height
			UpdateTotemBarButtons()
		end)
	end
	
	if ( not E.isClassic ) then 
		E:OnInit2(Skin_TotemFrame)
	end
end

local warningIsPoped = false
local function SkinsRquestReloadUI()
	if not warningIsPoped then
		warningIsPoped = true
		
		AleaUI_GUI.ShowPopUp(
		   'AleaUI', 
		   L["Need reload ui to apply this changes. Do it now?"], 
		   { name = YES, OnClick = function() 
				warningIsPoped = false
				ReloadUI()
			end}, 
		   { name = NO, OnClick = function() 	   
				warningIsPoped = false
		   end}		   
		)
	end
end

local skinsCategory = nil
local addonSkinsCategoryRegister = {}

addonSkinsCategoryRegister[1] = { addOn = 'Blizzard', name = 'Blizzard', opts = nil, gui = nil }
addonSkinsCategoryRegister[1].gui = {
	name = '',
	order = 2,
	type = 'group',
	embend = true,
	args = {
		Enable = {
			name = L['Enable'],
			order = 1,
			type = "toggle",
			width = 'full',
			set = function(self, value)		
				E.db.skins.enableAll = not E.db.skins.enableAll
				SkinsRquestReloadUI()
			end,
			get = function(self)
				return E.db.skins.enableAll
			end
		}
	},

}


function Skins:RegisterCategory(addOn, name, opts, gui, update)
	
	for i=1, #addonSkinsCategoryRegister do
		if addonSkinsCategoryRegister[i].addOn == addOn then
			return
		end
	end
	
	addonSkinsCategoryRegister[#addonSkinsCategoryRegister+1] = {
		addOn =  addOn,
		name = name or addOn,
		opts = opts,
		gui = gui,
		update = update,
	}
	
	E.default_settings.skins_custom[addOn] = opts
	
end

function Skins:UpdateAddonSkins()
	for i=2, #addonSkinsCategoryRegister do
		if addonSkinsCategoryRegister[i].update then
			addonSkinsCategoryRegister[i].update()
		end
	end
end

function Skins:GetAddOnOpts(addOn)
	return E.db.skins_custom[addOn]
end

function Skins:SetCategory(category)
	E.GUI.args.skins.args.Manager = nil
	
	if category == 1 then
		-- Blizzard always
		for k, v in pairs(addonSkinsCategoryRegister[1].gui.args) do
			if k ~= 'Enable' then
				addonSkinsCategoryRegister[1].gui.args[k] = nil
			end
		end
		local index = 2
		for varName in pairs(E.default_settings.skins) do	
			addonSkinsCategoryRegister[1].gui.args[varName] = {
				name = varName,
				order = index,
				type = "toggle",
				set = function(self, value)		
					E.db.skins[varName] = not E.db.skins[varName]
					SkinsRquestReloadUI()
				end,
				get = function(self)
					return E.db.skins[varName]
				end
			}
			
			index = index + 1
		end
		
		E.GUI.args.skins.args.Manager = addonSkinsCategoryRegister[1].gui
	elseif addonSkinsCategoryRegister[category] then
		E.GUI.args.skins.args.Manager = addonSkinsCategoryRegister[category].gui
	end
end

E:OnInit2(function()	
	E.GUI.args.skins ={
		order = 10,name = L["Skins"],type = "group",
		args={},
	}
	
	E.GUI.args.skins.args.SelectType = {
		name = L['AddOns'],
		order = 1,
		type = 'dropdown',
		width = 'full',
		values = function()
			local t = {}
			
			for i=1, #addonSkinsCategoryRegister do
				t[i] = addonSkinsCategoryRegister[i].name or addonSkinsCategoryRegister[i].addOn
			end
			
			return t
		end,
		set = function(info, value)
			skinsCategory = value
			Skins:SetCategory(value)
		end,
		get = function(info)
			return skinsCategory
		end,
	
	}
end)


do
	if ( TalentMicroButtonAlert ) then
		TalentMicroButtonAlert:Kill()
		CollectionsMicroButtonAlert:Kill()
		LFDMicroButtonAlert:Kill()
		EJMicroButtonAlert:Kill()
		ZoneAbilityButtonAlert:Kill()
		BagHelpBox:Kill()
		
		GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_WORLD_MAP_FRAME, true)
	end
end

do
	Skins.ThemeStatusBar(MirrorTimer1StatusBar)
	MirrorTimer1Border:SetAlpha(0)
	
	Skins.ThemeStatusBar(MirrorTimer2StatusBar)
	MirrorTimer2Border:SetAlpha(0)
	
	Skins.ThemeStatusBar(MirrorTimer3StatusBar)
	MirrorTimer3Border:SetAlpha(0)
end

do
	--[==[
	WorldStateAlwaysUpFrame:ClearAllPoints()
	WorldStateAlwaysUpFrame:SetPoint('TOP', -5, -50)
	WorldStateAlwaysUpFrame:EnableMouse(false)

	hooksecurefunc('WorldStateAlwaysUpFrame_AddFrame', function(alwaysUpShown, text, icon, dynamicIcon, dynamicFlashIcon, dynamicTooltip, state)
		local name = "AlwaysUpFrame"..alwaysUpShown;
		if ( _G[name] ) then
			_G[name]:EnableMouse(false)
		end
	end)
	]==]
end