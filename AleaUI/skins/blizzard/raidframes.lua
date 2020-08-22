if true then return end
local addonName, E = ...
local Skins = E:Module("Skins")
local _G = _G

local defr = 0.2
local defg = 0.2
local defb = 0.2

local def2r = 0.4
local def2g = 0.4
local def2b = 0.4

local frames = {}

local raidIndexCoord = {
	[1] = { 0, .25, 0, .25 }, --"STAR"
	[2] = { .25, .5, 0, .25}, --MOON
	[3] = { .5, .75, 0, .25}, -- CIRCLE
	[4] = { .75, 1, 0, .25}, -- SQUARE
	[5] = { 0, .25, .25, .5}, -- DIAMOND
	[6] = { .25, .5, .25, .5}, -- CROSS
	[7] = { .5, .75, .25, .5}, -- TRIANGLE
	[8] = { .75, 1, .25, .5}, --  SKULL
}

local UpdateRaidTargetIndex = function(self, unit)

	local munit = unit or self:GetAttribute("unit") or self.unit or self.displayedUnit
	
--	print('T', munit, unit, self:GetAttribute("unit"), self.unit, self.displayedUnit)
	
	if not UnitExists(munit) then 
		self.raidIcon:Hide()
		return 
	end
	
	local mark = GetRaidTargetIndex(munit)
	
	if raidIndexCoord[mark] then
		self.raidIcon:Show()
		self.raidIcon:SetTexCoord(raidIndexCoord[mark][1], raidIndexCoord[mark][2], raidIndexCoord[mark][3], raidIndexCoord[mark][4])
	else	
		self.raidIcon:Hide()
	end
end

local eventFrame = CreateFrame('Frame')
eventFrame:RegisterEvent('RAID_TARGET_UPDATE')
eventFrame:SetScript('OnEvent', function()	
	for i=1, #frames do
		UpdateRaidTargetIndex(frames[i])
	end
end)

local byte = string.byte
local sub = string.sub

local function utf8sub(str, start, numChars) 
    local currentIndex = start 
    while numChars > 0 and currentIndex <= #str do 
        local char = byte(str, currentIndex) 
        if char >= 240 then 
          currentIndex = currentIndex + 4 
        elseif char >= 225 then 
          currentIndex = currentIndex + 3 
        elseif char >= 192 then 
          currentIndex = currentIndex + 2 
        else 
          currentIndex = currentIndex + 1 
        end 
        numChars = numChars - 1 
    end 
    return sub(str, start, currentIndex - 1) 
end

local min_custom_aura_size = 10

local hidenframe = CreateFrame("Frame")
hidenframe:Hide()

local function LoadSkin(frame)
	
	if CompactPartyFrameTitle then
		CompactPartyFrameTitle:SetSize(1,1)
		CompactPartyFrameTitle:SetAlpha(0)
	end
	
	frame.name:SetFont(Skins.default_font, Skins.default_font_size, 'OUTLINE')
	frame.name:SetTextColor(frame.healthBar.r, frame.healthBar.g, frame.healthBar.b)
	
	frame.statusText:SetFont(Skins.default_font, Skins.default_font_size, 'OUTLINE')
	frame.statusText:SetTextColor(1, 1, 1)

	frame.healthBar:SetStatusBarTexture(Skins.default_texture, "BORDER")
	frame.healthBar:SetStatusBarColor(defr,defg,defb, 1)
	
	frame.healthBar.background:SetColorTexture(def2r, def2g, def2b, 1)
	
	frame.background:SetColorTexture(0, 0, 0, 1)
	
	frame.roleIcon:SetAlpha(0)
	
	if frame._myname then
		frame._myname:SetTextColor(frame.healthBar.r, frame.healthBar.g, frame.healthBar.b)		
		local name = frame.name:GetText()
		if name then
			frame._myname:SetText(#name > 0 and utf8sub(name, 1, 5) or "")
		end
	end
	
	if not frame.styled then
		frame.styled = true
		
		frame.name:SetParent(hidenframe)
	--	frame.statusText:SetParent(hidenframe)
		
		
		local name = eventFrame:CreateFontString(nil, 'BORDER', nil, 2)
		name:SetParent(frame)
		name:SetPoint("CENTER", frame, 0, 4)
		
		frame._myname = name
		frame._myname:SetFont(Skins.default_font, Skins.default_font_size, 'OUTLINE')
		frame._myname:SetTextColor(frame.healthBar.r, frame.healthBar.g, frame.healthBar.b)
		local name = frame.name:GetText()
		if name then
			frame._myname:SetText(#name > 0 and utf8sub(name, 1, 5) or "")
		end
	
		hooksecurefunc(frame.name, 'SetText', function(self, value)		
			frame._myname:SetText(value and utf8sub(value, 1, 5) or "")
		end)
		
		hooksecurefunc(frame.statusText, 'SetText', function(self, value)			
			if value == DEAD then			
				self:SetText('мертв');
			end
		end)
		
		hooksecurefunc(frame, 'SetAlpha', function(self, value)
			if value == 0.55 then
				self:SetAlpha(0.4)
				self.background:SetColorTexture(0, 0, 0, 0.4)
			end
		end)

		for i=1, 3 do
			--[[
			E:CreateBackdrop(frame.buffFrames[i], frame.buffFrames[i].icon, {0, 0, 0, 1}, {0,0,0,0})
			frame.buffFrames[i].icon:SetBorderDrawLayer('OVERLAY')
		
			E:CreateBackdrop(frame.debuffFrames[i], frame.debuffFrames[i].icon, {0, 0, 0, 1}, {0,0,0,0})
			frame.debuffFrames[i].icon:SetBorderDrawLayer('OVERLAY')
			]]
			
			frame.buffFrames[i]._border = Skins.NewBackdrop(frame.buffFrames[i], frame.buffFrames[i].Icon)
			frame.buffFrames[i]._border:SetFrameLevel(frame.buffFrames[i]:GetFrameLevel()+1)
			Skins.SetTemplate(frame.buffFrames[i]._border, 'BORDERED')
			frame.buffFrames[i].count:SetParent(frame.buffFrames[i]._border)
			
			frame.debuffFrames[i]._border = Skins.NewBackdrop(frame.debuffFrames[i], frame.debuffFrames[i].Icon)
			frame.debuffFrames[i]._border:SetFrameLevel(frame.debuffFrames[i]:GetFrameLevel()+1)
			Skins.SetTemplate(frame.debuffFrames[i]._border, 'BORDERED')
			frame.debuffFrames[i].count:SetParent(frame.debuffFrames[i]._border)
			
			frame.buffFrames[i].icon:SetTexCoord(unpack(E.media.texCoord))
			
			frame.debuffFrames[i].icon:SetTexCoord(unpack(E.media.texCoord))
			frame.debuffFrames[i].border:SetAlpha(0)
			
			hooksecurefunc(frame.debuffFrames[i].border, 'SetVertexColor',function(self, r, g, b, a)
				frame.debuffFrames[i]._border:SetBackdropBorderColor(r, g, b, 1)
			end)
			
			frame.buffFrames[i]:SetSize(min_custom_aura_size, min_custom_aura_size) 
			
			hooksecurefunc(frame.buffFrames[i], 'SetSize',function(self, s1, s2)
				if s1 == min_custom_aura_size then return end
	
				self:SetSize(min_custom_aura_size, min_custom_aura_size) 
			end)
			
			hooksecurefunc(frame.debuffFrames[i], 'SetSize',function(self, s1, s2)
				if not self.baseSize then return end
				if self.baseSize >= min_custom_aura_size then return end
				
				if s1 == self.baseSize then
					self:SetSize(min_custom_aura_size, min_custom_aura_size) 
				elseif s1 == self.baseSize*2 then
					self:SetSize(min_custom_aura_size*2, min_custom_aura_size*2) 
				end
			end)
		
		end
		
		frame.raidIcon = frame.healthBar:CreateTexture(nil, "ARTWORK", nil, 2)
		frame.raidIcon:SetPoint("CENTER",frame.healthBar, 'TOP', 0, -3)
		frame.raidIcon:SetSize(18,18)
		frame.raidIcon:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
		frame.raidIcon:SetTexCoord(0,1,0,1)
		frame.raidIcon:Hide()
		
		UpdateRaidTargetIndex(frame)

		frames[#frames+1] = frame
	end
end

hooksecurefunc('CompactUnitFrame_OnLoad', LoadSkin)
hooksecurefunc('CompactUnitFrame_UpdateUnitEvents', LoadSkin)
hooksecurefunc('DefaultCompactUnitFrameSetup', LoadSkin)
hooksecurefunc('CompactUnitFrame_UpdateHealthColor', LoadSkin)
hooksecurefunc('CompactUnitFrame_SetUnit', function(self, unit)	
	UpdateRaidTargetIndex(self, unit)
end)

hooksecurefunc('CompactRaidGroup_OnLoad', function(self)
	self.title:SetSize(1,1)
	self.title:SetAlpha(0)
end)

if IsAddOnLoaded('Blizzard_CompactRaidFrames') then
else LoadAddOn('Blizzard_CompactRaidFrames')
end

local hidenframe = CreateFrame('Frame')
hidenframe:Hide()


CompactRaidFrameManagerToggleButton:SetParent(hidenframe)

CompactRaidFrameManager:SetFrameStrata('MEDIUM')
CompactRaidFrameManager:SetPoint("TOPLEFT", UIParent, "TOPLEFT", -186, -240);
CompactRaidFrameManager:StripTextures()
CompactRaidFrameManager:SetBackdrop({ 
	bgFile = [[Interface\Buttons\WHITE8x8]], 
	edgeFile =	[[Interface\Buttons\WHITE8x8]],
	edgeSize = 1,
})
CompactRaidFrameManager:SetBackdropColor(Skins.default_background_color[1], Skins.default_background_color[2], Skins.default_background_color[3], 1)
CompactRaidFrameManager:SetBackdropBorderColor(Skins.default_border_color[1], Skins.default_border_color[2], Skins.default_border_color[3],1)

CompactRaidFrameManager.displayFrame:Show()
CompactRaidFrameManager.displayFrame:SetAlpha(0)

local stateFrame = CreateFrame("Button", nil, CompactRaidFrameManager, "SecureHandlerClickTemplate")
stateFrame:SetPoint("TOPRIGHT",0,0)
stateFrame:SetPoint("BOTTOMRIGHT",0,0)
stateFrame:SetWidth(25)
stateFrame:EnableMouse(true)
stateFrame:SetAttribute("_onclick", [=[
	local ref = self:GetParent()
	if not self:GetAttribute("state") then
	  self:SetAttribute("state","closed")
	end
	local state = self:GetAttribute("state")
	if state == "closed" then
	  ref:SetPoint("TOPLEFT", ref:GetParent(), "TOPLEFT", -7, -240);
	  self:SetAttribute("state","open")
	else
	  ref:SetPoint("TOPLEFT", ref:GetParent(), "TOPLEFT", -186, -240);
	  self:SetAttribute("state","closed")
	end
]=])

Skins.ThemeDropdown(CompactRaidFrameManager.displayFrame.profileSelector)

local textures = {
	'TopRight',
	'TopLeft',
	'TopMiddle',
	'MiddleRight',
	'MiddleLeft',
	'BottomMiddle',
	'BottomRight',
	'BottomLeft',
}
local function DeleteTextures(frame)
	local name = frame:GetName()	
	for i, v in pairs(textures) do
		_G[name..v]:SetAlpha(0)
	end
end


Skins.ThemeButton(CompactRaidFrameManager.displayFrame.filterOptions.filterRoleTank)
DeleteTextures(CompactRaidFrameManager.displayFrame.filterOptions.filterRoleTank)

Skins.ThemeButton(CompactRaidFrameManager.displayFrame.filterOptions.filterRoleHealer)
DeleteTextures(CompactRaidFrameManager.displayFrame.filterOptions.filterRoleHealer)

Skins.ThemeButton(CompactRaidFrameManager.displayFrame.filterOptions.filterRoleDamager)
DeleteTextures(CompactRaidFrameManager.displayFrame.filterOptions.filterRoleDamager)

Skins.ThemeButton(CompactRaidFrameManager.displayFrame.filterOptions.filterGroup1)
DeleteTextures(CompactRaidFrameManager.displayFrame.filterOptions.filterGroup1)

Skins.ThemeButton(CompactRaidFrameManager.displayFrame.filterOptions.filterGroup2)
DeleteTextures(CompactRaidFrameManager.displayFrame.filterOptions.filterGroup2)

Skins.ThemeButton(CompactRaidFrameManager.displayFrame.filterOptions.filterGroup3)
DeleteTextures(CompactRaidFrameManager.displayFrame.filterOptions.filterGroup3)

Skins.ThemeButton(CompactRaidFrameManager.displayFrame.filterOptions.filterGroup4)
DeleteTextures(CompactRaidFrameManager.displayFrame.filterOptions.filterGroup4)

Skins.ThemeButton(CompactRaidFrameManager.displayFrame.filterOptions.filterGroup5)
DeleteTextures(CompactRaidFrameManager.displayFrame.filterOptions.filterGroup5)

Skins.ThemeButton(CompactRaidFrameManager.displayFrame.filterOptions.filterGroup6)
DeleteTextures(CompactRaidFrameManager.displayFrame.filterOptions.filterGroup6)

Skins.ThemeButton(CompactRaidFrameManager.displayFrame.filterOptions.filterGroup7)
DeleteTextures(CompactRaidFrameManager.displayFrame.filterOptions.filterGroup7)

Skins.ThemeButton(CompactRaidFrameManager.displayFrame.filterOptions.filterGroup8)
DeleteTextures(CompactRaidFrameManager.displayFrame.filterOptions.filterGroup8)


Skins.ThemeButton(CompactRaidFrameManager.displayFrame.convertToRaid)
DeleteTextures(CompactRaidFrameManager.displayFrame.convertToRaid)

Skins.ThemeButton(CompactRaidFrameManager.displayFrame.hiddenModeToggle)
DeleteTextures(CompactRaidFrameManager.displayFrame.hiddenModeToggle)

Skins.ThemeButton(CompactRaidFrameManager.displayFrame.lockedModeToggle)
DeleteTextures(CompactRaidFrameManager.displayFrame.lockedModeToggle)

Skins.ThemeButton(CompactRaidFrameManager.displayFrame.leaderOptions.rolePollButton)
DeleteTextures(CompactRaidFrameManager.displayFrame.leaderOptions.rolePollButton)

Skins.ThemeButton(CompactRaidFrameManager.displayFrame.leaderOptions.readyCheckButton)
DeleteTextures(CompactRaidFrameManager.displayFrame.leaderOptions.readyCheckButton)

Skins.ThemeButton(_G[CompactRaidFrameManager.displayFrame.leaderOptions:GetName()..'RaidWorldMarkerButton'])
DeleteTextures(_G[CompactRaidFrameManager.displayFrame.leaderOptions:GetName()..'RaidWorldMarkerButton'])
_G[CompactRaidFrameManager.displayFrame.leaderOptions:GetName()..'RaidWorldMarkerButton'].Icon:SetDrawLayer('OVERLAY')
_G[CompactRaidFrameManager.displayFrame.leaderOptions:GetName()..'RaidWorldMarkerButton'].Icon:SetTexture([[Interface\RaidFrame\Raid-WorldPing]])

Skins.ThemeCheckBox(CompactRaidFrameManager.displayFrame.everyoneIsAssistButton)

stateFrame.button = stateFrame:CreateTexture(nil, 'OVERLAY')
stateFrame.button:SetTexture("Interface\\RaidFrame\\RaidPanel-Toggle")
stateFrame.button:SetTexCoord(0.5, 1, 0, 1);
stateFrame.button:SetSize(16, 64)
stateFrame.button:SetPoint('RIGHT', 0, 0)
stateFrame:SetScript('OnAttributeChanged', function(self, name, value)
	if name == 'state' then	
		if value == 'open' then
			CompactRaidFrameManager:SetBackdropColor(Skins.default_background_color[1], Skins.default_background_color[2], Skins.default_background_color[3], 1)
			CompactRaidFrameManager:SetBackdropBorderColor(Skins.default_border_color[1], Skins.default_border_color[2], Skins.default_border_color[3],1)
			stateFrame.button:SetTexCoord(0.5, 1, 0, 1);
			stateFrame.button:SetAlpha(1)
			CompactRaidFrameManager.displayFrame:SetAlpha(1)
		else
			CompactRaidFrameManager:SetBackdropColor(Skins.default_background_color[1], Skins.default_background_color[2], Skins.default_background_color[3], 0.5)
			CompactRaidFrameManager:SetBackdropBorderColor(Skins.default_border_color[1], Skins.default_border_color[2], Skins.default_border_color[3], 0.5)
			stateFrame.button:SetTexCoord(0, 0.5, 0, 1);
			stateFrame.button:SetAlpha(0.7)
			CompactRaidFrameManager.displayFrame:SetAlpha(0)
		end
	end
end)

local function ModRaidFrameSettings()
	
	CompactUnitFrameProfilesGeneralOptionsFrameHeightSlider:SetMinMaxValues(20, 200)
	CompactUnitFrameProfilesGeneralOptionsFrameWidthSlider:SetMinMaxValues(20, 200)
end

if IsAddOnLoaded('Blizzard_CUFProfiles') then
	ModRaidFrameSettings()
else E:OnAddonLoad('Blizzard_CUFProfiles', ModRaidFrameSettings)
end

