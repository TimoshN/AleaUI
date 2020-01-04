local addonName, E = ...
local L = E.L
local options
local AWM = E:Module('AuraWidgets')
local AWF = E:Module('AuraWidgersWatcher')
local Skins = E:Module("Skins")
local LSM = LibStub("LibSharedMedia-3.0")
local MAX_NUM_AURA_WATCHER_FRAMES = 10

local selectedspell
local selectedanchor

local spellName_to_frame = {}

local total_spellAurasFrames = 0
local spellAurasFrames = {}

local anchors = {}
local name_to_anchors = {}

local iconFrames = {}
local unit_to_check = {}
local mover_tag = 'AW:Anchor-'

local currentEncounterName = nil
local currentEncounterID = nil
local instaceBossName = nil

local ANCHOR_GROW = {
	['RIGHT'] = { 'BOTTOMLEFT' , 'BOTTOMRIGHT', 1 },
	['LEFT']  = { 'BOTTOMRIGHT' , 'BOTTOMLEFT', -1 },
}

local default_size = 60

local none = "None"
local none1 = "Interface\\Quiet.ogg"

local function CustomPlaySound(sound)

	if sound == none then return end
	
	local sound2 = LSM:Fetch("sound", sound)

	local willplay, handler = PlaySoundFile(sound2, 'MASTER')				
end
	
local function GetIcon()
	for i=1, #iconFrames do		
		if iconFrames[i].free then
			return iconFrames[i]
		end
	end
	
	local f = CreateFrame("Frame", nil, E.UIParent)
	f:SetSize(40, 40)
	f:SetFrameStrata('LOW')
	f.free = true
	f:Hide()

	local icon = f:CreateTexture(nil, "BACKGROUND", nil, -1)
	icon:SetAllPoints()
	icon:SetTexCoord(unpack(AleaUI.media.texCoord))
	--[==[
	f.backdrop = CreateFrame("Frame", nil, f)
	f.backdrop:SetFrameStrata("LOW")
	]==]
	
	f.bg = f:CreateTexture(nil, "BACKGROUND", nil, -2)
	f.bg:SetPoint("TOPLEFT", icon, "TOPLEFT", -1, 1)
	f.bg:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 1, -1)
	f.bg:SetColorTexture(0,0,0,1)

	local cd = CreateFrame("Cooldown", nil, f, "CooldownFrameTemplate")
	cd.parent = f
	cd:SetAllPoints()
	cd:SetReverse(true)
	cd.noMinDurationCheck = true
	cd:SetScript("OnUpdate", function(self, elapsed)
	
		if self._start == 0 and self._duration == 0 then
			self.parent.timer:SetText('')
			return
		end
		
		local numb = ((self._start + self._duration) - GetTime())
		
		if numb > 60 then
		--	self.parent.timer:SetText(format(" %dm ", ceil(numb / 60)))
		elseif numb > 3 then
		--	self.parent.timer:SetText(format(" %.0f ", numb))
		elseif numb > 0 then
		--	self.parent.timer:SetText(format(" %.1f ", numb))
		elseif numb < 0.1 then
			self.parent:EndTimer()
		else
			self.parent.timer:SetText('')
		end
	end)

	local textparent = CreateFrame("Frame", nil, cd)
	textparent:SetFrameLevel(cd:GetFrameLevel()+4)
	textparent:SetSize(1,1)
	textparent:Show()
	textparent:SetPoint("CENTER")

	local timer = textparent:CreateFontString(nil, "OVERLAY")
	timer:SetFont(AleaUI.media.default_font, 15, "OUTLINE")
	timer:SetPoint("TOPLEFT", cd, "TOPLEFT", -5, 0)
	timer:SetPoint("BOTTOMRIGHT", cd, "BOTTOMRIGHT", 5, 0)
	timer:SetJustifyH("CENTER")
	timer:SetJustifyV("BOTTOM")
	timer:SetText("")

	local stack = textparent:CreateFontString(nil, "OVERLAY")
	stack:SetFont(AleaUI.media.default_font, 15, "OUTLINE")
	stack:SetPoint("TOPLEFT", cd, "TOPLEFT", -5, 0)
	stack:SetPoint("BOTTOMRIGHT", cd, "BOTTOMRIGHT", 5, 0)
	stack:SetJustifyH("CENTER")
	stack:SetJustifyV("BOTTOM")
	stack:SetText("")
	
	local customText = textparent:CreateFontString(nil, "OVERLAY")
	customText:SetFont(AleaUI.media.default_font, 15, "OUTLINE")
	customText:SetPoint("TOPLEFT", cd, "TOPLEFT", -5, 0)
	customText:SetPoint("BOTTOMRIGHT", cd, "BOTTOMRIGHT", 5, 0)
	customText:SetJustifyH("CENTER")
	customText:SetJustifyV("CENTER")
	customText:SetText("")
	
	if false then		
		cd:SetSwipeTexture('',0, 0, 0, 0)
		cd:SetDrawEdge(false)
	else
		cd:SetSwipeTexture('',0, 0, 0, 0.7)
		cd:SetDrawEdge(false)
	end

	f.timer = timer
	f.stack = stack
	f.customTextW = customText
	f.icon = icon
	f.cooldown = cd
	
	E:RegisterCooldown(f.cooldown)
	
	f.UpdateCustomText = function(self, value1, value2, value3, source)	
		if not self.customName then 
			--[[
			local tempvalue1 = value1 and tonumber(value1)
			local tempvalue2 = value2 and tonumber(value2)
			local tempvalue3 = value3 and tonumber(value3)
			
			if tempvalue1 and tempvalue1 > 0 then
				self.customTextW:SetText(tempvalue1)
			elseif tempvalue2 and tempvalue2 > 0 then
				self.customTextW:SetText(tempvalue2)
			elseif tempvalue3 and tempvalue3 > 0 then
				self.customTextW:SetText(tempvalue3)
			end
			]]
			return 
		end
		
		local temp = self.customName
		
		temp = gsub(temp,"%%val1", tostring(value1 or ''))
		temp = gsub(temp,"%%val2", tostring(value2 or ''))
		temp = gsub(temp,"%%val3", tostring(value3 or ''))
		temp = gsub(temp,"%%source", UnitName(tostring(source or '')))	
		temp = gsub(temp,"||c", '|c')
		temp = gsub(temp,"||r", '|r')
		temp = gsub(temp,"\\n", '\n')
		
		self.customTextW:SetText(temp)
	end
	f.SetTimer = function(self, start, duration, stacks, status, spellID) -- status 1 buff; 2 icd; 3 forceshow
		if status == 1 then
			self:Show()
			self.stack:SetText( ( stacks and stacks > 0 ) and stacks or '' )
			self.icon:SetDesaturated(false)
			self.icon:SetTexture(GetSpellTexture(spellID))
			
			if math.floor(self.cooldown._start or 1) ~= math.floor(start) then
			--	print("T", 'Show', start, self.spellName)	
				CustomPlaySound(self.sound_onshow)
			end
			
			if self.showGlow then
				Skins.ShowOverlayGlow(self)
			else
				Skins.HideOverlayGlow(self)
			end
			
			self.cooldown._start = start
			self.cooldown._duration = duration
			
			if start == 0 and duration == 0 then
				self.cooldown:Hide()
			else
				self.cooldown:Show()
				self.cooldown:SetCooldown(start, duration)
			end
		elseif status == 2 then
			self:Show()
			self.stack:SetText( ( stacks and stacks > 0 ) and stacks or '' )
			self.icon:SetDesaturated(true)
			
			if self.cooldown._start ~= start then
			--	print("T", 'Show', start, self.spellName)	
				CustomPlaySound(self.sound_onshow)
			end
			self.cooldown._start = start
			self.cooldown._duration = duration
				
			if start == 0 and duration == 0 then
				self.cooldown:Hide()
			else
				self.cooldown:Show()
				self.cooldown:SetCooldown(start, duration)
			end
		end
	
		local anchor = self.anchor and name_to_anchors[self.anchor]
		
		if anchor then
			anchor.numauras = anchor.numauras + 1
			
			local opts = options.anchors[self.anchor]
			
			local point, relative = ANCHOR_GROW[opts.grow][1], ANCHOR_GROW[opts.grow][2]
			
			
			self:ClearAllPoints()

			self:SetPoint(point, anchor, relative, ( anchor.totalWidth ) * ANCHOR_GROW[opts.grow][3], 0)
			
			anchor.totalWidth = anchor.totalWidth + self:GetWidth() + 5
		end
	end
	
	f.EndTimer = function(self)
		if self:IsShown() then
	--		print("T", 'Hide', self.spellName)
			CustomPlaySound(self.sound_onhide)
		end
		
		Skins.HideOverlayGlow(self)
			
		self.timer:SetText('')
		self:Hide()
	end
	
	f.UpdateSettings = function(self, data)	
		self.free = false
		self:SetSize(data.size, data.size)
		self.enabled = data.showing
		self.spellName = data.spellName
		self.spellID = data.spellID		
		self.checkID = data.checkID
		self.anchor = data.anchor
		self.showGlow = data.showGlow
		self.customName = ( data.customName and data.customName:len() > 0 ) and data.customName or false
		self.sound_onhide = data.sound_onhide
		self.sound_onshow = data.sound_onshow
	end
	
	f.IsEnabled = function(self, spellName, filter, spellID)
		if self.enabled == 1 then
			local show = false
			if spellName == self.spellName then		
				if self.checkID then
					if self.spellID == spellID then
						show = true
					end
				else
					show = true
				end
			end			
			return show
		elseif self.enabled == 3 then
			local show = false
			if filter == 'buff' then
				if spellName == self.spellName then		
					if self.checkID then
						if self.spellID == spellID then
							show = true
						end
					else
						show = true
					end
				end
			end
			return show
		elseif self.enabled == 4 then
			local show = false
			if filter == 'debuff' then
				if spellName == self.spellName then	
					if self.checkID then
						if self.spellID == spellID then
							show = true
						end
					else
						show = true
					end
				end
			end
			return show
		end
		
		self:Hide()
		return false
	end

	iconFrames[#iconFrames+1] = f
	
	return f
end

local CheckForNewAuras

AWF.mainFrame = CreateFrame('Frame', 'AleaUI-AuraWatcherFrame', E.UIParent)
AWF.mainFrame:Hide()
AWF.mainFrame:SetFrameStrata('HIGH')
AWF.mainFrame:SetSize(300, 210)
AWF.mainFrame:SetPoint('TOPRIGHT', E.UIParent, 'TOPRIGHT', -3, -3)

AWF.mainFrame.amount = AWF.mainFrame:CreateFontString()
AWF.mainFrame.amount:SetDrawLayer('OVERLAY')
AWF.mainFrame.amount:SetPoint('BOTTOMRIGHT', AWF.mainFrame, 'BOTTOMRIGHT', -3, 3)
AWF.mainFrame.amount:SetFont(E.media.default_font2, 12, 'NONE')
AWF.mainFrame.amount:SetText('0/0')


AWF.mainFrame.textInfo = AWF.mainFrame:CreateFontString()
AWF.mainFrame.textInfo:SetDrawLayer('OVERLAY')
AWF.mainFrame.textInfo:SetPoint('BOTTOM', AWF.mainFrame, 'BOTTOM', 0, 45)
AWF.mainFrame.textInfo:SetFont(E.media.default_font2, 12, 'NONE')
AWF.mainFrame.textInfo:SetText(L['AURA_WATCHER_TEXT_DESC'])

AWF.mainFrame.headerInfo = AWF.mainFrame:CreateFontString()
AWF.mainFrame.headerInfo:SetDrawLayer('OVERLAY')
AWF.mainFrame.headerInfo:SetPoint('TOP', AWF.mainFrame, 'TOP', 0, -3)
AWF.mainFrame.headerInfo:SetFont(E.media.default_font2, 12, 'NONE')
AWF.mainFrame.headerInfo:SetText(L['AuraWatcher: New spells'])

AWF.mainFrame.addCurrent = CreateFrame("Button", AWF.mainFrame:GetName()..'AddButton', AWF.mainFrame, "OptionsButtonTemplate")
AWF.mainFrame.addCurrent:SetSize(80, 20)
AWF.mainFrame.addCurrent:SetPoint('BOTTOMLEFT', AWF.mainFrame, 'BOTTOMLEFT', 3, 3)
AWF.mainFrame.addCurrent:RegisterForClicks('AnyUp') 
_G[AWF.mainFrame.addCurrent:GetName() .. "Text"]:SetText(L["Add current"])

AWF.mainFrame.addCurrent:SetScript('OnClick', function(self, button)
	for i=1, MAX_NUM_AURA_WATCHER_FRAMES do		
		if AWF.buttons[i].spellID and AWF.buttons[i]:IsShown() then
			AWM.AddNewSpell(AWF.buttons[i].spellID, true, AWF.buttons[i].boss)
	--		print('Add new aura', GetSpellLink(AWF.buttons[i].spellID))
			options.ignoredSpells[AWF.buttons[i].spellID] = true
		end
	end
	CheckForNewAuras()
end)

AWF.mainFrame.ignoreCurrent = CreateFrame("Button", AWF.mainFrame:GetName()..'IgnoreButton', AWF.mainFrame, "OptionsButtonTemplate")
AWF.mainFrame.ignoreCurrent:SetSize(80, 20)
AWF.mainFrame.ignoreCurrent:SetPoint('LEFT', AWF.mainFrame.addCurrent, 'RIGHT', 3, 0)
AWF.mainFrame.ignoreCurrent:RegisterForClicks('AnyUp') 
_G[AWF.mainFrame.ignoreCurrent:GetName() .. "Text"]:SetText(L["Ignore current"])
AWF.mainFrame.ignoreCurrent:SetScript('OnClick', function(self, button)
	for i=1, MAX_NUM_AURA_WATCHER_FRAMES do		
		if AWF.buttons[i].spellID and AWF.buttons[i]:IsShown() then
	--		print('Ignore', GetSpellLink(AWF.buttons[i].spellID))
			options.ignoredSpells[AWF.buttons[i].spellID] = false
		end
	end
	CheckForNewAuras()
end)

local function ReBuildList()	
	for i=1, #options.NeWignoredSpells do	
		local spellInfo = options.ignoredSpells[options.NeWignoredSpells[i]]	
		if spellInfo == true or spellInfo == false then
			return table.remove(options.NeWignoredSpells, i), ReBuildList()
		end
	end	
end

local function GetBossName()
	local name = nil
	local bossname = nil
	
	local instanceName, typo = GetInstanceInfo()
	
	if typo == 'instance' or typo == 'scenario' then
		for i=1, 5 do	
			local unitName = UnitName('boss'..i)		
			if unitName then		
				name = typo..':'..unitName
				bossname = unitName
				break
			end	
		end
		
		if name then		
			if not options.encounters[name] then
				options.encounters[name] = {
					name = bossname,
					zone = instanceName,
				}
			end
			
		end
	end
	
	return name
end

function CheckForNewAuras()
	AWF.mainFrame:Hide()
	local i = 1
	
	for i=1, MAX_NUM_AURA_WATCHER_FRAMES do
		AWF.buttons[i]:Hide()
	end
	
	ReBuildList()
	
	
	local totalAnount = 0
	for num, spellID in ipairs(options.NeWignoredSpells) do
		if spellInfo and type(spellInfo) == 'string' then
			local typos, boss = strsplit(';', spellInfo)			
			if typos == 'popup_buff' or typos == 'popup_debuff' then			
				totalAnount = totalAnount + 1
			end
		end
	end
	
	
	for num, spellID in ipairs(options.NeWignoredSpells) do
		local spellInfo = options.ignoredSpells[spellID]
		
		if spellInfo and type(spellInfo) == 'string' then
			local typos, boss = strsplit(';', spellInfo)
			
			if typos == 'popup_buff' or typos == 'popup_debuff' then
				
				local bossID = tonumber(boss)
				
				AWF.buttons[i].boss = bossID or boss
				AWF.buttons[i].spellID = spellID
				AWF.buttons[i].icon:SetTexture(GetSpellTexture(spellID))
				AWF.buttons[i].auraType:SetText(( typos == 'popup_buff' and  '|cFF00FF00'..L['Buff']..'|r' or '|cFFFF0000'..L['Debuff']..'|r'))
				AWF.buttons[i]:Show()
				
				
				AWF.mainFrame.amount:SetText(format('%d/%d', i, totalAnount))
				
				i=i+1
				
				if i >= MAX_NUM_AURA_WATCHER_FRAMES+1 then
					break
				end
				
				AWF.mainFrame:Show()
			end
		end
	end
end


AWF.buttons = {}

for i=1, MAX_NUM_AURA_WATCHER_FRAMES do
	AWF.buttons[i] = CreateFrame('Button', nil, AWF.mainFrame)
	AWF.buttons[i]:SetSize(38, 38)
	AWF.buttons[i].icon = AWF.buttons[i]:CreateTexture()
	AWF.buttons[i].icon:SetAllPoints()
	AWF.buttons[i].icon:SetColorTexture(1, 0, 0, 1)
	AWF.buttons[i].icon:SetTexCoord(unpack(E.media.texCoord))
	
	AWF.buttons[i]:RegisterForClicks('AnyUp') 
	
	AWF.buttons[i].auraType = AWF.buttons[i]:CreateFontString()
	AWF.buttons[i].auraType:SetFont(E.media.default_font, E.media.default_font_size, 'OUTLINE')
	AWF.buttons[i].auraType:SetPoint('TOP', AWF.buttons[i], 'BOTTOM')
	
	AWF.buttons[i]:SetScript('OnEnter', function(self)
		if self.spellID then
			GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT")
			GameTooltip:SetSpellByID(self.spellID)
			GameTooltip:Show()
		end
	end)
	AWF.buttons[i]:SetScript('OnLeave', function(self)
		if self.spellID then
			GameTooltip:Hide()
		end
	end)
	
	AWF.buttons[i]:SetScript('OnClick', function(self, button)
		if button == 'LeftButton' then
			if self.spellID then
				AWM.AddNewSpell(self.spellID, true, self.boss)
			end
	--		print('Add new aura', GetSpellLink(self.spellID))
			options.ignoredSpells[self.spellID] = true
		else
	--		print('Ignore', GetSpellLink(self.spellID))
			options.ignoredSpells[self.spellID] = false
		end
		
		CheckForNewAuras()
	end)
	
	if i == 1 then
		AWF.buttons[i]:SetPoint('TOPLEFT', AWF.mainFrame, 'TOPLEFT', 15, -20)
	elseif i == floor( MAX_NUM_AURA_WATCHER_FRAMES*0.5 ) + 1 then
		AWF.buttons[i]:SetPoint('TOPLEFT', AWF.buttons[1], 'BOTTOMLEFT', 0, -15)
	else
		AWF.buttons[i]:SetPoint('LEFT', AWF.buttons[i-1], 'RIGHT', 20, 0)		
	end

end


function AWF:UNIT_AURA(event, unit)
	if unit ~= 'player' then return end
	
--	print('AWF', event, unit)
	
	if options.OnlyBossFights and not IsEncounterInProgress() then return end
	
	local i = 1
	
	local name, rank, icon, count, dispelType, duration, expires, caster, isStealable, shouldConsolidate, spellID, canApplyAura, isBossDebuff, value1, value2, value3
	local nameplateShowPersonal, timeMod
	
	while ( true ) do
		name, icon, count, dispelType, duration, expires, caster, isStealable, nameplateShowPersonal, spellID, canApplyAura, isBossDebuff, isCastByPlayer, timeMod, val1, val2, val3 = UnitAura(unit, i, 'HELPFUL')
		
		if not name then 
			break
		end
		
		if ( isBossDebuff or not UnitIsPlayer(caster or '') ) and not shouldConsolidate and options.ignoredSpells[spellID] == nil then
			options.ignoredSpells[spellID] = 'popup_buff'..';'..(currentEncounterID or instaceBossName or 'CUSTOM')
			table.insert(options.NeWignoredSpells, 1, spellID)
		end
		
		i = i + 1
	end
	
	i = 1 
	
	while ( true ) do
		name, icon, count, dispelType, duration, expires, caster, isStealable, nameplateShowPersonal, spellID, canApplyAura, isBossDebuff, isCastByPlayer, timeMod, val1, val2, val3 = UnitAura(unit, i, 'HARMFUL')
		
		if not name then 
			break
		end
		
		if ( isBossDebuff or not UnitIsPlayer(caster or '') ) and not shouldConsolidate and options.ignoredSpells[spellID] == nil then
			options.ignoredSpells[spellID] = 'popup_debuff'..';'..(currentEncounterID or instaceBossName or 'CUSTOM')
			table.insert(options.NeWignoredSpells, 1, spellID)
		end
		
		i = i + 1
	end
end

function AWF:ENCOUNTER_START(event, encounterID, encounterName, difficultyID, raidSize)
--	print('AWF', event, encounterName)
	
	currentEncounterName = encounterName
	currentEncounterID = encounterID
	if not options.encounters[encounterID] then
		options.encounters[encounterID] = {
			name = encounterName,
			zone = GetInstanceInfo(),
		}
	end
	
	self:RegisterEvent("UNIT_AURA")
	AWF.mainFrame:Hide()
end

function AWF:ENCOUNTER_END(event, encounterID, encounterName, difficultyID, raidSize, endStatus)
--	print('AWF', event, encounterName)

	if not options.encounters[encounterID] then
		options.encounters[encounterID] = {
			name = encounterName,
			zone = GetInstanceInfo(),
		}
	end
	
	currentEncounterName = nil
	currentEncounterID = nil
	
	self:UnregisterEvent("UNIT_AURA")
	CheckForNewAuras()
end

function AWF:BOSS_KILL(event, encounterID, encounterName )

--	print('WF:BOSS_KILL', encounterID, encounterName)
end

function AWF:PLAYER_REGEN_ENABLED(event)
--	print('AWF', event)
	
	instaceBossName = nil
	
	self:UnregisterEvent("UNIT_AURA")
	CheckForNewAuras()
end
function AWF:PLAYER_REGEN_DISABLED(event)
--	print('AWF', event)

	instaceBossName = GetBossName()

	self:RegisterEvent("UNIT_AURA")
	AWF.mainFrame:Hide()
end

local function UpdateAuraWatcherStatus()
	if options.enable_aurawatcher then
		AWF:RegisterEvent("PLAYER_REGEN_ENABLED")
		AWF:RegisterEvent("PLAYER_REGEN_DISABLED")
		AWF:RegisterEvent("ENCOUNTER_START")
		AWF:RegisterEvent("ENCOUNTER_END")
		AWF:RegisterEvent('BOSS_KILL')
	else
		AWF:UnregisterEvent("PLAYER_REGEN_ENABLED")
		AWF:UnregisterEvent("PLAYER_REGEN_DISABLED")
		AWF:UnregisterEvent("ENCOUNTER_START")
		AWF:UnregisterEvent("ENCOUNTER_END")
		AWF:UnregisterEvent("UNIT_AURA")
		AWF:UnregisterEvent('BOSS_KILL')
	end
end

local function EchoAuraWidgets(spellName, spellID, expires, duration, count, filter, curtime, value1, value2, value3, source)

	for i=1, total_spellAurasFrames do
		local f = spellAurasFrames[i]

		local enabled = f:IsEnabled(spellName, filter, spellID)

		if enabled then
			f:SetTimer(expires-duration, duration, count, 1, spellID) -- status 1 buff; 2 icd; 3 forceshow
			f:UpdateCustomText(value1, value2, value3, source)
			f._check = curtime	
		end
	end
end

function AWM:UNIT_AURA(event, unit)
	if not unit_to_check[unit] then return end
	
	local i = 1
	
	for i=1, #anchors do
		anchors[i].numauras = 0
		anchors[i].totalWidth = 0
	end
	
	local curtime = GetTime()
	
	local name, rank, icon, count, dispelType, duration, expires, caster, isStealable, shouldConsolidate, spellID, canApplyAura, isBossDebuff, value1, value2, value3, isCastByPlayer
	local nameplateShowPersonal, timeMod
	
	while ( true ) do
		name, icon, count, dispelType, duration, expires, caster, isStealable, nameplateShowPersonal, spellID, canApplyAura, isBossDebuff, isCastByPlayer, timeMod, value1, value2, value3 = UnitAura(unit, i, 'HELPFUL')
		
		if not name then 
			break
		end
		
		EchoAuraWidgets(name, spellID, expires, duration, count, 'buff', curtime, value1, value2, value3, caster)
		
		i = i + 1
	end
	
	i = 1 
	
	while ( true ) do
		name, icon, count, dispelType, duration, expires, caster, isStealable, nameplateShowPersonal, spellID, canApplyAura, isBossDebuff, isCastByPlayer, timeMod, value1, value2, value3 = UnitAura(unit, i, 'HARMFUL')
		
		if not name then 
			break
		end
		
		EchoAuraWidgets(name, spellID, expires, duration, count, 'debuff', curtime, value1, value2, value3, caster)
		
		i = i + 1
	end
	
	
	for i=1, total_spellAurasFrames do		
		if spellAurasFrames[i]._check ~= curtime then
			spellAurasFrames[i]:EndTimer()
		end
	end
end

local function RebuildAuras()
	wipe(unit_to_check)
	wipe(spellName_to_frame)
	wipe(spellAurasFrames)
	
	for i=1, #iconFrames do
		iconFrames[i].free = true
		iconFrames[i]:Hide()
	end
	
	unit_to_check['player'] = true
	
	AWM:UnregisterEvent("UNIT_AURA")

	total_spellAurasFrames = 0
	
	if options.enable_auraModule then
		for k,v in pairs(options.spelllist) do			
			if v.showing ~= 2 then
			
				total_spellAurasFrames = total_spellAurasFrames + 1
				
				local widget = GetIcon()
				widget:UpdateSettings(v)	
				
				spellAurasFrames[total_spellAurasFrames] = widget

				unit_to_check[v.unit] = true
				
				AWM:RegisterEvent("UNIT_AURA")
			end
		end
		
		AWM:UNIT_AURA(nil, 'player')
	end
end

function AWM.AddNewSpell(spell, openspell, filter)

	local num = tonumber(spell)	
	local spellName = num and GetSpellInfo(num) or spell
	
--	print("T", 'Add New Spell', spell, spellName, num)
	
	options.anount_spelllist = options.anount_spelllist + 1
	
	table.insert(options.spelllist, {
		showing = 1,
		fakeName = 'New aura'..options.anount_spelllist,
		show = true,
		size = default_size,
		checkID = false,
		spellID = num,
		spellName = spellName,
		unit = '',
		setReverse = false,
		filter = filter,
		anchor = next(options.anchors),
		showGlow = false,
	})
	
	RebuildAuras()
	
	selectedspell = #options.spelllist
	
	if openspell then
		AleaUI_GUI:Open(addonName)
		AleaUI_GUI:SelectGroup(addonName, "AuraWidgets", "spellList")
	end		
end

function AWM:CreateNewAnchor()
	for i=1, #anchors do		
		if anchors[i].free then
			return anchors[i]
		end
	end
	
	local f = CreateFrame("Frame", nil, E.UIParent)
	f:SetSize(20, 20)
	f:SetPoint("CENTER", E.UIParent, 'CENTER', 0, 0)
	f:Hide()
	f.free = false
	
	anchors[#anchors+1] = f
	
	return anchors[#anchors]
end

function AWM:UpdateAnchors()
	wipe(name_to_anchors)
	for i=1, #anchors do
		anchors[i].free = true
	end
	
	for name, data in pairs(options.anchors) do	
		local frame = AWM:CreateNewAnchor()	

		name_to_anchors[name] = frame
		
		E:Mover(frame, mover_tag..name)	
	end

end

local function GetEncounterIDbyName(name)	
	for id, data in pairs(options.encounters) do		
		if data.name == name then
			return id
		elseif id == tonumber(name or '') then
			return id
		end
	end
	
	return false
end

function E:UpdateAuraWidgetOptions()
	options = AleaUI_AuraWidgets
end

local function InitAuraWidgets()
	
	
	if AleaUI_AuraWidgets == nil then
		if AleaUIDB.profiles.Default.auraWidgets and not AleaUIDB.profiles.Default.auraWidgets.exported then
			AleaUIDB.profiles.Default.auraWidgets.exported = true
			AleaUI_AuraWidgets = AleaUIDB.profiles.Default.auraWidgets
		--	print('AleaUI AuraWidgets DB successfuly loaded.')
		end
	end

	if AleaUIDB.profiles.Default.auraWidgets and AleaUIDB.profiles.Default.auraWidgets.exported then
		AleaUIDB.profiles.Default.auraWidgets = nil
	end
	
	AleaUI_AuraWidgets = AleaUI_AuraWidgets or {}
	
	options = AleaUI_AuraWidgets

	if not options.font then
		options.font = ''
	end
	
	if not options.spelllist then
		options.spelllist = {}
	end

	if not options.ignoredSpells then
		options.ignoredSpells = {}
	end
	
	if not options.NeWignoredSpells then
		options.NeWignoredSpells = {}
	end
	
	if not options.anchors then
		options.anchors = {}	
	end
	
	options.anchors["Boss Debuffs"] = options.anchors["Boss Debuffs"] or {}
	options.anchors["Boss Debuffs"].grow = options.anchors["Boss Debuffs"].grow or 'LEFT'
	options.anchors["Boss Debuffs"].name = options.anchors["Boss Debuffs"].name or "Boss Debuffs"
	options.anchors["Boss Debuffs"].size = options.anchors["Boss Debuffs"].size or 80
	
	if not options.anount_spelllist then
		options.anount_spelllist = 0
	end
	
	if not options.encounters then
		options.encounters = {}
	end
	
	for index, data in pairs(options.spelllist) do
		if data.filter and data.filter ~= 'CUSTOM' then
			data.filter = GetEncounterIDbyName(data.filter)	or data.filter			
		end
	end
	
	
		
	Skins.ThemeButton(AWF.mainFrame.addCurrent)
	Skins.ThemeButton(AWF.mainFrame.ignoreCurrent)
	Skins.SetTemplate(AWF.mainFrame, 'DARK')
	
	AWM:UpdateAnchors()
	
	RebuildAuras()
	UpdateAuraWatcherStatus()
	CheckForNewAuras()
	
	E.GUI.args.AuraWidgets = {
		name = L["Aura widgets"],
		type = "group",
		order = 10,
		args = {},	
	}
	
	E.GUI.args.AuraWidgets.args.enable_auraModule = {
		name = L['Enable module'],
		type = "toggle", width = 'full',
		desc = L['Show spells from list'],
		order = 0.1,
		set = function(self, value)
			options.enable_auraModule = not options.enable_auraModule
		end,
		get = function(self)
			return options.enable_auraModule
		end,	
	}
	
	E.GUI.args.AuraWidgets.args.AuraWatcher = {
		name = L['Enable "AuraWatcher"'],
		type = "toggle",
		desc = L['Show list with new spells after combat'],
		order = 1,
		set = function(self, value)
			options.enable_aurawatcher = not options.enable_aurawatcher
			
			UpdateAuraWatcherStatus()
		end,
		get = function(self)
			return options.enable_aurawatcher
		end,	
	}
	
	E.GUI.args.AuraWidgets.args.OnlyBossFights = {
		name = L['Scan only boss fights'],
		type = "toggle",
		order = 2,
		set = function(self, value)
			options.OnlyBossFights = not options.OnlyBossFights
			
			UpdateAuraWatcherStatus()
		end,
		get = function(self)
			return options.OnlyBossFights
		end,	
	}
	
	E.GUI.args.AuraWidgets.args.Import_Export = {
		order = 99997,name = L["Export & Import"],type = "group",
		args={},
	}
	
	E.GUI.args.AuraWidgets.args.Import_Export.args.Export = {
		name = L['Export All Auras'],
		type = 'execute',
		order = 4.9,
		set = function(info, value)
			E:ExportAuraList()		
		end,
		get = function(self)
		end,
	}
	E.GUI.args.AuraWidgets.args.Import_Export.args.Import = {
		type = 'execute',
		order = 5,
		name = L['Import'],
		set = function(info, value)
			E:ImportProfile()	
		end,
		get = function(self)
		end,
	}

	E.GUI.args.AuraWidgets.args.AuraWatcherResetList = {
		name = L['Cache reset'],
		type = "execute",
		order = 6,
		set = function(self)
			wipe(options.ignoredSpells)
			wipe(options.NeWignoredSpells)
		end,
		get = function(self)
		end,	
	}
	
	E.GUI.args.AuraWidgets.args.anchors = {
		name = L['Anchors'],
		type = "group",
		order = 1,
		args = {},	
	}
	
	E.GUI.args.AuraWidgets.args.anchors.args.create = {
		name = "",
		type = "group",
		order = 1,
		embend = true,
		args = {},	
	}
	E.GUI.args.AuraWidgets.args.anchors.args.settings = {
		name = "",
		type = "group",
		order = 2,
		embend = true,
		args = {},	
	}
	
	E.GUI.args.AuraWidgets.args.anchors.args.create.args.name = {
		name = L['Name'],
		type = "editbox",
		order = 1,
		set = function(self, value)			
			if not options.anchors[value] then
				options.anchors[value] = {}
				options.anchors[value].name = value
				options.anchors[value].size = 80
				options.anchors[value].grow = "LEFT"					
			end
			
			AWM:UpdateAnchors()
		end,
		get = function(self)
			return ''
		end,
	}

	E.GUI.args.AuraWidgets.args.anchors.args.create.args.anchorlist = {
		name = L['Select anchor'],
		type = "dropdown",
		order = 2,
		values = function() 
			local t = {}			
			for k,v in pairs(options.anchors) do			
				t[k] = k
			end
			return t
		end,
		set = function(self, value)
			selectedanchor = value
		end,
		get = function(self)
			return selectedanchor
		end,	
	}
	
	E.GUI.args.AuraWidgets.args.anchors.args.settings.args.lock = {
		name = L['Unlock'],
		type = "execute",
		order = 1,
		set = function(self)
			if selectedanchor then
				local name = mover_tag..selectedanchor
				E:UnlockMover(name)
				
				if E:IsUnlocked(name) then
					E.GUI.args.AuraWidgets.args.anchors.args.settings.args.lock.name = L['Заблокировать']
				else
					E.GUI.args.AuraWidgets.args.anchors.args.settings.args.lock.name = L['Разблокировать']
				end
			end
		end,
		get = function(self)		
			if selectedanchor then
				local name = mover_tag..selectedanchor
				
				if E:IsUnlocked(name) then
					E.GUI.args.AuraWidgets.args.anchors.args.settings.args.lock.name = L['Заблокировать']
				else
					E.GUI.args.AuraWidgets.args.anchors.args.settings.args.lock.name = L['Разблокировать']
				end
			end
		end,	
	}

	E.GUI.args.AuraWidgets.args.anchors.args.settings.args.grow = {
		name = L['Grow'],
		type = "dropdown",
		order = 2,
		values = function()
			local t = {}			
			for k in pairs(ANCHOR_GROW)	do
				t[k] = k
			end
			return t
		end,
		set = function(self, value)
			if selectedanchor then
				options.anchors[selectedanchor].grow = value
				
				RebuildAuras()
			end
		end,
		get = function(self)
			if selectedanchor then
				return options.anchors[selectedanchor].grow
			end
		end,	
	}
	
	
	
	E.GUI.args.AuraWidgets.args.spellList = {
		name = L['Spell list'],
		type = "group",
		order = 2,
		args = {},	
	}

	E.GUI.args.AuraWidgets.args.spellList.args.create = {
		name = "",
		type = "group",
		order = 1,
		embend = true,
		args = {},	
	}

	E.GUI.args.AuraWidgets.args.spellList.args.settings = {
		name = "",
		type = "group",
		order = 2,
		embend = true,
		args = {},	
	}

	E.GUI.args.AuraWidgets.args.spellList.args.create.args.spellid = {
		name = L['SpellID'],
		type = "editbox",
		order = 1,
		set = function(self, value)
			AWM.AddNewSpell(value, false, 'CUSTOM')
		end,
		get = function(self)
			return ''
		end,

	}
	
	local filter_cutom = 'ALL'
	--[==[
	E.GUI.args.AuraWidgets.args.spellList.args.create.args.filters = {
		name = "Фильтр",
		type = "dropdown",
		order = 1.5,
		values = function()
			local t = {}
			t['ALL'] = 'All'			
			for spellname,params in pairs(options.spelllist) do
			
				local tag 
					
				if params.filter and options.encounters[params.filter] then
					tag = options.encounters[params.filter].name
				elseif params.filter == 'CUSTOM' then
					tag = 'Свои ауры'
				elseif params.filter then
					tag = params.filter
				end
						
				if tag then
					t[params.filter] = tag
				end
			end			
			return t
		end,
		set = function(self, value)			
			filter_cutom = value
		end,
		get = function(self)
			return filter_cutom
		end,	
	}
	]==]
	E.GUI.args.AuraWidgets.args.spellList.args.create.args.filters_multi = {
		name = L['Filters'],
		type = "multiselect",
		order = 1.6,
		values = function()
			local t = {}
			
			t[1] = { name = L['All'],  value = 'ALL' }
			t[2] = { name = L['Custom'], value = 'CUSTOM' }
			
			local zones = {}
			local bosses = {}
			
			for spellname,params in pairs(options.spelllist) do
			
				if params.filter and options.encounters[params.filter] then
				
					local name = options.encounters[params.filter].name
					local zone = options.encounters[params.filter].zone
					
					if not zones[zone] then
						t[#t+1] = { name = zone, values = {} }					
						zones[zone] = #t
					end
					
					
					t[zones[zone]].values[name] = {
						name = name,
						value = params.filter,
					}
				end
			
			end			
			return t
		end,
		set = function(self, value)			
			filter_cutom = value
		end,
		get = function(self)
			return filter_cutom
		end,	
	}

	
	E.GUI.args.AuraWidgets.args.spellList.args.create.args.spelllist = {
		name = L['Select spell'],
		type = "dropdown",
		order = 2,
		width = 'full',
		values = function()
			local t = {}			
			for spellname,params in pairs(options.spelllist) do			
				if filter_cutom == 'ALL' or ( filter_cutom == params.filter ) then
				
					if filter_cutom == 'ALL' then
						local tag 
					
						if params.filter and options.encounters[params.filter] then
							tag = options.encounters[params.filter].name
						elseif params.filter then
							tag = params.filter
						end
						
						tag = tag or UNKNOWN
						
						local spell_name = params.spellID and E:SpellString(params.spellID) or params.spellName or params.fakeName
						t[spellname] = ( tag ~= '' and '|cFFFFFF00'..tag..'|r - ' or '')..spell_name						
					elseif ( filter_cutom == params.filter ) then
						local spell_name = params.spellID and E:SpellString(params.spellID) or params.spellName or params.fakeName					
						t[spellname] = spell_name
					else
						t[spellname] = params.fakeName
					end
				end
			end			
			return t
		end,
		set = function(self, value)			
			selectedspell = value
		end,
		get = function(self)
			return selectedspell
		end,	
	}

	
	E.GUI.args.AuraWidgets.args.spellList.args.settings.args.fakeName = {
		name = L['Name'],
		type = "editbox",
		order = 3.9,
		width = 'full',
		set = function(self, value)
			if selectedspell and value ~= '' then
				options.spelllist[selectedspell].fakeName = value			
				RebuildAuras()
			end
		end,
		get = function(self)
			if selectedspell then
				return options.spelllist[selectedspell].fakeName or ''
			else
				return ''
			end
		end,	
	}
	
	E.GUI.args.AuraWidgets.args.spellList.args.settings.args.show = {
		name = L['Show'],
		type = "dropdown",
		order = 4,
		values = {		
			L['Always'],
			L['Never'],
			L['Only buff'],
			L['Only debuff'],
		},
		set = function(self, value)
			if selectedspell then
				options.spelllist[selectedspell].showing = value
				
				RebuildAuras()
			end
		end,
		get = function(self)
			if selectedspell then
				return options.spelllist[selectedspell].showing or 1
			else
				return 1
			end
		end,	
	}

	E.GUI.args.AuraWidgets.args.spellList.args.settings.args.spellID = {
		name = L['SpellID'],
		type = "editbox",
		order = 4,
		set = function(self, value)
			local num = tonumber(value)
			
			if selectedspell and num then
				options.spelllist[selectedspell].spellID = num
				
				RebuildAuras()
			end
		end,
		get = function(self)
			if selectedspell then
				return options.spelllist[selectedspell].spellID or ''
			else
				return ''
			end
		end,	
	}
	
	E.GUI.args.AuraWidgets.args.spellList.args.settings.args.spellName= {
		name = L['Spell name'],
		type = "editbox",
		order = 4.1,
		set = function(self, value)
			if selectedspell and value ~= '' then
				options.spelllist[selectedspell].spellName = value
				
				RebuildAuras()
			end
		end,
		get = function(self)
			if selectedspell then
				return options.spelllist[selectedspell].spellName or ''
			else
				return ''
			end
		end,	
	}
	
	E.GUI.args.AuraWidgets.args.spellList.args.settings.args.checkID = {
		name = L['Check ID'],
		type = "toggle",
		order = 4,
		set = function(self, value)
			if selectedspell then
				options.spelllist[selectedspell].checkID = not options.spelllist[selectedspell].checkID
				
				RebuildAuras()
			end
		end,
		get = function(self)
			if selectedspell then
				return options.spelllist[selectedspell].checkID or false
			else
				return false
			end
		end,	
	}
	
	E.GUI.args.AuraWidgets.args.spellList.args.settings.args.ShowGlow = {
		name = L['Shine'],
		type = "toggle",
		order = 4,
		set = function(self, value)
			if selectedspell then
				options.spelllist[selectedspell].showGlow = not options.spelllist[selectedspell].showGlow
				
				RebuildAuras()
			end
		end,
		get = function(self)
			if selectedspell then
				return options.spelllist[selectedspell].showGlow or false
			else
				return false
			end
		end,	
	}

	E.GUI.args.AuraWidgets.args.spellList.args.settings.args.unit = {
		name = L['Unit'],
		type = "editbox",
		order = 6,
		set = function(self, value)
			if selectedspell and value then
				options.spelllist[selectedspell].unit = value
				
				RebuildAuras()
			end
		end,
		get = function(self)
			if selectedspell then
				return options.spelllist[selectedspell].unit or ''
			else
				return ''
			end
		end,	
	}
	
	E.GUI.args.AuraWidgets.args.spellList.args.settings.args.customText = {
		name = L['Custom text'],
		type = "multieditbox",
		order = 6.1,
	--	width = 'full',
		set = function(self, value)
			if selectedspell and value ~= '' then
				options.spelllist[selectedspell].customName = value			
				RebuildAuras()
			end
		end,
		get = function(self)
			if selectedspell then
				return options.spelllist[selectedspell].customName or ''
			else
				return ''
			end
		end,	
	}
	
	E.GUI.args.AuraWidgets.args.spellList.args.settings.args.SoundFile = {					
		type = "group",	order	= 8,
		embend = true,
		name	= L['Sound'],
		args = {						
			OnShow = {
				order = 1,type = 'sound',name = L["On Show"],
			--	dialogControl = 'LSM30_Sound',
				values = function() 
					return LSM:HashTable("sound")
				end,
				set = function(info,value) 
					if selectedspell then 
						options.spelllist[selectedspell].sound_onshow = value
						
						RebuildAuras()
					end
				end,
				get = function(info) 
					if not selectedspell then return "None" end
					return options.spelllist[selectedspell] and options.spelllist[selectedspell].sound_onshow or "None"; 
				end,
			},
			OnHide = {
				order = 1,type = 'sound',name = L["On Hide"],
			--	dialogControl = 'LSM30_Sound',
				values = LSM:HashTable("sound"),
				set = function(info,value) 
					if selectedspell then
						options.spelllist[selectedspell].sound_onhide = value 
						
						RebuildAuras()
					end
				end,
				get = function(info) 
					if not selectedspell then return "None" end
					return options.spelllist[selectedspell] and options.spelllist[selectedspell].sound_onhide or "None";
				end,
			},
		}
	}
							
	--[[
	E.GUI.args.AuraWidgets.args.spellList.args.settings.args.setReverse = {
		name = "Reverse",
		type = "toggle",
		order = 5,
		set = function(self, value)
			if selectedspell then
				options.spelllist[selectedspell].setReverse = not options.spelllist[selectedspell].setReverse
				
				RebuildAuras()
			end
		end,
		get = function(self)
			if selectedspell then
				return options.spelllist[selectedspell].setReverse or false
			else
				return false
			end
		end,	
	}
	]]
	E.GUI.args.AuraWidgets.args.spellList.args.settings.args.size = {
		name = L['Size'],
		type = "slider", min = 1, max = 150, step = 1,
		order = 4,
		set = function(self, value)
			if selectedspell then
				options.spelllist[selectedspell].size = value
				
				RebuildAuras()
			end
		end,
		get = function(self)
			if selectedspell then
				return options.spelllist[selectedspell].size or 1
			else
				return 1
			end
		end,	
	}
	
	E.GUI.args.AuraWidgets.args.spellList.args.settings.args.anchorlist = {
		name = L['Select anchor'],
		type = "dropdown",
		order = 5,
		values = function() 
			local t = {}			
			for k,v in pairs(options.anchors) do			
				t[k] = k
			end
			return t
		end,
		set = function(self, value)
			if selectedspell then
				options.spelllist[selectedspell].anchor = value
				RebuildAuras()
			end
		end,
		get = function(self)
			if selectedspell then
				return options.spelllist[selectedspell].anchor
			end
		end,	
	}
	
	
	E.GUI.args.AuraWidgets.args.spellList.args.settings.args.filters = {
		name = L['Filter'],
		type = "dropdown",
		order = 9.9,
		values = function()
			local t = {}
			t['CUSTOM'] = L['Custom auras']	
			for id,params in pairs(options.encounters) do
				t[id] = params.name
			end			
			return t
		end,
		set = function(self, value)			
			if selectedspell then
				options.spelllist[selectedspell].filter = value
			end
		end,
		get = function(self)
			if selectedspell then
				return options.spelllist[selectedspell].filter
			end
		end,	
	}
	
	E.GUI.args.AuraWidgets.args.spellList.args.settings.args.delete = {
		name = L['Delete'],
		type = 'execute',
		order = 10,
		set = function()
			if selectedspell then	
				table.remove(options.spelllist, selectedspell)				
				selectedspell = nil
				RebuildAuras()
			end
		end,
		get = function()
		
		end,
	
	}
	E.GUI.args.AuraWidgets.args.spellList.args.settings.args.export = {
		name = L['Export'],
		type = 'execute',
		order = 11,
		set = function()
			if selectedspell then
				E:ExportAura(options.spelllist[selectedspell], options.encounters)
			end
		end,
		get = function()
		
		end,
	
	}
	
end

E:OnInit2(InitAuraWidgets)