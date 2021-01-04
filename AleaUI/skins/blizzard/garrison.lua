local addon, E = ...
local Skins = E:Module("Skins")
local _G = _G

local default_background_color = Skins.default_background_color
local default_border_color = Skins.default_border_color
local default_font = Skins.default_font
local default_texture = Skins.default_texture

local default_button_background = Skins.default_button_background
local default_button_border 	= Skins.default_button_border
local default_border_color_dark = Skins.default_border_color_dark


local garrisonAddon = "Blizzard_GarrisonUI"

if ( E.isClassic ) then 
	return 
end 


local e = CreateFrame("Frame")
e.elapsed = 0
e.attept = 0
e:RegisterEvent("SHIPMENT_CRAFTER_CLOSED")
e:RegisterEvent("SHIPMENT_CRAFTER_OPENED")
e:Hide()
e:SetScript("OnUpdate", function(self, elapsed)
	self.elapsed = self.elapsed + elapsed
	if self.elapsed < 0.1 then return end
	self.elapsed = 0
	
	if not _G["GarrisonCapacitiveDisplayFrame"]:IsShown() then
		self.attept = self.attept + 1		
		C_Garrison.RequestShipmentInfo();		
	else
		self:Hide()
		if self.attept > 0 then
			print("<AleaUI>","Open GarrisonCapacitiveDisplayFrame after", self.attept, "attepts")
		end
	end
end)

e:SetScript("OnEvent", function(self, event)
--	print(event)
	if event == "SHIPMENT_CRAFTER_OPENED" then
		self.attept = 0
		self.elapsed = -0.5
		self:Show()
	elseif event == "SHIPMENT_CRAFTER_CLOSED" then
		self:Hide()
	end
end)

local varName = 'garrison'
E.default_settings.skins[varName] = true

local function StyleGarrisonWindow()
	if not E.db.skins.enableAll then return end
	if not E.db.skins[varName] then return end

	_G["GarrisonCapacitiveDisplayFrame"]:StripTextures()
	_G["GarrisonCapacitiveDisplayFrameInset"]:StripTextures()
	
	_G["GarrisonCapacitiveDisplayFrame"]:SetToplevel(true)
	
	Skins.ThemeBackdrop('GarrisonCapacitiveDisplayFrame')
	
	Skins.ThemeScrollBar('QuestProgressScrollFrameScrollBar')
	
	Skins.ThemeButton(GarrisonCapacitiveDisplayFrame.StartWorkOrderButton)
	Skins.ThemeButton(GarrisonCapacitiveDisplayFrame.CreateAllWorkOrdersButton)
	
	GarrisonCapacitiveDisplayFrameLeft:Kill()
	
	Skins.ThemeFrameRing('GarrisonCapacitiveDisplayFrame')
	
	Skins.ThemeEditBox(GarrisonCapacitiveDisplayFrame.Count, true) --, width, height)
	
	GarrisonCapacitiveDisplayFrame.CapacitiveDisplay.ShipmentIconFrame.Icon:SetTexCoord(unpack(E.media.texCoord))
	
	E:CreateBackdrop(GarrisonCapacitiveDisplayFrame.CapacitiveDisplay.ShipmentIconFrame, GarrisonCapacitiveDisplayFrame.CapacitiveDisplay.ShipmentIconFrame.Icon, default_border_color, default_background_color)
	
	Skins.ThemeIconButton(GarrisonCapacitiveDisplayFrame.DecrementButton, true)
	Skins.ThemeIconButton(GarrisonCapacitiveDisplayFrame.IncrementButton, true)
	
	GarrisonCapacitiveDisplayFrame.DecrementButton:RePointHorizontal(7)
	GarrisonCapacitiveDisplayFrame.IncrementButton:RePointHorizontal(-7)
	
	GarrisonCapacitiveDisplayFrame.CapacitiveDisplay.ShipmentIconFrame.ShipmentName:SetFont(default_font, Skins.default_font_size)
	GarrisonCapacitiveDisplayFrame.CapacitiveDisplay.ShipmentIconFrame.ShipmentsAvailable:SetFont(default_font, Skins.default_font_size)
	
	GarrisonCapacitiveDisplayFrame.CapacitiveDisplay.IconBG:SetTexture(nil)
	
	E:CreateBackdrop(GarrisonCapacitiveDisplayFrame.CapacitiveDisplay, GarrisonCapacitiveDisplayFrame.CapacitiveDisplay.IconBG, default_border_color, default_background_color)
	
	hooksecurefunc('GarrisonCapacitiveDisplayFrame_Update', function(self)
		local display = self.CapacitiveDisplay;
		local reagents = display.Reagents;
		
		for i=1, #reagents do
			local reagent = reagents[i]
			if not reagent.styled then
				reagent.styled = true
				
				Skins.ThemeReagentItems(reagent)
			
			end
		end
	end)
	
	GarrisonLandingPage:StripTextures()
	GarrisonLandingPageReport:StripTextures()
	GarrisonLandingPageReportList:StripTextures()
	GarrisonLandingPageFollowerList:StripTextures()
	GarrisonLandingPageShipFollowerList:StripTextures()

	local backdrop = Skins.NewBackdrop(GarrisonLandingPage)
	Skins.SetTemplate(backdrop, 'DARK')
	backdrop:ClearAllPoints()
	backdrop:SetInside(GarrisonLandingPage, 10, 10)
	
	Skins.ThemeScrollBar('GarrisonLandingPageReportListListScrollFrameScrollBar')
	
	for i=1, 3 do
		Skins.ThemeTab('GarrisonLandingPageTab'..i, -10)
	end
	
	Skins.ThemeScrollBar('GarrisonLandingPageFollowerListListScrollFrameScrollBar')	
	Skins.ThemeEditBox(GarrisonLandingPageFollowerList.SearchBox, true)
	
	Skins.ThemeScrollBar('GarrisonLandingPageShipFollowerListListScrollFrameScrollBar')	
	Skins.ThemeEditBox(GarrisonLandingPageShipFollowerList.SearchBox, true)
	
	GarrisonLandingPageReport.InProgress:GetNormalTexture():SetTexture('')
	GarrisonLandingPageReport.Available:GetNormalTexture():SetTexture('')
	GarrisonLandingPageReport.InProgress:GetHighlightTexture():SetTexture('')
	GarrisonLandingPageReport.Available:GetHighlightTexture():SetTexture('')
	
	hooksecurefunc('GarrisonLandingPageReport_SetTab', function()
		GarrisonLandingPageReport.InProgress:GetNormalTexture():SetTexture('')
		GarrisonLandingPageReport.Available:GetNormalTexture():SetTexture('')
		GarrisonLandingPageReport.InProgress:GetHighlightTexture():SetTexture('')
		GarrisonLandingPageReport.Available:GetHighlightTexture():SetTexture('')
	end)
	
	Skins.SetTemplate(GarrisonLandingPageReport.InProgress, 'DARK')
	Skins.SetTemplate(GarrisonLandingPageReport.Available, 'DARK')
	
	
	OrderHallMissionFrame.GarrCorners:StripTextures()
	OrderHallMissionFrame:StripTextures()
	
	local artwork = CreateFrame('Frame', nil, OrderHallMissionFrame)
	artwork:SetSize(1,1)
	artwork:SetAllPoints()
	artwork:SetFrameStrata('LOW')
	Skins.ThemeBackdrop(artwork)
	
	OrderHallMissionFrame.ClassHallIcon:SetAlpha(0)
	
	for i=1, 3 do
		Skins.ThemeTab('OrderHallMissionFrameTab'..i)
	end
	
	Skins.ThemeScrollBar('OrderHallMissionFrameMissionsListScrollFrameScrollBar')
	Skins.ThemeScrollBar('OrderHallMissionFrameFollowersListScrollFrameScrollBar')
	
	Skins.ThemeButton(OrderHallMissionFrame.MissionTab.MissionPage.StartMissionButton)
	Skins.ThemeButton(OrderHallMissionFrame.MissionTab.ZoneSupportMissionPage.StartMissionButton)
	Skins.ThemeButton(OrderHallMissionFrameMissions.CombatAllyUI.InProgress.Unassign)


	
	if ( _G["GarrisonLandingPageMinimapButton"] ) then
		_G["GarrisonLandingPageMinimapButton"]:ClearAllPoints()
		_G["GarrisonLandingPageMinimapButton"]:SetScale(0.7)
		_G["GarrisonLandingPageMinimapButton"]:EnableMinimapMoving("garrisonMinimapButton")	
		E.minimapFader.AddToFading(_G["GarrisonLandingPageMinimapButton"])
	else 
		print('No garrison button found')
	end

	C_Timer.After(0.1, function() 
		E.minimapFader.InterateChildrend(_G["Minimap"]:GetChildren())
	end)
end

E:OnInit(function()
	if _G["GarrisonCapacitiveDisplayFrame"] then
		StyleGarrisonWindow()
	else
		E:OnAddonLoad(garrisonAddon, StyleGarrisonWindow)
	end
end)
