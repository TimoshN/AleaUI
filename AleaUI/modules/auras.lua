local E = AleaUI
local L = E.L
local UF = E:Module("UnitFrames")

local blacklist = {}
local whitelist = {}
local CCfilter = {}

local DebuffTypeColor = DebuffTypeColor
local GetSpellInfo = GetSpellInfo
local myName, myServer, myProfile

local defaults = {

	colorByType = true,
	show_spiral = true,
	mouseEvents = false,
	
	colors = {
		none 	= { r = DebuffTypeColor['none'].r, g = DebuffTypeColor['none'].g, b = DebuffTypeColor['none'].b },
		Disease = { r = DebuffTypeColor['Disease'].r, g = DebuffTypeColor['Disease'].g, b = DebuffTypeColor['Disease'].b },
		Poison 	= { r = DebuffTypeColor['Poison'].r, g = DebuffTypeColor['Poison'].g, b = DebuffTypeColor['Poison'].b },
		Curse 	= { r = DebuffTypeColor['Curse'].r, g = DebuffTypeColor['Curse'].g, b = DebuffTypeColor['Curse'].b },
		Magic 	= { r = DebuffTypeColor['Magic'].r, g = DebuffTypeColor['Magic'].g, b = DebuffTypeColor['Magic'].b },
		purge 	= { r = 252/255, g = 251/255, b = 210/255 },
	},
	buff = {
		gap = 0,
		["border"] = {
			["background_texture"] = E.media.default_bar_texture_name3,
			["size"] = 1,
			["inset"] = 0,
			["color"] = {
				0,  
				0,  
				0,  
				0,  
			},
			["background_inset"] = 0,
			["background_color"] = {
				0,  
				0,  
				0,  
				1,  
			},
			["texture"] = E.media.default_bar_texture_name3,
		},
	},
	debuff = {
		gap = 0,
		["border"] = {
			["background_texture"] = E.media.default_bar_texture_name3,
			["size"] = 1,
			["inset"] = 0,
			["color"] = {
				0,  
				0,  
				0,  
				0,  
			},
			["background_inset"] = 0,
			["background_color"] = {
				0,  
				0,  
				0,  
				0,  
			},
			["texture"] = E.media.default_bar_texture_name3,
		},	
	},
	
	filters = {},
}

E.default_settings.auradefault = defaults
E.default_chat_settings.auradefault = {
	['AuraWhitelist'] = {},
	['AuraBlacklist'] = {},
}

local filterType = { ["HARMFUL"] = true, ["HELPFUL"] = true }
--[[
	
	160452

]]
local defaultSpells1 = {--Important spells, add them with huge icons.
	
	6358, --Seduction

	33786, --Cyclone
	5782, --Fear
	5484, --Howl of Terror
	45438, --Ice Block
	642, --Divine Shield
	8122, --Psychic Scream

	23335, -- Silverwing Flag (alliance WSG flag)
	23333, -- Warsong Flag (horde WSG flag)
	34976, -- Netherstorm Flag (EotS flag)
	2094, --Blind
	33206, --Pain Suppression (priest) 
	47585, --Dispersion (priest)

	87204, -- Shadow Priest 4pPVP
	
	110913, --Warlock temnaia sdelka
	108416, --Warlock Gertvenniy dogovor
	104773, --Warlock Tverdia reshimost
		
	871, --Warrior Shield Wall
	
	19263, --Hunter Deterance
	
	61336, --Druid
	
	31230, --Rogue
	
	6940, --Paladin
	31821, --Paladin
	
	48707, --DK
	
	108271, --Shaman
	30823, --Shaman
	
	53480, --Hunter
	
	108945, --Priest
	6346, --Priest
	15286, --Priest
	
	122783, --Monk
	122278, --Monk
	
	108292, -- HOTW
	
	118038, -- warrior 
	45243, -- priest
	116849, -- monk poolp
	15487, --Silence (priest)
	10060, --Power Infusion (priest) 
	2825, --Bloodlust
	5246, --Intimidating Shout (warrior) 
	31224, --Cloak of Shadows (rogue) 
	498, --Divine Protection
	47476, --Strangulate (warlock) 
	31884, --Avenging Wrath (pally) 
	37587, --Bestial Wrath (hunter) 
	12472, --Icy Veins (mage)
	49039, --Lichborne (DK)
	48792, --Icebound Fortitude (DK)
	5277, --Evasion (rogue)
	53563, --Beacon of Light (pally)
	22812, --Barkskin (druid)
	67867, --Trampled (ToC arena spell when you run over someone)
    1022, --Hand of Protection (pally)
	10326, --Turn Evil (pally)

	46968, --Shockwave (warrior)
	46924, --Bladestorm (warrior)
	2983, --Sprint (rogue)
	2335, --Swiftness Potion
	6624, --Free Action Potion
	3448, --Lesser Invisibility Potion
	11464, --Invisibility Potion
	17634, --Potion of Petrification
	53905, --Indestructible Potion
	54221, --Potion of Speed
	1850, --Dash
	87204, --
	
	113860, --Warlock Черная душа: Страдание
	113861, --Warlock Черная душа: Знание	
	113858, --Warlock Черная душа: Изменчивость	
	23920, --Warrior Reflect
	1719, --Warrior Recklessness
	18499, --Warrior Berserk
	71, --Warrior  Defence Stance
	107574, --Warrior Avatar
	12292, --Warrior Bleed
	114028, --Warriot Mass Reflect	
	124974, --Druid
	102342, --Druid
	112071, --Druid Parad?	
	1966, -- Rogue faint	
	48263, --DK blood presens	
	77535, --DK Shield blood	
	16166, --Shaman	
	3045, --Hunter
	19574, --Hunter
	-- Druid
	99, -- Incapacitating Roar (talent)
	-- Hunter
	3355,	-- Freezing Trap
	1499,	-- Freezing Trap
	60192,  -- Freezing Trap
	19386,  -- Wyvern Sting
	-- Mage
	118, -- Polymorph
	28272, -- Polymorph (pig)
	28271, -- Polymorph (turtle)
	61305, -- Polymorph (black cat)
	61025, -- Polymorph (serpent) -- FIXME: gone ?
	61721, -- Polymorph (rabbit)
	61780, -- Polymorph (turkey)
	82691, -- Ring of Frost
	31661, -- Dragon's Breath
	-- Monk
	115078, -- Paralysis
--	123393, -- Breath of Fire (Glyphed)
	137460, -- Ring of Peace -- FIXME: correct spellIDs?
	-- Paladin
	20066, -- Repentance
	-- Priest
	605, -- Dominate Mind
	9484, -- Shackle Undead
	64044, -- Psychic Horror (Horror effect)
	88625, -- Holy Word: Chastise
	-- Rogue
	1776, -- Gouge
	6770, -- Sap
	-- Shaman
	51514, -- Hex
	-- Warlock
	710, -- Banish
	111397,
	137143, -- Blood Horror
	6789, -- Mortal Coil
	-- Pandaren
	107079, -- Quaking Palm
	-- Death Knight
	47476, -- Strangulate
	-- Druid
	114237, -- Glyph of Fae Silence
	-- Mage
	102051, -- Frostjaw
	-- Paladin
	31935, -- Avenger's Shield
	-- Priest
	15487, -- Silence
	-- Rogue
	1330, -- Garrote
	-- Blood Elf
	25046, -- Arcane Torrent (Energy version)
	28730, -- Arcane Torrent (Mana version)
	50613, -- Arcane Torrent (Runic power version)
	69179, -- Arcane Torrent (Rage version)
	80483, -- Arcane Torrent (Focus version)

	--[[ DISORIENTS ]]--
	-- Druid
	33786, -- Cyclone
	-- Paladin
	105421, -- Blinding Light -- FIXME: is this the right category? Its missing from blizzard's list
	10326, -- Turn Evil
	-- Priest
	8122, -- Psychic Scream
	-- Rogue
	2094, -- Blind
	-- Warlock
	5782, -- Fear -- probably unused
	118699, -- Fear -- new debuff ID since MoP
	130616, -- Fear (with Glyph of Fear)
	5484, -- Howl of Terror (talent)
	115268, -- Mesmerize (Shivarra)
	6358, -- Seduction (Succubus)
	-- Warrior
	5246, -- Intimidating Shout (main target)
	-- Death Knight
	108194, -- Asphyxiate
	91800, -- Gnaw (Ghoul)
	91797, -- Monstrous Blow (Dark Transformation Ghoul)
	115001, -- Remorseless Winter
	-- Druid
	22570, -- Maim
	5211, -- Mighty Bash
	1822, -- Rake (Stun from Prowl)
	163505, -- Rake (Stun from Prowl)
	-- Hunter
	109248, -- Binding Shot
	117526, -- Binding Shot
	19577, -- Intimidation
	24394, -- Intimidation
	-- Mage
	44572, -- Deep Freeze
	-- Monk
	119392, -- Charging Ox Wave
	113656, -- Fists of Fury
	120086, -- Fists of Fury
	119381, -- Leg Sweep
	-- Paladin
	853, -- Hammer of Justice
	119072, -- Holy Wrath
	105593, -- Fist of Justice
	-- Rogue
	1833, -- Cheap Shot
	408, -- Kidney Shot
	-- Shaman
	118345, -- Pulverize (Primal Earth Elemental)
	118905, -- Static Charge (Capacitor Totem)
	-- Warlock
	89766, -- Axe Toss (Felguard)
	30283, -- Shadowfury
	1122, --  Summon Infernal
	22703, -- Summon Infernal
	-- Warrior
	132168, -- Shockwave
	132169, -- Storm Bolt
	-- Tauren
	20549, -- War Stomp
	-- Death Knight
	96294, -- Chains of Ice (Chilblains Root)
	-- Druid
	339, -- Entangling Roots
	102359, -- Mass Entanglement (talent)
	113770, -- Entangling Roots (Treants)
	-- Hunter
	61685, 
	53148, -- Charge (Tenacity pet)
	135373, -- Entrapment (passive)
	136634, -- Narrow Escape (passive talent)
	-- Mage
	122, -- Frost Nova
	33395, -- Freeze (Water Elemental)
	111340, -- Ice Ward
	-- Monk
	116095, --
	116706, -- Disable

	-- Priest
	87194, -- Glyph of Mind Blast
	114404, -- Void Tendrils
	-- Shaman
	63685, -- Freeze (Frozen Power talent)
	64695, -- Earthgrab Totem
}

for i, spellID in pairs(defaultSpells1) do
	CCfilter[spellID] = true
end

local GrabAura

do
	local name, _, icon, count, dispelType, duration, expires, caster, isStealable, spellID, canApplyAura, isBossDebuff, isCastByPlayer, val1, val2, val3
	local nameplateShowPersonal, nameplateShowAll, timeMod
	--
	-- local canAssist = UnitCanAssist("player", self.unit);
	--
	
	function GrabAura(self, unit, filter, maxnum)
		local i, real_i = 0, 0
		local isEneny = UnitCanAttack(unit, "player")
		local filterFull = ( filter == 'HARMFUL' ) and filter..'|INCLUDE_NAME_PLATE_ONLY' or filter
		
		while ( true ) do
			local filt = false
			i=i+1

			name, icon, count, dispelType, duration, expires, caster, isStealable, nameplateShowPersonal, spellID, canApplyAura, isBossDebuff, isCastByPlayer, nameplateShowAll, timeMod, val1, val2, val3 = UnitAura(unit, i, filterFull)
			
			if ( not name ) then break end
			
			local isMine = ( caster == "player" or caster == 'pet' or caster == 'vehicle' )
			
			-- 3 filter all
			-- 2 only player
			-- 1 only not player
	
			if blacklist[spellID] then
				if blacklist[spellID] == 1 and not isMine then
					filt = false
				elseif blacklist[spellID] == 2 and isMine then
					filt = false
				elseif blacklist[spellID] == 3 then
					filt = false
				end
			elseif whitelist[spellID] then
				if whitelist[spellID] == 1 and not isMine then
					filt = true
				elseif whitelist[spellID] == 2 and isMine then
					filt = true
				elseif whitelist[spellID] == 3 then
					filt = true
				end
			else

				if filter == "HELPFUL" then filt = true end
				if caster then
					filt = UnitIsUnit(unit, caster)					
					if not filt then 
						filt = isMine
					end 
				end
				
				if ( true ) then 
					filt = UF:ShouldShow(caster, isCastByPlayer, spellID) 
				end	
				
				if filter == "HARMFUL" and isMine then filt = true end		
				if caster and UnitIsUnit(unit, caster) then filt = true end
				if filter == "HELPFUL" and not filt and not UnitIsPlayer(unit) then filt = true end			
				if filter == "HARMFUL" and CCfilter[spellID] then filt = true end
				if isStealable then filt = true end

			end
			--[[
			if self.CustomFilter and self.CustomFilters[filter] then
				if self.CustomFilters[filter].forceshow then
					filt = self.CustomFilters[filter].values[spellID]
				elseif self.CustomFilters[filter].values[spellID] then
					filt = self.CustomFilters[filter].values[spellID]
				end
			end
			]]
			
			if filt then
				real_i=real_i+1
				self:ShowAura(i, real_i, filter, unit, isMine, isEneny, name, icon, count, dispelType, duration, expires, caster, spellID, isStealable, shouldConsolidate, canApplyAura, isBossDebuff, val1, val2, val3)
				
				if ( real_i >= maxnum ) then break end
			end	
		end
		
		for i=real_i+1, maxnum do
			self[filter][i]:Hide()
		end
	end
	
end

local function UnitAuraFunc(self, event, unit)
	--[[
	if unit and self.parentFrame and self.parentFrame.displayedUnit then
		if not UnitIsUnit(self.parentFrame.displayedUnit, unit) then return end
		
	]]
	
	if unit and self.unit and unit ~= ( self.parentFrame.displayedUnit or self.parentFrame.unit ) then
		return
	end
	
	if self.buff_amount > 0 then
		GrabAura(self, unit, "HELPFUL", self.buff_amount)
	end
	if self.debuff_amount > 0 then
		GrabAura(self, unit, "HARMFUL", self.debuff_amount)
	end
end

local normal_color = { r = 0, g = 0, b = 0 }
local spellsteal_purge = { r = 252/255, g = 251/255, b = 210/255 } --252, 251, 210


local function ShowAura(self, real_i, i, filter, unit, isMine, isEneny, name, icon, count, dispelType, duration, expires, caster, spellID, isStealable, shouldConsolidate, canApplyAura, isBossDebuff, ...)
	if not self[filter][i] then return end
	
	local f = self[filter][i]
	
	f.isMine = isMine
	f.unit = unit
	f.filter = filter
	f.index = real_i
	f.spellID = spellID
	f.icon:SetTexture(icon)
	f:Show()
	
	if duration > 0 and expires > 0 then
	--	if f.cooldown._lastduration ~= duration or
	--		f.cooldown._lastexpires ~= expires then
			
	--		f.cooldown._lastduration = duration
	--		f.cooldown._lastexpires = expires		
			CooldownFrame_Set(f.cooldown, expires-duration, duration, true);
	--	end
	else
	--	self[filter][i].cooldown:Clear()
		CooldownFrame_Clear(f.cooldown);
	end
	
	if count and count > 1 then
		f.stack:SetText(count)
	else
		f.stack:SetText("")
	end
	
	local color = normal_color
	
	if isEneny and filter == "HARMFUL" and not isMine then
		f.icon:SetDesaturated(true)	
	elseif isMine and filter == "HARMFUL" then
		f.icon:SetDesaturated(false)
	else
		f.icon:SetDesaturated(false)
	end
	
	if filter == "HELPFUL" and ( isMine or not isEneny) then
		color = normal_color
	elseif ( isStealable ) then
		color = E.db.auradefault.colors['purge']
	elseif not E.db.auradefault.colorByType  then
		color = normal_color
	elseif ( dispelType ) then
		color = E.db.auradefault.colors[dispelType] or E.db.auradefault.colors["none"];
	else
		color = E.db.auradefault.colors["none"];
	end
	
	if color == normal_color then
		f.auraType:SetBackdropBorderColor(color.r, color.g, color.b, 0)
	else
		f.auraType:SetBackdropBorderColor(color.r, color.g, color.b, 1)
	end
end

local icon_total_amount = 0
local icon_total_amountn = 0
local iconlist = {}
local function UpdateStyle(frame)

	local opts = E.db.auradefault.buff
	
	frame.background:SetTexture(E:GetTexture(opts.border.background_texture))
	frame.background:SetVertexColor(opts.border.background_color[1],opts.border.background_color[2],opts.border.background_color[3],opts.border.background_color[4])
	frame.background:SetPoint('TOPLEFT', frame, 'TOPLEFT', opts.border.background_inset, -opts.border.background_inset)
	frame.background:SetPoint('BOTTOMRIGHT', frame, 'BOTTOMRIGHT', -opts.border.background_inset, opts.border.background_inset)
	
	frame.border:SetBackdrop({
	  edgeFile = E:GetBorder(opts.border.texture),
	  edgeSize = opts.border.size, 
	})
	frame.border:SetPoint('TOPLEFT', frame, 'TOPLEFT', opts.border.inset, -opts.border.inset)
	frame.border:SetPoint('BOTTOMRIGHT', frame, 'BOTTOMRIGHT', -opts.border.inset, opts.border.inset)
	frame.border:SetBackdropBorderColor(opts.border.color[1],opts.border.color[2],opts.border.color[3],opts.border.color[4])
	
	if E.db.auradefault.show_spiral then
		frame.cooldown:SetSwipeColor(0, 0, 0, 0.6)
	else
		frame.cooldown:SetSwipeColor(0, 0, 0, 0)
	end
end

local function InterateAuraFrames(func)	
	for i=1, #iconlist do
		iconlist[i][func](iconlist[i])
	end
end

local function CreateAuraFrame(frame)
	
	icon_total_amount= icon_total_amount + 1
	icon_total_amountn = icon_total_amountn + 1
	
	local f = CreateFrame("Button", (frame:GetName() or "AleaUIAuraFrame"..icon_total_amount).."IconFrame"..icon_total_amountn, frame)
	f.aleaUI = true
	f.parent = frame
	f:SetFrameLevel(frame:GetFrameLevel()+2)
	f:SetSize(1, 1)
	f:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
		GameTooltip:SetUnitAura(self.unit, self.index, self.filter)
		GameTooltip:Show()
	end)
	f:SetScript("OnLeave", function(self)
		GameTooltip:Hide()
	end)
	
	local background = f:CreateTexture(nil, "BACKGROUND")
	background:SetAllPoints()
	background:SetColorTexture(0, 0, 0, 1)
	
	f.background = background
	
	local border = CreateFrame("Frame", nil, f, BackdropTemplateMixin and 'BackdropTemplate')
	border:SetFrameLevel(f:GetFrameLevel())
	border:SetInside()
	border:SetBackdrop({
		edgeFile = [[Interface\Buttons\WHITE8x8]], 
		edgeSize = 1, 
	})
	border:SetBackdropBorderColor(0, 0, 0, 1)
	f.border = border
	
	local auraType = CreateFrame("Frame", nil, f, BackdropTemplateMixin and 'BackdropTemplate')
	auraType:SetFrameLevel(f:GetFrameLevel()+1)
	auraType:SetInside()
	auraType:SetBackdrop({
		edgeFile = [[Interface\Buttons\WHITE8x8]], 
		edgeSize = 1, 
	})
	auraType:SetBackdropBorderColor(0, 0, 0, 1)
	f.auraType = auraType
	
	local icon = f:CreateTexture(nil, "OVERLAY", nil, -5)
	icon:SetTexCoord(.1, .9, .1, .9)
	icon:SetInside()
	icon:SetTexture("Interface\\Icons\\spell_shadow_shadowwordpain")
	
	f.icon = icon
	
	local cooldown = CreateFrame("Cooldown", (f:GetName()).."CooldownFrame"..icon_total_amountn,f, "CooldownFrameTemplate")
	cooldown:SetAllPoints(icon)	
	cooldown:SetReverse(true)
	cooldown:SetDrawEdge(false)
	cooldown:SetSwipeColor(0, 0, 0, 0.6)	
	cooldown:SetBlingTexture("")	
	cooldown.noMinDurationCheck = true
	
	f.cooldown = cooldown
	
	E:RegisterCooldown(cooldown)
	
	local stackparent = CreateFrame("Frame", nil, f)
	stackparent:SetAllPoints(f)	
	stackparent:SetFrameLevel(f:GetFrameLevel()+2)

	local stack = f:CreateFontString();
	stack:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 0, 0)
	stack:SetSize(12*2, 12)
	stack:SetTextColor(1,1,1,1)
	stack:SetFont(AleaUI.media.default_font, 10, "OUTLINE")
	stack:SetJustifyH("RIGHT")
	stack:SetJustifyV("BOTTOM")
	stack:SetAlpha(1)
	stack:SetWordWrap(false)
	stack:SetDrawLayer("OVERLAY", -4)
	stack:SetParent(stackparent)
	
	f.stack = stack
	
	f.UpdateStyle = UpdateStyle
	
	f:UpdateStyle()
	f:Hide()
	
	
	f:RegisterForClicks("RightButtonUp")
	f:SetScript("OnClick", function(self, event, button)
		if not E.db.unitframes.mouseEvents then return end
		
		UF:BlacklistAura(f)
	end)
	
	iconlist[#iconlist+1] = f
	
	return f
end

function UF:BlacklistAura(f)
	-- 3 filter all
	-- 2 only player
	-- 1 only not player
	
	local arg = f.isMine and 2 or 1
	
	if IsShiftKeyDown() then
		if not whitelist[f.spellID] then
			whitelist[f.spellID] = 0	
		end
		
		whitelist[f.spellID] = whitelist[f.spellID] + arg
	else
		if not blacklist[f.spellID] then
			blacklist[f.spellID] = 0	
		end
		
		blacklist[f.spellID] = blacklist[f.spellID] + arg

		UnitAuraFunc(f.parent.AuraWidget, _, f.unit)	
	end
end

function ALEUI_RemoveBlacklist(spellid)
	blacklist[spellid] = nil
end

function ALEUI_RemoveWhitelist(spellid)
	whitelist[spellid] = nil
end

function UF:ShouldShow(unitCaster, isCastByPlayer, spellId)
	local hasCustom, alwaysShowMine, showForMySpec = SpellGetVisibilityInfo(spellId, "ENEMY_TARGET");
	if ( hasCustom ) then
		return showForMySpec or (alwaysShowMine and (unitCaster == "player" or unitCaster == "pet" or unitCaster == "vehicle") );
	else
		return not isCastByPlayer or unitCaster == "player" or unitCaster == "pet" or unitCaster == "vehicle";
	end
end

local direction_settings = {
	['left'] = { 'RIGHT', 'LEFT', 0, 0 },
	['right'] = { 'LEFT', 'RIGHT', 0, 0 },
}

local point_settings = {
	['top'] = { 'BOTTOM', 'TOP', 0, 0 },
	['bottom'] = { 'TOP', 'BOTTOM', 0, 0 },
	['left'] = { 'RIGHT', 'LEFT', 0, 0 },
	['right'] = { 'LEFT', 'RIGHT', 0, 0 },
}

local newRow_settings = {
	['top'] = { 'BOTTOM', 'TOP', 0, 0 },
	['bottom'] = { 'TOP', 'BOTTOM', 0, 0 },
}

local total_num = 0

local function SetFilter(self, values, filter, onlycustom)
	self.CustomFilter = true
	if not self.CustomFilters[filter] then 		
		self.CustomFilters[filter] = {}
		self.CustomFilters[filter].values = {}
		self.CustomFilters[filter].forceshow = false
	end
	self.CustomFilters[filter].values = values
	self.CustomFilters[filter].forceshow = onlycustom
	
	return self
end

local function Disable(self)

	self.enabled = false
	self:UnregisterAllEvents()
	for i=1, #self.HELPFUL do
		self.HELPFUL[i]:Hide()
	end
	for i=1, #self.HARMFUL do
		self.HARMFUL[i]:Hide()
	end
end

local function Enable(self)
	self.enabled = true
	self:RegisterEvent("UNIT_AURA")
end

local function UpdateSettings(self, opts)
	-- buff
	local number, direction, point, newrowdirection
	
	number = opts.buff.enable and opts.buff.row*opts.buff.perrow or 0
	direction = direction_settings[(opts.buff.direction or 'left')]
	point = point_settings[(opts.buff.point or 'top')]
	newrowdirection = newRow_settings[(opts.buff.newrowdirection or 'bottom')]
	
	for i=1, number do
		local f =  self.HELPFUL[i] or CreateAuraFrame(self.parentFrame)		
		f:SetSize(opts.buff.size, opts.buff.size)
		f:ClearAllPoints()

		--print(i, opts.buff.perrow)
		
		if i == 1 then
			f:SetPoint(point[1], self.parentFrame, point[2], point[3] + opts.buff.pos[1], point[4] + opts.buff.pos[2])
		elseif i == opts.buff.perrow+1 or 
				i == opts.buff.perrow*2 + 1 or 
				i == opts.buff.perrow*3 + 1 or 
				i == opts.buff.perrow*4 + 1 or 
				i == opts.buff.perrow*5 + 1 or 
				i == opts.buff.perrow*6 + 1 or 
				i == opts.buff.perrow*7 + 1 or 
				i == opts.buff.perrow*8 + 1 or 
				i == opts.buff.perrow*9 + 1 then
	--	elseif i%opts.buff.perrow + 1 then
			f:SetPoint(newrowdirection[1], self.HELPFUL[i-opts.buff.perrow], newrowdirection[2], newrowdirection[3], newrowdirection[4])
		else
			f:SetPoint(direction[1], self.HELPFUL[i-1], direction[2], direction[3], direction[4])
		end
		
		self.HELPFUL[i] = f
	end	
	for i=number+1, #self.HELPFUL do
		self.HELPFUL[i]:Hide()
	end
	
	self.buff_amount = number
	
	-- debuff
	
	number = opts.debuff.enable and opts.debuff.row*opts.debuff.perrow or 0
	direction = direction_settings[(opts.debuff.direction or 'left')]
	point = point_settings[(opts.debuff.point or 'top')]
	newrowdirection = newRow_settings[(opts.debuff.newrowdirection or 'bottom')]
	
	for i=1, number do
		local f =  self.HARMFUL[i] or CreateAuraFrame(self.parentFrame)	
		f:SetSize(opts.debuff.size, opts.debuff.size)
		f:ClearAllPoints()
		if i == 1 then
			f:SetPoint(point[1], self.parentFrame, point[2], point[3] + opts.debuff.pos[1], point[4] + opts.debuff.pos[2])
		elseif i == opts.debuff.perrow+1 or 
			i == opts.debuff.perrow*2 + 1 or 
			i == opts.debuff.perrow*3 + 1 or 
			i == opts.debuff.perrow*4 + 1 or
			i == opts.debuff.perrow*5 + 1 or
			i == opts.debuff.perrow*6 + 1 or
			i == opts.debuff.perrow*7 + 1 or
			i == opts.debuff.perrow*8 + 1 or 
			i == opts.debuff.perrow*9 + 1 then
	--	elseif i%opts.debuff.perrow == 1 then
			f:SetPoint(newrowdirection[1], self.HARMFUL[i-opts.debuff.perrow], newrowdirection[2], newrowdirection[3], newrowdirection[4])
		else
			f:SetPoint(direction[1], self.HARMFUL[i-1], direction[2], direction[3], direction[4])
		end
		
		self.HARMFUL[i] = f
	end	
	for i=number+1, #self.HARMFUL do
		self.HARMFUL[i]:Hide()
	end
	
	self.debuff_amount = number
	
	self.parentFrame:ForceUpdateAuras()
end

local function ForceUpdateAuras(self)
	if not self.AuraWidget.enabled then return end
	
	UnitAuraFunc(self.AuraWidget, _, self.unit)
end

local function TestUnitAuras(self)
	
	for i=1, self.buff_amount do
		self:ShowAura(i,i, 'HELPFUL', "player", true, false, "TEST", "Interface\\Icons\\spell_shadow_shadowwordpain", i, _, 20, GetTime()+20, 589)
	end
	
	for i=1, self.debuff_amount do
		self:ShowAura(i,i, 'HARMFUL', "player", true, false, "TEST", "Interface\\Icons\\spell_shadow_shadowwordpain", i, _, 20, GetTime()+20, 589)
	end

end
 
function UF:UnitAuraWidgets(f)
	myName = UnitName("player")
	myServer = GetRealmName()
	
	myProfile = myName.."-"..myServer
	
	if AleaUIDB["AuraWhitelist"] and AleaUIDB["AuraWhitelist"][myProfile] then
		E.chardb.auradefault.AuraWhitelist = AleaUIDB["AuraWhitelist"][myProfile]
		AleaUIDB["AuraWhitelist"][myProfile] = nil
	end
	if AleaUIDB["AuraBlacklist"] and AleaUIDB["AuraBlacklist"][myProfile] then
		E.chardb.auradefault.AuraBlacklist = AleaUIDB["AuraBlacklist"][myProfile]
		AleaUIDB["AuraBlacklist"][myProfile] = nil
	end
	
	whitelist = E.chardb.auradefault.AuraWhitelist
	blacklist = E.chardb.auradefault.AuraBlacklist

	total_num = total_num + 1

	local widget = CreateFrame("Frame", "AleaUIAuraWidget"..total_num, f)
	widget:SetFrameStrata('MEDIUM')
	widget.HELPFUL = {}
	widget.HARMFUL = {}
	widget:RegisterEvent("UNIT_AURA")
	widget:SetScript("OnEvent", UnitAuraFunc)	
	widget.unit = f.displayedUnit or f.unit
	widget.parentFrame = f
	widget.CustomFilter = false
	widget.CustomFilters = {}
	widget.enabled = true
	widget.buff_amount = 0
	widget.debuff_amount = 0
	widget.ShowAura = ShowAura
	widget.SetFilter = SetFilter
	widget.Disable = Disable
	widget.Enable = Enable
	widget.UpdateSettings = UpdateSettings
	widget.TestUnitAuras = TestUnitAuras
	
	f.AuraWidget = widget

	f.ForceUpdateAuras = ForceUpdateAuras
	
	return widget
end

do

	local AnchorDD = {
		['top'] = L['Top'],
		['bottom'] = L['Bottom'],
		['left'] = L['Left'],
		['right'] = L['Right'],
	}
	
	local directionDD = {
		['left'] = L['Left'],
		['right'] = L['Right'],
	}
	
	local NewRowDirectionDD = {
		['bottom'] = L['Bottom'],
		['top'] = L['Top'],
	}
	
	function UF:GetAuraWidgetSettings(unit, func, root)
	
		E.GUI.args.unitframes.args[root].args.auraGo = {
			name = L['Auras - Go'],
			order = 9,
			type = "execute",
			width = 'full',
			set = function()
				AleaUI_GUI:SelectGroup("AleaUI", "unitframes", root, 'auraWidget')
			end,
			get = function()
			
			end,
		}
			
			
			
		local t = {
			name = L["Auras"],
			order = 6,
			type = "group",
			args = {}
		}
		
		t.args.goback = {
			name = L['Back'],
			order = 0.1,
			type = "execute",
			width = 'full',
			set = function()
				AleaUI_GUI:SelectGroup("AleaUI", "unitframes", root)
			end,
			get = function()
			
			end,
		}
					
		t.args.BuffGroup = {
			name = L['Buffs'],
			order = 1,
			embend = true,
			type = "group",
			args = {}
		}
		
		t.args.DebuffGroup = {
			name = L['Debuffs'],
			order = 2,
			embend = true,
			type = "group",
			args = {}
		}
		
		t.args.BuffGroup.args.Enable = {
			name = L['Enable'],
			order = 0.1,
			width = 'full',
			type = "toggle",
			set = function(self, value)				
				E.db.unitframes.unitopts[unit].buff.enable = not E.db.unitframes.unitopts[unit].buff.enable
				UF[func]()
			end,
			get = function(self)
				return E.db.unitframes.unitopts[unit].buff.enable
			end	
		}
		t.args.BuffGroup.args.Size = {	
			name = L['Size'],
			order = 1,
			type = "slider",
			min = 1, max = 32, step = 1,
			set = function(self, value)
				E.db.unitframes.unitopts[unit].buff.size = value
				UF[func]()
			end,
			get = function(self)
				return E.db.unitframes.unitopts[unit].buff.size
			end,
		}
		
		t.args.BuffGroup.args.Rows = {	
			name = L['Rows'],
			order = 2,
			type = "slider",
			min = 1, max = 10, step = 1,
			set = function(self, value)
				E.db.unitframes.unitopts[unit].buff.row = value
				UF[func]()
			end,
			get = function(self)
				return E.db.unitframes.unitopts[unit].buff.row
			end,
		}
		
		t.args.BuffGroup.args.Perrow = {	
			name = L['Icons per row'],
			order = 3,
			type = "slider",
			min = 1, max = 10, step = 1,
			set = function(self, value)
				E.db.unitframes.unitopts[unit].buff.perrow = value
				UF[func]()
			end,
			get = function(self)
				return E.db.unitframes.unitopts[unit].buff.perrow
			end,
		}
		
		t.args.BuffGroup.args.Anchor = {	
			name = L['Fixation point'],
			order = 4,
			type = "dropdown",
			values = AnchorDD,
			set = function(self, value)
				E.db.unitframes.unitopts[unit].buff.point = value
				UF[func]()
			end,
			get = function(self)
				return E.db.unitframes.unitopts[unit].buff.point
			end,
		}
		
		t.args.BuffGroup.args.Direction = {	
			name = L['Direction'],
			order = 5,
			type = "dropdown",
			values = directionDD,
			set = function(self, value)
				E.db.unitframes.unitopts[unit].buff.direction = value
				UF[func]()
			end,
			get = function(self)
				return E.db.unitframes.unitopts[unit].buff.direction
			end,
		}
		
		t.args.BuffGroup.args.NewRowDirection = {	
			name = L['New row fixation'],
			order = 5.1,
			type = "dropdown",
			values = NewRowDirectionDD,
			set = function(self, value)
				E.db.unitframes.unitopts[unit].buff.newrowdirection = value
				UF[func]()
			end,
			get = function(self)
				return E.db.unitframes.unitopts[unit].buff.newrowdirection
			end,
		}
		
		t.args.BuffGroup.args.xOffset = {	
			name = L['Horizontal offset'],
			order = 6,
			type = "slider",
			min = -600, max = 600, step = 1,
			set = function(self, value)
				E.db.unitframes.unitopts[unit].buff.pos[1] = value
				UF[func]()
			end,
			get = function(self)
				return E.db.unitframes.unitopts[unit].buff.pos[1]
			end,
		}
		
		t.args.BuffGroup.args.yOffset = {	
			name = L['Vertical offset'],
			order = 7,
			type = "slider",
			min = -600, max = 600, step = 1,
			set = function(self, value)
				E.db.unitframes.unitopts[unit].buff.pos[2] = value
				UF[func]()
			end,
			get = function(self)
				return E.db.unitframes.unitopts[unit].buff.pos[2]
			end,
		}

		t.args.DebuffGroup.args.Enable = {
			name = L['Enable'],
			order = 0.1,
			width = 'full',
			type = "toggle",
			set = function(self, value)				
				E.db.unitframes.unitopts[unit].debuff.enable = not E.db.unitframes.unitopts[unit].debuff.enable
				UF[func]()
			end,
			get = function(self)
				return E.db.unitframes.unitopts[unit].debuff.enable
			end	
		}
		t.args.DebuffGroup.args.Size = {	
			name = L['Size'],
			order = 1,
			type = "slider",
			min = 1, max = 32, step = 1,
			set = function(self, value)
				E.db.unitframes.unitopts[unit].debuff.size = value
				UF[func]()
			end,
			get = function(self)
				return E.db.unitframes.unitopts[unit].debuff.size
			end,
		}
		
		t.args.DebuffGroup.args.Rows = {	
			name = L['Rows'],
			order = 2,
			type = "slider",
			min = 1, max = 10, step = 1,
			set = function(self, value)
				E.db.unitframes.unitopts[unit].debuff.row = value
				UF[func]()
			end,
			get = function(self)
				return E.db.unitframes.unitopts[unit].debuff.row
			end,
		}
		
		t.args.DebuffGroup.args.Perrow = {	
			name = L['Icons per row'],
			order = 3,
			type = "slider",
			min = 1, max = 10, step = 1,
			set = function(self, value)
				E.db.unitframes.unitopts[unit].debuff.perrow = value
				UF[func]()
			end,
			get = function(self)
				return E.db.unitframes.unitopts[unit].debuff.perrow
			end,
		}
		
		t.args.DebuffGroup.args.Anchor = {	
			name = L['Fixation point'],
			order = 4,
			type = "dropdown",
			values = AnchorDD,
			set = function(self, value)
				E.db.unitframes.unitopts[unit].debuff.point = value
				UF[func]()
			end,
			get = function(self)
				return E.db.unitframes.unitopts[unit].debuff.point
			end,
		}
		
		t.args.DebuffGroup.args.Direction = {	
			name = L['Direction'],
			order = 5,
			type = "dropdown",
			values = directionDD,
			set = function(self, value)
				E.db.unitframes.unitopts[unit].debuff.direction = value
				UF[func]()
			end,
			get = function(self)
				return E.db.unitframes.unitopts[unit].debuff.direction
			end,
		}
		
		t.args.DebuffGroup.args.NewRowDirection = {	
			name = L['New row fixation'],
			order = 5.1,
			type = "dropdown",
			values = NewRowDirectionDD,
			set = function(self, value)
				E.db.unitframes.unitopts[unit].debuff.newrowdirection = value
				UF[func]()
			end,
			get = function(self)
				return E.db.unitframes.unitopts[unit].debuff.newrowdirection
			end,
		}
		
		t.args.DebuffGroup.args.xOffset = {	
			name = L['Horizontal offset'],
			order = 6,
			type = "slider",
			min = -600, max = 600, step = 1,
			set = function(self, value)
				E.db.unitframes.unitopts[unit].debuff.pos[1] = value
				UF[func]()
			end,
			get = function(self)
				return E.db.unitframes.unitopts[unit].debuff.pos[1]
			end,
		}
		
		t.args.DebuffGroup.args.yOffset = {	
			name = L['Vertical offset'],
			order = 7,
			type = "slider",
			min = -600, max = 600, step = 1,
			set = function(self, value)
				E.db.unitframes.unitopts[unit].debuff.pos[2] = value
				UF[func]()
			end,
			get = function(self)
				return E.db.unitframes.unitopts[unit].debuff.pos[2]
			end,
		}
		
		return t
		
	end
	
end

E.GUI.args.unitframes.args.Auras = {
	name = L['Auras'],
	order = -1,
	type = "group", expand = true,
	args = {}
}

E.GUI.args.unitframes.args.Auras.args.enable = {
	name = L['Enable mouse events'],
	order = 0.1,
	width = 'full',
	type = "toggle",
	set = function(self, value)				
		E.db.unitframes.mouseEvents = not E.db.unitframes.mouseEvents
	end,
	get = function(self)
		return E.db.unitframes.mouseEvents
	end	
}
		
E.GUI.args.unitframes.args.Auras.args.colors = {
	name = L['Colors'],
	order = 1,
	type = "group", embend = true,
	args = {}
}

E.GUI.args.unitframes.args.Auras.args.colors.args.EnableColor = {
	name = L['Color by type'],
	order = 0.1,
	type = 'toggle', width = 'full',
	set = function(info)
		E.db.auradefault.colorByType = not E.db.auradefault.colorByType	
	end,
	get = function(info)
		return E.db.auradefault.colorByType
	end,
}	
E.GUI.args.unitframes.args.Auras.args.colors.args.EnableCooldownSpiral = {
	name = L['Enable cooldown spiral'],
	order = 0.2,
	type = 'toggle', width = 'full',
	set = function(info)
		E.db.auradefault.show_spiral = not E.db.auradefault.show_spiral	
		InterateAuraFrames('UpdateStyle')
	end,
	get = function(info)
		return E.db.auradefault.show_spiral
	end,
}

for k,v in pairs(defaults.colors) do
	E.GUI.args.unitframes.args.Auras.args.colors.args[k] = {
		name = L['colorType'..k] or k,
		order = 1,
		type = 'color', hasAlpha = false,
		set = function(info, r,g,b,a)
			E.db.auradefault.colors[k] = { r = r, g = g, b = b}		
		end,
		get = function(info)
			return 	E.db.auradefault.colors[k].r,
					E.db.auradefault.colors[k].g,
					E.db.auradefault.colors[k].b,
					1
		end,
	}	
end


E.GUI.args.unitframes.args.Auras.args.BorderOpts = {
	name = L['Borders'],
	order = 10,
	embend = true,
	type = "group",
	args = {}
}

E.GUI.args.unitframes.args.Auras.args.BorderOpts.args.BorderTexture = {
	order = 1,
	type = 'border',
	name = L['Border texture'],
	values = E:GetBorderList(),
	set = function(info,value) 
		E.db.auradefault.buff.border.texture = value;
		InterateAuraFrames('UpdateStyle')
	end,
	get = function(info) return E.db.auradefault.buff.border.texture end,
}

E.GUI.args.unitframes.args.Auras.args.BorderOpts.args.BorderColor = {
	order = 2,
	name = L['Border color'],
	type = "color", 
	hasAlpha = true,
	set = function(info,r,g,b,a) 
		E.db.auradefault.buff.border.color={ r, g, b, a}; 
		InterateAuraFrames('UpdateStyle')
	end,
	get = function(info) 
		return E.db.auradefault.buff.border.color[1],
				E.db.auradefault.buff.border.color[2],
				E.db.auradefault.buff.border.color[3],
				E.db.auradefault.buff.border.color[4] 
	end,
}

E.GUI.args.unitframes.args.Auras.args.BorderOpts.args.BorderSize = {
	name = L['Border size'],
	type = "slider",
	order	= 3,
	min		= 1,
	max		= 32,
	step	= 1,
	set = function(info,val) 
		E.db.auradefault.buff.border.size = val
		InterateAuraFrames('UpdateStyle')
	end,
	get =function(info)
		return E.db.auradefault.buff.border.size
	end,
}

E.GUI.args.unitframes.args.Auras.args.BorderOpts.args.BorderInset = {
	name = L['Border inset'],
	type = "slider",
	order	= 4,
	min		= -32,
	max		= 32,
	step	= 1,
	set = function(info,val) 
		E.db.auradefault.buff.border.inset = val
		InterateAuraFrames('UpdateStyle')
	end,
	get =function(info)
		return E.db.auradefault.buff.border.inset
	end,
}


E.GUI.args.unitframes.args.Auras.args.BorderOpts.args.BackgroundTexture = {
	order = 5,
	type = 'statusbar',
	name = L['Background texture'],
	values = E.GetTextureList,
	set = function(info,value) 
		E.db.auradefault.buff.border.background_texture = value;
		InterateAuraFrames('UpdateStyle')
	end,
	get = function(info) return E.db.auradefault.buff.border.background_texture end,
}

E.GUI.args.unitframes.args.Auras.args.BorderOpts.args.BackgroundColor = {
	order = 6,
	name = L['Background color'],
	type = "color", 
	hasAlpha = true,
	set = function(info,r,g,b,a) 
		E.db.auradefault.buff.border.background_color={ r, g, b, a}
		InterateAuraFrames('UpdateStyle')
	end,
	get = function(info) 
		return E.db.auradefault.buff.border.background_color[1],
				E.db.auradefault.buff.border.background_color[2],
				E.db.auradefault.buff.border.background_color[3],
				E.db.auradefault.buff.border.background_color[4] 
	end,
}


E.GUI.args.unitframes.args.Auras.args.BorderOpts.args.backgroundInset = {
	name = L['Background inset'],
	type = "slider",
	order	= 7,
	min		= -32,
	max		= 32,
	step	= 1,
	set = function(info,val) 
		E.db.auradefault.buff.border.background_inset = val
		InterateAuraFrames('UpdateStyle')
	end,
	get =function(info)
		return E.db.auradefault.buff.border.background_inset
	end,
}
		

E.GUI.args.unitframes.args.Auras.args.Filters = {
	name = L['Filters'],
	order = -1,
	type = "group", 
	args = {}
}

local selectedspell = nil
local selectedspellwl = nil

E.GUI.args.unitframes.args.Auras.args.Filters.args.blackList = {		
	name = L['Black list'],
	order = 1,
	type = "group", embend = true,
	args = {}
}
	
E.GUI.args.unitframes.args.Auras.args.Filters.args.blackList.args.spellid = {
	name = 'SpellID',
	type = "editbox",
	order = 1,
	set = function(self, value)
		local num = tonumber(value)			
		if num and GetSpellInfo(num) then
			
			blacklist[num] = true
			
			selectedspell = num
		end
	end,
	get = function(self)
		return ''
	end,

}
	
E.GUI.args.unitframes.args.Auras.args.Filters.args.blackList.args.spelllist = {
	name = L['Select spell'],
	type = "dropdown",
	order = 2,
	values = function() 
		local t = {}		
		if AleaUIDB then			
			for k,v in pairs(blacklist) do			
				if v then
					local name, _, icon = GetSpellInfo(k)
					if name then
						t[k] = "\124T"..icon..":10\124t "..name
					end
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

E.GUI.args.unitframes.args.Auras.args.Filters.args.blackList.args.show = {
	name = L['Mode'],
	type = "dropdown",
	order = 4,
	values = {
		L['Only foreign'],
		L['Only mine'],
		L['All'],
		L['Disable'],
	},
	set = function(self, value)
		if selectedspell then
			if value == 4 then
				blacklist[selectedspell] = false
			else
				blacklist[selectedspell] = value
			end
		end
	end,
	get = function(self)
		if selectedspell then
			if blacklist[selectedspell] == false then
				return 4
			else
				return blacklist[selectedspell]
			end
		else
			return 4
		end
	end,	
}


E.GUI.args.unitframes.args.Auras.args.Filters.args.whiteList = {		
	name = L["While list"],
	order = 1,
	type = "group", embend = true,
	args = {}
}
	
E.GUI.args.unitframes.args.Auras.args.Filters.args.whiteList.args.spellid = {
	name = 'SpellID',
	type = "editbox",
	order = 1,
	set = function(self, value)
		local num = tonumber(value)			
		if num and GetSpellInfo(num) then			
			whitelist[num] = true			
			selectedspellwl = num
		end
	end,
	get = function(self)
		return ''
	end,

}
	
E.GUI.args.unitframes.args.Auras.args.Filters.args.whiteList.args.spelllist = {
	name = L['Select spell'],
	type = "dropdown",
	order = 2,
	values = function() 
		local t = {}		
		if AleaUIDB then				
			for k,v in pairs(whitelist) do			
				if v then
					local name, _, icon = GetSpellInfo(k)
					if name then
						t[k] = "\124T"..icon..":10\124t "..name
					end
				end
			end
		end
		return t
	end,
	set = function(self, value)			
		selectedspellwl = value
	end,
	get = function(self)
		return selectedspellwl
	end,	
}

E.GUI.args.unitframes.args.Auras.args.Filters.args.whiteList.args.show = {
	name = "Mode",
	type = "dropdown",
	order = 4,
	values = {
		L['Only foreign'],
		L['Only mine'],
		L['All'],
		L['Disable'],
	},
	set = function(self, value)
		if selectedspellwl then
			if value == 4 then
				whitelist[selectedspellwl] = false
			else
				whitelist[selectedspellwl] = value
			end
		end
	end,
	get = function(self)
		if selectedspellwl then
			if whitelist[selectedspellwl] == false then
				return 4
			else
				return whitelist[selectedspellwl]
			end
		else
			return 4
		end
	end,	
}