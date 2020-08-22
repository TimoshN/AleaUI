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

local buttons_name = Skins.buttons_name

local varName = 'calendar'
E.default_settings.skins[varName] = true

E:OnAddonLoad('Blizzard_Calendar', function()
	
	if not E.db.skins.enableAll then return end
	if not E.db.skins[varName] then return end
		
	_G['CalendarFrame']:StripTextures()
	Skins.ThemeBackdrop('CalendarFrame')
	
	CalendarFilterFrame:StripTextures()
	
	
	local btn = _G['CalendarFilterButton']
	
	btn:StripTextures()
	btn:SetNormalTexture('')
	btn:SetPushedTexture('')
	btn:SetHighlightTexture('')
	btn:SetDisabledTexture('')

	
	local temp = CreateFrame("Frame", nil, btn)
	temp:SetPoint("TOPLEFT", btn, "TOPLEFT", 4, -4)
	temp:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", -4, 4)
	
	E:CreateBackdrop(btn, temp, default_button_border, { 0, 0, 0, 0 })
	
	btn.arrow = btn:CreateFontString()
	btn.arrow:SetPoint('CENTER', btn, 'CENTER', 3, 0)
	btn.arrow:SetFont("Fonts\\ARIALN.TTF", 12, "OUTLINE")
	btn.arrow:SetJustifyH("CENTER")
	btn.arrow:SetJustifyV("CENTER")
	btn.arrow:SetText(buttons_name[3])
	btn.arrow:SetTextColor(0.8, 0.8, 0, 1)

	Skins.HandleScript(btn, 'OnDisable', function(self)
		self.arrow:SetTextColor(0.3, 0.3, 0.3, 1)
	end)	
	Skins.HandleScript(btn, 'OnEnable', function(self)
		self.arrow:SetTextColor(0.8, 0.8, 0, 1)
	end)
	
	Skins.HandleScript(btn, 'OnMouseDown', function(self)
		self.arrow:SetPoint('CENTER', self, 'CENTER', 4, -2)
	end)
	
	Skins.HandleScript(btn, 'OnMouseUp', function(self)
		self.arrow:SetPoint('CENTER', self, 'CENTER', 3, 0)
	end)
	
	Skins.HandleScript(btn, 'OnShow', function(self)
		if self:IsEnabled() then
			self.arrow:SetTextColor(0.8, 0.8, 0, 1)
		else
			self.arrow:SetTextColor(0.3, 0.3, 0.3, 1)
		end
	end)
	
	CalendarViewHolidayFrame:StripTextures()
	Skins.ThemeBackdrop('CalendarViewHolidayFrame')
	Skins.ThemeScrollBar('CalendarViewHolidayScrollFrameScrollBar')
	CalendarViewHolidayTitleFrame:StripTextures()
	CalendarViewHolidayCloseButton:DisableDrawLayer('BACKGROUND')
	CalendarViewHolidayCloseButton:DisableDrawLayer('BORDER')
	
	
	Skins.ThemeScrollBar('CalendarCreateEventInviteListScrollFrameScrollBar')
	
	CalendarViewEventFrame:StripTextures()
	Skins.ThemeBackdrop('CalendarViewEventFrame')
--	Skins.ThemeScrollBar('CalendarViewEventScrollFrameScrollBar')
	Skins.ThemeScrollBar('CalendarViewEventInviteListScrollFrameScrollBar')
	CalendarViewEventTitleFrame:StripTextures()
	CalendarViewEventCloseButton:DisableDrawLayer('BACKGROUND')
	CalendarViewEventCloseButton:DisableDrawLayer('BORDER')
	
	CalendarViewEventDivider:Kill()
	
	CalendarViewEventDescriptionContainer:StripTextures()
	CalendarViewEventInviteList:StripTextures()
	
	Skins.ThemeBackdrop('CalendarViewEventDescriptionContainer')
	Skins.ThemeBackdrop('CalendarViewEventInviteList')
	
	Skins.ThemeButton('CalendarViewEventAcceptButton')
	Skins.ThemeButton('CalendarViewEventTentativeButton')
	Skins.ThemeButton('CalendarViewEventDeclineButton')
	Skins.ThemeButton('CalendarViewEventRemoveButton')
	
	CalendarCreateEventIcon:SetTexCoord(unpack(E.media.texCoord))
	CalendarCreateEventIcon.SetTexCoord = function()end
	
	CalendarClassButtonContainer:HookScript("OnShow", function()
		for i, class in ipairs(CLASS_SORT_ORDER) do
			local button = _G["CalendarClassButton"..i]
			local tcoords = CLASS_ICON_TCOORDS[class]
			local buttonIcon = button:GetNormalTexture()
			buttonIcon:SetTexture("Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes")
			buttonIcon:SetTexCoord(tcoords[1] + 0.015, tcoords[2] - 0.02, tcoords[3] + 0.018, tcoords[4] - 0.02) --F U C K I N G H A X
		end
	end)
	
	CalendarClassButton1:SetPoint("TOPLEFT", CalendarClassButtonContainer, "TOPLEFT", 5, 0)

	for i = 1, #CLASS_SORT_ORDER do
		local button = _G["CalendarClassButton"..i]
		button:StripTextures()
		Skins.ThemeBackdrop(button)
		button:SetSize(24, 24)
	end
	
	CalendarClassTotalsButton:StripTextures()
	Skins.ThemeBackdrop(CalendarClassTotalsButton)
	CalendarClassTotalsButton:SetWidth(24)
	
	Skins.ThemeBackdrop(CalendarContextMenu)
	CalendarContextMenu.SetBackdropColor = function()end
	CalendarContextMenu.SetBackdropBorderColor = function()end
	
	Skins.ThemeBackdrop(CalendarInviteStatusContextMenu)
	CalendarInviteStatusContextMenu.SetBackdropColor = function()end
	CalendarInviteStatusContextMenu.SetBackdropBorderColor = function()end
	
	--CreateEventFrame
	CalendarCreateEventFrame:StripTextures()
	Skins.ThemeBackdrop(CalendarCreateEventFrame)
	CalendarCreateEventFrame:SetPoint("TOPLEFT", CalendarFrame, "TOPRIGHT", 3, -24)
	CalendarCreateEventTitleFrame:StripTextures()
	
	Skins.ThemeButton(CalendarCreateEventCreateButton)
	Skins.ThemeButton(CalendarCreateEventMassInviteButton)
	Skins.ThemeButton(CalendarCreateEventInviteButton)
	Skins.ThemeButton(CalendarCreateEventRaidInviteButton)
	
	CalendarCreateEventInviteButton:SetPoint("TOPLEFT", CalendarCreateEventInviteEdit, "TOPRIGHT", 4, 1)
	CalendarCreateEventInviteEdit:SetWidth(CalendarCreateEventInviteEdit:GetWidth() - 2)

	CalendarCreateEventInviteList:StripTextures()
	Skins.ThemeBackdrop(CalendarCreateEventInviteList)

	Skins.ThemeEditBox(CalendarCreateEventInviteEdit, true)
	Skins.ThemeEditBox(CalendarCreateEventTitleEdit, true)
	Skins.ThemeDropdown(CalendarCreateEventTypeDropDown)
	
	Skins.ThemeDropdown(CalendarCreateEventDifficultyOptionDropDown)
	
	CalendarCreateEventDescriptionContainer:StripTextures()
	Skins.ThemeBackdrop(CalendarCreateEventDescriptionContainer)

	CalendarCreateEventCloseButton:DisableDrawLayer('BACKGROUND')
	CalendarCreateEventCloseButton:DisableDrawLayer('BORDER')
	
	Skins.ThemeCheckBox(CalendarCreateEventLockEventCheck)
	
	local temp1, f = Skins.ThemeDropdown(CalendarCreateEventHourDropDown)
	temp1:SetPoint("TOPLEFT", f, "TOPLEFT", 25, -5)
	temp1:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -30, 11)
	
	local temp1, f = Skins.ThemeDropdown(CalendarCreateEventMinuteDropDown)
	temp1:SetPoint("TOPLEFT", f, "TOPLEFT", 25, -5)
	temp1:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -30, 11)
	
	
	local temp1, f = Skins.ThemeDropdown(CalendarCreateEventAMPMDropDown)
	temp1:SetPoint("TOPLEFT", f, "TOPLEFT", 25, -5)
	temp1:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -30, 11)
	
	CalendarCreateEventIcon:SetTexCoord(unpack(E.media.texCoord))
	CalendarCreateEventIcon.SetTexCoord = function()end

	CalendarCreateEventInviteListSection:StripTextures()
end)