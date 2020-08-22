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

local varName = 'staticpopups'
E.default_settings.skins[varName] = true

local DELETE_GOOD_ITEM_PATTERN = DELETE_GOOD_ITEM:gsub('%%s', '.+')

local function Skin_StaticPopup()
	--[==[
	local textStr = {}
	textStr[DELETE_ITEM] = false
	textStr[DELETE_QUEST_ITEM] = false
	textStr[DELETE_GOOD_ITEM] = true
	textStr[DELETE_GOOD_QUEST_ITEM] = false
	]==]
	
		-- CONFIRM_PURCHASE_TOKEN_ITEM
		
	local autoAccept = { 109693, 109126, 124105, 142156 }
	local auraAcceptByResource = { 124124 }
	
	hooksecurefunc("StaticPopup_Show", function(tag, resource, arg1, arg2)
		if tag ~= "CONFIRM_PURCHASE_TOKEN_ITEM" then return end
		if false then return end
		
		local push = false
		
		if resource then
			for i=1, #auraAcceptByResource do
				if string.find(resource, tostring(auraAcceptByResource[i])) then
					push = true
					break
				end
			end
		end
		
		for i=1, #autoAccept do	
			if GetItemInfo(autoAccept[i]) == arg2.name then				
				push = true
				break
			end
		end
		
		if push then	
			C_Timer.After(0.1, function()		
				if _G["StaticPopup1Button1"]:IsShown() then
					_G["StaticPopup1Button1"]:Click()
				end
			end)
		end
	end)

	for i=1, 4 do
		if not E.db.skins.enableAll then return end
		if not E.db.skins[varName] then return end

		Skins.ThemeBackdrop('StaticPopup'..i)
		
		
		Skins.SetAllFontString('StaticPopup'..i, default_font, Skins.default_font_size, 'NONE')

		Skins.ThemeEditBox('StaticPopup'..i..'EditBox')
		
		Skins.ThemeButton('StaticPopup'..i..'Button1')
		Skins.ThemeButton('StaticPopup'..i..'Button2')
		Skins.ThemeButton('StaticPopup'..i..'Button3')
		
		
		_G['StaticPopup'..i]:HookScript('OnShow', function(self)
		
			if not self.__deleteAcceptButton then
				local btn = CreateFrame('CheckButton', nil, self, "UICheckButtonTemplate")

				btn:SetSize(30, 30)
				btn:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check")
				btn:SetDisabledCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check-Disabled")
	
				btn:SetPoint('CENTER', _G['StaticPopup'..i..'EditBox'], 'CENTER', -80, 0)
				
				local text = btn:CreateFontString(nil, 'OVERLAY', "GameFontHighlight")
				text:SetPoint("LEFT", btn, "RIGHT", 0 , 0)
				text:SetPoint("RIGHT", btn, "RIGHT", 180 , 0)	
				text:SetTextColor(1, 1, 1)
				text:SetJustifyH("LEFT")
				text:SetWordWrap(false)
				text:SetText(E.L['Accept to delete'])
				text:SetFont((text:GetFont()), 12, 'NONE')
				
				btn:SetChecked(false)
				btn:SetScript('OnClick', function()
					_G['StaticPopup'..i..'Button1']:Enable()
				end)
				
				btn:SetScript("OnClick", function(me)
				
					
					if me:GetChecked() then
						me:SetChecked( true )
						PlaySound(SOUNDKIT and SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON or "igMainMenuOptionCheckBoxOn")
						_G['StaticPopup'..i..'Button1']:Enable()
					else
						me:SetChecked( false )
						PlaySound(SOUNDKIT and SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF or "igMainMenuOptionCheckBoxOff")
						_G['StaticPopup'..i..'Button1']:Disable()
					end
					
				end)
	
	
				self.__deleteAcceptButton = btn
			end
			
			self.__deleteAcceptButton:Hide()
			self.__deleteAcceptButton:SetChecked(false)
			
			if string.match((_G['StaticPopup'..i..'Text']:GetText() or ''), DELETE_GOOD_ITEM_PATTERN) then
				local text = strsplit('\n', (_G['StaticPopup'..i..'Text']:GetText() or ''))
				
				_G['StaticPopup'..i..'Text']:SetText(text)
				
				self.__deleteAcceptButton:Show()
				_G['StaticPopup'..i..'EditBox']:Hide()
			end
		end)
	end
end

E:OnInit2(Skin_StaticPopup)