local DT = AleaUI:Module('DataText')
local L = AleaUI.L


local displayNumberString = " %s: |cFFFFFFFF%s|r "
local lastPanel;
local join = string.join
local timer = 0
local startTime = 0
local timerText = L["Combat"]

local floor = math.floor
local function OnUpdate(self)
	timer = GetTime() - startTime

	self.text:SetFormattedText(displayNumberString, timerText, format("%02d:%02d:%02d", floor(timer/60), timer % 60, (timer - floor(timer)) * 100))
end

local function DelayOnUpdate(self, elapsed)
	startTime = startTime - elapsed

	if(startTime <= 0) then
		startTime = GetTime()
		timer = 0
		self:SetScript("OnUpdate", OnUpdate)
	end
end

local function OnEvent(self, event, timerType, timeSeconds, totalTime)
	local inInstance, instanceType = IsInInstance()
	self.text:SetFormattedText(displayNumberString, timerText, "00:00:00")
	
	if(event == "START_TIMER" and instanceType == "arena") then
		startTime = timeSeconds
		timer = 0
		timerText = L["Arena"]
		self.text:SetFormattedText(displayNumberString, timerText, "00:00:00")
		self:SetScript("OnUpdate", DelayOnUpdate)
	elseif(event == "PLAYER_ENTERING_WORLD" or (event == "PLAYER_REGEN_ENABLED" and instanceType ~= "arena")) then
		self:SetScript("OnUpdate", nil)
	elseif(event == "PLAYER_REGEN_DISABLED" and instanceType ~= "arena") then
		startTime = GetTime()
		timer = 0
		timerText = L["Combat"]
		self:SetScript("OnUpdate", OnUpdate)
	elseif(not self.text:GetText()) then
		self.text:SetFormattedText(displayNumberString, timerText, format("%02d:%02d:%02d", floor(timer/60), timer % 60, (timer - floor(timer)) * 100))
	end
end


DT:RegisterDatatext('Combat/Arena Time', {"START_TIMER", "PLAYER_ENTERING_WORLD", "PLAYER_REGEN_DISABLED", "PLAYER_REGEN_ENABLED"}, OnEvent)