local DT = AleaUI:Module('DataText')
local L = AleaUI.L

local int = 3

local format = string.format
local join = string.join
local floor = math.floor
local wipe = table.wipe

local PendingInvites = false
local LastPendingInvites = nil

local APM = { TIMEMANAGER_PM, TIMEMANAGER_AM }
local europeDisplayFormat = '';
local ukDisplayFormat = '';
local europeDisplayFormat_nocolor = join("", "%02d", ":|r%02d")
local ukDisplayFormat_nocolor = join("", "", "%d", ":|r%02d", " %s|r")
local timerLongFormat = "%d:%02d:%02d"
local timerShortFormat = "%d:%02d"
local lockoutInfoFormat = "%s |cffaaaaaa(%s, %s/%s)"
local lockoutInfoFormatNoEnc = "%s |cffaaaaaa(%s)"
local formatBattleGroundInfo = "%s: "
local lockoutColorExtended, lockoutColorNormal = { r=0.3,g=1,b=0.3 }, { r=.8,g=.8,b=.8 }
local lockoutFormatString = { "%dd %02dh %02dm", "%dd %dh %02dm", "%02dh %02dm", "%dh %02dm", "%dh %02dm", "%dm" }
local curHr, curMin, curAmPm
local enteredFrame = false;

local Update, lastPanel; -- UpValue
local localizedName, isActive, canQueue, startTime, canEnter, _
local name, instanceID, reset, difficultyId, locked, extended, isRaid, maxPlayers, difficulty, numEncounters, encounterProgress

local function ValueColorUpdate(hex, r, g, b)
	europeDisplayFormat = join("", "%02d", hex, ":|r%02d")
	ukDisplayFormat = join("", "", "%d", hex, ":|r%02d", hex, " %s|r")
	
	if lastPanel ~= nil then
		Update(lastPanel, 20000)
	end
end

ValueColorUpdate("|cFFFFFFFF")

local time24 = true
local function ConvertTime(h, m)
	local AmPm
	if time24 == true then
		return h, m, -1
	else
		if h >= 12 then
			if h > 12 then h = h - 12 end
			AmPm = 1
		else
			if h == 0 then h = 12 end
			AmPm = 2
		end
	end
	return h, m, AmPm
end

local localtime = true
local function CalculateTimeValues(tooltip)
	if (tooltip and localtime) or (not tooltip and not localtime) then
		return ConvertTime(GetGameTime())
	else
		local	dateTable =	date("*t")
		return ConvertTime(dateTable["hour"], dateTable["min"])
	end
end

local function Click(self)
	GameTimeFrame:Click();
	self.glow:EndGlowing()
end

local function OnLeave(self)
	DT.tooltip:Hide();
	enteredFrame = false;
end

local function OnEvent(self, event)
	if event == "UPDATE_INSTANCE_INFO" and enteredFrame then
		RequestRaidInfo()
	end	
	if event == 'PLAYER_ENTERING_WORLD' or event == 'CALENDAR_UPDATE_PENDING_INVITES' then
		PendingInvites = ( C_Calendar.GetNumPendingInvites() > 0 ) or false	
		
		if PendingInvites then
			self.glow:SetVertexColor(1, 1, 0)
			self.glow:StartGlowing()
		else
			self.glow:EndGlowing()
		end	
	end
	
	if event == 'PLAYER_ENTERING_WORLD' then
		int = -1
		curHr = nil
		curMin = nil
		curAmPm = nil
		
	end
end

local function OnEnter(self)
	DT:SetupTooltip(self)

	if(not enteredFrame) then
		enteredFrame = true;
		RequestRaidInfo()
	end

	DT.tooltip:AddLine(VOICE_CHAT_BATTLEGROUND);
	for i = 1, GetNumWorldPVPAreas() do
		_, localizedName, isActive, canQueue, startTime, canEnter = GetWorldPVPAreaInfo(i)
		if canEnter then
			if isActive then
				startTime = WINTERGRASP_IN_PROGRESS
			elseif startTime == nil then
				startTime = QUEUE_TIME_UNAVAILABLE
			else
				startTime = SecondsToTime(startTime, false, nil, 3)
			end
			DT.tooltip:AddDoubleLine(format(formatBattleGroundInfo, localizedName), startTime, 1, 1, 1, lockoutColorNormal.r, lockoutColorNormal.g, lockoutColorNormal.b)	
		end
	end	

	local oneraid, lockoutColor
	local oneinstance
	for i = 1, GetNumSavedInstances() do
		name, _, reset, difficultyId, locked, extended, _, isRaid, maxPlayers, difficulty, numEncounters, encounterProgress  = GetSavedInstanceInfo(i)
		if isRaid and (locked or extended) and name then
			if not oneraid then
				DT.tooltip:AddLine(" ")
				DT.tooltip:AddLine(L["Saved Raid(s)"])
				oneraid = true
			end
			if extended then 
				lockoutColor = lockoutColorExtended 
			else 
				lockoutColor = lockoutColorNormal 
			end
			
			if (numEncounters and numEncounters > 0) and (encounterProgress and encounterProgress > 0) then
				DT.tooltip:AddDoubleLine(format(lockoutInfoFormat, GetDifficultyInfo(difficultyId), name, encounterProgress, numEncounters), SecondsToTime(reset, false, nil, 3), 1, 1, 1, lockoutColor.r, lockoutColor.g, lockoutColor.b)
			else
				DT.tooltip:AddDoubleLine(format(lockoutInfoFormatNoEnc, GetDifficultyInfo(difficultyId), name), SecondsToTime(reset, false, nil, 3), 1, 1, 1, lockoutColor.r, lockoutColor.g, lockoutColor.b)
			end			
		end
	end	
	
	for i=1, GetNumSavedInstances() do
		name, _, reset, difficultyId, locked, extended, _, isRaid, maxPlayers, difficulty, numEncounters, encounterProgress  = GetSavedInstanceInfo(i)
		
		if not isRaid and (locked or extended) and name then
			if not oneinstance then
				DT.tooltip:AddLine(" ")
				DT.tooltip:AddLine(L["Saved Instance(s)"])
				oneinstance = true
			end
			if extended then 
				lockoutColor = lockoutColorExtended 
			else 
				lockoutColor = lockoutColorNormal 
			end
			
			if (numEncounters and numEncounters > 0) and (encounterProgress and encounterProgress > 0) then
				DT.tooltip:AddDoubleLine(format(lockoutInfoFormat, GetDifficultyInfo(difficultyId), name, encounterProgress, numEncounters), SecondsToTime(reset, false, nil, 3), 1, 1, 1, lockoutColor.r, lockoutColor.g, lockoutColor.b)
			else
				DT.tooltip:AddDoubleLine(format(lockoutInfoFormatNoEnc, GetDifficultyInfo(difficultyId), name), SecondsToTime(reset, false, nil, 3), 1, 1, 1, lockoutColor.r, lockoutColor.g, lockoutColor.b)
			end	
		end
	end
	
	local addedLine = false
	for i = 1, GetNumSavedWorldBosses() do
		name, instanceID, reset = GetSavedWorldBossInfo(i)
		if(reset) then
			if(not addedLine) then
				DT.tooltip:AddLine(' ')
				DT.tooltip:AddLine(RAID_INFO_WORLD_BOSS.."(s)")
				addedLine = true
			end
			DT.tooltip:AddDoubleLine(name, SecondsToTime(reset, true, nil, 3), 1, 1, 1, 0.8, 0.8, 0.8)		
		end
	end
	
	local timeText
	local Hr, Min, AmPm = CalculateTimeValues(true)

	DT.tooltip:AddLine(" ")
	if AmPm == -1 then
		DT.tooltip:AddDoubleLine(localtime and TIMEMANAGER_TOOLTIP_REALMTIME or TIMEMANAGER_TOOLTIP_LOCALTIME, 
			format(europeDisplayFormat_nocolor, Hr, Min), 1, 1, 1, lockoutColorNormal.r, lockoutColorNormal.g, lockoutColorNormal.b)
	else
		DT.tooltip:AddDoubleLine(localtime and TIMEMANAGER_TOOLTIP_REALMTIME or TIMEMANAGER_TOOLTIP_LOCALTIME,
			format(ukDisplayFormat_nocolor, Hr, Min, APM[AmPm]), 1, 1, 1, lockoutColorNormal.r, lockoutColorNormal.g, lockoutColorNormal.b)
	end	
	
	DT.tooltip:Show()
end

function Update(self, t)
	int = int - t
		
	if int > 0 then 
		return 
	end

	if enteredFrame then
		OnEnter(self)
	end

	local Hr, Min, AmPm = CalculateTimeValues(false)

	-- no update quick exit
	if (Hr == curHr and Min == curMin and AmPm == curAmPm) and not (int < -15000) then
		int = 5
		return
	end
	
	curHr = Hr
	curMin = Min
	curAmPm = AmPm

	if AmPm == -1 then
		self.text:SetFormattedText(europeDisplayFormat, Hr, Min)
	else
		self.text:SetFormattedText(ukDisplayFormat, Hr, Min, APM[AmPm])
	end
	lastPanel = self
	int = 5
	
	
	if PendingInvites then
	
	else
	
	end
end

--[[
	DT:RegisterDatatext(name, events, eventFunc, updateFunc, clickFunc, onEnterFunc, onLeaveFunc)
	
	name - name of the datatext (required)
	events - must be a table with string values of event names to register 
	eventFunc - function that gets fired when an event gets triggered
	updateFunc - onUpdate script target function
	click - function to fire when clicking the datatext
	onEnterFunc - function to fire OnEnter
	onLeaveFunc - function to fire OnLeave, if not provided one will be set for you that hides the tooltip.
]]
DT:RegisterDatatext('Time', {"UPDATE_INSTANCE_INFO", 'CALENDAR_UPDATE_PENDING_INVITES', 'PLAYER_ENTERING_WORLD'}, OnEvent, Update, Click, OnEnter, OnLeave)