local E = AleaUI
local L = E.L

local CombatLogEvent = 'COMBAT_LOG_EVENT_UNFILTERED'

local core = CreateFrame("Frame")
core:SetScript("OnEvent", function(self, event, ...)	
	if event == CombatLogEvent then
		self[event](self, event, CombatLogGetCurrentEventInfo())
	else
		self[event](self, event, ...)
	end
end)

local myGUID = UnitGUID("player")
local twipe = table.wipe
local tinsert = table.insert
local tremove = table.remove

local SpiritLinkTotemID = 98021

local amountPoint = 0

local myParent = CreateFrame("Frame", nil, E.UIParent)
myParent:SetPoint("TOPLEFT", E.UIParent, "TOPLEFT", 0, 0)
myParent:SetPoint("BOTTOMRIGHT", E.UIParent, "BOTTOMRIGHT", 0, 0)
myParent:SetFrameStrata(E.UIParent:GetFrameStrata())
myParent:SetFrameLevel(0)

local band = bit.band
local gsub = string.gsub
local tolower = string.lower
local match = string.match
local random = fastrandom
local pairs = pairs
local ipairs = ipairs
local select = select

local travel_time = 7
local travel_width = 300

local width = 50
local init_step = 50

local GetTime = GetTime

local UNIT_HEALTH_EVENT = 'UNIT_HEALTH_FREQUENT'

if ( E.isShadowlands ) then 
	UNIT_HEALTH_EVENT = 'UNIT_HEALTH'
end

local SPELL_AURA_APPLIED_BUFF = "SPELL_AURA_APPLIED_BUFF"
local SPELL_AURA_APPLIED_DEBUFF = "SPELL_AURA_APPLIED_DEBUFF"
local SPELL_AURA_APPLIED_DOSE_BUFF = "SPELL_AURA_APPLIED_DOSE_BUFF"
local SPELL_AURA_APPLIED_DOSE_DEBUFF = "SPELL_AURA_APPLIED_DOSE_DEBUFF"

local Localiz = {
	["SPELL_HEAL"] = L["Heal"],
	["SPELL_PERIODIC_HEAL"] = L["HoTs"],
	["SPELL_DAMAGE"] = L['Spell damage'],
	["SPELL_PERIODIC_DAMAGE"] = L['DoTs'],
	["SPELL_AURA_APPLIED_DEBUFF"] = L['Debuff apply'],
	["SPELL_AURA_APPLIED_BUFF"] = L['Buff apply'],
	["SPELL_AURA_REFRESH_DEBUFF"] = L['Debuff refresh'],
	["SPELL_AURA_REFRESH_BUFF"] = L['Buff refresh'],
	["SPELL_AURA_APPLIED_DOSE_DEBUFF"] = L['Debuff stacks'],
	["SPELL_AURA_APPLIED_DOSE_BUFF"] = L['Buff stacks'],
	["SWING_DAMAGE"] = L['Melee damamge'],
	["RANGE_DAMAGE"] = L['Range damage'],
	["SPELL_ABSORBED"] = L['Absorb'],
}

local defaults = {

	enable = true,
	enable_damageDone = true,
	
	travel_time = 4,
	travel_width = 400,
	
	font = E.media.default_font_name,
	fontSize = 22,
	fontFlag = "OUTLINE",
	
	enabled = {	
		["SPELL_HEAL"] = true,
		["SPELL_PERIODIC_HEAL"] = true,
		["SPELL_DAMAGE"] = true,
		["SPELL_PERIODIC_DAMAGE"] = true,
		["SPELL_AURA_APPLIED_DEBUFF"] = true,
		["SPELL_AURA_APPLIED_BUFF"] = true,
		["SPELL_AURA_REFRESH_DEBUFF"] = true,
		["SPELL_AURA_REFRESH_BUFF"] = true,
		["SPELL_AURA_APPLIED_DOSE_DEBUFF"] = true,
		["SPELL_AURA_APPLIED_DOSE_BUFF"] = true,
		["SWING_DAMAGE"] = true,
		["RANGE_DAMAGE"] = true,
		["SPELL_ABSORBED"] = true,
		
	},
	
	colors = {
		["SPELL_HEAL"] = { 0, 1, 0, 1},
		["SPELL_PERIODIC_HEAL"] = { 0, 1, 0, 1},
		
		["SPELL_DAMAGE"] = { 1, 0, 0, 1},
		["SPELL_PERIODIC_DAMAGE"] = { 1, 0, 0, 1},
		
		["SPELL_AURA_APPLIED_DEBUFF"] = { 175/255, 78/255, 188/255, 1},
		["SPELL_AURA_APPLIED_BUFF"] = { 91/255, 188/255, 78/255, 1},
		
		["SPELL_AURA_REFRESH_DEBUFF"] = { 175/255, 78/255, 188/255, 1},
		["SPELL_AURA_REFRESH_BUFF"] = { 91/255, 188/255, 78/255, 1},
		
		["SPELL_AURA_APPLIED_DOSE_DEBUFF"] = { 175/255, 78/255, 188/255, 1},
		["SPELL_AURA_APPLIED_DOSE_BUFF"] = { 91/255, 188/255, 78/255, 1},
		
		["SWING_DAMAGE"] = { 255/255, 0/255, 0/255, 1},
		["RANGE_DAMAGE"] = { 255/255, 0/255, 0/255, 1},
		
		["SPELL_ABSORBED"] = { 255/255, 255/255, 0/255, 1},
	},
	
	filters = {
	
	}
}

E.default_settings.battletext = defaults

local function GetTextString(side)
	
	local point1, point2 = "LEFT", "RIGHT"
	local x, y = 2, 0
	
	if side then
		point1, point2 = "RIGHT", "LEFT"
		x, y = -2, 0
	end
	
	local f = CreateFrame("Frame", nil, myParent)
	f:SetFrameStrata("LOW")
	f:SetSize(15,15)
	
	local i = f:CreateTexture(nil, "ARTWORK")
	i:SetAllPoints()
	i:SetPoint("CENTER")
	i:SetColorTexture(1, 0, 1, 1)
	i:SetTexCoord(unpack(AleaUI.media.texCoord))

	local t = f:CreateFontString(nil, "ARTWORK")
	t:SetPoint(point1, i, point2, x, y)
	
	f.i = i
	f.t = t
	
	f.UpdateStyle = function(self)
		self.t:SetFont(E:GetFont(E.db.battletext.font), E.db.battletext.fontSize, E.db.battletext.fontFlag)
		self:SetSize(E.db.battletext.fontSize*0.6, E.db.battletext.fontSize*0.6)
	end

	f.side = side
	
	f.Reset = function(self, line)
		
		self.w = line*3
		self.elapsed = 0
		
		self:Show()
		self._progress = 1
		
		if self.side then
			self.current_step = -init_step
			self:SetPoint("CENTER", myParent, "CENTER", -init_step, self.w)
		else
			self.current_step = init_step
			self:SetPoint("CENTER", myParent, "CENTER", init_step, self.w)
		end
	end

	f.Move2 = function(self, speed)
	
		if self.side then
			self.current_step = self.current_step - speed
			self:SetPoint("CENTER", myParent, "CENTER", -init_step+self.current_step, self.w)				
			self._progress = 1 + ( self.current_step/travel_width)
		else
			self.current_step = self.current_step + speed		
			self:SetPoint("CENTER", myParent, "CENTER", init_step+self.current_step, self.w)		
			self._progress = 1 - ( self.current_step/travel_width)
		end
		
	end
	
	f.Alpha = function(self, value)
		
		value = 1-value
	
		self:SetAlpha(1*value)
	end
	
	return f
end

local UpdateBattleTextStyle

do	

	local leftside = {}
	local leftside_free = {}
	
	local rightside = {}
	local rightside_free = {}
	
	function UpdateBattleTextStyle()
		
		for i, frame in pairs(leftside) do		
			if frame then frame:UpdateStyle() end
		end
		
		for i, frame in pairs(leftside_free) do
			if frame then frame:UpdateStyle() end
		end
		
		for i, frame in pairs(rightside) do
			if frame then frame:UpdateStyle() end
		end
		
		for i, frame in pairs(rightside_free) do
			if frame then frame:UpdateStyle() end
		end
	end
	
	local function GetSide()
		return ( random(1,2) == 1 )
	end
	
	local ignore_line_1 = {}	
	local ignore_line_2 = {}
	local step1, step2 = -70, 70
	
	local warning1 = (step2+1)			-- 50% reached
	local warning2 = (step2*1.5)+1		-- 75% reached
	local warning3 = (step2*2)+1		-- 100% reached
	
	for i=step1, step2, 1 do
		ignore_line_1[i] = 0 --GetTime() + random(1,5)
		ignore_line_2[i] = 0 --GetTime() + random(1,5)
		
				
		leftside_free[#leftside_free+1] = GetTextString(true)
		rightside_free[#rightside_free+1] = GetTextString(false)
	end
	
	local function GetLine(size)
		local line
		local cur = GetTime()
		
		local trottle = size and ignore_line_1 or ignore_line_2
		
		local temperror = 0
		
		while (true) do
			line = random(step1,step2)
			temperror = temperror + 1
			
			
			if temperror == warning1 then
				print('T', 'AleaUI', 'BattleText', 'Warning1 reached - 50%')
			elseif temperror == warning2 then
				print('T', 'AleaUI', 'BattleText', 'Warning2 reached - 75%')
			elseif temperror == warning2 then
				print('T', 'AleaUI', 'BattleText', 'Warning3 reached - 100%')
			elseif temperror > warning1+warning1+warning1 then
				print('T', 'AleaUI', 'BattleText', 'Error reached at',temperror)		
				return nil
			end
	
			if trottle[line] < cur then
				trottle[line] = cur + 4		
				
				if trottle[line+1] then trottle[line+1] = cur + 3 end
				if trottle[line+2] then trottle[line+2] = cur + 2 end
				if trottle[line+3] then trottle[line+3] = cur + 1 end
				
				if trottle[line-1] then trottle[line-1] = cur + 3 end
				if trottle[line-2] then trottle[line-2] = cur + 2 end
				if trottle[line-3] then trottle[line-3] = cur + 1 end
				
				return line
			end
		end
	end
	
	local function OnUpdate(self, elapsed)
		
		local _i = 0
		
		local indexed = #leftside + #rightside
		local newtimer = travel_time-(travel_time-1)*indexed/(step2+step2)
		if newtimer > travel_time then newtimer = travel_time
		elseif newtimer < 1 then newtimer = 1 end		
		local speed = travel_width*elapsed/newtimer
	
		for i, frame in pairs(leftside) do
			frame:Move2(speed)
			frame:SetAlpha(frame._progress)
			
			if frame._progress <= 0 then
				frame:Hide()
				leftside_free[#leftside_free+1] = leftside[i]
				leftside[i] = nil				
			end			
			_i = _i + 1
		end
		

		for i, frame in pairs(rightside) do
			frame:Move2(speed)
			frame:SetAlpha(frame._progress)
			
			if frame._progress <= 0 then
				frame:Hide()
				rightside_free[#rightside_free+1] = rightside[i]
				rightside[i] = nil				
			end		
			_i = _i + 1
		end
		
		if _i == 0 then
			self:Hide()
		end
	end

	local animFrame = CreateFrame("Frame", "AleaUI-SBT_anitFrame")
	animFrame:Hide()
	animFrame:SetScript("OnUpdate", OnUpdate)

	function core:AddCombatText(event, spellid, damage, heal, absorb, crit, count, aura, amount)
		
		local name, _, icon = GetSpellInfo(spellid)
		
		local side  = GetSide()
		local from  = side and leftside_free or rightside_free
		local to	= side and leftside or rightside
		local f		= from[#from] or GetTextString(side)
		
		from[#from] = nil
			
			
		local text
		
		if event == "SPELL_ABSORBED" then
			if count > 1 then
				text = format(L['Absorb(%d) x%d'], absorb, count)
			else
				text = format(L['Absorb(%d)'], absorb)
			end
			
		elseif event == "SPELL_HEAL" or event == "SPELL_PERIODIC_HEAL" then			
			if count > 1 then		
				if absorb > 0 then					
					text = format("%d(%d) x%d", heal, absorb, count)
				else
					text = format("%d x%d", heal, count)
				end
			else
				if absorb > 0 then
					text = format("%d (%d)", heal, absorb)
				else
					text = format("%d", heal)
				end		
			end
		elseif event == "SWING_DAMAGE" or event == "RANGE_DAMAGE" or event == "SPELL_DAMAGE" or event == "SPELL_PERIODIC_DAMAGE" then
			if count > 1 then		
				if absorb > 0 then					
					text = format("%d(%d) x%d", damage, absorb, count)
				else
					text = format("%d x%d", damage, count)
				end
			else
				if absorb > 0 then
					text = format("%d (%d)", damage, absorb)
				else
					text = format("%d", damage)
				end		
			end
		elseif event == "SPELL_AURA_APPLIED_DEBUFF "or "SPELL_AURA_REFRESH_DEBUFF" or "SPELL_AURA_APPLIED_DOSE_DEBUFF" then
			if count > 1 then
				text = format("+%s(x%d)", name, count)
			elseif amount and amount > 0 then
				text = format("+%s(x%d)", name, amount)
			else
				text = format("+%s", name)
			end
		elseif event == "SPELL_AURA_APPLIED_BUFF" or "SPELL_AURA_REFRESH_BUFF" or "SPELL_AURA_APPLIED_DOSE_BUFF" then
			if count > 1 then
				text = format("+%s(x%d)", name, count)
			elseif amount and amount > 0 then
				text = format("+%s(x%d)", name, amount)
			else
				text = format("+%s", name)
			end
		end
		
		f:Reset(GetLine(side))
		f.i:SetTexture(icon)
		f.t:SetText(text or "")
		f.t:SetTextColor(E.db.battletext.colors[event][1], E.db.battletext.colors[event][2], E.db.battletext.colors[event][3])
	
		to[#to+1] = f
		
		OnUpdate(animFrame, 0)
		animFrame:Show()
	end
end

do
	local throttle_list = {}
	
	local throttle = 1.5
	local trottlemore = 0.2
	
	local function OnUpdate(self, elapsed)
		
		local _i = 0
		self.elapsed = ( self.elapsed or 0 ) + elapsed		
		if self.elapsed < 0.5 then return end
		self.elapsed = 0
		
		local curtime = GetTime()
		for event, data in pairs(throttle_list) do
			
			for spellid, data2 in pairs(data) do
				local data2 = data2
				if data2[8] and data2[8] < curtime and data2[5] > 0 then
					
					
					core:AddCombatText(event, spellid, data2[1], data2[2], data2[3], data2[4], data2[5], data2[6], data2[7])
					
			
					data2[1] = 0; 
					data2[2] = 0; 
					data2[8] = curtime+throttle;
					data2[3] = 0; 
					data2[4] = nil;
					data2[6] = nil;
					data2[5] = 0;
					data2[7] = nil; 

				else
					if data2[8] and data2[8] > curtime then
						_i = _i + 1						
					end
				end
			end
		end
		
		if _i == 0 then
			self:Hide()
			self.elapsed = 0
		end
	end
	
	local throttleFrame = CreateFrame("Frame", "AleaUI-SBT_throttleFrame")
	throttleFrame:Show()
	throttleFrame:SetScript("OnUpdate", OnUpdate)

		-- 1:damage = 0, 2:heal = 0, 3:absorb = 0, 4:crit = crit, 5:count = 0, 6:aura = aura, 7:amount = amount, 8:timer = 0, 9:event = event

	function core:DoThrottle(event, spellid, damage, heal, absorb, crit, aura, amount)
		if not throttle_list[event] then throttle_list[event] = {} end		
		if not throttle_list[event][spellid] then		
			throttle_list[event][spellid] = { 0, 0, 0, crit, 0, aura, amount, 0, event}
		end
		
		local curtime = GetTime()
		local data = throttle_list[event][spellid]
		
		if ( data[8] > curtime ) then
		
			if damage and damage > 0 then
				data[1] =  data[1] + damage
				data[5] =  data[5] + 1
			elseif heal and heal > 0 then
				data[2] =  data[2] + heal
				data[5] =  data[5] + 1
			end
			
			if absorb and absorb > 0 then
				data[3] =  data[3] + absorb			
			end
			
			if aura then
				data[5] =  data[5] + 1 + 1
				data[7] =  amount
			end
			
			data[6] = aura
			
			if not data[4] and crit then
				data[4] = crit
			end
			
			data[8] = data[8] + trottlemore
		
			throttleFrame:Show()
			
			return false
		else
			local damage1		= data[1] + ( damage and damage or 0 )
			local heal1 		= data[2] + ( heal and heal or 0 )
			local absorb1 		= data[3] + ( absorb and absorb or 0 )
			local count1 		= data[5] + ( (( damage and damage > 0 ) or ( heal and heal > 0 ) or ( absorb and absorb > 0 ) or aura) and 1 or 0)
			local aura1			= data[6] or aura
			local crit1			= data[4] or crit
			local amount1		= data[7] or amount
			
			data[1] = 0; 
			data[2] = 0; 
			data[3] = 0;
			data[5] = 0;
			data[4] = nil;
			data[6] = nil;
			data[7] = nil;
			
			data[8] = curtime+throttle;
			
			return event, spellid, damage1, heal1, absorb1, crit1, count1, aura1, amount1
		end
		
	end
	
end

local function GetSpellIDFilter(spellid, auraType)

	if auraType == "BUFF" then		
		if E.db.battletext.filters[spellid] and E.db.battletext.filters[spellid].type == auraType and E.db.battletext.filters[spellid].show then	
			return SPELL_AURA_APPLIED_DOSE_BUFF
		else
			return false
		end	
	elseif auraType == "DEBUFF" then
		if E.db.battletext.filters[spellid] and E.db.battletext.filters[spellid].type == auraType and not E.db.battletext.filters[spellid].show then	
			return false
		else
			return SPELL_AURA_APPLIED_DOSE_DEBUFF
		end	
	end

end

do
	
	local strings = {}
	local activeStrings = 0
	
	local stringParent = CreateFrame('Frame', nil, WorldFrame)
	stringParent:SetScale(1)
	stringParent:SetSize(1,1)
	stringParent:SetPoint("TOPLEFT", WorldFrame, 'TOPLEFT', 0, 0)
	
	local fade_time = 2
	local delayFaiding = 0.6
	local movingLong = 120
	
	local onUpdateFrame = CreateFrame('Frame')
	onUpdateFrame:Hide()
	local function OnUpdate(self, elapsed)
		local hide = true
		activeStrings = 0
		stringParent:Hide()
		for i=1, #strings do
			local f = strings[i]
			if not f.free then
		
				f.fading = f.fading - ( elapsed*delayFaiding )
				
				
				if f.fading > 0 then
					hide = false
					activeStrings = activeStrings + 1
					
					local alphaOffset = ( f.fading / .6 * 1 )
					
					f:SetAlpha( alphaOffset )
				else
					f.fading = 0
					f:SetAlpha( 0 )
					f.free = true
				end
				
				local xOffset = movingLong - ( f.fading / fade_time * movingLong )
				
				f:SetPoint('BOTTOMLEFT', WorldFrame, 'BOTTOMLEFT', f.xPos+xOffset, f.yPos)
			end
		end
		stringParent:Show()
		
		if hide then
			self:Hide()	
		end
	end
	
	onUpdateFrame:SetScript('OnUpdate', OnUpdate)
	
	local function GetString()
		for i=1, #strings do
			if strings[i].free then
				return strings[i]
			end
		end
		
		local f = CreateFrame('Frame', nil, stringParent)
		f:SetSize(14, 14)
		f.ID = #strings+1
		f.icon = f:CreateTexture()
		f.icon:SetAllPoints()
		f.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
		
		f.name = f:CreateFontString()
		f.name:SetFont(STANDARD_TEXT_FONT, 12, 'NONE')
		f.name:SetPoint('LEFT', f, 'RIGHT', 2, 0)
		f.name:SetWidth(170)
		f.name:SetShadowColor(0,0,0,1)
		f.name:SetShadowOffset(1,-1)
	
		strings[f.ID] = f
		
		return f
	end
	
	local counter = 0
	
	function core:AddDamageText(spellID, amount, critical)
		local xPos, yPos = 700, 500
		
		
		if false and E.TargetNamePlateFrame and E.TargetNamePlateFrame:IsVisible() then
			xPos, yPos = E.TargetNamePlateFrame:GetCenter()
		--[==[
			local x1, y1 = E.TargetNamePlateFrame:GetCenter()
			local x2, y2 = UIParent:GetCenter()	
			
			print('T', 'TargetNamePlateFrame', 'x1=',x1, 'y1=',y1, 'scale=',E.TargetNamePlateFrame:GetParent():GetEffectiveScale())
			print('T', 'UIParent', 'x2=',x2, 'y2=', y2, 'scale=',UIParent:GetEffectiveScale())
			
			local esc = E.TargetNamePlateFrame:GetParent():GetEffectiveScale()/UIParent:GetEffectiveScale()
			
			x1 = x1*esc
			y1 = y1*esc
	
			xPos = x2 - x1
			yPos = y2 - y1
		]==]
		end
		
	--	print('T', xPos, yPos)
		
		local string_f = GetString()
		string_f.free = false
		
		string_f.icon:SetTexture(GetSpellTexture(spellID))
		string_f.name:SetText(( critical and '|cFFFF0000!' or '|cFFFFFF00')..amount)
		
		string_f.alpha = 1
		string_f.fading = fade_time
		
		if counter > 5 then
			counter = 0
		end
		counter = counter + 1
		
		local step = string_f.ID%5
		string_f.yPos = yPos - 20 - ( step*14 )
		
		local xPosOffset = 0
		if activeStrings > 7 then
			xPosOffset = -40
		elseif activeStrings > 3 then
			xPosOffset = -20
		end
		
		string_f.xPos = xPos + xPosOffset
		string_f:SetPoint('BOTTOMLEFT', WorldFrame, 'BOTTOMLEFT', string_f.xPos, string_f.yPos)
		
		
--		print('T', counter, step, activeStrings)
		
		OnUpdate(onUpdateFrame, 0)
		onUpdateFrame:Show()
	end
end

function core:COMBAT_LOG_EVENT_UNFILTERED(event, ...)
	local timestamp,eventtype,hideCaster,sourceGUID,sourceName,sourceFlags,sourceFlags2,
	destGUID,destName,destFlags,destFlags2,spellid,spellName,spellSchool = ...
	
	if not myGUID then myGUID = UnitGUID("player") end

	if false and sourceGUID == myGUID and destGUID == UnitGUID('target') then	-- E.db.battletext.enable_damageDone
		if eventtype == "SPELL_DAMAGE" or eventtype == "SPELL_PERIODIC_DAMAGE" then	
			local amount,overkill,school,resisted,blocked,absorbed,critical,glancing,crushing,isOffHand,multistrike = select(15, ...)
			if multistrike then return end
			
			core:AddDamageText(spellid, amount, critical)		
		elseif eventtype == "SWING_DAMAGE" then	
			local amount,overkill,school,resisted,blocked,absorbed,critical,glancing,crushing,isOffHand,multistrike = select(12, ...)		
			if multistrike then return end
			
			core:AddDamageText(88163, amount, critical)	
		elseif eventtype == "RANGE_DAMAGE" then
			local amount,overkill,school,resisted,blocked,absorbed,critical,glancing,crushing,isOffHand,multistrike = select(15, ...)
			if multistrike then return end
			
			core:AddDamageText(88163, amount, critical)	
		end		
	end
	
	if not E.db.battletext.enable then return end
	if destGUID ~= myGUID then return end
		
	if eventtype == "SPELL_DAMAGE" or eventtype == "SPELL_PERIODIC_DAMAGE" then		
		if not E.db.battletext.enabled[eventtype] then return end
		
		local amount,overkill,school,resisted,blocked,absorbed,critical,glancing,crushing,multistrike = select(15, ...)
		local event1,spellid1,damage1,heal1,absorb1,crit1,count1,aura1 = self:DoThrottle(eventtype, spellid, amount, 0, absorbed, critical, nil)
		
		if spellid == SpiritLinkTotemID then return end
		
		if event1 then		
			self:AddCombatText(event1,spellid1,damage1,heal1,absorb1,crit1,count1,aura1)
		end
	elseif eventtype == "SPELL_HEAL" or eventtype == "SPELL_PERIODIC_HEAL" then
		if not E.db.battletext.enabled[eventtype] then return end
		
		local amount, overhealing, absorbed, critical = select(15, ...)
		
		if spellid == SpiritLinkTotemID then return end
		if amount < amountPoint then return end
		
		local event1,spellid1,damage1,heal1,absorb1,crit1,count1,aura1 = self:DoThrottle(eventtype, spellid, 0, amount, absorbed, critical, nil)
		
		if event1 then		
			self:AddCombatText(event1,spellid1,damage1,heal1,absorb1,crit1,count1,aura1)
		end
	elseif eventtype == "SPELL_AURA_APPLIED" then
		local auraType = select(15, ...)
		
		auraType = GetSpellIDFilter(spellid, auraType)	
		if not auraType then return end
		
		if not E.db.battletext.enabled[auraType] then return end
		
		
		local event1,spellid1,damage1,heal1,absorb1,crit1, count1, aura1 = self:DoThrottle(auraType, spellid, nil, nil, nil, critical, true)
		
		if event1 then
			self:AddCombatText(event1,spellid1,damage1,heal1,absorb1,crit1,count1,aura1)
		end

	elseif eventtype == "SPELL_AURA_APPLIED_DOSE" then
		local auraType, amount = select(15, ...)
		
		auraType = GetSpellIDFilter(spellid, auraType)	
		if not auraType then return end
		
		if not E.db.battletext.enabled[auraType] then return end
		
		self:AddCombatText(auraType, spellid, nil, nil, nil, critical, 0, true, amount)
	elseif eventtype == "SWING_DAMAGE" then
		if not E.db.battletext.enabled[eventtype] then return end
		
		local amount,overkill,school,resisted,blocked,absorbed,critical,glancing,crushing,multistrike = select(12, ...)
	
		local event1,spellid1,damage1,heal1,absorb1,crit1,count1,aura1 = self:DoThrottle(eventtype, 88163, amount, 0, absorbed, critical, nil)
		
				
		if event1 then		
			self:AddCombatText(event1,spellid1,damage1,heal1,absorb1,crit1,count1,aura1)
		end
	elseif eventtype == "RANGE_DAMAGE" then
		if not E.db.battletext.enabled[eventtype] then return end
		
		local amount,overkill,school,resisted,blocked,absorbed,critical,glancing,crushing,multistrike = select(15, ...)
	
		local event1,spellid1,damage1,heal1,absorb1,crit1,count1,aura1 = self:DoThrottle(eventtype, 88163, amount, 0, absorbed, critical, nil)
		
				
		if event1 then		
			self:AddCombatText(event1,spellid1,damage1,heal1,absorb1,crit1,count1,aura1)
		end
	elseif eventtype == "SPELL_ABSORBED" and ( UnitGetTotalAbsorbs("player") > 0 ) then
		
		--local sGUID = select(4, ...)
		--local sNAME = select(5, ...)
		--local tGUID = select(8, ...)
		--local tNAME = select(9, ...)
		local amount = select(22, ...)
		local spellID = 88163
		
		if amount == nil then
			amount = select(19, ...)		
		--	print("Melee", sNAME, tNAME, amount)
		else
			spellID = select(12, ...) --spellName
		--	print(spellName, sNAME, tNAME, amount)
		end
		
		
		local event1,spellid1,damage1,heal1,absorb1,crit1,count1,aura1 = self:DoThrottle(eventtype, spellID, 0, 0, amount, nil, nil)
		
				
		if event1 then		
			self:AddCombatText(event1,spellid1,damage1,heal1,absorb1,crit1,count1,aura1)
		end
	end
end
core.COMBAT_LOG_EVENT = core.COMBAT_LOG_EVENT_UNFILTERED

local curMax = 0
function core:UNIT_MAXHEALTH(event, unit)
	if unit ~= 'player' then return end
	myGUID = myGUID or UnitGUID(unit)	
	amountPoint	= UnitHealthMax(unit)*0.2
end
core[UNIT_HEALTH_EVENT] = core.UNIT_MAXHEALTH

--UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH UNIT_HEALTH

local selectedspell = nil

local function UpdateCombatTextStatus()	
	
	if E.db.battletext and ( E.db.battletext.enable ) then	--or E.db.battletext.enable_damageDone 
		core:RegisterEvent(CombatLogEvent)
	else
		core:UnregisterEvent(CombatLogEvent)
	end
	
	if not CombatText then return end
	--[==[
	if E.db.battletext and ( E.db.battletext.enable ) then --or E.db.battletext.enable_damageDone 
		CombatText:UnregisterEvent("COMBAT_TEXT_UPDATE");
		CombatText:UnregisterEvent("UNIT_HEALTH");
		CombatText:UnregisterEvent("UNIT_POWER_UPDATE");
		CombatText:UnregisterEvent("PLAYER_REGEN_DISABLED");
		CombatText:UnregisterEvent("PLAYER_REGEN_ENABLED");
		CombatText:UnregisterEvent("UNIT_COMBO_POINTS");
		CombatText:UnregisterEvent("RUNE_POWER_UPDATE");
		CombatText:UnregisterEvent("UNIT_ENTERED_VEHICLE");
		CombatText:UnregisterEvent("UNIT_EXITING_VEHICLE");
	else
		if ( SHOW_COMBAT_TEXT == "0" ) then
			CombatText:UnregisterEvent("COMBAT_TEXT_UPDATE");
			CombatText:UnregisterEvent("UNIT_HEALTH");
			CombatText:UnregisterEvent("UNIT_POWER_UPDATE");
			CombatText:UnregisterEvent("PLAYER_REGEN_DISABLED");
			CombatText:UnregisterEvent("PLAYER_REGEN_ENABLED");
			CombatText:UnregisterEvent("UNIT_COMBO_POINTS");
			CombatText:UnregisterEvent("RUNE_POWER_UPDATE");
			CombatText:UnregisterEvent("UNIT_ENTERED_VEHICLE");
			CombatText:UnregisterEvent("UNIT_EXITING_VEHICLE");
			return;
		end
		
		-- register events
		CombatText:RegisterEvent("COMBAT_TEXT_UPDATE");
		CombatText:RegisterEvent("UNIT_HEALTH");
		CombatText:RegisterEvent("UNIT_POWER_UPDATE");
		CombatText:RegisterEvent("PLAYER_REGEN_DISABLED");
		CombatText:RegisterEvent("PLAYER_REGEN_ENABLED");
		CombatText:RegisterEvent("UNIT_COMBO_POINTS");
		CombatText:RegisterEvent("RUNE_POWER_UPDATE");
		CombatText:RegisterEvent("UNIT_ENTERED_VEHICLE");
		CombatText:RegisterEvent("UNIT_EXITING_VEHICLE");
	end
	]==]
end
--[==[
	["enableFloatingCombatText"] = { prettyName = SHOW_COMBAT_TEXT_TEXT, description = OPTION_TOOLTIP_SHOW_COMBAT_TEXT , type = "boolean"},
	["floatingCombatTextAllSpellMechanics"] = { prettyName = nil, description = "", type = "boolean"},
	["floatingCombatTextAuras"] = { prettyName = COMBAT_TEXT_SHOW_AURAS_TEXT, description = OPTION_TOOLTIP_COMBAT_TEXT_SHOW_AURAS , type = "boolean"},
	["floatingCombatTextCombatDamage"] = { prettyName = SHOW_DAMAGE_TEXT, description = OPTION_TOOLTIP_SHOW_DAMAGE, type = "boolean"},
	["floatingCombatTextCombatDamageAllAutos"] = { prettyName = nil, description = "Show all auto-attack numbers, rather than hiding non-event numbers", type = "boolean"},
	["floatingCombatTextCombatDamageDirectionalOffset"] = { prettyName = nil, description = "Amount to offset directional damage numbers when they start", type = "boolean"},
	["floatingCombatTextCombatDamageDirectionalScale"] = { prettyName = "Directional Scale", description = "Directional damage numbers movement scale (disabled = no directional numbers)", type = "boolean"},
	["floatingCombatTextCombatHealing"] = { prettyName = SHOW_COMBAT_HEALING, description = OPTION_TOOLTIP_SHOW_COMBAT_HEALING, type = "boolean"},
	["floatingCombatTextCombatHealingAbsorbSelf"] = { prettyName = SHOW_COMBAT_HEALING_ABSORB_SELF.." (Self)", description = OPTION_TOOLTIP_SHOW_COMBAT_HEALING_ABSORB_SELF, type = "boolean"},
	["floatingCombatTextCombatHealingAbsorbTarget"] = { prettyName = SHOW_COMBAT_HEALING_ABSORB_TARGET.." (Target)" , description = OPTION_TOOLTIP_SHOW_COMBAT_HEALING_ABSORB_TARGET, type = "boolean"},
	["floatingCombatTextCombatLogPeriodicSpells"] = { prettyName = LOG_PERIODIC_EFFECTS, description = OPTION_TOOLTIP_LOG_PERIODIC_EFFECTS, type = "boolean"},
	["floatingCombatTextCombatState"] = { prettyName = COMBAT_TEXT_SHOW_COMBAT_STATE_TEXT, description = OPTION_TOOLTIP_COMBAT_TEXT_SHOW_COMBAT_STATE, type = "boolean"},
	["floatingCombatTextComboPoints"] = { prettyName = COMBAT_TEXT_SHOW_COMBO_POINTS_TEXT, description = OPTION_TOOLTIP_COMBAT_TEXT_SHOW_COMBO_POINTS , type = "boolean"},
	["floatingCombatTextDamageReduction"] = { prettyName =COMBAT_TEXT_SHOW_RESISTANCES_TEXT, description = OPTION_TOOLTIP_COMBAT_TEXT_SHOW_RESISTANCES, type = "boolean"},
	["floatingCombatTextDodgeParryMiss"] = { prettyName = COMBAT_TEXT_SHOW_DODGE_PARRY_MISS_TEXT, description = OPTION_TOOLTIP_COMBAT_TEXT_SHOW_DODGE_PARRY_MISS, type = "boolean"},
	["floatingCombatTextEnergyGains"] = { prettyName = COMBAT_TEXT_SHOW_ENERGIZE_TEXT.." & "..COMBAT_TEXT_SHOW_COMBO_POINTS_TEXT, description = OPTION_TOOLTIP_COMBAT_TEXT_SHOW_ENERGIZE, type = "boolean"},
	["floatingCombatTextFloatMode"] = { prettyName = "FCT: Float Mode", description = OPTION_TOOLTIP_COMBAT_TEXT_MODE, type = "number"},
	["floatingCombatTextFriendlyHealers"] = { prettyName = COMBAT_TEXT_SHOW_FRIENDLY_NAMES_TEXT, description = OPTION_TOOLTIP_COMBAT_TEXT_SHOW_FRIENDLY_NAMES, type = "boolean"},
	["floatingCombatTextHonorGains"] = { prettyName = COMBAT_TEXT_SHOW_HONOR_GAINED_TEXT, description = OPTION_TOOLTIP_COMBAT_TEXT_SHOW_HONOR_GAINED, type = "boolean"},
	["floatingCombatTextLowManaHealth"] = { prettyName = COMBAT_TEXT_SHOW_LOW_HEALTH_MANA_TEXT, description = OPTION_TOOLTIP_COMBAT_TEXT_SHOW_LOW_HEALTH_MANA, type = "boolean"},
	["floatingCombatTextPeriodicEnergyGains"] = { prettyName = COMBAT_TEXT_SHOW_PERIODIC_ENERGIZE_TEXT, description = OPTION_TOOLTIP_COMBAT_TEXT_SHOW_PERIODIC_ENERGIZE, type = "boolean"},
	["floatingCombatTextPetMeleeDamage"] = { prettyName = SHOW_PET_MELEE_DAMAGE, description = OPTION_TOOLTIP_SHOW_PET_MELEE_DAMAGE, type = "boolean"},
	["floatingCombatTextPetSpellDamage"] = { prettyName = "FCT: Pet Spell Damage", description = "Display pet spell damage in the world", type = "boolean"},
	["floatingCombatTextReactives"] = { prettyName = COMBAT_TEXT_SHOW_REACTIVES_TEXT, description = OPTION_TOOLTIP_COMBAT_TEXT_SHOW_REACTIVES, type = "boolean"},
	["floatingCombatTextRepChanges"] = { prettyName = COMBAT_TEXT_SHOW_REPUTATION_TEXT, description = OPTION_TOOLTIP_COMBAT_TEXT_SHOW_REPUTATION, type = "boolean"},
	["floatingCombatTextSpellMechanics"] = { prettyName = SHOW_TARGET_EFFECTS, description = OPTION_TOOLTIP_SHOW_TARGET_EFFECTS, type = "boolean"},
	["floatingCombatTextSpellMechanicsOther"] = { prettyName = SHOW_OTHER_TARGET_EFFECTS, description = OPTION_TOOLTIP_SHOW_OTHER_TARGET_EFFECTS, type = "boolean"},
]==]

local function InitBT()
	myGUID = UnitGUID("player")
	
	core:RegisterEvent("UNIT_MAXHEALTH")
	core:RegisterEvent(UNIT_HEALTH_EVENT)
	core:UNIT_MAXHEALTH('UNIT_MAXHEALTH', 'player')

	SetCVar('floatingCombatTextCombatLogPeriodicSpells', '1')
	
	E.GUI.args.BattleText = {
		name = L['Combat text'],
		type = "group",
		order = 5,
		args = {},
	}
	
	E.GUI.args.BattleText.args.Enable = {
		name = L['Enable'],
		type = 'toggle',
		order = 0.1,
		width = 'full',
		set = function()
			E.db.battletext.enable = not E.db.battletext.enable
			
			UpdateCombatTextStatus()
		end,
		get = function()
			return E.db.battletext.enable
		end,
	}
	
	E.GUI.args.BattleText.args.DisplayFloatingDamage = {
		name = L['Display floating damage'],
		type = 'toggle',
		order = 0.2,
		set = function()
			SetCVar('floatingCombatTextCombatDamage', GetCVarBool('floatingCombatTextCombatDamage') and 0 or 1)
		end,
		get = function()
			return GetCVarBool('floatingCombatTextCombatDamage')
		end,
	}
	E.GUI.args.BattleText.args.DisplayFloatingHeal = {
		name = L['Display floating heal'],
		type = 'toggle',
		order = 0.3,
		set = function()
			SetCVar('floatingCombatTextCombatHealing', GetCVarBool('floatingCombatTextCombatHealing') and 0 or 1)
		end,
		get = function()
			return GetCVarBool('floatingCombatTextCombatHealing')
		end,
	}
	
	--[==[
	E.GUI.args.BattleText.args.EnableDamageDone = {
		name = 'Показать наносимый урон',
		type = 'toggle',
		order = 0.2,
		set = function()
			E.db.battletext.enable_damageDone = not E.db.battletext.enable_damageDone
			
			UpdateCombatTextStatus()
		end,
		get = function()
			return E.db.battletext.enable_damageDone
		end,
	}
	]==]
	
	E.GUI.args.BattleText.args.EnableList = {
		name = L['Events'],
		type = "group",
		embend = true,
		order = 1,
		args = {},
	}

	for k,v in pairs(defaults.enabled) do
		E.GUI.args.BattleText.args.EnableList.args[k] = {
			name = Localiz[k], desc = Localiz[k],
			order = 1,
			type = "toggle",
			set = function(self, value)
				E.db.battletext.enabled[k] = not E.db.battletext.enabled[k]
			end,
			get = function(self)
				return E.db.battletext.enabled[k]
			end,
		}
	end
	
	E.GUI.args.BattleText.args.FontStyle = {
		name = L['Text style'],
		type = "group",
		embend = true,
		order = 2,
		args = {},
	}
	
	E.GUI.args.BattleText.args.FontStyle.args.font = {	
		name = L['Font'],
		order = 1,
		type = "font",
		values = E.GetFontList,
		set = function(self, value)
			E.db.battletext.font = value
			UpdateBattleTextStyle()
		end,
		get = function(self)
			return E.db.battletext.font
		end,
	}
	
	E.GUI.args.BattleText.args.FontStyle.args.fontSize = {	
		name = L['Size'],
		order = 1,
		type = "slider",
		min = 1, max = 32, step = 1,
		set = function(self, value)
			E.db.battletext.fontSize = value
			UpdateBattleTextStyle()			
		end,
		get = function(self)
			return E.db.battletext.fontSize
		end,
	}
	E.GUI.args.BattleText.args.FontStyle.args.fontFlag = {	
		name = L['Outline'],
		order = 3,
		type = "dropdown",
		values = {			
			[""] = NO,
			["OUTLINE"] = "OUTLINE",
		},
		set = function(self, value)
			E.db.battletext.fontFlag = value
			UpdateBattleTextStyle()
		end,
		get = function(self)
			return E.db.battletext.fontFlag
		end,
	}
	
	E.GUI.args.BattleText.args.colors = {
		name = L['Colors'],
		type = "group",
		embend = true,
		order = 3,
		args = {},
	}
	
	for k,v in pairs(defaults.colors) do
		
		E.GUI.args.BattleText.args.colors.args[k] = {
			name = Localiz[k], desc = Localiz[k],
			order = 1,
			type = "color",
			set = function(self, r,g,b)
				E.db.battletext.colors[k] = { r, g, b, 1 }
			end,
			get = function(self)
				return E.db.battletext.colors[k][1], E.db.battletext.colors[k][2], E.db.battletext.colors[k][3], 1
			end,
		}
		
	end
	
	E.GUI.args.BattleText.args.filter = {
		name = L['Filters'],
		type = "group",
		order = 1,
		args = {},	
	}
	
	E.GUI.args.BattleText.args.filter.args.spellid = {
		name = "SpellID",
		type = "editbox",
		order = 1,
		set = function(self, value)
			local num = tonumber(value)			
			if num and GetSpellInfo(num) then
				if not E.db.battletext.filters[num] then
				
					E.db.battletext.filters[num] = {}
					E.db.battletext.filters[num].show = false
					E.db.battletext.filters[num].type = "DEBUFF"
				end
				
				selectedspell = num
			end
		end,
		get = function(self)
			return ''
		end,
	
	}
	
	E.GUI.args.BattleText.args.filter.args.spelllist = {
		name = L['Select spell'],
		type = "dropdown",
		order = 2,
		values = function()
			local t = {}
			
			for spellid,params in pairs( E.db.battletext.filters ) do				
				t[spellid] = (GetSpellInfo(spellid) or UNKNOWN).." "..( params.type or UNKNOWN ).." "..( params.show and "SHOW" or "HIDE" )
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
	
	
	E.GUI.args.BattleText.args.filter.args.showhude = {
		name = L['Enable'],
		type = "toggle",
		order = 3,
		set = function(self, value)
			if selectedspell then
				E.db.battletext.filters[selectedspell].show = not E.db.battletext.filters[selectedspell].show
			end
		end,
		get = function(self)
			if selectedspell then
				return E.db.battletext.filters[selectedspell].show
			else
				return false
			end
		end,	
	}
	
	E.GUI.args.BattleText.args.filter.args.spelltype = {
		name = L['Type'],
		type = "dropdown",
		order = 4,
		values = {
			["BUFF"] = L['Buff'],
			["DEBUFF"] = L['Debuff'],
		},
		set = function(self, value)
			if selectedspell then
				E.db.battletext.filters[selectedspell].type = value
			end
		end,
		get = function(self)
			if selectedspell then
				return E.db.battletext.filters[selectedspell].type or "DEBUFF"
			else
				return "DEBUFF"
			end
		end,	
	}
	
	
	E:UpdateCombatTextSettings()
end

function E:UpdateCombatTextSettings()
	UpdateCombatTextStatus()
	UpdateBattleTextStyle()
end

AleaUI:OnInit(InitBT)
AleaUI:OnAddonLoad('Blizzard_CombatText', UpdateCombatTextStatus)