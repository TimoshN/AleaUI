local addonName, E = ...
local UF = E:Module("UnitFrames")
local RF = E:Module("RaidFrames")
local Skins = E:Module("Skins")
local L = E.L

-------------------------------------
-- LUA GLOBALS
-------------------------------------

local format = format
local floor = floor
local select = select
local tostring = tostring
local pairs = pairs
local find = string.find
local ceil = ceil
local sub = string.sub
local tinsert = table.insert
local tremove = table.remove

-------------------------------------
-- API GLOBALS
-------------------------------------

local UnitName = UnitName
local UnitIsConnected = UnitIsConnected
local UnitIsDeadOrGhost = UnitIsDeadOrGhost
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitPowerMax = UnitPowerMax
local UnitPower = UnitPower
local UnitGetIncomingHeals = UnitGetIncomingHeals
local UnitGetTotalHealAbsorbs = UnitGetTotalHealAbsorbs
local UnitGetTotalAbsorbs = UnitGetTotalAbsorbs
local UnitExists = UnitExists
local UnitInRaid = UnitInRaid
local UnitInVehicle = UnitInVehicle
local GetRaidRosterInfo = GetRaidRosterInfo
local UnitGroupRolesAssigned = UnitGroupRolesAssigned
local GetTexCoordsForRoleSmallCircle = GetTexCoordsForRoleSmallCircle
local UnitThreatSituation = UnitThreatSituation
local GetThreatStatusColor = GetThreatStatusColor
local GetReadyCheckTimeLeft = GetReadyCheckTimeLeft
local GetReadyCheckStatus = GetReadyCheckStatus
local UnitHasIncomingResurrection = UnitHasIncomingResurrection
local SpellGetVisibilityInfo = SpellGetVisibilityInfo
local UnitAffectingCombat = UnitAffectingCombat
local UnitBuff = UnitBuff
local UnitDebuff = UnitDebuff
local UnitIsUnit = UnitIsUnit
local UnitDistanceSquared = UnitDistanceSquared
local UnitInRange = UnitInRange
local UnitClass = UnitClass
local UnitIsPlayer = UnitIsPlayer
local UnitHasVehicleUI = UnitHasVehicleUI
local GetInstanceInfo = GetInstanceInfo
local GetSpecializationInfo = GetSpecializationInfo
local GetRaidTargetIndex = GetRaidTargetIndex
local UnitInOtherParty = UnitInOtherParty
local GetSpellInfo = GetSpellInfo
local CooldownFrame_Set = CooldownFrame_Set
local CooldownFrame_Clear = CooldownFrame_Clear

local UnitInPhase = E.UnitInPhase

-------------------------------------
-- GLOBAL VARIABLES
-------------------------------------

local READY_CHECK_READY_TEXTURE = READY_CHECK_READY_TEXTURE
local READY_CHECK_NOT_READY_TEXTURE = READY_CHECK_NOT_READY_TEXTURE
local READY_CHECK_WAITING_TEXTURE = READY_CHECK_WAITING_TEXTURE
local RAID_CLASS_COLORS = RAID_CLASS_COLORS
local DISTANCE_THRESHOLD_SQUARED = DISTANCE_THRESHOLD_SQUARED or 250*250
local MAX_INCOMING_HEAL_OVERFLOW = 1 -- 1.05
local BUFF_STACKS_OVERFLOW = BUFF_STACKS_OVERFLOW or 10

local UNIT_HEALTH_EVENT = E.UNIT_HEALTH_EVENT

-------------------------------------
-- MODULE VARIABLES
-------------------------------------

local HideRaid
local mult = E.multi

local profileOwner = E.myname..' - '..E.myrealm

local options, charOptions

local TOTAL_HEADERS = 8
local headerLists = {}

local ArtElements = {}

local defaulr_color = { r = 0, g = 1, b = 0}
local class_color = {}

for k,v in pairs(RAID_CLASS_COLORS) do
	class_color[k] = {}
	class_color[k].r = v.r*.8
	class_color[k].g = v.g*.8
	class_color[k].b = v.b*.8
end

-- Clique Support
ClickCastFrames = ClickCastFrames or {}

-- Function List
local UpdateButton, OnShowButton, OnChangeAttribute
local CreateGroupHeader, CreateUnitFrameArtwork
local CallArtworkFunction, SecureInitFunction
local UpdateAll
local orient = "HORIZONTAL"  --HORIZONTAL VERTICAL


local ShowEnergy = false

local colors = {
	power = {
		[0] = { r = 48/255, g = 113/255, b = 191/255}, -- Mana
		[1] = { r = 255/255, g = 1/255, b = 1/255}, -- Rage
		[2] = { r = 255/255, g = 178/255, b = 0}, -- Focus
		[3] = { r = 1, g = 1, b = 34/255}, -- Energy
		[5] = {	r = .55, g = .57, b = .61}, --Runes
		[6] = { r = 0, g = 209/255, b = 1}, -- Runic Power --0, 209/255, 1
		[7] = { r = .8, g = .6, b = 0}, --Ammoslot
		[8] = { r = 0, g = .55, b = .5}, --Fuel
		[9] = { r = .55, g = .57, b = .61}, --Steam
		[10] = { r = .60, g = .09, b = .17}, --Pyrite
	},
}

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

local classIndicators = {
	['SHAMAN'] = {
		{
			['topleft'] 	= { spellID = nil, enable = false, color = { 0, 1, 0 }, },
			['topright'] 	= { spellID = nil, enable = false, color = { 0, 1, 0 }, },
			['bottomleft'] 	= { spellID = nil, enable = false, color = { 0, 1, 0 }, },
			['bottomright'] = { spellID = nil, enable = false, color = { 0, 1, 0 }, },
		}, -- Elemental
		{
			['topleft'] 	= { spellID = nil, enable = false, color = { 0, 1, 0 }, },
			['topright'] 	= { spellID = nil, enable = false, color = { 0, 1, 0 }, },
			['bottomleft'] 	= { spellID = nil, enable = false, color = { 0, 1, 0 }, },
			['bottomright'] = { spellID = nil, enable = false, color = { 0, 1, 0 }, },
		}, -- ench
		{
			['topleft'] 	= { spellID = 61295, enable = false, color = { 0, 1, 0 }, },
			['topright'] 	= { spellID = 61295, enable = true, color = { 0, 1, 0 }, },
			['bottomleft'] 	= { spellID = nil, enable = false, color = { 0, 1, 0 }, },
			['bottomright'] = { spellID = nil, enable = false, color = { 0, 1, 0 }, },
		}, -- restor
	},
}

local onlyRaidBuffFilter = true
local raidBuffs = {
	-- Warlock
	[104773] = true,
	[110913] = true,
	[108416] = true,
	-- Priest
	[33206] = true,
	[62618] = true,
	[45242] = true,
	[47585] = true,
	[41635] = true,
	-- Druid
	[22812] = true,
	[61336] = true,
	[102342] = true,
	-- Hunter
	[19263] = true,
	-- Mage
	[45438] = true,
	[110959] = true,

	-- Monk
	[115203] = true,
	[115176] = true,
	[122783] = true,

	-- Paladin
	[642] = true,
	[1022] = true,
	[6940] = true,
	[31821] = true,
	[31850] = true,
	[86659] = true,
	[114039] = true,


 	-- Rogue

	[31224] = true,
	[74001] = true,
	[1966] = true,
	-- Warrior

	[871] = true,
	[97462] = true,
	[114029] = true,

	-- DK
	[49222] = true,
	[48707] = true,
	[48792] = true,
	[51052] = true,

	-- Shaman

	[30823] = true,


	--------- RAID BOSS BUFFS

	[163663] = true
}
local onlyRaidDebuffFilter = false
local raidDebuffs = {
	[76577] = true,
}

local defaults = {
	lastProfile = 1,
	enableAutoChangeProfile = true,
	enableModule = true,
	Profiles = {
		['MainProfile'] = {
			name = L['Main'],
			deletable = false,
			onlyRaidBuffFilter = onlyRaidBuffFilter,
			raidBuffs = raidBuffs,
			onlyRaidDebuffFilter = onlyRaidDebuffFilter,
			raidDebuffs = raidDebuffs,

			horizontal = true,
			gropUp = true,
			color = { 0.2,0.2,0.2, 1 },
			bgcolor = { 0.4, 0.4, 0.4, 1},

			auraSize = 12,
			auraSizeBig = 18,

			width = 77,
			height = 40,

			texture = E.media.default_bar_texture_name1,
			font = E.media.default_font_name,
			fontSize = 10,

			amountBuffs = 3,
			amountDebuffs = 3,

			buffSize = 12,
			buffSizeBig = 18,
			debuffSize = 12,
			debuffSizeBig = 18,

			enablePVP = true,
			enablePVE = true,

			raidSize = 1,
			raidSize_max = 40,
			perCharSpec = {},

			groupToShow = {true,true,true,true,true,true,true,true,},
			position = format('%s\031%s\031%s\031%d\031%d', 'BOTTOMLEFT', 'AleaUIParent', 'BOTTOMLEFT', 4, 196),
			artwork = {
				['enable'] = false,
				['width'] = 100,
				['height'] = 100,
				["background_texture"] = E.media.default_bar_texture_name3,
				["size"] = 1,
				["inset"] = 0,
				["color"] = {
					0,
					0,
					0,
					1,
				},
				["background_inset"] = 0,
				["background_color"] = {
					0,
					0,
					0,
					0.6,
				},
				["texture"] = E.media.default_bar_texture_name3,
			}
		},
	},
	ProfileList = {
		'MainProfile',
	}
}

E.default_settings.raidFramesSettings = defaults

local defaultsChar = {
	Profiles = {
		['MainProfile'] = {
			perCharSpec = {},
		},
	},
	indicators = {
		[E.myclass] = classIndicators[E.myclass],
	},
}

E.default_chat_settings.raidFramesSettings = defaultsChar

------------------------------------
-- Update Functions
------------------------------------

local UpdateColor = function(self)
	local _,class = UnitClass(self.displayedUnit)
	if class then
		self.classcolor = UnitIsPlayer(self.displayedUnit) and class_color[class] or defaulr_color
	end

	local r1, g1, b1, a1

	if self.classcolor then
		local color = options.color or defaults.color
		r1, g1, b1, a1 = color[1], color[2], color[3], color[4]
	else
		r1, g1, b1, a1 = 0.6,0.2,0.2, 1
	end

	local r, g, b

	if false then
		r,g,b = E:ColorGradient(h, hm, 0.6, 0, 0, 0.6, 0.6, 0, r1, g1, b1)
	else
		r,g,b = r1, g1, b1
	end

	self.health:SetStatusBarColor(r, g, b, a1)

	local bgcolor = options.bgcolor or defaults.bgcolor

	if UnitIsDeadOrGhost(self.displayedUnit) or UnitIsConnected(self.displayedUnit) then
		self.health.bg:SetVertexColor(bgcolor[1], bgcolor[2], bgcolor[3], bgcolor[4])
	else
		self.health.bg:SetVertexColor(bgcolor[1], bgcolor[2], bgcolor[3], bgcolor[4])
	end

	self.text:SetTextColor(self.classcolor and self.classcolor.r or 1, self.classcolor and self.classcolor.g or 1, self.classcolor and self.classcolor.b or 1)
end

local UpdateName = function(self)
	local name, realm = UnitName(self.displayedUnit)
	if name then
		self.text:SetText(name)
	end
end

local UpdateStatus = function(self, sethp)
	self.text2:SetText(not UnitIsConnected(self.displayedUnit) and L['offline'] or ( UnitIsDeadOrGhost(self.displayedUnit) or UnitHealth(self.displayedUnit) == 0  ) and L['dead'] or sethp)
end

local UpdateHealth = function(self)
	if not self.displayedUnit then return end

	local h,hm = UnitHealth(self.displayedUnit), UnitHealthMax(self.displayedUnit)
	if hm == 0 then return end
	local pers = (h/hm*100)

	local flpers = floor(pers+0.5)

	self.health:SetMinMaxValues(0, hm)
	self.health:SetValue(h+0.01)

	if flpers < 100 then
		UpdateStatus(self, format("%.0f%s",pers,"%"))
	else
		UpdateStatus(self, "")
	end
end

local UpdatePower = function(self)
	if not options.showPowerBars then return end 
	if not self.displayedUnit then return end

	if UnitPowerMax(self.displayedUnit, ALTERNATE_POWER_INDEX) > 0 then
		self.power:SetValue(UnitPower(self.displayedUnit, ALTERNATE_POWER_INDEX)/UnitPowerMax(self.displayedUnit, ALTERNATE_POWER_INDEX)*100)
	elseif UnitPowerMax(self.displayedUnit) > 0 then
		self.power:SetValue(UnitPower(self.displayedUnit)/UnitPowerMax(self.displayedUnit)*100)
	else
		self.power:SetValue(0)
	end
	local powercolor = UF:PowerColorRGB(self.displayedUnit)
	self.power:SetStatusBarColor(powercolor[1], powercolor[2], powercolor[3])

	if UnitIsDeadOrGhost(self.displayedUnit) or UnitIsConnected(self.displayedUnit) then
		self.power.bg:SetVertexColor(0.5, 0.5, 0.5)
	else
		self.power.bg:SetVertexColor(0,0,0)
	end
end

--[==[
local function UpdateFillBar(frame, previousTexture, bar, amount, barOffsetXPercent)
	if ( amount == 0 ) then
		bar:Hide();
		if ( bar.overlay ) then
			bar.overlay:Hide();
		end
		return previousTexture;
	end

	local barOffsetX = 0;
	if ( barOffsetXPercent ) then
		local healthBarSizeX = frame.health:GetWidth();
		barOffsetX = healthBarSizeX * barOffsetXPercent;
	end

	bar:SetPoint("TOPLEFT", previousTexture, "TOPRIGHT", barOffsetX, 0);
	bar:SetPoint("BOTTOMLEFT", previousTexture, "BOTTOMRIGHT", barOffsetX, 0);

	local totalWidth, totalHeight = frame.health:GetSize();
	local _, totalMax = frame.health:GetMinMaxValues();

	local barSize = (amount / totalMax) * totalWidth;
	bar:SetWidth(barSize);
	bar:Show();
	if ( bar.overlay ) then
		bar.overlay:SetTexCoord(0, barSize / bar.overlay.tileSize, 0, totalHeight / bar.overlay.tileSize);
		bar.overlay:Show();
	end
	return bar;
end
]==]

local function UpdateHealPrediction_Horizontal(self)
	local _, maxHealth = self.health:GetMinMaxValues();
	local health = self.health:GetValue();
	local width, height = self.health:GetSize()
	local unit = self.displayedUnit or self.unit

	if ( E.isClassic or maxHealth <= 0 or not unit ) then
		self.health.totalHealPrediction:SetWidth(0.0001)
		self.health.totalHealPrediction:Hide()
		self.health.totalAbsorb:Hide()
		self.health.totalHealAbsorb:Hide()
		return;
	end

	local widthperhp = width/maxHealth

	local myIncomingHeal      = UnitGetIncomingHeals(unit, "player") or 0;
	local allIncomingHeal     = UnitGetIncomingHeals(unit) or 0;
	local totalAbsorb         = UnitGetTotalAbsorbs(unit) or 0;
	local myCurrentHealAbsorb = UnitGetTotalHealAbsorbs(unit) or 0;

	local realIncomingHeal	  = allIncomingHeal - myCurrentHealAbsorb
	if realIncomingHeal < 0 then realIncomingHeal = 0 end

	if myCurrentHealAbsorb > 0 then
		if myCurrentHealAbsorb > health then
	--		self.health.overHealAbsorbGlow:Show()
			self.health.totalHealAbsorb:SetWidth(health*widthperhp > 0.0001 and health*widthperhp or 0.0001 )
			self.health.totalHealAbsorb:SetHeight(height)
		else
	--		self.health.overHealAbsorbGlow:Hide()
			self.health.totalHealAbsorb:SetWidth(myCurrentHealAbsorb*widthperhp > 0.0001 and myCurrentHealAbsorb*widthperhp or 0.0001 )
			self.health.totalHealAbsorb:SetHeight(height)
		end
		self.health.totalHealAbsorb:Show()
	else
	--	self.health.overHealAbsorbGlow:Hide()
		self.health.totalHealAbsorb:Hide()
	end

	if realIncomingHeal > 0 then
		if realIncomingHeal > maxHealth - health then
			local healLeft = realIncomingHeal
			if realIncomingHeal + health > maxHealth * MAX_INCOMING_HEAL_OVERFLOW then
				healLeft =  maxHealth * MAX_INCOMING_HEAL_OVERFLOW - health
			end

			if healLeft == 0 then healLeft = 0.0001 end

			self.health.totalHealPrediction:SetWidth(healLeft*widthperhp > 0.0001 and healLeft*widthperhp or 0.0001 ) --healLeft*widthperhp)
			self.health.totalHealPrediction:SetHeight(height)
		--	self.health.totalHealPrediction:SetPoint('LEFT', self.health, 'LEFT', health*widthperhp, 0)
			self.health.totalHealPrediction:SetPoint('LEFT', self.health.statusBarTexture, 'RIGHT', 0, 0)
			self.health.totalHealPrediction:Show()
		else

			self.health.totalHealPrediction:SetWidth(realIncomingHeal*widthperhp > 0.0001 and realIncomingHeal*widthperhp or 0.0001 )
			self.health.totalHealPrediction:SetHeight(height)
		--	self.health.totalHealPrediction:SetPoint('LEFT', self.health, 'LEFT', health*widthperhp, 0)
			self.health.totalHealPrediction:SetPoint('LEFT', self.health.statusBarTexture, 'RIGHT', 0, 0)
			self.health.totalHealPrediction:Show()
		end
	else
		self.health.totalHealPrediction:SetWidth(0.0001)
		self.health.totalHealPrediction:SetHeight(height)
		self.health.totalHealPrediction:Hide()
	end

	if totalAbsorb > 0 then
		--[[
		if ( health + totalAbsorb ) > maxHealth then
			self.health.overAbsorbGlow:Show()
		else
			self.health.overAbsorbGlow:Hide()
		end
		]]
		local absorbLeft = maxHealth - health - realIncomingHeal

		if totalAbsorb < absorbLeft then
			absorbLeft = totalAbsorb
		end

		if absorbLeft > 0 then
			self.health.totalAbsorb:SetWidth(absorbLeft*widthperhp > 0.0001 and absorbLeft*widthperhp or 0.0001 )
			self.health.totalAbsorb:SetHeight(height)
		--	self.health.totalAbsorb:SetPoint('LEFT', self.health, 'LEFT', (health+realIncomingHeal)*widthperhp, 0)
			self.health.totalAbsorb:SetPoint('LEFT', self.health.totalHealPrediction:IsShown() and self.health.totalHealPrediction or self.health.statusBarTexture, 'RIGHT', 0, 0)
			self.health.totalAbsorb:Show()
		else
			self.health.totalAbsorb:SetWidth(0.0001)
			self.health.totalAbsorb:SetHeight(height)
			self.health.totalAbsorb:Hide()
		end
	else
		self.health.totalAbsorb:Hide()
	--	self.health.overAbsorbGlow:Hide()
	end
end

local function UpdateHealPrediction_Vertical(self)
	local _, maxHealth = self.health:GetMinMaxValues();
	local health = self.health:GetValue();
	local width, height = self.health:GetSize()
	local unit = self.displayedUnit or self.unit

	if ( E.isClassic or maxHealth <= 0 or not unit) then
		self.health.totalHealPrediction:SetHeight(0.0001)
		self.health.totalHealPrediction:Hide()
		self.health.totalAbsorb:Hide()
		self.health.totalHealAbsorb:Hide()
		return;
	end

	local heightperhp = height/maxHealth

	local myIncomingHeal      = UnitGetIncomingHeals(unit, "player") or 0;
	local allIncomingHeal     = UnitGetIncomingHeals(unit) or 0;
	local totalAbsorb         = UnitGetTotalAbsorbs(unit) or 0;
	local myCurrentHealAbsorb = UnitGetTotalHealAbsorbs(unit) or 0;

	local realIncomingHeal	  = allIncomingHeal - myCurrentHealAbsorb
	if realIncomingHeal < 0 then realIncomingHeal = 0 end

	if myCurrentHealAbsorb > 0 then
		if myCurrentHealAbsorb > health then
	--		self.health.overHealAbsorbGlow:Show()
			self.health.totalHealAbsorb:SetWidth(width)
			self.health.totalHealAbsorb:SetHeight(health*heightperhp > 0.0001 and health*heightperhp or 0.0001)
		else
	--		self.health.overHealAbsorbGlow:Hide()
			self.health.totalHealAbsorb:SetWidth(width)
			self.health.totalHealAbsorb:SetHeight(myCurrentHealAbsorb*heightperhp > 0.0001 and myCurrentHealAbsorb*heightperhp or 0.0001)
		end
		self.health.totalHealAbsorb:Show()
	else
	--	self.health.overHealAbsorbGlow:Hide()
		self.health.totalHealAbsorb:Hide()
	end

	if realIncomingHeal > 0 then
		if realIncomingHeal > maxHealth - health then
			local healLeft = realIncomingHeal
			if realIncomingHeal + health > maxHealth * MAX_INCOMING_HEAL_OVERFLOW then
				healLeft =  maxHealth * MAX_INCOMING_HEAL_OVERFLOW - health
			end

			if healLeft == 0 then healLeft = 0.0001 end

			self.health.totalHealPrediction:SetWidth(width) --healLeft*widthperhp)
			self.health.totalHealPrediction:SetHeight(healLeft*heightperhp > 0.0001 and healLeft*heightperhp or 0.0001 )
			self.health.totalHealPrediction:SetPoint('BOTTOM', self.health, 'BOTTOM', 0, health*heightperhp)
			self.health.totalHealPrediction:Show()
		else

			self.health.totalHealPrediction:SetWidth(width)
			self.health.totalHealPrediction:SetHeight(realIncomingHeal*heightperhp > 0.0001 and realIncomingHeal*heightperhp or 0.0001 )
			self.health.totalHealPrediction:SetPoint('BOTTOM', self.health, 'BOTTOM', 0, health*heightperhp)
			self.health.totalHealPrediction:Show()
		end
	else
		self.health.totalHealPrediction:SetWidth(width)
		self.health.totalHealPrediction:SetHeight(0.0001)
		self.health.totalHealPrediction:Hide()
	end

	if totalAbsorb > 0 then
		--[[
		if ( health + totalAbsorb ) > maxHealth then
			self.health.overAbsorbGlow:Show()
		else
			self.health.overAbsorbGlow:Hide()
		end
		]]
		local absorbLeft = maxHealth - health - realIncomingHeal

		if totalAbsorb < absorbLeft then
			absorbLeft = totalAbsorb
		end

		if absorbLeft > 0 then
			self.health.totalAbsorb:SetWidth(width)
			self.health.totalAbsorb:SetHeight(absorbLeft*heightperhp > 0.0001 and absorbLeft*heightperhp or 0.0001 )
			self.health.totalAbsorb:SetPoint('BOTTOM', self.health, 'BOTTOM', 0, (health+realIncomingHeal)*heightperhp)
			self.health.totalAbsorb:Show()
		else
			self.health.totalAbsorb:SetWidth(width)
			self.health.totalAbsorb:SetHeight(0.0001)
			self.health.totalAbsorb:Hide()
		end
	else
		self.health.totalAbsorb:Hide()
	--	self.health.overAbsorbGlow:Hide()
	end
end


local UpdateHealPrediction = function(self)
--	if self.lastHealPrediction == GetTime() then return end
--	self.lastHealPrediction = GetTime()

	if options.horizontalFill then
		UpdateHealPrediction_Horizontal(self)
	else
		UpdateHealPrediction_Vertical(self)
	end
end


local UpdateRaidTargetIndex = function(self)
	if not UnitExists(self.displayedUnit) then
		self.raidIcon:Hide()
		return
	end

	local mark = GetRaidTargetIndex(self.displayedUnit)

	if raidIndexCoord[mark] then
		self.raidIcon:Show()
		self.raidIcon:SetTexCoord(raidIndexCoord[mark][1], raidIndexCoord[mark][2], raidIndexCoord[mark][3], raidIndexCoord[mark][4])
	else
		self.raidIcon:Hide()
	end
end

local UpdateRole = function(self)
	local size = self.role:GetHeight()
	local raidID = UnitInRaid(self.displayedUnit)
	
	if UnitInVehicle and UnitInVehicle(self.displayedUnit) and UnitHasVehicleUI(self.displayedUnit) then
		self.role:SetTexture("Interface\\Vehicles\\UI-Vehicles-Raid-Icon")
		self.role:SetTexCoord(0, 1, 0, 1)
		self.role:Show()
		self.role:SetSize(size, size)
	elseif (UnitInParty(self.displayedUnit) or UnitInRaid(self.displayedUnit)) and UnitIsGroupLeader(self.displayedUnit) then
		self.role:SetTexture("Interface\\GroupFrame\\UI-Group-LeaderIcon")
		self.role:SetTexCoord(0, 1, 0, 1)
		self.role:Show()
		self.role:SetSize(size, size)
	elseif raidID and select(10, GetRaidRosterInfo(raidID)) then
		local role = select(10, GetRaidRosterInfo(raidID))

		self.role:SetTexture("Interface\\GroupFrame\\UI-Group-"..role.."Icon")
		self.role:SetTexCoord(0, 1, 0, 1)
		self.role:Show()
		self.role:SetSize(size, size)
	else
		local role = UnitGroupRolesAssigned and UnitGroupRolesAssigned(self.displayedUnit)
		if (role == "TANK" or role == "HEALER" or role == "DAMAGER") then
			self.role:SetTexture("Interface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES")
			self.role:SetTexCoord(GetTexCoordsForRoleSmallCircle(role))
			self.role:Show()
			self.role:SetSize(size, size)
		else
			self.role:Hide()
			self.role:SetSize(1, size)
		end
	end
end
local ThreatStatusColor = {
	[0] = { 0.7, 0.7, 0.7 },
	[1] = { 1, 1, 0.47 },
	[2] = { 1, 0.5, 0 },
	[3] = { 0.6, 0, 0 },
}
local UpdateAggro = function(self)
	local status = UnitThreatSituation and UnitThreatSituation(self.displayedUnit)
	if (status and status > 0) then
		self.aggro:SetVertexColor(ThreatStatusColor[status][1], ThreatStatusColor[status][2], ThreatStatusColor[status][3])
		self.aggro:Show()
	else
		self.aggro:Hide()
	end
end

local UpdateReadyCheck = function(frame)
    if (frame.readyCheckDecay and GetReadyCheckTimeLeft() <= 0) then return end

    local readyCheckStatus = GetReadyCheckStatus(frame.unit)

	--print(readyCheckStatus, frame.unit)

    frame.readyCheckStatus = readyCheckStatus
    if readyCheckStatus == "ready" then
        frame.readyCheckIcon:SetTexture(READY_CHECK_READY_TEXTURE)
        frame.readyCheckIcon:Show()
    elseif readyCheckStatus == "notready" then
        frame.readyCheckIcon:SetTexture(READY_CHECK_NOT_READY_TEXTURE)
        frame.readyCheckIcon:Show()
    elseif readyCheckStatus == "waiting" then
        frame.readyCheckIcon:SetTexture(READY_CHECK_WAITING_TEXTURE)
        frame.readyCheckIcon:Show()
    else
        frame.readyCheckIcon:Hide()
    end
end

local FinishReadyCheck = function(frame)
    frame.readyCheckEnd = true
    if frame.readyCheckStatus == "waiting" then
        frame.readyCheckIcon:SetTexture(READY_CHECK_NOT_READY_TEXTURE)
        frame.readyCheckIcon:Show()
    end
end

local CheckReadyCheckDecay = function(frame, elapsed)
    if frame.readyCheckEnd == false then

        if frame.readyCheckDecay > 1 then
            frame.readyCheckDecay = frame.readyCheckDecay + elapsed
        else
		--	print("UpdateReadyCheck(frame)", frame.readyCheckDecay)
            frame.readyCheckDecay = 0
            UpdateReadyCheck(frame)
        end
	else
		if ( GetReadyCheckTimeLeft() <= 0 ) then

			if not frame.readyCheckDecay then frame.readyCheckDecay = 0 end

			frame.readyCheckDecay = frame.readyCheckDecay + elapsed

			if frame.readyCheckDecay > 5 then

				frame.readyCheckIcon:Hide()
			end
		end
    end
end

local UpdateCenterStatusIcon = function(frame)
	if ( UnitInOtherParty(frame.unit) ) then
		frame.centerStatusIcon.texture:SetTexture("Interface\\LFGFrame\\LFG-Eye");
		frame.centerStatusIcon.texture:SetTexCoord(0.125, 0.25, 0.25, 0.5);
		frame.centerStatusIcon.border:SetTexture("Interface\\Common\\RingBorder");
		frame.centerStatusIcon.border:Show();
		frame.centerStatusIcon:Show();
	elseif (  UnitHasIncomingResurrection(frame.unit) ) then
		frame.centerStatusIcon.texture:SetTexture("Interface\\RaidFrame\\Raid-Icon-Rez");
		frame.centerStatusIcon.texture:SetTexCoord(0, 1, 0, 1);
		frame.centerStatusIcon.border:Hide();
		frame.centerStatusIcon:Show();
	elseif (  C_IncomingSummon and C_IncomingSummon.HasIncomingSummon(frame.unit) ) then
		local status = C_IncomingSummon.IncomingSummonStatus(frame.unit);
		if(status == Enum.SummonStatus.Pending) then
			frame.centerStatusIcon.texture:SetAtlas("Raid-Icon-SummonPending");
			frame.centerStatusIcon.texture:SetTexCoord(0, 1, 0, 1);
			frame.centerStatusIcon.border:Hide();
			frame.centerStatusIcon:Show();
		elseif( status == Enum.SummonStatus.Accepted ) then
			frame.centerStatusIcon.texture:SetAtlas("Raid-Icon-SummonAccepted");
			frame.centerStatusIcon.texture:SetTexCoord(0, 1, 0, 1);
			frame.centerStatusIcon.border:Hide();
			frame.centerStatusIcon:Show();
		elseif( status == Enum.SummonStatus.Declined ) then
			frame.centerStatusIcon.texture:SetAtlas("Raid-Icon-SummonDeclined");
			frame.centerStatusIcon.texture:SetTexCoord(0, 1, 0, 1);
			frame.centerStatusIcon.border:Hide();
			frame.centerStatusIcon.tooltip = INCOMING_SUMMON_TOOLTIP_SUMMON_DECLINED;
			frame.centerStatusIcon:Show();
		end
	elseif ( frame.inDistance and (not UnitInPhase(frame.unit))) then
		frame.centerStatusIcon.texture:SetTexture("Interface\\TargetingFrame\\UI-PhasingIcon");
		frame.centerStatusIcon.texture:SetTexCoord(0.15625, 0.84375, 0.15625, 0.84375);
		frame.centerStatusIcon.border:Show();
		frame.centerStatusIcon:Show();
	else
		frame.centerStatusIcon:Hide();
	end
end

local function UpdateDistance(frame)
	local distance, checkedDistance = UnitDistanceSquared(frame.displayedUnit);

	if ( checkedDistance ) then
		local inDistance = distance < DISTANCE_THRESHOLD_SQUARED;
		if ( inDistance ~= frame.inDistance ) then
			frame.inDistance = inDistance;
			UpdateCenterStatusIcon(frame);
		end
	end
end

local function UpdateTargetBorder(self)
	if UnitIsUnit(self.displayedUnit, "target") then
		self.border:Show()
	else
		self.border:Hide()
	end
end

local function UtilShouldDisplayBuff(spellId, unitCaster, canApplyAura)
	local hasCustom, alwaysShowMine, showForMySpec = SpellGetVisibilityInfo(spellId, UnitAffectingCombat("player") and "RAID_INCOMBAT" or "RAID_OUTOFCOMBAT");

	if ( hasCustom ) then
		return showForMySpec or (alwaysShowMine and (unitCaster == "player" or unitCaster == "pet" or unitCaster == "vehicle"));
	else
		return (unitCaster == "player" or unitCaster == "pet" or unitCaster == "vehicle") and canApplyAura and not SpellIsSelfBuff(spellId);
	end
end

local function UtilSetBuff(buffFrame, index, icon, count, expirationTime, duration)

	buffFrame.icon:SetTexture(icon);
	if ( count > 1 ) then
		local countText = count;
		if ( count >= 99 ) then
			countText = BUFF_STACKS_OVERFLOW;
		end
		buffFrame.count:Show();
		buffFrame.count:SetText(countText);
	else
		buffFrame.count:Hide();
	end
	--buffFrame:SetID(index);
	if ( expirationTime and expirationTime ~= 0 ) then
		local startTime = expirationTime - duration;
		buffFrame.cooldown:SetCooldown(startTime, duration);
		buffFrame.cooldown:Show();
	else
		buffFrame.cooldown:Hide();
	end
	buffFrame:Show();
end

local function UtilSetIndicator(frame, expirationTime, duration, color)
	if ( expirationTime and expirationTime ~= 0 ) then
		local startTime = expirationTime - duration;
		frame.cooldown:SetCooldown(startTime, duration);
		frame.cooldown:Show();
	else
		frame.cooldown:Hide();
	end
	frame:Show();
	frame.icon:SetColorTexture(color[1], color[2], color[3], 1)
end

local indicatorDefaultColor = {
	['topleft'] = { 0, 1, 0, 1 },
	['topright'] = { 1, 1, 0, 1 },
	['bottomleft'] = { 1, 0, 1, 1 },
	['bottomright'] = { 1, 0, 0, 1 },
}
local indicatorDefaultMapping = {
	['topleft'] = 'topLeftIndicator',
	['topright'] = 'topRightIndicator',
	['bottomleft'] = 'bottomLeftIndicator',
	['bottomright'] = 'bottomRightIndicator',
}

local function UtilIsIndicatorSpell(name, spellId, unitCaster)
	if ( unitCaster == 'player' or unitCaster == 'pet' or unitCaster == 'vehicle' ) and E.chardb.raidFramesSettings.indicators[E.myclass] then
		local spec = GetSpecialization()
		local data = spec and E.chardb.raidFramesSettings.indicators[E.myclass][spec] or false

		if data then
			if data['topleft'] and data['topleft'].enable and ( data['topleft'].spellID == name or tonumber(data['topleft'].spellID or '') == spellId )  then
				return true
			elseif data['topright'] and data['topright'].enable and ( data['topright'].spellID == name or tonumber(data['topright'].spellID or '') == spellId ) then
				return true
			elseif data['bottomleft'] and data['bottomleft'].enable and ( data['bottomleft'].spellID == name or tonumber(data['bottomleft'].spellID or '') == spellId ) then
				return true
			elseif data['bottomright'] and data['bottomright'].enable and ( data['bottomright'].spellID == name or tonumber(data['bottomright'].spellID or '')== spellId )  then
				return true
			end
		end
	end

	return false
end

local function SetIndicatorSpell(frame, name, expirationTime, duration, spellId)
	if E.chardb.raidFramesSettings.indicators[E.myclass] then
		local spec = GetSpecialization()
		local data = spec and E.chardb.raidFramesSettings.indicators[E.myclass][spec] or false

		if data then
			local p = 'topleft'
			if data[p] and data[p].enable and ( data[p].spellID == name or tonumber(data[p].spellID or '') == spellId )  then
				UtilSetIndicator(frame[indicatorDefaultMapping[p]], expirationTime, duration, data[p].color or indicatorDefaultColor[p])
			end

			p = 'topright'
			if data[p] and data[p].enable and ( data[p].spellID == name or tonumber(data[p].spellID or '') == spellId )  then
				UtilSetIndicator(frame[indicatorDefaultMapping[p]], expirationTime, duration, data[p].color or indicatorDefaultColor[p])
			end

			p = 'bottomleft'
			if data[p] and data[p].enable and ( data[p].spellID == name or tonumber(data[p].spellID or '') == spellId )  then
				UtilSetIndicator(frame[indicatorDefaultMapping[p]], expirationTime, duration, data[p].color or indicatorDefaultColor[p])
			end

			p = 'bottomright'
			if data[p] and data[p].enable and ( data[p].spellID == name or tonumber(data[p].spellID or '') == spellId )  then
				UtilSetIndicator(frame[indicatorDefaultMapping[p]], expirationTime, duration, data[p].color or indicatorDefaultColor[p])
			end
		end
	end
end
--[==[
local function UtilCheckIndicatorSpell(frame, unit, position)
	if E.chardb.raidFramesSettings.indicators[E.myclass] then
		local spec = GetSpecialization()
		local data = spec and E.chardb.raidFramesSettings.indicators[E.myclass][spec] or false

		if data and data[position] and data[position].enable then
			local name = tonumber(data[position].spellID or '') and GetSpellInfo(tonumber(data[position].spellID)) or data[position].spellID or false

			if name then
				local _, _, count, _, duration, expirationTime, _, _, _, spellId = AuraUtil.FindAuraByName(name, unit, "HELPFUL")
				
				if expirationTime and duration then
					UtilSetIndicator(frame[indicatorDefaultMapping[position]], expirationTime, duration, data[position].color or indicatorDefaultColor[position])
					return
				end
			end
		end
	end
	frame[indicatorDefaultMapping[position]]:Hide()
end
]==]
--[==[

	showtopLeft = ( indicatorSpell == 'topLeftIndicator' )
				showtopRight = ( indicatorSpell == 'topRightIndicator' )
				showbottomLeft = ( indicatorSpell == 'bottomLeftIndicator' )
				showbottomRight = ( indicatorSpell == 'bottomRightIndicator' )

				UtilSetIndicator(frame[indicatorSpell], frame.displayedUnit, index, filter, indicatorColor)

]==]
local function UpdateBuffs(frame)

	local index = 1;
	local frameNum = 1;
	local filter = "RAID";
	local name, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, nameplateShowPersonal, spellId, canApplyAura, isBossAura;

	index = 1;
	filter = nil;
	
	
	frame[indicatorDefaultMapping['topleft']]:Hide()
	frame[indicatorDefaultMapping['topright']]:Hide()
	frame[indicatorDefaultMapping['bottomleft']]:Hide()
	frame[indicatorDefaultMapping['bottomright']]:Hide()
	
	while ( true ) do
		name, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, nameplateShowPersonal, spellId, canApplyAura, isBossAura = UnitBuff(frame.displayedUnit, index, filter);
		
		if ( name ) then

			--print(name)

			if UtilIsIndicatorSpell(name, spellId, unitCaster) then
				-- Skip this
				SetIndicatorSpell(frame, name, expirationTime, duration, spellId)

				--print('SetIndicatorSpell', name)
			elseif ( frameNum <= frame.maxBuffsShow and UtilShouldDisplayBuff(spellId, unitCaster, canApplyAura) and not isBossAura ) then
				UtilSetBuff(frame.buffFrames[frameNum], index, icon, count, expirationTime, duration)

				--print('UtilSetBuff', name)

				frameNum = frameNum + 1;
			else
				--print('Skip spell', name)

			end
		else
			break;
		end
		index = index + 1;
	end
	
	for i=frameNum, frame.maxBuffs do
		frame.buffFrames[i]:Hide();
	end
end

local function UtilShouldDisplayDebuff(spellId, unitCaster)
	if spellId == 206151 then
		return false
	end

	local hasCustom, alwaysShowMine, showForMySpec = SpellGetVisibilityInfo(spellId, UnitAffectingCombat("player") and "RAID_INCOMBAT" or "RAID_OUTOFCOMBAT");
	if ( hasCustom ) then
		return showForMySpec or (alwaysShowMine and (unitCaster == "player" or unitCaster == "pet" or unitCaster == "vehicle") );	--Would only be "mine" in the case of something like forbearance.
	else
		return true;
	end
end

local function UtilIsPriorityDebuff(spellId)
	if ( E.myclass == "PALADIN" ) then
		if ( spellId == 25771 ) then	--Forbearance
			return true;
		end
	end

	return false;
end

local function UtilSetDebuff(debuffFrame, index, filter, icon, count, expirationTime, duration, debuffType, isBossAura, isBossBuff)
	-- make sure you are using the correct index here!
	--isBossAura says make this look large.
	--isBossBuff looks in HELPFULL auras otherwise it looks in HARMFULL ones

	debuffFrame.filter = filter;
	debuffFrame.icon:SetTexture(icon);
	if ( count > 1 ) then
		local countText = count;
		if ( count >= 99 ) then
			countText = BUFF_STACKS_OVERFLOW;
		end
		debuffFrame.count:Show();
		debuffFrame.count:SetText(countText);
	else
		debuffFrame.count:Hide();
	end
	--debuffFrame:SetID(index);
	if ( expirationTime and expirationTime ~= 0 ) then
		local startTime = expirationTime - duration;
		CooldownFrame_Set(debuffFrame.cooldown, startTime, duration, true);
	else
		CooldownFrame_Clear(debuffFrame.cooldown);
	end

	local color = DebuffTypeColor[debuffType] or DebuffTypeColor["none"];

	if debuffFrame._color_r ~= color.r or 
		debuffFrame._color_g ~= color.g or 
		debuffFrame._color_b ~= color.b then

			debuffFrame._color_r = color.r
			debuffFrame._color_g = color.g
			debuffFrame._color_b = color.b

		debuffFrame:SetBackdropBorderColor(color.r, color.g, color.b, 1);
	end

	debuffFrame.isBossBuff = isBossBuff;
	if ( isBossAura ) then
		debuffFrame:SetSize(options.debuffSizeBig, options.debuffSizeBig);
	else
		debuffFrame:SetSize(debuffFrame.baseSize, debuffFrame.baseSize);
	end

	debuffFrame:Show();
end

local function UpdateDebuffs(frame)

	local index = 1;
	local frameNum = 1;
	local filter = nil;
	local maxDebuffs = frame.maxDebuffsShow;
	local dispelColor = nil
	local name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, nameplateShowPersonal, spellId, canApplyAura, isBossAura;

	--Show both Boss buffs & debuffs in the debuff location
	--First, we go through all the debuffs looking for any boss flagged ones.
	while ( frameNum <= maxDebuffs ) do
		name, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, nameplateShowPersonal, spellId, canApplyAura, isBossAura = UnitDebuff(frame.displayedUnit, index, filter);
		if ( name ) then
			if ( isBossAura ) then
				local debuffFrame = frame.debuffFrames[frameNum];

				UtilSetDebuff(debuffFrame, index, filter, icon, count, expirationTime, duration, debuffType, isBossAura, false)

				frameNum = frameNum + 1;
				--Boss debuffs are about twice as big as normal debuffs, so display one less.
				local bossDebuffScale = (options.debuffSizeBig)/debuffFrame.baseSize
				maxDebuffs = maxDebuffs - (bossDebuffScale - 1);
			end
		else
			break;
		end
		index = index + 1;
	end

	--Now we go through the debuffs with a priority (e.g. Weakened Soul and Forbearance)
	index = 1;
	while ( true ) do
		name, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, nameplateShowPersonal, spellId, canApplyAura, isBossAura = UnitDebuff(frame.displayedUnit, index, filter);
		if ( name ) then
			if UtilIsIndicatorSpell(name, spellId, unitCaster) then
				-- Skip this
				SetIndicatorSpell(frame, name, expirationTime, duration, spellId)
			elseif ( frameNum <= maxDebuffs and UtilIsPriorityDebuff(spellId) ) then
				local debuffFrame = frame.debuffFrames[frameNum];

				UtilSetDebuff(debuffFrame, index, filter, icon, count, expirationTime, duration, debuffType, false, false)

				frameNum = frameNum + 1;
			end
		else
			break;
		end
		index = index + 1;
	end

	if ( displayOnlyDispellableDebuffs ) then
		filter = "RAID";
	end

	index = 1;
	--Now, we display all normal debuffs.
	if ( true ) then -- frame.optionTable.displayNonBossDebuffs
		while ( true ) do
			name, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, nameplateShowPersonal, spellId, canApplyAura, isBossAura = UnitDebuff(frame.displayedUnit, index, filter);
			if ( name ) then

				if UtilIsIndicatorSpell(name, spellId, unitCaster) then
					-- Skip this
					SetIndicatorSpell(frame, name, expirationTime, duration, spellId)
				elseif ( frameNum <= maxDebuffs and UtilShouldDisplayDebuff(spellId, unitCaster, canApplyAura) and not isBossAura and not UtilIsPriorityDebuff(spellId)) then
					local debuffFrame = frame.debuffFrames[frameNum];
					
					UtilSetDebuff(debuffFrame, index, filter, icon, count, expirationTime, duration, debuffType, false, false)

					frameNum = frameNum + 1;
				end
			else
				break;
			end
			index = index + 1;
		end
	end

	for i=frameNum, frame.maxDebuffs do
		local debuffFrame = frame.debuffFrames[i];
		debuffFrame:Hide();
	end


	index = 1;
	while true do
		name, icon, count, debuffType = UnitDebuff(frame.displayedUnit, index, 'RAID');

		if ( name ) then
			if debuffType and E.dispellList and E.dispellList[debuffType] then
				dispelColor = debuffType
				break;
			end
		else
			break;
		end
		index = index + 1;
	end


	if dispelColor then
		local color = DebuffTypeColor[dispelColor] or DebuffTypeColor["none"];
		frame.health.dispellOverlay:SetVertexColor(color.r*1.2, color.g*1.2, color.b*1.2, 0.2)
	else
		frame.health.dispellOverlay:SetVertexColor(1, 0, 0, 0)
	end
end

UpdateAll = function(self)
	if not self.displayedUnit then return end
	UpdateColor(self)
	UpdateName(self)
	UpdateHealth(self)
	UpdatePower(self)
	UpdateHealPrediction(self)
	UpdateRole(self)
	UpdateAggro(self)
	UpdateReadyCheck(self)
	UpdateDistance(self)
	UpdateCenterStatusIcon(self)
	UpdateRaidTargetIndex(self)
	UpdateTargetBorder(self)

	UpdateBuffs(self)
	UpdateDebuffs(self)
end

local eventList = {
	["UNIT_MAXHEALTH"] = true,
	[UNIT_HEALTH_EVENT] = true,
	["UNIT_POWER_UPDATE"] = true,
	["UNIT_MAXPOWER"] = true,

	["UNIT_PHASE"] = true,
	["UNIT_AURA"] = true,
	['UNIT_FLAGS'] = true,
	["UNIT_OTHER_PARTY_CHANGED"] = true,
	
	['PLAYER_FLAGS_CHANGED'] = true, 

	["UNIT_CONNECTION"] = true,
	["UNIT_DISPLAYPOWER"] = true,

	["UNIT_NAME_UPDATE"] = true,
	

	["PLAYER_ROLES_ASSIGNED"] = false,
	["PLAYER_LOGIN"] = false,

	["UNIT_POWER_BAR_SHOW"] = false,
	["PLAYER_TARGET_CHANGED"] = false,
	["PLAYER_REGEN_ENABLED"] = false,
	["PLAYER_REGEN_DISABLED"] = false,
	["RAID_TARGET_UPDATE"] = false,
	["READY_CHECK"] = false,
	["READY_CHECK_CONFIRM"] = true,
	["READY_CHECK_FINISHED"] = false,
	["PLAYER_ENTERING_WORLD"] = false,

	["PLAYER_DEAD"] = false,
	['PLAYER_ALIVE'] = false,
}

if not E.isClassic then 
	eventList["UNIT_HEAL_PREDICTION"] = true
	eventList["UNIT_HEAL_ABSORB_AMOUNT_CHANGED"] = true

	eventList["UNIT_THREAT_SITUATION_UPDATE"] = true
	eventList["UNIT_ABSORB_AMOUNT_CHANGED"] = true

	eventList['INCOMING_SUMMON_CHANGED'] = true
	eventList["INCOMING_RESURRECT_CHANGED"] = true

	eventList["UNIT_ENTERED_VEHICLE"] = true
	eventList["UNIT_EXITED_VEHICLE"] = true
end 

local function UnitFrameHandler(self, event, ...)
	local unit = ...

	-- if ( eventList[event] ~= nil ) then 
	-- 	if ( eventList[event] == false and unit ) then 
	-- 		print('EVENT WITH UNIT', event, unit) 
	-- 	end
	-- end 


	if event == "PLAYER_ENTERING_WORLD" or event == "PLAYER_LOGIN" then
		UpdateAll(self)
	elseif event == "PLAYER_TARGET_CHANGED" then
		UpdateTargetBorder(self)
	elseif event == "PLAYER_ROLES_ASSIGNED" or event == "UNIT_ENTERED_VEHICLE" or event == "UNIT_EXITED_VEHICLE" then
		UpdateRole(self)
	elseif event == "READY_CHECK_CONFIRM" then
		UpdateReadyCheck(self)
	elseif event == "READY_CHECK" then
		self.readyCheckDecay = 0
		self.readyCheckEnd = false
		UpdateReadyCheck(self)
	elseif event == "READY_CHECK_FINISHED" then
		FinishReadyCheck(self)
	elseif event == "RAID_TARGET_UPDATE" then
		UpdateRaidTargetIndex(self)
	elseif event == "PLAYER_REGEN_ENABLED" then
		UpdateBuffs(self)
		UpdateDebuffs(self)

	--	self.auratr = ( self.updateaura and 0.5 or 0 )
	--	self.updateaura = true
	elseif event == "PLAYER_REGEN_DISABLED" then
		UpdateBuffs(self)
		UpdateDebuffs(self)
	--	self.auratr = ( self.updateaura and 0.5 or 0 )
	--	self.updateaura = true
	elseif unit and (unit == self.displayedUnit or unit == self.unit) then
		if event == "UNIT_HEALTH" or event == "UNIT_MAXHEALTH" or event == "UNIT_HEALTH_FREQUENT" then
			UpdateHealth(self)
			UpdateHealPrediction(self)
		elseif event == 'UNIT_AURA' then
			UpdateBuffs(self)
			UpdateDebuffs(self)
		--	self.auratr = ( self.updateaura and 0.5 or 0 )
		--	self.updateaura = true
		elseif event == "UNIT_THREAT_SITUATION_UPDATE" then
			UpdateAggro(self)
		elseif event == "UNIT_NAME_UPDATE" then
		
			--print('T', event, 'unit=', unit, UnitName(unit), 'self.displayedUnit=', self.displayedUnit, 'self.unit=', self.unit)
			
			UpdateColor(self)
			UpdateName(self)
		elseif event == "UNIT_CONNECTION" or event == "PLAYER_DEAD" or event == 'PLAYER_ALIVE' then
		
			--print('T', event, 'unit=', unit, UnitName(unit), 'self.displayedUnit=', self.displayedUnit, 'self.unit=', self.unit)
		
			UpdateColor(self)
			UpdateStatus(self)
			UpdateName(self)
		elseif event == "UNIT_POWER_UPDATE" or event == "UNIT_MAXPOWER" or event == "UNIT_DISPLAYPOWER" or event == "UNIT_POWER_BAR_SHOW" then
			UpdatePower(self)
		elseif event == "UNIT_HEAL_PREDICTION" then
			UpdateHealPrediction(self)
		elseif event == "UNIT_HEAL_ABSORB_AMOUNT_CHANGED" then
			UpdateHealPrediction(self)
		elseif event == "INCOMING_RESURRECT_CHANGED" then
			UpdateCenterStatusIcon(self)
		elseif event == "UNIT_OTHER_PARTY_CHANGED" then
			UpdateCenterStatusIcon(self)
		elseif event == "UNIT_ABSORB_AMOUNT_CHANGED" then
			UpdateHealPrediction(self)
		elseif event == "UNIT_PHASE" or event == 'UNIT_FLAGS' then
			UpdateCenterStatusIcon(self)
		end
	end
end

local function UnitFrameOnUpdateHandler(self, elapsed)
	self.st = (self.st or 0 ) + elapsed
	if self.st > .5 then
		if UnitIsUnit(self.displayedUnit, "player") then
			self:SetAlpha(1)
		elseif not UnitInRange(self.displayedUnit) then
			self:SetAlpha(.4)
		else
			self:SetAlpha(1)
		end
		self.st = 0
	end

	--[==[
	if self.updateaura then
		self.auratr = ( self.auratr or 0 ) + elapsed
		if self.auratr > 0.1 then
			self.auratr = 0
			self.updateaura = false

			UpdateBuffs(self)
			UpdateDebuffs(self)
		end
	end
	]==]
	
	UpdateDistance(self)
	CheckReadyCheckDecay(self, elapsed)
end

local function RaidUnitFrame_ToggleEvents(self)
	local unit = self.prevunit

	if unit then
	
		if UnitIsUnit('player', unit) then
			unit = 'player'
		end

		local unitChanged = false 

		if ( self.unit ~= unit or self.displayedUnit ~= unit ) then 
			unitChanged = true 
		end
		
		self.unit = unit
		self.displayedUnit = unit

		if self.enabled ~= true then
			self.enabled = true

			self:SetScript("OnUpdate", UnitFrameOnUpdateHandler)
			self:SetScript("OnEvent", UnitFrameHandler)

		--	print('Enable frame:1. Hidden=',self.prevhidden, '. Unit=',self.prevunit, UnitName(unit), UnitClass(unit), UnitGUID(unit))
		end

		if UnitGUID(unit) ~= self.lastGUID or unitChanged then
			self.lastGUID = UnitGUID(unit)

			for event, unitSpecific in pairs(eventList) do

				if ( unitSpecific ) then 
					self:RegisterUnitEvent(event, unit, unit)
				else 
					self:RegisterEvent(event)
				end
			end

			UpdateAll(self)

		--	print('Enable frame:2. Hidden=',self.prevhidden, '. Unit=',self.prevunit, UnitName(unit), UnitClass(unit), UnitGUID(unit))
		end
	else
		self.unit = nil
		self.displayedUnit = nil
		self.lastGUID = nil

		if self.enabled ~= false then
			self.enabled = false

			self:UnregisterAllEvents()

			self:SetScript("OnUpdate", nil)
			self:SetScript("OnEvent", nil)

		--	print('Disable frame. Hidden=',self.prevhidden, '. Unit=',self.prevunit)
		end
	end
end

function OnChangeAttribute(self, attribute, unit)
	if attribute == 'unit' then
	
		--print('OnChangeAttribute', 'unit', unit)
		
		self.prevunit = unit
		RaidUnitFrame_ToggleEvents(self)
	elseif attribute == 'statehidden' then
	
		--print('OnChangeAttribute', 'statehidden', unit)
		
		self.prevhidden = unit
		RaidUnitFrame_ToggleEvents(self)
	end
end

------------------------------------
-- Unit Frame Artwork
------------------------------------
local AuraBackdrop = {
	bgFile = [[Interface\Buttons\WHITE8x8]],
	edgeFile =	[[Interface\Buttons\WHITE8x8]],
	edgeSize = 1,
}

local FrameBorders = {
	bgFile = "Interface\\Buttons\\WHITE8x8",
	tile = true,
	tileSize = 0,
	insets = {
		left = -mult,
		right = -mult,
		top = -mult,
		bottom = -mult
	}
}

local function UpdateStatusBarTexture(self)
	local texture = E:GetTexture(options.texture)

	self.health:SetStatusBarTexture(texture)
	self.health:SetOrientation(options.horizontalFill and 'HORIZONTAL' or 'VERTICAl')
	self.power:SetStatusBarTexture(texture)

	E:SetSmoothBar(self.health, options.smoothBars)
	E:SetSmoothBar(self.power, options.smoothBars)

	if options.horizontalFill then
		self.health.bg:ClearAllPoints()
		self.health.bg:SetPoint('TOPLEFT', self.health.statusBarTexture, 'TOPRIGHT', 0, 0)
		self.health.bg:SetPoint('BOTTOMRIGHT', self.health, 'BOTTOMRIGHT', 0, 0)

		self.health.totalHealPrediction:ClearAllPoints()
		self.health.totalHealPrediction:SetPoint('LEFT', self.health, 'LEFT', 0, 0)

		self.health.totalAbsorb:ClearAllPoints()
		self.health.totalAbsorb:SetPoint('LEFT', self.health, 'LEFT', 0, 0)

		self.health.totalHealAbsorb:ClearAllPoints()
		self.health.totalHealAbsorb:SetPoint('TOPRIGHT', self.health.statusBarTexture, 'TOPRIGHT', 0, 0)
		self.health.totalHealAbsorb:SetPoint('BOTTOMRIGHT', self.health.statusBarTexture, 'BOTTOMRIGHT', 0, 0)

	else
		self.health.bg:ClearAllPoints()
		self.health.bg:SetPoint('BOTTOMLEFT', self.health.statusBarTexture, 'TOPLEFT', 0, 0)
		self.health.bg:SetPoint('TOPRIGHT', self.health, 'TOPRIGHT', 0, 0)

		self.health.totalHealPrediction:ClearAllPoints()
		self.health.totalHealPrediction:SetPoint('BOTTOM', self.health, 'BOTTOM', 0, 0)

		self.health.totalAbsorb:ClearAllPoints()
		self.health.totalAbsorb:SetPoint('BOTTOM', self.health, 'BOTTOM', 0, 0)

		self.health.totalHealAbsorb:ClearAllPoints()
		self.health.totalHealAbsorb:SetPoint('TOPLEFT', self.health.statusBarTexture, 'TOPLEFT', 0, 0)
		self.health.totalHealAbsorb:SetPoint('TOPRIGHT', self.health.statusBarTexture, 'TOPRIGHT', 0, 0)
	end

	if options.showPowerBars  then
		self.health:SetPoint("TOPLEFT", 0, 0)
		self.health:SetPoint("BOTTOMRIGHT", 0, 5)
		self.power:Show()
	else
		self.health:SetAllPoints()
		self.power:Hide()
	end

	self.health.totalHealPrediction:SetTexture(texture)
	self.health.totalHealPrediction:SetVertexColor(E.db.unitframes.colors.otherHeal[1],
		E.db.unitframes.colors.otherHeal[2],E.db.unitframes.colors.otherHeal[3],E.db.unitframes.colors.otherHeal[4])
	--[==[
	self.health.overAbsorbGlow:SetVertexColor(E.db.unitframes.colors.otherHeal[1],
		E.db.unitframes.colors.otherHeal[2],E.db.unitframes.colors.otherHeal[3],1)
	]==]
	self.health.totalAbsorb:SetTexture(texture)
	self.health.totalAbsorb:SetVertexColor(E.db.unitframes.colors.otherAbsorb[1],
		E.db.unitframes.colors.otherAbsorb[2],E.db.unitframes.colors.otherAbsorb[3],E.db.unitframes.colors.otherAbsorb[4])
	--[==[
	self.health.overAbsorbGlow:SetVertexColor(E.db.unitframes.colors.otherAbsorb[1],
		E.db.unitframes.colors.otherAbsorb[2],E.db.unitframes.colors.otherAbsorb[3],E.db.unitframes.colors.otherAbsorb[4])
	]==]

	self.health.totalHealAbsorb:SetTexture(texture)
	self.health.totalHealAbsorb:SetVertexColor(E.db.unitframes.colors.myHealAbsorb[1],
		E.db.unitframes.colors.myHealAbsorb[2],E.db.unitframes.colors.myHealAbsorb[3],E.db.unitframes.colors.myHealAbsorb[4])
	--[==[
	self.health.overHealAbsorbGlow:SetVertexColor(E.db.unitframes.colors.myHealAbsorb[1],
		E.db.unitframes.colors.myHealAbsorb[2],E.db.unitframes.colors.myHealAbsorb[3],1)
		]==]
end

local function UpdateFontStyle(self)
	self.text:SetFont(E:GetFont(options.font), (options.fontSize or 10), "OUTLINE")
	self.text2:SetFont(E:GetFont(options.font), (options.fontSize or 10), "OUTLINE")
end

local function UpdateBuffAndDebuff(self)

	local auraPos, auraOffset, auraOffsetBuff, auraOffsetDebuff;

	if ( options.showPowerBars ) then
		auraPos = "TOP";
		auraOffset = 2 + 4 + options.auraSize;
		auraOffsetBuff = 2 + 4 + options.buffSize;
		auraOffsetDebuff  = 2 + 4 + options.debuffSize;
	else
		auraPos = "BOTTOM";
		auraOffset = 2;
		auraOffsetBuff = 2
		auraOffsetDebuff  = 2
	end

	local buffPos, buffRelativePoint, buffOffset = auraPos.."RIGHT", auraPos.."LEFT", auraOffsetBuff;
	self.buffFrames[1]:ClearAllPoints();
	self.buffFrames[1]:SetPoint(buffPos, self, "BOTTOMRIGHT", -3, buffOffset);
	for i=1, #self.buffFrames do
		if ( i > 1 ) then
			self.buffFrames[i]:ClearAllPoints();
			self.buffFrames[i]:SetPoint(buffPos, self.buffFrames[i - 1], buffRelativePoint, 0, 0);
		end
		self.buffFrames[i]:SetSize(options.buffSize, options.buffSize);
	end

	local debuffPos, debuffRelativePoint, debuffOffset = auraPos.."LEFT", auraPos.."RIGHT", auraOffsetDebuff;
	self.debuffFrames[1]:ClearAllPoints();
	self.debuffFrames[1]:SetPoint(debuffPos, self, "BOTTOMLEFT", 3, debuffOffset);
	for i=1, #self.debuffFrames do
		if ( i > 1 ) then
			self.debuffFrames[i]:ClearAllPoints();
			self.debuffFrames[i]:SetPoint(debuffPos, self.debuffFrames[i - 1], debuffRelativePoint, 0, 0);
		end
		self.debuffFrames[i].baseSize = options.debuffSize;
	end

	--[[
	self.dispelDebuffFrames[1]:SetPoint("TOPRIGHT", -3, -2);
	for i=1, #self.dispelDebuffFrames do
		if ( i > 1 ) then
			self.dispelDebuffFrames[i]:SetPoint("RIGHT", self.dispelDebuffFrames[i - 1], "LEFT", 0, 0);
		end
		self.dispelDebuffFrames[i]:SetSize(12, 12);
	end
	]]

	self.maxBuffsShow = options.amountBuffs
	self.maxDebuffsShow = options.amountDebuffs
end

function RF:InterateArtElements(...)
	for i=1, select('#', ...) do
		local func = select(i, ...)
		for frame in pairs(ArtElements) do
			frame[func](frame)
		end
	end
end

local function NewBorder(point, layer, level)
	local border = {}
	border.point = point
	local size = 2
	border.size = size
	for i=1, 4 do
		local b = point:CreateTexture()
		b:SetDrawLayer(layer, level)
		b:Hide()
		b:SetSize(size, size)
		b:SetTexture([[Interface\Buttons\WHITE8x8]])
		b:SetVertexColor(1,1,1,1)
		border[i] = b
	end

	border[1]:SetPoint("TOPLEFT", point, 'TOPLEFT',         0, -size) -- left
	border[1]:SetPoint("BOTTOMLEFT", point, 'BOTTOMLEFT',   0, size)

	border[2]:SetPoint("TOPLEFT", point, 'TOPLEFT',         0, 0) -- top
	border[2]:SetPoint("TOPRIGHT", point, 'TOPRIGHT',       0, 0)

	border[3]:SetPoint("TOPRIGHT", point, 'TOPRIGHT',       0, -size) -- right
	border[3]:SetPoint("BOTTOMRIGHT", point, 'BOTTOMRIGHT', 0, size)

	border[4]:SetPoint("BOTTOMRIGHT", point, 'BOTTOMRIGHT', 0, 0) -- bottom
	border[4]:SetPoint("BOTTOMLEFT", point, 'BOTTOMLEFT',   0, 0)

	border.Show = function(self)
		for i=1, 4 do self[i]:Show() end
	end
	border.Hide = function(self)
		for i=1, 4 do self[i]:Hide() end
	end
	border.SetTexture = function(self, r, g, b, a)
		if r and g and b then
			for i=1, 4 do self[i]:SetColorTexture(r, g, b, a) end
		else
			for i=1, 4 do self[i]:SetTexture(r) end
		end
	end
	border.SetSize = function(self, size)
		self.size = size

		for i=1, 4 do self[i]:SetSize(size, size) end
		self[1]:SetPoint("TOPLEFT", self.point, 'TOPLEFT',         0, -size) -- left
		self[1]:SetPoint("BOTTOMLEFT", self.point, 'BOTTOMLEFT',   0, size)

		self[2]:SetPoint("TOPLEFT", self.point, 'TOPLEFT',         0, 0) -- top
		self[2]:SetPoint("TOPRIGHT", self.point, 'TOPRIGHT',       0, 0)

		self[3]:SetPoint("TOPRIGHT", self.point, 'TOPRIGHT',       0, -size) -- right
		self[3]:SetPoint("BOTTOMRIGHT", self.point, 'BOTTOMRIGHT', 0, size)

		self[4]:SetPoint("BOTTOMRIGHT", self.point, 'BOTTOMRIGHT', 0, 0) -- bottom
		self[4]:SetPoint("BOTTOMLEFT", self.point, 'BOTTOMLEFT',   0, 0)
	end

	border.SetVertexColor = function(self, r,g,b,a)
		for i=1, 4 do self[i]:SetVertexColor(r, g, b, a) end
	end

	border.SetInside = function(self, point)
		local point = point or self.point
		local size = self.size

		self[1]:ClearAllPoints()
		self[1]:SetPoint("TOPLEFT", self.point, 'TOPLEFT',         0, -size) -- left
		self[1]:SetPoint("BOTTOMLEFT", self.point, 'BOTTOMLEFT',   0, size)

		self[2]:ClearAllPoints()
		self[2]:SetPoint("TOPLEFT", self.point, 'TOPLEFT',         0, 0) -- top
		self[2]:SetPoint("TOPRIGHT", self.point, 'TOPRIGHT',       0, 0)

		self[3]:ClearAllPoints()
		self[3]:SetPoint("TOPRIGHT", self.point, 'TOPRIGHT',       0, -size) -- right
		self[3]:SetPoint("BOTTOMRIGHT", self.point, 'BOTTOMRIGHT', 0, size)

		self[4]:ClearAllPoints()
		self[4]:SetPoint("BOTTOMRIGHT", self.point, 'BOTTOMRIGHT', 0, 0) -- bottom
		self[4]:SetPoint("BOTTOMLEFT", self.point, 'BOTTOMLEFT',   0, 0)
	end

	border.SetOutside = function(self, point)
		local point = point or self.point
		local size = self.size

		self[1]:ClearAllPoints()
		self[1]:SetPoint("TOPRIGHT", self.point, 'TOPLEFT',         0, size) -- left
		self[1]:SetPoint("BOTTOMRIGHT", self.point, 'BOTTOMLEFT',   0, -size)

		self[2]:ClearAllPoints()
		self[2]:SetPoint("BOTTOMLEFT", self.point, 'TOPLEFT',         0, 0) -- top
		self[2]:SetPoint("BOTTOMRIGHT", self.point, 'TOPRIGHT',       0, 0)

		self[3]:ClearAllPoints()
		self[3]:SetPoint("TOPLEFT", self.point, 'TOPRIGHT',       0, size) -- right
		self[3]:SetPoint("BOTTOMLEFT", self.point, 'BOTTOMRIGHT', 0, -size)

		self[4]:ClearAllPoints()
		self[4]:SetPoint("TOPRIGHT", self.point, 'BOTTOMRIGHT', 0, 0) -- bottom
		self[4]:SetPoint("TOPLEFT", self.point, 'BOTTOMLEFT',   0, 0)
	end

	return border
end

do

	local SetMinMaxValues = function(self, minValue, maxValue)
		self.minValue = minValue
		self.maxValue = maxValue

		if self.value then
			if self.value > self.maxValue then
	--			print('SetMinMaxValues:Value is more then maxValue', self.value, self.maxValue)
				self.value = self.maxValue
			elseif self.value < self.minValue then
	--			print('SetMinMaxValues:Value is low then maxValue', self.value, self.minValue)
				self.value = self.minValue
			end
		else
	--		print('SetMinMaxValues:No Value set as maxValue', self.value, self.maxValue)
			self.value = self.maxValue
		end

		self:SetValue(self.value)
	end

	local GetMinMaxValues = function(self)
		return self.minValue, self.maxValue
	end

	local GetValue = function(self)
		return self.value
	end

	local SetValue = function(self, value)
		if value > self.maxValue then
	--		print('SetValue:Value is more then maxValue', value, self.maxValue)
			value = self.maxValue
		elseif value < self.minValue then
	--		print('SetValue:Value is low then minValue', value, self.minValue)
			value = self.minValue
		end

		self.value = value

		local cur = self.value/self.maxValue

		if     cur > 1 then cur = 1
		elseif cur < 0 then cur = 0 end

		local width = self:GetWidth()

		local texWidth = width * cur

		if texWidth > width then
			texWidth = width
		end

		local minV, maxV = self:GetMinMaxValues()

	--	print('SetValue', 'self.value:',self.value, 'self.GetMinMaxValues:', minV, maxV ,'self.GetSize:', self:GetSize(),'self.parent:GetSize:', self.parent:GetSize())

		self.fakeStatusBar:SetWidth(texWidth)
		self.fakeStatusBar:SetTexCoord(0, cur, 0, 1)
	end

	local SetStatusBarTexture = function(self, texture)
		self.fakeStatusBar:SetTexture(texture)
	end

	local SetStatusBarColor = function(self, r,g,b,a)
		self.fakeStatusBar:SetVertexColor(r,g,b,a)
	end

	local SetOrientation = function(self, orient)
		self.orientation = orient
	end

	local UpdateBarBySize = function(self)
		self:SetValue(self.value)
	end

	function E.CreateFrameArtElement(typo, name, parent)
		local f
		if typo == 'StatusBar' then

			f = CreateFrame("Frame", name, parent)
			f:SetPoint("TOPLEFT", 0, 0)
			f:SetPoint("BOTTOMRIGHT", 0, 6)

			f.name = name
			f.parent = parent

			f.SetOrientation = SetOrientation
			f.SetMinMaxValues = SetMinMaxValues
			f.GetMinMaxValues = GetMinMaxValues
			f.GetValue = GetValue
			f.SetValue = SetValue
			f.SetStatusBarTexture = SetStatusBarTexture
			f.SetStatusBarColor = SetStatusBarColor

			f:SetScript('OnSizeChanged', UpdateBarBySize) --[==[ function(self)
				print('OnSizeChanged', 'self.parent:GetSize():',self.parent:GetSize(), 'self:GetSize():', self:GetSize(), 'self.fakeStatusBar:GetSize():',self.fakeStatusBar:GetSize())
			end)
			]==]
			f:SetScript('OnShow', UpdateBarBySize) --[==[, function(self)
				print('OnShow', 'self.parent:GetSize():',self.parent:GetSize(), 'self:GetSize():', self:GetSize(), 'self.fakeStatusBar:GetSize():',self.fakeStatusBar:GetSize())
			end)
			]==]

			f.fakeStatusBar = f:CreateTexture()
			f.fakeStatusBar:SetPoint('TOPLEFT', f, 'TOPLEFT', 0, 0)
			f.fakeStatusBar:SetPoint('BOTTOMLEFT', f, 'BOTTOMLEFT', 0, 0)
			f.fakeStatusBar:SetTexture([[Interface\Buttons\WHITE8x8]])
			f.fakeStatusBar:SetVertexColor(.6,.6,.6,1)
		end


		return f
	end

end

local function CustomSetValue(self, value)
	local minv, maxv = self:GetMinMaxValues()

	local parent = self:GetParent()

	local r1, g1, b1, a1

	if parent.classcolor then
		local color = options.color or defaults.color
		r1, g1, b1, a1 = color[1], color[2], color[3], color[4]
	else
		r1, g1, b1, a1 = 0.6,0.2,0.2, 1
	end

	local r, g, b = E:ColorGradient(value, maxv, 0.6, 0, 0, 0.6, 0.6, 0, r1, g1, b1)

	self:SetStatusBarColor(r, g, b, a1)

	self:OldSetValue(value)
end

function CreateUnitFrameArtwork(self)

	ClickCastFrames[self] = true

	self.styled = true

	local groupID, frameID = string.match(self:GetName(), 'AleaUI_GroupHeader(%d+)UnitButton(%d+)')

	self.groupID = groupID
	self.frameID = frameID
	self.UpdateFontStyle = self.UpdateFontStyle or UpdateFontStyle
	self.UpdateStatusBarTexture = self.UpdateStatusBarTexture or UpdateStatusBarTexture
	self.UpdateBuffAndDebuff = self.UpdateBuffAndDebuff or UpdateBuffAndDebuff

	self.health = self.health or CreateFrame('StatusBar', self:GetName()..'HealthBar', self) --E.CreateFrameArtElement('StatusBar', self:GetName()..'HealthBar', self)
	self.health.parent = self
	self.health:SetAllPoints(self)
	self.health:SetOrientation(orient)
	self.health:SetMinMaxValues(0, 100)
	self.health:SetValue(50)

	--if not self.health.OldSetValue then
	--	self.health.OldSetValue = self.health.SetValue
	--	self.health.SetValue = CustomSetValue
	--end

	self.health:SetStatusBarTexture([[Interface\Buttons\WHITE8x8]])

	E:SetSmoothBar(self.health, true)

	local drawLayer, subLayer = "ARTWORK",-5
	self.health.fakeStatusBar = self.health:GetStatusBarTexture()
	self.health.fakeStatusBar:SetDrawLayer(drawLayer, subLayer)

	self.health.statusBarTexture = self.health.fakeStatusBar

	self.health.dispellOverlay = self.health.dispellOverlay or self.health:CreateTexture()
	self.health.dispellOverlay:SetTexture([[Interface\Buttons\WHITE8x8]])
	self.health.dispellOverlay:SetDrawLayer(drawLayer, subLayer+3)
	self.health.dispellOverlay:SetAllPoints()

	self.health.totalHealPrediction = self.health.totalHealPrediction or self.health:CreateTexture()
	self.health.totalHealPrediction:SetTexture(E:GetTexture(options.texture))
	self.health.totalHealPrediction:SetDrawLayer(drawLayer, subLayer+1)
	self.health.totalHealPrediction:SetPoint('LEFT', self.health, 'LEFT', 0, 0)
	self.health.totalHealPrediction:SetVertexColor(0, 1, 0)
	self.health.totalHealPrediction:SetWidth(0)
	self.health.totalHealPrediction:SetHeight(15)

	self.health.totalAbsorb = self.health.totalAbsorb or self.health:CreateTexture()
	self.health.totalAbsorb:SetTexture(E:GetTexture(options.texture))
	self.health.totalAbsorb:SetDrawLayer(drawLayer, subLayer+1)
	self.health.totalAbsorb:SetPoint('LEFT', self.health, 'LEFT', 0, 0)
	self.health.totalAbsorb:SetVertexColor(0, 190/255, 204/255)
	self.health.totalAbsorb:SetWidth(0)
	self.health.totalAbsorb:SetHeight(15)

	self.health.totalHealAbsorb = self.health.totalHealAbsorb or self.health:CreateTexture()
	--self.health.totalHealAbsorb:SetTexture("Interface\\RaidFrame\\Absorb-Fill", true, true);
	self.health.totalHealAbsorb:SetTexture(E:GetTexture(options.texture))
	self.health.totalHealAbsorb:SetVertexColor(0, 190/255, 204/255)
	self.health.totalHealAbsorb:SetDrawLayer(drawLayer, subLayer+2)
	self.health.totalHealAbsorb:SetPoint('TOPRIGHT', self.health.statusBarTexture, 'TOPRIGHT', 0, 0)
	self.health.totalHealAbsorb:SetPoint('BOTTOMRIGHT', self.health.statusBarTexture, 'BOTTOMRIGHT', 0, 0)
	self.health.totalHealAbsorb:SetVertexColor(255/255, 0, 0, 0.9)
	self.health.totalHealAbsorb:SetWidth(0)
	self.health.totalHealAbsorb:SetHeight(15)

	self.health.PostSetValue = self.health.PostSetValue or function(self)
		UpdateHealPrediction(self.parent)
	end

	--[==[
	self.health.overAbsorbGlow = self.health.overAbsorbGlow or self.health:CreateTexture()
	self.health.overAbsorbGlow:SetTexture("Interface\\AddOns\\AleaUI\\media\\glow")
	self.health.overAbsorbGlow:SetPoint('TOPRIGHT', self.health, 'TOPRIGHT', 0, 0)
	self.health.overAbsorbGlow:SetPoint('BOTTOMRIGHT', self.health, 'BOTTOMRIGHT', 0, 0)
	self.health.overAbsorbGlow:SetDrawLayer(drawLayer, subLayer+2)
	self.health.overAbsorbGlow:SetTexCoord(0, 0.2, 0, 1)
	self.health.overAbsorbGlow:SetWidth(8)
	self.health.overAbsorbGlow:SetVertexColor(0, 190/255, 204/255)
	self.health.overAbsorbGlow:Hide()

	self.health.overHealAbsorbGlow = self.health.overHealAbsorbGlow or self.health:CreateTexture()
	self.health.overHealAbsorbGlow:SetTexture("Interface\\AddOns\\AleaUI\\media\\glow")
	self.health.overHealAbsorbGlow:SetPoint('TOPLEFT', self.health, 'TOPLEFT', 0, 0)
	self.health.overHealAbsorbGlow:SetPoint('BOTTOMLEFT', self.health, 'BOTTOMLEFT', 0, 0)
	self.health.overHealAbsorbGlow:SetDrawLayer(drawLayer, subLayer+2)
	self.health.overHealAbsorbGlow:SetTexCoord(0.05, 0.25, 0, 1)
	self.health.overHealAbsorbGlow:SetWidth(8)
	self.health.overHealAbsorbGlow:SetVertexColor(240/255, 16/255, 0)
	self.health.overHealAbsorbGlow:Hide()
	]==]

    self.health.bg = self.health.bg or self.health:CreateTexture()
	self.health.bg:SetDrawLayer("ARTWORK", subLayer-1)
	self.health.bg:SetPoint('TOPLEFT', self.health.statusBarTexture, 'TOPRIGHT', 0, 0)
	self.health.bg:SetPoint('BOTTOMRIGHT', self.health, 'BOTTOMRIGHT', 0, 0)
	self.health.bg:SetColorTexture(.6,.6,.6,1)

    self.role = self.role or self.health:CreateTexture()
	self.role:SetDrawLayer("ARTWORK", -3)
    self.role:SetPoint("TOPLEFT", 2, -2)
	self.role:SetSize(10, 10)
    self.role:Hide()

	self.readyCheckIcon = self.readyCheckIcon or self.health:CreateTexture()
	self.readyCheckIcon:SetDrawLayer('OVERLAY', subLayer+1)
    self.readyCheckIcon:SetPoint('CENTER', self.health, 'CENTER', 0, 0)
	self.readyCheckIcon:SetSize(15, 15)
    self.readyCheckIcon:Hide()

	self.centerStatusIcon =  self.centerStatusIcon or CreateFrame('Frame', nil, self.health)
	self.centerStatusIcon:SetPoint('CENTER', self.health, 'CENTER', 0, 0)
	self.centerStatusIcon:SetSize(22, 22)
	self.centerStatusIcon:Hide()

	self.centerStatusIcon.texture = self.centerStatusIcon.texture or self.centerStatusIcon:CreateTexture()
	self.centerStatusIcon.texture:SetDrawLayer('ARTWORK', subLayer+3)
	self.centerStatusIcon.texture:SetAllPoints()
	self.centerStatusIcon.texture:Show()

	self.centerStatusIcon.border = self.centerStatusIcon.border or self.centerStatusIcon:CreateTexture()
	self.centerStatusIcon.border:SetDrawLayer('ARTWORK', subLayer+4)
	self.centerStatusIcon.border:SetAllPoints()
	self.centerStatusIcon.border:Hide()


    self.power = self.powerbar or CreateFrame("StatusBar", nil, self)
	self.power:SetPoint("TOPLEFT", self.health, "BOTTOMLEFT", 0, subLayer+4)
    self.power:SetPoint("BOTTOMRIGHT", 0, 0)
	self.power:SetStatusBarTexture(E:GetTexture(options.texture))
    self.power:GetStatusBarTexture():SetDrawLayer("ARTWORK",subLayer+3)
    self.power:SetMinMaxValues(0,100)
	self.power:SetOrientation("HORIZONTAL")
    self.power.parent = self

	E:SetSmoothBar(self.power, true)

    self.power.bg = self.power.bg or self.power:CreateTexture()
	self.power.bg:SetAllPoints(self.power)
	self.power.bg:SetDrawLayer('ARTWORK', subLayer+2)
	self.power.bg:SetColorTexture(.1,.1,.1)
	self.power.bg:SetVertexColor(.2,.2,.2)

	if not self.power.borderArt then
		self.power.borderArt = NewBorder(self.power, 'ARTWORK', subLayer+2)
	end
	self.power.borderArt:Show()
	self.power.borderArt:SetTexture(0,0,0,1)
	self.power.borderArt:SetSize(1)
	self.power.borderArt:SetOutside()

	if not self.borderArt then
		self.borderArt = NewBorder(self.health, 'ARTWORK', subLayer+2)
	end
	self.borderArt:Show()
	self.borderArt:SetTexture(0,0,0,1)
	self.borderArt:SetSize(1)
	self.borderArt:SetOutside()

	if not self.border then
		self.border = NewBorder(self.health, 'ARTWORK', subLayer+6)
	end

	if not self.aggro then
		self.aggro = NewBorder(self.health, 'ARTWORK', subLayer+3)
	end

    self.text = self.text or self.health:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall", -4)
	self.text:SetDrawLayer('ARTWORK', subLayer+1)
	self.text:SetWordWrap(false)
	self.text:SetFont(E:GetFont(options.font), options.fontSize or 10, "OUTLINE")
  --  self.text:SetPoint("BOTTOM", self.health, 'CENTER', 0, 0)
	self.text:SetPoint('TOPLEFT', self.role, 'TOPRIGHT', 0, 0)
	self.text:SetPoint('RIGHT', self.health, 'RIGHT', 0, 0)
    self.text:SetJustifyH("LEFT")
	self.text:SetTextColor(self.classcolor and self.classcolor.r or 1, self.classcolor and self.classcolor.g or 1, self.classcolor and self.classcolor.b or 1)
    self.text:SetShadowColor(0,0,0)
    self.text:SetShadowOffset(mult,-mult)
    self.text.parent = self

    self.text2 = self.text2 or self.health:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
	self.text2:SetDrawLayer('ARTWORK', subLayer+1)
	self.text2:SetFont(E:GetFont(options.font), options.fontSize or 10, "OUTLINE")
    self.text2:SetPoint("TOP", self.health, 'CENTER', 0, 0)
    self.text2:SetJustifyH("CENTER")
    self.text2:SetTextColor(1, 1, 1)
    self.text2:SetShadowColor(0, 0, 0)
    self.text2:SetShadowOffset(mult, -mult)
    self.text2.parent = self

	self.raidIcon = self.raidIcon or self.health:CreateTexture()
	self.raidIcon:SetDrawLayer("ARTWORK", subLayer+7)
    self.raidIcon:SetPoint("CENTER", self.health, 'TOP', 0, -3)
	self.raidIcon:SetSize(16,16)
    self.raidIcon:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
	self.raidIcon:SetTexCoord(0,1,0,1)
    self.raidIcon:Hide()

	self.buffFrames = self.buffFrames or {}
	self.debuffFrames = self.debuffFrames or {}
	self.dispelDebuffFrames = self.dispelDebuffFrames or {}

	self.topLeftIndicator = self.topLeftIndicator or CreateFrame('Frame', nil, self.health)
	self.topLeftIndicator:SetSize(8, 8)
	self.topLeftIndicator:SetPoint('TOPLEFT', self.health, 'TOPLEFT', 0, 0)

	self.topLeftIndicator.icon = self.topLeftIndicator.icon or self.topLeftIndicator:CreateTexture()
	self.topLeftIndicator.icon:SetAllPoints(self.topLeftIndicator)
	self.topLeftIndicator.icon:SetColorTexture(0, 1, 0, 1)
	self.topLeftIndicator.icon:SetDrawLayer('ARTWORK', subLayer+1)

	self.topLeftIndicator.cooldown = self.topLeftIndicator.cooldown or CreateFrame('Cooldown', nil, self.topLeftIndicator, 'CooldownFrameTemplate')
	self.topLeftIndicator.cooldown:SetAllPoints(self.topLeftIndicator)
	self.topLeftIndicator.cooldown:SetReverse(true)
	self.topLeftIndicator.cooldown:SetDrawEdge(false)
	self.topLeftIndicator.cooldown:SetSwipeColor(0, 0, 0, 0.6)
	self.topLeftIndicator.cooldown:SetBlingTexture("")


	self.topRightIndicator = self.topRightIndicator or CreateFrame('Frame', nil, self.health)
	self.topRightIndicator:SetSize(8, 8)
	self.topRightIndicator:SetPoint('TOPRIGHT', self.health, 'TOPRIGHT', 0, 0)

	self.topRightIndicator.icon = self.topRightIndicator.icon or self.topRightIndicator:CreateTexture()
	self.topRightIndicator.icon:SetAllPoints(self.topRightIndicator)
	self.topRightIndicator.icon:SetColorTexture(1, 1, 0, 1)
	self.topRightIndicator.icon:SetDrawLayer('ARTWORK', subLayer+1)

	self.topRightIndicator.cooldown =self.topRightIndicator.cooldown or CreateFrame('Cooldown', nil, self.topRightIndicator, 'CooldownFrameTemplate')
	self.topRightIndicator.cooldown:SetAllPoints(self.topRightIndicator)
	self.topRightIndicator.cooldown:SetReverse(true)
	self.topRightIndicator.cooldown:SetDrawEdge(false)
	self.topRightIndicator.cooldown:SetSwipeColor(0, 0, 0, 0.6)
	self.topRightIndicator.cooldown:SetBlingTexture("")

	self.bottomLeftIndicator = self.bottomLeftIndicator or CreateFrame('Frame', nil, self.health)
	self.bottomLeftIndicator:SetSize(8, 8)
	self.bottomLeftIndicator:SetPoint('BOTTOMLEFT', self.health, 'BOTTOMLEFT', 0, 0)

	self.bottomLeftIndicator.icon = self.bottomLeftIndicator.icon or self.bottomLeftIndicator:CreateTexture()
	self.bottomLeftIndicator.icon:SetAllPoints(self.bottomLeftIndicator)
	self.bottomLeftIndicator.icon:SetColorTexture(1, 0, 1, 1)
	self.bottomLeftIndicator.icon:SetDrawLayer('ARTWORK', subLayer+1)

	self.bottomLeftIndicator.cooldown =self.bottomLeftIndicator.cooldown or CreateFrame('Cooldown', nil, self.bottomLeftIndicator, 'CooldownFrameTemplate')
	self.bottomLeftIndicator.cooldown:SetAllPoints(self.bottomLeftIndicator)
	self.bottomLeftIndicator.cooldown:SetReverse(true)
	self.bottomLeftIndicator.cooldown:SetDrawEdge(false)
	self.bottomLeftIndicator.cooldown:SetSwipeColor(0, 0, 0, 0.6)
	self.bottomLeftIndicator.cooldown:SetBlingTexture("")

	self.bottomRightIndicator = self.bottomRightIndicator or CreateFrame('Frame', nil, self.health)
	self.bottomRightIndicator:SetSize(8, 8)
	self.bottomRightIndicator:SetPoint('BOTTOMLEFT', self.health, 'BOTTOMLEFT', 0, 0)

	self.bottomRightIndicator.icon = self.bottomRightIndicator.icon or self.bottomRightIndicator:CreateTexture()
	self.bottomRightIndicator.icon:SetAllPoints(self.bottomRightIndicator)
	self.bottomRightIndicator.icon:SetColorTexture(1, 0, 0, 1)
	self.bottomRightIndicator.icon:SetDrawLayer('ARTWORK', subLayer+1)

	self.bottomRightIndicator.cooldown =self.bottomRightIndicator.cooldown or CreateFrame('Cooldown', nil, self.bottomRightIndicator, 'CooldownFrameTemplate')
	self.bottomRightIndicator.cooldown:SetAllPoints(self.bottomRightIndicator)
	self.bottomRightIndicator.cooldown:SetReverse(true)
	self.bottomRightIndicator.cooldown:SetDrawEdge(false)
	self.bottomRightIndicator.cooldown:SetSwipeColor(0, 0, 0, 0.6)
	self.bottomRightIndicator.cooldown:SetBlingTexture("")

	for i=1, 3 do
		self.buffFrames[i] = self.buffFrames[i] or CreateFrame('Frame', nil, self.health, BackdropTemplateMixin and 'BackdropTemplate')
		self.buffFrames[i]:SetSize(options.buffSize,options.buffSize)
		self.buffFrames[i]:SetBackdrop(AuraBackdrop)
		self.buffFrames[i]:SetBackdropColor(0, 0, 0, 0)
		self.buffFrames[i]:SetBackdropBorderColor(0, 0, 0, 1)

		self.buffFrames[i].icon = self.buffFrames[i].icon or self.buffFrames[i]:CreateTexture()
		self.buffFrames[i].icon:SetInside(self.buffFrames[i])
		self.buffFrames[i].icon:SetTexCoord(unpack(E.media.texCoord))
		self.buffFrames[i].icon:SetColorTexture(0, 1, 0, 1)

		self.buffFrames[i].cooldown = self.buffFrames[i].cooldown or CreateFrame('Cooldown', nil, self.buffFrames[i], 'CooldownFrameTemplate')
		self.buffFrames[i].cooldown:SetAllPoints(self.buffFrames[i])
		self.buffFrames[i].cooldown:SetReverse(true)
		self.buffFrames[i].cooldown:SetDrawEdge(false)
		self.buffFrames[i].cooldown:SetSwipeColor(0, 0, 0, 0.6)
		self.buffFrames[i].cooldown:SetBlingTexture("")

		self.buffFrames[i].countParent = self.buffFrames[i].countParent or CreateFrame('Frame', nil, self.buffFrames[i])
		self.buffFrames[i].countParent:SetFrameLevel(self.buffFrames[i].cooldown:GetFrameLevel()+1)
		self.buffFrames[i].countParent:SetFrameStrata('HIGH')
		self.buffFrames[i].countParent:SetAllPoints(self.buffFrames[i])

		self.buffFrames[i].count = self.buffFrames[i].count or self.buffFrames[i].countParent:CreateFontString()
		self.buffFrames[i].count:SetFontObject(NumberFontNormalSmall)
		self.buffFrames[i].count:SetDrawLayer('OVERLAY', 4)
		self.buffFrames[i].count:SetJustifyH('RIGHT')
		self.buffFrames[i].count:SetPoint('BOTTOMRIGHT', self.buffFrames[i], 'BOTTOMRIGHT', 5, 0)
		self.buffFrames[i].count:SetText(5)

		E:RegisterCooldown(self.buffFrames[i].cooldown)
		self.buffFrames[i].baseSize = options.buffSize

		self.debuffFrames[i] = self.debuffFrames[i] or CreateFrame('Frame', nil, self.health, BackdropTemplateMixin and 'BackdropTemplate')
		self.debuffFrames[i]:SetSize(options.debuffSize,options.debuffSize)
		self.debuffFrames[i]:SetBackdrop(AuraBackdrop)
		self.debuffFrames[i]:SetBackdropColor(0, 0, 0, 0)
		self.debuffFrames[i]:SetBackdropBorderColor(0, 0, 0, 1)

		self.debuffFrames[i].icon = self.debuffFrames[i].icon or self.debuffFrames[i]:CreateTexture()
		self.debuffFrames[i].icon:SetInside(self.debuffFrames[i])
		self.debuffFrames[i].icon:SetColorTexture(1, 0, 0, 1)
		self.debuffFrames[i].icon:SetTexCoord(unpack(E.media.texCoord))

		self.debuffFrames[i].cooldown = self.debuffFrames[i].cooldown or CreateFrame('Cooldown', nil, self.debuffFrames[i], 'CooldownFrameTemplate')
		self.debuffFrames[i].cooldown:SetAllPoints(self.debuffFrames[i])
		self.debuffFrames[i].cooldown:SetReverse(true)
		self.debuffFrames[i].cooldown:SetDrawEdge(false)
		self.debuffFrames[i].cooldown:SetSwipeColor(0, 0, 0, 0.6)
		self.debuffFrames[i].cooldown:SetBlingTexture("")
		self.debuffFrames[i].baseSize = options.debuffSize

		self.debuffFrames[i].countParent = self.debuffFrames[i].countParent or CreateFrame('Frame', nil, self.debuffFrames[i])
		self.debuffFrames[i].countParent:SetFrameLevel(self.debuffFrames[i].cooldown:GetFrameLevel()+1)
		self.debuffFrames[i].countParent:SetFrameStrata('HIGH')
		self.debuffFrames[i].countParent:SetAllPoints(self.debuffFrames[i])

		self.debuffFrames[i].count = self.debuffFrames[i].count or self.debuffFrames[i].countParent:CreateFontString()
		self.debuffFrames[i].count:SetFontObject(NumberFontNormalSmall)
		self.debuffFrames[i].count:SetDrawLayer('OVERLAY', 4)
		self.debuffFrames[i].count:SetJustifyH('RIGHT')
		self.debuffFrames[i].count:SetPoint('BOTTOMRIGHT', self.debuffFrames[i], 'BOTTOMRIGHT', 5, 0)
		self.debuffFrames[i].count:SetText(5)

		E:RegisterCooldown(self.debuffFrames[i].cooldown)

		self.maxBuffs = i
		self.maxDebuffs = i
	end


	self:UpdateBuffAndDebuff()

	self:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	self:SetScript('OnEnter', UnitFrame_OnEnter)
	self:SetScript('OnLeave', UnitFrame_OnLeave)

	self.health:ClearAllPoints()

	if options.showPowerBars  then
		self.health:SetPoint("TOPLEFT", 0, 0)
		self.health:SetPoint("BOTTOMRIGHT", 0, 5)
		self.power:Show()
	else
		self.health:SetAllPoints()
		self.power:Hide()
	end

	ArtElements[self] = true

	self:UpdateFontStyle()
	self:UpdateStatusBarTexture()

	-- Scripts
	self:SetScript("OnAttributeChanged", OnChangeAttribute)
	self:SetScript('OnShow',  RF.OnUnitFrameShown)
	self:SetScript('OnHide',  RF.OnUnitFrameHiden)
end

RF.raidFrameBackGround = CreateFrame("Frame", nil, E.UIParent, BackdropTemplateMixin and 'BackdropTemplate')
RF.raidFrameBackGround:SetFrameStrata('LOW')
RF.raidFrameBackGround:SetFrameLevel(2)
RF.raidFrameBackGround:SetBackdrop({
  edgeFile = [[Interface\Buttons\WHITE8x8]],
  edgeSize = 1,
})
RF.raidFrameBackGround:SetBackdropBorderColor(0,0,0,1)
RF.raidFrameBackGround:SetPoint("BOTTOMLEFT", E.UIParent, "BOTTOMLEFT", 0, -0)
RF.raidFrameBackGround:SetSize(100,100)

RF.raidFrameBackGround.back = RF.raidFrameBackGround:CreateTexture()
RF.raidFrameBackGround.back:SetDrawLayer('BACKGROUND', -2)
RF.raidFrameBackGround.back:SetColorTexture(0, 0, 0, 0)
RF.raidFrameBackGround.back:SetPoint("BOTTOMLEFT", RF.raidFrameBackGround.artWork, "BOTTOMLEFT", 0, -0)

function RF.UpdateRaidFrameBackground()
	if options.artwork.enable and IsInRaid() then
		RF.raidFrameBackGround:Show()
	else
		RF.raidFrameBackGround:Hide()
	end
end

function RF.UpdateRaidFrameBackgroundSettings()
	local anchor = 'BOTTOMLEFT'
	local anchorTo = _G['AleaUIRaidFrames']
	local offset = 1
	if options.horizontal then
		if options.gropUp then
			anchor = 'BOTTOMLEFT'
			offset = 1
		else
			anchor = 'TOPLEFT'
			offset = 1
		end
	else
		if options.gropUp then
			anchor = 'TOPLEFT'
			offset = -1
		end
	end

	RF.raidFrameBackGround:ClearAllPoints()
	RF.raidFrameBackGround:SetPoint(anchor, anchorTo, anchor, options.artwork.inset, options.artwork.inset*offset)
	RF.raidFrameBackGround:SetBackdrop({
	  edgeFile = E:GetBorder(options.artwork.texture),
	  edgeSize = options.artwork.size,
	})
	RF.raidFrameBackGround:SetBackdropBorderColor(options.artwork.color[1],options.artwork.color[2],options.artwork.color[3],options.artwork.color[4])
	RF.raidFrameBackGround:SetSize(options.artwork.width, options.artwork.height)
	
	RF.raidFrameBackGround.back:ClearAllPoints()
	RF.raidFrameBackGround.back:SetTexture(E:GetTexture(options.artwork.background_texture))
	RF.raidFrameBackGround.back:SetVertexColor(options.artwork.background_color[1],options.artwork.background_color[2],options.artwork.background_color[3],options.artwork.background_color[4])
	RF.raidFrameBackGround.back:SetSize(options.artwork.width+options.artwork.background_inset+options.artwork.background_inset,
		options.artwork.height+options.artwork.background_inset+options.artwork.background_inset)
	RF.raidFrameBackGround.back:SetPoint("BOTTOMLEFT", RF.raidFrameBackGround, "BOTTOMLEFT", -options.artwork.background_inset, -options.artwork.background_inset)

	RF.UpdateRaidFrameBackground()
end

function RF.OnUnitFrameShown(...)
	UpdateAll(...)
	RF.UpdateRaidFrameBackground()
end

function RF.OnUnitFrameHiden()
	RF.UpdateRaidFrameBackground()
end

function RF.UdapteByLSM()
	for frame in pairs(ArtElements) do
		local texture = E:GetTexture(options.texture)
		frame.health:SetStatusBarTexture(texture)
		frame.text:SetFont(E:GetFont(options.font), options.fontSize or 10, "OUTLINE")
		frame.text2:SetFont(E:GetFont(options.font), options.fontSize or 10, "OUTLINE")
		frame.health.totalHealPrediction:SetTexture(texture)
		frame.health.totalAbsorb:SetTexture(texture)
	end
end

E.OnLSMUpdateRegister(RF.UdapteByLSM)

function CallArtworkFunction(self, frameName, ...)
	local frame = _G[frameName]
	CreateUnitFrameArtwork(frame)
end

local raid = CreateFrame("Frame", "AleaUIRaidFrames", UIParent, 'SecureHandlerStateTemplate')
raid:SetMovable(true)
raid:SetSize(1,1)

local RaidFrameInitialization = [[
	local header = self:GetParent()

	local manager = header:GetParent()

	local frames = table.new()
	table.insert(frames, self)
	self:GetChildList(frames)

	for i=1, #frames do
		local frame = frames[i]
		local unit


		RegisterUnitWatch(frame)

		if(header:GetAttribute'showRaid') then
			unit = 'raid'
		elseif(header:GetAttribute'showParty') then
			unit = 'party'
		end

		local headerType = header:GetAttribute('headerType')
		local suffix = frame:GetAttribute('unitsuffix')
		if(unit and suffix) then
			if(headerType == 'pet' and suffix == 'target') then
				unit = unit .. headerType .. suffix
			else
				unit = unit .. suffix
			end
		elseif(unit and headerType == 'pet') then
			unit = unit .. headerType
		end

		frame:SetAttribute('*type1', 'target')
	--	frame:SetAttribute('shift-type1', 'target')
		frame:SetAttribute('*type2', 'togglemenu')
		frame:SetAttribute('toggleForVehicle', false)
		frame:SetAttribute('guessUnit', unit)
	end
	self:SetWidth(header:GetAttribute('setting_opts_width'))
	self:SetHeight(header:GetAttribute('setting_opts_height'))

	local clique = header:GetFrameRef("clickcast_header")
	if(clique) then
		clique:SetAttribute("clickcast_button", self)
		clique:RunAttribute("clickcast_register")
	end

	header:CallMethod('CallArtworkFunction', self:GetName())

	manager:GetFrameRef('updater'):Hide()
	manager:GetFrameRef('updater'):Show()
]]

local CliqueOnEnter = [[local snippet = self:GetAttribute('clickcast_onenter'); if snippet then self:Run(snippet) end]]
local CliqueOnLeave = [[local snippet = self:GetAttribute('clickcast_onleave'); if snippet then self:Run(snippet) end]]


local headersUpdatePosition = [[
	local growUp = manager:GetAttribute('AleaGrowUp')
	local horizontal = manager:GetAttribute('AleaHorizontal')

	local offset = tonumber(manager:GetAttribute('xOffset')) or 0

	local point, relPoint, xOffset, yOffset = 'TOPLEFT', 'TOPRIGHT', offset, 0
	local parentPoint = 'TOPLEFT'

	if horizontal then
		if growUp then
			point, relPoint, xOffset, yOffset = 'BOTTOMLEFT', 'TOPLEFT', 0, offset
			parentPoint = 'BOTTOMLEFT'
		else
			point, relPoint, xOffset, yOffset = 'TOPLEFT', 'BOTTOMLEFT', 0, -offset
			parentPoint = 'TOPLEFT'
		end
	end

--	print('T', point, relPoint, xOffset, yOffset)

	local lastHeader
	local lastMember

	for i=1, #Headers do
		local header = Headers[i]

		if HeadersVisability[i] then
			if not lastHeader then
				header:ClearAllPoints()
				header:SetPoint(parentPoint, raidMover, 0, 0)
				lastHeader = header
			else
				header:ClearAllPoints()
				header:SetPoint(point, lastHeader, relPoint, xOffset, yOffset)
				lastHeader = header
			end
		end
	end

	header1button:SetAttribute('isgreen', HeadersVisability[1])
	header2button:SetAttribute('isgreen', HeadersVisability[2])
	header3button:SetAttribute('isgreen', HeadersVisability[3])
	header4button:SetAttribute('isgreen', HeadersVisability[4])
	header5button:SetAttribute('isgreen', HeadersVisability[5])
	header6button:SetAttribute('isgreen', HeadersVisability[6])
	header7button:SetAttribute('isgreen', HeadersVisability[7])
	header8button:SetAttribute('isgreen', HeadersVisability[8])
]]

local managerwidth, managerheight = 200,300
local manager = CreateFrame('Frame', nil, UIParent, 'SecureHandlerStateTemplate')
manager:SetFrameLevel(30)
manager:SetFrameStrata('LOW')
manager:SetSize(managerwidth, managerheight)
manager:SetPoint("TOPLEFT", UIParent, "TOPLEFT", -186, -240);
manager:SetAttribute('AleaGrowUp', true)
manager:SetAttribute('AleaHorizontal', true)
manager:SetFrameRef('raidMover', raid)
RegisterStateDriver(manager, "visibility", "[group:raid][group:party]show;hide")
--RegisterStateDriver(manager, "visibility", "show")
E:CreateBackdrop(manager, manager, {0, 0, 0, 1}, {0.1, 0.1, 0.1, 0.9})


--[==[
manager.bg = manager:CreateTexture(nil, 'OVERLAY')
manager.bg:SetAllPoints()
manager.bg:SetColorTexture(0,0,0,0.7)

RF.raidFrameBackGround = CreateFrame("Frame", nil, E.UIParent)
RF.raidFrameBackGround:SetFrameStrata('LOW')
RF.raidFrameBackGround:SetFrameLevel(2)
RF.raidFrameBackGround:SetBackdrop({
  edgeFile = [[Interface\Buttons\WHITE8x8]],
  edgeSize = 1,
})
RF.raidFrameBackGround:SetBackdropBorderColor(0,0,0,1)
RF.raidFrameBackGround:SetPoint("BOTTOMLEFT", E.UIParent, "BOTTOMLEFT", 0, -0)
RF.raidFrameBackGround:SetSize(100,100)

RF.raidFrameBackGround.back = RF.raidFrameBackGround:CreateTexture()
RF.raidFrameBackGround.back:SetDrawLayer('BACKGROUND', -2)
RF.raidFrameBackGround.back:SetColorTexture(0, 0, 0, 0)
RF.raidFrameBackGround.back:SetPoint("BOTTOMLEFT", RF.raidFrameBackGround.artWork, "BOTTOMLEFT", 0, -0)
]==]


local leaderRequested = {}
local previousButton
local NUM_WORLD_RAID_MARKERS = 8
local TEX_WORLD_RAID_MARKERS = {}
tinsert(TEX_WORLD_RAID_MARKERS, "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_6:14:14|t")
tinsert(TEX_WORLD_RAID_MARKERS, "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_4:14:14|t")
tinsert(TEX_WORLD_RAID_MARKERS, "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_3:14:14|t")
tinsert(TEX_WORLD_RAID_MARKERS, "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_7:14:14|t")
tinsert(TEX_WORLD_RAID_MARKERS, "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_1:14:14|t")
tinsert(TEX_WORLD_RAID_MARKERS, "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_2:14:14|t")
tinsert(TEX_WORLD_RAID_MARKERS, "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_5:14:14|t")
tinsert(TEX_WORLD_RAID_MARKERS, "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_8:14:14|t")

local function CreateBasicButton(parent, name, text, tooltipText)
	local button = CreateFrame("Button", name, parent, "SecureActionButtonTemplate"..(BackdropTemplateMixin and ', BackdropTemplate' or ''))
	button.text = button:CreateFontString()
	button.text:SetFont(STANDARD_TEXT_FONT, 12, "")
	button.text:SetText(text)
	button.text:SetPoint("CENTER")
	button.text:SetSize(30, 30)
	button:SetBackdrop({
			bgFile = [=[Interface\TargetingFrame\UI-StatusBar]=],
			edgeFile = [=[Interface\ChatFrame\ChatFrameBackground]=], edgeSize = 1,
			insets = {top = 0, left = 0, bottom = 0, right = 0},
			})
	button:SetBackdropColor(0.2, 0.2, 0.2, 1) --цвет фона
	button:SetBackdropBorderColor(0.4, 0.4, 0.4, 1) --цвет фона

	button:SetWidth(25)
	button:SetHeight(25)
	button:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:AddLine(tooltipText, 0, 1, 0.5, 1, 1, 1)
		GameTooltip:Show()
		self:SetBackdropBorderColor(1, 1, 1, 1) --цвет краев
	end)
	button:SetScript("OnLeave", function(self)
		GameTooltip:Hide()
		self:SetBackdropBorderColor(0.4, 0.4, 0.4, 1) --цвет краев
	end)
	return button
end

function RF:UpdateLeaderRequests()
	for i=1, #leaderRequested do
		if UnitIsGroupAssistant("player") or UnitIsGroupLeader("player") then
			leaderRequested[i]:SetAlpha(1)
		else
			leaderRequested[i]:SetAlpha(0.3)
		end
	end
end

for i=1, NUM_WORLD_RAID_MARKERS do
local text = TEX_WORLD_RAID_MARKERS[i]
local button = CreateBasicButton(manager, addonName.."RaidManager".."Button"..i, text, "WorldMarker"..i)
button:SetAttribute("type", "macro")
button:SetAttribute("macrotext", format("/wm %d", i))
if not previousButton then
  button:SetPoint("TOPRIGHT", manager, 85-managerwidth, -45)
else
  button:SetPoint("TOP", previousButton, "BOTTOM", 0, -2)
end
local cancelButton = CreateBasicButton(manager, addonName.."RaidManager".."Button"..i.."Cancel", "|TInterface\\Buttons\\UI-GroupLoot-Pass-Up:14:14:0:0|t", "Clear WorldMarker"..i)
cancelButton:SetAttribute("type", "macro")
cancelButton:SetAttribute("macrotext", format("/cwm %d", i))
cancelButton:SetPoint("RIGHT", button, "LEFT", -2, 0)


leaderRequested[#leaderRequested+1] = button
leaderRequested[#leaderRequested+1] = cancelButton

previousButton = button
end

--rolecheck button
local button = CreateBasicButton(manager, addonName.."RaidManager".."ButtonRoleCheck", "|TInterface\\LFGFrame\\LFGRole:14:14:0:0:64:16:32:48:0:16|t", "Role check")
button:SetScript("OnClick", InitiateRolePoll)
button:SetPoint("TOPRIGHT", manager, 155-managerwidth, -45)
leaderRequested[#leaderRequested+1] = button

previousButton = button

--raid to party button
local buttonLeft = CreateBasicButton(manager, addonName.."RaidManager".."ButtonRaidToParty", "|TInterface\\GroupFrame\\UI-Group-AssistantIcon:14:14:0:0|t", "Raid to party")
buttonLeft:SetScript("OnClick", ConvertToParty)
buttonLeft:SetPoint("RIGHT", button, "LEFT", -2, 0)
leaderRequested[#leaderRequested+1] = buttonLeft

--readycheck button
local button = CreateBasicButton(manager, addonName.."RaidManager".."ButtonReady", "|TInterface\\RaidFrame\\ReadyCheck-Ready:14:14:0:0|t", "Ready check")
button:SetScript("OnClick", DoReadyCheck)
button:SetPoint("TOP", previousButton, "BOTTOM", 0, -2)
leaderRequested[#leaderRequested+1] = button

previousButton = button

--party to raid button
local buttonLeft = CreateBasicButton(manager, addonName.."RaidManager".."ButtonPartyToRaid", "|TInterface\\GroupFrame\\UI-Group-LeaderIcon:14:14:0:0|t", "Party to raid")
buttonLeft:SetScript("OnClick", ConvertToRaid)
buttonLeft:SetPoint("RIGHT", button, "LEFT", -2, 0)
leaderRequested[#leaderRequested+1] = buttonLeft

--pull button
local pullCounter = 10
local button = CreateBasicButton(manager, addonName.."RaidManager".."ButtonPullCounter", "|TInterface\\TargetingFrame\\UI-TargetingFrame-Skull:14:14:0:0|t", "Boss pull in "..pullCounter)
button:SetPoint("TOP", previousButton, "BOTTOM", 0, -2)
button:SetAttribute("type", "macro")
button:SetAttribute("macrotext", format("/pull %d", pullCounter))
previousButton = button

--stopwatch toggle
local buttonLeft = CreateBasicButton(manager, addonName.."RaidManager".."ButtonStopWatch", "|TInterface\\ChatFrame\\UI-ChatIcon-ArmoryChat-AwayMobile:14:14:0:0|t", "Toggle stopwatch")
buttonLeft:SetScript("OnClick", function()
	if Stopwatch_IsPlaying() then
		Stopwatch_Clear()
	else
		Stopwatch_Play()
	end
	Stopwatch_Toggle()
end)
buttonLeft:SetPoint("RIGHT", button, "LEFT", -2, 0)

manager.buttons = {}
local button_xOffset, buttonyOffset = 45, -50
for i=1, 8 do
	manager.buttons[i] = CreateBasicButton(manager, nil, '', 'Group'..i)
	manager.buttons[i]:SetSize(30, 15)

	manager.buttons[i].text:SetFont(STANDARD_TEXT_FONT, 10, 'OUTLINE')
	manager.buttons[i].text:SetPoint('CENTER', manager.buttons[i], 'CENTER')
	manager.buttons[i].text:SetText('0/0')

	manager.buttons[i]:SetAttribute('isgreen', true)
	manager.buttons[i]:SetAttribute('header', i)

	manager.buttons[i]:SetPoint("TOP", previousButton, 'BOTTOM', i == 1 and -10 or 0, -3)
	previousButton = manager.buttons[i]

	manager:SetFrameRef('header'..i..'button', manager.buttons[i])


	manager:WrapScript(manager.buttons[i], 'OnClick', [[
		local id = self:GetAttribute('header')
		HeadersVisability[id] = not HeadersVisability[id]

		self:SetAttribute('isgreen', HeadersVisability[id])

		Headers[id]:SetAttribute("showRaid", HeadersVisability[id])
		Headers[id]:SetAttribute("showParty", HeadersVisability[id])

		updater:Hide()
		updater:Show()
	]])

	manager.buttons[i]:SetScript('OnAttributeChanged', function(self, attr, value)
		if attr ~= 'isgreen' then return end
		if value then
			self:SetBackdropColor(0, 0.5, 0, 1)
		else
			self:SetBackdropColor(0.5, 0, 0, 1)
		end
	end)
end

manager:RegisterEvent('GROUP_ROSTER_UPDATE')
manager._GROUP_ROSTER_UPDATE = function(self)
	for i=1, 8 do
		manager.buttons[i].numMembers = 0
	end

	for i=1, 40 do

		local name, rank, subgroup = GetRaidRosterInfo(i)

		if name and subgroup and manager.buttons[subgroup] then
			manager.buttons[subgroup].numMembers = manager.buttons[subgroup].numMembers + 1

		end
	end

	for i=1, 8 do
		manager.buttons[i].text:SetText(format('%d/5', manager.buttons[i].numMembers))
	end
end

manager:SetScript('OnEvent', manager._GROUP_ROSTER_UPDATE)

manager.updater = CreateFrame('Frame', nil, manager, 'SecureHandlerStateTemplate')
manager:WrapScript(manager.updater, 'OnShow', headersUpdatePosition)
manager:SetFrameRef('updater', manager.updater)

manager:Execute([[
	Headers = newtable()
	HeadersVisability = newtable()

	manager = self
	raidMover = self:GetFrameRef('raidMover')
	updater = self:GetFrameRef('updater')

	header1button = self:GetFrameRef('header1button')
	header2button = self:GetFrameRef('header2button')
	header3button = self:GetFrameRef('header3button')
	header4button = self:GetFrameRef('header4button')
	header5button = self:GetFrameRef('header5button')
	header6button = self:GetFrameRef('header6button')
	header7button = self:GetFrameRef('header7button')
	header8button = self:GetFrameRef('header8button')

	for i=1, 8 do
		HeadersVisability[i] = true
	end
]])

local stateFrame = CreateFrame("Button", nil, manager, "SecureHandlerClickTemplate")
stateFrame:SetPoint("TOPRIGHT",0,-50)
stateFrame:SetPoint("BOTTOMRIGHT",0,50)
stateFrame:SetWidth(25)
stateFrame:EnableMouse(true)

stateFrame:SetAttribute("_onclick", [=[
	if not self:GetAttribute("state") then
	  self:SetAttribute("state","closed")
	end
	local state = self:GetAttribute("state")
	if state == "closed" then
	  self:GetParent():SetPoint("TOPLEFT", self:GetParent():GetParent(), "TOPLEFT", -7, -240);
	  self:SetAttribute("state","open")
	else
	  self:GetParent():SetPoint("TOPLEFT", self:GetParent():GetParent(), "TOPLEFT", -186, -240);
	  self:SetAttribute("state","closed")
	end
]=])
stateFrame.button = stateFrame:CreateTexture(nil, 'OVERLAY')
stateFrame.button:SetTexture("Interface\\RaidFrame\\RaidPanel-Toggle")
stateFrame.button:SetTexCoord(0.5, 1, 0, 1);
stateFrame.button:SetSize(16, 64)
stateFrame.button:SetPoint('RIGHT', 0, 0)
stateFrame:SetScript('OnAttributeChanged', function(self, name, value)
	if name == 'state' then
		if value == 'open' then
			stateFrame.button:SetTexCoord(0.5, 1, 0, 1);
			stateFrame.button:SetAlpha(1)

			manager.OpenSettings:Show()
		else
			stateFrame.button:SetTexCoord(0, 0.5, 0, 1);
			stateFrame.button:SetAlpha(0.7)

			manager.OpenSettings:Hide()
		end

		manager._GROUP_ROSTER_UPDATE()
	end
end)


function CreateGroupHeader(num)

	local template_1 = "SecureGroupHeaderTemplate"
	local header_name = "_GroupHeader"..num
	local header_type = "group"
	local header_addon = "AleaUI"

	if num == "pet" then
		template_1 = "SecureGroupPetHeaderTemplate"
		header_name = "_GroupHeader_Pets"
		header_type = "pet"
	end

	local width  = options.width
	local height = options.height

	if (num == "pet") then
		height = (options.height)/2
	end

	local RaidGroupHeader = CreateFrame("Frame", header_addon..header_name, manager, template_1)
	RaidGroupHeader:Hide()
	RaidGroupHeader:SetFrameStrata('LOW')
	RaidGroupHeader:SetFrameLevel(5)
	RaidGroupHeader._headerText = RaidGroupHeader:CreateFontString(nil, "BACKGROUND", nil, -8)
	RaidGroupHeader._headerText:SetFontObject(GameFontWhite)
	RaidGroupHeader._headerText:SetFont(STANDARD_TEXT_FONT, 10, "OUTLINE")
	RaidGroupHeader._headerText:SetPoint("BOTTOM", RaidGroupHeader, "TOP", 0, 3)
	RaidGroupHeader._headerText:SetText(E.L["group"].." "..num)
	RaidGroupHeader._headerText:Hide()

	RaidGroupHeader:SetMovable(true)
	RaidGroupHeader:SetClampedToScreen(true)

	RaidGroupHeader:SetAttribute("_onenter", CliqueOnEnter)
    RaidGroupHeader:SetAttribute("_onleave", CliqueOnLeave)
	RaidGroupHeader:SetAttribute('_ignore', true)

	-- RaidGroupHeader Frame Header
	RaidGroupHeader:SetAttribute("template", "SecureUnitButtonTemplate")
	RaidGroupHeader:SetAttribute("templateType", "Button")

	RaidGroupHeader:SetAttribute('headerType', header_type)

	if num ~= "pet" then
		RaidGroupHeader:SetAttribute("groupFilter", tostring(num))
	end

	local point, numPerRow, numPerCol, xOffset, yOffset = "TOP", 5, 1, 0, -2
	if options.horizontal then
		point, numPerRow, numPerCol, xOffset, yOffset = "LEFT", 1, 5, 2, 0
	end

	RaidGroupHeader:SetAttribute("showRaid", true) -- When true, the group header is shown when the player is in a raid.
	RaidGroupHeader:SetAttribute("showParty", true) -- When true, the group header is shown when the player is in a party. This attribute doesnТt imply showRaid but can work alongside it.
	RaidGroupHeader:SetAttribute("showSolo", false) -- When true, the header is shown when the player is not in any group. This option implies showPlayer.
	RaidGroupHeader:SetAttribute("showPlayer", true) -- When true, the header includes the player when not in a raid (normally, the player would not be visible in a party listing).

	RaidGroupHeader:SetAttribute("point", point)
	RaidGroupHeader:SetAttribute("xOffset",xOffset)
	RaidGroupHeader:SetAttribute("yOffset",yOffset)
	RaidGroupHeader:SetAttribute("unitsPerColumn",numPerRow)
	RaidGroupHeader:SetAttribute("maxColumns",numPerCol)
	RaidGroupHeader:SetAttribute("columnAnchorPoint",point)
	RaidGroupHeader:SetAttribute('setting_opts_width', width)
	RaidGroupHeader:SetAttribute('setting_opts_height', height)

	RaidGroupHeader.CallArtworkFunction = CallArtworkFunction	-- This function is called from the init function

	RaidGroupHeader:SetAttribute('_ignore', false)

	RaidGroupHeader:SetAttribute("initialConfigFunction", RaidFrameInitialization) 		-- Init function (Secure)

	manager:SetAttribute("xOffset",xOffset)

	manager:WrapScript(RaidGroupHeader, 'OnShow', headersUpdatePosition)
	manager:WrapScript(RaidGroupHeader, 'OnHide', headersUpdatePosition)

	if(ClickCastHeader) then
		SecureHandlerSetFrameRef(RaidGroupHeader, 'clickcast_header', header)
	end

	manager:SetFrameRef('header', RaidGroupHeader)
	manager:Execute([[tinsert(Headers, self:GetFrameRef("header"))]])

	return RaidGroupHeader
end


local postCombatUpdate = CreateFrame("Frame")
postCombatUpdate:SetScript('OnEvent', function(self, event)
	self:UnregisterAllEvents()
	RF:UpdateProfileSettings()
end)

local lastLastLastProfile = nil


function RF:OnProfileChange()
	RF:PrepareProfiles()
	RF:UpdateProfileSettings()
	RF:UdapteByLSM()
end

function RF:UpdateProfileSettings()
	if not E.db.raidFramesSettings.enableModule then
	--	print('RF:UpdateProfileSettings - Skip update cuz of E.db.raidFramesSettings.enableModule', E.db.raidFramesSettings.enableModule)
		return
	end

	if InCombatLockdown() then
	--	print("You Are in combat")
		postCombatUpdate:RegisterEvent('PLAYER_REGEN_ENABLED')
		return
	end

	local lastProfile = E.db.raidFramesSettings.lastProfile or 1
	local profileName = E.db.raidFramesSettings.ProfileList[lastProfile] or E.db.raidFramesSettings.ProfileList[1]

	options = E.db.raidFramesSettings.Profiles[profileName]
	charOptions = E.chardb.raidFramesSettings.Profiles[profileName]

	manager.dropdown.main:RefreshData()

	RF:UpdateOffsetGUI()
	RF:UpdateDeleteButton()
	RF:UpdateIndicatorsGUI()

	if lastLastLastProfile ~= lastProfile then
		lastLastLastProfile = lastProfile

		RF:InterateArtElements('UpdateStatusBarTexture')
		RF:InterateArtElements('UpdateFontStyle')

		manager:Execute(format([[
			HeadersVisability[1] = %s
			HeadersVisability[2] = %s
			HeadersVisability[3] = %s
			HeadersVisability[4] = %s
			HeadersVisability[5] = %s
			HeadersVisability[6] = %s
			HeadersVisability[7] = %s
			HeadersVisability[8] = %s

			for i=1, 8 do
				Headers[i]:SetAttribute("showRaid", HeadersVisability[i])
				Headers[i]:SetAttribute("showParty", HeadersVisability[i])
			end
		]], tostring(options.groupToShow[1]),
			tostring(options.groupToShow[2]),
			tostring(options.groupToShow[3]),
			tostring(options.groupToShow[4]),
			tostring(options.groupToShow[5]),
			tostring(options.groupToShow[6]),
			tostring(options.groupToShow[7]),
			tostring(options.groupToShow[8])))
	end

	E.SetFrameOptsCustom("raidframeHeader", E.UnpackFrameOpts(options.position))
	E:Mover(raid, "raidframeHeader", 200, 20, "TOPLEFT", RF.RaidMoverHandler)

	RF.UpdateRaidFrameBackgroundSettings()

	for num, header in pairs(headerLists) do


		--[==[
			для вертикального расположения yOffset как вертиальный отступ
			для горизонтального как горизонтальный отступ
		]==]

		local point = "TOP"
		local numPerRow = 5
		local numPerCol = 1
		local xOffset = options.xOffset or 0
		local yOffset = -(options.yOffset or 2)
		local columnSpacing = 0

		if options.horizontal then
			point = "LEFT"
			numPerRow = 1
			numPerCol = 5
			xOffset = options.xOffset or 0
			yOffset = 0
			columnSpacing = options.yOffset or 2
		end

		local width  = options.width
		local height = options.height

		if (num == "pet") then
			height = (options.height)/2
		end

		manager:SetAttribute('AleaGrowUp', options.gropUp)
		manager:SetAttribute('AleaHorizontal', options.horizontal)

		header:SetAttribute("unitsPerColumn",1)
		header:SetAttribute("maxColumns",0)
		header:SetAttribute('_ignore', true)
		header:SetAttribute("point", point)
		header:SetAttribute("xOffset",xOffset)
		header:SetAttribute("yOffset",yOffset)
		header:SetAttribute("unitsPerColumn",numPerRow)
		header:SetAttribute("columnSpacing",columnSpacing)
		header:SetAttribute("maxColumns",numPerCol)
		header:SetAttribute("columnAnchorPoint",point)
		header:SetAttribute('setting_opts_width', options.width)
		header:SetAttribute('setting_opts_height', options.height)

		for m=1, 5 do
			local name = header:GetName()
			local memberName = name..'UnitButton'..m

			local frame = _G[memberName]

			if frame then
				frame:SetSize(options.width, options.height)

				for i=1, 3 do
					frame.buffFrames[i].baseSize = options.buffSize
					frame.debuffFrames[i].baseSize = options.debuffSize
				end
			end
		end

		header:SetAttribute('_ignore',false)
		header:SetAttribute('customUpdate', not header:GetAttribute('customUpdate'))

		manager:SetAttribute("xOffset",xOffset)

		manager.updater:Hide()
		manager.updater:Show()
	end
end

function HideRaid()
	if InCombatLockdown() then return end
	CompactRaidFrameManager:Kill()
	local compact_raid = CompactRaidFrameManager_GetSetting("IsShown")
	if compact_raid and compact_raid ~= "0" then
		CompactRaidFrameManager_SetSetting("IsShown", "0")
	end
end

local HidenUIParent = CreateFrame("Frame")
HidenUIParent:Hide()

function RF:DisableBlizzard()

	if not CompactRaidFrameManager_UpdateShown then

		AleaUI_GUI.ShowPopUp(
		   "AleaUI",
		   L['Blizzard raid frames are disabled. You need to enable them and reload ui.'],
		   { name = "Yes", OnClick = function()
			EnableAddOn("Blizzard_CompactRaidFrames")
			EnableAddOn("Blizzard_CUFProfiles")
			ReloadUI()
			end},
		   { name = "No", OnClick = function()
			EnableAddOn("Blizzard_CompactRaidFrames")
			EnableAddOn("Blizzard_CUFProfiles")
		   end}
		)

		return
	end

	for i=1, 20 do
		local button = _G['InterfaceOptionsFrameCategoriesButton'..i]
		local text = _G['InterfaceOptionsFrameCategoriesButton'..i..'Text']
		if text then
			if text:GetText() == COMPACT_UNIT_FRAME_PROFILES then
				button:SetScale(0.0001)
				break
			end
		end
	end

	hooksecurefunc("CompactRaidFrameManager_UpdateShown", HideRaid)
	CompactRaidFrameManager:HookScript('OnShow', HideRaid)
	CompactRaidFrameContainer:UnregisterAllEvents()

	hooksecurefunc('CompactRaidGroup_OnLoad', function(self)
		self:UnregisterEvent("GROUP_ROSTER_UPDATE");
	end)

	HideRaid()
	hooksecurefunc("CompactUnitFrame_RegisterEvents", function(self)

		if string.match( (self.unit or '') , 'nameplate') then
			return
		end

		CompactUnitFrame_UnregisterEvents(self)
	end)

	for i=1,4 do
		local frame = _G["PartyMemberFrame"..i]
		frame:UnregisterAllEvents()
		frame:SetParent(HidenUIParent)
		frame:SetAlpha(0)
		_G["PartyMemberFrame"..i..'HealthBar']:UnregisterAllEvents()
		_G["PartyMemberFrame"..i..'ManaBar']:UnregisterAllEvents()
	end
end

local optsSelectedProfile = nil
local createProfile_CopyFrom = nil

function RF.RaidMoverHandler(event, point1, parent, point2, xOffset, yOffset)
	if event == 'SetFrameOpts' then
		options.position = format('%s\031%s\031%s\031%d\031%d', point1, parent, point2, xOffset, yOffset)
	end
end

local function HideProfileCreatorFrame()

--	print("T", 'HideProfileCreatorFrame')
	RF.profileCreator:Hide()
	createProfile_CopyFrom = nil

	AleaUI_GUI:Open('AleaUI')
	AleaUI_GUI:SelectGroup('AleaUI', 'RaidFrames')
end

local function CreateNewRaidProfile()
	local name = RF.profileCreator.editBox:GetText()
	local copyFrom = createProfile_CopyFrom or 1

	if name and copyFrom then

		local copyFromProfile = E.db.raidFramesSettings.ProfileList[copyFrom]

		E.db.raidFramesSettings.Profiles[name] = E.deepcopy( E.db.raidFramesSettings.Profiles[copyFromProfile])
		E.db.raidFramesSettings.Profiles[name].name = name
		E.db.raidFramesSettings.Profiles[name].deletable = true

		E.chardb.raidFramesSettings.Profiles[name] = { perCharSpec = {}, }

		for i=1, GetNumSpecializations() do
			E.chardb.raidFramesSettings.Profiles[name].perCharSpec[i] = false
		end

		table.insert(E.db.raidFramesSettings.ProfileList, name)

		E.db.raidFramesSettings.lastProfile = #E.db.raidFramesSettings.ProfileList
		RF:UpdateProfileSettings()
	end

	HideProfileCreatorFrame()
end

local profileCreator = CreateFrame('Frame', 'AleaUIRaidProfileCreationFrame', E.UIParent)
profileCreator:SetSize(350, 160)
profileCreator:SetPoint('CENTER', E.UIParent, 'CENTER', 0, 0)
profileCreator:Hide()

profileCreator.editBox = CreateFrame("EditBox", nil, profileCreator, "InputBoxTemplate")
profileCreator.editBox:SetFontObject(ChatFontNormal)
profileCreator.editBox:SetFrameLevel(profileCreator:GetFrameLevel() + 1)
profileCreator.editBox:SetAutoFocus(false)
profileCreator.editBox:SetWidth(160)
profileCreator.editBox:SetHeight(20)
profileCreator.editBox:SetPoint('TOP', profileCreator, 'TOP', 0, -40)
profileCreator.editBox:SetScript("OnEscapePressed", function(self)
	self:ClearFocus()
end)

profileCreator.header = profileCreator:CreateFontString()
profileCreator.header:SetFont(E.media.default_font, E.media.default_font_size+4, 'OUTLINE')
profileCreator.header:SetText(L['New profile'])
profileCreator.header:SetPoint('BOTTOM', profileCreator.editBox, 'TOP', 0, 2)
profileCreator.header:SetTextColor(1, 0.8, 0)

profileCreator.createButton = CreateFrame('Button', nil, profileCreator, "UIPanelButtonTemplate")
profileCreator.createButton:SetSize(120, 22)
profileCreator.createButton:SetFrameLevel(profileCreator:GetFrameLevel() + 2)
profileCreator.createButton:SetText(L['Create'])
profileCreator.createButton:SetPoint('BOTTOMRIGHT', profileCreator, 'BOTTOM', 0, 5)
profileCreator.createButton:SetScript('OnClick', CreateNewRaidProfile)

profileCreator.cancelButton = CreateFrame('Button', nil, profileCreator, "UIPanelButtonTemplate")
profileCreator.cancelButton:SetSize(120, 22)
profileCreator.cancelButton:SetFrameLevel(profileCreator:GetFrameLevel() + 2)
profileCreator.cancelButton:SetText(CANCEL)
profileCreator.cancelButton:SetPoint('LEFT', profileCreator.createButton, 'RIGHT', 0, 0)
profileCreator.cancelButton:SetScript('OnClick', HideProfileCreatorFrame)

profileCreator.header2 = profileCreator:CreateFontString()
profileCreator.header2:SetFont(E.media.default_font, E.media.default_font_size+4, 'OUTLINE')
profileCreator.header2:SetText(L['Copy from'])
profileCreator.header2:SetPoint('BOTTOM', profileCreator.dropdown, 'TOP', 0, 2)
profileCreator.header2:SetTextColor(1, 0.8, 0)

profileCreator.dropdown = AleaUI_GUI:GetPrototype('dropdown')
profileCreator.dropdown.free = false
profileCreator.dropdown:ClearAllPoints()
profileCreator.dropdown:SetParent(profileCreator)
profileCreator.dropdown:SetWidth(150)
profileCreator.dropdown:SetPoint('TOP', profileCreator.editBox, 'BOTTOM', 0, -10)
profileCreator.dropdown.settings = {
	order = 1,
	name = L['Copy from']..':',
	width = 'full',
	docked = true,
	values = function()
		local t = {}

		for k,v in pairs(E.db.raidFramesSettings.ProfileList) do

			t[k] = E.db.raidFramesSettings.Profiles[v].name or v
			if t[k] == 'Main' then t[k] = L['MainRaidProfile'] end
		end

		return t
	end,
	set = function(self, value)
		createProfile_CopyFrom = value
	end,
	get = function(self)
		return createProfile_CopyFrom
	end,
}

profileCreator.dropdown.main.RefreshData = function()
	profileCreator.dropdown:Update(profileCreator, profileCreator.dropdown.settings)

	if AleaUI_GUI:IsOpened(addonName) then
		AleaUI_GUI:IsOpened(addonName):RefreshData()
	else
		AleaUI_GUI:FreeDropDowns()
	end
end

RF.profileCreator = profileCreator

manager.dropdown = AleaUI_GUI:GetPrototype('dropdown')
manager.dropdown.free = false
manager.dropdown:SetParent(manager)
manager.dropdown:ClearAllPoints()
manager.dropdown:SetPoint('TOP', manager, 'TOP', -25, -4)
manager.dropdown:SetWidth(110)
manager.dropdown.settings = {
	order = 1,
	name = L['Profile:'],
	width = 'full',
	docked = true,
	values = function()
		local t = {}

		for k,v in pairs(E.db.raidFramesSettings.ProfileList) do
			t[k] = E.db.raidFramesSettings.Profiles[v].name or v
			if t[k] == 'Main' then t[k] = L['MainRaidProfile'] end
		end

		return t
	end,
	set = function(self, value)
		E.db.raidFramesSettings.lastProfile = value
		RF:UpdateProfileSettings()
	end,
	get = function(self)
		return E.db.raidFramesSettings.lastProfile
	end,
}

manager.dropdown.main.RefreshData = function()
	manager.dropdown:Update(manager, manager.dropdown.settings)

	if AleaUI_GUI:IsOpened(addonName) then
		AleaUI_GUI:IsOpened(addonName):RefreshData()
	else
		AleaUI_GUI:FreeDropDowns()
	end
end

 do

	local button = CreateFrame("Button", nil, manager, BackdropTemplateMixin and 'BackdropTemplate')
	button.text = button:CreateFontString()
	button.text:SetFont(STANDARD_TEXT_FONT, 12, "")
	button.text:SetText("|TInterface\\Buttons\\UI-OptionsButton:14:14:0:0|t")
	button.text:SetPoint("CENTER")
	button.text:SetSize(30, 30)
	button:SetBackdrop({
			bgFile = [=[Interface\TargetingFrame\UI-StatusBar]=],
			edgeFile = [=[Interface\ChatFrame\ChatFrameBackground]=], edgeSize = 1,
			insets = {top = 0, left = 0, bottom = 0, right = 0},
			})
	button:SetBackdropColor(0.2, 0.2, 0.2, 1) --цвет фона
	button:SetBackdropBorderColor(0.4, 0.4, 0.4, 1) --цвет фона

	button:SetWidth(25)
	button:SetHeight(25)
	button:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:AddLine("Open settings", 0, 1, 0.5, 1, 1, 1)
		GameTooltip:Show()
		self:SetBackdropBorderColor(1, 1, 1, 1) --цвет краев
	end)
	button:SetScript("OnLeave", function(self)
		GameTooltip:Hide()
		self:SetBackdropBorderColor(0.4, 0.4, 0.4, 1) --цвет краев
	end)
	button:SetScript("OnClick", function(self)
		if AleaUI_GUI:IsOpened(addonName) then
			AleaUI_GUI:SelectGroup("AleaUI", "RaidFrames")
		else
			AleaUI_GUI:Open(addonName)
			AleaUI_GUI:SelectGroup("AleaUI", "RaidFrames")
		end
	end)
	button:SetPoint("LEFT", manager.dropdown, "RIGHT", 4, -2)
	button:Hide()

	manager.OpenSettings = button
end


function RF:PrepareProfiles()
	for profileName, profile in pairs(E.db.raidFramesSettings.Profiles) do

		if profile.enablePVP == nil then

			profile.enablePVP = true
			profile.enablePVE = true
		--	profile.enable1Spec = true
		--	profile.enable2Spec = true
		end

		if profile.raidSize == nil then
			profile.raidSize = 1
		end
		if profile.raidSize_max == nil then
			profile.raidSize_max = 40
		end

		if not E.chardb.raidFramesSettings.Profiles[profileName] then
			E.chardb.raidFramesSettings.Profiles[profileName] = {}

			if profileName == 'MainProfile' then
				E.chardb.raidFramesSettings.Profiles[profileName].perCharSpec = { true, true }
			else
				E.chardb.raidFramesSettings.Profiles[profileName].perCharSpec = { false, false }
			end

			if profile.perCharSpec and profile.perCharSpec[ profileOwner ] then
				E.chardb.raidFramesSettings.Profiles[profileName].perCharSpec = profile.perCharSpec[ profileOwner ]
				profile.perCharSpec[ profileOwner ] = {}
				profile.perCharSpec[ profileOwner ] = nil
			end
		end

		if profile.groupToShow == nil then
			profile.groupToShow = {true,true,true,true,true,true,true,true,}
		end

		if profile.amountBuffs == nil then
			profile.amountBuffs = 3
			profile.amountDebuffs = 3

			profile.buffSize = 12
			profile.buffSizeBig = 18
			profile.debuffSize = 12
			profile.debuffSizeBig = 18
		end

		if profile.artwork == nil then
			profile.artwork = {
				['enable'] = false,
				['width'] = 100,
				['height'] = 100,
				["background_texture"] = E.media.default_bar_texture_name3,
				["size"] = 1,
				["inset"] = 0,
				["color"] = {
					0,
					0,
					0,
					1,
				},
				["background_inset"] = 0,
				["background_color"] = {
					0,
					0,
					0,
					0.6,
				},
				["texture"] = E.media.default_bar_texture_name3,
			}
		end

		if profile.artwork.width == nil then
			profile.artwork.width = 100
		end
		if profile.artwork.height == nil then
			profile.artwork.height = 100
		end

		if E.chardb.raidFramesSettings.Profiles[profileName].indicators then
			E.chardb.raidFramesSettings.Profiles[profileName].indicators = nil
		end
	end
end

E:OnInit2(function()

	profileOwner = E.myname..' - '..E.myrealm

	RF:PrepareProfiles()

	if E.db.raidFramesSettings.enableModule then
		TOTAL_HEADERS = 8
		RegisterStateDriver(manager, "visibility", "[group:raid][group:party]show;hide")

		RF:DisableBlizzard()
	else
		TOTAL_HEADERS = 0
		RegisterStateDriver(manager, "visibility", "hide")
	end

	local lastProfile = E.db.raidFramesSettings.lastProfile or 1

	profileCreator.backdrop = Skins.NewBackdrop(profileCreator)
	Skins.SetTemplate(profileCreator.backdrop, 'DARK')
	Skins.ThemeEditBox(profileCreator.editBox, true)
	Skins.ThemeButton(profileCreator.createButton)
	Skins.ThemeButton(profileCreator.cancelButton)

	local profileName = E.db.raidFramesSettings.ProfileList[lastProfile] or E.db.raidFramesSettings.ProfileList[1]
	options = E.db.raidFramesSettings.Profiles[profileName]
	charOptions = E.chardb.raidFramesSettings.Profiles[profileName]

	manager:SetAttribute('AleaGrowUp', options.gropUp)
	manager:SetAttribute('AleaHorizontal', options.horizontal)

	for i=1, TOTAL_HEADERS do
		local header = CreateGroupHeader(i)
		header:Show()
		headerLists[#headerLists+1] = header
	end

	if ( false ) then
		local header = CreateGroupHeader("pet")
		header:Show()
	end

	profileCreator.dropdown.main:RefreshData()

--	print("OnInit2", InCombatLockdown())
	E.SetFrameOptsCustom("raidframeHeader", E.UnpackFrameOpts(options.position))
	E:Mover(raid, "raidframeHeader", 200, 20, "TOPLEFT", RF.RaidMoverHandler)

	RF.UpdateRaidFrameBackgroundSettings()

	E.GUI.args.RaidFrames = {
		name = L["Raid frames"],
		type = "group",
		order = 5,
		args = {},
	}

	E.GUI.args.RaidFrames.args.blizzardSettings = {
		name = L["Blizzard Settings"],
		type = "tabgroup",
		width = 'full',
		order = 2,
		args = {}
	}

	E.GUI.args.RaidFrames.args.blizzardSettings.args.indicatorSettings = {
		name = L["Indicators"],
		type = "group",
		embend = true,
		order = -1,
		args = {},
	}


	for k, v in pairs({ 'topleft', 'topright', 'bottomleft', 'bottomright'}) do

		--	['topleft'] = { spellID = 1, enable = true, color = { 0, 1, 0 }, },
		--	['topright'] = { spellID = 1, enable = true, color = { 0, 1, 0 }, },
		--	['bottomleft'] = { spellID = 1, enable = true, color = { 0, 1, 0 }, },
		--	['bottomright'] = { spellID = 1, enable = true, color = { 0, 1, 0 }, },

		E.GUI.args.RaidFrames.args.blizzardSettings.args.indicatorSettings.args[v] = {
			name = L['RF'..v]..' - '..UNKNOWN,
			type = 'group',
			order = k,
			embend = true,
			args = {}
		}

		C_Timer.After(1, RF.UpdateIndicatorsGUI)

		E.GUI.args.RaidFrames.args.blizzardSettings.args.indicatorSettings.args[v].args.enable = {
			name = L['Enable'],
			type = "toggle",
			order = 1,
			set = function(self, value)
				if not E.chardb.raidFramesSettings.indicators[E.myclass] then
					E.chardb.raidFramesSettings.indicators[E.myclass] = {}
				end
				if not E.chardb.raidFramesSettings.indicators[E.myclass][GetSpecialization()] then
					E.chardb.raidFramesSettings.indicators[E.myclass][GetSpecialization()] = {}
				end
				if not E.chardb.raidFramesSettings.indicators[E.myclass][GetSpecialization()][v] then
					E.chardb.raidFramesSettings.indicators[E.myclass][GetSpecialization()][v] = {}
				end

				E.chardb.raidFramesSettings.indicators[E.myclass][GetSpecialization()][v].enable = not E.chardb.raidFramesSettings.indicators[E.myclass][GetSpecialization()][v].enable
			end,
			get = function(self)
				if not E.chardb.raidFramesSettings.indicators[E.myclass] then return false end
				if not E.chardb.raidFramesSettings.indicators[E.myclass][GetSpecialization()] then return false end
				if not E.chardb.raidFramesSettings.indicators[E.myclass][GetSpecialization()][v] then return false end

				return E.chardb.raidFramesSettings.indicators[E.myclass][GetSpecialization()][v].enable
			end,
		}
		E.GUI.args.RaidFrames.args.blizzardSettings.args.indicatorSettings.args[v].args.spellID = {
			name = L['SpellID'],
			type = "editbox",
			order = 2,
			set = function(self, value)
				if value then
					if not E.chardb.raidFramesSettings.indicators[E.myclass] then
						E.chardb.raidFramesSettings.indicators[E.myclass] = {}
					end
					if not E.chardb.raidFramesSettings.indicators[E.myclass][GetSpecialization()] then
						E.chardb.raidFramesSettings.indicators[E.myclass][GetSpecialization()] = {}
					end
					if not E.chardb.raidFramesSettings.indicators[E.myclass][GetSpecialization()][v] then
						E.chardb.raidFramesSettings.indicators[E.myclass][GetSpecialization()][v] = {}
					end

					E.GUI.args.RaidFrames.args.blizzardSettings.args.indicatorSettings.args[v].name = L['RF'..v]..' - '..( GetSpellInfo(value) and E:SpellString(value) or E:SpellString(nil) )

					E.chardb.raidFramesSettings.indicators[E.myclass][GetSpecialization()][v].spellID = value
				end
			end,
			get = function(self)
				if not E.chardb.raidFramesSettings.indicators[E.myclass] then return '' end
				if not E.chardb.raidFramesSettings.indicators[E.myclass][GetSpecialization()] then return '' end
				if not E.chardb.raidFramesSettings.indicators[E.myclass][GetSpecialization()][v] then return '' end

				local value =  E.chardb.raidFramesSettings.indicators[E.myclass] and
					E.chardb.raidFramesSettings.indicators[E.myclass][GetSpecialization()] and
					E.chardb.raidFramesSettings.indicators[E.myclass][GetSpecialization()][v] and
					E.chardb.raidFramesSettings.indicators[E.myclass][GetSpecialization()][v].spellID or ''

				E.GUI.args.RaidFrames.args.blizzardSettings.args.indicatorSettings.args[v].name = L['RF'..v]..' - '..( GetSpellInfo(value) and E:SpellString(value) or E:SpellString(nil) )


				return value
			end,
		}
	end

	E.GUI.args.RaidFrames.args.profileList = {
		name = L["Profiles"],
		type = "dropdown",
		order = 1,
		values = function()
			local t = {}

			for i=1, #E.db.raidFramesSettings.ProfileList do

				local value = E.db.raidFramesSettings.ProfileList[i]
				local name = E.db.raidFramesSettings.Profiles[value]

				t[i] = name and name.name or E.db.raidFramesSettings.ProfileList[i]
				if t[i] == 'Main' then t[i] = L['MainRaidProfile'] end
			end

			t[99999] = '...'..L['New']

			return t
		end,
		set = function(self, value)
		--	print('Профили', 'on set', value)

			if value == 99999 then
		--		print("T", 'Create New', value)
				AleaUI_GUI:Close('AleaUI')
				RF.profileCreator:Show()
				RF.profileCreator.dropdown.main:RefreshData()
			else
				E.db.raidFramesSettings.lastProfile = value
				RF:UpdateProfileSettings()
			end
		end,
		get = function(self)
			return E.db.raidFramesSettings.lastProfile or 1
		end,
	}

	E.GUI.args.RaidFrames.args.unlock = {
		name = L['Unlock'],
		type = 'execute',
		order = 1.3,
		set = function()
			E:UnlockMover('raidframeHeader')
		end,
		get = function()end,
	}


	E.GUI.args.RaidFrames.args.enableModule = {
		name = L["Enabled"],
		type = "toggle",
		order = 1.4,
		set = function(self, value)
			AleaUI_GUI.ShowPopUp(
			   "AleaUI",
			   L['To apply changes you need reload ui. Do it now?'],
			   { name = YES, OnClick = function()
					E.db.raidFramesSettings.enableModule = not E.db.raidFramesSettings.enableModule
					ReloadUI()
				end},
			   { name = NO, OnClick = function()

			   end}
			)
		end,
		get = function(self)
			return E.db.raidFramesSettings.enableModule
		end,
	}

	E.GUI.args.RaidFrames.args.blizzardSettings.args.general = {
		name = L['General'],
		type = 'group',
		order = 1,
		args = {},
	}


	E.GUI.args.RaidFrames.args.blizzardSettings.args.general.args.horizontalFill = {
		name = L['Horizontal bar fill'],
		type = "toggle",
		order = 1.4,
		set = function(self, value)
		--	print('Горизонтальные', 'on set')
			options.horizontalFill = not options.horizontalFill
			RF:InterateArtElements('UpdateStatusBarTexture')
		end,
		get = function(self)
		--	print('Горизонтальные', 'on get')
			return options.horizontalFill
		end,
	}

	E.GUI.args.RaidFrames.args.blizzardSettings.args.general.args.showPowerBars = {
		name = L['Show power bars'],
		type = "toggle",
		order = 1.4,
		set = function(self, value)
		--	print('Горизонтальные', 'on set')
			options.showPowerBars = not options.showPowerBars
			RF:InterateArtElements('UpdateStatusBarTexture')
		end,
		get = function(self)
		--	print('Горизонтальные', 'on get')
			return options.showPowerBars
		end,
	}

	E.GUI.args.RaidFrames.args.blizzardSettings.args.general.args.smoothBars = {
		name = L['Smooth bars'],
		type = "toggle",
		order = 1.5,
		set = function(self, value)
		--	print('Горизонтальные', 'on set')
			options.smoothBars = not options.smoothBars
			RF:InterateArtElements('UpdateStatusBarTexture')
		end,
		get = function(self)
		--	print('Горизонтальные', 'on get')
			return options.smoothBars
		end,
	}

	E.GUI.args.RaidFrames.args.blizzardSettings.args.general.args.horizontal = {
		name = L['Horizontal position'],
		type = "toggle",
		order = 1.8,
		set = function(self, value)
		--	print('Горизонтальные', 'on set')
			options.horizontal = not options.horizontal
			RF:UpdateProfileSettings()
		end,
		get = function(self)
		--	print('Горизонтальные', 'on get')
			return options.horizontal
		end,
	}

	E.GUI.args.RaidFrames.args.blizzardSettings.args.general.args.gropUp = {
		name = L['Grow up'],
		type = "toggle",
		order = 1.9,
		width = 'full',
		set = function(self, value)
		--	print('Рост вверх', 'on set')
			options.gropUp = not options.gropUp
			RF:UpdateProfileSettings()
		end,
		get = function(self)
		--	print('Рост вверх', 'on get')
			return options.gropUp
		end,
	}

	E.GUI.args.RaidFrames.args.blizzardSettings.args.general.args.width = {
		name = L['Width'],
		order = 2,
		type = "slider",
		min = 20, max = 200, step = 1,
		set = function(self, value)
		--	print('Ширина', 'on set', value)
			options.width = value
			RF:UpdateProfileSettings()
		end,
		get = function(self)
			return options.width
		end
	}

	E.GUI.args.RaidFrames.args.blizzardSettings.args.general.args.height = {
		name = L['Height'],
		order = 3,
		type = "slider",
		min = 20, max = 200, step = 1,
		set = function(self, value)
		--	print('Высота', 'on set', value)
			options.height = value
			RF:UpdateProfileSettings()
		end,
		get = function(self)
			return options.height
		end
	}

	E.GUI.args.RaidFrames.args.blizzardSettings.args.general.args.XOffset = {
		name = L['Step1'],
		order = 3.1,
		type = "slider",
		min = 0, max = 20, step = 1,
		set = function(self, value)
		--	print('Ширина', 'on set', value)
			options.xOffset = value
			RF:UpdateProfileSettings()
		end,
		get = function(self)
			return options.xOffset
		end
	}

	E.GUI.args.RaidFrames.args.blizzardSettings.args.general.args.YOffset = {
		name = L['Step2'],
		order = 3.2,
		type = "slider",
		min = 0, max = 20, step = 1,
		set = function(self, value)
		--	print('Ширина', 'on set', value)
			options.yOffset = value
			RF:UpdateProfileSettings()
		end,
		get = function(self)
			return options.yOffset
		end
	}

	E.GUI.args.RaidFrames.args.blizzardSettings.args.general.args.backgroundcolor = {
		name = L['Background color'],
		order = 3.6,
		type = "color",
		hasAlpha = true,
		set = function(self, r,g,b,a)
			options.bgcolor = { r, g, b, a }
			RF:UpdateProfileSettings()
		end,
		get = function(self)
			return options.bgcolor[1], options.bgcolor[2], options.bgcolor[3], options.bgcolor[4]
		end,
	}

	E.GUI.args.RaidFrames.args.blizzardSettings.args.general.args.color = {
		name = L["Color"],
		order = 3.7,
		type = "color",
		hasAlpha = true,
		set = function(self, r,g,b,a)
			options.color = { r, g, b, a }
			RF:InterateArtElements('UpdateStatusBarTexture')
		end,
		get = function(self)
			return options.color[1], options.color[2], options.color[3], options.color[4]
		end,
	}

	E.GUI.args.RaidFrames.args.blizzardSettings.args.general.args.texture = {
		name = L['Texture'],
		order = 3.8,
		type = "statusbar",
		values = E.GetTextureList,
		set = function(self, value)
			options.texture = value

			RF:InterateArtElements('UpdateStatusBarTexture')
		end,
		get = function(self)
			return options.texture
		end,
	}

	E.GUI.args.RaidFrames.args.blizzardSettings.args.general.args.font = {
		name = L['Font'],
		order = 3.9,
		type = "font",
		values = E.GetFontList,
		set = function(self, value)
			options.font = value
			RF:InterateArtElements('UpdateFontStyle')
		end,
		get = function(self)
			return options.font
		end,
	}

	E.GUI.args.RaidFrames.args.blizzardSettings.args.general.args.fontSize = {
		name = L['Font size'],
		order = 4,
		type = "slider", min = 3, max = 32, step = 1,
		set = function(self, value)
			options.fontSize = value
			RF:InterateArtElements('UpdateFontStyle')
		end,
		get = function(self)
			return options.fontSize or 10
		end,
	}

	E.GUI.args.RaidFrames.args.blizzardSettings.args.auraIconSettings = {
		name = L['Auras'],
		type = "group",
		order = 4,
		embend = true,
		args = {},
	}

	E.GUI.args.RaidFrames.args.blizzardSettings.args.auraIconSettings.args.buffShowing = {
		name = L['Buff amount'],
		order = 1, width = 'full',
		type = "slider", min = 1, max = 3, step = 1,
		set = function(self, value)
			options.amountBuffs = value
			RF:InterateArtElements('UpdateBuffAndDebuff')
		end,
		get = function(self)
			return options.amountBuffs or 3
		end,
	}

	E.GUI.args.RaidFrames.args.blizzardSettings.args.auraIconSettings.args.buffSize = {
		name = L['Buff size'],
		order = 2,
		type = "slider", min = 3, max = 32, step = 1,
		set = function(self, value)
			options.buffSize = value
			RF:InterateArtElements('UpdateBuffAndDebuff')
		end,
		get = function(self)
			return options.buffSize or 12
		end,
	}

	E.GUI.args.RaidFrames.args.blizzardSettings.args.auraIconSettings.args.buffSizeBig = {
		name = L['Big buff size'],
		order = 3,
		type = "slider", min = 3, max = 32, step = 1,
		set = function(self, value)
			options.buffSizeBig = value
			RF:InterateArtElements('UpdateBuffAndDebuff')
		end,
		get = function(self)
			return options.buffSizeBig or 18
		end,
	}

	E.GUI.args.RaidFrames.args.blizzardSettings.args.auraIconSettings.args.debuffShowing = {
		name = L['Debuff amount'],
		order = 4, width = 'full',
		type = "slider", min = 1, max = 3, step = 1,
		set = function(self, value)
			options.amountDebuffs = value
			RF:InterateArtElements('UpdateBuffAndDebuff')
		end,
		get = function(self)
			return options.amountDebuffs or 3
		end,
	}

	E.GUI.args.RaidFrames.args.blizzardSettings.args.auraIconSettings.args.debuffSize = {
		name = L['Debuff size'],
		order = 5,
		type = "slider", min = 3, max = 32, step = 1,
		set = function(self, value)
			options.debuffSize = value
			RF:InterateArtElements('UpdateBuffAndDebuff')
		end,
		get = function(self)
			return options.debuffSize or 12
		end,
	}

	E.GUI.args.RaidFrames.args.blizzardSettings.args.auraIconSettings.args.debuffSizeBig = {
		name = L['Big debuff size'],
		order = 6,
		type = "slider", min = 3, max = 32, step = 1,
		set = function(self, value)
			options.debuffSizeBig = value
			RF:InterateArtElements('UpdateBuffAndDebuff')
		end,
		get = function(self)
			return options.debuffSizeBig or 18
		end,
	}

	E.GUI.args.RaidFrames.args.blizzardSettings.args.autoEnable = {
		name = L['Auto enable'],
		type = "group",
		order = 5,
		embend = true,
		args = {},
	}

	E.GUI.args.RaidFrames.args.blizzardSettings.args.autoEnable.args.enablePVP = {
		name = L["for PVP"],
		type = "toggle",
		order = 4,
		set = function(self, value)
			options.enablePVP = not options.enablePVP
			RF:ReCheckAuraActivation()
			RF:UpdateProfileSettings()
		end,
		get = function(self)
			return options.enablePVP
		end,
	}

	E.GUI.args.RaidFrames.args.blizzardSettings.args.autoEnable.args.enablePVE = {
		name = L["for PVE"],
		type = "toggle",
		order = 5,
		set = function(self, value)
			options.enablePVE = not options.enablePVE
			RF:ReCheckAuraActivation()
			RF:UpdateProfileSettings()
		end,
		get = function(self)
			return options.enablePVE
		end,
	}

	if not E.isClassic and GetNumSpecializations() == 0 then
		local handler = CreateFrame('Frame')
		handler:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
		handler:RegisterEvent("PLAYER_LOGIN")
		handler:SetScript('OnEvent', function(self, event, unit)
			unit = unit or 'player'
			if unit ~= 'player' then return end

			if GetNumSpecializations() == 0 then return end

			for i=1, GetNumSpecializations() do
				local id, name, description, icon, background, role = GetSpecializationInfo(i)
				local tName = name and "|T"..icon ..":0:0:0:0|t"..name or L['Not selected']

				if charOptions.perCharSpec[i] == nil then
					charOptions.perCharSpec[i] = false
				end

				E.GUI.args.RaidFrames.args.blizzardSettings.args.autoEnable.args['enable'..i..'Spec'] = {
					name = tName,
					order = 5+i,
					type = "toggle",
					newLine = i==1 and true or false,
					set = function(self, value)
						charOptions.perCharSpec[i] = not charOptions.perCharSpec[i]
						RF:ReCheckAuraActivation()
						RF:UpdateProfileSettings()
					end,
					get = function(self)
						return charOptions.perCharSpec[i]
					end,
				}
			end

			handler:UnregisterAllEvents()
		end)
	elseif not E.isClassic then 
		for i=1, GetNumSpecializations() do
			local id, name, description, icon, background, role = GetSpecializationInfo(i)
			local tName = name and "|T"..icon ..":0:0:0:0|t"..name or L['Not selected']

			if charOptions.perCharSpec[i] == nil then
				charOptions.perCharSpec[i] = false
			end

			E.GUI.args.RaidFrames.args.blizzardSettings.args.autoEnable.args['enable'..i..'Spec'] = {
				name = tName,
				order = 5+i,
				type = "toggle",
				newLine = i==1 and true or false,
				set = function(self, value)
					charOptions.perCharSpec[i] = not charOptions.perCharSpec[i]
					RF:ReCheckAuraActivation()
					RF:UpdateProfileSettings()
				end,
				get = function(self)
					return charOptions.perCharSpec[i]
				end,
			}
		end
	elseif E.isClassic then 
		for i=1, 1 do
			local tName = L['Not selected']

			if charOptions.perCharSpec[i] == nil then
				charOptions.perCharSpec[i] = false
			end

			E.GUI.args.RaidFrames.args.blizzardSettings.args.autoEnable.args['enable'..i..'Spec'] = {
				name = tName,
				order = 5+i,
				type = "toggle",
				newLine = i==1 and true or false,
				set = function(self, value)
					charOptions.perCharSpec[i] = not charOptions.perCharSpec[i]
					RF:ReCheckAuraActivation()
					RF:UpdateProfileSettings()
				end,
				get = function(self)
					return charOptions.perCharSpec[i]
				end,
			}
		end
	end
	--[==[
	E.GUI.args.RaidFrames.args.autoEnable.args.enable1Spec = {
		name = "1 спек",
		type = "toggle",
		order = 6,
		set = function(self, value)
			options.perCharSpec[ profileOwner ][1] = not options.perCharSpec[ profileOwner ][1]
			options.enable1Spec = not options.enable1Spec
			RF:UpdateProfileSettings()
		end,
		get = function(self)
			return options.perCharSpec[ profileOwner ][1]
		--	return options.enable1Spec
		end,
	}

	E.GUI.args.RaidFrames.args.autoEnable.args.enable2Spec = {
		name = "2 спек",
		type = "toggle",
		order = 7,
		set = function(self, value)
			options.perCharSpec[ profileOwner ][2] = not options.perCharSpec[ profileOwner ][2]
			options.enable2Spec = not options.enable2Spec
			RF:UpdateProfileSettings()
		end,
		get = function(self)
			return options.perCharSpec[ profileOwner ][2]
		--	return options.enable2Spec
		end,
	}
	]==]

	E.GUI.args.RaidFrames.args.blizzardSettings.args.autoEnable.args.raidorpartySize_min = {
		name = L["Raid size from:"],
		desc = L['Minimum instance size to enable this profile.'],
		order = 15,
		type = "slider",
		newLine = true,
		min = 1, max = 40, step = 1,
		set = function(self, value)
			options.raidSize = value
			RF:ReCheckAuraActivation()
			RF:UpdateProfileSettings()
		end,
		get = function(self)
			return options.raidSize
		end
	}

	E.GUI.args.RaidFrames.args.blizzardSettings.args.autoEnable.args.raidorpartySize_max = {
		name = L["Raid size up to:"],
		desc = L['Maximum instance size to enable this profile.'],
		order = 16,
		type = "slider",
		min = 1, max = 40, step = 1,
		set = function(self, value)
			options.raidSize_max = value
			RF:ReCheckAuraActivation()
			RF:UpdateProfileSettings()
		end,
		get = function(self)
			return options.raidSize_max
		end
	}

	E.GUI.args.RaidFrames.args.blizzardSettings.args.groupToShow = {
		name = L["Show groups"],
		type = "group",
		order = 6,
		embend = true,
		args = {},
	}

	for i=1, 8 do

		E.GUI.args.RaidFrames.args.blizzardSettings.args.groupToShow.args['group'..i] = {
			name = L["Group"].." "..i,
			type = "toggle",
			order = i,
			set = function(self, value)
				options.groupToShow[i] = not options.groupToShow[i]
				lastLastLastProfile = nil
				RF:ReCheckAuraActivation()
				RF:UpdateProfileSettings()
			end,
			get = function(self)
				return options.groupToShow[i]
			end,
		}

	end

	E.GUI.args.RaidFrames.args.blizzardSettings.args.ArtWorkOpts = {
		name = L['Art background'],
		order = 11,
		embend = true,
		type = "group",
		args = {}
	}

	E.GUI.args.RaidFrames.args.blizzardSettings.args.ArtWorkOpts.args.Enable = {
		name = L['Enable'],
		type = 'toggle',
		order = 0.1,
		width = 'full',
		set = function(info)
			options.artwork.enable = not options.artwork.enable
			RF.UpdateRaidFrameBackgroundSettings()
		end,
		get = function(info)
			return options.artwork.enable
		end,
	}

	E.GUI.args.RaidFrames.args.blizzardSettings.args.ArtWorkOpts.args.Width = {
		name = L['Width'],
		type = "slider",
		order	= 0.2,
		min		= 1,
		max		= 500,
		step	= 1,
		set = function(info,val)
			options.artwork.width = val
			RF.UpdateRaidFrameBackgroundSettings()
		end,
		get =function(info)
			return options.artwork.width
		end,
	}
	E.GUI.args.RaidFrames.args.blizzardSettings.args.ArtWorkOpts.args.Height = {
		name = L['Height'],
		type = "slider",
		order	= 0.3,
		min		= 1,
		max		= 500,
		step	= 1,
		set = function(info,val)
			options.artwork.height = val
			RF.UpdateRaidFrameBackgroundSettings()
		end,
		get =function(info)
			return options.artwork.height
		end,
	}

	E.GUI.args.RaidFrames.args.blizzardSettings.args.ArtWorkOpts.args.BorderTexture = {
		order = 1,
		type = 'border',
		name = L['Border texture'],
		values = E:GetBorderList(),
		set = function(info,value)
			options.artwork.texture = value;
			RF.UpdateRaidFrameBackgroundSettings()
		end,
		get = function(info) return options.artwork.texture end,
	}

	E.GUI.args.RaidFrames.args.blizzardSettings.args.ArtWorkOpts.args.BorderColor = {
		order = 2,
		name = L['Border color'],
		type = "color",
		hasAlpha = true,
		set = function(info,r,g,b,a)
			options.artwork.color={ r, g, b, a};
			RF.UpdateRaidFrameBackgroundSettings()
		end,
		get = function(info)
			return options.artwork.color[1],
					options.artwork.color[2],
					options.artwork.color[3],
					options.artwork.color[4]
		end,
	}

	E.GUI.args.RaidFrames.args.blizzardSettings.args.ArtWorkOpts.args.BorderSize = {
		name = L['Border size'],
		type = "slider",
		order	= 3,
		min		= 1,
		max		= 32,
		step	= 1,
		set = function(info,val)
			options.artwork.size = val
			RF.UpdateRaidFrameBackgroundSettings()
		end,
		get =function(info)
			return options.artwork.size
		end,
	}

	E.GUI.args.RaidFrames.args.blizzardSettings.args.ArtWorkOpts.args.BorderInset = {
		name = L['Border inset'],
		type = "slider",
		order	= 4,
		min		= -32,
		max		= 32,
		step	= 1,
		set = function(info,val)
			options.artwork.inset = val
			RF.UpdateRaidFrameBackgroundSettings()
		end,
		get =function(info)
			return options.artwork.inset
		end,
	}


	E.GUI.args.RaidFrames.args.blizzardSettings.args.ArtWorkOpts.args.BackgroundTexture = {
		order = 5,
		type = 'statusbar',
		name = L['Background texture'],
		values = E.GetTextureList,
		set = function(info,value)
			options.artwork.background_texture = value;
			RF.UpdateRaidFrameBackgroundSettings()
		end,
		get = function(info) return options.artwork.background_texture end,
	}

	E.GUI.args.RaidFrames.args.blizzardSettings.args.ArtWorkOpts.args.BackgroundColor = {
		order = 6,
		name = L['Background color'],
		type = "color",
		hasAlpha = true,
		set = function(info,r,g,b,a)
			options.artwork.background_color={ r, g, b, a}
			RF.UpdateRaidFrameBackgroundSettings()
		end,
		get = function(info)
			return options.artwork.background_color[1],
					options.artwork.background_color[2],
					options.artwork.background_color[3],
					options.artwork.background_color[4]
		end,
	}


	E.GUI.args.RaidFrames.args.blizzardSettings.args.ArtWorkOpts.args.backgroundInset = {
		name = L['Background inset'],
		type = "slider",
		order	= 7,
		min		= -32,
		max		= 32,
		step	= 1,
		set = function(info,val)
			options.artwork.background_inset = val
			RF.UpdateRaidFrameBackgroundSettings()
		end,
		get =function(info)
			return options.artwork.background_inset
		end,
	}

	if (not E.isClassic) then 
	RF:RegisterEvent('PLAYER_SPECIALIZATION_CHANGED')
	RF:RegisterEvent('PLAYER_TALENT_UPDATE')
	RF:RegisterEvent('ACTIVE_TALENT_GROUP_CHANGED')
	end 
	RF:RegisterEvent('PLAYER_LEVEL_UP')
	RF:RegisterEvent('PLAYER_ENTERING_WORLD')
	RF:RegisterEvent('GROUP_JOINED')
	RF:RegisterEvent('GROUP_LEFT')

	RF:RegisterEvent('RAID_INSTANCE_WELCOME')
	RF:RegisterEvent('GROUP_ROSTER_UPDATE')
	RF:RegisterEvent('PLAYER_ENTERING_BATTLEGROUND')

	RF:RegisterEvent('ZONE_CHANGED')
	RF:RegisterEvent('ZONE_CHANGED_NEW_AREA')
	RF:RegisterEvent('ZONE_CHANGED_INDOORS')

	RF:RegisterEvent('PLAYER_REGEN_ENABLED')
	RF:RegisterEvent('PLAYER_REGEN_DISABLED')

	RF:PLAYER_REGEN_ENABLED()
	RF:UpdateProfileSettings()
end)

function RF:UpdateDeleteButton()
	if #E.db.raidFramesSettings.ProfileList == 1 then
		E.GUI.args.RaidFrames.args.delete = nil
	else
		E.GUI.args.RaidFrames.args.delete = E.GUI.args.RaidFrames.args.delete or {
			name = L['Delete profile'],
			type = 'execute',
			order = -1,
			set = function()
				if not E.db.raidFramesSettings.lastProfile then return end
				if E.db.raidFramesSettings.lastProfile == 1 then return end

				local temp = tremove(E.db.raidFramesSettings.ProfileList, E.db.raidFramesSettings.lastProfile)

				E.db.raidFramesSettings.Profiles[temp] = nil
				E.chardb.raidFramesSettings.Profiles[temp] = nil

				E.db.raidFramesSettings.lastProfile = 1

				lastLastLastProfile = nil

				RF:ReCheckAuraActivation()
				RF:UpdateProfileSettings()
			end,
			get = function()end,
		}
	end
end

function RF:UpdateOffsetGUI()
	if options.horizontal then
		-- step1
		-- vertical offset
		E.GUI.args.RaidFrames.args.blizzardSettings.args.general.args.XOffset.name = L['Vertical offset']
		E.GUI.args.RaidFrames.args.blizzardSettings.args.general.args.XOffset.order = 3.1
		-- step2
		-- horizontal
		E.GUI.args.RaidFrames.args.blizzardSettings.args.general.args.YOffset.name = L['Horizontal offset']
		E.GUI.args.RaidFrames.args.blizzardSettings.args.general.args.YOffset.order = 3.2
	else
		-- step2
		-- vertical offset
		E.GUI.args.RaidFrames.args.blizzardSettings.args.general.args.YOffset.name = L['Vertical offset']
		E.GUI.args.RaidFrames.args.blizzardSettings.args.general.args.YOffset.order = 3.1
		-- step1
		-- horizontal
		E.GUI.args.RaidFrames.args.blizzardSettings.args.general.args.XOffset.name = L['Horizontal offset']
		E.GUI.args.RaidFrames.args.blizzardSettings.args.general.args.XOffset.order = 3.2
	end
end

function RF:UpdateIndicatorsGUI()
	for k, v in pairs({ 'topleft', 'topright', 'bottomleft', 'bottomright'}) do
		local value =  E.chardb.raidFramesSettings.indicators[E.myclass] and
			E.chardb.raidFramesSettings.indicators[E.myclass][GetSpecialization()] and
			E.chardb.raidFramesSettings.indicators[E.myclass][GetSpecialization()][v] and
			E.chardb.raidFramesSettings.indicators[E.myclass][GetSpecialization()][v].spellID or ''

		E.GUI.args.RaidFrames.args.blizzardSettings.args.indicatorSettings.args[v].name = L['RF'..v]..' - '..( GetSpellInfo(value) and E:SpellString(value) or E:SpellString(nil) )
	end
end

local countMap = {};	--Maps number of players to the category. (For example, so that AQ20 counts as a 25-man.)
for i=1, 10 do countMap[i] = 10 end;
for i=11, 15 do countMap[i] = 15 end;
for i=16, 20 do countMap[i] = 20 end;
for i=21, 25 do countMap[i] = 25 end;
for i=26, 30 do countMap[i] = 30 end;
for i=31, 40 do countMap[i] = 40 end;

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

function RF:GetAutoActivationState()
	local name, instanceType, difficultyIndex, difficultyName, maxPlayers, playerDifficulty, isDynamic, mapID, instanceGroupSize = GetInstanceInfo();
	if ( not name ) then	--We don't have info.
		return false;
	end

	local numPlayers, profileType, enemyType;

	if ( instanceType == "party" or instanceType == "raid" ) then
		if ( maxPlayers <= 5 ) then
			numPlayers = 5;	--For 5-man dungeons.
		else
			numPlayers = difficultyRaidSize[difficultyIndex] or countMap[maxPlayers];
		end
		profileType, enemyType = instanceType, "PvE";
	elseif ( instanceType == "arena" ) then
		local groupSize = GetNumGroupMembers(LE_PARTY_CATEGORY_HOME);
		--TODO - Get the actual arena size, not just the # in party.
		if ( groupSize <= 2 ) then
			numPlayers, profileType, enemyType = 2, instanceType, "PvP";
		elseif ( groupSize <= 3 ) then
			numPlayers, profileType, enemyType = 3, instanceType, "PvP";
		else
			numPlayers, profileType, enemyType = 5, instanceType, "PvP";
		end
	elseif ( instanceType == "pvp" ) then
		if ( C_PvP.IsRatedBattleground() ) then
			numPlayers, profileType, enemyType = 10, instanceType, "PvP";
		else
			numPlayers, profileType, enemyType = countMap[maxPlayers], instanceType, "PvP";
		end
	else
		if ( IsInRaid() ) then
			numPlayers, profileType, enemyType = countMap[GetNumGroupMembers()], "world", "PvE";
		else
			numPlayers, profileType, enemyType = 5, "world", "PvE";
		end
	end

	if ( not numPlayers ) then
		return false;
	end

	return true, numPlayers, profileType, enemyType;
end

function RF:GetActiveRaidProfile()
	local lastProfile = E.db.raidFramesSettings.lastProfile or 1
	return E.db.raidFramesSettings.ProfileList[lastProfile]
end


local checkAutoActivationTimer;

function RF:ReCheckAuraActivation()
	if true then return end

	RF.lastActivationType, RF.lastNumPlayers, RF.lastSpec, RF.lastEnemyType = nil, nil, nil, nil

	lastLastLastProfile = nil

	RF:CheckAutoActivation()
end

function RF:CheckAutoActivation()
	if not E.db.raidFramesSettings.enableModule then
	--	print('RF:CheckAutoActivation - Skip update cuz of E.db.raidFramesSettings.enableModule', E.db.raidFramesSettings.enableModule)
		return
	end

	if ( not IsInGroup() ) then
		RF:SetLastActivationType(nil, nil, nil, nil);
		return;
	end

	local success, numPlayers, activationType, enemyType = RF:GetAutoActivationState();

	if ( not success ) then
		if ( checkAutoActivationTimer ) then
			checkAutoActivationTimer:Cancel();
		end
		checkAutoActivationTimer = C_Timer.NewTimer(3, RF.CheckAutoActivation);
		return;
	else
		if ( checkAutoActivationTimer ) then
			checkAutoActivationTimer:Cancel();
			checkAutoActivationTimer = nil;
		end
	end

	local spec = GetSpecialization and GetSpecialization();
	local lastActivationType, lastNumPlayers, lastSpec, lastEnemyType = RF:GetLastActivationType();

	if ( activationType == "world" ) then
	--	return;
	end

	if ( lastActivationType == activationType and lastNumPlayers == numPlayers and lastSpec == spec and lastEnemyType == enemyType ) then
		return;
	end

	if ( RF:ProfileMatchesAutoActivation(RF:GetActiveRaidProfile(), numPlayers, spec, enemyType) ) then
		RF:SetLastActivationType(activationType, numPlayers, spec, enemyType);
	else
		local update = false

		for i=1, #E.db.raidFramesSettings.ProfileList do
			local profile = E.db.raidFramesSettings.ProfileList[i];
			if ( RF:ProfileMatchesAutoActivation(profile, numPlayers, spec, enemyType) ) then
				RF:ActivateRaidProfile(i);
				RF:SetLastActivationType(activationType, numPlayers, spec, enemyType);
			end
		end
		RF:UpdateProfileSettings()
	end
end

function RF:ActivateRaidProfile(profile)
	E.db.raidFramesSettings.lastProfile = profile
end

function RF:SetLastActivationType(activationType, numPlayers, spec, enemyType)
	RF.lastActivationType = activationType;
	RF.lastNumPlayers = numPlayers;
	RF.lastSpec = spec;
	RF.lastEnemyType = enemyType;
end

function RF:GetLastActivationType()
	return RF.lastActivationType, RF.lastNumPlayers, RF.lastSpec, RF.lastEnemyType;
end

function RF:ProfileMatchesAutoActivation(profile, numPlayers, spec, enemyType)

	local profileData = E.db.raidFramesSettings.Profiles[profile]
	local profileCharData = E.chardb.raidFramesSettings.Profiles[profile]

	local matched = 0

	if profileData.raidSize_max >= numPlayers and profileData.raidSize  <= numPlayers then
		matched = matched + 1
	end

	for i=1, #profileCharData.perCharSpec do
		if profileCharData.perCharSpec[i] and GetSpecialization() == i then
			matched = matched + 1
		end
	end

	if profileData.enablePVP and enemyType == 'PvP' then
		matched = matched + 1
	elseif profileData.enablePVE and enemyType == 'PvE' then
		matched = matched + 1
	end

	return ( matched == 3 )
end

function RF:PLAYER_REGEN_DISABLED(event) E.GUI.args.RaidFrames.args.profileList.disabled = true end
function RF.PLAYER_REGEN_ENABLED(event) E.GUI.args.RaidFrames.args.profileList.disabled = false	end

RF.PLAYER_SPECIALIZATION_CHANGED 	= RF.CheckAutoActivation
RF.PLAYER_TALENT_UPDATE 			= RF.CheckAutoActivation
RF.PLAYER_LEVEL_UP 					= RF.CheckAutoActivation
RF.PLAYER_ENTERING_WORLD 			= RF.CheckAutoActivation
RF.RAID_INSTANCE_WELCOME 			= RF.CheckAutoActivation
RF.GROUP_ROSTER_UPDATE 				= RF.CheckAutoActivation
RF.PLAYER_ENTERING_BATTLEGROUND 	= RF.CheckAutoActivation
RF.ACTIVE_TALENT_GROUP_CHANGED 		= RF.CheckAutoActivation
RF.GROUP_JOINED 					= RF.CheckAutoActivation
RF.GROUP_LEFT						= RF.CheckAutoActivation
RF.ZONE_CHANGED 					= RF.CheckAutoActivation
RF.ZONE_CHANGED_NEW_AREA 			= RF.CheckAutoActivation
RF.ZONE_CHANGED_INDOORS 			= RF.CheckAutoActivation
