local addonName, E = ...
local Skins = E:Module("Skins")
local _G = _G

local varName = 'mailframe'
E.default_settings.skins[varName] = true

local default_background_color = Skins.default_background_color
local default_border_color = Skins.default_border_color
local default_font = Skins.default_font
local default_texture = Skins.default_texture

local default_button_background = Skins.default_button_background
local default_button_border 	= Skins.default_button_border
local default_border_color_dark = Skins.default_border_color_dark

local function Skin_MailFrame()
	if not E.db.skins.enableAll then return end
	if not E.db.skins[varName] then return end

	MailFrame:StripTextures(true)
	MailFrameInset:StripTextures(true)
	SendMailMoneyBg:StripTextures()
	SendMailMoneyInset:StripTextures()
	OpenMailFrame:StripTextures()
	OpenMailFrameInset:StripTextures()
	SendMailScrollFrame:StripTextures()
	SendMailFrame:StripTextures()

	Skins.ThemeBackdrop('MailFrame')
	Skins.ThemeBackdrop('MailFrameInset')
	Skins.ThemeBackdrop('OpenMailFrame')
	Skins.ThemeFrameRing(OpenMailFrame)
	Skins.ThemeButton('OpenMailReportSpamButton')
	Skins.ThemeButton('OpenMailReplyButton')
	Skins.ThemeButton('OpenMailDeleteButton')
	Skins.ThemeButton('OpenMailCancelButton')

	OpenMailLetterButton:StripTextures()
	OpenMailLetterButtonIconTexture:SetTexCoord(unpack(E.media.texCoord))
	local backdrop = Skins.NewBackdrop(OpenMailLetterButton)
	backdrop:SetOutside(OpenMailLetterButtonIconTexture)
	Skins.SetTemplate(backdrop, 'BORDERED')
		
	for attBrn = 1, ATTACHMENTS_MAX_SEND do
		local btn = _G['OpenMailAttachmentButton'..attBrn]
		Skins.ThemeMailItem(btn)
	end

	for i=1, 2 do
		Skins.ThemeTab('MailFrameTab'..i)
	end

	for i = 1, INBOXITEMS_TO_DISPLAY do
		local bg = _G["MailItem"..i]
		bg:StripTextures()	

		local sender = _G["MailItem"..i..'Sender']
		sender:SetFont(default_font, Skins.default_font_size, 'NONE')
		local subject = _G["MailItem"..i..'Subject']
		subject:SetFont(default_font, Skins.default_font_size, 'NONE')
		
		E:CreateBackdrop(bg, bg, { 0, 0, 0, 0.3 }, { 0, 0, 0, 0.1})
		
		local b = _G["MailItem"..i.."Button"]
		b:StripTextures()
		Skins.ThemeButton(b)
		Skins.ChangeButtonBorder(b, 'DARK')
		
		local t = _G["MailItem"..i.."ButtonIcon"]
		t:SetTexCoord(unpack(E.media.texCoord))
		t:SetInside(nil, 2, 2)
		
	--	local backdrop = Skins.NewBackdrop(b)
	--	backdrop:SetOutside(t)
	--	Skins.SetTemplate(backdrop, 'BORDERED')
	end

	local function MailFrameSkin()
		for i = 1, ATTACHMENTS_MAX_SEND do
			local b = _G["SendMailAttachment"..i]
			if not b.skinned then
				b.skinned = true
				
				b:StripTextures()
				Skins.ThemeButton(b)
				b.IconBorder:Kill()
			end
			
			local t = b:GetNormalTexture()

			if t then
				if not b._iconborder then
					b._iconborder = b:CreateTexture()
					local a1, a2 = t:GetDrawLayer()
					b._iconborder:SetDrawLayer(a1, a2-1)
					b._iconborder:SetColorTexture(0,0,0,1)
					b._iconborder:SetOutside(t)
					b._iconborder:Show()
				end
				
				t:SetTexCoord(E.media.texCoord[1], E.media.texCoord[2], E.media.texCoord[3], E.media.texCoord[4])
				t:SetInside(b)
			else
				if b._iconborder then
					b._iconborder:Hide()
				end
			end
		end
	end
	hooksecurefunc("SendMailFrame_Update", MailFrameSkin)
		
	Skins.ThemeIconButton(InboxPrevPageButton, true)
	Skins.ThemeIconButton(InboxNextPageButton, true)
		
	Skins.ThemeScrollBar('OpenMailScrollFrameScrollBar')
	Skins.ThemeScrollBar('SendMailScrollFrameScrollBar')

	SendScrollBarBackgroundTop:SetAlpha(0)

	Skins.ThemeButton('SendMailMailButton')
	Skins.ThemeButton('SendMailCancelButton')

	Skins.ThemeEditBox('SendMailNameEditBox', true)
	Skins.ThemeEditBox('SendMailSubjectEditBox', true)
	Skins.ThemeEditBox('SendMailMoneyGold', true, 45, 20)
	Skins.ThemeEditBox('SendMailMoneySilver', true, 20, 20)
	Skins.ThemeEditBox('SendMailMoneyCopper', true, 20, 20)

	ItemTextFrame:StripTextures()
	ItemTextFrameInset:StripTextures()
	Skins.ThemeBackdrop(ItemTextFrame)
	Skins.ThemeFrameRing(ItemTextFrame)
	Skins.ThemeScrollBar('ItemTextScrollFrameScrollBar')

	ItemTextPageText:SetFont(E.media.default_font, E.media.default_font_size)
	ItemTextPageText:SetTextColor(1, 1, 1)
	ItemTextPageText:SetShadowColor(0,0,0,1)
	ItemTextPageText:SetShadowOffset(1,-1)
	hooksecurefunc(ItemTextPageText, "SetTextColor", function(self, r, g, b)
		if r ~= 1 or g ~= 1 or b ~= 1 then
			ItemTextPageText:SetTextColor(1, 1, 1)
		end
	end)
	Skins.ThemeIconButton(ItemTextPrevPageButton)
	Skins.ThemeIconButton(ItemTextNextPageButton)
	
end

E:OnInit2(Skin_MailFrame)