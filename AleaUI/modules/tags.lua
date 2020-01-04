local addOn, E = ...
local L = E.L
local Tags = E:Module("Tags")


local tag_function = {}
local tag_OnEvents = {}
local tag_OnUpdate = {}

Tags.tag_function = tag_function
Tags.tag_OnEvents = tag_OnEvents
Tags.tag_OnUpdate = tag_OnUpdate

Tags.Functions = {}

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

--            POST_UPDATE_FRAME        - event for OnShowing frames or when focus target changed

tag_OnEvents["[health]"] = "UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH UNIT_HEALTH"
tag_function["[health]"] = function(unit)
	return E:ShortValue(UnitHealth(unit))
end
	
tag_OnEvents["[health:max]"] = "UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH UNIT_HEALTH"
tag_function["[health:max]"] = function(unit)
	return E:ShortValue(UnitHealthMax(unit))
end

tag_OnEvents["[health:percent]"] = "UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH UNIT_HEALTH"
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
	if ( UnitIsWildBattlePet(unit) or UnitIsBattlePetCompanion(unit) ) then
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
	if ( UnitIsWildBattlePet(unit) or UnitIsBattlePetCompanion(unit) ) then
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
		local class, classFileName  = UnitClassBase(unit)	
		if classFileName then
			return format('|c%s%s|r', RAID_CLASS_COLORS[classFileName] and RAID_CLASS_COLORS[classFileName].colorStr or 'ffffffff', class)
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
		info = ( faction == "Horde" and "|cFFFF0000" or "|cFF0000FF" )..factionname.."|r "..info 
	end
	
	
	local level = UnitLevel(unit)
	if ( UnitIsWildBattlePet(unit) or UnitIsBattlePetCompanion(unit) ) then
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

--[==[

	local function gsubHandler(tag)
		
	end

	f.tags:gsub("(%[.-%])", gsubHandler))
	
	for k in gmatch(tagtext, '%[..-%]+') do
		tinsert(self[fs].taglist, k)
	end
]==]

local function UnpackToString(t)
	local s = ''
	
	for i=1, #t do
		s = s..t
	end
	
	return t
end

local funcList = {}

function Tags.GetFunction(tagText, unit)
	if not Tags.Functions[tagText] then

		print('TagText:', tagText)
		
		local tags = {}
		for k in gmatch(tagText, '%[..-%]+') do
			print('  Tag:', k)
			tags[#tags+1] = 'tags["'..k..'"](unit)'
		end
	
		local pattern = tagText:gsub("(%[.-%])", '%%s')
		
		for tag in pairs(tags) do
		--	pattern = pattern:gsub(tag, 'tag_function["'..tag..'"]('..unit..')')
		end
		
		local func = [[local tags = ...; return function(unit) return ("]]..pattern..[["):format(]]..table.concat(tags,",")..[[) end]]
		
		print('Pattern',func)
	
		Tags.Functions[tagText] = assert(loadstring(func))(tag_function)
		
	end
	
	return Tags.Functions[tagText](unit)
end

do

	local lastFrame = nil
	
	local function gsubHandler(tag)
		return tag_function[tag](lastFrame)
	end
	
	
	function Tags.BasicFormatFunction(tagText, unit)	
		lastFrame = unit
		return tagText:gsub("(%[.-%])", gsubHandler)
	end
end

--print(Tags.Debug_RunFunction('GetFunction', " [health] - [health:max] | [health:percent]", 'target'))

function Tags.Debug_RunFunction(func, tag, unit)
	local startTime = debugprofilestop()	
	
	for i=1, 1000 do
		Tags[func](tag, unit)
	end
	print(format("%s executed in %f ms", func, debugprofilestop()-startTime))
end

AleaUI_Debug_RunFunctionByName = Tags.Debug_RunFunction


function AleaUI_Debug_RunFunction(func, ...)
	local startTime = debugprofilestop()
	
	for i=1, 1000 do
		func(...)
	end
	
	print(format("func executed in %f ms", debugprofilestop()-startTime))
end