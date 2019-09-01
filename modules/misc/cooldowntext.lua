local addonName, E = ...
local L = E.L

local CT = E:Module("Cooldown")
local UF = E:Module("UnitFrames")

local ICON_SIZE = 36 --the normal size for an icon (don't change this)
local FONT_SIZE = 18 --the base font size to use at a scale of 1
local MIN_SCALE = 0.3 --the minimum scale we want to show cooldown counts at, anything below this will be hidden
local MIN_DURATION = 1.6 --the minimum duration to show cooldown text for

local floor = math.floor
local min = math.min
local GetTime = GetTime

local threshold = 3

local TimeColors = {
	[0] = '|cfffefefe',
	[1] = '|cfffefefe',
	[2] = '|cfffefefe',
	[3] = '|cfffefefe',
	[4] = '|cfffe0000',
	[5] = '|cffff4c4c',
	[6] = '|cffff9999',
}

E.TimeFormats = {
	[0] = { '%.0f'..L['DAY_FORMAT_TIME'], '%.0f'..L['DAY_FORMAT_TIME'], '%.0f'..L['DAY_FORMAT_TIME'] },
	[1] = { '%.0f'..L['HOUR_FORMAT_TIME'], '%.0f'..L['HOUR_FORMAT_TIME'], '%.0f'..L['HOUR_FORMAT_TIME'] },
	[2] = { '%.0f'..L['MINUTE_FORMAT_TIME'], '%.0f'..L['MINUTE_FORMAT_TIME'], '%.0f'..L['MINUTE_FORMAT_TIME'] },
	[3] = { '%.0f'..L['SECONDS_FORMAT_TIME'], '%.0f', '%.0f' },
	[4] = { '%.1f'..L['SECONDS_FORMAT_TIME'], '%.1f', '%d' },
	[5] = { '%.1f'..L['SECONDS_FORMAT_TIME'], '%.1f', '%d' },
	[6] = { '%.1f'..L['SECONDS_FORMAT_TIME'], '%.1f', '%d' },
}

local defaults = {
	
	time_format = 1,
	
	show_millisec = true,
	
	point = 'TOPLEFT',
	offsetX = -1,
	offsetY = -1,
	
	font = E.media.default_font_name,
	fontSize = 18,
	fontOutline = 'OUTLINE',	
}

E.default_settings.cooldown = defaults

local JustifyByPoint = {
	['TOPLEFT'] = { 'LEFT', 'TOP' },
	['TOPRIGHT'] = { 'RIGHT', 'TOP' },
	['BOTTOMRIGHT'] = { 'RIGHT', 'BOTTOM' },
	['BOTTOMLEFT'] = { 'LEFT', 'BOTTOM' },
	['CENTER'] = { 'CENTER', 'CENTER' },
	['BOTTOM'] = { 'CENTER', 'BOTTOM' },
	['TOP'] = { 'CENTER', 'TOP' },
}

		
local fullCooldownList = {}

local DAY, HOUR, MINUTE = 86400, 3600, 60 --used for calculating aura time text
local DAYISH, HOURISH, MINUTEISH = HOUR * 23.5, MINUTE * 59.5, 59.5 --used for caclculating aura time at transition points
local HALFDAYISH, HALFHOURISH, HALFMINUTEISH = DAY/2 + 0.5, HOUR/2 + 0.5, MINUTE/2 + 0.5 --used for calculating next update times

-- will return the the value to display, the formatter id to use and calculates the next update for the Aura
function E:GetTimeInfo(s, threshhold)
	if s < MINUTE then
		if s >= threshhold then
			return ceil(s), 3, 0.51
		else
			if E.db.cooldown.show_millisec then
				if s >= 2 then
					return s, 6, 0.051
				elseif s >= 1 then
					return s, 5, 0.051
				else
					return s, 4, 0.051
				end
			else
				if s >= 2 then
					return ceil(s), 6, 0.51
				elseif s >= 1 then
					return ceil(s), 5, 0.51
				else
					return ceil(s), 4, 0.051
				end
			end
		end
	elseif s < HOUR then
		local minutes = floor((s/MINUTE)+.5)
		return ceil(s / MINUTE), 2, minutes > 1 and (s - (minutes*MINUTE - HALFMINUTEISH)) or (s - MINUTEISH)
	elseif s < DAY then
		local hours = floor((s/HOUR)+.5)
		return ceil(s / HOUR), 1, hours > 1 and (s - (hours*HOUR - HALFHOURISH)) or (s - HOURISH)
	else
		local days = floor((s/DAY)+.5)
		return ceil(s / DAY), 0,  days > 1 and (s - (days*DAY - HALFDAYISH)) or (s - DAYISH)
	end
end

local function Cooldown_OnUpdate(cd, elapsed)
	if cd.nextUpdate > 0 then
		cd.nextUpdate = cd.nextUpdate - elapsed
		return
	end

	local remain = cd.duration - (GetTime() - cd.start)

	if remain > 0.05 then
		if (cd.fontScale * cd:GetEffectiveScale() / E.UIParent:GetScale()) < MIN_SCALE then
			cd.text:SetText('')
			cd.nextUpdate = 500
		else
			local timervalue, formatid
			timervalue, formatid, cd.nextUpdate = E:GetTimeInfo(remain, threshold)		
			cd.text:SetFormattedText(("%s%s|r"):format(TimeColors[formatid], E.TimeFormats[formatid][E.db.cooldown.show_millisec and 2 or 3]), timervalue)
		end
	else
		CT:Cooldown_StopTimer(cd)
	end
end

function CT:Cooldown_OnSizeChanged(cd, width, height)
	local fontScale = floor(width +.5) / ICON_SIZE
	local override = cd:GetParent().SizeOverride
	if override then 
		fontScale = override
	end
	
	if fontScale > 1 then
		fontScale = 1
	end
	
	if fontScale == cd.fontScale then
		return
	end
	
	cd.fontScale = fontScale
	if fontScale < MIN_SCALE and not override then
		cd:Hide()
	else

		cd:Show()
		cd.text:SetFont(E:GetFont(E.db.cooldown.font), fontScale * E.db.cooldown.fontSize, E.db.cooldown.fontOutline)
	
		if cd.enabled then
			self:Cooldown_ForceUpdate(cd)
		end
	end
end

function CT:Cooldown_ForceUpdate(cd)
	cd.nextUpdate = 0
	cd:Show()
end

function CT:Cooldown_StopTimer(cd)
	cd.enabled = nil
	cd:Hide()
end

function CT:CreateCooldownTimer(parent)
	local timer = CreateFrame('Frame', nil, parent); timer:Hide()
	timer:SetAllPoints()
	timer:SetScript('OnUpdate', Cooldown_OnUpdate)
	--[==[
	timer:SetFrameStrata('TOOLTIP')
	timer.bg = timer:CreateTexture(nil, 'OVERLAY')
	timer.bg:SetAllPoints()
	timer.bg:SetColorTexture(1, 0, 0, 0.4)
	]==]
	
	local text = timer:CreateFontString(nil, 'OVERLAY')
	text:SetSize(50, 50)
	text:SetPoint(E.db.cooldown.point, timer, E.db.cooldown.point, E.db.cooldown.offsetX, E.db.cooldown.offsetY)
	text:SetJustifyH(JustifyByPoint[E.db.cooldown.point][1])
	text:SetJustifyV(JustifyByPoint[E.db.cooldown.point][2])
	
	timer.text = text

	self:Cooldown_OnSizeChanged(timer, parent:GetSize())
	parent:HookScript('OnSizeChanged', function(_, ...) 
		self:Cooldown_OnSizeChanged(timer, ...) 
	end)

	parent.timer = timer
	
	fullCooldownList[parent] = true
	
	return timer
end

local function GetGCD()
	local startTime, duration = GetSpellCooldown(E.isClassic and 29515 or 61304);
	
	return duration or 0
end

local function IsGCDCooldown(start, duration)
	local startTime, durationTime = GetSpellCooldown(E.isClassic and 29515 or 61304);
	return ( startTime == start and durationTime == duration )
end
  
function CT:OnSetCooldown(start, duration)
	local button = self:GetParent()
	if self.noCooldownCount then return end

	if start > 0 and ( self.noMinDurationCheck or not IsGCDCooldown(start, duration) ) and ( self.currentCooldownType ~= COOLDOWN_TYPE_LOSS_OF_CONTROL ) then
		local timer = self.timer or CT:CreateCooldownTimer(self)
		timer.start = start
		timer.duration = duration
		timer.enabled = true
		timer.nextUpdate = 0
		if timer.fontScale >= MIN_SCALE then timer:Show() end
	else
		local timer = self.timer
		if timer then
			CT:Cooldown_StopTimer(timer)
		end
	end
end

local function DisableDrawBling(self, arg)
	if arg ~= false then
		self:SetDrawBling(false)
	end
end

function E:RegisterCooldown(cooldown)
	if(cooldown.isHooked) then return end

	hooksecurefunc(cooldown, "SetCooldown", CT.OnSetCooldown)
	cooldown.isHooked = true
	cooldown:SetHideCountdownNumbers(true)
	cooldown:SetDrawBling(false)	
	hooksecurefunc(cooldown, "SetDrawBling", DisableDrawBling)
end

function CT:UpdateSettings()
	
	for cooldown in pairs(fullCooldownList) do
		if cooldown.timer then
			
			cooldown.timer.fontScale = nil
			CT:Cooldown_OnSizeChanged(cooldown.timer, cooldown:GetSize())
			
			cooldown.timer.text:ClearAllPoints()
			cooldown.timer.text:SetPoint(E.db.cooldown.point, cooldown.timer, E.db.cooldown.point, E.db.cooldown.offsetX, E.db.cooldown.offsetY)
			cooldown.timer.text:SetJustifyH(JustifyByPoint[E.db.cooldown.point][1])
			cooldown.timer.text:SetJustifyV(JustifyByPoint[E.db.cooldown.point][2])
	
		end
	end
	
end

E.GUI.args.Cooldown = {
	name = L['Cooldown text'],
	type = "group",
	order = 5,
	args = {},
}

E.GUI.args.Cooldown.args.ShowMillisec = {
	name = L['Show milliseconds'],
	type = 'toggle',
	order = 1,
	set = function()
		E.db.cooldown.show_millisec = not E.db.cooldown.show_millisec
		CT:UpdateSettings()
	end,
	get = function()
		return E.db.cooldown.show_millisec
	end,	
}

E.GUI.args.Cooldown.args.fontTemplate = {
	name = L['Font style'],
	type = "group",
	order = 5,
	embend = true,
	args = {},
}
E.GUI.args.Cooldown.args.fontTemplate.args.font = {	
	name = L["Font"],
	order = 6,
	type = "font",
	values = E.GetFontList,
	set = function(self, value)
		E.db.cooldown.font = value
		CT:UpdateSettings()
	end,
	get = function(self)
		return E.db.cooldown.font
	end,
}
E.GUI.args.Cooldown.args.fontTemplate.args.fontOutline = {	
	name = L["Outline"],
	order = 7,
	type = "dropdown",
	values = {			
		["NONE"] = NO,
		["OUTLINE"] = "OUTLINE",
	},
	set = function(self, value)
		E.db.cooldown.fontOutline = value
		CT:UpdateSettings()
	end,
	get = function(self)
		return E.db.cooldown.fontOutline
	end,
}
E.GUI.args.Cooldown.args.fontTemplate.args.fontSize = {	
	name = L["Size"],
	order = 8,
	type = "slider",
	min = 1, max = 32, step = 1,
	set = function(self, value)
		E.db.cooldown.fontSize = value
		CT:UpdateSettings()
	end,
	get = function(self)
		return E.db.cooldown.fontSize
	end,
}

E.GUI.args.Cooldown.args.fontPoint = {
	name = L["Point"],
	type = "group",
	order = 4,
	embend = true,
	args = {},
}

E.GUI.args.Cooldown.args.fontPoint.args.xOffset = {
	name = L['Horizontal offset'],
	order = 3,
	type = 'slider',
	min = -50, max = 50, step = 1,
	set = function(info, value)
		E.db.cooldown.offsetX = value
		CT:UpdateSettings()
	end,
	get = function(info)
		return E.db.cooldown.offsetX
	end,
}
E.GUI.args.Cooldown.args.fontPoint.args.yOffset = {
	name = L['Vertical offset'],
	order = 4,
	type = 'slider',
	min = -50, max = 50, step = 1,
	set = function(info, value)
		E.db.cooldown.offsetY = value
		CT:UpdateSettings()
	end,
	get = function(info)
		return E.db.cooldown.offsetY
	end,
}		
E.GUI.args.Cooldown.args.fontPoint.args.point = {
	name = L['Attach point'],
	order = 5,
	type = 'dropdown',
	values = {
		['TOPLEFT'] = 'TOPLEFT',
		['TOPRIGHT'] = 'TOPRIGHT',
		['BOTTOMRIGHT'] = 'BOTTOMRIGHT',
		['BOTTOMLEFT'] = 'BOTTOMLEFT',
		['CENTER'] = 'CENTER',
		['BOTTOM'] = 'BOTTOM',
		['TOP'] = 'TOP',
	},
	set = function(info, value)
		E.db.cooldown.point = value
		CT:UpdateSettings()
	end,
	get = function(info)
		return E.db.cooldown.point
	end,
}
