local E = AleaUI
local UF = E:Module("UnitFrames")
local L = E.L

local find = string.find
local select = select
local format = string.format
local pairs = pairs
local ipairs = ipairs
local atan2 = math.atan2
local modf = math.modf
local ceil = math.ceil
local floor = math.floor
local abs = math.abs
local gmatch = string.gmatch
local tinsert = table.insert
local match = string.match
local unpack = unpack
local max = math.max
local strsplit = strsplit

local _
local ItemHasRange = ItemHasRange
local IsItemInRange = IsItemInRange
local UnitCanAttack = UnitCanAttack
local UnitIsFriend = UnitIsFriend
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitExists = UnitExists
local UnitName = UnitName
local UnitPowerMax = UnitPowerMax
local UnitPower = UnitPower
local UnitIsWildBattlePet = UnitIsWildBattlePet
local UnitLevel = UnitLevel
local UnitIsBattlePetCompanion = UnitIsBattlePetCompanion
local UnitBattlePetLevel = UnitBattlePetLevel
local RAID_CLASS_COLORS = RAID_CLASS_COLORS
local UnitReaction = UnitReaction
local UnitClass = UnitClass 
local UnitClassification = UnitClassification
local UnitClassBase = UnitClassBase
local UnitFactionGroup = UnitFactionGroup
local UnitIsPVPFreeForAll = UnitIsPVPFreeForAll
local UnitIsPVP = UnitIsPVP
local GetPVPTimer = GetPVPTimer
local GetRaidTargetIndex = GetRaidTargetIndex
local UnitAlternatePowerInfo = UnitAlternatePowerInfo
local UnitGetIncomingHeals = UnitGetIncomingHeals
local UnitGetTotalHealAbsorbs = UnitGetTotalHealAbsorbs
local UnitGetTotalAbsorbs = UnitGetTotalAbsorbs
local UnitInVehicleHidesPetFrame = UnitInVehicleHidesPetFrame
local UnitCreatureType = UnitCreatureType
local UnitIsTappedByAllThreatList = UnitIsTappedByAllThreatList or function() return false end
local UnitIsTapped = UnitIsTapped or UnitIsTappedByAllThreatList
local UnitIsTappedByPlayer = UnitIsTappedByPlayer or UnitIsTappedByAllThreatList
local UnitPowerType = UnitPowerType
local UnitIsUnit = UnitIsUnit
local UnitIsPlayer = UnitIsPlayer
local UnitHasVehicleUI = UnitHasVehicleUI
local UNKNOWN = UNKNOWN
local UnitRace = UnitRace
local UnitInPhase = UnitInPhase
local PVP = PVP
local UnitIsVisible = UnitIsVisible
local UnitIsConnected = UnitIsConnected
local CreateFrame = CreateFrame
local RegisterStateDriver = RegisterStateDriver
local IsSpellKnown = IsSpellKnown
local NO = NO
local RAID_CLASS_COLORS = RAID_CLASS_COLORS
local CLASS_LOCALIZED = {}

for classID = 1, 20 do -- GetNumClasses not supported by wow classic
	local classInfo = C_CreatureInfo.GetClassInfo(classID)
	if classInfo then
	  CLASS_LOCALIZED[classInfo.classFile] = classInfo.className
	end
end


local function UnitPowerBarVisible(unit)
	local powerIndex = UnitPowerType(unit)
	
	if not powerIndex then
		return false
	end
	
	local powerMax = UnitPowerMax(unit, powerIndex)
	
	return ( powerMax and powerMax ~= 0 )
end

local pointDD = {		
	['LEFT'] = L['Left'],
	['RIGHT'] = L['Right'],
	['CENTER'] = L['Center'],	
}

UF.handledFrames = {}
UF.handledFrames['health'] = {}
UF.handledFrames['power'] = {}
UF.handledFrames['altpower'] = {}
UF.handledFrames['altmanabar'] = {}
UF.handledFrames['unitframes'] = {}

function UF:InterateAllFrames(func)
	for frame in pairs(UF.handledFrames['unitframes']) do
		if frame[func] then	
			frame[func](frame)
		end
	end
end

function UF:UpdateAllUnitFrames()
	for frame in pairs(UF.handledFrames['unitframes']) do
		frame:PostUpdate()
	end	
end

local function UpdateByLSM()
	for f in pairs(UF.handledFrames['unitframes']) do
		if f.opts then
			local opts = f.opts
			f.health:SetStatusBarTexture(E:GetTexture(opts.health.texture))
			f.power:SetStatusBarTexture(E:GetTexture(opts.power.texture))
			f.altpower:SetStatusBarTexture(E:GetTexture(opts.altpower.texture))
			
			local inset = 0
			if f.health.bg:IsShown() then
			--	inset = 2
			end
			
			f.health.totalHealPrediction:SetTexture(E:GetTexture(opts.health.texture))	
			f.health.totalHealPrediction:SetVertexColor(E.db.unitframes.colors.otherHeal[1], 
				E.db.unitframes.colors.otherHeal[2],E.db.unitframes.colors.otherHeal[3],E.db.unitframes.colors.otherHeal[4])		
			f.health.totalHealPrediction:SetHeight(opts.health.height-inset)
		
			f.health.totalAbsorb:SetTexture(E:GetTexture(opts.health.texture))	
			f.health.totalAbsorb:SetVertexColor(E.db.unitframes.colors.otherAbsorb[1], 
				E.db.unitframes.colors.otherAbsorb[2],E.db.unitframes.colors.otherAbsorb[3],E.db.unitframes.colors.otherAbsorb[4])		
			f.health.totalAbsorb:SetHeight(opts.health.height-inset)
			
			f.health.totalHealAbsorb:SetTexture(E:GetTexture(opts.health.texture))	
			f.health.totalHealAbsorb:SetVertexColor(E.db.unitframes.colors.myHealAbsorb[1], 
				E.db.unitframes.colors.myHealAbsorb[2],E.db.unitframes.colors.myHealAbsorb[3],E.db.unitframes.colors.myHealAbsorb[4])		
			f.health.totalHealAbsorb:SetHeight(opts.health.height-inset)
			
			f.health.overHealAbsorbGlow:SetVertexColor(E.db.unitframes.colors.myHealAbsorb[1], 
				E.db.unitframes.colors.myHealAbsorb[2],E.db.unitframes.colors.myHealAbsorb[3],E.db.unitframes.colors.myHealAbsorb[4])
			
			f.health.overAbsorbGlow:SetVertexColor(E.db.unitframes.colors.otherAbsorb[1], 
				E.db.unitframes.colors.otherAbsorb[2],E.db.unitframes.colors.otherAbsorb[3],E.db.unitframes.colors.otherAbsorb[4])
		
			f.health.leftText:SetFont(E:GetFont(opts.health.text.left.font),opts.health.text.left.fontSize, opts.health.text.left.fontOutline)
			f.health.rightText:SetFont(E:GetFont(opts.health.text.right.font),opts.health.text.right.fontSize, opts.health.text.right.fontOutline)
			f.health.centerText:SetFont(E:GetFont(opts.health.text.center.font),opts.health.text.center.fontSize, opts.health.text.center.fontOutline)

			f.power.leftText:SetFont(E:GetFont(opts.power.text.left.font),opts.power.text.left.fontSize, opts.power.text.left.fontOutline)
			f.power.rightText:SetFont(E:GetFont(opts.power.text.right.font),opts.power.text.right.fontSize, opts.power.text.right.fontOutline)
			f.power.centerText:SetFont(E:GetFont(opts.power.text.center.font),opts.power.text.center.fontSize, opts.power.text.center.fontOutline)

			f.altpower.leftText:SetFont(E:GetFont(opts.altpower.text.left.font),opts.altpower.text.left.fontSize, opts.altpower.text.left.fontOutline)
			f.altpower.rightText:SetFont(E:GetFont(opts.altpower.text.right.font),opts.altpower.text.right.fontSize, opts.altpower.text.right.fontOutline)
			f.altpower.centerText:SetFont(E:GetFont(opts.altpower.text.center.font),opts.altpower.text.center.fontSize, opts.altpower.text.center.fontOutline)
			
			if f.altmanabar then
				f.altmanabar:SetStatusBarTexture(E:GetTexture(opts.altmanabar.texture))
				
				f.altmanabar.leftText:SetFont(E:GetFont(opts.altmanabar.text.left.font),opts.altmanabar.text.left.fontSize, opts.altmanabar.text.left.fontOutline)
				f.altmanabar.rightText:SetFont(E:GetFont(opts.altmanabar.text.right.font),opts.altmanabar.text.right.fontSize, opts.altmanabar.text.right.fontOutline)
				f.altmanabar.centerText:SetFont(E:GetFont(opts.altmanabar.text.center.font),opts.altmanabar.text.center.fontSize, opts.altmanabar.text.center.fontOutline)
			end
		end
	end	
end

E.UpdateByLSM = UpdateByLSM
E.OnLSMUpdateRegister(function()
	UpdateByLSM()
end)	

local defaults = {	

	nameColorByValue = false,
	nameColorByClass = false,
	reverBarColor = false,
	rangeCheck = false,
	smoothBars = false,
	
	['colors'] = {
		["normal"] 				= { 0.2, 0.2, 0.2, 1 },
		["tapped"] 				= { 0.6, 0.6, 0.6, 1},
		["hp_background"] 		= { 0.4, 0.4, 0.4, 1 },
		["power_background"]	= { 0, 0, 0, 1 },
		["altpower_background"] = { 0, 0, 0, 1 },
		
		['myHeal']				= { 11/255, 136/255, 105/255,  0.9 },
		['otherHeal']			= { 21/255, 89/255, 72/255,    0.9 },
		['myHealAbsorb']		= { 255/255, 0/255, 33/255,    0.9 },
		['otherAbsorb']			= { 89/255, 236/255, 247/255,  0.9 },
	},
	
	['reaction_colors'] = {
		[1] = { 0.78, 0.25, 0.25, 1 }, 
		[2] = { 0.78, 0.25, 0.25, 1 }, 
		[3] = { 0.78, 0.25, 0.25, 1 }, 
		[4] = { 218/255, 197/255, 92/255 }, 
		[5] = { 75/255,  175/255, 76/255 }, 
		[6] = { 75/255,  175/255, 76/255 }, 
		[7] = { 75/255,  175/255, 76/255 },
		[8] = { 75/255,  175/255, 76/255 },
	},
	
	['power_colors'] = {
		["MANA"] 		= { 53/255, 74/255, 123/255 },
		["RAGE"] 		= { 166/255, 64/255, 64/255 },
		["FOCUS"] 		= { 181/255, 110/255, 69/255 },
		["ENERGY"] 		= { 166/255, 161/255, 89/255 },
		["RUNIC_POWER"] = { 0, 209/255, 1 },
		["ALTERNATE"] 	= { 0.7, 0.7, 0.7, 1 },
		['INSANITY'] 	= { 0.40, 0, 0.80, 1},
		['MAELSTROM']   = { 0.00, 0.50, 1.00, 1},
		["FURY"]		= { 0.788, 0.259, 0.992, 1 },
		['PAIN']		= { 255/255, 156/255, 0, 1 },
		['LUNAR_POWER'] = { 0.30, 0.52, 0.90, 1},
	},

	['unitopts'] = {},
}


E.default_settings.unitframes = defaults

local MAX_POWER_MINIMUM = 150
UF.MAX_POWER_MINIMUM = MAX_POWER_MINIMUM

local function colorString(...)	
	return format("|cff%02x%02x%02x", select(1, ...))
end

E.RGBToHex = colorString

function E.NumCompress(value)
	if value >= 1e6 then
		return ('%.2fm'):format(value / 1e6)
	elseif value >= 1e4 then
		return ('%.1fk'):format(value / 1e3)
	else
		return ('%.0f'):format(value)
	end
end

-- http://www.wowwiki.com/ColorGradient
function E:ColorGradient(a, b, ...)
	local perc
	if(b == 0) then
		perc = 0
	else
		perc = a / b
	end

	if perc >= 1 then
		local r, g, b = select(select('#', ...) - 2, ...)
		return r, g, b
	elseif perc <= 0 then
		local r, g, b = ...
		return r, g, b
	end

	local num = select('#', ...) / 3
	local segment, relperc = modf(perc*(num-1))
	local r1, g1, b1, r2, g2, b2 = select((segment*3)+1, ...)

	return r1 + (r2-r1)*relperc, g1 + (g2-g1)*relperc, b1 + (b2-b1)*relperc
end

do
	local format = format
	local math_fmod = math.fmod
	function E.NumberToTime(timer)
		if timer <= 60 then
			return format(" %.0fс ", timer+0.1)
		else
			return format(" %dм ", timer/60)
			-- return ("%d:%0.2dm"):format(timer/60, math_fmod(timer, 60))
		end
	end
end

do
	UF.ClassColors = {}
	UF.ClassColors['Default'] = { 1, 1, 1 }
	
	for class, data in pairs(RAID_CLASS_COLORS) do
		UF.ClassColors[class] = { data.r, data.g, data.b, 1 }
	end
	
	
	function UF.GetClassColor(unit)
		local unitReaction = UnitReaction(unit, 'player')
	--	local isFriend = UnitIsFriend(unit, 'player')
		
		local _, unitClass = UnitClass(unit)
		if (UnitIsPlayer(unit)) then
			local color = UF.ClassColors[unitClass]
			if color then return color end
	--	elseif not isFriend and (not UnitIsTappedByAllThreatList(unit) and UnitIsTapped(unit) and not UnitIsTappedByPlayer(unit)) then
	--		local color = E.db.unitframes.colors["tapped"]
	--		return format("|cff%02x%02x%02x", color[1]*255, color[2]*255, color[3]*255)
		elseif (unitReaction) then
			local reaction = E.db.unitframes.reaction_colors[unitReaction]
			if reaction then return reaction end
		end
		
		return UF.ClassColors['Default']
	end
end

local Harm_Items_Table = {
	{ 37727, 5 },
	{ 34368, 8 },
	{ 32321, 10 },
	{ 33069, 15 },
	{ 10645, 20 },
	{ 31463, 25 },
	{ 34191, 30 },
	{ 18904, 35 },
	{ 28767, 40 },
	{ 23836, 45 },
	{ 37887, 60 },
	{ 35278, 80 },
}

local Help_Items_Table = {
	{37727, 5},
	{34368, 8},
	{33278, 8},	
	{32321, 10},
	{1251, 15},
	{21519, 20},
	{31463, 25},
	{34191, 30},
	{18904, 35},
	{34471, 40},
	{32698, 45},
	{37887, 60},
	{35278, 80},
}

local function CheckItemRange(id, unit)
	if ItemHasRange(id) and ( IsItemInRange(id, unit) == 1 or IsItemInRange(id, unit) == true ) then
		return true
	end
end

local MAX_RANGE = 90
local MAX_PLAYER_LEVEL = MAX_PLAYER_LEVEL
local MIN_RANGE = 0

local function GetRange(unit)
	local _range = MAX_RANGE
	local _range2 = MIN_RANGE
	
	local attack = false

	if UnitCanAttack('player', unit) then
		attack = true
		
		for i=1, #Harm_Items_Table do
			local data = Harm_Items_Table[i]
			
			if CheckItemRange(data[1], unit) then
				_range = data[2]
				_range2 = Harm_Items_Table[i-1] and Harm_Items_Table[i-1][2] or MIN_RANGE
				break
			end
		end
	else
		attack = false
		for i=1, #Help_Items_Table do
			local data = Help_Items_Table[i]
			if  CheckItemRange(data[1], unit) then
				_range = data[2]
				_range2 = Help_Items_Table[i-1] and Help_Items_Table[i-1][2] or MIN_RANGE			
				break
			end
		end
	end
	
	return _range, attack, _range2
end

local function IsFriendly(unit)
	local reaction = UnitReaction("player", unit) or 0

	return reaction > 4
end

local tag_function = {}
local tag_OnEvents = {}
local tag_OnUpdate = {}

UF.tag_function = tag_function
UF.tag_OnEvents = tag_OnEvents
UF.tag_OnUpdate = tag_OnUpdate

--            POST_UPDATE_FRAME        - event for OnShowing frames or when focus target changed

tag_OnEvents["[health]"] = "UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH"
tag_function["[health]"] = function(unit)
	return E:ShortValue(UnitHealth(unit))
end
	
tag_OnEvents["[health:max]"] = "UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH"
tag_function["[health:max]"] = function(unit)
	return E:ShortValue(UnitHealthMax(unit))
end

tag_OnEvents["[health:percent]"] = "UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH"
tag_function["[health:percent]"] = function(unit)
	local hp = UnitHealth(unit)
	local hpmax = UnitHealthMax(unit) or 0		
	
	local perc = 0
	
	if hp and hpmax and hpmax > 0 then
		perc = hp/hpmax* 100
	end
	
	if perc < 100 and perc > 0 then
		return format('%.1f%%', perc)
	else
		return format('%d%%', perc)
	end
end
	
tag_OnEvents["[name]"] = "UNIT_NAME_UPDATE POST_UPDATE_FRAME"
tag_function["[name]"] =  function(unit)		
	return UnitName(unit) or UNKNOWN
end
	
tag_OnEvents["[name:10]"] = "UNIT_NAME_UPDATE POST_UPDATE_FRAME"
tag_function["[name:10]"] = function(unit)
	local name = UnitName(unit) or UNKNOWN
	return E:utf8sub(name, 1, 10)
end

tag_OnEvents["[name:15]"] = "UNIT_NAME_UPDATE POST_UPDATE_FRAME"
tag_function["[name:15]"] = function(unit)
	local name = UnitName(unit) or UNKNOWN
	return E:utf8sub(name, 1, 15)
end

tag_OnEvents["[name:20]"] = "UNIT_NAME_UPDATE POST_UPDATE_FRAME"
tag_function["[name:20]"] = function(unit)
	local name = UnitName(unit) or UNKNOWN
	return E:utf8sub(name, 1, 20)
end

tag_OnEvents["[name:25]"] = "UNIT_NAME_UPDATE POST_UPDATE_FRAME"
tag_function["[name:25]"] = function(unit)
	local name = UnitName(unit) or UNKNOWN
	return E:utf8sub(name, 1, 25)
end

tag_OnEvents["[name:30]"] = "UNIT_NAME_UPDATE POST_UPDATE_FRAME"
tag_function["[name:30]"] = function(unit)
	local name = UnitName(unit) or UNKNOWN
	return E:utf8sub(name, 1, 30)
end

tag_OnEvents["[name:40]"] = "UNIT_NAME_UPDATE POST_UPDATE_FRAME"
tag_function["[name:40]"] = function(unit)
	local name = UnitName(unit) or UNKNOWN
	return E:utf8sub(name, 1, 40)
end

tag_OnEvents["[name:50]"] = "UNIT_NAME_UPDATE POST_UPDATE_FRAME"
tag_function["[name:50]"] = function(unit)
	local name = UnitName(unit) or UNKNOWN
	return E:utf8sub(name, 1, 50)
end

tag_OnEvents["[power:mana]"]	= "UNIT_MAXPOWER UNIT_POWER_UPDATE UNIT_POWER_FREQUENT"
tag_function["[power:mana]"] = function(unit)
	local powerType = 0

	return format("%s%d", UF:PowerColorString(unit, nil, 'MANA'), UnitPower(unit, powerType))
end
	
tag_OnEvents["[power:mana:max]"] = "UNIT_MAXPOWER UNIT_POWER_UPDATE UNIT_POWER_FREQUENT"
tag_function["[power:mana:max]"] = function(unit)
	local powerType = 0
	
	return format("%s%d", UF:PowerColorString(unit, nil, 'MANA'), UnitPowerMax(unit, powerType))
end
	
tag_OnEvents["[power:mana:percent]"] = "UNIT_MAXPOWER UNIT_POWER_UPDATE UNIT_POWER_FREQUENT"
tag_function["[power:mana:percent]"] = function(unit, power)	
	local powerType = 0
	
	if UnitPowerMax(unit, powerType) > MAX_POWER_MINIMUM then
		local pers = UnitPower(unit, powerType)/UnitPowerMax(unit, powerType)*100
		return format( ( pers < 100 and pers > 0 ) and '%s%.1f%%' or '%s%d%%', UF:PowerColorString(unit, nil, 'MANA'), pers)
	else
		return format("%s%.0f", UF:PowerColorString(unit, nil, 'MANA'), UnitPower(unit, powerType))
	end
end

tag_OnEvents["[power]"]	= "UNIT_MAXPOWER UNIT_POWER_UPDATE UNIT_POWER_FREQUENT"
tag_function["[power]"] = function(unit)
	local powerType = UnitPowerType(unit)
	
	return format("%s%d", UF:PowerColorString(unit), UnitPower(unit, powerType))
end
	
tag_OnEvents["[power:max]"] = "UNIT_MAXPOWER UNIT_POWER_UPDATE UNIT_POWER_FREQUENT"
tag_function["[power:max]"] = function(unit)
	local powerType = UnitPowerType(unit)
	
	return format("%s%d", UF:PowerColorString(unit), UnitPowerMax(unit, powerType))
end
	
tag_OnEvents["[power:percent:smart]"] = "UNIT_MAXPOWER UNIT_POWER_UPDATE UNIT_POWER_FREQUENT"
tag_function["[power:percent:smart]"] = function(unit, power)	
	local powerType = UnitPowerType(unit)
	
	if UnitPowerMax(unit, powerType) > MAX_POWER_MINIMUM then
		local pers = UnitPower(unit, powerType)/UnitPowerMax(unit, powerType)*100
		return format( ( pers < 100 and pers > 0 ) and '%s%.1f%%' or '%s%d%%', UF:PowerColorString(unit), pers)
	else
		return format("%s%.0f", UF:PowerColorString(unit), UnitPower(unit, powerType))
	end
end

tag_OnEvents["[power:percent]"] = "UNIT_MAXPOWER UNIT_POWER_UPDATE UNIT_POWER_FREQUENT"
tag_function["[power:percent]"] = function(unit, power)	
	local powerType = UnitPowerType(unit)
	local powerMax = UnitPowerMax(unit, powerType)
	
	if powerMax == 0 then
		return ''
	end

	local pers = UnitPower(unit, powerType)/powerMax*100
	return format( ( pers < 100 and pers > 0 ) and '%s%.1f%%' or '%s%d%%', UF:PowerColorString(unit), pers)
end

tag_OnEvents["[bothpower:percent]"] = "UNIT_MAXPOWER UNIT_POWER_UPDATE UNIT_POWER_FREQUENT"
tag_function["[bothpower:percent]"] = function(unit)
	local power = ''
	local altpower = ''
	local separator = ''
	
	local powerType = UnitPowerType(unit)
	
	local maxPower = UnitPowerMax(unit, powerType)
	local curPower = UnitPower(unit, powerType)
	
	local altMaxPower = UnitPowerMax(unit, E.PowerType.Alternate)
	local curAltMaxPower = UnitPower(unit, E.PowerType.Alternate)
	
	if maxPower > MAX_POWER_MINIMUM then
		local pers = curPower/maxPower*100
		power = format( ( pers < 100 and pers > 0 ) and '%s%.1f%%' or '%s%d%%', UF:PowerColorString(unit), pers)
	elseif maxPower > 0 then
		power = format("%s%.0f", UF:PowerColorString(unit), curPower)
	end
	
	if altMaxPower > MAX_POWER_MINIMUM then	
		local pers = curAltMaxPower/altMaxPower*100
		altpower = format( ( pers < 100 and pers > 0 ) and '%s%.1f%%' or '%s%d%%', UF:PowerColorString(unit, E.PowerType.Alternate), pers)
	elseif altMaxPower > 0 then
		altpower = format("%s%.0f", UF:PowerColorString(unit, E.PowerType.Alternate), curAltMaxPower)
	end

	if power ~= '' and altpower ~= '' then
		separator = ' | '
	end
	
	return format("%s%s%s",power,separator,altpower)
end

tag_OnEvents["[altpower]"]	= "UNIT_MAXPOWER UNIT_POWER_UPDATE UNIT_POWER_FREQUENT"
tag_function["[altpower]"] = function(unit)
	local altMaxPower = UnitPowerMax(unit, E.PowerType.Alternate)
	local curAltMaxPower = UnitPower(unit, E.PowerType.Alternate)
	
	if altMaxPower == 0 then
		return ''
	end
	
	return format("%s%d", UF:PowerColorString(unit, E.PowerType.Alternate), curAltMaxPower)
end
	
tag_OnEvents["[altpower:max]"] = "UNIT_MAXPOWER UNIT_POWER_UPDATE UNIT_POWER_FREQUENT"
tag_function["[altpower:max]"] = function(unit)
	local altMaxPower = UnitPowerMax(unit, E.PowerType.Alternate)
	local curAltMaxPower = UnitPower(unit, E.PowerType.Alternate)

	return format("%s%d", UF:PowerColorString(unit, E.PowerType.Alternate), altMaxPower)
end
	
tag_OnEvents["[altpower:percent:smart]"] = "UNIT_MAXPOWER UNIT_POWER_UPDATE UNIT_POWER_FREQUENT"
tag_function["[altpower:percent:smart]"] = function(unit)
	local altMaxPower = UnitPowerMax(unit, E.PowerType.Alternate)
	local curAltMaxPower = UnitPower(unit, E.PowerType.Alternate)

	if altMaxPower > MAX_POWER_MINIMUM then
		
		local pers = curAltMaxPower/altMaxPower*100
		return format( ( pers < 100 and pers > 0 ) and '%s%.1f%%' or '%s%d%%', UF:PowerColorString(unit, E.PowerType.Alternate), pers)
	else
		return format("%s%.0f", UF:PowerColorString(unit, E.PowerType.Alternate), curAltMaxPower )
	end
end

tag_OnEvents["[altpower:percent]"] = "UNIT_MAXPOWER UNIT_POWER_UPDATE UNIT_POWER_FREQUENT"
tag_function["[altpower:percent]"] = function(unit)
	local altMaxPower = UnitPowerMax(unit, E.PowerType.Alternate)
	local curAltMaxPower = UnitPower(unit, E.PowerType.Alternate)
	
	local pers = curAltMaxPower/altMaxPower*100
	return format( ( pers < 100 and pers > 0 ) and '%s%.1f%%' or '%s%d%%', UF:PowerColorString(unit, E.PowerType.Alternate), pers)
end

-- UnitClassification(unit);

tag_OnEvents["[level]"] = "UNIT_LEVEL PLAYER_LEVEL_UP POST_UPDATE_FRAME"
tag_function["[level]"] = function(unit)
	local level = UnitLevel(unit)
	if ( UnitIsWildBattlePet and UnitIsWildBattlePet(unit) or UnitIsBattlePetCompanion and UnitIsBattlePetCompanion(unit) ) then
		return UnitBattlePetLevel(unit)
	elseif (level == UnitLevel('player')) then
		return '|cffF2F266'..level.."|r"
	elseif (level > UnitLevel('player')+3) then
		return '|cffff0000'..level.."|r"
	elseif (level > UnitLevel('player')) then
		return '|cffF2F266'..level.."|r"
	elseif level > 0 then
		return '|cff4baf4c'..level.."|r"
	else
		return '|cffcc7f00??|r'
	end
end

tag_OnEvents["[level:smart]"] = "UNIT_LEVEL PLAYER_LEVEL_UP POST_UPDATE_FRAME"
tag_function["[level:smart]"] = function(unit)
	local level = UnitLevel(unit)
	if ( UnitIsWildBattlePet and UnitIsWildBattlePet(unit) or UnitIsBattlePetCompanion and UnitIsBattlePetCompanion(unit) ) then
		return UnitBattlePetLevel(unit);
	elseif level == UnitLevel('player') then
		return ''
	elseif (level > UnitLevel('player')+3) then
		return '|cffff0000'..level.."|r"
	elseif (level > UnitLevel('player')) then
		return '|cffF2F266'..level.."|r"
	elseif(level > 0) then
		return '|cff4baf4c'..level.."|r"
	else
		return '|cffcc7f00??|r'
	end
end

tag_OnEvents["[playerlevel]"] = "UNIT_LEVEL PLAYER_LEVEL_UP POST_UPDATE_FRAME"
tag_function["[playerlevel]"] = function(unit)
	local level = UnitLevel(unit)
	
	if level == MAX_PLAYER_LEVEL then
		return ''
	else
		return '|cff4baf4c'..level.."|r"
	end
end

tag_OnEvents["[namecolor]"] = 'UNIT_NAME_UPDATE POST_UPDATE_FRAME UNIT_FACTION'
tag_function["[namecolor]"] = function(unit)
	local unitReaction = UnitReaction(unit, 'player')
	local isFriend = UnitIsFriend(unit, 'player')
	
	local _, unitClass = UnitClass(unit)
	if (UnitIsPlayer(unit)) then
		local class = RAID_CLASS_COLORS[unitClass]
		if class then return '|c'..RAID_CLASS_COLORS[unitClass].colorStr end
		return '|cFFFFFFFF'	
	elseif not isFriend and (not UnitIsTappedByAllThreatList(unit) and UnitIsTapped(unit) and not UnitIsTappedByPlayer(unit)) then
		local color = E.db.unitframes.colors["tapped"]
		return format("|cff%02x%02x%02x", color[1]*255, color[2]*255, color[3]*255)
	elseif (unitReaction) then
		local reaction = E.db.unitframes.reaction_colors[unitReaction]
		return format("|cff%02x%02x%02x", reaction[1]*255, reaction[2]*255, reaction[3]*255)
	else
		return '|cFFC2C2C2'
	end
end


local classificationColor = {
	elite = "|cffffff00"..L['Elite'].."|r",
	minus = "",
	normal = "",
	rare = "|cffaaaaaa"..L['Rare'].."|r",
	rareelite = "|cffaaaaaa"..L['Rare'].."+|r",
	worldboss = "|cffff0000"..L['Boss'].."|r",
}

local classificationColorShort = {
	elite = "|cffffff00+|r",
	minus = "",
	normal = "",
	rare = "|cffaaaaaaR|r",
	rareelite = "|cffaaaaaaR+|r",
	worldboss = "|cffff0000+|r",
}

tag_OnEvents["[classification]"] = "UNIT_LEVEL UNIT_NAME_UPDATE POST_UPDATE_FRAME"
tag_function["[classification]"] = function(unit)
	local classif = UnitClassification(unit)
	return classificationColor[classif] or ''
end

tag_OnEvents["[classification:short]"] = "UNIT_LEVEL UNIT_NAME_UPDATE POST_UPDATE_FRAME"
tag_function["[classification:short]"] = function(unit)
	local classif = UnitClassification(unit)
	return classificationColorShort[classif] or ''
end


tag_OnEvents["[class]"] = "UNIT_LEVEL UNIT_NAME_UPDATE POST_UPDATE_FRAME"
tag_function["[class]"] = function(unit)
	
	if UnitIsPlayer(unit) then
		local class, classFileName = UnitClass(unit)
		if classFileName then
			return format('|c%s%s|r', RAID_CLASS_COLORS[classFileName] and RAID_CLASS_COLORS[classFileName].colorStr or 'ffffffff', class)
		end
	else
		local class  = UnitClassBase(unit)	
		if class then
			return format('|c%s%s|r', RAID_CLASS_COLORS[class] and RAID_CLASS_COLORS[class].colorStr or 'ffffffff', CLASS_LOCALIZED[class])
		end

	end
	
	return ''
end

tag_OnEvents["[creaturetype]"] = "UNIT_LEVEL UNIT_NAME_UPDATE POST_UPDATE_FRAME"
tag_function["[creaturetype]"] = function(unit)
	return UnitCreatureType(unit) or UNKNOWN
end	
	
tag_OnEvents["[faction]"] = "UNIT_LEVEL UNIT_NAME_UPDATE POST_UPDATE_FRAME"
tag_function["[faction]"] = function(unit)
	local faction, factionname = UnitFactionGroup(unit)
	if faction and UnitIsPlayer(unit) then
		return ( faction == "Horde" and "|cFFFF0000" or "|cFF0000FF" )..factionname.."|r"
	else
		return ''
	end
end

tag_OnEvents["[autoinfo]"] = "UNIT_LEVEL PLAYER_LEVEL_UP UNIT_NAME_UPDATE POST_UPDATE_FRAME"
tag_function["[autoinfo]"] = function(unit)
	local info 
	
	local classif = UnitClassification(unit)
	info = classificationColor[classif] or ''
	
	local faction, factionname = UnitFactionGroup(unit)
	if faction then
		info = ( faction == "Horde" and "|cFFFF0000" or "|cFF008eff" )..factionname.."|r "..info 
	end
	
	
	local level = UnitLevel(unit)
	if ( UnitIsWildBattlePet and UnitIsWildBattlePet(unit) or UnitIsBattlePetCompanion and UnitIsBattlePetCompanion(unit) ) then
		info = UnitBattlePetLevel(unit).." "..info
	elseif level == UnitLevel('player') then
		
	elseif(level > 0) then
		info = '|cff4baf4c'..level.."|r "..info
	else
		info = '|cffcc7f00??|r '..info
	end
	
	return info
end

tag_OnEvents["[race]"] = "UNIT_LEVEL UNIT_NAME_UPDATE POST_UPDATE_FRAME"
tag_function["[race]"] = function(unit)
	local race, raceEn = UnitRace(unit)
	if race then
		return race
	else
		local npcRace = UnitCreatureType(unit)
		if npcRace then
			return npcRace
		else
			return ''
		end
	end
end


tag_OnEvents["[range]"] = "POST_UPDATE_FRAME ON_RANGE_CHANGED"
tag_function["[range]"] = function(unit, skip, r1, enemy1, r21)

	local r, enemy, r2 
	local phazed = UnitInPhase(unit)
	
	if UnitIsUnit('player', unit) then
		return ''
	elseif not UnitIsVisible('player', unit) then 
		return '??'
	elseif phazed then
		if E.db.unitframes.rangeCheck then
			return ''
		end
	
		if skip then
			r, enemy, r2 = r1, enemy1, r21
		else
			r, enemy, r2 = GetRange(unit)
		end
		
		if enemy then
			if r == MAX_RANGE then		
				return format("|cff%02x%02x%02x%s|r", 255, 0, 0, ">80")
			end
			return format("|cff%02x%02x%02x%d-%d|r", 255, 0, 0, r2+1, r)
		else
			if r == MAX_RANGE then
				return format("|cff%02x%02x%02x%s|r", 0, 255, 0, ">80")
			end
			return format("|cff%02x%02x%02x%d-%d|r", 0, 255, 0, r2+1, r)
		end
	else
		return format("|cff%02x%02x%02x%s|r", 100, 100, 100, 'Фазирование')
	end
end

tag_OnUpdate["[timer]"] = { trottle = 1 }
tag_function["[timer]"] = function(unit)
	if (UnitIsPVPFreeForAll(unit) or UnitIsPVP(unit)) then
		local timer = GetPVPTimer()

		if timer ~= 301000 and timer ~= -1 then	
			local mins = floor((timer / 1000) / 60)
			local secs = floor((timer / 1000) - (mins * 60))
			return format("%s (%01.f:%02.f)", PVP, mins, secs)
		else
			return PVP
		end
	else
		return ""
	end
end

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

local function UpdateRaidMark(self)
	if not UnitExists(self.displayerUnit or self.unit) then 
		self.raidMark:Hide()
		return 
	end
	local mark = GetRaidTargetIndex(self.displayerUnit or self.unit);
		
	if ( raidIndexCoord[mark] ) then
		self.raidMark:Show()
		self.raidMark:SetTexCoord(raidIndexCoord[mark][1], raidIndexCoord[mark][2], raidIndexCoord[mark][3], raidIndexCoord[mark][4])
	else
		self.raidMark:Hide()
	end		
end

local function UpdateAltPower(f, unit, show)
	if show then
		f.altpower:Show()
	else
		f.altpower:Hide()
	end	
	f:UNIT_DISPLAYPOWER("UNIT_DISPLAYPOWER", unit, "ALTERNATE")
end
 
local testParentFrame = CreateFrame('Frame', nil, E.UIParent)
testParentFrame:SetSize(1,1)
testParentFrame.enabledForTest = {}
testParentFrame:RegisterEvent('PLAYER_REGEN_DISABLED')
testParentFrame:SetScript('OnEvent', function(self, event)
	if event == 'PLAYER_REGEN_ENABLED' then
		self:UnregisterEvent(event)
		self:RegisterEvent('PLAYER_REGEN_DISABLED')
	else
		self:UnregisterEvent(event)
		UF:DisableAllTestFrames()
		self:RegisterEvent('PLAYER_REGEN_ENABLED')
	end
end)
 
function UF:ReEnableTestFrames()
	for frame in pairs( testParentFrame.enabledForTest ) do
		frame:EnableTestFrames()
	end
end

function UF:DisableAllTestFrames()
	for frame in pairs( testParentFrame.enabledForTest ) do
		frame:DisableTestFrames()
	end
end

function UF:EnableTestFrames()
	
	if self.health then
		self.health:SetParent(testParentFrame)
		self.health.leftText:SetText('hlt')
		self.health.rightText:SetText('hrt')		
		self.health.centerText:SetText('hct')
		self.health:SetMinMaxValues(1, 100)
		self.health:SetValue(30)
	end
	if self.power then
		self.power:SetParent(testParentFrame)
		self.power.leftText:SetText('plt')
		self.power.rightText:SetText('prt')		
		self.power.centerText:SetText('pct')
		self.power:SetMinMaxValues(1, 100)
		self.power:SetValue(40)
	end
	
	if self.altpower then
		self.altpower:SetParent(testParentFrame)
		self.altpower.leftText:SetText('alt')
		self.altpower.rightText:SetText('art')		
		self.altpower.centerText:SetText('act')
		self.altpower:SetMinMaxValues(1, 100)
		self.altpower:SetValue(50)
	end
	
	if self.border then
		self.border:SetParent(testParentFrame)
	end
	
	if self.aggro then
		self.aggro:SetParent(testParentFrame)
		self.aggro:Show()
	end
	
	if self.castBar then
		self.castBar:SetParent(testParentFrame)
		self.castBar:TestCastBar()
	end
	
	
	if self.AuraWidget then
		if self.AuraWidget then
			for i=1, self.AuraWidget.buff_amount do
				self.AuraWidget.HELPFUL[i]:SetParent(testParentFrame)			
			end
			for i=1, self.AuraWidget.debuff_amount do
				self.AuraWidget.HARMFUL[i]:SetParent(testParentFrame)		
			end
		end
		self.AuraWidget:TestUnitAuras()
	end
	
	self:UpdateHealPrediction()
	
	testParentFrame.enabledForTest[self] = true
end


function UF:DisableTestFrames()
	
	if self.health then
		self.health.leftText:SetText('')
		self.health.rightText:SetText('')		
		self.health.centerText:SetText('')
		self.health:SetParent(self)
	end
	if self.power then
		self.power.leftText:SetText('')
		self.power.rightText:SetText('')		
		self.power.centerText:SetText('')
		self.power:SetParent(self)
	end
	
	if self.altpower then
		self.altpower.leftText:SetText('')
		self.altpower.rightText:SetText('')		
		self.altpower.centerText:SetText('')
		self.altpower:SetParent(self)
	end
	
	if self.border then
		self.border:SetParent(self)
	end
	
	if self.aggro then
		self.aggro:SetParent(self)
	end
	
	if self.castBar then
		self.castBar:SetParent(self)
		self.castBar:Hide()
	end
	
	if self.AuraWidget then
		for i=1, self.AuraWidget.buff_amount do
			self.AuraWidget.HELPFUL[i]:SetParent(self)			
		end
		for i=1, self.AuraWidget.debuff_amount do
			self.AuraWidget.HARMFUL[i]:SetParent(self)		
		end
		
		local func = self.AuraWidget:GetScript("OnEvent")
		func(self.AuraWidget, _, self.displayerUnit or self.unit)
	end
	
	self:PostUpdate()
	testParentFrame.enabledForTest[self] = nil
end

function UF:ToggleTestFrames()
	if testParentFrame.enabledForTest[self] then
		self:DisableTestFrames()
	else
		self:EnableTestFrames()
	end
	
	self:UpdateFrameConstruct()
end


local MAX_INCOMING_HEAL_OVERFLOW = 1.05;


local UpdateHealPrediction = function(self)
	local _, maxHealth = self.health:GetMinMaxValues();
	local health = self.health:GetValue();
	local width = self.health:GetWidth()
	
	if ( maxHealth <= 0 or E.isClassic) then
		self.health.totalHealPrediction:SetWidth(0)
		self.health.totalHealPrediction:Hide()
		self.health.totalAbsorb:Hide()			
		self.health.overHealAbsorbGlow:Hide()
		self.health.totalHealAbsorb:Hide()	
		self.health.overAbsorbGlow:Hide()
		return;
	end
	
	local widthperhp = width/maxHealth
	
	local myIncomingHeal      = UnitGetIncomingHeals(self.displayerUnit or self.unit, "player") or 0;
	local allIncomingHeal     = UnitGetIncomingHeals(self.displayerUnit or self.unit) or 0;
	local totalAbsorb         = UnitGetTotalAbsorbs(self.displayerUnit or self.unit) or 0;
	local myCurrentHealAbsorb = UnitGetTotalHealAbsorbs(self.displayerUnit or self.unit) or 0;
	
	local realIncomingHeal	  = allIncomingHeal - myCurrentHealAbsorb
	if realIncomingHeal < 0 then realIncomingHeal = 0 end
		
	if myCurrentHealAbsorb > 0 then
		if myCurrentHealAbsorb > health then
			self.health.overHealAbsorbGlow:Show()
			self.health.totalHealAbsorb:SetWidth(health*widthperhp)
		else
			self.health.overHealAbsorbGlow:Hide()
			self.health.totalHealAbsorb:SetWidth(myCurrentHealAbsorb*widthperhp)
		end
		self.health.totalHealAbsorb:Show()
	else
		self.health.overHealAbsorbGlow:Hide()
		self.health.totalHealAbsorb:Hide()
	end
	
	if realIncomingHeal > 0 then
		if realIncomingHeal > maxHealth - health then
			local healLeft = realIncomingHeal
			if realIncomingHeal + health > maxHealth * MAX_INCOMING_HEAL_OVERFLOW then			
				healLeft =  maxHealth * MAX_INCOMING_HEAL_OVERFLOW - health
			end
			
			self.health.totalHealPrediction:SetWidth(healLeft*widthperhp)
			--self.health.totalHealPrediction:SetPoint('LEFT', self.health, 'LEFT', health*widthperhp, 0)
			self.health.totalHealPrediction:SetPoint('LEFT', self.health.statusBarTexture, 'RIGHT', 0, 0)
			self.health.totalHealPrediction:Show()
		else		
			self.health.totalHealPrediction:SetWidth(realIncomingHeal*widthperhp)
			--self.health.totalHealPrediction:SetPoint('LEFT', self.health, 'LEFT', health*widthperhp, 0)
			self.health.totalHealPrediction:SetPoint('LEFT', self.health.statusBarTexture, 'RIGHT', 0, 0)
			self.health.totalHealPrediction:Show()
		end
	else
		self.health.totalHealPrediction:SetWidth(0)
		self.health.totalHealPrediction:Hide()
	end
	
	if totalAbsorb > 0 then
		if ( health + totalAbsorb ) > maxHealth then
			self.health.overAbsorbGlow:Show()
		else
			self.health.overAbsorbGlow:Hide()
		end
		
		local absorbLeft = maxHealth - health - realIncomingHeal
	
		if totalAbsorb < absorbLeft then
			absorbLeft = totalAbsorb
		end
		
		if absorbLeft > 0 then	
			self.health.totalAbsorb:SetWidth(absorbLeft*widthperhp)
		--	self.health.totalAbsorb:SetPoint('LEFT', self.health, 'LEFT', (health+realIncomingHeal)*widthperhp, 0)
			self.health.totalAbsorb:SetPoint('LEFT', self.health.totalHealPrediction:IsShown() and self.health.totalHealPrediction or self.health.statusBarTexture, 'RIGHT', 0, 0)
			self.health.totalAbsorb:Show()
		else
			self.health.totalAbsorb:SetWidth(0)
			self.health.totalAbsorb:Hide()
		end
	else
		self.health.totalAbsorb:Hide()
		self.health.overAbsorbGlow:Hide()
	end
end

local UpdateText

do
	
	local ipairs = ipairs
	local gsub = gsub
	local pairs = pairs
	local gmatch = string.gmatch
	local lastFrame = nil
	
	local function gsubHandler(tag)
		return lastFrame.parent.parent.tag_Cache[tag] or tag
	end
	
	function UpdateText(f)  -- fontstring обновляет данные строки и даннах
	--	local tags = f.tags
	--	print('1', tags)
		
		lastFrame = f
	--	tags = tags:gsub("(%[.-%])", gsubHandler)
		
		--for i=1, #f.taglist do
		--	local tag = f.taglist[i]
		--	tags = gsub(tags, "%"..tag, f.parent.parent.tag_Cache[tag] or '')
		--end
		
	--	print('2', tags)
		
	--	f:SetText(tags)	
		f:SetText(f.tags:gsub("(%[.-%])", gsubHandler))
	end
end
 local countFrames = 0
 
function UF:StatusBar(frame, val, offsetx, offsety)
	countFrames = countFrames + 1
	
	local drawLayer, subLayer = 'ARTWORK', 0
	local f = CreateFrame("StatusBar", "AleaUIStatusBarUF"..countFrames, frame)
	f.parent = frame
	f.val = val
	f:SetStatusBarTexture([[Interface\Buttons\WHITE8x8]])
	
	f.border = CreateFrame("Frame", f:GetName()..'Border', f)
	f.border:SetBackdrop({
	  edgeFile = [[Interface\Buttons\WHITE8x8]],
	  edgeSize = 1, 
	})
	
	if val == "health" then
		drawLayer, subLayer = 'ARTWORK', -1
		
		f.statusBarTexture = f:GetStatusBarTexture()
		f.statusBarTexture:SetDrawLayer(drawLayer, subLayer)
		
		
		local totalHealPrediction = f:CreateTexture()
		totalHealPrediction:SetTexture([[Interface\Buttons\WHITE8x8]])
		totalHealPrediction:SetDrawLayer(drawLayer, subLayer+1)
		totalHealPrediction:SetPoint('LEFT', f, 'LEFT', 0, 0)
		totalHealPrediction:SetVertexColor(0, 1, 0)
		totalHealPrediction:SetWidth(0)
		totalHealPrediction:SetHeight(15)
		
		local totalAbsorb = f:CreateTexture()
		totalAbsorb:SetTexture([[Interface\Buttons\WHITE8x8]])
		totalAbsorb:SetDrawLayer(drawLayer, subLayer+1)
		totalAbsorb:SetPoint('LEFT', f, 'LEFT', 0, 0)
		totalAbsorb:SetVertexColor(0, 190/255, 204/255)
		totalAbsorb:SetWidth(0)
		totalAbsorb:SetHeight(15)
		
		local totalHealAbsorb = f:CreateTexture()
	--	totalHealAbsorb:SetTexture([[Interface\Buttons\WHITE8x8]])	
	--	totalHealAbsorb:SetTexture("Interface\\RaidFrame\\Absorb-Fill", true, true);
		totalHealAbsorb:SetTexture([[Interface\Buttons\WHITE8x8]])
		totalHealAbsorb:SetDrawLayer(drawLayer, subLayer+1)
		totalHealAbsorb:SetPoint('TOPRIGHT', f.statusBarTexture, 'TOPRIGHT', 0, 0)
		totalHealAbsorb:SetPoint('BOTTOMRIGHT', f.statusBarTexture, 'BOTTOMRIGHT', 0, 0)
		totalHealAbsorb:SetVertexColor(255/255, 0, 0, 0.9)
	--	totalHealAbsorb:SetVertexColor(255/255, 74/255, 61/255, 0.15)
		totalHealAbsorb:SetWidth(0)
		totalHealAbsorb:SetHeight(15)
		
		local overAbsorbGlow = f:CreateTexture()
		overAbsorbGlow:SetTexture("Interface\\AddOns\\AleaUI\\media\\glow")
		overAbsorbGlow:SetPoint('TOPRIGHT', f, 'TOPRIGHT', 0, 0)
		overAbsorbGlow:SetPoint('BOTTOMRIGHT', f, 'BOTTOMRIGHT', 0, 0)
		overAbsorbGlow:SetDrawLayer(drawLayer, subLayer+2)
		overAbsorbGlow:SetTexCoord(0, 0.2, 0, 1)
		overAbsorbGlow:SetWidth(12)
		overAbsorbGlow:SetVertexColor(0, 190/255, 204/255)
		
		local overHealAbsorbGlow = f:CreateTexture()
		overHealAbsorbGlow:SetTexture("Interface\\AddOns\\AleaUI\\media\\glow")
		overHealAbsorbGlow:SetPoint('TOPLEFT', f, 'TOPLEFT', 0, 0)
		overHealAbsorbGlow:SetPoint('BOTTOMLEFT', f, 'BOTTOMLEFT', 0, 0)
		overHealAbsorbGlow:SetDrawLayer(drawLayer, subLayer+2)
		overHealAbsorbGlow:SetTexCoord(0.05, 0.25, 0, 1)
		overHealAbsorbGlow:SetWidth(12)
		overHealAbsorbGlow:SetVertexColor(240/255, 16/255, 0)
		
		f.PostSetValue = function(self)
			self.parent:UpdateHealPrediction()
		end
	
		f.totalHealAbsorb = totalHealAbsorb
		f.totalAbsorb = totalAbsorb
		f.totalHealPrediction = totalHealPrediction
		f.overHealAbsorbGlow = overHealAbsorbGlow
		f.overAbsorbGlow = overAbsorbGlow
	end

	local inset = 0
	f.border:SetBackdropBorderColor(0,0,0,1)
	f.border:SetPoint("TOPLEFT", f, "TOPLEFT", inset, -inset)
	f.border:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -inset, inset)
	
	f.border.bg = f:CreateTexture()
	f.border.bg:SetDrawLayer(drawLayer, subLayer-2)
	f.border.bg:SetColorTexture(0, 0, 0, 0)
	f.border.bg:SetPoint("TOPLEFT", f, "TOPLEFT", inset, -inset)
	f.border.bg:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -inset, inset)
	
	local bg = f:CreateTexture()
	bg:SetDrawLayer(drawLayer, subLayer-1)
	bg:SetColorTexture(0, 0, 0, 0)
	bg:SetPoint("TOPLEFT", f:GetStatusBarTexture(), "TOPRIGHT", 0, 0)
	bg:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 0, 0)
	
	f.bg = bg

	local leftText = f.border:CreateFontString(nil, "OVERLAY") --, "GameFontNormal");
	leftText.parent = f
	leftText.val = "leftText"
	
	leftText.tags = frame.taglist[val]["leftText"]
	
	leftText:SetPoint("LEFT", f, "LEFT", offsetx or 0, offsety or 0)	
	leftText:SetTextColor(1,1,1)
	leftText:SetFont("Fonts\\ARIALN.TTF", 11, "OUTLINE")
	leftText:SetShadowColor(0,0,0,1)
	leftText:SetShadowOffset(1,-1)
	leftText:SetAlpha(1)
	leftText:SetJustifyH("LEFT")
	leftText.UpdateText = UpdateText
	f.leftText = leftText
	
	local rightText = f.border:CreateFontString(nil, "OVERLAY") --, "GameFontNormal");
	rightText.parent = f
	rightText.val = "rightText"
	
	rightText.tags = frame.taglist[val]["rightText"]
	
	rightText:SetPoint("RIGHT", f, "RIGHT", offsetx and -offsetx or 0, offsety or 0)	
	rightText:SetTextColor(1,1,1)
	rightText:SetFont("Fonts\\ARIALN.TTF", 11, "OUTLINE")
	rightText:SetShadowColor(0,0,0,1)
	rightText:SetShadowOffset(1,-1)
	rightText:SetAlpha(1)
	rightText:SetJustifyH("RIGHT")
	rightText.UpdateText = UpdateText
	f.rightText = rightText
	
	local centerText = f.border:CreateFontString(nil, "OVERLAY") --, "GameFontNormal");
	centerText.parent = f
	centerText.val = "centerText"
	
	centerText.tags = frame.taglist[val]["centerText"]
	
	centerText:SetPoint("CENTER", f, "CENTER", 0, offsety or 0)
	centerText:SetTextColor(1,1,1)
	centerText:SetFont("Fonts\\ARIALN.TTF", 11, "OUTLINE")
	centerText:SetShadowColor(0,0,0,1)
	centerText:SetShadowOffset(1,-1)
	centerText:SetAlpha(1)
	centerText:SetJustifyH("Center")
	centerText.UpdateText = UpdateText
	f.centerText = centerText
	
	f.UpdateTagText = function(self)
		for fs, tagtext in pairs(self.parent.taglist[self.val]) do		
			self[fs].tags = tagtext
			self[fs]:SetText('')
			self[fs].taglist = {}
			for k in gmatch(tagtext, '%[..-%]+') do
				tinsert(self[fs].taglist, k)
			end
		end
	end
	
	UF.handledFrames[val][f] = true

	return f
end

local unitEvents = {
	["player"] = {
		"PLAYER_ALIVE", 'PLAYER_DEAD',
		"UNIT_HEALTH_FREQUENT",
		"UNIT_POWER_FREQUENT",	
		"UNIT_NAME_UPDATE",
		"UNIT_MAXHEALTH",
		"UNIT_MAXPOWER",
		"UNIT_LEVEL",
		"UNIT_PORTRAIT_UPDATE",
	--	"UNIT_MODEL_CHANGED",
		"UNIT_DISPLAYPOWER",
		"UNIT_HEAL_PREDICTION",
		"UNIT_ABSORB_AMOUNT_CHANGED",
		"UNIT_HEAL_ABSORB_AMOUNT_CHANGED",
		"UNIT_FACTION",
		"UNIT_ENTERED_VEHICLE",
		"UNIT_ENTERING_VEHICLE",
		"UNIT_EXITING_VEHICLE",
		"UNIT_EXITED_VEHICLE",
		"RAID_TARGET_UPDATE",
		"UNIT_TARGETABLE_CHANGED",
		"VEHICLE_UPDATE",
		"UNIT_PHASE",
		"UNIT_OTHER_PARTY_CHANGED",
		"UNIT_FLAGS",
	},
	["boss"] = {
		"UNIT_HEALTH_FREQUENT",
		"UNIT_POWER_UPDATE",	
		"UNIT_NAME_UPDATE",
		"UNIT_MAXHEALTH",
		"UNIT_MAXPOWER",
		"UNIT_LEVEL",
		"UNIT_PORTRAIT_UPDATE",
	--	"UNIT_MODEL_CHANGED",
		"UNIT_DISPLAYPOWER",
		"UNIT_HEAL_PREDICTION",
		"UNIT_ABSORB_AMOUNT_CHANGED",
		"UNIT_HEAL_ABSORB_AMOUNT_CHANGED",
		"UNIT_FACTION",
		"RAID_TARGET_UPDATE",
		"UNIT_TARGETABLE_CHANGED",
		"UNIT_PHASE",
		"UNIT_OTHER_PARTY_CHANGED",
		"UNIT_FLAGS",
	},
	["target"] = {
		"UNIT_HEALTH_FREQUENT",
		"UNIT_POWER_UPDATE",	
		"UNIT_NAME_UPDATE",
		"UNIT_MAXHEALTH",
		"UNIT_MAXPOWER",
		"UNIT_LEVEL",
		"UNIT_PORTRAIT_UPDATE",
	--	"UNIT_MODEL_CHANGED",
		"UNIT_DISPLAYPOWER",
		"UNIT_HEAL_PREDICTION",
		"UNIT_ABSORB_AMOUNT_CHANGED",
		"UNIT_HEAL_ABSORB_AMOUNT_CHANGED",
		"UNIT_FACTION",
		"RAID_TARGET_UPDATE",
		"UNIT_TARGETABLE_CHANGED",
		"UNIT_PHASE",
		"UNIT_OTHER_PARTY_CHANGED",
		"UNIT_FLAGS",
	},
	["arena"] = {
		"UNIT_HEALTH_FREQUENT",
		"UNIT_POWER_UPDATE",	
		"UNIT_NAME_UPDATE",
		"UNIT_MAXHEALTH",
		"UNIT_MAXPOWER",
		"UNIT_LEVEL",
		"UNIT_PORTRAIT_UPDATE",
	--	"UNIT_MODEL_CHANGED",
		"UNIT_DISPLAYPOWER",
		"UNIT_HEAL_PREDICTION",
		"UNIT_ABSORB_AMOUNT_CHANGED",
		"UNIT_HEAL_ABSORB_AMOUNT_CHANGED",
		"UNIT_FACTION",
		"RAID_TARGET_UPDATE",
		"UNIT_TARGETABLE_CHANGED",
		"UNIT_PHASE",
		"UNIT_OTHER_PARTY_CHANGED",
		"UNIT_FLAGS",
	},
	
	["focus"] = {
		"UNIT_HEALTH_FREQUENT",
		"UNIT_POWER_UPDATE",	
		"UNIT_NAME_UPDATE",
		"UNIT_MAXHEALTH",
		"UNIT_MAXPOWER",
		"UNIT_LEVEL",
		"UNIT_PORTRAIT_UPDATE",
	--	"UNIT_MODEL_CHANGED",
		"UNIT_DISPLAYPOWER",
		"UNIT_HEAL_PREDICTION",
		"UNIT_ABSORB_AMOUNT_CHANGED",
		"UNIT_HEAL_ABSORB_AMOUNT_CHANGED",
		"UNIT_FACTION",
		"RAID_TARGET_UPDATE",
		"UNIT_TARGETABLE_CHANGED",
		"UNIT_PHASE",
		"UNIT_OTHER_PARTY_CHANGED",
		"UNIT_FLAGS",
	},
	
	["pet"] = {
		"UNIT_NAME_UPDATE",
		"UNIT_MAXHEALTH",
		"UNIT_HEALTH_FREQUENT",
		"UNIT_POWER_UPDATE",
		"UNIT_PORTRAIT_UPDATE",
	--	"UNIT_MODEL_CHANGED",
		"UNIT_LEVEL",
		"UNIT_HEAL_PREDICTION",
		"UNIT_ABSORB_AMOUNT_CHANGED",
		"UNIT_HEAL_ABSORB_AMOUNT_CHANGED",
		"UNIT_FACTION",
		"UNIT_ENTERED_VEHICLE",
		"UNIT_ENTERING_VEHICLE",
		"UNIT_EXITING_VEHICLE",
		"UNIT_EXITED_VEHICLE",
		"RAID_TARGET_UPDATE",
		"UNIT_TARGETABLE_CHANGED",
		"VEHICLE_UPDATE",
		"UNIT_PHASE",
		"UNIT_OTHER_PARTY_CHANGED",
		"UNIT_FLAGS",
	}
}
do

	local frames = {}
	local trottle = 0.25
	
	
	local function OnUpdate(self, elapsed)
		self.elapsed = ( self.elapsed or 0 ) + elapsed
		if self.elapsed < trottle then return end
		self.elapsed = 0
		
		local hide = true
		
		for frame in pairs(frames) do			
			if frame then
				hide = false
				if UnitExists(frame.displayerUnit or frame.unit) then
					frame:OnUpdate_Update()
				end
			end
		end
		
		if hide then self:Hide() end
	end
	
	local updater = CreateFrame("Frame", "AleaUI-UF-Updater", UIParent)
	updater:Show()
	updater:SetScript("OnUpdate", OnUpdate)
	
	
	function UF:AddOnUpdateEvent(frame)
		frames[frame] = true
		updater:Show()
	end
	
	function UF:AddOnUpdateUnevent(frame)
		frames[frame] = nil	
	end
end

local function SetTextureRotation(texture, rotate)
	local  ulx,uly , llx,lly , urx,ury , lrx,lry
	
	if(rotate == 0 or rotate == 360) then
	   ulx,uly , llx,lly , urx,ury , lrx,lry = 0,0 , 0,1 , 1,0 , 1,1;
	elseif(rotate == 90) then
	   ulx,uly , llx,lly , urx,ury , lrx,lry = 1,0 , 0,0 , 1,1 , 0,1;
	elseif(rotate == 180) then
	   ulx,uly , llx,lly , urx,ury , lrx,lry = 1,1 , 1,0 , 0,1 , 0,0;
	elseif(rotate == 270) then
	   ulx,uly , llx,lly , urx,ury , lrx,lry = 0,1 , 1,1 , 0,0 , 1,0;
	end
	
	texture:SetTexCoord(ulx,uly , llx,lly , urx,ury , lrx,lry);
end

E.SetTextureRotation = SetTextureRotation

local borderoffset = 1

local function UpdateFrameConstruct(f, opts)
	opts = opts or f.opts
	f.opts = opts 
	f:SetSize(opts.width, opts.height)
	
	if opts.border then
	f.border:SetBackdrop({
	  edgeFile = E:GetBorder(opts.border.texture),
	  edgeSize = opts.border.size, 
	})
	f.border:SetBackdropBorderColor(opts.border.color[1],opts.border.color[2],opts.border.color[3],opts.border.color[4])
	f.border:SetPoint("TOPLEFT", f, "TOPLEFT", opts.border.inset, -opts.border.inset)
	f.border:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -opts.border.inset, opts.border.inset)

	local grad = 0
	if opts.border.backgroundRotate == 1 then
		grad = 0
	elseif opts.border.backgroundRotate == 2 then
		grad = 90
	elseif opts.border.backgroundRotate == 3 then
		grad = 180
	elseif opts.border.backgroundRotate == 4 then
		grad = 270
	end
	
	f.border.bg:SetTexture(E:GetTexture(opts.border.background_texture))
	f.border.bg:SetVertexColor(opts.border.background_color[1],opts.border.background_color[2],opts.border.background_color[3],opts.border.background_color[4])
	
	SetTextureRotation(f.border.bg, grad)
	
	f.border.bg:SetPoint("TOPLEFT", f.border, "TOPLEFT", opts.border.background_inset, -opts.border.background_inset)
	f.border.bg:SetPoint("BOTTOMRIGHT", f.border, "BOTTOMRIGHT", -opts.border.background_inset, opts.border.background_inset)
	end
	
	f.health:SetSize(opts.health.width, opts.health.height)
	f.power:SetSize(opts.power.width, opts.power.height)
	f.altpower:SetSize(opts.altpower.width, opts.altpower.height)

	f.health._alpha = opts.health.alpha
	f.health:SetStatusBarTexture(E:GetTexture(opts.health.texture))
	
	f.power._alpha = opts.power.alpha
	f.power:SetStatusBarTexture(E:GetTexture(opts.power.texture))
	
	f.altpower._alpha = opts.altpower.alpha
	f.altpower:SetStatusBarTexture(E:GetTexture(opts.altpower.texture))
	
	f.health:SetFrameLevel(f:GetFrameLevel()+opts.health.level)
	f.power:SetFrameLevel(f:GetFrameLevel()+opts.power.level)
	f.altpower:SetFrameLevel(f:GetFrameLevel()+opts.altpower.level)
	
	E:SetSmoothBar(f.health, E.db.unitframes.smoothBars)
	E:SetSmoothBar(f.power, E.db.unitframes.smoothBars)
	E:SetSmoothBar(f.altpower, E.db.unitframes.smoothBars)
	
	if f.altmanabar then		
		E:SetSmoothBar(f.altmanabar, E.db.unitframes.smoothBars)
		
		f.altmanabar:SetSize(opts.altmanabar.width, opts.altmanabar.height)
		f.altmanabar._alpha = opts.altmanabar.alpha
		f.altmanabar:SetStatusBarTexture(E:GetTexture(opts.altmanabar.texture))
		f.altmanabar:SetFrameLevel(f:GetFrameLevel()+opts.altmanabar.level)
	end
	
	f.health:ClearAllPoints()
	f.health:SetPoint(opts.health.point, f , opts.health.point, opts.health.pos[1], opts.health.pos[2])	
	
	local inset = 0
	if f.health.bg:IsShown() then
	--	inset = 2
	end
	
	f.health.totalHealPrediction:SetTexture(E:GetTexture(opts.health.texture))	
	f.health.totalHealPrediction:SetVertexColor(E.db.unitframes.colors.otherHeal[1], 
		E.db.unitframes.colors.otherHeal[2],E.db.unitframes.colors.otherHeal[3],E.db.unitframes.colors.otherHeal[4])		
	f.health.totalHealPrediction:SetHeight(opts.health.height-inset)
	
	f.health.totalAbsorb:SetTexture(E:GetTexture(opts.health.texture))	
	f.health.totalAbsorb:SetVertexColor(E.db.unitframes.colors.otherAbsorb[1], 
		E.db.unitframes.colors.otherAbsorb[2],E.db.unitframes.colors.otherAbsorb[3],E.db.unitframes.colors.otherAbsorb[4])		
	f.health.totalAbsorb:SetHeight(opts.health.height-inset)
	f.health.overAbsorbGlow:SetVertexColor(E.db.unitframes.colors.otherAbsorb[1], 
		E.db.unitframes.colors.otherAbsorb[2],E.db.unitframes.colors.otherAbsorb[3],E.db.unitframes.colors.otherAbsorb[4])
	
	
	f.health.totalHealAbsorb:SetTexture(E:GetTexture(opts.health.texture))	
	f.health.totalHealAbsorb:SetVertexColor(E.db.unitframes.colors.myHealAbsorb[1], 
		E.db.unitframes.colors.myHealAbsorb[2],E.db.unitframes.colors.myHealAbsorb[3],E.db.unitframes.colors.myHealAbsorb[4])		
	f.health.totalHealAbsorb:SetHeight(opts.health.height-inset)
	
	f.health.overHealAbsorbGlow:SetVertexColor(E.db.unitframes.colors.myHealAbsorb[1], 
		E.db.unitframes.colors.myHealAbsorb[2],E.db.unitframes.colors.myHealAbsorb[3],E.db.unitframes.colors.myHealAbsorb[4])

	
	f.health.leftText:SetFont(E:GetFont(opts.health.text.left.font),opts.health.text.left.fontSize, opts.health.text.left.fontOutline)
	f.health.leftText:ClearAllPoints()
	f.health.leftText:SetPoint(opts.health.text.left.point, f.health, opts.health.text.left.point, opts.health.text.left.pos[1], opts.health.text.left.pos[2])
	f.health.leftText:SetJustifyH(opts.health.text.left.point)
	
	f.health.rightText:SetFont(E:GetFont(opts.health.text.right.font),opts.health.text.right.fontSize, opts.health.text.right.fontOutline)
	f.health.rightText:ClearAllPoints()
	f.health.rightText:SetPoint(opts.health.text.right.point, f.health, opts.health.text.right.point, opts.health.text.right.pos[1], opts.health.text.right.pos[2])
	f.health.rightText:SetJustifyH(opts.health.text.right.point)
	
	f.health.centerText:SetFont(E:GetFont(opts.health.text.center.font),opts.health.text.center.fontSize, opts.health.text.center.fontOutline)
	f.health.centerText:ClearAllPoints()
	f.health.centerText:SetPoint(opts.health.text.center.point, f.health, opts.health.text.center.point, opts.health.text.center.pos[1], opts.health.text.center.pos[2])
	f.health.centerText:SetJustifyH(opts.health.text.center.point)

	if opts.health.border then
	f.health.border:SetBackdrop({
	  edgeFile = E:GetBorder(opts.health.border.texture),
	  edgeSize = opts.health.border.size, 
	})
	f.health.border:SetBackdropBorderColor(opts.health.border.color[1],opts.health.border.color[2],opts.health.border.color[3],opts.health.border.color[4])
	f.health.border:SetPoint("TOPLEFT", f.health, "TOPLEFT", opts.health.border.inset, -opts.health.border.inset)
	f.health.border:SetPoint("BOTTOMRIGHT", f.health, "BOTTOMRIGHT", -opts.health.border.inset, opts.health.border.inset)

	f.health.border.bg:SetTexture(E:GetTexture(opts.health.border.background_texture))
	f.health.border.bg:SetVertexColor(opts.health.border.background_color[1],opts.health.border.background_color[2],opts.health.border.background_color[3],opts.health.border.background_color[4])
	f.health.border.bg:SetPoint("TOPLEFT", f.health.border, "TOPLEFT", opts.health.border.background_inset, -opts.health.border.background_inset)
	f.health.border.bg:SetPoint("BOTTOMRIGHT", f.health.border, "BOTTOMRIGHT", -opts.health.border.background_inset, opts.health.border.background_inset)
	end
	
	
	--	f.health.myHealAbsorb:SetTexture(unpack(E.db.unitframes.colors.myHealAbsorb))
	
	f.power:ClearAllPoints()
	f.power:SetPoint(opts.power.point, f , opts.power.point, opts.power.pos[1], opts.power.pos[2])
	
	f.power.leftText:SetFont(E:GetFont(opts.power.text.left.font),opts.power.text.left.fontSize, opts.power.text.left.fontOutline)
	f.power.leftText:ClearAllPoints()
	f.power.leftText:SetPoint(opts.power.text.left.point, f.power, opts.power.text.left.point, opts.power.text.left.pos[1], opts.power.text.left.pos[2])
	f.power.leftText:SetJustifyH(opts.power.text.left.point)
	
	f.power.rightText:SetFont(E:GetFont(opts.power.text.right.font),opts.power.text.right.fontSize, opts.power.text.right.fontOutline)
	f.power.rightText:ClearAllPoints()
	f.power.rightText:SetPoint(opts.power.text.right.point, f.power, opts.power.text.right.point, opts.power.text.right.pos[1], opts.power.text.right.pos[2])
	f.power.rightText:SetJustifyH(opts.power.text.right.point)
	
	f.power.centerText:SetFont(E:GetFont(opts.power.text.center.font),opts.power.text.center.fontSize, opts.power.text.center.fontOutline)
	f.power.centerText:ClearAllPoints()
	f.power.centerText:SetPoint(opts.power.text.center.point, f.power, opts.power.text.center.point, opts.power.text.center.pos[1], opts.power.text.center.pos[2])
	f.power.centerText:SetJustifyH(opts.power.text.center.point)
	
	if opts.power.border then
	f.power.border:SetBackdrop({
	  edgeFile = E:GetBorder(opts.power.border.texture),
	  edgeSize = opts.power.border.size, 
	})
	f.power.border:SetBackdropBorderColor(opts.power.border.color[1],opts.power.border.color[2],opts.power.border.color[3],opts.power.border.color[4])
	f.power.border:SetPoint("TOPLEFT", f.power, "TOPLEFT", opts.power.border.inset, -opts.power.border.inset)
	f.power.border:SetPoint("BOTTOMRIGHT", f.power, "BOTTOMRIGHT", -opts.power.border.inset, opts.power.border.inset)

	f.power.border.bg:SetTexture(E:GetTexture(opts.power.border.background_texture))
	f.power.border.bg:SetVertexColor(opts.power.border.background_color[1],opts.power.border.background_color[2],opts.power.border.background_color[3],opts.power.border.background_color[4])
	f.power.border.bg:SetPoint("TOPLEFT", f.power.border, "TOPLEFT", opts.power.border.background_inset, -opts.power.border.background_inset)
	f.power.border.bg:SetPoint("BOTTOMRIGHT", f.power.border, "BOTTOMRIGHT", -opts.power.border.background_inset, opts.power.border.background_inset)
	end
	
	f.altpower:ClearAllPoints()
	f.altpower:SetPoint(opts.altpower.point, f , opts.altpower.point, opts.altpower.pos[1], opts.altpower.pos[2])
	
	f.altpower.leftText:SetFont(E:GetFont(opts.altpower.text.left.font),opts.altpower.text.left.fontSize, opts.altpower.text.left.fontOutline)
	f.altpower.leftText:ClearAllPoints()
	f.altpower.leftText:SetPoint(opts.altpower.text.left.point, f.altpower, opts.altpower.text.left.point, opts.altpower.text.left.pos[1], opts.altpower.text.left.pos[2])
	f.altpower.leftText:SetJustifyH(opts.altpower.text.left.point)
	
	f.altpower.rightText:SetFont(E:GetFont(opts.altpower.text.right.font),opts.altpower.text.right.fontSize, opts.altpower.text.right.fontOutline)
	f.altpower.rightText:ClearAllPoints()
	f.altpower.rightText:SetPoint(opts.altpower.text.right.point, f.altpower, opts.altpower.text.right.point, opts.altpower.text.right.pos[1], opts.altpower.text.right.pos[2])
	f.altpower.rightText:SetJustifyH(opts.altpower.text.right.point)
	
	f.altpower.centerText:SetFont(E:GetFont(opts.altpower.text.center.font),opts.altpower.text.center.fontSize, opts.altpower.text.center.fontOutline)
	f.altpower.centerText:ClearAllPoints()
	f.altpower.centerText:SetPoint(opts.altpower.text.center.point, f.altpower, opts.altpower.text.center.point, opts.altpower.text.center.pos[1], opts.altpower.text.center.pos[2])
	f.altpower.centerText:SetJustifyH(opts.altpower.text.center.point)
	
	if opts.altpower.border then
	f.altpower.border:SetBackdrop({
	  edgeFile = E:GetBorder(opts.altpower.border.texture),
	  edgeSize = opts.altpower.border.size, 
	})
	f.altpower.border:SetBackdropBorderColor(opts.altpower.border.color[1],opts.altpower.border.color[2],opts.altpower.border.color[3],opts.altpower.border.color[4])
	f.altpower.border:SetPoint("TOPLEFT", f.altpower, "TOPLEFT", opts.altpower.border.inset, -opts.altpower.border.inset)
	f.altpower.border:SetPoint("BOTTOMRIGHT", f.altpower, "BOTTOMRIGHT", -opts.altpower.border.inset, opts.altpower.border.inset)

	f.altpower.border.bg:SetTexture(E:GetTexture(opts.altpower.border.background_texture))
	f.altpower.border.bg:SetVertexColor(opts.altpower.border.background_color[1],opts.altpower.border.background_color[2],opts.altpower.border.background_color[3],opts.altpower.border.background_color[4])
	f.altpower.border.bg:SetPoint("TOPLEFT", f.altpower.border, "TOPLEFT", opts.altpower.border.background_inset, -opts.altpower.border.background_inset)
	f.altpower.border.bg:SetPoint("BOTTOMRIGHT", f.altpower.border, "BOTTOMRIGHT", -opts.altpower.border.background_inset, opts.altpower.border.background_inset)
	end
	
	if f.altmanabar then		
		f.altmanabar:ClearAllPoints()
		f.altmanabar:SetPoint(opts.altmanabar.point, f , opts.altmanabar.point, opts.altmanabar.pos[1], opts.altmanabar.pos[2])
		
		f.altmanabar.leftText:SetFont(E:GetFont(opts.altmanabar.text.left.font),opts.altmanabar.text.left.fontSize, opts.altmanabar.text.left.fontOutline)
		f.altmanabar.leftText:ClearAllPoints()
		f.altmanabar.leftText:SetPoint(opts.altmanabar.text.left.point, f.altmanabar, opts.altmanabar.text.left.point, opts.altmanabar.text.left.pos[1], opts.altmanabar.text.left.pos[2])
		f.altmanabar.leftText:SetJustifyH(opts.altmanabar.text.left.point)
		
		f.altmanabar.rightText:SetFont(E:GetFont(opts.altmanabar.text.right.font),opts.altmanabar.text.right.fontSize, opts.altmanabar.text.right.fontOutline)
		f.altmanabar.rightText:ClearAllPoints()
		f.altmanabar.rightText:SetPoint(opts.altmanabar.text.right.point, f.altmanabar, opts.altmanabar.text.right.point, opts.altmanabar.text.right.pos[1], opts.altmanabar.text.right.pos[2])
		f.altmanabar.rightText:SetJustifyH(opts.altmanabar.text.right.point)
		
		f.altmanabar.centerText:SetFont(E:GetFont(opts.altmanabar.text.center.font),opts.altmanabar.text.center.fontSize, opts.altmanabar.text.center.fontOutline)
		f.altmanabar.centerText:ClearAllPoints()
		f.altmanabar.centerText:SetPoint(opts.altmanabar.text.center.point, f.altmanabar, opts.altmanabar.text.center.point, opts.altmanabar.text.center.pos[1], opts.altmanabar.text.center.pos[2])
		f.altmanabar.centerText:SetJustifyH(opts.altmanabar.text.center.point)
		
		
		if opts.altmanabar.border then
		f.altmanabar.border:SetBackdrop({
		  edgeFile = E:GetBorder(opts.altmanabar.border.texture),
		  edgeSize = opts.altmanabar.border.size, 
		})
		f.altmanabar.border:SetBackdropBorderColor(opts.altmanabar.border.color[1],opts.altmanabar.border.color[2],opts.altmanabar.border.color[3],opts.altmanabar.border.color[4])
		f.altmanabar.border:SetPoint("TOPLEFT", f.altmanabar, "TOPLEFT", opts.altmanabar.border.inset, -opts.altmanabar.border.inset)
		f.altmanabar.border:SetPoint("BOTTOMRIGHT", f.altmanabar, "BOTTOMRIGHT", -opts.altmanabar.border.inset, opts.altmanabar.border.inset)

		f.altmanabar.border.bg:SetTexture(E:GetTexture(opts.altmanabar.border.background_texture))
		f.altmanabar.border.bg:SetVertexColor(opts.altmanabar.border.background_color[1],opts.altmanabar.border.background_color[2],opts.altmanabar.border.background_color[3],opts.altmanabar.border.background_color[4])
		f.altmanabar.border.bg:SetPoint("TOPLEFT", f.altmanabar.border, "TOPLEFT", opts.altmanabar.border.background_inset, -opts.altmanabar.border.background_inset)
		f.altmanabar.border.bg:SetPoint("BOTTOMRIGHT", f.altmanabar.border, "BOTTOMRIGHT", -opts.altmanabar.border.background_inset, opts.altmanabar.border.background_inset)
		end
	end
	
end

local function UF_OnUpdater1(self, elapsed)	
	local unit = self.parent.displayerUnit or self.parent.unit

	self.elapsed = self.elapsed + elapsed
	self.elapsed1 = ( self.elapsed1 or 0 ) + elapsed
	
	if self.elapsed > 0.25 then
		self.elapsed  = 0
		
		local phazed = UnitInPhase(unit)
		local maxRange = ( E.myclass == 'DRUID' and GetSpecialization() == 1 ) and 45 or 40
		
		if phazed and not UnitIsUnit('player', unit) then
			local range, enemy, r2
		
			if not E.db.unitframes.rangeCheck then
				range, enemy, r2 = GetRange(unit)
			else
				range, enemy, r2 = maxRange, true, maxRange
			end
			
			if range ~= self.range then
				
				self.parent.tag_Cache['[range]'] = tag_function['[range]'](unit, true, range, enemy, r2)
				self.parent:EventTextUpdate("ON_RANGE_CHANGED", unit)
				
				self.range = range
				self.parent.range = range
				self.parent:UNIT_PHASE('UPDATER', unit)
			end
		end
	end
	
	--ON_RANGE_CHANGED
	if self.elapsed1 > 0.1 then
		self.elapsed1 = 0
		
		for tag, t in pairs(tag_OnUpdate) do
			if self.parent.existstags[tag] then
				t.elapsed = ( t.elapsed or 0 ) + elapsed
			
				if t.elapsed > t.trottle then
					t.elapsed = 0				
					self.parent.tag_Cache[tag] = tag_function[tag](unit)

					for i=1, #self.parent.tagToStrings[tag] do						
						self.parent.tagToStrings[tag][i]:UpdateText(unit)
					end
				end
			end
		end
	end
end
do
	local aggroborders = {	
		edgeFile = "Interface\\AddOns\\AleaUI\\media\\glow", 
		edgeSize = 3,
	}

	local function AddAggroBorder(f)
		local aggro = CreateFrame("Frame", nil, f)
		aggro:SetFrameLevel(max(f:GetFrameLevel()-1, 0))
		aggro:SetFrameStrata("LOW")
		aggro:SetBackdrop(aggroborders)		
		aggro:SetBackdropBorderColor(1, 0, 0, 1)
		aggro:SetScale(1)
		aggro:SetPoint("TOPLEFT", f, "TOPLEFT", -3, 3)
		aggro:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 3, -3)	
		aggro:Hide()

		return aggro
	end

	UF.AddAggroBorder = AddAggroBorder
end
--[==[
local function UpdatePowerBarColors(self, unit, power, debugg)
	local normalPower = UnitPowerMax(unit)
	local altpower = UnitPowerMax(unit, E.PowerType.Alternate)
	
	if ( not normalPower or normalPower == 0 ) and ( altpower and altpower > 0 ) then
		local color = UF:PowerColorRGB(unit, E.PowerType.Alternate)
		self.altpower:SetStatusBarColor(0, 0, 0, 0)
		self.altpower.bg:SetTexture(0, 0, 0, 0)
	
		self.power:SetStatusBarColor(color[1],color[2],color[3],color[4])
		self.power.bg:SetTexture(color[1]*0.4, color[2]*0.4, color[3]*0.4, self.power._alpha)
	else
		if power == "ALTERNATE" then
			local color = E.db.unitframes.power_colors["ALTERNATE"]
			if ( altpower and altpower > 0 ) then
				self.altpower:SetStatusBarColor(color[1], color[2], color[3], self.altpower._alpha)
				self.altpower.bg:SetTexture(color[1]*0.4, color[2]*0.4, color[3]*0.4, self.altpower._alpha)			
				
				self.altpower.showed = true
			else
				self.altpower:SetStatusBarColor(0, 0, 0, 0)
				self.altpower.bg:SetTexture(0, 0, 0, 0)
				
				self.altpower.showed = false
			end
		else
			local color = UF:PowerColorRGB(unit)
			self.power:SetStatusBarColor(color[1],color[2],color[3],color[4])
			self.power.bg:SetTexture(color[1]*0.4, color[2]*0.4, color[3]*0.4, self.power._alpha)
		end
	end
	
	print('T', 'UpdatePowerBars', debugg, unit, self.altpower.showed)
end
]==]
local UnitFrameMethods = {}
UnitFrameMethods['UNIT_HEALTH_FREQUENT'] = function (self, event, unit)
	if unit ~= ( self.displayerUnit or self.unit ) then return end
	
	local max = UnitHealthMax(self.displayerUnit or self.unit)
	local cur = UnitHealth(self.displayerUnit or self.unit)

	self.health:SetMinMaxValues(0, max)
	self.health:SetValue(cur)
	
	local color, bgcolor
	
	if E.db.unitframes.reverBarColor then
		color	= E.db.unitframes.colors["hp_background"]
		bgcolor = E.db.unitframes.nameColorByClass and UF.GetClassColor(self.displayerUnit or self.unit) or E.db.unitframes.colors["normal"]
	else
		color   = E.db.unitframes.nameColorByClass and UF.GetClassColor(self.displayerUnit or self.unit) or E.db.unitframes.colors["normal"]
		bgcolor = E.db.unitframes.colors["hp_background"]
	end
	
	if E.db.unitframes.nameColorByValue then
		self.update_color = true
		
		local r, g, b = E:ColorGradient(cur, max, 0.6, 0, 0, 0.6, 0.6, 0, color[1], color[2], color[3])	
		self.health:SetStatusBarColor(r,g,b, self.health._alpha)	
	else
		if self.update_color then
			self.update_color = false
			self.health:SetStatusBarColor(color[1], color[2], color[3], self.health._alpha)	
		end
	end
	
	if self.health.maxHealth ~= max then
		self.health.maxHealth = max
		self:EventTextUpdate("UNIT_MAXHEALTH", self.displayerUnit or self.unit)
	end
	
	self:UNIT_HEAL_PREDICTION(event, self.displayerUnit or self.unit)		
	if event then self:EventTextUpdate(event, self.displayerUnit or self.unit) end
end
UnitFrameMethods['UNIT_HEALTH_FREQUENT'] = UnitFrameMethods.UNIT_HEALTH_FREQUENT
UnitFrameMethods['UNIT_MAXHEALTH'] = UnitFrameMethods.UNIT_HEALTH_FREQUENT
UnitFrameMethods['UNIT_FACTION'] = function (self, event, unit)
	if unit ~= ( self.displayerUnit or self.unit ) then return end
	
	local color, bgcolor
	
	if E.db.unitframes.reverBarColor then
		color	= E.db.unitframes.colors["hp_background"]
		bgcolor = E.db.unitframes.nameColorByClass and UF.GetClassColor(self.displayerUnit or self.unit) or E.db.unitframes.colors["normal"]
	else
		color   = E.db.unitframes.nameColorByClass and UF.GetClassColor(self.displayerUnit or self.unit) or E.db.unitframes.colors["normal"]
		bgcolor = E.db.unitframes.colors["hp_background"]
	end
			
	if not E.db.unitframes.nameColorByValue then
		self.health:SetStatusBarColor(color[1], color[2], color[3], self.health._alpha)	
	end		
	self.health.bg:SetColorTexture(bgcolor[1],bgcolor[2],bgcolor[3], self.health._alpha)		
	if event then self:EventTextUpdate(event, self.displayerUnit or self.unit) end
end
UnitFrameMethods['UNIT_POWER_UPDATE'] = function(self, event, unit)
	if unit ~= ( self.displayerUnit or self.unit ) then return end
	
	local powerType = UnitPowerType(self.displayerUnit or self.unit)
	
	
	if unit == 'player' and self.altmanabar then
		local hasAltManabar = false
		local curBar = UnitPower('player', powerType)
		local manaBar = UnitPower('player', 0)
		
		if curBar ~= manaBar then
			hasAltManabar = true
		end
		
		if hasAltManabar then
		
			local manaBarMax = UnitPowerMax('player', 0)
			
			if manaBarMax == manaBar then
				self.altmanabar:Hide()
			else
				self.altmanabar:Show()
			end
			
			self.altmanabar:SetMinMaxValues(0, manaBarMax or 0)
			self.altmanabar:SetValue(manaBar or 0)
			
			local color = E.db.unitframes.power_colors["MANA"]
			
			if color[1] ~= self.altmanabar._color1 or color[2] ~= self.altmanabar._color2 or color[3] ~= self.altmanabar._color3  then
				self.altmanabar:SetStatusBarColor(color[1], color[2], color[3], self.altmanabar._alpha)
				self.altmanabar.bg:SetColorTexture(color[1]*0.4, color[2]*0.4, color[3]*0.4, self.altmanabar._alpha)
				
				self.altmanabar._color1 = color[1]
				self.altmanabar._color2 = color[2]
				self.altmanabar._color3 = color[3]
			end
		else
			self.altmanabar:Hide()
		end
		
		self.hasAltManabar = hasAltManabar
	end
	
	local normalPower = UnitPowerMax(self.displayerUnit or self.unit, powerType)
	local altpower = UnitPowerMax(self.displayerUnit or self.unit, E.PowerType.Alternate)
	
	local showAltPower = altpower and altpower > 0
	local showPower = normalPower and ( normalPower > 0 or normalPower < 0 )
	
	local status = 0
	
	if showPower and showAltPower then
		status = 3
		
		local curPower = UnitPower(self.displayerUnit or self.unit, powerType)
		local curAltPower = UnitPower(self.displayerUnit or self.unit, E.PowerType.Alternate)
		local barType, minap = UnitAlternatePowerInfo(self.displayerUnit or self.unit)
		
		self.power:SetMinMaxValues(0, normalPower or 0)
		self.power:SetValue(curPower or 0)
		
		self.altpower:SetMinMaxValues(minap or 0 , altpower or 0)
		self.altpower:SetValue(curAltPower)		

		local powercolor = UF:PowerColorRGB(self.displayerUnit or self.unit)
		if powercolor[1] ~= self.power._color1 or 
			powercolor[2] ~= self.power._color2 or 
			powercolor[3] ~= self.power._color3  then
			
			self.power:SetStatusBarColor(powercolor[1],powercolor[2],powercolor[3], self.power._alpha)
			self.power.bg:SetColorTexture(powercolor[1]*0.4, powercolor[2]*0.4, powercolor[3]*0.4, self.power._alpha)
			
			self.power._color1 = powercolor[1]
			self.power._color2 = powercolor[2]
			self.power._color3 = powercolor[3]
		end
		
		local altcolor = E.db.unitframes.power_colors["ALTERNATE"]
		if altcolor[1] ~= self.altpower._color1 or altcolor[2] ~= self.altpower._color2 or altcolor[3] ~= self.altpower._color3  then
		
			self.altpower:SetStatusBarColor(altcolor[1], altcolor[2], altcolor[3], self.altpower._alpha)
			self.altpower.bg:SetColorTexture(altcolor[1]*0.4, altcolor[2]*0.4, altcolor[3]*0.4, self.altpower._alpha)		
			
			self.altpower._color1 = altcolor[1]
			self.altpower._color2 = altcolor[2]
			self.altpower._color3 = altcolor[3]
		end
	elseif showPower and not showAltPower then
		status = 2
		
		local curPower = UnitPower(self.displayerUnit or self.unit, powerType)
		
		self.power:SetMinMaxValues(0, normalPower or 0)
		self.power:SetValue(curPower or 0)
		
		self.altpower:SetMinMaxValues(0,0)
		self.altpower:SetValue(0)
		
		local powercolor = UF:PowerColorRGB(self.displayerUnit or self.unit)
		if powercolor[1] ~= self.power._color1 or 
			powercolor[2] ~= self.power._color2 or 
			powercolor[3] ~= self.power._color3  then
			
			self.power:SetStatusBarColor(powercolor[1],powercolor[2],powercolor[3], self.power._alpha)
			self.power.bg:SetColorTexture(powercolor[1]*0.4, powercolor[2]*0.4, powercolor[3]*0.4, self.power._alpha)
			
			self.power._color1 = powercolor[1]
			self.power._color2 = powercolor[2]
			self.power._color3 = powercolor[3]
		end

		if 0 ~= self.altpower._color1 or 0 ~= self.altpower._color2 or 0 ~= self.altpower._color3  then
		
			self.altpower:SetStatusBarColor(0,0,0,0)
			self.altpower.bg:SetColorTexture(0,0,0,0)			
			
			self.altpower._color1 = 0
			self.altpower._color2 = 0
			self.altpower._color3 = 0
		end		
	elseif not showPower and showAltPower then
		status = 1
		
		local curAltPower = UnitPower(self.displayerUnit or self.unit, E.PowerType.Alternate)
		local barType, minap = UnitAlternatePowerInfo(self.displayerUnit or self.unit)
		
		self.power:SetMinMaxValues(minap or 0, altpower or 0)
		self.power:SetValue(curAltPower or 0)
		
		self.altpower:SetMinMaxValues(0 , 0)
		self.altpower:SetValue(0)
		
		local powercolor = E.db.unitframes.power_colors["ALTERNATE"]
		if powercolor[1] ~= self.power._color1 or 
			powercolor[2] ~= self.power._color2 or 
			powercolor[3] ~= self.power._color3  then
			
			self.power:SetStatusBarColor(powercolor[1],powercolor[2],powercolor[3], self.power._alpha)
			self.power.bg:SetColorTexture(powercolor[1]*0.4, powercolor[2]*0.4, powercolor[3]*0.4, self.power._alpha)
			
			self.power._color1 = powercolor[1]
			self.power._color2 = powercolor[2]
			self.power._color3 = powercolor[3]
		end

		if 0 ~= self.altpower._color1 or 0 ~= self.altpower._color2 or 0 ~= self.altpower._color3  then
		
			self.altpower:SetStatusBarColor(0,0,0,0)
			self.altpower.bg:SetColorTexture(0,0,0,0)			
			
			self.altpower._color1 = 0
			self.altpower._color2 = 0
			self.altpower._color3 = 0
		end
	else
		self.power:SetMinMaxValues(0, 0)
		self.power:SetValue(0)
		
		self.altpower:SetMinMaxValues(0 , 0)
		self.altpower:SetValue(0)
		
		local powercolor = UF:PowerColorRGB(self.displayerUnit or self.unit)
		if powercolor[1] ~= self.power._color1 or 
			powercolor[2] ~= self.power._color2 or 
			powercolor[3] ~= self.power._color3  then
			
			self.power:SetStatusBarColor(powercolor[1],powercolor[2],powercolor[3], self.power._alpha)
			self.power.bg:SetColorTexture(powercolor[1]*0.4, powercolor[2]*0.4, powercolor[3]*0.4, self.power._alpha)
			
			self.power._color1 = powercolor[1]
			self.power._color2 = powercolor[2]
			self.power._color3 = powercolor[3]
		end

		if 0 ~= self.altpower._color1 or 0 ~= self.altpower._color2 or 0 ~= self.altpower._color3  then
		
			self.altpower:SetStatusBarColor(0,0,0,0)
			self.altpower.bg:SetColorTexture(0,0,0,0)			
			
			self.altpower._color1 = 0
			self.altpower._color2 = 0
			self.altpower._color3 = 0
		end
	end		
	
	self:EventTextUpdate('UNIT_POWER_UPDATE', self.displayerUnit or self.unit, powerType)
end
UnitFrameMethods['UNIT_POWER_FREQUENT'] = UnitFrameMethods.UNIT_POWER_UPDATE
UnitFrameMethods['UNIT_MAXPOWER'] = UnitFrameMethods.UNIT_POWER_UPDATE
UnitFrameMethods['UNIT_DISPLAYPOWER'] = function(self, event, unit)
	if unit ~= ( self.displayerUnit or self.unit ) then return end

	self:UNIT_POWER_UPDATE(event, self.displayerUnit or self.unit)
end

UnitFrameMethods['UNIT_POWER_BAR_SHOW'] = UnitFrameMethods.UNIT_POWER_UPDATE
UnitFrameMethods['UNIT_POWER_BAR_HIDE'] = UnitFrameMethods.UNIT_POWER_UPDATE
UnitFrameMethods['UNIT_NAME_UPDATE'] = function(self, event, unit)
	if unit ~= ( self.displayerUnit or self.unit ) then return end	
	if event then self:EventTextUpdate(event, self.displayerUnit or self.unit) end
end
UnitFrameMethods['UNIT_LEVEL'] = function (self, event, unit)
	if unit ~= ( self.displayerUnit or self.unit ) then return end	
	if event then self:EventTextUpdate(event, unit) end
end
UnitFrameMethods['UNIT_MODEL_CHANGED'] = function (self, event, unit)
	if unit ~= ( self.displayerUnit or self.unit ) then return end
	if self.model then self.model:UpdateModel(event, true) end
end
UnitFrameMethods['UNIT_PORTRAIT_UPDATE'] = UnitFrameMethods.UNIT_MODEL_CHANGED
UnitFrameMethods['UNIT_HEAL_PREDICTION'] = function(self, event, unit)
	if unit ~= ( self.displayerUnit or self.unit ) then return end
	UpdateHealPrediction(self)
end	
UnitFrameMethods['UNIT_ABSORB_AMOUNT_CHANGED'] = UnitFrameMethods.UNIT_HEAL_PREDICTION
UnitFrameMethods['UNIT_HEAL_ABSORB_AMOUNT_CHANGED'] = UnitFrameMethods.UNIT_HEAL_PREDICTION
UnitFrameMethods['RAID_TARGET_UPDATE'] = function(self, event, unit) self:UpdateRaidMark() end	
UnitFrameMethods['UNIT_TARGETABLE_CHANGED'] = function (self, event, unit)
	if unit ~= ( self.displayerUnit or self.unit ) then return end
	
	if self.targetable ~= UnitCanAttack("player", self.displayerUnit or self.unit) then	
		self.targetable = UnitCanAttack("player", self.displayerUnit or self.unit)
		self:PostUpdate()
	end
end	
UnitFrameMethods['UNIT_ENTERED_VEHICLE'] = function (self, event, unit, ...)
	
	if UnitHasVehicleUI('player') and not self.displayerUnit then
		if self.unit == 'player' then
			self.displayerUnit = 'vehicle'
		elseif self.unit == 'pet' then
			self.displayerUnit = 'player'
		end

		UF.OnVehicleUpdate(self)
	end
	
--	print(unit, event, self.unit, UnitInVehicleHidesPetFrame(unit))
end
UnitFrameMethods['UNIT_ENTERING_VEHICLE'] = UnitFrameMethods.UNIT_ENTERED_VEHICLE

UnitFrameMethods['UNIT_EXITED_VEHICLE'] = function (self, event, unit, ...) 

	if not UnitHasVehicleUI('player') and self.displayerUnit then
		self.displayerUnit = nil
	
		UF.OnVehicleUpdate(self)
	end

--	print(unit, event, self.unit, UnitInVehicleHidesPetFrame(unit))
end

UnitFrameMethods['UNIT_EXITING_VEHICLE'] = UnitFrameMethods.UNIT_EXITED_VEHICLE
UnitFrameMethods['VEHICLE_UPDATE'] = function(self, event)
--	print(UnitHasVehicleUI('player'),  UnitHasVehiclePlayerFrameUI('player'))
end

UnitFrameMethods['PLAYER_ALIVE'] = function(self, event) self:PostUpdate() end
UnitFrameMethods['PLAYER_DEAD'] = UnitFrameMethods.PLAYER_ALIVE


UnitFrameMethods['UNIT_PHASE'] = function(self, event, unit)
	if unit ~= ( self.displayerUnit or self.unit ) then return end
	
	
	local maxRange = ( E.myclass == 'DRUID' and GetSpecialization() == 1 ) and 45 or 40
	local inPhase =  UnitInPhase(unit)
	local IsFriend = IsFriendly(unit)
	local alpha = 1
	
	if self.check_range then
		if ( not inPhase ) then
			alpha = 0.6
		elseif not IsFriend and not UnitCanAttack('player', unit) then
			alpha = 0.6
		elseif not E.db.unitframes.rangeCheck and ( self.range or maxRange ) > maxRange then
			alpha = 0.6
		end
	end

	
--	print(self.range, alpha, inPhase, IsFriend, unit)
	
	self:SetAlpha(alpha)
	
	if ( not inPhase) then
		self.centerStatusIcon.texture:SetTexture("Interface\\TargetingFrame\\UI-PhasingIcon");
		self.centerStatusIcon.texture:SetTexCoord(0.15625, 0.84375, 0.15625, 0.84375);
		self.centerStatusIcon.border:Show();
		self.centerStatusIcon:Show();
	else
		self.centerStatusIcon:Hide();
	end
end
UnitFrameMethods['UNIT_OTHER_PARTY_CHANGED'] = UnitFrameMethods.UNIT_PHASE
UnitFrameMethods['UNIT_FLAGS'] = UnitFrameMethods.UNIT_PHASE

UnitFrameMethods['OnUpdate_Update'] = function(self)
	local unit = self.displayerUnit or self.unit
	
	self:UNIT_NAME_UPDATE("UNIT_NAME_UPDATE", unit)
	self:UNIT_HEALTH_FREQUENT("UNIT_HEALTH_FREQUENT", unit)
	self:UNIT_HEAL_PREDICTION("UNIT_HEAL_PREDICTION", unit)
	self:UNIT_POWER_UPDATE("UNIT_POWER_UPDATE", unit)
	self:UNIT_FACTION("UNIT_FACTION", unit)
	self:UNIT_PHASE(nil, unit)

	self:ForceUpdateAuras()
end
UnitFrameMethods['PostUpdate'] = function(self)
	local unit = self.displayerUnit or self.unit

	self:OnUpdate_Update()
	
	self:RAID_TARGET_UPDATE()		
	self:EventTextUpdate("POST_UPDATE_FRAME", unit)
	
	if (not E.isClassic) then 
	if self.threat then self:UNIT_THREAT_SITUATION_UPDATE() end
	end
	if self.aggro then self:PLAYER_TARGET_CHANGED() end
	if self.model then self.model:UpdateModel() end
end

local stateMonitor = CreateFrame("Frame", nil, nil, "SecureHandlerBaseTemplate")

function UF.OnVehicleUpdate(self)
	local unit = self.displayerUnit or self.unit
	
	if UnitName(unit) and UnitName(unit) ~= UNKNOWN then
		self:PostUpdate()
	--	print('UF.OnVehicleUpdate Done', 'UnitHasVehicleUI:', UnitHasVehicleUI('player'),  'UnitHasVehiclePlayerFrameUI:', UnitHasVehiclePlayerFrameUI('player'))
	else
		C_Timer.NewTicker(0, function(ticker)
			if UnitHealthMax(unit) and UnitHealthMax(unit) > 0 then
				self:PostUpdate()
				ticker:Cancel()
	--			print('UF.OnVehicleUpdate Update Delay', 'UnitHasVehicleUI:', UnitHasVehicleUI('player'),  'UnitHasVehiclePlayerFrameUI:',UnitHasVehiclePlayerFrameUI('player'))
			--	print('Remove displayerUnit for ', self.unit, UnitName(self.unit))
			end
		end)
	end			
end

local function trueFunction()
	return true;
end

function UF:UnitEvent(frame, unit, check_range)
	frame.check_range = check_range
	
	local rit = frame.health.border:CreateTexture(nil,"OVERLAY", nil, -5)
	rit:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
	rit:SetPoint("TOP", frame, "TOP", 0,5)
	rit:SetSize(22,22)
	rit:Hide()
	
	frame.centerStatusIcon = CreateFrame('Frame', nil, frame.health)
	frame.centerStatusIcon:SetPoint('CENTER', frame, 'CENTER', 0, 0)
	frame.centerStatusIcon:SetSize(22, 22)
	frame.centerStatusIcon:Hide()	
	frame.centerStatusIcon:SetFrameLevel( frame.health:GetFrameLevel()+10 )

	frame.centerStatusIcon.texture = frame.centerStatusIcon:CreateTexture()
	frame.centerStatusIcon.texture:SetDrawLayer('ARTWORK', -2)
	frame.centerStatusIcon.texture:SetAllPoints()
	frame.centerStatusIcon.texture:Show()

	frame.centerStatusIcon.border = frame.centerStatusIcon:CreateTexture()
	frame.centerStatusIcon.border:SetDrawLayer('ARTWORK', -1)
	frame.centerStatusIcon.border:SetAllPoints()
	frame.centerStatusIcon.border:Hide()

	local border = CreateFrame("Frame", nil, frame)
	border:SetBackdrop({
	  edgeFile = [[Interface\Buttons\WHITE8x8]],
	  edgeSize = 1, 
	})
	border:SetBackdropBorderColor(0,0,0,1)
	border:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, -0)
	border:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -0, 0)

	local bg = border:CreateTexture(nil,"BACKGROUND")
	bg:SetColorTexture(0, 0, 0, 0)
	bg:SetPoint("TOPLEFT", border, "TOPLEFT", 0, -0)
	bg:SetPoint("BOTTOMRIGHT", border, "BOTTOMRIGHT", -0, 0)

	frame.border = border
	frame.border.bg = bg

	frame.unit = unit

	frame.raidMark = rit
	frame.UpdateFrameConstruct = UpdateFrameConstruct
	frame.UpdateRaidMark = UpdateRaidMark
	
	frame.EnableTestFrames = UF.EnableTestFrames
	frame.DisableTestFrames = UF.DisableTestFrames
	frame.ToggleTestFrames = UF.ToggleTestFrames
	frame.UpdateHealPrediction = UpdateHealPrediction
	
	frame:SetScript("OnEvent", function(self, event, ...) self[event](self, event, ...) end)

	if unitEvents[unit] or unitEvents[match(unit, "(boss)%d")] or unitEvents[match(unit, "(arena)%d")] then
		for i,event in ipairs(unitEvents[unit] or unitEvents[match(unit, "(boss)%d")] or unitEvents[match(unit, "(arena)%d")]) do
			--frame:RegisterEvent(event, unit)

			xpcall(frame.RegisterEvent, trueFunction, frame, event)
		end
	else
		UF:AddOnUpdateEvent(frame)
	end
	
	frame.tagToStrings = {} 
	frame.getFSbytag = function(self, tag)
		self.tagToStrings[tag] = {}
		for bar, t in pairs(self.taglist) do
			if self[bar] then
				for text, tags in pairs(t) do
					if find(tags, tag) then
						self.tagToStrings[tag][#self.tagToStrings[tag]+1] = self[bar][text]
					end
				end
			end
		end
	end
	
	frame.UpdateExistsTags = function(self)
		self.existstags = {}
		self.existstargs_int = {}
		self.existstargs_int_event = {}
		
		for frame, text in pairs(self.taglist) do
			if self[frame] then
				self[frame]:UpdateTagText()			
				for fs in pairs(text) do
					for i, tagtext in ipairs(self[frame][fs].taglist) do
						self.existstags[tagtext] = true
						self.existstargs_int[#self.existstargs_int+1] = tagtext
						self.existstargs_int_event[tagtext] = {}
						for a=1, select('#', strsplit(' ', tag_OnEvents[tagtext])) do
							local event = select(a, strsplit(' ', tag_OnEvents[tagtext]))
							self.existstargs_int_event[tagtext][event] = true
						end

						self:getFSbytag(tagtext)
					end
				end
			end
		end
	end
	
	frame:UpdateExistsTags()

	frame.tag_Cache = {}
	
	frame.EventTextUpdate = function(self, event, unit)
		for i=1, #self.existstargs_int do	
			local tag = self.existstargs_int[i]
	
			if tag_function[tag] then			
				if self.existstargs_int_event[tag][event] then
					self.tag_Cache[tag] = tag_function[tag](unit)

					for a=1, #self.tagToStrings[tag] do						
						self.tagToStrings[tag][a]:UpdateText(unit)
					end					
				end
			end
		end
	end
	
	countFrames = countFrames + 1
	
	frame._onupdate1 = CreateFrame("Frame", ( frame:GetName() or "AleaUFsFrame"..countFrames).."-Updater1", frame)
	frame._onupdate1.parent = frame
	frame._onupdate1.elapsed = 0
	frame._onupdate1:SetScript("OnUpdate", UF_OnUpdater1)
	
	
	for event, func in pairs(UnitFrameMethods) do
		frame[event] = func
	end
	
	frame:SetFrameStrata('LOW')
	frame:SetFrameLevel(5)
	frame:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	
	frame:SetAttribute('unit', unit)
	frame:SetAttribute("type1", "target")
	frame:SetAttribute("shift-type1", "target")
	frame:SetAttribute("type2", "togglemenu")
		
	if ( unit == 'player' or unit == 'pet' ) and not E.isClassic then		
		stateMonitor:WrapScript(frame, "OnAttributeChanged", [[
			if( name == "state-vehicleupdated" ) then
				if value == 'enable' and UnitHasVehicleUI and UnitHasVehicleUI('player') then
					self:SetAttribute("type1", "macro")
					self:SetAttribute("shift-type1", "macro")
				else
					self:SetAttribute("type1", "target")
					self:SetAttribute("shift-type1", "target")
				end
			elseif name == 'state-visability' then
				if value == 'hide' then
					self:Hide()
				elseif UnitHasVehicleUI and UnitHasVehicleUI('player') then
					self:Show()						
				elseif UnitExists(self:GetAttribute('unit')) then
					self:Show()
				end
			end
		]])
		RegisterStateDriver(frame, "vehicleupdated", ("[@vehicle, exists] enable; hide"))
		RegisterStateDriver(frame, "visability", ("[@vehicle, exists] show1; [@%s, exists] show2; hide"):format(unit))
		frame:SetAttribute("macrotext", "/target "..(unit == 'player' and 'vehicle' or 'player'))
	else
		stateMonitor:WrapScript(frame, "OnAttributeChanged", [[
			if name == 'state-visability' then
				if value == 'show' then
					self:Show()
				else
					self:Hide()
				end
			end
		]])
		RegisterStateDriver(frame, "visability", ("[target=%s, exists] show; hide"):format(unit))
	end
	
	UF.handledFrames['unitframes'][frame] = true
end


do
	
	local facing_reset = math.pi
	local models = 0
	local extended_opts = false
	
	local forceDisable3Dmodels = {
		[118460] = true, -- Engine of Souls, ToS	
	}
	
	local function UpdateModel(frame, event, shouldUpdate)
		if not frame.enabled then return end
		
		local unit = frame.parent.displayerUnit or frame.parent.unit
		local guid = UnitGUID(unit)
	
		local npcID = E.GetNpcID(unit)
		
	--	print(event or "FORCE_UPDATE", frame.parent.unit, UnitIsVisible(frame.parent.unit), UnitIsConnected(frame.parent.unit))
		
		if(not UnitExists(unit) or not UnitIsConnected(unit) or not UnitIsVisible(unit) or forceDisable3Dmodels[npcID] ) then
			frame:SetCamDistanceScale(0.25)
			frame:SetPortraitZoom(0)
			frame:SetPosition(0,0,0.1)
			frame:ClearModel()
			frame:SetModel('interface\\buttons\\talktomequestionmark.m2')
			frame.lastGUID = nil
		elseif frame.lastGUID ~= guid or shouldUpdate then
			frame:SetCamDistanceScale(1)
			frame:SetPortraitZoom(1)
			frame:SetPosition(0,0,0)
			frame:ClearModel()
			frame:SetUnit(unit)
			--[==[
			if extended_opts then
				local x = frame.opts and frame.opts.x or 0
				local y = frame.opts and frame.opts.y or 0
				local z = frame.opts and frame.opts.z or 0
				
				frame:SetPosition(x, y, z)
				
				if frame.opts and frame.opts.facing then
					frame:SetFacing(frame.opts and frame.opts.facing)
				else
					local rotation = 0
					
					if frame:GetFacing() ~= (rotation / 60) then
						frame:SetFacing(rotation / 60)
					end
				end
			else
				frame:SetPosition(0, 0, 0)
			end
			]==]
			
			
			frame.lastGUID = guid
		end
	end
	
	local function Enable(frame)
		frame.enabled = true
		frame:Show()
		UpdateModel(frame)
		frame:SetScript("OnShow", UpdateModel)
	end
	
	local function Disable(frame)
		frame.enabled = true
		frame:Hide()
		frame:SetScript("OnShow", nil)
	end
	
	local function UpdateSettings(frame, opts)
		frame.opts = opts
		frame:ClearAllPoints()
		frame:SetFrameLevel(frame.parent:GetFrameLevel()+opts.level)
		frame:SetAlpha(opts.alpha)		
		frame:SetPoint(opts.point, frame.parent, opts.point, opts.pos[1], opts.pos[2])
		frame:SetSize(opts.width, opts.height)
		
		if opts.showBG then
			frame:SetUIEnabledBackdop()
		else
			frame:SetUIDisabledBackdrop()
		end
		--[==[
		if extended_opts then
			local x = frame.opts and frame.opts.x or 0
			local y = frame.opts and frame.opts.y or 0
			local z = frame.opts and frame.opts.z or 0
			
			frame:SetPosition(x, y, z)
			
			if frame.opts and frame.opts.facing then
				frame:SetFacing(frame.opts and frame.opts.facing)
			else
				local rotation = 0
				
				if frame:GetFacing() ~= (rotation / 60) then
					frame:SetFacing(rotation / 60)
				end
			end
		else
			frame:SetPosition(0, 0, 0)
		end
		]==]
	end
	
	function UF:CreateModel(frame)
		
		models = models + 1
		
		local f = CreateFrame("PlayerModel", 'AleaUFs'..'Model'..models..'Frame', frame)
		f.unit = frame.unit
		f.parent = frame
		f:SetFrameLevel(2)
		f:SetAlpha(0.4)
		f:SetAllPoints(frame)
	--[==[	
		f.bg = f:CreateTexture(nil, 'ARTWORK')
		f.bg:SetPoint('TOPLEFT', f, 'TOPLEFT', -1, 1)
		f.bg:SetPoint('BOTTOMRIGHT', f, 'BOTTOMRIGHT', 1, -1)
		f.bg:SetColorTexture(1,0,0,1)
	]==]
		
		E:CreateBackdrop(f, nil, {0,0,0,1}, {0,0,0,1})
		
		f:SetUIBorderDrawLayer('OVERLAY')	
		f:SetUIBackgroundDrawLayer('ARTWORK')
		
		f.UpdateModel = UpdateModel
		f.Enable = Enable
		f.Disable = Disable
		f.UpdateSettings = UpdateSettings
		
		return f
	end
	
	
	function UF:GetModelSettings(unit, func, dir)
	
		E.GUI.args.unitframes.args[dir].args['ModelGo'] = {
			name = L['Model']..' - '..L['Go'],
			order = 5,
			type = "execute",
			width = 'full',
			set = function()
				AleaUI_GUI:SelectGroup("AleaUI", "unitframes", dir, 'model')
			end,
			get = function()
			
			end,
		}
	
		local t = {
			name = L['Model'],
			order = 16,
		--	embend = true,
			type = 'group',
			args = {
				goback = {
					name = L['Back'],
					order = 0.1,
					type = "execute",
					width = 'full',
					set = function()
						AleaUI_GUI:SelectGroup("AleaUI", "unitframes", dir)
					end,
					get = function()
					
					end,
				},
				enable = {
					name = L['Enable'],
					order = 0.2,
					width = 'full',
					type = 'toggle',
					set = function(info, value)
						E.db.unitframes.unitopts[unit].model.enable = not E.db.unitframes.unitopts[unit].model.enable
						UF[func]()
					end,
					get = function(info)
						return E.db.unitframes.unitopts[unit].model.enable
					end,
				},
				width = {
					name = L['Width'],
					order = 1,
					type = 'slider',
					min = 1, max = 600, step = 1,
					set = function(info, value)
						E.db.unitframes.unitopts[unit].model.width = value
						UF[func]()
					end,
					get = function(info)
						return E.db.unitframes.unitopts[unit].model.width
					end,	
				},
				height = {
					name = L['Height'],
					order = 2,
					type = 'slider',
					min = 1, max = 600, step = 1,
					set = function(info, value)
						E.db.unitframes.unitopts[unit].model.height = value
						UF[func]()
					end,
					get = function(info)
						return E.db.unitframes.unitopts[unit].model.height
					end,	
				},
				xOffset = {
					name = L['Horizontal offset'],
					order = 3,
					type = 'slider',
					min = -600, max = 600, step = 1,
					set = function(info, value)
						E.db.unitframes.unitopts[unit].model.pos[1] = value
						UF[func]()
					end,
					get = function(info)
						return E.db.unitframes.unitopts[unit].model.pos[1]
					end,
				},
				yOffset = {
					name = L['Vertical offset'],
					order = 4,
					type = 'slider',
					min = -600, max = 600, step = 1,
					set = function(info, value)
						E.db.unitframes.unitopts[unit].model.pos[2] = value
						UF[func]()
					end,
					get = function(info)
						return E.db.unitframes.unitopts[unit].model.pos[2]
					end,
				},				
				point = {
					name = L['Fixation point'],
					order = 5,
					type = 'dropdown',
					values = pointDD,
					set = function(info, value)
						E.db.unitframes.unitopts[unit].model.point = value
						UF[func]()
					end,
					get = function(info)
						return E.db.unitframes.unitopts[unit].model.point
					end,

				},
				level = {
					name = L['Frame level'],
					order = 7,
					type = 'slider',
					min = 0, max = 5, step = 1,
					set = function(info, value)
						E.db.unitframes.unitopts[unit].model.level = value
						UF[func]()
					end,
					get = function(info)
						return E.db.unitframes.unitopts[unit].model.level
					end,
				},
				alpha = {
					name = L['Transparency'],
					order = 8,
					type = 'slider',
					min = 0, max = 1, step = 0.1,
					set = function(info, value)
						E.db.unitframes.unitopts[unit].model.alpha = value
						UF[func]()
					end,
					get = function(info)
						return E.db.unitframes.unitopts[unit].model.alpha
					end,
				},				
				showBG = {
					name = L['Show background'],
					order = 9,
					type = 'toggle',
					set = function(info, value)
						E.db.unitframes.unitopts[unit].model.showBG = not E.db.unitframes.unitopts[unit].model.showBG
						UF[func]()
					end,
					get = function(info)
						return E.db.unitframes.unitopts[unit].model.showBG
					end,
				},
			},
		}
		
		if extended_opts then
			t.args.rotate = {
				name = L['Rotation'],
				order = 9,
				type = 'slider',
				min = 0, max = facing_reset*2, step = 0.1,
				set = function(info, value)
					E.db.unitframes.unitopts[unit].model.facing = value
					UF[func]()
				end,
				get = function(info)
					return E.db.unitframes.unitopts[unit].model.facing
				end,
			}
			t.args.zOffset = {
				name = L['Approximation'],
				order = 10,
				type = 'slider',
				min = -1, max = 1, step = 0.1,
				set = function(info, value)
					E.db.unitframes.unitopts[unit].model.z = value
					UF[func]()
				end,
				get = function(info)
					return E.db.unitframes.unitopts[unit].model.z
				end,
			}
			t.args.xOffset = {
				name = L['Horizontal offset'],
				order = 10,
				type = 'slider',
				min = -1, max = 1, step = 0.1,
				set = function(info, value)
					E.db.unitframes.unitopts[unit].model.x = value
					UF[func]()
				end,
				get = function(info)
					return E.db.unitframes.unitopts[unit].model.x
				end,
			}
			t.args.yOffset = {
				name = L['Vertical offset'],
				order = 10,
				type = 'slider',
				min = -1, max = 1, step = 0.1,
				set = function(info, value)
					E.db.unitframes.unitopts[unit].model.y = value
					UF[func]()
				end,
				get = function(info)
					return E.db.unitframes.unitopts[unit].model.y
				end,
			}
		
		end
		
		return t
	end
end

do
	local powerCache = {}
	local defaultColor = { 1, 1, 1 }
	local defaultColorStr = "|cFFFFFFFF"
	local UnitPowerType = UnitPowerType
	local PowerBarColor = PowerBarColor
	
	local function BuildPowerCache(powerToken, r,g,b, reset)	
		if not reset then
			if powerCache[powerToken] then return end
		end
		if not r or not g or not b then return end
		
		
		if r>1 or g>1 or b>1 then 
			r = r/255 
			g = g/255
			b = b/255
		end
		
		powerCache[powerToken] = { color = { r, g, b }, colorStr = colorString(r*255, g*255, b*255) }		
	end
	
	
	for powerToken, data in pairs(PowerBarColor) do
		if powerToken and type(powerToken) == 'string' then
			BuildPowerCache(powerToken, data.r, data.g, data.b, true)	
		end
	end
	
	local function SavePoverColorInfo(name, powerType, powerToken, altR, altG, altB, power, unit)
		AleaUIDB_2 = AleaUIDB_2 or {}
		AleaUIDB_2.aleaUIColors = AleaUIDB_2.aleaUIColors or {}
		if not AleaUIDB_2.aleaUIColors[name] then
			AleaUIDB_2.aleaUIColors[name] = {}
		end
	
		AleaUIDB_2.aleaUIColors[name].powerType = powerType
		AleaUIDB_2.aleaUIColors[name].powerToken = powerToken
		AleaUIDB_2.aleaUIColors[name].altR = altR
		AleaUIDB_2.aleaUIColors[name].altG = altG
		AleaUIDB_2.aleaUIColors[name].altB = altB
		AleaUIDB_2.aleaUIColors[name].unit = UnitName(unit) or unit
		AleaUIDB_2.aleaUIColors[name].power = power		
	end

	function UF:PowerColorRGB(unit, power)
		local powerType, powerToken, altR, altG, altB = UnitPowerType(unit)

		if altR then
			BuildPowerCache(powerToken, altR, altG, altB)
		end
		
		local color = powerCache[powerToken] and powerCache[powerToken].color or powerCache["MANA"].color;
		
		if not altR and power == E.PowerType.Alternate then
			color = powerCache["ALTERNATE"].color
		end

		return color or defaultColor
	end
	
	function UF:PowerColorString(unit, power, powerTokenCustom)
		local powerType, powerToken, altR, altG, altB = UnitPowerType(unit)

		if altR then
			BuildPowerCache(powerToken, altR, altG, altB)
		end
		
		local color = powerCache[powerTokenCustom or powerToken] and powerCache[powerTokenCustom or powerToken].colorStr or powerCache["MANA"].colorStr;
		
		if not altR and power == E.PowerType.Alternate then
			color = powerCache["ALTERNATE"].colorStr
		end

		return color or defaultColorStr
	end
	
	
	function UF:UpdateCustomPowerColors()
		for powerToket, data in pairs(E.db.unitframes.power_colors) do
			BuildPowerCache(powerToket, data[1], data[2], data[3], true)
		end
	end
	
	
	E:OnInit2(UF.UpdateCustomPowerColors)
end

do
	local defaultBackdropColor = { 0, 0, 0, 1 }
	local defaultColor = { 0, 0, 0, 1 }
	
	local storage = {}

	local function SetUIBorderAlpha(self, ...)
		storage[self].al_backdrop:SetAlpha(...)
		storage[self].al_bordertop:SetAlpha(...)
		storage[self].al_borderbottom:SetAlpha(...)
		storage[self].al_borderleft:SetAlpha(...)
		storage[self].al_borderright:SetAlpha(...)
	end
		
	local function SetUIBackgroundColor(self,r,g,b,a)
		storage[self].al_backdrop:SetColorTexture(r,g,b,a)		
	end
	
	local function SetUIBackdropBorderColor(self, r,g,b,a)
		storage[self].al_bordertop:SetColorTexture(r,g,b,a)
		storage[self].al_borderbottom:SetColorTexture(r,g,b,a)
		storage[self].al_borderleft:SetColorTexture(r,g,b,a)
		storage[self].al_borderright:SetColorTexture(r,g,b,a)		
	end
		
	local function SetUIBorderDrawLayer(self, layer, sublayer)
		sublayer = sublayer or 0
		
		storage[self].al_bordertop:SetDrawLayer(layer, sublayer)	
		storage[self].al_borderbottom:SetDrawLayer(layer, sublayer)	
		storage[self].al_borderleft:SetDrawLayer(layer, sublayer)	
		storage[self].al_borderright:SetDrawLayer(layer, sublayer)	
	end
	
	local function SetUIBackgroundDrawLayer(self, layer, sublayer)
		sublayer = sublayer or 0
		
		storage[self].al_backdrop:SetDrawLayer(layer, sublayer)
	end
	
	local function SetUIDisabledBackdrop(self)		
		storage[self].al_bordertop:Hide()
		storage[self].al_borderbottom:Hide()
		storage[self].al_borderleft:Hide()
		storage[self].al_borderright:Hide()
		storage[self].al_backdrop:Hide()
	end
	
	local function SetUIEnabledBackdop(self)
		storage[self].al_bordertop:Show()
		storage[self].al_borderbottom:Show()
		storage[self].al_borderleft:Show()
		storage[self].al_borderright:Show()
		storage[self].al_backdrop:Show()
	end
	
	function E:CreateBackdrop(parent, point, color, backdropcolor, background, size,step)
		point = point or parent
		
		if storage[point] then return point end
		
		local size = size or 1
		local step = step or 0
		
		local backdropcolor = backdropcolor or { 0, 0, 0, 1 }
		local color = color or defaultColor
		
		local noscalemult = size * ( 2 - parent:GetScale()) --* (2-UIParent:GetScale()) * ( 2- parent:GetScale())
		
		local background = background and "BACKGROUND" or "BORDER"
		
		local al_backdrop = parent:CreateTexture(nil, background)
		al_backdrop:SetSnapToPixelGrid(false)
		al_backdrop:SetTexelSnappingBias(0)
		al_backdrop:SetDrawLayer(background, -4)
		al_backdrop:SetAllPoints(point)
		al_backdrop:SetColorTexture(unpack(backdropcolor))		

		local al_bordertop = parent:CreateTexture(nil, "BORDER")
		al_bordertop:SetSnapToPixelGrid(false)
		al_bordertop:SetTexelSnappingBias(0)
		al_bordertop:SetPoint("TOPRIGHT",point,"TOPLEFT",0,noscalemult+step)
		al_bordertop:SetPoint("BOTTOMRIGHT",point,"BOTTOMLEFT",0,-noscalemult-step)	
		al_bordertop:SetSize(noscalemult,noscalemult)		
		al_bordertop:SetColorTexture(unpack(color))	
		al_bordertop:SetDrawLayer("BORDER", 1)
			
		local al_borderbottom = parent:CreateTexture(nil, "BORDER")
		al_borderbottom:SetSnapToPixelGrid(false)
		al_borderbottom:SetTexelSnappingBias(0)
		al_borderbottom:SetPoint("BOTTOMRIGHT",point,"TOPRIGHT",noscalemult+step,0)
		al_borderbottom:SetPoint("BOTTOMLEFT",point,"TOPLEFT",-noscalemult-step,0)
		al_borderbottom:SetSize(noscalemult,noscalemult)
		al_borderbottom:SetColorTexture(unpack(color))	
		al_borderbottom:SetDrawLayer("BORDER", 1)
			
		local al_borderleft = parent:CreateTexture(nil, "BORDER")
		al_borderleft:SetSnapToPixelGrid(false)
		al_borderleft:SetTexelSnappingBias(0)
		al_borderleft:SetPoint("TOPLEFT",point,"TOPRIGHT",0,noscalemult+step)
		al_borderleft:SetPoint("BOTTOMLEFT",point,"BOTTOMRIGHT",0,-noscalemult-step)
		al_borderleft:SetSize(noscalemult,noscalemult)
		al_borderleft:SetColorTexture(unpack(color))	
		al_borderleft:SetDrawLayer("BORDER", 1)
			
		local al_borderright = parent:CreateTexture(nil, "BORDER")
		al_borderright:SetSnapToPixelGrid(false)
		al_borderright:SetTexelSnappingBias(0)
		al_borderright:SetPoint("TOPRIGHT",point,"BOTTOMRIGHT",noscalemult+step,0)
		al_borderright:SetPoint("TOPLEFT",point,"BOTTOMLEFT",-noscalemult-step,0)
		al_borderright:SetSize(noscalemult,noscalemult)
		al_borderright:SetColorTexture(unpack(color))
		al_borderright:SetDrawLayer("BORDER", 1)	
		
		point.SetUIBorderAlpha = SetUIBorderAlpha	
		point.SetUIBorderDrawLayer = SetUIBorderDrawLayer	

		point.SetUIBackgroundColor = SetUIBackgroundColor		
		point.SetUIBackdropBorderColor = SetUIBackdropBorderColor		
		point.SetUIBackgroundDrawLayer = SetUIBackgroundDrawLayer	
		point.SetUIDisabledBackdrop = SetUIDisabledBackdrop
		point.SetUIEnabledBackdop = SetUIEnabledBackdop
		
		storage[point] = {
			al_backdrop = al_backdrop,
			al_bordertop = al_bordertop,
			al_borderbottom = al_borderbottom,
			al_borderleft = al_borderleft,
			al_borderright = al_borderright,
		}

		return point
	end
	
	local secures = {}
	function E:SecureCreateBackdrop(parent, point, root, color, backdropcolor, background, size,step)
		point = point or parent
		
		if not secures[point] then
			secures[point] = root or {}
			
			local size = size or 1
			local step = step or 0
			
			local backdropcolor = backdropcolor or { 0, 0, 0, 1 }
			local color = color or defaultColor
			
			local noscalemult = size * ( 2 - parent:GetScale()) --* (2-UIParent:GetScale()) * ( 2- parent:GetScale())
			
			local background = background and "BACKGROUND" or "BORDER"
			
			local al_backdrop = parent:CreateTexture(nil, background)
			al_backdrop:SetSnapToPixelGrid(false)
			al_backdrop:SetTexelSnappingBias(0)	
			al_backdrop:SetDrawLayer(background, -4)
			al_backdrop:SetAllPoints(point)
			al_backdrop:SetColorTexture(unpack(backdropcolor))		

			local al_bordertop = parent:CreateTexture(nil, "BORDER")
			al_bordertop:SetSnapToPixelGrid(false)
			al_bordertop:SetTexelSnappingBias(0)
			al_bordertop:SetPoint("TOPRIGHT",point,"TOPLEFT",0,noscalemult+step)
			al_bordertop:SetPoint("BOTTOMRIGHT",point,"BOTTOMLEFT",0,-noscalemult-step)	
			al_bordertop:SetSize(noscalemult,noscalemult)		
			al_bordertop:SetColorTexture(unpack(color))	
			al_bordertop:SetDrawLayer("BORDER", 1)
				
			local al_borderbottom = parent:CreateTexture(nil, "BORDER")
			al_borderbottom:SetSnapToPixelGrid(false)
			al_borderbottom:SetTexelSnappingBias(0)		
			al_borderbottom:SetPoint("BOTTOMRIGHT",point,"TOPRIGHT",noscalemult+step,0)
			al_borderbottom:SetPoint("BOTTOMLEFT",point,"TOPLEFT",-noscalemult-step,0)
			al_borderbottom:SetSize(noscalemult,noscalemult)
			al_borderbottom:SetColorTexture(unpack(color))	
			al_borderbottom:SetDrawLayer("BORDER", 1)
				
			local al_borderleft = parent:CreateTexture(nil, "BORDER")
			al_borderleft:SetSnapToPixelGrid(false)
			al_borderleft:SetTexelSnappingBias(0)
			al_borderleft:SetPoint("TOPLEFT",point,"TOPRIGHT",0,noscalemult+step)
			al_borderleft:SetPoint("BOTTOMLEFT",point,"BOTTOMRIGHT",0,-noscalemult-step)
			al_borderleft:SetSize(noscalemult,noscalemult)
			al_borderleft:SetColorTexture(unpack(color))	
			al_borderleft:SetDrawLayer("BORDER", 1)
				
			local al_borderright = parent:CreateTexture(nil, "BORDER")
			al_borderright:SetSnapToPixelGrid(false)
			al_borderright:SetTexelSnappingBias(0)
			al_borderright:SetPoint("TOPRIGHT",point,"BOTTOMRIGHT",noscalemult+step,0)
			al_borderright:SetPoint("TOPLEFT",point,"BOTTOMLEFT",-noscalemult-step,0)
			al_borderright:SetSize(noscalemult,noscalemult)
			al_borderright:SetColorTexture(unpack(color))
			al_borderright:SetDrawLayer("BORDER", 1)	
			
			root.SetUIBorderAlpha = SetUIBorderAlpha	
			root.SetUIBackgroundColor = SetUIBackgroundColor		
			root.SetUIBackdropBorderColor = SetUIBackdropBorderColor		
			root.SetUIBorderDrawLayer = SetUIBorderDrawLayer	
			root.SetUIBackgroundDrawLayer = SetUIBackgroundDrawLayer	
			root.SetUIDisabledBackdrop = SetUIDisabledBackdrop
			root.SetUIEnabledBackdop = SetUIEnabledBackdop		

			storage[root] = {
				al_backdrop = al_backdrop,
				al_bordertop = al_bordertop,
				al_borderbottom = al_borderbottom,
				al_borderleft = al_borderleft,
				al_borderright = al_borderright,
			}

		end
		
		return secures[point]
	end
end

do

	local char
	local string_byte = string.byte
	local sub = sub
	
	local function chsize(char)
		if not char then
			return 0
		elseif char > 240 then
			return 4
		elseif char > 225 then
			return 3
		elseif char > 192 then
			return 2
		else
			return 1
		end
	end

	function E:utf8sub(str, startChar, numChars)
	  if not str then return "" end
	  local startIndex = 1
	  while startChar > 1 do
		  local char = string_byte(str, startIndex)
		  startIndex = startIndex + chsize(char)
		  startChar = startChar - 1
	  end
	 
	  local currentIndex = startIndex
	 
	  while numChars > 0 and currentIndex <= #str do
		local char = string_byte(str, currentIndex)
		currentIndex = currentIndex + chsize(char)
		numChars = numChars -1
	  end
	  return str:sub(startIndex, currentIndex - 1)
	end
end	

do
	local SpellIsKnown = SpellIsKnown
	function E:CheckLevelBonus(spellID)		
		return IsSpellKnown(spellID)
	end
end

do
	local unitFrameOptsCount = 1
	local tempOptsCount = 1
	
	local playerFrameElements = {	
		healthBar = {
			name = L['Health bar'],
			value = 'health',
		},
		powerBar = {
			name = L['Power bar'],
			value = 'power',
		},
		altpowerBar = {
			name = L['Alternative power bar'],
			value = 'altpower',
		},
		altmanaBar = {
			name = L['Mana bar'],
			value = 'altmanabar',
		},
	}
	
	local unitFrameElements = {	
		healthBar = {
			name = L['Health bar'],
			value = 'health',
		},
		powerBar = {
			name = L['Power bar'],
			value = 'power',
		},
		altpowerBar = {
			name = L['Alternative power bar'],
			value = 'altpower',
		},
	}
	
	local perBarElements = {
		leftText = {
			name = L['Left text'],
			value = 'left',
		},
		rightText = {
			name = L['Right text'],
			value = 'right',
		},
		centerText = {
			name = L['Center text'],
			value = 'center',
		},
	}
	
	local function CopySettings(to, from)
		
		to.width = from.width
		to.height = from.height

		for line, data in pairs(to.tags_list) do
			if from.tags_list[line] then
				to.tags_list[line] = E.deepcopy(from.tags_list[line])
			end
		end
		
		to.border = E.deepcopy(from.border)
		to.health = E.deepcopy(from.health)
		to.power = E.deepcopy(from.power)
		to.altpower = E.deepcopy(from.altpower)
		if from.altmanabar and to.altmanabar then
			to.altmanabar = E.deepcopy(from.altmanabar)
		end
		to.model = E.deepcopy(from.model)
		to.buff = E.deepcopy(from.buff)
		to.debuff = E.deepcopy(from.debuff)
		to.castBar = E.deepcopy(from.castBar)
	end
	
	local funcStyleList = {}
	
	function UF:UpdatFrameStyle(func)	
		if func then
			if funcStyleList[func] then
				UF[func]()
			end
		else
			for f in pairs(funcStyleList) do
				UF[f]()
			end
		end
	end

	function UF:GetUnitFrameOptions(unit, func, unlockname, guiName, testFrames)
	
		funcStyleList[func] = true
		
		tempOptsCount = 1
		local t = {
			name = "Temp",
			order = unitFrameOptsCount,
			expand = false,
			type = "group",
			hidden = true,
			args = {}
		}
		
		unitFrameOptsCount = unitFrameOptsCount + 1
		
		t.args['BorderGo'] = {
			name = L['Border']..' - '..L['Go'],
			order = -1,
			type = "execute",
			width = 'full',
			set = function()
				AleaUI_GUI:SelectGroup("AleaUI", "unitframes", guiName, 'BorderOpts')
			end,
			get = function()
			
			end,
		}
		
		
		t.args.BorderOpts = {
			name = L['Border'],
			order = 10,
			embend = false,
			type = "group",
			args = {}
		}
		
		t.args.BorderOpts.args.goback = {
			name = L['Back'],
			order = 0.1,
			type = "execute",
			width = 'full',
			set = function()
				AleaUI_GUI:SelectGroup("AleaUI", "unitframes", guiName)
			end,
			get = function()
			
			end,
		}

		t.args.BorderOpts.args.BorderTexture = {
			order = 1,
			type = 'border',
			name = L['Border texture'],
			values = E:GetBorderList(),
			set = function(info,value) 
				E.db.unitframes.unitopts[unit].border.texture = value;
				UF[func]()
			end,
			get = function(info) return E.db.unitframes.unitopts[unit].border.texture end,
		}

		t.args.BorderOpts.args.BorderColor = {
			order = 2,
			name = L['Border color'],
			type = "color", 
			hasAlpha = true,
			set = function(info,r,g,b,a) 
				E.db.unitframes.unitopts[unit].border.color={ r, g, b, a}; 
				UF[func]()
			end,
			get = function(info) 
				return E.db.unitframes.unitopts[unit].border.color[1],
						E.db.unitframes.unitopts[unit].border.color[2],
						E.db.unitframes.unitopts[unit].border.color[3],
						E.db.unitframes.unitopts[unit].border.color[4] 
			end,
		}

		t.args.BorderOpts.args.BorderSize = {
			name = L['Border size'],
			type = "slider",
			order	= 3,
			min		= 1,
			max		= 32,
			step	= 1,
			set = function(info,val) 
				E.db.unitframes.unitopts[unit].border.size = val
				UF[func]()
			end,
			get =function(info)
				return E.db.unitframes.unitopts[unit].border.size
			end,
		}

		t.args.BorderOpts.args.BorderInset = {
			name = L['Border inset'],
			type = "slider",
			order	= 4,
			min		= -32,
			max		= 32,
			step	= 1,
			set = function(info,val) 
				E.db.unitframes.unitopts[unit].border.inset = val
				UF[func]()
			end,
			get =function(info)
				return E.db.unitframes.unitopts[unit].border.inset
			end,
		}


		t.args.BorderOpts.args.BackgroundTexture = {
			order = 5,
			type = 'statusbar',
			name = L['Background texture'],
			values = E.GetTextureList,
			set = function(info,value) 
				E.db.unitframes.unitopts[unit].border.background_texture = value;
				UF[func]()
			end,
			get = function(info) return E.db.unitframes.unitopts[unit].border.background_texture end,
		}

		t.args.BorderOpts.args.BackgroundColor = {
			order = 6,
			name = L['Background color'],
			type = "color", 
			hasAlpha = true,
			set = function(info,r,g,b,a) 
				E.db.unitframes.unitopts[unit].border.background_color={ r, g, b, a}
				UF[func]()
			end,
			get = function(info) 
				return E.db.unitframes.unitopts[unit].border.background_color[1],
						E.db.unitframes.unitopts[unit].border.background_color[2],
						E.db.unitframes.unitopts[unit].border.background_color[3],
						E.db.unitframes.unitopts[unit].border.background_color[4] 
			end,
		}


		t.args.BorderOpts.args.backgroundInset = {
			name = L['Background inset'],
			type = "slider",
			order	= 7,
			min		= -32,
			max		= 32,
			step	= 1,
			set = function(info,val) 
				E.db.unitframes.unitopts[unit].border.background_inset = val
				UF[func]()
			end,
			get =function(info)
				return E.db.unitframes.unitopts[unit].border.background_inset
			end,
		}
		
		t.args.BorderOpts.args.backgroundRotate = {
			name = L['Background rotation'],
			type = "slider",
			order	= 8,
			min		= 1,
			max		= 4,
			step	= 1,
			set = function(info,val) 
				E.db.unitframes.unitopts[unit].border.backgroundRotate = val
				UF[func]()
			end,
			get =function(info)
				return E.db.unitframes.unitopts[unit].border.backgroundRotate
			end,
		}
			
		
		t.args.mainOpts = {
			name = L['General'],
			order = 1,
			embend = true,
			type = "group",
			args = {}
		}
		
		t.args.mainOpts.args.unlock = {
			name = L['Unlock'],
			order = 1,
			type = "execute",
			set = function(self, value)	E:UnlockMover(unlockname) end,
			get = function(self)end
		}
		
		if testFrames then
		t.args.mainOpts.args.testFrames = {
			name = L['Test'],
			order = 1.1,
			type = "execute",
			set = function(self, value)	UF[testFrames]() end,
			get = function(self)end
		}
		end
		
		t.args.mainOpts.args.width = {
			name = L['Clickable width'], desc = L['Clickable width desc'],
			order = 2,
			type = 'slider',
			min = 1, max = 600, step = 1,
			set = function(info, value)
				E.db.unitframes.unitopts[unit].width = value
				UF[func]()
			end,
			get = function(info)
				return E.db.unitframes.unitopts[unit].width
			end,	
		}
		t.args.mainOpts.args.height = {
			name = L['Clickable height'], desc = L['Clickable height desc'],
			order = 3,
			type = 'slider',
			min = 1, max = 600, step = 1,
			set = function(info, value)
				E.db.unitframes.unitopts[unit].height = value
				UF[func]()
			end,
			get = function(info)
				return E.db.unitframes.unitopts[unit].height
			end,	
		}
		
		t.args.mainOpts.args.copySettings = {
			name = L['Copy settings from:'],
			order = 5,
			type = 'dropdown', width = 'full',
			values = function()
				local t = {}		
				for k,v in pairs( E.db.unitframes.unitopts ) do
					t[k] = k
				end			
				return t
			end,
			set = function(info, value)
				CopySettings(E.db.unitframes.unitopts[unit], E.db.unitframes.unitopts[value])
				UF[func]()
			end,
			get = function(info)
				return
			end,
		
		}
		if unit == 'bosses' or unit == 'arenas' then
			t.args.mainOpts.args.copySettings.width = nil
			
			t.args.mainOpts.args.growUp = {
				name = L['Grow Up'],
				order = 6,
				type = 'toggle',
				set = function(info, value)
					E.db.unitframes.unitopts[unit].growup = not E.db.unitframes.unitopts[unit].growup
					UF[func]()
				end,
				get = function(info)
					return E.db.unitframes.unitopts[unit].growup
				end,	
			}
			
		end
		
		tempOptsCount = tempOptsCount + 1
		--AleaUI_GUI:SelectGroup("RcdV3", "SpellList")
		for root, data in pairs( ( ( E:HasAltManaBar() and unit == 'player' ) and playerFrameElements or unitFrameElements ) ) do
			
			t.args[root..'Go'] = {
				name = data.name..' - '..L['Go'],
				order = tempOptsCount,
				type = "execute",
				width = 'full',
				set = function()
					AleaUI_GUI:SelectGroup("AleaUI", "unitframes", guiName, root)
				end,
				get = function()
				
				end,
			}
			
			t.args[root] = {
				name = data.name,
				order = tempOptsCount,
				type = "group",
				args = {
					
					goback = {
						name = L['Back'],
						order = 0.1,
						type = "execute",
						width = 'full',
						set = function()
							AleaUI_GUI:SelectGroup("AleaUI", "unitframes", guiName)
						end,
						get = function()
						
						end,
					},
			
					width = {
						name = L['Width'],
						order = 1,
						type = 'slider',
						min = 1, max = 600, step = 1,
						set = function(info, value)
							E.db.unitframes.unitopts[unit][data.value].width = value
							UF[func]()
						end,
						get = function(info)
							return E.db.unitframes.unitopts[unit][data.value].width
						end,	
					},
					height = {
						name = L['Height'],
						order = 2,
						type = 'slider',
						min = 1, max = 600, step = 1,
						set = function(info, value)
							E.db.unitframes.unitopts[unit][data.value].height = value
							UF[func]()
						end,
						get = function(info)
							return E.db.unitframes.unitopts[unit][data.value].height
						end,	
					},
					xOffset = {
						name = L['Horizontal offset'],
						order = 3,
						type = 'slider',
						min = -600, max = 600, step = 1,
						set = function(info, value)
							E.db.unitframes.unitopts[unit][data.value].pos[1] = value
							UF[func]()
						end,
						get = function(info)
							return E.db.unitframes.unitopts[unit][data.value].pos[1]
						end,
					},
					yOffset = {
						name = L['Vertical offset'],
						order = 4,
						type = 'slider',
						min = -600, max = 600, step = 1,
						set = function(info, value)
							E.db.unitframes.unitopts[unit][data.value].pos[2] = value
							UF[func]()
						end,
						get = function(info)
							return E.db.unitframes.unitopts[unit][data.value].pos[2]
						end,
					},				
					point = {
						name = L['Fixation point'],
						order = 5,
						type = 'dropdown',
						values = pointDD,
						set = function(info, value)
							E.db.unitframes.unitopts[unit][data.value].point = value
							UF[func]()
						end,
						get = function(info)
							return E.db.unitframes.unitopts[unit][data.value].point
						end,
					
					},					
					texture = {	
						name = L['Texture'],
						order = 6,
						type = "statusbar",
						values = E.GetTextureList,
						set = function(self, value)
							E.db.unitframes.unitopts[unit][data.value].texture = value
							UF[func]()
						end,
						get = function(self)
							return E.db.unitframes.unitopts[unit][data.value].texture
						end,
					},
					level = {
						name = L['Frame level'],
						order = 7,
						type = 'slider',
						min = 0, max = 5, step = 1,
						set = function(info, value)
							E.db.unitframes.unitopts[unit][data.value].level = value
							UF[func]()
						end,
						get = function(info)
							return E.db.unitframes.unitopts[unit][data.value].level
						end,
					},
					alpha = {
						name = L['Transparency'],
						order = 8,
						type = 'slider',
						min = 0, max = 1, step = 0.1,
						set = function(info, value)
							E.db.unitframes.unitopts[unit][data.value].alpha = value
							UF[func]()
						end,
						get = function(info)
							return E.db.unitframes.unitopts[unit][data.value].alpha
						end,	
					}
				}
			}
			
			t.args[root].args.BorderOpts = {
				name = L['Borders'],
				order = 9,
				embend = true,
				type = "group",
				args = {}
			}
			
			t.args[root].args.BorderOpts.args.BorderTexture = {
				order = 1,
				type = 'border',
				name = L['Border texture'],
				values = E:GetBorderList(),
				set = function(info,value) 
					E.db.unitframes.unitopts[unit][data.value].border.texture = value;
					UF[func]()
				end,
				get = function(info) return E.db.unitframes.unitopts[unit][data.value].border.texture end,
			}

			t.args[root].args.BorderOpts.args.BorderColor = {
				order = 2,
				name = L['Border color'],
				type = "color", 
				hasAlpha = true,
				set = function(info,r,g,b,a) 
					E.db.unitframes.unitopts[unit][data.value].border.color={ r, g, b, a}; 
					UF[func]()
				end,
				get = function(info) 
					return E.db.unitframes.unitopts[unit][data.value].border.color[1],
							E.db.unitframes.unitopts[unit][data.value].border.color[2],
							E.db.unitframes.unitopts[unit][data.value].border.color[3],
							E.db.unitframes.unitopts[unit][data.value].border.color[4] 
				end,
			}

			t.args[root].args.BorderOpts.args.BorderSize = {
				name = L['Border size'],
				type = "slider",
				order	= 3,
				min		= 1,
				max		= 32,
				step	= 1,
				set = function(info,val) 
					E.db.unitframes.unitopts[unit][data.value].border.size = val
					UF[func]()
				end,
				get =function(info)
					return E.db.unitframes.unitopts[unit][data.value].border.size
				end,
			}

			t.args[root].args.BorderOpts.args.BorderInset = {
				name = L['Border inset'],
				type = "slider",
				order	= 4,
				min		= -32,
				max		= 32,
				step	= 1,
				set = function(info,val) 
					E.db.unitframes.unitopts[unit][data.value].border.inset = val
					UF[func]()
				end,
				get =function(info)
					return E.db.unitframes.unitopts[unit][data.value].border.inset
				end,
			}


			t.args[root].args.BorderOpts.args.BackgroundTexture = {
				order = 5,
				type = 'statusbar',
				name = L['Background texture'],
				values = E.GetTextureList,
				set = function(info,value) 
					E.db.unitframes.unitopts[unit][data.value].border.background_texture = value;
					UF[func]()
				end,
				get = function(info) return E.db.unitframes.unitopts[unit][data.value].border.background_texture end,
			}

			t.args[root].args.BorderOpts.args.BackgroundColor = {
				order = 6,
				name = L['Background color'],
				type = "color", 
				hasAlpha = true,
				set = function(info,r,g,b,a) 
					E.db.unitframes.unitopts[unit][data.value].border.background_color={ r, g, b, a}
					UF[func]()
				end,
				get = function(info) 
					return E.db.unitframes.unitopts[unit][data.value].border.background_color[1],
							E.db.unitframes.unitopts[unit][data.value].border.background_color[2],
							E.db.unitframes.unitopts[unit][data.value].border.background_color[3],
							E.db.unitframes.unitopts[unit][data.value].border.background_color[4] 
				end,
			}


			t.args[root].args.BorderOpts.args.backgroundInset = {
				name = L['Background inset'],
				type = "slider",
				order	= 7,
				min		= -32,
				max		= 32,
				step	= 1,
				set = function(info,val) 
					E.db.unitframes.unitopts[unit][data.value].border.background_inset = val
					UF[func]()
				end,
				get =function(info)
					return E.db.unitframes.unitopts[unit][data.value].border.background_inset
				end,
			}

			for dir, data2 in pairs(perBarElements) do
				t.args[root].args[dir] = {				
					name = data2.name,
					order = 10,
					embend = true,
					type = "group",
					args = {
						xOffset = {
							name = L['Horizontal offset'],
							order = 3,
							type = 'slider',
							min = -600, max = 600, step = 1,
							set = function(info, value)
								E.db.unitframes.unitopts[unit][data.value].text[data2.value].pos[1] = value
								UF[func]()
							end,
							get = function(info)
								return E.db.unitframes.unitopts[unit][data.value].text[data2.value].pos[1]
							end,
						},
						yOffset = {
							name = L['Vertical offset'],
							order = 4,
							type = 'slider',
							min = -600, max = 600, step = 1,
							set = function(info, value)
								E.db.unitframes.unitopts[unit][data.value].text[data2.value].pos[2] = value
								UF[func]()
							end,
							get = function(info)
								return E.db.unitframes.unitopts[unit][data.value].text[data2.value].pos[2]
							end,
						},				
						point = {
							name = L['Fixation point'],
							order = 5,
							type = 'dropdown',
							values = pointDD,
							set = function(info, value)
								E.db.unitframes.unitopts[unit][data.value].text[data2.value].point = value
								UF[func]()
							end,
							get = function(info)
								return E.db.unitframes.unitopts[unit][data.value].text[data2.value].point
							end,
						
						},	
						
						font = {	
							name = L['Font'],
							order = 6,
							type = "font",
							values = E.GetFontList,
							set = function(self, value)
								E.db.unitframes.unitopts[unit][data.value].text[data2.value].font = value
								UF[func]()
							end,
							get = function(self)
								return E.db.unitframes.unitopts[unit][data.value].text[data2.value].font
							end,
						},
						fontOutline = {	
							name = L['Outline'],
							order = 7,
							type = "dropdown",
							values = {			
								[""] = NO,
								["OUTLINE"] = "OUTLINE",
							},
							set = function(self, value)
								E.db.unitframes.unitopts[unit][data.value].text[data2.value].fontOutline = value
								UF[func]()
							end,
							get = function(self)
								return E.db.unitframes.unitopts[unit][data.value].text[data2.value].fontOutline
							end,
						},
						fontSize = {	
							name = L['Size'],
							order = 8,
							type = "slider",
							min = 1, max = 32, step = 1,
							set = function(self, value)
								E.db.unitframes.unitopts[unit][data.value].text[data2.value].fontSize = value
								UF[func]()
							end,
							get = function(self)
								return E.db.unitframes.unitopts[unit][data.value].text[data2.value].fontSize
							end,
						},
						customText = {
							name = L['Custom text'], desc = L['CUSTOM_TEXT_DESC'],
							order = 10,
							type = 'editbox',
							width = 'full',
							set = function(info, value)
								E.db.unitframes.unitopts[unit].tags_list[data.value][dir] = value
								UF[func]()
							end,
							get = function(info)
								return E.db.unitframes.unitopts[unit].tags_list[data.value][dir]
							end,
						},
					},
				}
			
			end
			tempOptsCount = tempOptsCount + 1
		end
		
		return t
	end
end
--[==[
AleaUI.GUI.args.unitframes.args.Frameoptions = {
	name = "Фреймы",
	order = 1,
	expand = true,
	type = "group",
	args = {}
}

AleaUI.GUI.args.unitframes.args.Frameoptions.args.UnitSelect = {
	name = 'Выберите фрейм'
	order = 1, width = 'full',
	type = 'dropdown',
	values = {},
	set = function(info, value)
	
	end,
	get = function(info)
		return nil
	end,
}
]==]

E.GUI.args.unitframes.args.nameColorByValue = {
	name = L['Bar color by value'],
	order = 1,
	type = 'toggle',
	width = 'full',
	set = function(info, value)
		E.db.unitframes.nameColorByValue = not E.db.unitframes.nameColorByValue
		UF:UpdateAllUnitFrames()
	end,
	get = function(info)
		return E.db.unitframes.nameColorByValue
	end,
}

E.GUI.args.unitframes.args.nameColorByClass = {
	name = L['Bar color by class'],
	order = 1.1,
	type = 'toggle',
	width = 'full',
	set = function(info, value)
		E.db.unitframes.nameColorByClass = not E.db.unitframes.nameColorByClass
		UF:UpdateAllUnitFrames()
	end,
	get = function(info)
		return E.db.unitframes.nameColorByClass
	end,
}

E.GUI.args.unitframes.args.reverBarColor = {
	name = L['Swap bar and background colors'],
	order = 1.2,
	type = 'toggle',
	width = 'full',
	set = function(info, value)
		E.db.unitframes.reverBarColor = not E.db.unitframes.reverBarColor
		UF:UpdateAllUnitFrames()
	end,
	get = function(info)
		return E.db.unitframes.reverBarColor
	end,
}

E.GUI.args.unitframes.args.rangeCheck = {
	name = L['Disable range check'],
	order = 1.3,
	type = 'toggle',
	width = 'full',
	set = function(info, value)
		E.db.unitframes.rangeCheck = not E.db.unitframes.rangeCheck
		UF:UpdateAllUnitFrames()
	end,
	get = function(info)
		return E.db.unitframes.rangeCheck
	end,
}

E.GUI.args.unitframes.args.smoothBars = {
	name = L['Smooth bars'],
	order = 1.4,
	type = 'toggle',
	width = 'full',
	set = function(info, value)
		E.db.unitframes.smoothBars = not E.db.unitframes.smoothBars
		UF:InterateAllFrames('UpdateFrameConstruct')
	end,
	get = function(info)
		return E.db.unitframes.smoothBars
	end,
}

E.GUI.args.unitframes.args.BarColors = {
	name = L['Bar color'],
	order = 2,
	type = 'group',
	embend = true,
	args = {},
}

E.GUI.args.unitframes.args.BarColors.args.Normal = {
	name = L['Health'],
	order = 1,
	type = 'color',
	set = function(info, r,g,b,a)
		E.db.unitframes.colors.normal = { r, g, b, 1 }
		UF:UpdateAllUnitFrames()
	end,
	get = function(info)
		return 	E.db.unitframes.colors.normal[1],
				E.db.unitframes.colors.normal[2],
				E.db.unitframes.colors.normal[3],
				1
	end,
}

E.GUI.args.unitframes.args.BarColors.args.Tapped = {
	name = L['Tapped'],
	order = 2,
	type = 'color',
	set = function(info, r,g,b,a)
		E.db.unitframes.colors.tapped = { r, g, b, 1 }
		UF:UpdateAllUnitFrames()
	end,
	get = function(info)
		return 	E.db.unitframes.colors.tapped[1],
				E.db.unitframes.colors.tapped[2],
				E.db.unitframes.colors.tapped[3],
				1
	end,
}

E.GUI.args.unitframes.args.BarColors.args.HP_Background = {
	name = L['Health background'],
	order = 3,
	type = 'color',
	set = function(info, r,g,b,a)
		E.db.unitframes.colors.hp_background = { r, g, b, 1 }
		UF:UpdateAllUnitFrames()
	end,
	get = function(info)
		return 	E.db.unitframes.colors.hp_background[1],
				E.db.unitframes.colors.hp_background[2],
				E.db.unitframes.colors.hp_background[3],
				1
	end,
}

E.GUI.args.unitframes.args.BarColors.args.Power_Background = {
	name = L['Power background'],
	order = 4,
	type = 'color',
	set = function(info, r,g,b,a)
		E.db.unitframes.colors.power_background = { r, g, b, 1 }
		UF:UpdateAllUnitFrames()
	end,
	get = function(info)
		return 	E.db.unitframes.colors.power_background[1],
				E.db.unitframes.colors.power_background[2],
				E.db.unitframes.colors.power_background[3],
				1
	end,
}

E.GUI.args.unitframes.args.BarColors.args.Altpower_Background = {
	name = L['Alternative power background'],
	order = 5,
	type = 'color',
	set = function(info, r,g,b,a)
		E.db.unitframes.colors.altpower_background = { r, g, b, 1 }
		UF:UpdateAllUnitFrames()
	end,
	get = function(info)
		return 	E.db.unitframes.colors.altpower_background[1],
				E.db.unitframes.colors.altpower_background[2],
				E.db.unitframes.colors.altpower_background[3],
				1
	end,
}

E.GUI.args.unitframes.args.ReactionColors = {
	name = L['Reaction colors'],
	order = 3,
	type = 'group',
	embend = true,
	args = {},
}

--[==[
local ReactionLocalized = {
	['Hated'] = L['Hated'], --'Ненависть', 
	['Hostile'] = 'Враждебный', 
	['Unfriendly'] = 'Недружественный', 
	['Neutral'] = "Равнодушие", 
	['Friendly'] = "Дружелюбие", 
	['Honored'] = 'Уважение', 
	['Revered'] = 'Почтение', 
	['Exalted'] = 'Превознесение',
}
]==]
for i, v in pairs({'Hated', 'Hostile', 'Unfriendly', 'Neutral', 'Friendly', 'Honored', 'Revered', 'Exalted'}) do

	E.GUI.args.unitframes.args.ReactionColors.args['reaction'..i] = {
		name = L[v],
		order = i,
		type = 'color',
		set = function(info, r,g,b,a)
			E.db.unitframes.reaction_colors[i] = { r, g, b, 1 }
			UF:UpdateAllUnitFrames()
		end,
		get = function(info)
			return 	E.db.unitframes.reaction_colors[i][1],
					E.db.unitframes.reaction_colors[i][2],
					E.db.unitframes.reaction_colors[i][3],
					1
		end,
	}
end


E.GUI.args.unitframes.args.PowerColors = {
	name = L['Power colors'],
	order = 5,
	type = 'group',
	embend = true,
	args = {},
}

local indexed = 0
for k, v in pairs({
	["MANA"] 		= L['Mana'],
	["RAGE"] 		= L['Rage'],
	["FOCUS"] 		= L['Focus'],
	["ENERGY"] 		= L['Energy'],
	["RUNIC_POWER"] = L['Runic power'],
	["ALTERNATE"] 	= L['Alternative resource'],
	['INSANITY'] 	= L['Insanity'],
	['MAELSTROM']   = L['Maelstrom'],
	["FURY"]		= L['Fury'],
	['PAIN']		= L['Pain'],
	['LUNAR_POWER'] = L['Lunar power'],
		
	}) do
	indexed = indexed + 1
	E.GUI.args.unitframes.args.PowerColors.args[k] = {
		name = v,
		order = indexed,
		type = 'color', hasAlpha = true,
		set = function(info, r,g,b,a)
			E.db.unitframes.power_colors[k] = { r, g, b, a }
			UF:UpdateCustomPowerColors()
			UF:UpdateAllUnitFrames()
		end,
		get = function(info)
			return 	E.db.unitframes.power_colors[k][1],
					E.db.unitframes.power_colors[k][2],
					E.db.unitframes.power_colors[k][3],
					E.db.unitframes.power_colors[k][4] or 1
		end,
	}
end

E.GUI.args.unitframes.args.HealColors = {
	name = L['Healing colors'],
	order = 6,
	type = 'group',
	embend = true,
	args = {},
}

local indexed = 0
for k, v in pairs({
	["otherHeal"] 	 = L['Heal'],
	["myHealAbsorb"] = L['Heal ansorb'],
	["otherAbsorb"]  = L['Absorb'],
	}) do
	indexed = indexed + 1
	E.GUI.args.unitframes.args.HealColors.args[k] = {
		name = v,
		order = indexed,
		type = 'color', hasAlpha = true,
		set = function(info, r,g,b,a)
			E.db.unitframes.colors[k] = { r, g, b, a }
			UpdateByLSM()
			UF:UpdateAllUnitFrames()
		end,
		get = function(info)
			return 	E.db.unitframes.colors[k][1],
					E.db.unitframes.colors[k][2],
					E.db.unitframes.colors[k][3],
					E.db.unitframes.colors[k][4] or 1
		end,
	}	
end


do

	local smoothing = {}
	local function Smooth(self, value)
		if value ~= self:GetValue() or value == 0 then
			smoothing[self] = value
		else
			smoothing[self] = nil
		end
	end

	local function SmoothBar(bar)
		if not bar.SetValue_ then
			bar.SetValue_ = bar.SetValue;
			bar.SetValue = Smooth;
		end
	end

	local function ResetBar(bar)
		if bar.SetValue_ then
			bar.SetValue = bar.SetValue_;
			bar.SetValue_ = nil;
			
			smoothing[bar] = nil
		end
	end

	function E:SetSmoothBar(bar, enable)
		if enable then
			SmoothBar(bar)
		else
			ResetBar(bar)
		end
		
		bar.Smooth = enable
	end
	
	local f, min, max = CreateFrame('Frame'), math.min, math.max
	f:SetScript('OnUpdate', function()
		local rate = GetFramerate()
		local limit = 30/rate

		for bar, value in pairs(smoothing) do
			local cur = bar:GetValue()
			local new = cur + min((value-cur)/3, max(value-cur, limit))
			if new ~= new then
				-- Mad hax to prevent QNAN.
				new = value
			end
			bar:SetValue_(new)
			if bar.PostSetValue then bar:PostSetValue(new) end
			if (cur == value or abs(new - value) < 2) and bar.Smooth then
				bar:SetValue_(value)
				if bar.PostSetValue then bar:PostSetValue(new) end
				smoothing[bar] = nil
			elseif not bar.Smooth then
				bar:SetValue_(value)
				if bar.PostSetValue then bar:PostSetValue(new) end
				smoothing[bar] = nil		
			end
		end
	end)
end