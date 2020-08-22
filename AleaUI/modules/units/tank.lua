local addonName, E = ...
local TF = E:Module("Tanks")
local UF = E:Module("UnitFrames")

local enabled = true

TF:RegisterEvent("GROUP_ROSTER_UPDATE")
TF:RegisterEvent("PLAYER_ENTERING_WORLD")
TF:RegisterEvent("PLAYER_ENTERING_BATTLEGROUND")
TF:RegisterEvent("GROUP_JOINED")
TF:RegisterEvent("GROUP_LEFT")
TF:RegisterEvent("RAID_INSTANCE_WELCOME")
TF:RegisterEvent("ZONE_CHANGED_NEW_AREA")	
TF:RegisterEvent("UNIT_NAME_UPDATE")
TF:RegisterEvent("INSPECT_READY")
TF:RegisterEvent("PLAYER_REGEN_ENABLED")
TF:RegisterEvent("ROLE_CHANGED_INFORM")
TF:RegisterEvent("PLAYER_ROLES_ASSIGNED")
TF:RegisterEvent("PLAYER_REGEN_DISABLED")

-- TF:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")


local gmatch = gmatch
local IsInRaid = IsInRaid
local GetRaidRosterInfo = GetRaidRosterInfo
local UnitGroupRolesAssigned = UnitGroupRolesAssigned
local UnitName = UnitName
local pairs = pairs
local ipairs = ipairs
local unpack = unpack
local InCombatLockdown = InCombatLockdown
local GetSpecializationInfoByID = GetSpecializationInfoByID
local GetInspectSpecialization = GetInspectSpecialization

local tanks = {}
local tanks_s = {}
local guid_in_queue = {}
local force_name = {}
local statusbartexture = "Interface\\AddOns\\AleaUI\\media\\Minimalist.tga"

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
	
local w,h = 126, 20
local enemy_color = { 1,  0,  0}
local friendly_color = { 0,  0.6,  0}

local difficultyRaidSize = {
	[0] = 40, -- None; not in an Instance.
	[1] = 5, -- 5-player Instance.
	[2] = 5, -- 5-player Heroic Instance.
	[3] = 10, -- 10-player Raid Instance.
	[4] = 25, -- 25-player Raid Instance.
	[5] = 10, -- 10-player Heroic Raid Instance.
	[6] = 25, -- 25-player Heroic Raid Instance.
	[7] = 25, -- 25-player Raid Finder Instance.
	[8] = 5, -- Challenge Mode Instance.
	[9] = 40, -- 40-player Raid Instance.
	[10] = 40, -- Not used.
	[11] = 3, -- Heroic Scenario Instance.
	[12] = 3, -- Scenario Instance.
	[13] = 40, -- Not used.
	[14] = 30, -- 10-30-player Normal Raid Instance.
	[15] = 30, -- 10-30-player Heroic Raid Instance.
	[16] = 20, -- 20-player Mythic Raid Instance .
	[17] = 25, -- 10-30-player Raid Finder Instance.
	[18] = 40, -- 40-player Event raid (Used by the level 100 version of Molten Core for WoW's 10th anniversary).
	[19] = 5, -- 5-player Event instance (Used by the level 90 version of UBRS at WoD launch).
	[20] = 25, -- 25-player Event scenario (unknown usage).
	[21] = 40, -- Not used.
	[22] = 40, -- Not used.
	[23] = 5, -- Mythic 5-player Instance.
	[24] = 5, -- Timewalker 5-player Instance.
}

local loop = CreateFrame("Frame")
loop:SetScript("OnUpdate", function(self, elapsed)	
	self.elapsed = ( self.elapsed or 0 ) + elapsed
	if self.elapsed < 0.05 then return end
	self.elapsed = 0
	TF:GROUP_ROSTER_UPDATE(_, "forced")
end)
function TF:GROUP_ROSTER_UPDATE(event, forced)
	if not enabled then return end
	if not IsInRaid() then return end

	if forced ~= "forced" then
		loop:Show()
		return 
	end
	
	loop:Hide()

	local index = 0
	wipe(tanks_s)
	wipe(guid_in_queue)

	local name, instanceType, difficultyIndex, difficultyName, maxPlayers, playerDifficulty, isDynamic, mapID, instanceGroupSize = GetInstanceInfo();
	local numPlayers = 8
	
	if ( instanceType == "party" or instanceType == "raid" ) then
		numPlayers = ceil(( difficultyRaidSize[difficultyIndex]  or 5 ) / 5)
	end

	for i = 1,  MAX_RAID_MEMBERS do
		local name, rank, subgroup, level, class, fileName, zone, online, isDead, role, isML = GetRaidRosterInfo(i)	
		if name and subgroup <= numPlayers then		
			local unitName = UnitName("raid"..i)

			guid_in_queue[UnitGUID("raid"..i)] = "raid"..i
			
			if role == "MAINTANK" or role == "MAINASSIST" or ( UnitGroupRolesAssigned("raid"..i) == "TANK" ) or force_name[UnitName("raid"..i)] then
				index = index + 1			
				tanks_s[index] = "raid"..i

				--			print(name, unitName, index, tanks_s[index], role, UnitGroupRolesAssigned("raid"..i))

				if index > 5 then break end
			end
		end
	end

	if not InCombatLockdown() then
		for i, unit in pairs(tanks_s) do	
			self:CreateTankFrames(unit, i)
		end
	end
end

TF.PLAYER_ENTERING_WORLD 		= TF.GROUP_ROSTER_UPDATE
TF.PLAYER_ENTERING_BATTLEGROUND = TF.GROUP_ROSTER_UPDATE
TF.GROUP_JOINED 				= TF.GROUP_ROSTER_UPDATE
TF.GROUP_LEFT 					= TF.GROUP_ROSTER_UPDATE
TF.RAID_INSTANCE_WELCOME 		= TF.GROUP_ROSTER_UPDATE
TF.ZONE_CHANGED_NEW_AREA 		= TF.GROUP_ROSTER_UPDATE
TF.PLAYER_REGEN_ENABLED 		= TF.GROUP_ROSTER_UPDATE
TF.PLAYER_REGEN_DISABLED 		= TF.GROUP_ROSTER_UPDATE
TF.UNIT_NAME_UPDATE 			= TF.GROUP_ROSTER_UPDATE
TF.ROLE_CHANGE_INFORM 			= TF.GROUP_ROSTER_UPDATE
TF.PLAYER_ROLES_ASSIGNED 		= TF.GROUP_ROSTER_UPDATE

function TF:INSPECT_READY(event, guid)
	if guid_in_queue[guid] then
	
	local unit2 = guid_in_queue[guid]
	local _, _, _, _, _, specRole = GetSpecializationInfoByID(GetInspectSpecialization(unit2))
	
		if specRole == "TANK" then
			local exists = false
			
			for i, unit in ipairs(tanks_s) do
			
				if UnitIsUnit(unit2, unit) then
					exists = true					
					break
				end
			end
			
			if not exists then
		--		print("Add Tank By Role", UnitName(unit2))
			end
		end
	end	
end

function TF:PLAYER_SPECIALIZATION_CHANGED(event, unit)
--	unit = unit or "player"	

--	local _, _, _, _, _, specRole = GetSpecializationInfoByID(GetInspectSpecialization(unit))
	
--	print(event, UnitName(unit), specRole)
	
--	guid_in_queue[UnitGUID(unit)] = unit
end

function TF:GetColor(unit)
	
	if UnitIsPlayer(unit) then
		local _, class = UnitClass(unit)
		
		if RAID_CLASS_COLORS[class] then		
			return RAID_CLASS_COLORS[class].r*.8, RAID_CLASS_COLORS[class].g*.8, RAID_CLASS_COLORS[class].b*.8		
		else
			if UnitCanAttack("player", unit) then				
				return enemy_color[1], enemy_color[2], enemy_color[3]
			else			
				return friendly_color[1], friendly_color[2], friendly_color[3]
			end
		end
	else
		if UnitCanAttack("player", unit) or UnitIsEnemy("player",unit) then				
			return enemy_color[1], enemy_color[2], enemy_color[3]
		else			
			return friendly_color[1], friendly_color[2], friendly_color[3]
		end	
	end
end


local mover = CreateFrame("Frame", nil, E.UIParent)
mover:SetSize(320,20)
mover:SetPoint("CENTER", E.UIParent, "CENTER", 0, 0)

function TF:CreateTankFrame(parent, unit, onupdate)
	
	local handler = CreateFrame('Button', nil, parent, "SecureUnitButtonTemplate")
	handler:SetSize(w, h)
	handler:SetFrameStrata("MEDIUM")
	handler:SetFrameLevel(2)
	handler:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	handler:SetAttribute("type1", "target")
	handler:SetAttribute("shift-type1", "target")
	handler:SetAttribute("unit", unit)
	handler:SetAttribute("type2", "togglemenu")
	
	RegisterUnitWatch(handler)
	
	local frame = CreateFrame("StatusBar", nil, handler)
	frame:SetSize(w,h)
	frame:SetAllPoints()
	frame:SetStatusBarTexture(statusbartexture)
	frame:SetFrameStrata("LOW")
	frame:SetMinMaxValues(0, 100)
	frame:SetValue(50)
	
	frame.select = {}
	
	local color_target = { 232/255, 228/255, 111/255, 1}
	
	frame.select[1] = frame:CreateTexture(nil, "BORDER", nil, 5)
	frame.select[1]:SetSize(1,1)
	frame.select[1]:SetPoint("TOPRIGHT",frame,"TOPLEFT",0,1)
	frame.select[1]:SetPoint("BOTTOMRIGHT",frame,"BOTTOMLEFT",0,-1)
	frame.select[1]:SetColorTexture(unpack(color_target))
	frame.select[1]:Hide()
	
	frame.select[2] = frame:CreateTexture(nil, "BORDER", nil, 5)
	frame.select[2]:SetSize(1,1)
	frame.select[2]:SetPoint("BOTTOMRIGHT",frame,"TOPRIGHT",1,0)
	frame.select[2]:SetPoint("BOTTOMLEFT",frame,"TOPLEFT",-1,0)
	frame.select[2]:SetColorTexture(unpack(color_target))
	frame.select[2]:Hide()
	
	frame.select[3] = frame:CreateTexture(nil, "BORDER", nil, 5)
	frame.select[3]:SetSize(1,1)
	frame.select[3]:SetPoint("TOPLEFT",frame,"TOPRIGHT",0,1)
	frame.select[3]:SetPoint("BOTTOMLEFT",frame,"BOTTOMRIGHT",0,-1)
	frame.select[3]:SetColorTexture(unpack(color_target))
	frame.select[3]:Hide()
	
	frame.select[4] = frame:CreateTexture(nil, "BORDER", nil, 5)
	frame.select[4]:SetSize(1,1)
	frame.select[4]:SetPoint("TOPRIGHT",frame,"BOTTOMRIGHT",1,0)
	frame.select[4]:SetPoint("TOPLEFT",frame,"BOTTOMLEFT",-1,0)
	frame.select[4]:SetColorTexture(unpack(color_target))
	frame.select[4]:Hide()
	
	frame.select.Show = function(self)
		self[1]:Show();self[2]:Show();self[3]:Show();self[4]:Show()
	end
	frame.select.Hide = function(self)
		self[1]:Hide();self[2]:Hide();self[3]:Hide();self[4]:Hide()
	end
		
	frame.unit = unit
	frame.handler = handler
	handler.art = frame
	
	E:CreateBackdrop(frame, nil, { 0,0,0,1}, { 0,0,0,1})
	
	local rightText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal");
	rightText:SetPoint("RIGHT", frame, "RIGHT", 0, 0)	
	rightText:SetTextColor(1,1,1)
	rightText:SetFont(E.media.default_font, 9, "OUTLINE")
	rightText:SetAlpha(1)
	rightText:SetJustifyH("RIGHT")
	rightText:SetWordWrap(false)
	frame.rightText = rightText
	
	local leftText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal");
	leftText:SetPoint("LEFT", frame, "LEFT", 0, 0)
	leftText:SetPoint("RIGHT", rightText, "LEFT", 0, 0)	
	leftText:SetTextColor(1,1,1)
	leftText:SetFont(E.media.default_font, 9, "OUTLINE")
	leftText:SetAlpha(1)
	leftText:SetJustifyH("LEFT")
	leftText:SetWordWrap(false)
	frame.leftText = leftText
	
	
	local rit = frame:CreateTexture(nil,"OVERLAY", nil, -5)
	rit:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
	rit:SetPoint("TOP", frame, "TOP", 0,5)
	rit:SetSize(h*0.7,h*0.7)
	rit:Hide()
	--[[
	local rits = frame:CreateTexture(nil,"OVERLAY", nil, -6)
	rits:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
	rits:SetPoint("CENTER", rit, "CENTER", 0,0)
	rits:SetSize(h,h)
	rits:SetVertexColor(0,0,0,1)
	rits:Hide()
	]]
	frame.raidMark = rit
--	frame.raidMarkShadow = rits
	
	frame:SetScript("OnEvent", function(self, event, ...)			
		self[event](self, event, ...)
	end)

	frame.RAID_TARGET_UPDATE = function(self)
		if not UnitExists(self.unit) then 
			self.raidMark:Hide()
	--		self.raidMarkShadow:Hide()
			return 
		end
		local mark = GetRaidTargetIndex(self.unit);

		if ( raidIndexCoord[mark] ) then
			self.raidMark:Show()
			self.raidMark:SetTexCoord(unpack(raidIndexCoord[mark]))
			
		--	self.raidMarkShadow:Show()
		--	self.raidMarkShadow:SetTexCoord(unpack(raidIndexCoord[mark]))
		else
			self.raidMark:Hide()
		--	self.raidMarkShadow:Hide()
		end		
	end
	
	frame.UNIT_HEALTH = function(self, event, unit)
		if self.unit ~= unit then return end
		
		local hp, maxhp = UnitHealth(self.unit), UnitHealthMax(self.unit)

		self:SetMinMaxValues(0, maxhp)
		self:SetValue(hp)
		
		if self.guid ~= UnitGUID(self.unit) then
			self.guid = UnitGUID(self.unit)
			local r,g,b = TF:GetColor(self.unit)
			self:SetStatusBarColor(r,g,b, 1)
			
			self:RAID_TARGET_UPDATE()
			self:PLAYER_TARGET_CHANGED()
		end
		
		if maxhp and maxhp > 0 then
			self.rightText:SetText(format("%.0f%%",hp/maxhp*100))
		else
	--		print(maxhp, hp, UnitGUID(self.unit), UnitName(self.unit))
			
			self.rightText:SetText("??")
		end
	end
	
	frame.PLAYER_TARGET_CHANGED = function(self)
		if UnitIsUnit(self.unit, "target") then
			self.select:Show()
		else
			self.select:Hide()
		end
		
		frame:OnUpdate_Update()
	end

	frame.UNIT_NAME_UPDATE = function(self, event, unit)		
		if self.unit ~= unit then return end

		self.leftText:SetText(UnitName(self.unit)) --AleaUI:utf8sub(UnitName(self.unit), 1, 12))
	end
	
	
	frame.OnUpdate_Update = function(self)	
		self:UNIT_NAME_UPDATE(nil, self.unit)
		self:UNIT_HEALTH(nil, self.unit)
	end
	
	frame:RegisterEvent("UNIT_NAME_UPDATE")
	frame:RegisterEvent("UNIT_HEALTH")

	frame:RegisterEvent("RAID_TARGET_UPDATE")	
	frame:RegisterEvent("PLAYER_TARGET_CHANGED")	

	handler.Deactivate = function(self, onupdate)	
	
--		print("Deactivate", self.art.unit)
	
		self.art:UnregisterAllEvents()		
		UnregisterUnitWatch(self)
		self:Hide()
		
	--	_frames[self.art] = nil
		if onupdate then UF:AddOnUpdateUnevent(self.art) end
	end
	
	handler.Reactivate = function(self, unit, onupdate)	
	
		self.art.unit = unit
	
		self.art:RegisterEvent("UNIT_NAME_UPDATE")
		self.art:RegisterEvent("UNIT_HEALTH")
		self.art:RegisterEvent("RAID_TARGET_UPDATE")	
		self.art:RegisterEvent("PLAYER_TARGET_CHANGED")	
		
		UnregisterUnitWatch(self)		
		self:SetAttribute("unit", unit)
		
		self.art:OnUpdate_Update()
		
		RegisterUnitWatch(self)
		
	--	_frames[self.art] = true
		if onupdate then UF:AddOnUpdateEvent(self.art) end
	end
	
	return handler
end


local function UpdateForcedTanks()
	wipe(force_name)
	
	if not enabled then return end
	
	if E.db.Frames.tankMoverFrame.mytanks then
		for v in gmatch(E.db.Frames.tankMoverFrame.mytanks, "[^ :\"-]+") do
			force_name[v] = true
			
	--		print("T >"..v.."<")
		end
	end
	TF:GROUP_ROSTER_UPDATE(event, "forced")
end

function E:DisableTanksFrames()
	enabled = false
	
	TF:UnregisterEvent("GROUP_ROSTER_UPDATE")
	TF:UnregisterEvent("PLAYER_ENTERING_WORLD")
	TF:UnregisterEvent("PLAYER_ENTERING_BATTLEGROUND")
	TF:UnregisterEvent("GROUP_JOINED")
	TF:UnregisterEvent("GROUP_LEFT")
	TF:UnregisterEvent("RAID_INSTANCE_WELCOME")
	TF:UnregisterEvent("ZONE_CHANGED_NEW_AREA")	
	TF:UnregisterEvent("UNIT_NAME_UPDATE")
	TF:UnregisterEvent("INSPECT_READY")
	TF:UnregisterEvent("PLAYER_REGEN_ENABLED")
	TF:UnregisterEvent("ROLE_CHANGED_INFORM")
	TF:UnregisterEvent("PLAYER_ROLES_ASSIGNED")
	TF:UnregisterEvent("PLAYER_REGEN_DISABLED")

	for i=1, #tanks do
		tanks[i].t:Deactivate()
		tanks[i].tt:Deactivate(true)
		tanks[i].ttt:Deactivate(true)
	end
end

function E:EnableTanksFrames()
	enabled = true
	
	TF:RegisterEvent("GROUP_ROSTER_UPDATE")
	TF:RegisterEvent("PLAYER_ENTERING_WORLD")
	TF:RegisterEvent("PLAYER_ENTERING_BATTLEGROUND")
	TF:RegisterEvent("GROUP_JOINED")
	TF:RegisterEvent("GROUP_LEFT")
	TF:RegisterEvent("RAID_INSTANCE_WELCOME")
	TF:RegisterEvent("ZONE_CHANGED_NEW_AREA")	
	TF:RegisterEvent("UNIT_NAME_UPDATE")
	TF:RegisterEvent("INSPECT_READY")
	TF:RegisterEvent("PLAYER_REGEN_ENABLED")
	TF:RegisterEvent("ROLE_CHANGED_INFORM")
	TF:RegisterEvent("PLAYER_ROLES_ASSIGNED")
	TF:RegisterEvent("PLAYER_REGEN_DISABLED")
	
	TF:GROUP_ROSTER_UPDATE(event, "forced")
end

local function InitTankFrames()
	E:Mover(mover, "tankMoverFrame")

	E.GUI.args.unitframes.args.tanksFrames = {
		name = E.L['Tanks'],
		order = 1,
		expand = true,
		type = "group",
		args = {}
	}

	E.GUI.args.unitframes.args.tanksFrames.args.Enable = {
		name = E.L['Enable'],
		order = 1,
		type = "toggle", width = 'full',
		set = function(self, value)		
			E.db.Frames.tankMoverFrame.enabled = not E.db.Frames.tankMoverFrame.enabled
			
			if E.db.Frames.tankMoverFrame.enabled then
				E:EnableTanksFrames()
			else
				E:DisableTanksFrames()
			end
		end,
		get = function(self)
			return E.db.Frames.tankMoverFrame.enabled
		end
	}
	
	E.GUI.args.unitframes.args.tanksFrames.args.unlock = {
		name = E.L['Unlock'],
		order = 2,
		type = "execute",
		set = function(self, value)	E:UnlockMover("tankMoverFrame") end,
		get = function(self)end
	}
	
	E.GUI.args.unitframes.args.tanksFrames.args.update = {
		name = E.L['Refresh'],
		order = 2,
		type = "execute",
		set = function(self, value)	UpdateForcedTanks() end,
		get = function(self)end
	}
	
	E.GUI.args.unitframes.args.tanksFrames.args.TankList = {
		name = E.L['Tanks'],
		order = 3, width = "full",
		type = "editbox",
		set = function(self, value)			
			E.db.Frames.tankMoverFrame.mytanks = value
			UpdateForcedTanks()
		end,
		get = function(self) 
			return E.db.Frames.tankMoverFrame.mytanks  or ''
		end
	}
	if E.db.Frames.tankMoverFrame.enabled then
		E:EnableTanksFrames()
	else
		E:DisableTanksFrames()
	end
	UpdateForcedTanks()
end

function TF:CreateTankFrames(unit, index)
	
--	print("CreateTankFrames", unit, index)
	
	if not tanks[index] then
		tanks[index] = {}
		
		tanks[index].t = self:CreateTankFrame(mover, unit)
		tanks[index].t.index = index
		tanks[index].t.art:OnUpdate_Update()
		tanks[index].t:SetPoint("BOTTOMLEFT", mover, "BOTTOMLEFT", 0 , ( index - 1)*25)
		
		tanks[index].tt = self:CreateTankFrame(mover, unit.."target", true)
		tanks[index].tt.index = index
		tanks[index].tt.art:OnUpdate_Update()
		tanks[index].tt:SetPoint("LEFT", tanks[index].t, "RIGHT", 5 , 0)
		
		tanks[index].ttt = self:CreateTankFrame(mover, unit.."targettarget", true)
		tanks[index].ttt.index = index
		tanks[index].ttt.art:OnUpdate_Update()
		tanks[index].ttt:SetPoint("LEFT", tanks[index].tt, "RIGHT", 5 , 0)

	end
	
	tanks[index].t:Reactivate(unit)
	tanks[index].tt:Reactivate(unit.."target", true)
	tanks[index].ttt:Reactivate(unit.."targettarget", true)
	
	
	for i=index+1, #tanks do
		tanks[i].t:Deactivate()
		tanks[i].tt:Deactivate(true)
		tanks[i].ttt:Deactivate(true)
	end
end


AleaUI_TEST2_TEST = function()


	TF:CreateTankFrames("player", 1)
	TF:CreateTankFrames("player", 2)
	TF:CreateTankFrames("player", 3)
end

E:OnInit2(InitTankFrames)