local addOn, E = ...
local L = E.L
local NP = E:Module('NamePlates')
local UF = E:Module("UnitFrames")

local plateFrameOffset = 3
local plateFrameOffsetFriendly = 10
local plateFrameWidthOffset = 20
local ignoreSizeChange = true
local numVisiblePlates = 0
local showHitbox = false

local parentToBlizzard = true
local baseNonTargetAlpha = parentToBlizzard and 0.6 or 0.6

local baseStrata = 'LOW'
local baseFrameLevel = 5

local _G = _G
local GetTime = GetTime
local floor = floor
local UnitAura = UnitAura
local CreateFrame = CreateFrame
local GetSpellInfo = GetSpellInfo
local UnitGUID = UnitGUID
local UnitIsUnit = UnitIsUnit
local UnitIsPlayer = UnitIsPlayer
local UnitCanAttack = UnitCanAttack
local UnitExists = UnitExists
local pairs = pairs
--local C_NamePlate = C_NamePlate
local GetRaidTargetIndex = GetRaidTargetIndex
local UnitPlayerControlled = UnitPlayerControlled
local UnitIsTapDenied = UnitIsTapDenied
local UnitDetailedThreatSituation = UnitDetailedThreatSituation
local MouseIsOver = MouseIsOver
local UnitClass = UnitClass
local UnitSelectionColor = UnitSelectionColor
local UnitClassification = UnitClassification
local UnitLevel = UnitLevel
local UnitBattlePetLevel = UnitBattlePetLevel
local UnitIsBattlePetCompanion = UnitIsBattlePetCompanion
local UnitName = UnitName
local UnitGetIncomingHeals = UnitGetIncomingHeals
local UnitGetTotalAbsorbs = UnitGetTotalAbsorbs
local UnitGetTotalHealAbsorbs = UnitGetTotalHealAbsorbs
local UnitHealthMax = UnitHealthMax
local UnitHealth = UnitHealth
local UnitChannelInfo = UnitChannelInfo
local UnitCastingInfo = UnitCastingInfo
local UnitPowerMax = UnitPowerMax
local UnitPower = UnitPower
local UnitPowerType = UnitPowerType
local GetFramerate = GetFramerate
local max = math.max
local tonumber = tonumber
local ceil = ceil
local unpack = unpack
local UnitIsFriend = UnitIsFriend
local UnitThreatSituation = UnitThreatSituation
local UnitShouldDisplayName = UnitShouldDisplayName

local selectedspell
local selectedname
local selectedspellbl

NP.CreatedPlates = {}
--[==[
	["nameplateOtherAtBase"] = "Position other nameplates at the base, rather than overhead -1=bottom 0=top 1=middle",
	["nameplateOverlapH"] = "Percentage amount for horizontal overlap of nameplates",
	["nameplateOverlapV"] = "Percentage amount for vertical overlap of nameplates",
	["nameplateResourceOnTarget"] = "Nameplate class resource overlay mode. 0=self, 1=target",

	["nameplateShowSelf"] = "",
	["nameplateShowEnemies"] = "",
	["nameplateShowEnemyMinions"] = "",
	["nameplateShowEnemyPets"] = "",
	["nameplateShowEnemyGuardians"] = "",
	["nameplateShowEnemyTotems"] = "",
	["nameplateShowEnemyMinus"] = "",
	["nameplateShowFriends"] = "",
	["nameplateShowFriendlyMinions"] = "",
	["nameplateShowFriendlyPets"] = "",
	["nameplateShowFriendlyGuardians"] = "",
	["nameplateShowFriendlyTotems"] = "",
	["nameplateShowAll"] = "",

	["nameplateMaxDistance"] = "The max distance to show nameplates.",
	["nameplateTargetBehindMaxDistance"] = "The max distance to show the target nameplate when the target is behind the camera.",
	["nameplateMotion"] = "Defines the movement/collision model for nameplates",
	["nameplateMotionSpeed"] = "Controls the rate at which nameplate animates into their target locations [0.0-1.0] default=0.025",
	["nameplateGlobalScale"] = "Applies global scaling to non-self nameplates, this is applied AFTER selected, min, and max scale.",
	["nameplateMinScale"] = "The minimum scale of nameplates. default=0.8",
	["nameplateMaxScale"] = "The max scale of nameplates.",
	["nameplateLargerScale"] = "An additional scale modifier for important monsters.",
	["nameplateMinScaleDistance"] = "The distance from the max distance that nameplates will reach their minimum scale.",
	["nameplateMaxScaleDistance"] = "The distance from the camera that nameplates will reach their maximum scale.",
	["nameplateMinAlpha"] = "The minimum alpha of nameplates.",
	["nameplateMaxAlpha"] = "The max alpha of nameplates.",
	["nameplateMinAlphaDistance"] = "The distance from the max distance that nameplates will reach their minimum alpha.",
	["nameplateMaxAlphaDistance"] = "The distance from the camera that nameplates will reach their maximum alpha.",
	["nameplateSelectedScale"] = "The scale of the selected nameplate.",
	["nameplateSelectedAlpha"] = "The alpha of the selected nameplate.",
	["nameplateSelfScale"] = "The scale of the self nameplate.",
	["nameplateSelfAlpha"] = "The alpha of the self nameplate.",
	["nameplateSelfBottomInset"] = "The inset from the bottom (in screen percent) that the self nameplate is clamped to.",
	["nameplateSelfTopInset"] = "The inset from the top (in screen percent) that the self nameplate is clamped to.",
	["nameplateOtherBottomInset"] = "The inset from the bottom (in screen percent) that the non-self nameplates are clamped to.",
	["nameplateOtherTopInset"] = "The inset from the top (in screen percent) that the non-self nameplates are clamped to.",
	["nameplateLargeBottomInset"] = "The inset from the bottom (in screen percent) that large nameplates are clamped to.",
	["nameplateLargeTopInset"] = "The inset from the top (in screen percent) that large nameplates are clamped to.",
	["nameplateClassResourceTopInset"] = "The inset from the top (in screen percent) that nameplates are clamped to when class resources are being displayed on them.",
	["ShowClassColorInNameplate"] = "use this to display the class color in the nameplate health bar",
	["ShowNamePlateLoseAggroFlash"] = "When enabled, if you are a tank role and lose aggro, the nameplate with briefly flash.",
	["NamePlateHorizontalScale"] = "Applied to horizontal size of all nameplates.",
	["NamePlateVerticalScale"] = "Applied to vertical size of all nameplates.",

	["nameplateTargetRadialPosition"] = { prettyName = nil, description = "When target is off screen, position its nameplate radially around sides and bottom", type = "number"},
	["nameplateOccludedAlphaMult"] = { prettyName = nil, description = "Alpha multiplier of nameplates for occluded targets", type = "number"}, 0.4 default

]==]
local colorToTypeName = {
	["color1"] = "Physical",
	["color2"] = "Magic",
	["color3"] = "Curse",
	["color4"] = "Disease",
	["color5"] = "Poison",
	["color6"] = "Buff",
	["purge"] = "Purge",
}

local spellstringcache = {}

function NP:SpellString(spellid)
	if not spellstringcache[spellid] then
		local name, _, icon = GetSpellInfo(spellid)
		spellstringcache[spellid] = "\124T"..icon..":10\124t "..name
	end

	return spellstringcache[spellid]
end


--[==[
	1 - Hated
	2 - Hostile
	3 - Unfriendly
	4 - Neutral
	5 - Friendly
	6 - Honored
	7 - Revered
	8 - Exalted
]==]
function NP:IsFriendly(unit)
	local reaction = UnitReaction("player", unit)

	return reaction > 4
end

local disableMouseover = true

local function DisableBlizzardNamePlates()
	--NamePlateDriverFrame:UnregisterAllEvents()
	--NamePlateDriverFrame:RegisterEvent("FORBIDDEN_NAME_PLATE_CREATED");
	--NamePlateDriverFrame:RegisterEvent("FORBIDDEN_NAME_PLATE_UNIT_ADDED");
	--NamePlateDriverFrame:RegisterEvent("FORBIDDEN_NAME_PLATE_UNIT_REMOVED");
	--NamePlateDriverFrame.SetBaseNamePlateSize = E.noop

	NamePlateDriverFrame:UnregisterEvent("UNIT_AURA");
	
	--[==[
	hooksecurefunc(NamePlateDriverMixin, 'SetBaseNamePlateSize', function()
		print('Hook', 'NamePlateDriverMixin:SetBaseNamePlateSize')
	end)
	hooksecurefunc(NamePlateDriverFrame, 'SetBaseNamePlateSize', function()
		print('Hook', 'NamePlateDriverFrame:SetBaseNamePlateSize')
	end)

	hooksecurefunc(NamePlateDriverMixin, 'UpdateNamePlateOptions', function()
		print('Hook', 'NamePlateDriverMixin:UpdateNamePlateOptions')
		NP:UpdateBasePlateSize()
	end)

	hooksecurefunc(NamePlateDriverFrame, 'UpdateNamePlateOptions', function()
		print('Hook', 'NamePlateDriverFrame:UpdateNamePlateOptions')
		NP:UpdateBasePlateSize()
	end)
	]==]

	local outcombatUpdate = CreateFrame('Frame')
	outcombatUpdate:SetScript('OnEvent', function(self, event)
		NP:UpdateBasePlateSize()
		self:UnregisterEvent(event)
	end)

	local function UpdateBasePlateSize()
		if ignoreSizeChange then return end
		if InCombatLockdown() then
			outcombatUpdate:RegisterEvent('PLAYER_REGEN_ENABLED')
		else
			NP:UpdateBasePlateSize()
		end
	end

	--hooksecurefunc(C_NamePlate, 'SetNamePlateFriendlySize', UpdateBasePlateSize)
	hooksecurefunc(C_NamePlate, 'SetNamePlateEnemySize', UpdateBasePlateSize)
	hooksecurefunc(C_NamePlate, 'SetNamePlateSelfSize', UpdateBasePlateSize)
	

	ClassNameplateBarRogueDruidFrame:UnregisterAllEvents()
	ClassNameplateBarRogueDruidFrame:SetScript('OnEvent', E.noop)

	DeathKnightResourceOverlayFrame:UnregisterAllEvents()
	DeathKnightResourceOverlayFrame:SetScript('OnEvent', E.noop)

	ClassNameplateBarMageFrame:UnregisterAllEvents()
	ClassNameplateBarMageFrame:SetScript('OnEvent', E.noop)

	if ClassNameplateBarMonkFrame then
	ClassNameplateBarMonkFrame:UnregisterAllEvents()
	ClassNameplateBarMonkFrame:SetScript('OnEvent', E.noop)
	end

	ClassNameplateBarPaladinFrame:UnregisterAllEvents()
	ClassNameplateBarPaladinFrame:SetScript('OnEvent', E.noop)

	ClassNameplateBarWarlockFrame:UnregisterAllEvents()
	ClassNameplateBarWarlockFrame:SetScript('OnEvent', E.noop)
end

AleaUI:OnInit2(function()
	if NamePlateDriverFrame then
		DisableBlizzardNamePlates()
	else
		AleaUI:OnAddonLoad('Blizzard_NamePlates', DisableBlizzardNamePlates)
	end
end)

local defaults = {

	reactions = {
		tapped  		= { r = 0.6, g = 0.6, b = 0.6 },
		neutral 		= { r = 218/255, g = 197/255, b = 92/255 },
		enemy 			= { r = 0.78, g = 0.25, b = 0.25 },
		friendlyNPC 	= { r = 0.31, g = 0.45, b = 0.63},
		friendlyPlayer 	= { r = 75/255,  g = 175/255, b = 76/255},
	},


	showfromspelllist	= true,
	showmyauras			= true,
	showpurge			= true,

	easyPlatesForFriendly = true,

	backdropfadecolor 	= { .06, .06, .06,  0.3 },
	bordercolor 		= { 0,0,0,1 },
	backgroundInset		= 0,
	borderInset			= 0,
	borderSize			= 1,
	background_texture	= E.media.default_bar_texture_name3,
	borderTexture		= E.media.default_bar_texture_name3,

	font 				= E.media.default_font_name,
	fontSize 			= 10,
	fontOutline 		= 'OUTLINE',

	friendlyFont		= E.media.default_font_name,
	friendlyFontSize	= 10,
	friendlyFontOutline = 'OUTLINE',

	nonTargetAlpha 		= 0.6,
	healthBar_width 	= 120,
	healthBar_height 	= 18,
	healthBar_texture 	= E.media.default_bar_texture_name1,

	hitbox_height		= 40,
	hitbox_width		= 120,

	overlapV			= 0.9,
	overlapH 			= 0.8,
	
	healthBar_name_visability = 1, -- 1 always; 2 only target; 3 never
	healthBar_name_attachTo = 'TOPLEFT',
	healthBar_name_widthUpTo = 1, -- 1 to lvl text; 2 to bar; 3 full text
	healthBar_name_xOffset = 0,
	healthBar_name_yOffset = 0,

	healthBar_hp_xOffset = 0,
	healthBar_hp_yOffset = 0,
	healthBar_hp_format  = 4,
	healthBar_hp_attachTo = 'BOTTOM',

	healthBar_lvl_visability = 2, -- 1 always; 2 only not same; 3 never
	healthBar_lvl_attachTo = 'TOPRIGHT',
	healthBar_lvl_xOffset = 3,
	healthBar_lvl_yOffset = 10,

	castBar_height 		= 6,
	castBar_offset		= -3,
	castBar_color 		= {1,208/255,0 },
	castBar_noInterrupt = {0.78,0.25,0.25 },
	castBar_bordercolor = { .06, .06, .06,  0.3 },
	castBar_background  = { 0,0,0,1 },

	castBar_borderTexture = E.media.default_bar_texture_name3,
	castBar_borderSize	= 1,
	castBar_borderInset = 0,
	castBar_backgroundInset = 0,
	castBar_background_texture = E.media.default_bar_texture_name3,

	raidIcon_xOffset 	= -4,
	raidIcon_yOffset	= 6,
	raidIcon_size 		= 28,
	raidIcon_attachTo 	= 'LEFT',
	raidIcon_attachFrom = "RIGHT",

	auraSize			= 16,

	aura_xOffset = 0,
	aura_yOffset = 1,
	stretchTexture = false,

	buffs = {
		numAuras 		= 6,
		friendlynumAuras = 6,
		stretchTexture 	= true,
	},
	debuffs = {
		numAuras 		= 6,
		friendlynumAuras = 6,
		stretchTexture 	= true,
	},
	colorByType 		= false,

	typecolors 			= {
		color1		= {0.80,0,0},
		color2		= {0.20,0.60,1.00},
		color3		= {0.60,0.00,1.00 },
		color4		= {0.60,0.40, 0 },
		color5		= {0.00,0.60,0 },
		color6		= {0.00,1.00,0 },
		purge		= { 1, 1, 1 },
	},

	spelllist = {},
	namelist = {},
	blacklist = {},

	nameplateMaxDistance = 60,
	nameplateOffsets = false,

	nameplateMotion = "STACKED",

	nameplateShowAll = true,

	nameplateShowSelf = false,

	nameplateShowEnemies = true,
	nameplateShowEnemyMinions = true,
	nameplateShowEnemyPets = true,
	nameplateShowEnemyGuardians = true,
	nameplateShowEnemyTotems = true,
	nameplateShowEnemyMinus = true,

	nameplateShowFriends = false,
	nameplateShowFriendlyMinions = false,
	nameplateShowFriendlyPets = false,
	nameplateShowFriendlyGuardians = false,
	nameplateShowFriendlyTotems = false,

	nameplatePosition = 0,
}

local defaultSpells1 = {--Important spells, add them with huge icons.
	205369, -- Priest Shadow bomb
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
	29166, --Innervate (druid)
	47585, --Dispersion (priest)

	87204, -- Shadow Priest 4pPVP

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

	53480, --Hunter

	15286, --Priest

	122783, --Monk
	122278, --Monk
	122465, --Monk

}

local defaultSpells2 = {--semi-important spells, add them with mid size icons.
	186265, -- hunter
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

	23920, --Warrior Reflect
	1719, --Warrior Recklessness
	18499, --Warrior Berserk
	71, --Warrior  Defence Stance
	107574, --Warrior Avatar
	12292, --Warrior Bleed
	114028, --Warriot Mass Reflect

	124974, --Druid

	102342, --Druid

	1966, -- Rogue faint
	48263, --DK blood presens
	77535, --DK Shield blood

	3045, --Hunter
	19574, --Hunter

	--[[ INCAPACITATES ]]--
	-- Druid
	99, -- Incapacitating Roar (talent)
	-- Hunter
	3355,	-- Freezing Trap
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
	6789, -- Mortal Coil
	-- Pandaren
	107079, -- Quaking Palm

	--[[ SILENCES ]]--
	-- Death Knight
	47476, -- Strangulate
	-- Druid

	-- Mage

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

	--[[ STUNS ]]--
	-- Death Knight
	108194, -- Asphyxiate
	91800, -- Gnaw (Ghoul)
	91797, -- Monstrous Blow (Dark Transformation Ghoul)

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

	113656, -- Fists of Fury
	120086, -- Fists of Fury
	119381, -- Leg Sweep
	-- Paladin
	853, -- Hammer of Justice

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


	--[[ ROOTS ]]--
	-- Death Knight
	96294, -- Chains of Ice (Chilblains Root)
	-- Druid
	339, -- Entangling Roots
	102359, -- Mass Entanglement (talent)

	-- Hunter
	61685,
	53148, -- Charge (Tenacity pet)
	135373, -- Entrapment (passive)
	136634, -- Narrow Escape (passive talent)
	-- Mage
	122, -- Frost Nova
	33395, -- Freeze (Water Elemental)
	-- Monk
	116095, --
	116706, -- Disable
	-- Priest
	114404, -- Void Tendrils
	-- Shaman
	64695, -- Earthgrab Totem
}

local bannedspells = {
	[15407] = true,
	[146198] = true,
}

local specific_defaultSpellsOpts = {
	[12292]  = { show = 4, spellID = 12292,  checkID = true, size = 1.5, filter = 2, },
	[163505] = { show = 4, spellID = 163505, checkID = true, size = 1.5, filter = 2, },
	[123393] = { show = 4, spellID = 123393, checkID = true, size = 2, filter = 2, },
}
for k,v in pairs(defaultSpells1) do
	if GetSpellInfo(v) then
		defaults.spelllist[GetSpellInfo(v)] = specific_defaultSpellsOpts[v] or { show = 4, spellID = v, checkID = false, size = 2, filter = 2, }
	else
	--	print('<AleaUI:NPAuralist>defaultSpells1', v, 'is Unknown')
	end
end
wipe(defaultSpells1)
for k,v in pairs(defaultSpells2) do
	if GetSpellInfo(v) then
		defaults.spelllist[GetSpellInfo(v)] = specific_defaultSpellsOpts[v] or { show = 4, spellID = v, checkID = false, size = 1.5, filter = 2, }
	else
	--	print('<AleaUI:NPAuralist>defaultSpells2', v, 'is Unknown')
	end
end
wipe(defaultSpells2)
for k,v in pairs(bannedspells) do
	if GetSpellInfo(k) then
		defaults.blacklist[GetSpellInfo(k)] = specific_defaultSpellsOpts[v] or { show = 2, spellID = k, checkID = false, size = 1, filter = 2, }
	else
	--	print('<AleaUI:NPAuralist>bannedspells', k, 'is Unknown')
	end
end
wipe(bannedspells)

E.default_settings.nameplates = defaults

local GetNamePlateForUnit = C_NamePlate.GetNamePlateForUnit
local GetNamePlates = C_NamePlate.GetNamePlates

NP:RegisterEvent("NAME_PLATE_CREATED");
NP:RegisterEvent("NAME_PLATE_UNIT_ADDED");
NP:RegisterEvent("NAME_PLATE_UNIT_REMOVED");
NP:RegisterEvent("PLAYER_TARGET_CHANGED");
--NP:RegisterEvent("DISPLAY_SIZE_CHANGED");
--NP:RegisterEvent("CVAR_UPDATE");
NP:RegisterEvent("RAID_TARGET_UPDATE");
NP:RegisterEvent('UPDATE_MOUSEOVER_UNIT')
NP:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE")
NP:RegisterEvent('QUEST_LOG_UPDATE')
NP:RegisterEvent('QUEST_WATCH_UPDATE')
NP:RegisterEvent('CURSOR_UPDATE')

local questGUIDs = {}
local questLog = {}
local questGUIDsSkip = {}

-- UnitShouldDisplayName
function NP.IsUnitQuestFlagged(unit)

	if not unit then
		return false
	end

	if UnitIsPlayer(unit) then
		return false
	end

	local npcID = E.GetNpcID(unit)
	local guid = UnitGUID(unit)

	if questGUIDs[npcID] then
		return true
	end

	if questGUIDsSkip[guid] then
		return false
	end

	E.scantip:ClearLines()
	E.scantip:SetUnit(unit)

	for i = 1, E.scantip:NumLines() do
		local left = _G[E.scantip:GetName().."TextLeft"..i]:GetText()

		if left and questLog[left] then
			print('Assigned quest', left, 'with', npcID)
			
			local questText = _G[E.scantip:GetName().."TextLeft"..(i+1)]:GetText()
			local a1, a2, a3, a4 = string.find(questText, '(%d+)/(%d+)')

			local per1, per2, per3, per4 = string.find(questText, '(%d+)%%')

			print(' Quest text:', questText, a3, a4, per3, per3 == '100' )

			questGUIDs[npcID] = true

			if ( ( a3 and a3 == a4 ) or per3 == '100' ) then
				return false
			else
				return true
			end
		end
	end

	questGUIDsSkip[guid] = true

	return questGUIDs[npcID]
end


local lastNumQuest = -1
local lastNumQuestComplete = -1
function NP:QUEST_LOG_UPDATE(event, ...)
	questLog = {}

	local questCurrent = 0
	local questCompleteCurrent = 0

	for a=1, GetNumQuestLogEntries() do
	   local title, level, suggestedGroup, isHeader, isCollapsed, isComplete, frequency, questID = GetQuestLogTitle(a);

		if ( questID and questID > 0 ) then
			if isComplete then
				questCompleteCurrent = questCompleteCurrent + 1
			else
				questCurrent = questCurrent + 1

				questLog[title] = true
			end
		end
	end


	if lastNumQuest ~= questCurrent or event == 'QUEST_WATCH_UPDATE' or lastNumQuestComplete ~= questCompleteCurrent then
	--	print('Update questlog', lastNumQuest,'->', questCurrent, lastNumQuestComplete,'->',questCompleteCurrent)

		questGUIDs = {}
		questGUIDsSkip = {}

		lastNumQuest = questCurrent
		lastNumQuestComplete = questCompleteCurrent

		for _, frame in pairs(GetNamePlates()) do
			frame.AleaNP.isQuestFlagged = NP.IsUnitQuestFlagged(frame.AleaNP.unit)
			frame.AleaNP:UpdateName()
		end
	end
end

NP.QUEST_LOG_UPDATE = NP.QUEST_LOG_UPDATE
NP.QUEST_WATCH_UPDATE = NP.QUEST_LOG_UPDATE

function NP:NAME_PLATE_CREATED(event, realFrame)
	NP:CreateNamePlateFrame(realFrame)
end

function NP:NAME_PLATE_UNIT_ADDED(event, unit)
	local realFrame = GetNamePlateForUnit(unit)

	if ( realFrame ) then
		numVisiblePlates = numVisiblePlates + 1

	--	print('Update count plates', numVisiblePlates)

		--realFrame.namePlateUnitToken = unit

		realFrame.AleaNP.plateNamePlate = nil
		realFrame.AleaNP:Show()
		
	--	if realFrame.UnitFrame then
	--		realFrame.UnitFrame:SetAlpha(0)
	--	end
		
		realFrame.AleaNP.overlay:Hide()

		realFrame.AleaNP.FriendlyPlate:Show()

		realFrame.AleaNP.unit = unit
		realFrame.AleaNP.guid = UnitGUID(unit)
		realFrame.AleaNP.npcID = E.GetNpcID(unit)

		realFrame.AleaNP.isMinus = UnitClassification(unit) == 'minus'
		realFrame.AleaNP.isPlayer = UnitIsPlayer(unit)

		--[==[
			UnitCanAssist('player', unit)

			UnitReaction("player", unit) and UnitReaction("player", unit) <= 4

			UnitIsFriend('player', unit)
		]==]

		realFrame.AleaNP.isFriend = NP:IsFriendly(unit)

		realFrame.AleaNP.canAttack = UnitCanAttack('player', unit);
		realFrame.AleaNP.isQuestFlagged = NP.IsUnitQuestFlagged(unit)

		realFrame.AleaNP:OnShowUpdate()

		if UnitIsUnit(unit, 'target') and not UnitIsUnit(unit, 'player') then
			realFrame.AleaNP:SetTargetWidth()
		else
			realFrame.AleaNP:SetNormalWidth()
		end
	end
end

function NP:NAME_PLATE_UNIT_REMOVED(event, unit)
	local realFrame = GetNamePlateForUnit(unit)

	if ( realFrame ) then
		numVisiblePlates = numVisiblePlates -1

	--	print('Update count plates', numVisiblePlates)

		--realFrame.namePlateUnitToken = nil

		realFrame.AleaNP:Hide()
		realFrame.AleaNP.FriendlyPlate:Hide()
		realFrame.AleaNP.overlay:Hide()
		
	--	if realFrame.UnitFrame then
	--		realFrame.UnitFrame:SetAlpha(0)
	--	end
		
		E.ClearAnimationCutaway( realFrame.AleaNP )

		realFrame.AleaNP.isMinus = nil
		realFrame.AleaNP.guid = nil
		realFrame.AleaNP.npcID = nil
		realFrame.AleaNP.isPlayer = nil
		realFrame.AleaNP.isFriend = nil
		realFrame.AleaNP.canAttack = nil
		realFrame.AleaNP.isQuestFlagged = nil

		NP:RemovePowerBar(realFrame.AleaNP)

		realFrame.AleaNP:UnregisterAllEvents()

		realFrame.AleaNP.unit = nil
		realFrame.AleaNP.plateNamePlate = nil
		realFrame.AleaNP:SetNormalWidth()

		realFrame.AleaNP.castBar:SkipFade()
	end
end

function NP:PLAYER_TARGET_CHANGED(event)
	if UnitExists('target') then
		local realFrame = GetNamePlateForUnit('target')
		for _, frame in pairs(GetNamePlates()) do
			if frame ~= realFrame then
				frame.AleaNP:SetAlpha( frame.AleaNP.disableBars and 0 or baseNonTargetAlpha)
				frame.AleaNP:UpdateFrameLevel()
				frame.AleaNP:SetNormalWidth()
				frame.AleaNP:UpdateName()
				frame.AleaNP:UpdateLevel()
			end
		end

		if ( realFrame ) then
			realFrame.AleaNP:SetAlpha( realFrame.AleaNP.disableBars and 0 or 1)
			realFrame.AleaNP:UpdateAuras()
			realFrame.AleaNP:UpdateFrameLevel()
			realFrame.AleaNP:UpdateName()
			realFrame.AleaNP:UpdateLevel()
			if not UnitIsUnit(realFrame.AleaNP.unit, 'player') then
				realFrame.AleaNP:SetTargetWidth()
			else
				realFrame.AleaNP:SetNormalWidth()
			end
		end
	else
		for _, frame in pairs(GetNamePlates()) do
			frame.AleaNP:SetAlpha( frame.AleaNP.disableBars and 0 or baseNonTargetAlpha)
			frame.AleaNP:UpdateFrameLevel()
			frame.AleaNP:SetNormalWidth()
			frame.AleaNP:UpdateName()
			frame.AleaNP:UpdateLevel()
		end
	end
end

function NP:DISPLAY_SIZE_CHANGED(event)
end


local throttledAggroCheck = true
local function ThrottledUpdateAggro()
--	print('ThrottledUpdateAggro')

	for _, frame in pairs(GetNamePlates()) do
		if not frame.AleaNP.disableBars then
			frame.AleaNP:UpdateAggro()
			frame.AleaNP:UpdateFaction()
		end
	end

	throttledAggroCheck = true
end

function NP:UNIT_THREAT_SITUATION_UPDATE(event, unit)
	if event == 'UNIT_THREAT_SITUATION_UPDATE' and ( unit == 'player' or unit == 'vehicle' or unit == 'per' ) then

		if throttledAggroCheck then
		--	ThrottledUpdateAggro()

			throttledAggroCheck = false

			C_Timer.After(0.05, ThrottledUpdateAggro)
		end
	end
end

function NP:UpdateCustomName()
	for _, frame in pairs(GetNamePlates()) do
		if frame.AleaNP.unit then
			frame.AleaNP:UpdateName()
			frame.AleaNP:UpdateLevel()
		end
	end
end

function NP.EventHandler(self, event, unit)
	if event == 'UNIT_THREAT_SITUATION_UPDATE' and ( unit == 'player' or unit == 'vehicle' or unit == 'per' ) then

		if throttledAggroCheck then
		--	ThrottledUpdateAggro()

			throttledAggroCheck = false

			C_Timer.After(0.05, ThrottledUpdateAggro)
		end
	elseif unit and unit == self.unit then
		if event == 'UNIT_AURA' then
			self:UpdateAuras()
		elseif event == 'UNIT_HEALTH' or event == 'UNIT_MAXHEALTH' or event == 'UNIT_HEALTH_FREQUENT' or
			event == 'UNIT_ABSORB_AMOUNT_CHANGED' or event == 'UNIT_HEAL_PREDICTION' or event == 'UNIT_HEAL_ABSORB_AMOUNT_CHANGED' then

			self:UpdateHealth()
		elseif event == 'UNIT_FACTION' or event == 'UNIT_FLAGS' then
	--		print('Event', event, unit)
			local isFriend = NP:IsFriendly(unit)
			local canAttack = UnitCanAttack("player", unit);

			if ( self.isFriend ~= isFriend ) or ( self.canAttack ~= canAttack ) then
				self.isFriend = isFriend
				self.canAttack = canAttack

				self:OnShowUpdate()
			end

			self:UpdateName()
			self:UpdateFaction()
		elseif event == 'UNIT_NAME_UPDATE' then
			self:UpdateName()
		elseif event == "UNIT_SPELLCAST_CHANNEL_START" or
				event == "UNIT_SPELLCAST_CHANNEL_UPDATE" or
				event == "UNIT_SPELLCAST_START" or
				event == "UNIT_SPELLCAST_DELAYED" then

			self:UpdateCast()
		elseif event == "UNIT_SPELLCAST_CHANNEL_STOP" or
				event == "UNIT_SPELLCAST_STOP" or
				event == "UNIT_SPELLCAST_INTERRUPTED" or
				event == 'UNIT_SPELLCAST_FAILED' then

			self:UpdateCast()
		elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
			self:UpdateCast()
		elseif event == "UNIT_SPELLCAST_INTERRUPTIBLE" then
			self.castBar.notInterruptible = false
		elseif event == "UNIT_SPELLCAST_NOT_INTERRUPTIBLE" then
			self.castBar.notInterruptible = true
		end
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

function NP:RAID_TARGET_UPDATE(event)
	for _, frame in pairs(GetNamePlates()) do
		local icon = frame.AleaNP.raidIcon
		local index = GetRaidTargetIndex(frame.AleaNP.unit)

		if ( index and raidIndexCoord[index] ) then
			icon:Show()
			icon:SetTexCoord(raidIndexCoord[index][1], raidIndexCoord[index][2], raidIndexCoord[index][3], raidIndexCoord[index][4])
		else
			icon:Hide()
		end
	end
end

function NP:CVAR_UPDATE(event, name)
--	print('NP:CVAR_UPDATE', name)
end

local RAID_CLASS_COLORS = RAID_CLASS_COLORS

local function IsTapDenied(unit)
	return not UnitPlayerControlled(unit) and UnitIsTapDenied(unit);
end

local function IsOnThreatList(threatStatus)
	return threatStatus ~= nil
end

local function IsTapped(unit)
	local _, threatStatus = UnitDetailedThreatSituation("player", unit);
	return IsOnThreatList(threatStatus);
end

local mouseoverUpdate = CreateFrame('Frame')
mouseoverUpdate:Hide()
mouseoverUpdate:SetScript('OnUpdate', function(self, elapsed)
	if UnitExists('mouseover') then

		if mouseoverUpdate.overlayFrame then
		--	if MouseIsOver(mouseoverUpdate.overlayFrame) then
		--		if not mouseoverUpdate.overlayFrame.AleaNP.mouseIsOver then
		--			mouseoverUpdate.overlayFrame.AleaNP.mouseIsOver = true
					mouseoverUpdate.overlayFrame.AleaNP.overlay:Show()
		--			mouseoverUpdate.overlayFrame.AleaNP:UpdateFrameLevel()
		--		end
		--	else
		--		mouseoverUpdate.overlayFrame.AleaNP.mouseIsOver = false
		--		mouseoverUpdate.overlayFrame.AleaNP.overlay:Hide()
			--	mouseoverUpdate.overlayFrame.AleaNP:UpdateTargetAlpha()
			--	mouseoverUpdate.overlayFrame.AleaNP:UpdateFrameLevel()
		--	end
		end
		return
	end

	for _, frame in pairs(GetNamePlates()) do
	--	frame.AleaNP.mouseIsOver = false
		frame.AleaNP.overlay:Hide()
	end

	self:Hide()
end)

function NP:UPDATE_MOUSEOVER_UNIT()
	local realFrame = GetNamePlateForUnit('mouseover')

	if disableMouseover then
		for _, frame in pairs(GetNamePlates()) do
			if frame ~= realFrame then
				frame.AleaNP.mouseIsOver = false
				frame.AleaNP.overlay:Hide()
			end
		end

		mouseoverUpdate.overlayFrame = nil
	end

	if realFrame then
		if disableMouseover and not realFrame.AleaNP.plateNamePlate and not self.disableBars then
			mouseoverUpdate.overlayFrame = realFrame
			mouseoverUpdate:Show()
		end

		realFrame.AleaNP:UpdateAuras()
	end
end

function NP:CURSOR_UPDATE()
--	print('T', 'CURSOR_UPDATE')

end

function NP:UNIT_FACTION(event, unit)
	local realFrame = GetNamePlateForUnit(unit)

	if ( realFrame ) then
		realFrame.AleaNP:UpdateName()
		realFrame.AleaNP:UpdateFaction()
	end
end

function NP:UpdateFaction()
	if not self.unit then return end

	local localizedClass, englishClass = UnitClass(self.unit);
	local classColor = RAID_CLASS_COLORS[englishClass];

	local r, g, b
	
	--Ghuun
	if self.npcID == 141851 then
		r, g, b = 255/255, 89/255, 240/255
		
	--Explosives
	elseif self.npcID == 120651 then
		r, g, b = 255/255, 157/255, 0
	elseif self.plateNamePlate then
		r, g, b = 0.1, 0.6, 0.1
	elseif self.isPlayer and classColor then
		-- Use class colors for players if class color option is turned on
		r, g, b = classColor.r, classColor.g, classColor.b;
	elseif ( IsTapDenied(self.unit) ) then
		-- Use grey if not a player and can't get tap on unit
		r, g, b = E.db.nameplates.reactions.tapped.r, E.db.nameplates.reactions.tapped.g, E.db.nameplates.reactions.tapped.b
	elseif self.isFriend then
		if self.isPlayer then
			r, g, b = E.db.nameplates.reactions.friendlyPlayer.r, E.db.nameplates.reactions.friendlyPlayer.g, E.db.nameplates.reactions.friendlyPlayer.b
		else
			r, g, b = E.db.nameplates.reactions.friendlyNPC.r, E.db.nameplates.reactions.friendlyNPC.g, E.db.nameplates.reactions.friendlyNPC.b
		end
	elseif ( true ) then
		-- Use color based on the type of unit (neutral, etc.)
		if ( IsTapped(self.unit) ) then
			r, g, b = E.db.nameplates.reactions.enemy.r, E.db.nameplates.reactions.enemy.g, E.db.nameplates.reactions.enemy.b
		else
			r, g, b = UnitSelectionColor(self.unit, true);

			if r > 0.9 and g == 0 and b == 0 then
				r, g, b = E.db.nameplates.reactions.enemy.r, E.db.nameplates.reactions.enemy.g, E.db.nameplates.reactions.enemy.b
			elseif r > 0.9 and g > 0.9 and b == 0 then
				r, g, b = E.db.nameplates.reactions.neutral.r, E.db.nameplates.reactions.neutral.g, E.db.nameplates.reactions.neutral.b
			end
		end
	else
		r, g, b = E.db.nameplates.reactions.enemy.r, E.db.nameplates.reactions.enemy.g, E.db.nameplates.reactions.enemy.b
	end

	local classif = UnitClassification(self.unit)

	if classif == 'elite' or classif == 'worldboss' then
		self.eliteIcon:Show()
		self.eliteIcon:SetDesaturated(false)
	elseif classif == 'rare' or classif == 'rareelite' then
		self.eliteIcon:Show()
		self.eliteIcon:SetDesaturated(true)
	else
		self.eliteIcon:Hide()
	end

	self:UpdateLevel()
	if not UnitIsDeadOrGhost(self.unit) then
		if self._color_r ~= r or
			self._color_g ~= g or
			self._color_b ~= b then

			self:SetStatusBarColor(r, g, b, 1)

			self.nameText_Friendly:SetTextColor(r,g,b)

			self._color_r, self._color_g, self._color_b = r, g, b
		end
	end
end

function NP:UpdateLevel()
	if not self.unit then return end

	local level = UnitLevel(self.unit)

	if E.db.nameplates.healthBar_lvl_visability == 3 then
		self.levelText:SetText('')
	elseif E.db.nameplates.healthBar_lvl_visability == 2 and not UnitIsUnit(self.unit, 'target') then
		self.levelText:SetText('')
	else
		if ( UnitIsWildBattlePet(self.unit) or UnitIsBattlePetCompanion(self.unit) ) then
			self.levelText:SetText(UnitBattlePetLevel(self.unit))
		elseif level == UnitLevel('player') then
			self.levelText:SetText('')
		elseif (level > UnitLevel('player')+3) then
			self.levelText:SetText('|cffff0000'..level.."|r")
		elseif(level > UnitLevel('player')) then
			self.levelText:SetText('|cffF2F266'..level.."|r")
		elseif level > 0 then
			self.levelText:SetText('|cff4baf4c'..level.."|r")
		else
			self.levelText:SetText('|cffcc7f00??|r')
		end
	end
end

function NP:UpdateName()
	if not self.unit then return end

	local name, server = UnitName(self.unit)

	local pref = self.isQuestFlagged and "|TInterface\\GossipFrame\\AvailableQuestIcon:0|t" or ''

	if E.db.nameplates.namelist[name] and E.db.nameplates.namelist[name].show then
		name = E.db.nameplates.namelist[name].subname or name
	end

	if not self.isMinus and E.db.nameplates.healthBar_name_visability == 3 then
		if server and self.isPlayer then
			self.nameText:SetText('')
			self.nameText_Friendly:SetText(name..'(*)')
		else
			self.nameText:SetText('')
			self.nameText_Friendly:SetText(name)
		end
	elseif E.db.nameplates.healthBar_name_visability == 2 or self.isMinus then
		if server and self.isPlayer then
			self.nameText:SetText( UnitIsUnit(self.unit, 'target') and name..'(*)' or '' )
			self.nameText_Friendly:SetText(name..'(*)')
		else
			self.nameText:SetText( UnitIsUnit(self.unit, 'target') and pref..name or '' )
			self.nameText_Friendly:SetText(name)
		end
	else
		if server and self.isPlayer then
			self.nameText:SetText(name..'(*)')
			self.nameText_Friendly:SetText(name..'(*)')
		else
			self.nameText:SetText(pref..name)
			self.nameText_Friendly:SetText(name)
		end
	end
end

function NP:UpdateTargetAlpha()
	if not self.unit then return end

	if self.disableBars then
		self:SetAlpha(0)
		return
	end

	if UnitExists('target') then
		if UnitIsUnit('target', self.unit) then
			self:SetAlpha(1)
		else
			self:SetAlpha(baseNonTargetAlpha)
		end
	else
		self:SetAlpha(baseNonTargetAlpha)
	end
end

function NP:UpdateFrameLevel()
	if not self.unit then return end
	--if true then return end

	if UnitIsUnit('target', self.unit) then
		self:SetFrameLevel(baseFrameLevel + 15)
		self.FriendlyPlate:SetFrameLevel(baseFrameLevel + 15)
	--elseif UnitIsUnit('mouseover', self.unit) and self.mouseIsOver then
	--	self:SetFrameLevel(4)
	else
		self:SetFrameLevel(baseFrameLevel)
		self.FriendlyPlate:SetFrameLevel(baseFrameLevel)
	end
end

do
	local floor = floor
	function NP:ShortPercValue(v)

		if v == 100 then
			return ('%d'):format(v)
		end

		return ('%.1f'):format(v)
	end
end


local MAX_INCOMING_HEAL_OVERFLOW = 1;

local UpdateHealPrediction = function(self)
	local _, maxHealth = self:GetMinMaxValues();
	local health = self:GetValue();
	local width = self:GetWidth()

	if ( maxHealth <= 0 ) or not self.unit then
		self.totalHealPrediction:SetWidth(0)
		self.totalHealPrediction:Hide()
		self.totalAbsorb:Hide()
		self.totalHealAbsorb:Hide()
		return;
	end

	local widthperhp = width/maxHealth

	local myIncomingHeal      = UnitGetIncomingHeals(self.unit, "player") or 0;
	local allIncomingHeal     = UnitGetIncomingHeals(self.unit) or 0;
	local totalAbsorb         = UnitGetTotalAbsorbs(self.unit) or 0;
	local myCurrentHealAbsorb = UnitGetTotalHealAbsorbs(self.unit) or 0;

	local realIncomingHeal	  = allIncomingHeal - myCurrentHealAbsorb
	if realIncomingHeal < 0 then realIncomingHeal = 0 end

	if myCurrentHealAbsorb > 0 then
		if myCurrentHealAbsorb > health then
			self.totalHealAbsorb:SetWidth(health*widthperhp)
		else
			self.totalHealAbsorb:SetWidth(myCurrentHealAbsorb*widthperhp)
		end
		self.totalHealAbsorb:Show()
	else
		self.totalHealAbsorb:Hide()
	end

	if realIncomingHeal > 0 then
		if realIncomingHeal > maxHealth - health then
			local healLeft = realIncomingHeal
			if realIncomingHeal + health > maxHealth * MAX_INCOMING_HEAL_OVERFLOW then
				healLeft =  maxHealth * MAX_INCOMING_HEAL_OVERFLOW - health
			end

			if healLeft*widthperhp > 1 then
				self.totalHealPrediction:SetWidth(healLeft*widthperhp+0.1)
				self.totalHealPrediction:SetPoint('LEFT', self.statusBarTexture, 'RIGHT', 0, 0)
				self.totalHealPrediction:Show()
			else
				self.totalHealPrediction:SetWidth(0)
				self.totalHealPrediction:Hide()
			end
		else
			self.totalHealPrediction:SetWidth(realIncomingHeal*widthperhp)
			self.totalHealPrediction:SetPoint('LEFT', self.statusBarTexture, 'RIGHT', 0, 0)
			self.totalHealPrediction:Show()
		end
	else
		self.totalHealPrediction:SetWidth(0)
		self.totalHealPrediction:Hide()
	end

	if totalAbsorb > 0 then
		local absorbLeft = maxHealth - health - realIncomingHeal

		if totalAbsorb < absorbLeft then
			absorbLeft = totalAbsorb
		end

		if absorbLeft > 0 then
			self.totalAbsorb:SetWidth(absorbLeft*widthperhp)
			self.totalAbsorb:SetPoint('LEFT', self.totalHealPrediction:IsShown() and self.totalHealPrediction or self.statusBarTexture, 'RIGHT', 0, 0)
			self.totalAbsorb:Show()
		else
			self.totalAbsorb:SetWidth(0)
			self.totalAbsorb:Hide()
		end
	else
		self.totalAbsorb:Hide()
	end
end

function NP:UpdateHealth()
	if not self.unit then return end

	local maxHP = UnitHealthMax(self.unit)
	local curHP = UnitHealth(self.unit)


	self:SetMinMaxValues(0, maxHP)
	self:SetValue(curHP)

	UpdateHealPrediction(self)

	if E.db.nameplates.healthBar_hp_format == 1 then
		self.healthText:SetText('')
	elseif E.db.nameplates.healthBar_hp_format == 2 then
		self.healthText:SetFormattedText('%s%%', NP:ShortPercValue(curHP/maxHP*100))
	elseif E.db.nameplates.healthBar_hp_format == 3 then
		self.healthText:SetFormattedText('%s', E:ShortValue(curHP))
	elseif E.db.nameplates.healthBar_hp_format == 5 then
		local pers = ceil(curHP/maxHP*100)
		if pers < 100 then
			self.healthText:SetFormattedText('%d', pers)
		else
			self.healthText:SetText('')
		end
	else
		self.healthText:SetFormattedText('%s - %s%%', E:ShortValue(curHP), NP:ShortPercValue(curHP/maxHP*100))
	end
end

--options.spelllist[GetSpellInfo(v)] = specific_defaultSpellsOpts[v] or { show = 1, spellID = v, checkID = false, size = 2 }
--options.blacklist[GetSpellInfo(k)] = specific_defaultSpellsOpts[v] or { show = 2, spellID = k, checkID = false, size = 1 }

do

	local icons = {}

	local timeout = 0
	local function OnUpdate(self, elapsed)
		timeout = timeout + elapsed
		if timeout < 0.1 then return end
		timeout = 0

		local getTime = GetTime()
		local hide = true
		for frame, expiration in pairs(icons) do
			hide = false
			frame.timer:SetText(E.FormatTime(6, expiration-getTime, true))
		end

		if hide then
			self:Hide()
		end
	end

	local onUpdater = CreateFrame('Frame')
	onUpdater:Hide()
	onUpdater:SetScript('OnUpdate', OnUpdate)

	function NP:AuraIcon_Add(frame, expiration)
		icons[frame] = expiration
		onUpdater:Show()
	end

	function NP:AuraIcon_Remove(frame)
		if icons[frame] then
			icons[frame] = nil
			OnUpdate(onUpdater, 1)
		end
	end

end

do

	local hour, minute = 3600, 60
	local format = string.format
    local ceil = math.ceil
	local floor = math.floor
	local fmod = math.fmod

	function NP:formatTimeRemaining2(msecs)
		if msecs < 0 then msecs = 0 end

		if msecs >= hour then
			return "%dh", ceil(msecs / hour)
		elseif msecs >= minute then
			return "%dm", ceil(msecs / minute)
		else
			return "%.0f", ceil(msecs)
		end
    end
end

local types_to_color = {
	["BUFF"] = "color6",
	["DEBUFF"] = "color1",
	["Poison"] = "color5",
	["Magic"] = "color2",
	["Disease"] = "color4",
	["Curse"] = "color3",
	["purge"] = "purge",
}

local function UpdateBorderColor(self, types)
	if types == "black" or types == nil then
		self:SetBorderColor(E.db.nameplates.bordercolor[1],E.db.nameplates.bordercolor[2],E.db.nameplates.bordercolor[3],1)
	else
		local c = E.db.nameplates.typecolors[types_to_color[types] or "color1"]
		self:SetBorderColor(c[1],c[2],c[3],1)
	end
end

local function FillAuraFrame(frame, unit, filter, nameplate, auratype)

	local index = 1
	local frameIndex = 1
	local frameSize = 1
	local isfriend = nameplate.isFriend and not nameplate.canAttack

	local numAuras = isfriend and E.db.nameplates[auratype].friendlynumAuras or E.db.nameplates[auratype].numAuras

	local height = E.db.nameplates.stretchTexture and E.db.nameplates.auraSize*0.7 or E.db.nameplates.auraSize
	local width = E.db.nameplates.auraSize
	local name, rank, texture, count, debuffType, duration, expirationTime, caster, isStealable, nameplateShowPersonal, spellID, _, _, _, nameplateShowAll
	
	while true do

		name, texture, count, debuffType, duration, expirationTime, caster, isStealable, nameplateShowPersonal, spellID, _, _, _, nameplateShowAll = UnitAura(unit, index, filter)

		if not name then break end
		if not frame.icons[frameIndex] then break end
		if frameIndex > numAuras then break end

		local skip = false
		
		local isMine = ( caster == "player" or caster == 'pet' or caster == 'vehicle' )
		
		local arg = E.db.nameplates.blacklist[name]
		if arg then
			if arg.checkID then
				if arg.spellID == spellID then
					skip = true;
				end
			else
				skip = true;
			end
		end

	--	print('T1', skip)

		local skip2 = false

		if not skip then
			local argW = E.db.nameplates.spelllist[name]
			local localHeight = height
			local localWidth = width

		--	print('T1', name, arg)

			if argW then
				if true then --C.db.profile.showspellformlist
					if argW.checkID then
						if argW.spellID == spellID then
							if argW.show == 1 then skip2 = true; localHeight = height*argW.size; localWidth = width*argW.size
							elseif argW.show == 3 and ( cisMine ) then skip2 = true; localHeight = height*argW.size; localWidth = width*argW.size;
							elseif argW.show == 4 and ( not isfriend ) then skip2 = true; localHeight = height*argW.size; localWidth = width*argW.size;
							elseif argW.show == 5 and ( isfriend ) then skip2 = true; localHeight = height*argW.size; localWidth = width*argW.size;
							else skip2 = false;
							end
						else skip2 = false;
						end
					else
						if argW.show == 1 then skip2 = true; localHeight = height*argW.size; localWidth = width*argW.size;
						elseif argW.show == 3 and ( isMine ) then skip2 = true; localHeight = height*argW.size; localWidth = width*argW.size;
						elseif argW.show == 4 and ( not isfriend ) then skip2 = true; localHeight = height*argW.size; localWidth = width*argW.size;
						elseif argW.show == 5 and ( isfriend ) then skip2 = true; localHeight = height*argW.size; localWidth = width*argW.size;
						else skip2 = false;
						end
					end
				end
			end

			if ( isMine ) or
			   ( nameplateShowAll ) or
			   ( filter == 'HELPFUL' and not isfriend and isStealable ) or
			   ( skip2 ) or E.spellContol[spellID] then
				
				local f = frame.icons[frameIndex]
				
				f.icon:SetTexture(texture)

				if not nameplate.isFriend and auratype == "debuffs" and not isMine then
					f.icon:SetDesaturated(true)	
				elseif isMine and auratype == "debuffs" then
					f.icon:SetDesaturated(false)
				else
					f.icon:SetDesaturated(true)
				end
	
				if E.db.nameplates.showpurge and isStealable then
					UpdateBorderColor(f, 'purge')
				elseif E.db.nameplates.colorByType then
					UpdateBorderColor(f, debuffType)
				else
					UpdateBorderColor(f, "black")
				end


				if duration and duration > 0 then
					f.timer:SetText(E.FormatTime(6, expirationTime-GetTime(), true)) --NP:formatTimeRemaining2(expirationTime-GetTime()))
					f.timer:Show()

					NP:AuraIcon_Add(f, expirationTime)
				else
					f.timer:Hide()
					NP:AuraIcon_Remove(f)
				end

				if count and count > 1 then
					f.stack:SetText(count)
					f.stack:Show()
				else
					f.stack:Hide()
				end

				f:Show()
				f:SetSize(localWidth, localHeight)

				if frameSize < localHeight then
					frameSize = localHeight
				end

				frameIndex = frameIndex + 1
			end
		end
		index = index + 1
	end
	if frameSize > 1 then
		frame:SetSize(frameSize+6, frameSize+6)
	else
		frame:SetSize(frameSize, frameSize)
	end

	for i=frameIndex, 6 do
		frame.icons[i]:Hide()
		NP:AuraIcon_Remove(frame.icons[i])
	end
end

local function FillAuraFramePersonal(frame, unit, filter, nameplate, auratype)

	local index = 1
	local frameIndex = 1
	local frameSize = 1
	local height = E.db.nameplates.stretchTexture and E.db.nameplates.auraSize*0.7 or E.db.nameplates.auraSize
	local width = E.db.nameplates.auraSize

	local isfriend = nameplate.isFriend and not nameplate.canAttack

	local numAuras = isfriend and E.db.nameplates[auratype].friendlynumAuras or E.db.nameplates[auratype].numAuras
	
	local name, rank, texture, count, debuffType, duration, expirationTime, caster, isStealable, nameplateShowPersonal, spellID, _, _, _, nameplateShowAll
	
	while true do

		name, texture, count, debuffType, duration, expirationTime, caster, isStealable, nameplateShowPersonal, spellID, _, _, _, nameplateShowAll = UnitAura(unit, index, filter)

		if not name then break end
		if not frame.icons[frameIndex] then break end
		if frameIndex > numAuras then break end

		local skip = false

		local arg = E.db.nameplates.blacklist[name]
		if arg then
			if arg.checkID then
				if arg.spellID == spellID then
					skip = true;
				end
			else
				skip = true;
			end
		end

		if not skip then
			local localsize = height

			if ( (nameplateShowPersonal and (caster == "player" or caster == "pet" or caster == "vehicle")) ) or ( caster == "player" and  duration and duration < 60 and duration > 0 ) then

				frame.icons[frameIndex].icon:SetTexture(texture)

				UpdateBorderColor(frame.icons[frameIndex], "black")

				if duration and duration > 0 then
					frame.icons[frameIndex].timer:SetText(E.FormatTime(6, expirationTime-GetTime(), true)) --NP:formatTimeRemaining2(expirationTime-GetTime()))
					frame.icons[frameIndex].timer:Show()

					NP:AuraIcon_Add(frame.icons[frameIndex], expirationTime)
				else
					frame.icons[frameIndex].timer:Hide()
					NP:AuraIcon_Remove(frame.icons[frameIndex])
				end

				if count and count > 1 then
					frame.icons[frameIndex].stack:SetText(count)
					frame.icons[frameIndex].stack:Show()
				else
					frame.icons[frameIndex].stack:Hide()
				end

				frame.icons[frameIndex]:Show()
				frame.icons[frameIndex]:SetSize(width, height)

				if frameSize < height then
					frameSize = height
				end

				frameIndex = frameIndex + 1
			end
		end
		index = index + 1
	end
	if frameSize > 1 then
		frame:SetSize(frameSize+6, frameSize+6)
	else
		frame:SetSize(frameSize, frameSize)
	end

	for i=frameIndex, 6 do
		frame.icons[i]:Hide()
		NP:AuraIcon_Remove(frame.icons[i])
	end
end

local function FillAuraFrameHide(frame, unit, filter, nameplate, auratype)
	for i=1, 6 do
		frame.icons[i]:Hide()
		NP:AuraIcon_Remove(frame.icons[i])
	end
end

function NP:UpdateAuras()
	if not self.unit then return end
	if self.plateNamePlate then
		FillAuraFramePersonal(self.DebuffFrame, self.unit, 'HELPFUL|INCLUDE_NAME_PLATE_ONLY', self, 'debuffs')
		FillAuraFrameHide(self.BuffFrame)
	else
		FillAuraFrame(self.DebuffFrame, self.unit, 'HARMFUL|INCLUDE_NAME_PLATE_ONLY', self, 'debuffs')
		FillAuraFrame(self.BuffFrame, self.unit, 'HELPFUL', self, 'buffs')
	end
end

local green =  {0, 1, 0}

local function NamePlate_CastBarOnUpdate(self)


	local color

	if self.castType == 'channel' then
		local curValue

		if self.fader:IsShown() then
			curValue = self:GetValue()
		else
			curValue = self.duration - ( GetTime() - self.startTime )
		end

		if curValue >= 0 then
			self:SetValue(curValue)
			self.time:SetText(E.FormatTime(5, curValue))

			if curValue > 0 and (curValue/self.duration) <= 0.02 then
				color = green
			elseif self.notInterruptible then
				color = E.db.nameplates.castBar_noInterrupt
			else
				color = E.db.nameplates.castBar_color
			end
			local sparkPosition = (curValue / self.duration) * self:GetWidth();
			self.spark:SetPoint("CENTER", self, "LEFT", sparkPosition, 0);

			self:SetStatusBarColor(color[1], color[2], color[3])

			return
		end
	else
		local curValue

		if self.fader:IsShown() then
			curValue = self:GetValue()
		else
			curValue = GetTime() - self.startTime
		end

		if curValue >= 0 and curValue <= self.duration then
			self:SetValue(curValue)
			self.time:SetText(E.FormatTime(5, curValue))

			if curValue > 0 and (curValue/self.duration) >= 0.98 then
				color = green
			elseif self.notInterruptible then
				color = E.db.nameplates.castBar_noInterrupt
			else
				color = E.db.nameplates.castBar_color
			end

			local sparkPosition = (curValue / self.duration) * self:GetWidth();
			self.spark:SetPoint("CENTER", self, "LEFT", sparkPosition, 0);

			self:SetStatusBarColor(color[1], color[2], color[3])

			return
		end
	end

	self.plate:StopCast()
end

function NP:UpdateCast()
	if not self.unit then return end

	if self.plateNamePlate or self.disableBars then
	--	self.castBar.castType = nil
	--	self.castBar.startTime = nil
	--	self.castBar.endTime = nil
	--	self.castBar.notInterruptible = nil
		self.castBar:FadeOut()
		return
	end

	local name, text, texture, startTime, endTime, isTradeSkill, notInterruptible = UnitChannelInfo(self.unit)

	if name then
		self.castBar.castType = 'channel'
		self.castBar.startTime = startTime*0.001
		self.castBar.endTime = endTime*0.001
		self.castBar.duration = ( endTime - startTime ) * 0.001
		self.castBar.notInterruptible = notInterruptible

		self.castBar:SetMinMaxValues(0, self.castBar.duration )
		self.castBar:SetValue(0)
		self.castBar.name:SetText(name)
		self.castBar.icon:SetTexture(texture)

		self.castBar:FadeIn()
		NamePlate_CastBarOnUpdate(self.castBar)
		return
	end

	local name, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible = UnitCastingInfo(self.unit)
	if name then
		self.castBar.castType = 'normal'
		self.castBar.startTime = startTime*0.001
		self.castBar.endTime = endTime*0.001
		self.castBar.duration = ( endTime - startTime ) * 0.001
		self.castBar.notInterruptible = notInterruptible

		self.castBar:SetMinMaxValues(0, self.castBar.duration )
		self.castBar:SetValue(0)
		self.castBar.name:SetText(name)
		self.castBar.icon:SetTexture(texture)

		self.castBar:FadeIn()
		NamePlate_CastBarOnUpdate(self.castBar)
		return
	end

	self:StopCast()
end

function NP:StopCast(notChannel)

	if notChannel and self.castBar.castType == 'channel' then
		return
	end

--	self.castBar.castType = nil
--	self.castBar.startTime = nil
--	self.castBar.endTime = nil
--	self.castBar.notInterruptible = nil

	if self.castBar.endTime and (self.castBar.endTime-0.1) > GetTime() then
		self.castBar:FadeOut(true)
	else
		self.castBar:FadeOut()
	end
end

function NP:UpdateRaidIcon()
	if not self.unit then return end

	local index = GetRaidTargetIndex(self.unit)

	if ( index and raidIndexCoord[index] ) then
		self.raidIcon:Show()
		self.raidIcon:SetTexCoord(raidIndexCoord[index][1], raidIndexCoord[index][2], raidIndexCoord[index][3], raidIndexCoord[index][4])
	else
		self.raidIcon:Hide()
	end
end

function NP:RegisterEvents()

	self:UnregisterAllEvents()

	--print('NAMEPLATES', self.unit)

	if self.disableBars then
		self:RegisterUnitEvent('UNIT_AURA', self.unit)
		self:RegisterUnitEvent('UNIT_NAME_UPDATE', self.unit)
		self:RegisterUnitEvent('UNIT_FACTION', self.unit)
		self:RegisterUnitEvent('UNIT_FLAGS', self.unit)
	else
		self:RegisterUnitEvent('UNIT_AURA', self.unit)

		self:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_START", self.unit)
		self:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_STOP", self.unit)
		self:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_UPDATE", self.unit)
		self:RegisterUnitEvent("UNIT_SPELLCAST_START", self.unit)
		self:RegisterUnitEvent("UNIT_SPELLCAST_DELAYED", self.unit)
		self:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTED", self.unit)
		self:RegisterUnitEvent("UNIT_SPELLCAST_STOP", self.unit)
		self:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", self.unit)
		self:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTIBLE", self.unit)
		self:RegisterUnitEvent("UNIT_SPELLCAST_NOT_INTERRUPTIBLE", self.unit)
	--	self:RegisterEvent("UNIT_SPELLCAST_FAILED")

		self:RegisterUnitEvent('UNIT_HEALTH_FREQUENT', self.unit)
		self:RegisterUnitEvent('UNIT_MAXHEALTH', self.unit)

		self:RegisterUnitEvent('UNIT_ABSORB_AMOUNT_CHANGED', self.unit)
		self:RegisterUnitEvent('UNIT_HEAL_PREDICTION', self.unit)
		self:RegisterUnitEvent('UNIT_HEAL_ABSORB_AMOUNT_CHANGED', self.unit)

		self:RegisterUnitEvent('UNIT_NAME_UPDATE', self.unit)
		self:RegisterUnitEvent('UNIT_FACTION', self.unit)
		self:RegisterUnitEvent('UNIT_FLAGS', self.unit)
	end
end

function NP:SetupPlayerPlate(plate)
	if UnitIsUnit('player', plate.unit) then
		plate.plateNamePlate = true
		NP:SetupPowerBar(plate)
	else
		plate.plateNamePlate = false
		NP:RemovePowerBar(plate)
	end
end

function NP:OnShowUpdate()
	NP:SetupPlayerPlate(self)

	self:UpdateVisibleParts()

	self:UpdateName()
	self:UpdateLevel()
	self:UpdateFaction()
	self:UpdateTargetAlpha()
	self:UpdateFrameLevel()
	self:UpdateHealth()
	self:UpdateAuras()
	self:UpdateCast()
	self:UpdateRaidIcon()
	self:UpdateAggro()
	self:UpdateCastBarPosition()
	self:UpdateDRs('Stun')
	self:UpdateSize()

	E.ClearAnimationCutaway( self )
end


NP.PerClassPowerBar = {
	['WARLOCK'] = {
		powerToken = SPELL_POWER_SOUL_SHARDS,
		maxValue = 5,
		color = { RAID_CLASS_COLORS['WARLOCK'].r, RAID_CLASS_COLORS['WARLOCK'].g, RAID_CLASS_COLORS['WARLOCK'].b, 1 },
	},
}

local hiden = CreateFrame('Frame')
hiden:Hide()

function NP:RemovePowerBar(plate)
	if plate.havePowerBar then
		plate.havePowerBar = false

		if NP.powerBar.parent == plate then
			NP.powerBar:SetParent(hiden)
			NP.powerBar.parent = nil
		end

		plate:SetWidth(plate.defaultWidth)
		plate:SetHeight(plate.defaultHeight)
--		plate:SetPoint('BOTTOMLEFT', plate.owner, 'BOTTOMLEFT', 0, 0)
--		plate:SetPoint('BOTTOMRIGHT', plate.owner, 'BOTTOMRIGHT', 0, 0)
		plate:SetPoint('BOTTOM', plate.owner, 'BOTTOM', 0, 10)

		plate.DebuffFrame:UpdatePosition()
	end
end

function NP:UpdatePowerBar()
	local maxV = UnitPowerMax("player", NP.powerBar.powerToken)
	self:SetMinMaxValues(0, NP.powerBar.maxValue or maxV or 100)
	self:SetValue(UnitPower("player", NP.powerBar.powerToken))
end

function NP:SetupPowerBar(plate)

	if not NP.powerBar then
		NP.powerBar = CreateFrame('StatusBar')
		NP.powerBar:RegisterUnitEvent("UNIT_POWER_FREQUENT", "player", '');
		NP.powerBar:SetScript('OnEvent', NP.UpdatePowerBar)
		NP.powerBar:SetScript('OnShow', NP.UpdatePowerBar)
		NP:CreateBackdrop(NP.powerBar)
	end

	if not plate.havePowerBar or NP.powerBar.parent ~= plate then
		plate.havePowerBar = true

		NP.UpdatePowerBar(NP.powerBar)

		NP.powerBar:SetParent(plate)

		NP.powerBar.parent = plate

		plate.sizer:Hide()

		plate:SetHeight(5)
		plate:SetWidth(plate.defaultWidth)

		plate.DebuffFrame:UpdatePosition()

	--	plate.DebuffFrame:SetPoint("BOTTOMLEFT", plate, 'TOPLEFT', 0, 2)
	--	plate.DebuffFrame:SetPoint("BOTTOMRIGHT", plate, 'TOPRIGHT', 0, 2)

	--	plate:SetPoint('BOTTOMLEFT', plate.owner, 'BOTTOMLEFT', 0, 5)
	--	plate:SetPoint('BOTTOMRIGHT', plate.owner, 'BOTTOMRIGHT', 0, 5)
		plate:SetPoint('BOTTOM', plate.owner, 'BOTTOM', 0, -40)

		NP.powerBar:SetPoint('TOPLEFT', plate, 'BOTTOMLEFT', 0, 0)
		NP.powerBar:SetPoint('TOPRIGHT', plate, 'BOTTOMRIGHT', 0, 0)
		NP.powerBar:SetSize(5, 5)

		NP.powerBar:SetStatusBarTexture(E:GetTexture(E.db.nameplates.healthBar_texture))

		if NP.PerClassPowerBar[E.myclass] then
			local color = NP.PerClassPowerBar[E.myclass].color or UF:PowerColorRGB("player")
			NP.powerBar:SetStatusBarColor(color[1], color[2], color[3])

			NP.powerBar.powerToken = NP.PerClassPowerBar[E.myclass].powerToken or UnitPowerType('player')
			NP.powerBar.maxValue = NP.PerClassPowerBar[E.myclass].maxValue
		else
			local color = UF:PowerColorRGB("player")

			NP.powerBar:SetStatusBarColor(color[1], color[2], color[3])
			NP.powerBar.powerToken = UnitPowerType('player')
			NP.powerBar.maxValue = nil
		end
	end
end



function NP.SetTargetWidth(self)
	if not self.isTarget then
		self.isTarget = true
		self.sizer.scaleTo = 100
		self.sizer.scaleValue = self.sizer.scaleValue or 0
		self.sizer.to = E.db.nameplates.healthBar_width
		self.sizer.to2 = E.db.nameplates.healthBar_height
		self.sizer:Show()
	end
end


function NP.SetNormalWidth(self)
	if self.isTarget then
		self.isTarget = false
		self.sizer.scaleTo = 0
		self.sizer.scaleValue = self.sizer.scaleValue or 0
		self.sizer.to = self.defaultWidth
		self.sizer.to2 = self.defaultHeight
		self.sizer:Show()
	end
end

local ThreatStatusColor = {
	[0] = { 0.7, 0.7, 0.7 },
	[1] = { 1, 1, 0.47 },
	[2] = { 1, 0.5, 0 },
	[3] = { 1, 0.3, 0.3 },
}
function NP.UpdateAggro(self)
	local status = UnitThreatSituation('player', self.unit)

	if (status and status > 0) then
		self.glowIndicator:SetBackdropBorderColor(ThreatStatusColor[status][1], ThreatStatusColor[status][2], ThreatStatusColor[status][3])
		self.glowIndicator:Show()
	else
		self.glowIndicator:Hide()
	end

	local isTanking = UnitDetailedThreatSituation('player', self.unit)

	if self.isPlayer then
		self.nameText:SetTextColor(1,1,1,1)
	else
		if isTanking then
			self.nameText:SetTextColor(1,0.5,0.5,1)
		elseif false and status and status > 0 then
			self.nameText:SetTextColor(ThreatStatusColor[status][1], ThreatStatusColor[status][2], ThreatStatusColor[status][3],1)
		else
			self.nameText:SetTextColor(1,1,1,1)
		end
	end
end

local NamePlate_DRBarOnUpdate = function(self, elapsed)
	local guid = self.plate.guid

	if not guid then
		self.dr = nil

		self:Hide()
		return
	end

	if self.disableBars then
		self:Hide()
		return
	end

	if not E.StunTimer[guid] or E.StunTimer[guid] < GetTime() then
		E.StunTimer[guid] = nil
		E.StunDRs[guid] = 1
		self.dr = nil

		self:Hide()
		return
	end

	if self.dr ~= E.StunDRs[guid]  then
		if E.StunDRs[guid] == 0.25 then
			self.time:SetText('25')
			self:SetStatusBarColor(0.9,0.4,0.2,1)
		elseif E.StunDRs[guid] == 0.5 then
			self.time:SetText('50')
			self:SetStatusBarColor(0.9,0.9,0.2,1)
		elseif E.StunDRs[guid] == 1 then
			self.time:SetText('100')
			self:SetStatusBarColor(0.9,0.9,0.9,1)
		elseif E.StunDRs[guid] < 0.25 then
			self.time:SetText('imm')
			self:SetStatusBarColor(0.9,0.2,0.2,1)
		end
	end

	self.dr = E.StunDRs[guid]

	self:SetValue(E.StunTimer[guid]-GetTime())

	local sparkPosition = ( (E.StunTimer[guid]-GetTime()) / 18) * self:GetWidth();
	self.spark:SetPoint("CENTER", self, "LEFT", sparkPosition, 0);
end

function NP.UpdateDRs(self, text)
	if not self.drBar then 
		return 
	end
	
	local guid = self.guid

	if self.disableBars then
		self.drBar:Hide()
		return
	end

	if not E.StunTimer[guid] or E.StunTimer[guid] < GetTime() then
		E.StunTimer[guid] = nil
		E.StunDRs[guid] = 1

		self.drBar:Hide()
		return
	end

	self.drBar:Show()
	self.drBar.name:SetText(text)
	self.drBar.time:SetText('100')
end

function NP.UpdateNameTextWidth(self)
	if E.db.nameplates.healthBar_name_widthUpTo == 1 then
		self.nameText:SetWidth(self:GetWidth()-15)
	elseif E.db.nameplates.healthBar_name_widthUpTo == 2 then
		self.nameText:SetWidth(self:GetWidth())
	elseif E.db.nameplates.healthBar_name_widthUpTo == 3 then
		self.nameText:SetWidth(0)
	elseif E.db.nameplates.healthBar_name_widthUpTo == 4 then
		self.nameText:SetWidth(self:GetWidth()-( E.db.nameplates.healthBar_hp_format == 5 and 15 or 25))
	end
end

function NP.UpdateSize(self)
	if self.isMinus then
		local height = 4
		local width = 50

		self.defaultWidth = width
		self.defaultHeight = height

		self.defaultWidthIncrease = E.db.nameplates.healthBar_width - width
		self.defaultHeightIncrease = E.db.nameplates.healthBar_height - height

		self:SetSize(self.defaultWidth, self.defaultHeight)
	else
		self.defaultWidth = E.db.nameplates.healthBar_width*0.8
		self.defaultHeight = E.db.nameplates.healthBar_height*0.9

		self.defaultWidthIncrease = E.db.nameplates.healthBar_width - self.defaultWidth
		self.defaultHeightIncrease = E.db.nameplates.healthBar_height - self.defaultHeight

		self:SetSize(self.defaultWidth, self.defaultHeight)
	end

	self:UpdateNameTextWidth()
end

local enableShowFriendly = true

function NP:UpdateVisibleParts()

	if E.db.nameplates.easyPlatesForFriendly and ( self.isFriend or not self.canAttack ) and not self.plateNamePlate then
		self.disableBars = true

		self.nameText_Friendly:Show()
		self.nameText:Hide()
		self.levelText:Hide()
		self.healthText:Hide()

		self.raidIcon:SetParent(self.FriendlyPlate)
		self.raidIcon:ClearAllPoints()
		self.raidIcon:SetPoint('RIGHT', self.nameText_Friendly, 'LEFT', 0, 0)

		self.BuffFrame:SetParent(self.FriendlyPlate)
		self.DebuffFrame:SetParent(self.FriendlyPlate)
		self.DebuffFrame:UpdatePosition()

		self.personalOffset = 0
	elseif self.plateNamePlate then
		self.disableBars = false

		self.nameText_Friendly:Hide()

		self.levelText:Hide()
		self.nameText:Hide()
		self.healthText:Hide()

		self.raidIcon:SetParent(self)
		self.raidIcon:ClearAllPoints()
		self.raidIcon:SetPoint(E.db.nameplates.raidIcon_attachFrom, self, E.db.nameplates.raidIcon_attachTo, E.db.nameplates.raidIcon_xOffset, E.db.nameplates.raidIcon_yOffset)

		self.BuffFrame:SetParent(self)
		self.DebuffFrame:SetParent(self)
		self.DebuffFrame:UpdatePosition()

		self.personalOffset = 0
	else
		self.disableBars = false

		self.nameText_Friendly:Hide()
		self.nameText:Show()

		if self.isMinus then
			self.levelText:Hide()
			self.healthText:Hide()
		else
			self.levelText:Show()
			self.healthText:Show()
		end

		self.raidIcon:SetParent(self)
		self.raidIcon:ClearAllPoints()
		self.raidIcon:SetPoint(E.db.nameplates.raidIcon_attachFrom, self, E.db.nameplates.raidIcon_attachTo, E.db.nameplates.raidIcon_xOffset, E.db.nameplates.raidIcon_yOffset)

		self.BuffFrame:SetParent(self)
		self.DebuffFrame:SetParent(self)
		self.DebuffFrame:UpdatePosition()

		if self.isFriend or not self.canAttack then
			self.personalOffset = 25
		else
			self.personalOffset = 0
		end
	end

	self:UpdateBasePlatePosition()
	self:UpdateTextPlatePosition()
	self:RegisterEvents()
end

do
    local function SetValueCutaway(self, value)
        if not self:IsVisible() then
            -- passthrough initial calls
            self:orig_anim_SetValue(value)
            return
        end

		if numVisiblePlates > 5 then
			if self.unit and UnitIsUnit(self.unit, 'target') then

			else
				self:orig_anim_SetValue(value)
				return
			end
		end

		local maxValue = select(2,self:GetMinMaxValues())

        if value < self:GetValue() and (self:GetValue()-value)/maxValue > 0.02 then
            if not E.frameIsFading(self.Fader) then
				self.Fader:Show()
                self.Fader:SetPoint(
                    'RIGHT', self, 'LEFT',
                    (self:GetValue() / maxValue) * self:GetWidth(), 0
                )

                -- store original rightmost value
                self.Fader.right = self:GetValue()

                E.frameFade(self.Fader, {
                    mode = 'OUT',
                    timeToFade = .2
                })
            end
        end

        if self.Fader.right and value > self.Fader.right then
            -- stop animation if new value overlaps old end point
            E.frameFadeRemoveFrame(self.Fader)
            self.Fader:SetAlpha(0)
			self.Fader:Hide()
        end

		self.Fader:SetAlpha(0)
        self:orig_anim_SetValue(value)
    end
    local function SetStatusBarColor(self,...)
        self:orig_anim_SetStatusBarColor(...)
        self.Fader:SetVertexColor(...)
    end
    local function SetAnimationCutaway(bar)
        local fader = bar:CreateTexture(nil,'ARTWORK')
		fader:SetDrawLayer('ARTWORK', 3)
        fader:SetTexture('interface/buttons/white8x8')
        fader:SetAlpha(0)

		fader:Hide()

        fader:SetPoint('TOP')
        fader:SetPoint('BOTTOM')
        fader:SetPoint('LEFT', bar.statusBarTexture ,'RIGHT')

        bar.orig_anim_SetValue = bar.SetValue
        bar.SetValue = SetValueCutaway

        bar.orig_anim_SetStatusBarColor = bar.SetStatusBarColor
        bar.SetStatusBarColor = SetStatusBarColor

        bar.Fader = fader
    end
    local function ClearAnimationCutaway(bar)
        if not bar.Fader then return end
        E.frameFadeRemoveFrame(bar.Fader)
        bar.Fader:SetAlpha(0)
		bar.Fader:Hide()
    end
    local function DisableAnimationCutaway(bar)
        ClearAnimationCutaway(bar)

        bar.SetValue = bar.orig_anim_SetValue
        bar.orig_anim_SetValue = nil

        bar.SetStatusBarColor = bar.orig_anim_SetStatusBarColor
        bar.orig_anim_SetStatusBarColor = nil

        bar.Fader = nil
    end

	E.ClearAnimationCutaway = ClearAnimationCutaway
	E.DisableAnimationCutaway = DisableAnimationCutaway
	E.SetAnimationCutaway = SetAnimationCutaway
end

local function SizerOnSizeChanged(self,x,y)
--	print(x,y)
    self.f:SetPoint('CENTER',WorldFrame,'BOTTOMLEFT',floor(x)-100,floor(y)+plateFrameOffset+self.f.personalOffset)
end

function NP.UpdatePosition(self)
	self:ClearAllPoints()

	self.plate.BuffFrame:SetPoint("BOTTOMLEFT", self, 'TOPLEFT', 0, 1)
	self.plate.BuffFrame:SetPoint("BOTTOMRIGHT", self, 'TOPRIGHT', 0, 1)

	if self.plate.disableBars  then
		self:SetPoint("BOTTOMLEFT", self.plate.FriendlyPlate, 'TOPLEFT', 0, 16)
		self:SetPoint("BOTTOMRIGHT", self.plate.FriendlyPlate, 'TOPRIGHT', 0, 16)
	elseif self.plate.havePowerBar then
		self:SetPoint("BOTTOMLEFT", self.plate, 'TOPLEFT', 0, 2)
		self:SetPoint("BOTTOMRIGHT", self.plate, 'TOPRIGHT', 0, 2)
	else
		self:SetPoint("BOTTOMLEFT", self.plate, 'TOPLEFT', 0, 10)
		self:SetPoint("BOTTOMRIGHT", self.plate, 'TOPRIGHT', 0, 10)
	end
end

local min, max = math.min, math.max
function NP.OnSizerUpdate(self, elapsed)
	local rate = GetFramerate()
	local limit = 30/rate

	do
		local value = self.scaleTo
		local cur = self.scaleValue
		local new = cur + min((value-cur)/3, max(value-cur, limit))
		if new ~= new then
			new = value
		end

		self.scaleValue = new
		if (cur == value or abs(new - value) < 2) then
			self.scaleValue = value
			self:Hide()
		end
	end

	self.Scale = self.scaleValue/100

	self.plate:SetWidth(self.plate.defaultWidth + (self.plate.defaultWidthIncrease*self.Scale))
	self.plate:SetHeight(self.plate.defaultHeight + (self.plate.defaultHeightIncrease*self.Scale))

	UpdateHealPrediction(self.plate)

	if self.plate.Fader and self.plate.Fader:IsShown() then
		self.plate.Fader:SetPoint(
			'RIGHT', self.plate, 'LEFT',
			(self.plate.Fader.right / select(2,self.plate:GetMinMaxValues())) * self.plate:GetWidth(), 0
		)
	end

	self.plate:UpdateNameTextWidth()
end

function NP.OnCastBarFader(self, elapsed)
	local alpha = self.castBar:GetAlpha()

	alpha = alpha - elapsed

	if alpha > 0 then
		self.castBar:SetAlpha(alpha)
	else
		self.castBar:SetAlpha(0)
		self.castBar:Hide()
		self:Hide()
	end
end

function NP.CastBarFadeIn(self, reason)
	self.fader:Hide()
	if self.plate.plateNamePlate or self.plate.disableBars then
		self:SetAlpha(0)
		self:Hide()
	else
		self:SetAlpha(1)
		self:Show()
	end
end
function NP.CastBarFadeOut(self, reason)

	if self.plate.plateNamePlate or self.plate.disableBars then
		self:SetAlpha(0)
		self:Hide()
		self.fader:Hide()
	elseif self:IsShown() and not self.fader:IsShown() then
		self:SetAlpha(1)
		self.fader:Show()

		if reason then
			self.name:SetText(L['Interrupted'])
		end
	end
end

function NP.CastBarSkipFade(self)
	self:SetAlpha(0)
	self:Hide()
	self.fader:Hide()
end

function NP.UpdateCastBarPosition(self, style)
	if self.drBar and self.drBar:IsShown() then
		self.castBar:SetPoint('TOPLEFT', self, 'BOTTOMLEFT', 0, (E.db.nameplates.castBar_offset-5))
		self.castBar:SetPoint('TOPRIGHT', self, 'BOTTOMRIGHT', 0, (E.db.nameplates.castBar_offset-5))
	else
		self.castBar:SetPoint('TOPLEFT', self, 'BOTTOMLEFT', 0, E.db.nameplates.castBar_offset)
		self.castBar:SetPoint('TOPRIGHT', self, 'BOTTOMRIGHT', 0, E.db.nameplates.castBar_offset)
	end
end

function NP.UpdateBasePlatePosition(self)
	self:SetPoint('BOTTOM', self:GetParent(), 'BOTTOM', 0, plateFrameOffset+self.personalOffset)
end

function NP.UpdateTextPlatePosition(self)
	self.FriendlyPlate:SetPoint('BOTTOM', self.FriendlyPlate:GetParent(), 'BOTTOM', 0, plateFrameOffsetFriendly+self.personalOffset)
end

function NP.ToggleHitbox(self)
	if ( showHitbox ) then
		self.hitbox_overlay:Show()
	else 
		self.hitbox_overlay:Hide()
	end
end

function NP:CreateNamePlateFrame(frame)
	
	local plate = CreateFrame('StatusBar', nil, WorldFrame)

	if parentToBlizzard then
		plate:SetParent(frame)
		plate:SetIgnoreParentAlpha(true)
	end
--	plate:SetPoint('BOTTOMLEFT', frame, 'BOTTOMLEFT', 0, 0)
--	plate:SetPoint('BOTTOMRIGHT', frame, 'BOTTOMRIGHT', 0, 0)
--	plate:SetPoint('BOTTOM', frame, 'BOTTOM', 0, plateFrameOffset)

	--[==[
	local scaler = CreateFrame('Frame', nil, frame)
	scaler.scale = 1
	scaler:SetScript('OnShow', function(self)
		self.scale = 1
	end)
	scaler:SetScript('OnUpdate', function(self, elapsed)
		if self.scale ~= frame:GetScale() then
			self.scale = frame:GetScale()

			print(self.scale)
		end
	end)
	]==]

	plate.hitbox_overlay = frame:CreateTexture()
	plate.hitbox_overlay:SetAllPoints()
	plate.hitbox_overlay:SetColorTexture(0, 1, 1, 0.3)

	if ( showHitbox ) then
		plate.hitbox_overlay:Show()
	else 
		plate.hitbox_overlay:Hide()
	end

	---------------------
	-- ERT NPA Support --
	---------------------
	--[==[
	if not frame.UnitFrame then
		local UnitFrame = CreateFrame('Frame', nil, UIParent)
		UnitFrame:SetPoint('CENTER', frame, 'CENTER', 0, 0)
	
		UnitFrame.selectionHighlight = CreateFrame('Frame')
		UnitFrame.castBar = CreateFrame('Frame')
		UnitFrame.castBar.Icon = CreateFrame('Frame')
		UnitFrame.castBar.BorderShield = CreateFrame('Frame')

		frame.UnitFrame = UnitFrame
	end
	]==]
	
	plate.personalOffset = 0

	--[==[
	local positioner = CreateFrame('Frame', nil,plate)
    positioner:SetPoint('BOTTOMLEFT',WorldFrame, -100, 0)
    positioner:SetPoint('TOPRIGHT',frame,'CENTER')
    positioner:SetScript('OnSizeChanged',SizerOnSizeChanged)
    positioner.f = plate
	]==]
	plate.owner = frame

	plate:SetAlpha(1)
	plate:SetStatusBarTexture(E.media.default_bar_texture1)
	plate:SetSize(100, 8)
	plate:SetStatusBarColor(0.7, 0, 0, 1)
	plate:SetFrameStrata(baseStrata)
	plate:SetFrameLevel(baseFrameLevel)
	plate:EnableMouse(false)

	plate.statusBarTexture = plate:GetStatusBarTexture()
	plate.statusBarTexture:SetDrawLayer('ARTWORK', 0)

	E.SetAnimationCutaway(plate)
	E.ClearAnimationCutaway(plate)

	local totalHealPrediction = plate:CreateTexture()
		totalHealPrediction:SetTexture([[Interface\Buttons\WHITE8x8]])
		totalHealPrediction:SetDrawLayer('ARTWORK', 1)
		totalHealPrediction:SetPoint('LEFT', plate, 'LEFT', 0, 0)
		totalHealPrediction:SetPoint('TOP', plate, 'TOP', 0, 0)
		totalHealPrediction:SetPoint('BOTTOM', plate, 'BOTTOM', 0, 0)
		totalHealPrediction:SetVertexColor(0, 1, 0)
		totalHealPrediction:SetWidth(0)
		totalHealPrediction:SetHeight(15)

	local totalAbsorb = plate:CreateTexture()
		totalAbsorb:SetTexture([[Interface\Buttons\WHITE8x8]])
		totalAbsorb:SetDrawLayer('ARTWORK', 1)
		totalAbsorb:SetPoint('LEFT', plate, 'LEFT', 0, 0)
		totalAbsorb:SetPoint('TOP', plate, 'TOP', 0, 0)
		totalAbsorb:SetPoint('BOTTOM', plate, 'BOTTOM', 0, 0)
		totalAbsorb:SetVertexColor(0, 190/255, 204/255)
		totalAbsorb:SetWidth(0)
		totalAbsorb:SetHeight(15)

	local totalHealAbsorb = plate:CreateTexture()
	--	totalHealAbsorb:SetTexture([[Interface\Buttons\WHITE8x8]])
		totalHealAbsorb:SetTexture("Interface\\RaidFrame\\Absorb-Fill", true, true);
		totalHealAbsorb:SetDrawLayer('ARTWORK', 1)
		totalHealAbsorb:SetPoint('TOPRIGHT', plate.statusBarTexture, 'TOPRIGHT', 0, 0)
		totalHealAbsorb:SetPoint('BOTTOMRIGHT', plate.statusBarTexture, 'BOTTOMRIGHT', 0, 0)
		totalHealAbsorb:SetVertexColor(255/255, 0, 0, 0.9)
	--	totalHealAbsorb:SetVertexColor(255/255, 74/255, 61/255, 0.15)
		totalHealAbsorb:SetWidth(0)
		totalHealAbsorb:SetHeight(15)

	plate.totalHealAbsorb = totalHealAbsorb
	plate.totalAbsorb = totalAbsorb
	plate.totalHealPrediction = totalHealPrediction

	plate:SetScript('OnEvent', NP.EventHandler)

	plate.sizer = CreateFrame('Frame')
	plate.sizer.plate = plate
	plate.sizer:Hide()
	plate.sizer:SetScript('OnUpdate',  NP.OnSizerUpdate)

	--[==[
	plate.backArt = plate:CreateTexture()
	plate.backArt:SetAllPoints(frame)
	plate.backArt:SetColorTexture(1, 0, 0, 0.4)
	plate.backArt:SetDrawLayer('OVERLAY')
	]==]

	plate.border = CreateFrame('Frame', nil, plate)
--	plate.border:SetFrameStrata("LOW")
	plate.border:SetFrameLevel(plate:GetFrameLevel()-1)

	plate.border.bg = plate.border:CreateTexture()
	plate.border.bg:SetDrawLayer("BORDER", 0)

	plate.glowIndicator = CreateFrame("Frame", nil, plate)
--	plate.glowIndicator:SetFrameStrata("LOW")
	plate.glowIndicator:SetFrameLevel(plate:GetFrameLevel()-2)

	plate.glowIndicator:SetBackdrop({
 		edgeFile = "Interface\\AddOns\\AleaUI\\media\\glow",
		edgeSize = 5,
 	--	insets = {left = 5, right = 5, top = 5, bottom = 5},
 	})
	plate.glowIndicator:SetBackdropBorderColor(0, 1, 0, 1)
--	plate.glowIndicator:SetScale(1)
	plate.glowIndicator:SetPoint("TOPLEFT", plate, "TOPLEFT", -5, 5)
	plate.glowIndicator:SetPoint("BOTTOMRIGHT", plate, "BOTTOMRIGHT", 5, -5)
	plate.glowIndicator:SetAlpha(0.8)
	plate.glowIndicator:Hide()

	plate.overlay = plate:CreateTexture()
	plate.overlay:SetAllPoints()
	plate.overlay:SetColorTexture(1, 1, 1, 0.4)
	plate.overlay:SetDrawLayer('ARTWORK', 1)
	plate.overlay:Hide()

	plate.levelText = plate:CreateFontString()
	plate.levelText:SetFont(E.media.default_font2, 10, 'OUTLINE')
	plate.levelText:SetText('100')
	plate.levelText:SetWidth(30)
	plate.levelText:SetJustifyH('RIGHT')
	plate.levelText:SetPoint('BOTTOMRIGHT', plate, 'BOTTOMRIGHT', 0, 10)
	plate.levelText:SetDrawLayer('ARTWORK', 2)
	plate.levelText:Show()

	plate.nameText = plate:CreateFontString()
	plate.nameText:SetFont(E.media.default_font2, 10, 'OUTLINE')
	plate.nameText:SetText('NameText')
	plate.nameText:SetPoint('BOTTOMLEFT', plate, 'BOTTOMLEFT', 0, 10)
	plate.nameText:SetPoint('RIGHT', plate.levelText, 'LEFT', -1, 0)
	plate.nameText:SetDrawLayer('ARTWORK', 2)
	plate.nameText:SetJustifyH('LEFT')
	plate.nameText:SetWordWrap(false)
	plate.nameText:Show()

	plate.healthText = plate:CreateFontString()
	plate.healthText:SetFont(E.media.default_font2, 10, 'OUTLINE')
	plate.healthText:SetText('100%')
	plate.healthText:SetPoint('CENTER', plate, 'CENTER', 0, 0)
	plate.healthText:SetAllPoints(plate)
	plate.healthText:SetDrawLayer('ARTWORK', 2)
	plate.healthText:SetJustifyH('CENTER')
	plate.healthText:SetWordWrap(false)
	plate.healthText:Show()

	plate.DebuffFrame = CreateFrame('Frame', nil, plate)
	plate.DebuffFrame.plate = plate

	plate.DebuffFrame:SetSize(20, 20)
--	plate.DebuffFrame:SetFrameStrata("LOW")
	plate.DebuffFrame:SetFrameLevel(plate:GetFrameLevel())
	plate.DebuffFrame:SetPoint("BOTTOMLEFT", plate, 'TOPLEFT', 0, 12)
	plate.DebuffFrame:SetPoint("BOTTOMRIGHT", plate, 'TOPRIGHT', 0, 12)
	plate.DebuffFrame.icons = {}

	plate.DebuffFrame.UpdatePosition = NP.UpdatePosition

	for i=1, 6 do
		local iconf = CreateFrame("Frame", nil, plate.DebuffFrame)
		iconf:SetSize(14, 14)
	--	iconf:SetFrameStrata("LOW")
		iconf:SetFrameLevel(plate:GetFrameLevel())

		if i==1 then
			iconf:SetPoint('BOTTOMLEFT', plate.DebuffFrame, 'BOTTOMLEFT', 0, 0)
		else
			iconf:SetPoint('BOTTOMLEFT', plate.DebuffFrame.icons[i-1], 'BOTTOMRIGHT', 3, 0)
		end

		iconf.icon = iconf:CreateTexture(nil, 'ARTWORK')
		iconf.icon:SetAllPoints()
		iconf.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)

	--	iconf.iconbg = iconf:CreateTexture(nil, 'ARTWORK', nil, -1)
	--	iconf.iconbg:SetAllPoints()
	--	iconf.iconbg:SetColorTexture(0,0,0,1)

		iconf.timer = iconf:CreateFontString()
		iconf.timer:SetFont(E.media.default_font2, 10, 'OUTLINE')
		iconf.timer:SetText('10')
		iconf.timer:SetPoint('BOTTOMLEFT', iconf, 'TOPLEFT', 0, -4)
		iconf.timer:SetDrawLayer('ARTWORK', 0)
		iconf.timer:SetJustifyH('LEFT')
		iconf.timer:Show()

		iconf.stack = iconf:CreateFontString()
		iconf.stack:SetFont(E.media.default_font2, 10, 'OUTLINE')
		iconf.stack:SetText('10')
		iconf.stack:SetPoint('BOTTOMRIGHT', iconf, 'BOTTOMRIGHT', 0, -4)
		iconf.stack:SetDrawLayer('ARTWORK', 0)
		iconf.stack:SetJustifyH('RIGHT')
		iconf.stack:Show()

		iconf:Hide()
		NP:CreateBackdrop(iconf)

		plate.DebuffFrame.icons[i] = iconf
	end

	plate.BuffFrame = CreateFrame('Frame', nil, plate)
	plate.BuffFrame:SetSize(20, 20)
--	plate.BuffFrame:SetFrameStrata("LOW")
	plate.BuffFrame:SetFrameLevel(plate:GetFrameLevel())
	plate.BuffFrame:SetPoint("BOTTOMLEFT", plate.DebuffFrame, 'TOPLEFT', 0, 1)
	plate.BuffFrame:SetPoint("BOTTOMRIGHT", plate.DebuffFrame, 'TOPRIGHT', 0, 1)
	plate.BuffFrame.icons = {}
	for i=1, 6 do
		local iconf = CreateFrame("Frame", nil, plate.BuffFrame)
		iconf:SetSize(14, 14)
	--	iconf:SetFrameStrata('LOW')
		iconf:SetFrameLevel(plate:GetFrameLevel())

		if i==1 then
			iconf:SetPoint('BOTTOMRIGHT', plate.BuffFrame, 'BOTTOMRIGHT', 0, 0)
		else
			iconf:SetPoint('BOTTOMRIGHT', plate.BuffFrame.icons[i-1], 'BOTTOMLEFT', -3, 0)
		end

		iconf.icon = iconf:CreateTexture(nil, 'ARTWORK')
		iconf.icon:SetAllPoints()
		iconf.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)

	--	iconf.iconbg = iconf:CreateTexture(nil, 'ARTWORK', nil, -1)
	--	iconf.iconbg:SetAllPoints()
	--	iconf.iconbg:SetColorTexture(0,0,0,1)

		iconf.timer = iconf:CreateFontString()
		iconf.timer:SetFont(E.media.default_font2, 10, 'OUTLINE')
		iconf.timer:SetText('10')
		iconf.timer:SetPoint('BOTTOMLEFT', iconf, 'TOPLEFT', 0, -4)
		iconf.timer:SetDrawLayer('ARTWORK', 0)
		iconf.timer:SetJustifyH('LEFT')
		iconf.timer:Show()

		iconf.stack = iconf:CreateFontString()
		iconf.stack:SetFont(E.media.default_font2, 10, 'OUTLINE')
		iconf.stack:SetText('10')
		iconf.stack:SetPoint('BOTTOMRIGHT', iconf, 'BOTTOMRIGHT', 0, -4)
		iconf.stack:SetDrawLayer('ARTWORK', 0)
		iconf.stack:SetJustifyH('RIGHT')
		iconf.stack:Show()

		iconf:Hide()

		NP:CreateBackdrop(iconf)

		plate.BuffFrame.icons[i] = iconf
	end

	-- Dragon Border
	plate.eliteIcon = plate:CreateTexture(nil, 'ARTWORK', nil, 3)
	plate.eliteIcon:SetSize(42.602336883545*1.3, 31.154767990112*1.3)
	plate.eliteIcon:SetTexture([[Interface\Tooltips\EliteNameplateIcon]])
	plate.eliteIcon:Hide()
	plate.eliteIcon:SetPoint("RIGHT", plate, "RIGHT", 37, -4)

	-- Raid mark
	plate.raidIcon = plate:CreateTexture(nil, 'ARTWORK')
	plate.raidIcon:SetSize(26, 26)
	plate.raidIcon:SetTexture([[Interface\TargetingFrame\UI-RaidTargetingIcons]])
	plate.raidIcon:Hide()
	plate.raidIcon:SetPoint(E.db.nameplates.raidIcon_attachFrom, plate, E.db.nameplates.raidIcon_attachTo, E.db.nameplates.raidIcon_xOffset, E.db.nameplates.raidIcon_yOffset)

	--CastBar
	plate.castBar = CreateFrame("StatusBar", nil, plate)
	plate.castBar.plate = plate
	plate.castBar:SetPoint('TOPLEFT', plate, 'BOTTOMLEFT', 0, E.db.nameplates.castBar_offset)
	plate.castBar:SetPoint('TOPRIGHT', plate, 'BOTTOMRIGHT', 0, E.db.nameplates.castBar_offset)
--	plate.castBar:SetFrameStrata('LOW')
	plate.castBar:SetFrameLevel(plate:GetFrameLevel())

	plate.castBar:SetScript('OnUpdate', NamePlate_CastBarOnUpdate)
	plate.castBar:Hide()
	plate.castBar:SetScript('OnSizeChanged', NamePlate_CastBarOnUpdate)

	plate.castBar.fader = CreateFrame('Frame', nil, plate.castBar)
	plate.castBar.fader:Hide()
	plate.castBar.fader.castBar = plate.castBar
	plate.castBar.fader:SetScript('OnUpdate', NP.OnCastBarFader)

	plate.castBar.FadeIn = NP.CastBarFadeIn
	plate.castBar.FadeOut = NP.CastBarFadeOut
	plate.castBar.SkipFade = NP.CastBarSkipFade

	--NP:CreateBackdrop(plate.castBar)

	plate.castBar.border = CreateFrame('Frame', nil, plate.castBar)
	plate.castBar.border:SetFrameLevel(plate.castBar:GetFrameLevel()-1)

	plate.castBar.border.bg = plate.castBar.border:CreateTexture()
	plate.castBar.border.bg:SetDrawLayer("BORDER", 0)

	plate.castBar.time = plate.castBar:CreateFontString(nil, 'OVERLAY')
	plate.castBar.time:SetPoint("TOPRIGHT", plate.castBar, "BOTTOMRIGHT", 6, -2)
	plate.castBar.time:SetJustifyH("RIGHT")
	plate.castBar.time:SetWordWrap(false)

	plate.castBar.name = plate.castBar:CreateFontString(nil, 'OVERLAY')
	plate.castBar.name:SetPoint("TOPLEFT", plate.castBar, "BOTTOMLEFT", 0, -2)
	plate.castBar.name:SetPoint("TOPRIGHT", plate.castBar.time, "TOPLEFT", 0, -2)
	plate.castBar.name:SetJustifyH("LEFT")
	plate.castBar.name:SetWordWrap(false)

	plate.castBar.icon = plate.castBar:CreateTexture(nil, 'OVERLAY')
	plate.castBar.icon:SetTexCoord(.07, .93, .07, .93)
	plate.castBar.icon:SetDrawLayer("OVERLAY")
	plate.castBar.icon:SetPoint("TOPLEFT", plate, "TOPRIGHT", 5, 0)

	plate.castBar.icon.border = CreateFrame('Frame', nil, plate.castBar)
	plate.castBar.icon.border:SetFrameLevel(plate.castBar:GetFrameLevel()-1)

	plate.castBar.icon.border.bg = plate.castBar.icon.border:CreateTexture()
	plate.castBar.icon.border.bg:SetDrawLayer("BORDER", 0)


--	NP:CreateBackdrop(plate.castBar, plate.castBar.icon)

	plate.castBar.spark = plate.castBar:CreateTexture(nil, "OVERLAY")
	plate.castBar.spark:SetTexture([[Interface\CastingBar\UI-CastingBar-Spark]])
	plate.castBar.spark:SetBlendMode("ADD")
	plate.castBar.spark:SetDrawLayer("OVERLAY", 2)
	plate.castBar.spark:SetSize(15, 15)

	-- Opts
	plate.castBar:SetSize(100, 6)
	plate.castBar:SetStatusBarTexture(E.media.default_bar_texture1)
	plate.castBar.time:SetFont(E.media.default_font2, 10, 'OUTLINE')
	plate.castBar.name:SetFont(E.media.default_font2, 10, 'OUTLINE')
	plate.castBar.icon:SetSize(6 + 10 + 5, 6 + 10 + 5)

	plate.UpdateCastBarPosition = NP.UpdateCastBarPosition
	
	
	--[==[
	plate.drBar = CreateFrame("StatusBar", nil, plate)
	plate.drBar.plate = plate
	plate.drBar:SetPoint('TOPLEFT', plate, 'BOTTOMLEFT', 16, -2)
	plate.drBar:SetPoint('TOPRIGHT', plate, 'BOTTOMRIGHT', 0, -2)
	plate.drBar:SetFrameLevel(plate:GetFrameLevel())
	plate.drBar:SetMinMaxValues(0, 18)
	plate.drBar:SetScript('Onupdate', NamePlate_DRBarOnUpdate)
	plate.drBar:SetScript('OnSizeChanged', NamePlate_DRBarOnUpdate)
	plate.drBar:SetScript('OnShow', function(self)
		plate:UpdateCastBarPosition()
	end)
	plate.drBar:SetScript('OnHide', function(self)
		plate:UpdateCastBarPosition()
	end)
	plate.drBar:Hide()

	plate.drBar.bg = plate.drBar:CreateTexture(nil, 'BACKGROUND', nil, -1)
	plate.drBar.bg:SetAllPoints()
	plate.drBar.bg:SetColorTexture(0,0,0,0.6)

	plate.drBar.time = plate.drBar:CreateFontString(nil, 'OVERLAY')
	plate.drBar.time:SetPoint("BOTTOMLEFT", plate.drBar, "BOTTOMRIGHT", 2, 0)
	plate.drBar.time:SetJustifyH("RIGHT")
	plate.drBar.time:SetWordWrap(false)
	plate.drBar.time:Hide()

	plate.drBar.name = plate.drBar:CreateFontString(nil, 'OVERLAY')
	plate.drBar.name:SetPoint("RIGHT", plate.drBar, "LEFT", -2, 0)
	plate.drBar.name:SetJustifyH("RIGHT")
	plate.drBar.name:SetWordWrap(false)

	plate.drBar:SetSize(100, 3)
	plate.drBar:SetStatusBarTexture(E.media.default_bar_texture1)
	plate.drBar:SetStatusBarColor(0.9,0.9,0.9,1)
	plate.drBar.time:SetFont("Fonts\\ARIALN.TTF", 8, 'NONE')
	plate.drBar.name:SetFont("Fonts\\ARIALN.TTF", 8, 'NONE')
	plate.drBar.name:SetShadowColor(0,0,0)
	plate.drBar.name:SetShadowOffset(1, -1)

	plate.drBar.spark = plate.drBar:CreateTexture(nil, "OVERLAY")
	plate.drBar.spark:SetTexture([[Interface\CastingBar\UI-CastingBar-Spark]])
	plate.drBar.spark:SetBlendMode("ADD")
	plate.drBar.spark:SetDrawLayer("OVERLAY", 2)
	plate.drBar.spark:SetSize(10, 15)
	]==]
	--[==[
	plate.drBar.icon = plate.drBar:CreateTexture(nil, 'OVERLAY')
	plate.drBar.icon:SetTexCoord(.07, .93, .07, .93)
	plate.drBar.icon:SetDrawLayer("OVERLAY")
	plate.drBar.icon:SetPoint("TOPLEFT", plate, "TOPRIGHT", 5, 0)
	NP:CreateBackdrop(plate.drBar, plate.drBar.icon)
	]==]

	local FriendlyPlate = CreateFrame('StatusBar', nil, WorldFrame)
	if parentToBlizzard then
		FriendlyPlate:SetParent(frame)
		FriendlyPlate:SetIgnoreParentAlpha(true)
	end

	FriendlyPlate:SetSize(40,1)
	FriendlyPlate:SetPoint('BOTTOM', frame, 'BOTTOM', 0, 0)
	FriendlyPlate:SetFrameStrata(baseStrata)
	FriendlyPlate:SetFrameLevel(plate:GetFrameLevel())
	FriendlyPlate:SetScale(UIParent:GetEffectiveScale())

	FriendlyPlate.personalOffset = 0

	plate.FriendlyPlate = FriendlyPlate


	--[==[
	local positioner = CreateFrame('Frame', nil,FriendlyPlate)
    positioner:SetPoint('BOTTOMLEFT',WorldFrame, -100, 0)
    positioner:SetPoint('TOPRIGHT',frame,'CENTER')
    positioner:SetScript('OnSizeChanged',SizerOnSizeChanged)
    positioner.f = FriendlyPlate
	]==]

	plate.FriendlyPlate.textParent = CreateFrame('Frame', nil, plate.FriendlyPlate)
	plate.FriendlyPlate.textParent:SetAlpha(baseNonTargetAlpha)

	plate.nameText_Friendly = plate.FriendlyPlate.textParent:CreateFontString()
	plate.nameText_Friendly:SetFont(E.media.default_font2, 10, 'OUTLINE')
	plate.nameText_Friendly:SetText('NameText')
	plate.nameText_Friendly:SetPoint('BOTTOM', FriendlyPlate, 'BOTTOM', 0, 0)
	plate.nameText_Friendly:SetDrawLayer('ARTWORK', 2)
	plate.nameText_Friendly:SetJustifyH('LEFT')
	plate.nameText_Friendly:SetWordWrap(false)
	plate.nameText_Friendly:Hide()
	
	plate.UpdateLevel = NP.UpdateLevel
	plate.UpdateFaction = NP.UpdateFaction
	plate.UpdateName = NP.UpdateName
	plate.OnShowUpdate = NP.OnShowUpdate
	plate.UpdateTargetAlpha = NP.UpdateTargetAlpha
	plate.UpdateFrameLevel = NP.UpdateFrameLevel
	plate.UpdateHealth = NP.UpdateHealth
	plate.UpdateAuras = NP.UpdateAuras
	plate.UpdateCast = NP.UpdateCast
	plate.StopCast = NP.StopCast
	plate.UpdateRaidIcon = NP.UpdateRaidIcon
	plate.SetTargetWidth = NP.SetTargetWidth
	plate.SetNormalWidth = NP.SetNormalWidth
	plate.UpdateAggro = NP.UpdateAggro
	plate.UpdateDRs = NP.UpdateDRs
	plate.UpdateVisibleParts = NP.UpdateVisibleParts
	plate.RegisterEvents = NP.RegisterEvents
	plate.UpdateNameTextWidth = NP.UpdateNameTextWidth
	plate.UpdateSize = NP.UpdateSize
	plate.UpdateBasePlatePosition = NP.UpdateBasePlatePosition
	plate.UpdateTextPlatePosition = NP.UpdateTextPlatePosition
	plate.ToggleHitbox = NP.ToggleHitbox

	plate.ThrottledUpdateAggro = function()
		print('ThrottledUpdateAggro', plate, plate.unit)
	end

--	NP:CreateBackdrop(plate)

	--[==[
	plate._testBar = CreateFrame('Frame', nil, frame)
	plate._testBar:SetSize(200, 18)
	plate._testBar:SetPoint('BOTTOM', frame, 'TOP', 0, 40)
	plate._testBar.texture = plate._testBar:CreateTexture()
	plate._testBar.texture:SetColorTexture(1,1,1,0.8)
	plate._testBar.texture:SetAllPoints()
	plate._testBar:SetScale(UIParent:GetEffectiveScale())
	]==]

	plate:SetScale(UIParent:GetEffectiveScale())
	NP.CreatedPlates[#NP.CreatedPlates+1] = plate

	frame.AleaNP = plate
	
	
	if frame.UnitFrame and not frame.AleaNP.onShowHooked then
		frame.UnitFrame:HookScript("OnShow", function(self)
			self:Hide() --Hide Blizzard's Nameplate
		end)
		--print('Hooked on NAME_PLATE_CREATED')
		frame.AleaNP.onShowHooked = true
	end
	
	
	NP.UpdateSettings(plate)
end

function NP.UpdateSettings(plate)

	local font = E:GetFont(E.db.nameplates.font)
	local friendlyFont = E:GetFont(E.db.nameplates.friendlyFont)

	local fontSize = E.db.nameplates.fontSize

	local horizontalScale = tonumber(GetCVar("NamePlateHorizontalScale"))

	plate.defaultWidth = E.db.nameplates.healthBar_width*0.8
	plate.defaultHeight = E.db.nameplates.healthBar_height*0.9

	plate.defaultWidthIncrease = E.db.nameplates.healthBar_width - plate.defaultWidth
	plate.defaultHeightIncrease = E.db.nameplates.healthBar_height - plate.defaultHeight

	plate:SetSize(plate.defaultWidth, plate.defaultHeight)

	local modif = plate.defaultHeight/15

	plate.eliteIcon:SetPoint("RIGHT", plate, "RIGHT", 37*modif, -4)
	plate.eliteIcon:SetSize(42.602336883545*1.3*modif, 31.154767990112*1.3*modif)

	plate:SetStatusBarTexture(E:GetTexture(E.db.nameplates.healthBar_texture))

	plate.totalHealPrediction:SetTexture(E:GetTexture(E.db.nameplates.healthBar_texture))
	plate.totalHealPrediction:SetVertexColor(E.db.unitframes.colors.otherHeal[1],
		E.db.unitframes.colors.otherHeal[2],E.db.unitframes.colors.otherHeal[3],E.db.unitframes.colors.otherHeal[4])
	plate.totalHealPrediction:SetHeight(E.db.nameplates.healthBar_height)

	plate.totalAbsorb:SetTexture(E:GetTexture(E.db.nameplates.healthBar_texture))
	plate.totalAbsorb:SetVertexColor(E.db.unitframes.colors.otherAbsorb[1],
		E.db.unitframes.colors.otherAbsorb[2],E.db.unitframes.colors.otherAbsorb[3],E.db.unitframes.colors.otherAbsorb[4])
	plate.totalAbsorb:SetHeight(E.db.nameplates.healthBar_height)

	plate.totalHealAbsorb:SetVertexColor(E.db.unitframes.colors.myHealAbsorb[1],
		E.db.unitframes.colors.myHealAbsorb[2],E.db.unitframes.colors.myHealAbsorb[3],E.db.unitframes.colors.myHealAbsorb[4])
	plate.totalHealAbsorb:SetHeight(E.db.nameplates.healthBar_height)

--	plate:SetBorderColor(E.db.nameplates.bordercolor[1], E.db.nameplates.bordercolor[2],E.db.nameplates.bordercolor[3],E.db.nameplates.bordercolor[4])
--	plate.backdrop:SetColorTexture(E.db.nameplates.backdropfadecolor[1], E.db.nameplates.backdropfadecolor[2],E.db.nameplates.backdropfadecolor[3],E.db.nameplates.backdropfadecolor[4])

--	print('Test', 'multi', multi)

	plate.border:SetBackdrop({
	  edgeFile = E:GetBorder(E.db.nameplates.borderTexture),
	  edgeSize = E.db.nameplates.borderSize,
	})
	plate.border:SetBackdropBorderColor(E.db.nameplates.bordercolor[1], E.db.nameplates.bordercolor[2],E.db.nameplates.bordercolor[3],E.db.nameplates.bordercolor[4])
	plate.border:SetPoint("TOPLEFT", plate, "TOPLEFT", E.db.nameplates.borderInset, -E.db.nameplates.borderInset)
	plate.border:SetPoint("BOTTOMRIGHT", plate, "BOTTOMRIGHT", -E.db.nameplates.borderInset, E.db.nameplates.borderInset)

	plate.border.bg:SetTexture(E:GetTexture(E.db.nameplates.background_texture))
	plate.border.bg:SetVertexColor(E.db.nameplates.backdropfadecolor[1], E.db.nameplates.backdropfadecolor[2],E.db.nameplates.backdropfadecolor[3],E.db.nameplates.backdropfadecolor[4])
	plate.border.bg:SetPoint("TOPLEFT", plate.border, "TOPLEFT", E.db.nameplates.backgroundInset, -E.db.nameplates.backgroundInset)
	plate.border.bg:SetPoint("BOTTOMRIGHT", plate.border, "BOTTOMRIGHT", -E.db.nameplates.backgroundInset, E.db.nameplates.backgroundInset)

	plate.nameText:ClearAllPoints()
	plate.nameText:SetFont(font, fontSize, E.db.nameplates.fontOutline)

	plate.nameText:SetPoint(E.db.nameplates.healthBar_name_attachTo, plate, E.db.nameplates.healthBar_name_attachTo, E.db.nameplates.healthBar_name_xOffset, E.db.nameplates.healthBar_name_yOffset)
	plate:UpdateNameTextWidth()

	plate.nameText_Friendly:SetFont(friendlyFont, E.db.nameplates.friendlyFontSize, E.db.nameplates.friendlyFontOutline)

	plate.levelText:ClearAllPoints()
	plate.levelText:SetFont(font, fontSize, E.db.nameplates.fontOutline)
	plate.levelText:SetWidth(0)
	plate.levelText:SetPoint(E.db.nameplates.healthBar_lvl_attachTo, plate, E.db.nameplates.healthBar_lvl_attachTo, E.db.nameplates.healthBar_lvl_xOffset, E.db.nameplates.healthBar_lvl_yOffset)

	plate.healthText:ClearAllPoints()
	plate.healthText:SetFont(font, fontSize, E.db.nameplates.fontOutline)
	plate.healthText:SetPoint(E.db.nameplates.healthBar_hp_attachTo, plate, E.db.nameplates.healthBar_hp_attachTo, E.db.nameplates.healthBar_hp_xOffset, E.db.nameplates.healthBar_hp_yOffset)

	plate.castBar:SetSize(E.db.nameplates.healthBar_width, E.db.nameplates.castBar_height)
	plate.castBar:SetStatusBarTexture(E:GetTexture(E.db.nameplates.healthBar_texture))
	plate.castBar.time:SetFont(font, fontSize, E.db.nameplates.fontOutline)
	plate.castBar.name:SetFont(font, fontSize, E.db.nameplates.fontOutline)
	plate.castBar.icon:SetSize(E.db.nameplates.castBar_height + E.db.nameplates.healthBar_height + 3, E.db.nameplates.castBar_height + E.db.nameplates.healthBar_height + 3)

	plate.castBar.icon.border:SetBackdrop({
	  edgeFile = E:GetBorder(E.db.nameplates.castBar_borderTexture),
	  edgeSize = E.db.nameplates.castBar_borderSize,
	})
	plate.castBar.icon.border:SetBackdropBorderColor(E.db.nameplates.castBar_bordercolor[1], E.db.nameplates.castBar_bordercolor[2],E.db.nameplates.castBar_bordercolor[3],E.db.nameplates.castBar_bordercolor[4])
	plate.castBar.icon.border:SetPoint("TOPLEFT", plate.castBar.icon, "TOPLEFT", E.db.nameplates.castBar_borderInset, -E.db.nameplates.castBar_borderInset)
	plate.castBar.icon.border:SetPoint("BOTTOMRIGHT", plate.castBar.icon, "BOTTOMRIGHT", -E.db.nameplates.castBar_borderInset, E.db.nameplates.castBar_borderInset)

	plate.castBar.icon.border.bg:SetTexture(E:GetTexture(E.db.nameplates.castBar_background_texture))
	plate.castBar.icon.border.bg:SetVertexColor(E.db.nameplates.castBar_background[1], E.db.nameplates.castBar_background[2],E.db.nameplates.castBar_background[3],E.db.nameplates.castBar_background[4])
	plate.castBar.icon.border.bg:SetPoint("TOPLEFT", plate.castBar.icon.border, "TOPLEFT", E.db.nameplates.castBar_backgroundInset, -E.db.nameplates.castBar_backgroundInset)
	plate.castBar.icon.border.bg:SetPoint("BOTTOMRIGHT", plate.castBar.icon.border, "BOTTOMRIGHT", -E.db.nameplates.castBar_backgroundInset, E.db.nameplates.castBar_backgroundInset)


	plate.castBar.border:SetBackdrop({
	  edgeFile = E:GetBorder(E.db.nameplates.castBar_borderTexture),
	  edgeSize = E.db.nameplates.castBar_borderSize,
	})
	plate.castBar.border:SetBackdropBorderColor(E.db.nameplates.castBar_bordercolor[1], E.db.nameplates.castBar_bordercolor[2],E.db.nameplates.castBar_bordercolor[3],E.db.nameplates.castBar_bordercolor[4])
	plate.castBar.border:SetPoint("TOPLEFT", plate.castBar, "TOPLEFT", E.db.nameplates.castBar_borderInset, -E.db.nameplates.castBar_borderInset)
	plate.castBar.border:SetPoint("BOTTOMRIGHT", plate.castBar, "BOTTOMRIGHT", -E.db.nameplates.castBar_borderInset, E.db.nameplates.castBar_borderInset)

	plate.castBar.border.bg:SetTexture(E:GetTexture(E.db.nameplates.castBar_background_texture))
	plate.castBar.border.bg:SetVertexColor(E.db.nameplates.castBar_background[1], E.db.nameplates.castBar_background[2],E.db.nameplates.castBar_background[3],E.db.nameplates.castBar_background[4])
	plate.castBar.border.bg:SetPoint("TOPLEFT", plate.castBar.border, "TOPLEFT", E.db.nameplates.castBar_backgroundInset, -E.db.nameplates.castBar_backgroundInset)
	plate.castBar.border.bg:SetPoint("BOTTOMRIGHT", plate.castBar.border, "BOTTOMRIGHT", -E.db.nameplates.castBar_backgroundInset, E.db.nameplates.castBar_backgroundInset)

	plate.castBar:SetPoint('TOPLEFT', plate, 'BOTTOMLEFT', 0, E.db.nameplates.castBar_offset)
	plate.castBar:SetPoint('TOPRIGHT', plate, 'BOTTOMRIGHT', 0, E.db.nameplates.castBar_offset)

	local iconSize = E.db.nameplates.castBar_height + E.db.nameplates.healthBar_height + E.db.nameplates.castBar_offset
	plate.castBar.icon:SetSize(iconSize,iconSize)

--	castBar_bordercolor = { .06, .06, .06,  0.3 },
--	castBar_background  = { 0,0,0,1 },



	local sparkMod = 10/15*E.db.nameplates.castBar_height

	plate.castBar.spark:SetSize(10,15)

	plate.raidIcon:ClearAllPoints()
	if plate.disableBars then
		plate.raidIcon:SetPoint('RIGHT', plate.nameText_Friendly, 'LEFT', 0, 0)
	else
		plate.raidIcon:SetPoint(E.db.nameplates.raidIcon_attachFrom, plate, E.db.nameplates.raidIcon_attachTo, E.db.nameplates.raidIcon_xOffset, E.db.nameplates.raidIcon_yOffset)
	end

	local stretch = E.db.nameplates.stretchTexture and 0.7 or 1
	local stretchTex = E.db.nameplates.stretchTexture and 0.2 or 0

	for i=1, 6 do
		plate.DebuffFrame.icons[i].icon:SetTexCoord(0.07, 0.93, 0.07+stretchTex, 0.93-stretchTex)
		plate.DebuffFrame.icons[i]:SetSize(E.db.nameplates.auraSize, ceil(E.db.nameplates.auraSize*stretch))
		plate.DebuffFrame.icons[i].timer:SetFont(font, fontSize, E.db.nameplates.fontOutline)
		plate.DebuffFrame.icons[i].stack:SetFont(font, fontSize, E.db.nameplates.fontOutline)

		plate.BuffFrame.icons[i].icon:SetTexCoord(0.07, 0.93, 0.07+stretchTex, 0.93-stretchTex)
		plate.BuffFrame.icons[i]:SetSize(E.db.nameplates.auraSize, ceil(E.db.nameplates.auraSize*stretch+0.5))
		plate.BuffFrame.icons[i].timer:SetFont(font, fontSize, E.db.nameplates.fontOutline)
		plate.BuffFrame.icons[i].stack:SetFont(font, fontSize, E.db.nameplates.fontOutline)
	end


	if NP.powerBar then
		NP.powerBar.backdrop:SetColorTexture(unpack(E.db.nameplates.backdropfadecolor))
		NP.powerBar.bordertop:SetColorTexture(unpack(E.db.nameplates.bordercolor))
		NP.powerBar.borderbottom:SetColorTexture(unpack(E.db.nameplates.bordercolor))
		NP.powerBar.borderleft:SetColorTexture(unpack(E.db.nameplates.bordercolor))
		NP.powerBar.borderright:SetColorTexture(unpack(E.db.nameplates.bordercolor))
	end

end

local function SetBorderColor(self, r, g, b,a)
	self.bordertop:SetColorTexture(r, g, b,a)
	self.borderbottom:SetColorTexture(r, g, b,a)
	self.borderleft:SetColorTexture(r, g, b,a)
	self.borderright:SetColorTexture(r, g, b,a)
end

function NP:CreateBackdrop(parent, point)
	point = point or parent
	local noscalemult = 1-- * UIParent:GetScale()/WorldFrame:GetScale()

--	print(noscalemult)
--	print(1 * UIParent:GetScale()/WorldFrame:GetScale())

	if point.bordertop then return end

	point.backdrop = parent:CreateTexture(nil, "BORDER")
	point.backdrop:SetDrawLayer("BORDER", -4)
	point.backdrop:SetAllPoints(point)
	point.backdrop:SetColorTexture(unpack(E.db.nameplates.backdropfadecolor))

	point.bordertop = parent:CreateTexture(nil, "BORDER")
	point.bordertop:SetPoint("TOPLEFT", point, "TOPLEFT", -noscalemult, noscalemult)
	point.bordertop:SetPoint("TOPRIGHT", point, "TOPRIGHT", noscalemult, noscalemult)
	point.bordertop:SetHeight(noscalemult)
	point.bordertop:SetColorTexture(unpack(E.db.nameplates.bordercolor))
	point.bordertop:SetDrawLayer("BORDER", 1)

	point.borderbottom = parent:CreateTexture(nil, "BORDER")
	point.borderbottom:SetPoint("BOTTOMLEFT", point, "BOTTOMLEFT", -noscalemult, -noscalemult)
	point.borderbottom:SetPoint("BOTTOMRIGHT", point, "BOTTOMRIGHT", noscalemult, -noscalemult)
	point.borderbottom:SetHeight(noscalemult)
	point.borderbottom:SetColorTexture(unpack(E.db.nameplates.bordercolor))
	point.borderbottom:SetDrawLayer("BORDER", 1)

	point.borderleft = parent:CreateTexture(nil, "BORDER")
	point.borderleft:SetPoint("TOPLEFT", point, "TOPLEFT", -noscalemult, noscalemult)
	point.borderleft:SetPoint("BOTTOMLEFT", point, "BOTTOMLEFT", noscalemult, -noscalemult)
	point.borderleft:SetWidth(noscalemult)
	point.borderleft:SetColorTexture(unpack(E.db.nameplates.bordercolor))
	point.borderleft:SetDrawLayer("BORDER", 1)

	point.borderright = parent:CreateTexture(nil, "BORDER")
	point.borderright:SetPoint("TOPRIGHT", point, "TOPRIGHT", noscalemult, noscalemult)
	point.borderright:SetPoint("BOTTOMRIGHT", point, "BOTTOMRIGHT", -noscalemult, -noscalemult)
	point.borderright:SetWidth(noscalemult)
	point.borderright:SetColorTexture(unpack(E.db.nameplates.bordercolor))
	point.borderright:SetDrawLayer("BORDER", 1)

	point.SetBorderColor = SetBorderColor
end

function NP:ToggleAllHitbox()

	showHitbox = not showHitbox

	NP:ForEachPlate("ToggleHitbox")
end

function NP:UpdateAllPlates()
	NP:ForEachPlate("UpdateSettings")
end

function NP:ForEachPlate(functionToRun, ...)
	for i=1, #NP.CreatedPlates do
		NP[functionToRun](NP.CreatedPlates[i], ...)
	end
end

function NP:UpdateBasePlateSize()
	local horizontalScale = UIParent:GetEffectiveScale()

	local plateHeight = E.db.nameplates.healthBar_height + plateFrameWidthOffset

	ignoreSizeChange = true

	C_NamePlate.SetNamePlateFriendlySize(1,1) --120, 40)
	C_NamePlate.SetNamePlateEnemySize(E.db.nameplates.hitbox_width, E.db.nameplates.hitbox_height);
	C_NamePlate.SetNamePlateSelfSize(E.db.nameplates.hitbox_width-20, 1);
	ignoreSizeChange = false

	--[==[
	C_Timer.After(0.5, function()
		E:LockCVar('nameplateOverlapV', 1.4)
		E:LockCVar('nameplateOverlapH', 1.2)
	end)
	]==]
end


function NP:CVarUpdate()
	E:LockCVar("nameplateMotion", E.db.nameplates.nameplateMotion == "STACKED" and 1 or 0)
	E:LockCVar("nameplateShowAll", E.db.nameplates.nameplateShowAll and '1' or '0')

	E:LockCVar("nameplateMaxDistance", E.db.nameplates.nameplateMaxDistance)

	E:LockCVar("nameplateOtherTopInset", E.db.nameplates.nameplateOffsets  and '.08' or '-1')
	E:LockCVar("nameplateOtherBottomInset",  E.db.nameplates.nameplateOffsets  and '.1' or '-1')

	E:LockCVar("nameplateLargeBottomInset", '.08')
	E:LockCVar("nameplateLargeTopInset", '.1')

	-- "Position other nameplates at the base, rather than overhead -1=bottom 0=top 1=middle",
	E:LockCVar("nameplateOtherAtBase", E.db.nameplates.nameplatePosition)

	E:LockCVar("nameplateShowSelf", E.db.nameplates.nameplateShowSelf and '1' or '0')

	SetCVar("nameplateShowEnemies", E.db.nameplates.nameplateShowEnemies and '1' or '0')
	E:LockCVar("nameplateShowEnemyMinions", E.db.nameplates.nameplateShowEnemyMinions and '1' or '0')
	E:LockCVar("nameplateShowEnemyPets", E.db.nameplates.nameplateShowEnemyPets and '1' or '0')
	E:LockCVar("nameplateShowEnemyGuardians", E.db.nameplates.nameplateShowEnemyGuardians and '1' or '0')
	E:LockCVar("nameplateShowEnemyTotems", E.db.nameplates.nameplateShowEnemyTotems and '1' or '0')
	E:LockCVar("nameplateShowEnemyMinus", E.db.nameplates.nameplateShowEnemyMinus and '1' or '0')

	SetCVar("nameplateShowFriends", E.db.nameplates.nameplateShowFriends and '1' or '0')
	E:LockCVar("nameplateShowFriendlyMinions", E.db.nameplates.nameplateShowFriendlyMinions and '1' or '0')
	E:LockCVar("nameplateShowFriendlyPets", E.db.nameplates.nameplateShowFriendlyPets and '1' or '0')
	E:LockCVar("nameplateShowFriendlyGuardians", E.db.nameplates.nameplateShowFriendlyGuardians and '1' or '0')
	E:LockCVar("nameplateShowFriendlyTotems", E.db.nameplates.nameplateShowFriendlyTotems and '1' or '0')

	E:LockCVar('NameplateMinScale',1)
    E:LockCVar('NameplateMaxScale',1)
	E:LockCVar('nameplateLargerScale',1)
	E:LockCVar('nameplateSelectedScale', 1)
	E:LockCVar('nameplateOverlapH', E.db.nameplates.overlapH)
	E:LockCVar('nameplateOverlapV', E.db.nameplates.overlapV)

	E:LockCVar('nameplateOccludedAlphaMult', 1.0)

	--[==[
	E:LockCVar("UnitNameFriendlySpecialNPCName", "1");
	E:LockCVar("UnitNameNPC", "0");
	E:LockCVar("UnitNameHostleNPC", "0");
	E:LockCVar("UnitNameInteractiveNPC", "0");
	E:LockCVar("ShowQuestUnitCircles", "1");
	]==]
end

function NP.OnInit()
	NP:UpdateBasePlateSize()

	SystemFont_LargeNamePlateFixed:SetFont(STANDARD_TEXT_FONT, 10, 'OUTLINE') 
	SystemFont_NamePlateFixed:SetFont(STANDARD_TEXT_FONT, 10, 'OUTLINE') 
	SystemFont_LargeNamePlate:SetFont(STANDARD_TEXT_FONT, 10, 'OUTLINE') 
	SystemFont_NamePlate:SetFont(STANDARD_TEXT_FONT, 10, 'OUTLINE') 
end

function NP:UpdateProfileSettings()
	NP:UpdateAllPlates()
	NP:UpdateBasePlateSize()
	NP:CVarUpdate()
end

E:OnInit2(NP.OnInit)
E:OnInit(function()
	NP:CVarUpdate()

	local function CVarCheck(cvarName, value)
		if cvarName == 'nameplateShowEnemies' or cvarName == 'nameplateShowFriends' then
			E.db.nameplates.nameplateShowFriends = GetCVarBool("nameplateShowFriends")
			E.db.nameplates.nameplateShowEnemies = GetCVarBool("nameplateShowEnemies")
		end
	end

	hooksecurefunc("SetCVar", CVarCheck)


	local iname = 'InterfaceOptionsNamesPanelUnitNameplates'

	_G[iname..'PersonalResource']:SetScale(0.00001)
	_G[iname..'PersonalResource']:SetAlpha(0)

	_G[iname..'PersonalResourceOnEnemy']:SetScale(0.00001)
	_G[iname..'PersonalResourceOnEnemy']:SetAlpha(0)

	_G[iname..'MakeLarger']:SetScale(0.00001)
	_G[iname..'MakeLarger']:SetAlpha(0)

	_G[iname..'AggroFlash']:SetScale(0.00001)
	_G[iname..'AggroFlash']:SetAlpha(0)

	_G[iname..'ShowAll']:SetScale(0.00001)
	_G[iname..'ShowAll']:SetAlpha(0)

	_G[iname..'Enemies']:SetScale(0.00001)
	_G[iname..'Enemies']:SetAlpha(0)

	_G[iname..'EnemyMinions']:SetScale(0.00001)
	_G[iname..'EnemyMinions']:SetAlpha(0)

	_G[iname..'EnemyMinus']:SetScale(0.00001)
	_G[iname..'EnemyMinus']:SetAlpha(0)

	_G[iname..'Friends']:SetScale(0.00001)
	_G[iname..'Friends']:SetAlpha(0)

	_G[iname..'FriendlyMinions']:SetScale(0.00001)
	_G[iname..'FriendlyMinions']:SetAlpha(0)

	_G[iname..'MotionDropDown']:SetScale(0.00001)
	_G[iname..'MotionDropDown']:SetAlpha(0)

	local f = CreateFrame('Button', nil, _G[ 'InterfaceOptionsNamesPanelUnitNameplates'], "UIPanelButtonTemplate")
	f:SetSize(160, 22)
	f:SetText(L['Nameplate settings'])
	f:SetPoint('TOPLEFT', 0, -15)
	f:SetScript('OnClick', function()
		InterfaceOptionsFrame:Hide();
		HideUIPanel(GameMenuFrame);
		AleaUI_GUI:Open('AleaUI')
		AleaUI_GUI:SelectGroup("AleaUI", "NamePlates")
		PlaySound(SOUNDKIT and SOUNDKIT.IG_MAINMENU_OPTION or "igMainMenuOption");
	end)
end)
-----------------------
-- Interface
-----------------------
E.GUI.args.NamePlates = {
	name = L['Nameplates'],
	type = "group",
	order = 5,
	args = {},
}

E.GUI.args.NamePlates.args.tabSettings = {
	name = L["Tabs"],
	type = "tabgroup",
	width = 'full',
	order = 2,
	args = {}
}


E.GUI.args.NamePlates.args.tabSettings.args.blizzardSettings = {
	name = L["Blizzard Settings"],
	type = "group",
	order = 1,
	embend = true,
	args = {},
}


E.GUI.args.NamePlates.args.tabSettings.args.generals = {
	name = L['General'],
	type = "group",
	order = 1.2,
	embend = true,
	args = {},
}

E.GUI.args.NamePlates.args.tabSettings.args.blizzardSettings.args.nameplateShowAll = {
	name = L['Show always'],
	order = 0.1,
	type = "toggle",
	width = 'full',
	set = function(self, value)
		E.db.nameplates.nameplateShowAll = not E.db.nameplates.nameplateShowAll
		E:LockCVar("nameplateShowAll", E.db.nameplates.nameplateShowAll and 1 or 0)
	end,
	get = function(self)
		return E.db.nameplates.nameplateShowAll
	end,
}

E.GUI.args.NamePlates.args.tabSettings.args.blizzardSettings.args.nameplateShowEnemies = {
	name = L['Show enemies'],
	order = 0.2,
	type = "toggle",
	set = function(self, value)
		SetCVar("nameplateShowEnemies", GetCVarBool("nameplateShowEnemies") and 0 or 1)
		E.db.nameplates.nameplateShowEnemies = GetCVarBool("nameplateShowEnemies")
	end,
	get = function(self)
		return GetCVarBool("nameplateShowEnemies")
	end,
}
E.GUI.args.NamePlates.args.tabSettings.args.blizzardSettings.args.nameplateShowEnemyMinions = {
	name = L['Show enemy minions'],
	order = 0.4,
	type = "toggle", newLine = true,
	set = function(self, value)
		E.db.nameplates.nameplateShowEnemyMinions = not E.db.nameplates.nameplateShowEnemyMinions
		E:LockCVar("nameplateShowEnemyMinions", E.db.nameplates.nameplateShowEnemyMinions and 1 or 0)
	end,
	get = function(self)
		return E.db.nameplates.nameplateShowEnemyMinions
	end,
}

E.GUI.args.NamePlates.args.tabSettings.args.blizzardSettings.args.nameplateShowEnemyPets = {
	name = L['Show enemy pets'],
	order = 0.6,
	type = "toggle",  newLine = true,
	set = function(self, value)
		E.db.nameplates.nameplateShowEnemyPets = not E.db.nameplates.nameplateShowEnemyPets
		E:LockCVar("nameplateShowEnemyPets", E.db.nameplates.nameplateShowEnemyPets and 1 or 0)
	end,
	get = function(self)
		return E.db.nameplates.nameplateShowEnemyPets
	end,
}

E.GUI.args.NamePlates.args.tabSettings.args.blizzardSettings.args.nameplateShowEnemyGuardians = {
	name = L['Show enemy guardians'],
	order = 0.8,
	type = "toggle",  newLine = true,
	set = function(self, value)
		E.db.nameplates.nameplateShowEnemyGuardians = not E.db.nameplates.nameplateShowEnemyGuardians
		E:LockCVar("nameplateShowEnemyGuardians", E.db.nameplates.nameplateShowEnemyGuardians and 1 or 0)
	end,
	get = function(self)
		return E.db.nameplates.nameplateShowEnemyGuardians
	end,
}

E.GUI.args.NamePlates.args.tabSettings.args.blizzardSettings.args.nameplateShowEnemyTotems = {
	name = L['Show enemy totems'],
	order = 1.0,
	type = "toggle",  newLine = true,
	set = function(self, value)
		E.db.nameplates.nameplateShowEnemyTotems = not E.db.nameplates.nameplateShowEnemyTotems
		E:LockCVar("nameplateShowEnemyTotems", E.db.nameplates.nameplateShowEnemyTotems and 1 or 0)
	end,
	get = function(self)
		return E.db.nameplates.nameplateShowEnemyTotems
	end,
}

E.GUI.args.NamePlates.args.tabSettings.args.blizzardSettings.args.nameplateShowEnemyMinus = {
	name = L['Show enemy minus'],
	order = 1.2,
	type = "toggle", width = 'full',
	set = function(self, value)
		E.db.nameplates.nameplateShowEnemyMinus = not E.db.nameplates.nameplateShowEnemyMinus
		E:LockCVar("nameplateShowEnemyMinus", E.db.nameplates.nameplateShowEnemyMinus and 1 or 0)
	end,
	get = function(self)
		return E.db.nameplates.nameplateShowEnemyMinus
	end,
}

E.GUI.args.NamePlates.args.tabSettings.args.blizzardSettings.args.nameplateShowSelf = {
	name = DISPLAY_PERSONAL_RESOURCE,
	order = 2,
	type = "toggle", width = 'full',
	set = function(self, value)
		E.db.nameplates.nameplateShowSelf = not E.db.nameplates.nameplateShowSelf
		E:LockCVar("nameplateShowSelf", E.db.nameplates.nameplateShowSelf and 1 or 0)
	end,
	get = function(self)
		return E.db.nameplates.nameplateShowSelf
	end,
}


E.GUI.args.NamePlates.args.tabSettings.args.blizzardSettings.args.nameplateShowFriends = {
	name = L['Show friends'],
	order = 0.3,
	type = "toggle",
	set = function(self, value)
		SetCVar("nameplateShowFriends", GetCVarBool("nameplateShowFriends") and 0 or 1)
		E.db.nameplates.nameplateShowFriends = GetCVarBool("nameplateShowFriends")
	end,
	get = function(self)
		return GetCVarBool("nameplateShowFriends")
	end,
}

E.GUI.args.NamePlates.args.tabSettings.args.blizzardSettings.args.nameplateShowFriendlyMinions = {
	name = L['Show friendly minions'],
	order = 0.5,
	type = "toggle",
	set = function(self, value)
		E.db.nameplates.nameplateShowFriendlyMinions = not E.db.nameplates.nameplateShowFriendlyMinions
		E:LockCVar("nameplateShowFriendlyMinions", E.db.nameplates.nameplateShowFriendlyMinions and 1 or 0)
	end,
	get = function(self)
		return E.db.nameplates.nameplateShowFriendlyMinions
	end,
}

E.GUI.args.NamePlates.args.tabSettings.args.blizzardSettings.args.nameplateShowFriendlyPets = {
	name = L['Show friendly pets'],
	order = 0.7,
	type = "toggle",
	set = function(self, value)
		E.db.nameplates.nameplateShowFriendlyPets = not E.db.nameplates.nameplateShowFriendlyPets
		E:LockCVar("nameplateShowFriendlyPets", E.db.nameplates.nameplateShowFriendlyPets and 1 or 0)
	end,
	get = function(self)
		return E.db.nameplates.nameplateShowFriendlyPets
	end,
}

E.GUI.args.NamePlates.args.tabSettings.args.blizzardSettings.args.nameplateShowFriendlyGuardians = {
	name = L['Show friendly guardians'],
	order = 0.9,
	type = "toggle",
	set = function(self, value)
		E.db.nameplates.nameplateShowFriendlyGuardians = not E.db.nameplates.nameplateShowFriendlyGuardians
		E:LockCVar("nameplateShowFriendlyGuardians", E.db.nameplates.nameplateShowFriendlyGuardians and 1 or 0)
	end,
	get = function(self)
		return E.db.nameplates.nameplateShowFriendlyGuardians
	end,
}

E.GUI.args.NamePlates.args.tabSettings.args.blizzardSettings.args.nameplateShowFriendlyTotems = {
	name = L['Show friendly totems'],
	order = 1.1,
	type = "toggle",
	set = function(self, value)
		E.db.nameplates.nameplateShowFriendlyTotems = not E.db.nameplates.nameplateShowFriendlyTotems
		E:LockCVar("nameplateShowFriendlyTotems", E.db.nameplates.nameplateShowFriendlyTotems and 1 or 0)
	end,
	get = function(self)
		return E.db.nameplates.nameplateShowFriendlyTotems
	end,
}

E.GUI.args.NamePlates.args.tabSettings.args.blizzardSettings.args.nameplateMaxDistance = {
	name = L['Distance'],
	order = 4,
	type = "slider",
	min = 30, max = 60, step = 1,
	set = function(self, value)
		E.db.nameplates.nameplateMaxDistance = value
		E:LockCVar("nameplateMaxDistance", value)
	end,
	get = function(self)
		return E.db.nameplates.nameplateMaxDistance
	end,
}

E.GUI.args.NamePlates.args.tabSettings.args.blizzardSettings.args.nameplateOffsets = {
	name = L['Enable sticking'],
	order = 5,
	type = "toggle",

	set = function(self, value)
		E.db.nameplates.nameplateOffsets = not E.db.nameplates.nameplateOffsets

		E:LockCVar("nameplateOtherTopInset", E.db.nameplates.nameplateOffsets  and '.08' or '-1')
		E:LockCVar("nameplateOtherBottomInset",  E.db.nameplates.nameplateOffsets  and '.1' or '-1')

	end,
	get = function(self)
		return E.db.nameplates.nameplateOffsets
	end,
}

E.GUI.args.NamePlates.args.tabSettings.args.blizzardSettings.args.nameplatePosition = {
	name = L['Position'],
	order = 6,
	type = "dropdown",
	values = {
		[-1] = 'Bottom',
		[0] = 'Top',
		[1] = 'Middle',
	},
	set = function(self, value)
		E.db.nameplates.nameplatePosition = value
		E:LockCVar("nameplateOtherAtBase", E.db.nameplates.nameplatePosition)
	end,
	get = function(self)
		return E.db.nameplates.nameplatePosition
	end,
}

E.GUI.args.NamePlates.args.tabSettings.args.blizzardSettings.args.nameplateMotion = {
	name = L["Motion"],
	order = 7,
	type = "dropdown",
	values = {
		['STACKED'] = UNIT_NAMEPLATES_TYPE_2,
		['OVERLAP'] = UNIT_NAMEPLATES_TYPE_1,
	},
	set = function(self, value)
		E.db.nameplates.nameplateMotion = value
		E:LockCVar("nameplateMotion", E.db.nameplates.nameplateMotion == "STACKED" and 1 or 0)
	end,
	get = function(self)
		return E.db.nameplates.nameplateMotion
	end,
}

E.GUI.args.NamePlates.args.tabSettings.args.blizzardSettings.args.toggleHitboxHighlight = {
	name = L["Show hitbox"],
	type = "execute",
	order = 8,
	newLine = true,
	set = function(self)
		NP:ToggleAllHitbox()

		if ( showHitbox ) then
			E.GUI.args.NamePlates.args.tabSettings.args.blizzardSettings.args.toggleHitboxHighlight.name = L["Hide hitbox"]
		else
			E.GUI.args.NamePlates.args.tabSettings.args.blizzardSettings.args.toggleHitboxHighlight.name = L["Show hitbox"]
		end
	end,
	get = function(self)
		return ''
	end,
}

E.GUI.args.NamePlates.args.tabSettings.args.blizzardSettings.args.hitbox_width = {
	name = L['Hitbox width'],
	order = 10,
	type = "slider",
	newLine = true,
	min = 10, max = 600, step = 1,
	set = function(self, value)
		E.db.nameplates.hitbox_width = value

		NP:UpdateBasePlateSize()
	end,
	get = function(self)
		return E.db.nameplates.hitbox_width
	end,
}

E.GUI.args.NamePlates.args.tabSettings.args.blizzardSettings.args.hitbox_height = {
	name = L['Hitbox height'],
	order = 11,
	type = "slider",
	min = 10, max = 600, step = 1,
	set = function(self, value)
		E.db.nameplates.hitbox_height = value
		NP:UpdateBasePlateSize()
	end,
	get = function(self)
		return E.db.nameplates.hitbox_height
	end,
}


E.GUI.args.NamePlates.args.tabSettings.args.blizzardSettings.args.overlapH = {
	name = L['Horizontal spacing'],
	order = 12,
	type = "slider",
	min = 0, max = 3, step = 0.1,
	newLine = true,
	set = function(self, value)
		E.db.nameplates.overlapH = value

		E:LockCVar('nameplateOverlapH', E.db.nameplates.overlapH)
	end,
	get = function(self)
		return E.db.nameplates.overlapH
	end,
}

E.GUI.args.NamePlates.args.tabSettings.args.blizzardSettings.args.overlapV = {
	name = L['Vertical spacing'],
	order = 13,
	type = "slider",
	min = 0, max = 3, step = 0.1,
	set = function(self, value)
		E.db.nameplates.overlapV = value

		E:LockCVar('nameplateOverlapV', E.db.nameplates.overlapV)
	end,
	get = function(self)
		return E.db.nameplates.overlapV
	end,
}

--[==[
E.GUI.args.NamePlates.args.blizzardSettings.args.nameplateShowFriendlyMinions = {
	name = "ƒружественные питомцы",
	order = 1.2,
	type = "toggle",

	set = function(self, value)
		E.db.nameplates.nameplateShowFriendlyMinions = not E.db.nameplates.nameplateShowFriendlyMinions
		E:LockCVar("nameplateShowFriendlyMinions", E.db.nameplates.nameplateShowFriendlyMinions and 1 or 0)
	end,
	get = function(self)
		return E.db.nameplates.nameplateShowFriendlyMinions
	end,
}

E.GUI.args.NamePlates.args.blizzardSettings.args.nameplateShowEnemyMinions = {
	name = "¬ражеские питомцы",
	order = 1.2,
	type = "toggle",

	set = function(self, value)
		E.db.nameplates.nameplateShowEnemyMinions = not E.db.nameplates.nameplateShowEnemyMinions
		E:LockCVar("nameplateShowEnemyMinions", E.db.nameplates.nameplateShowEnemyMinions and 1 or 0)
	end,
	get = function(self)
		return E.db.nameplates.nameplateShowEnemyMinions
	end,
}

E.GUI.args.NamePlates.args.blizzardSettings.args.nameplateShowEnemyMinus = {
	name = "¬ражеские слабые мобы",
	order = 1.3,
	type = "toggle",

	set = function(self, value)
		E.db.nameplates.nameplateShowEnemyMinus = not E.db.nameplates.nameplateShowEnemyMinus
		E:LockCVar("nameplateShowEnemyMinus", E.db.nameplates.nameplateShowEnemyMinus and 1 or 0)
	end,
	get = function(self)
		return E.db.nameplates.nameplateShowEnemyMinus
	end,
}

]==]

E.GUI.args.NamePlates.args.tabSettings.args.generals.args.buff_amount = {
	name = L['Buff amount'],
	order = 3,
	type = "slider",
	min = 0, max = 6, step = 1,
	set = function(self, value)
		E.db.nameplates.buffs.numAuras = value
		NP:UpdateAllPlates()
	end,
	get = function(self)
		return E.db.nameplates.buffs.numAuras
	end,
}

E.GUI.args.NamePlates.args.tabSettings.args.generals.args.debuff_amount = {
	name = L['Debuff amount'],
	order = 4,
	type = "slider",
	min = 0, max = 6, step = 1,
	set = function(self, value)
		E.db.nameplates.debuffs.numAuras = value
		NP:UpdateAllPlates()
	end,
	get = function(self)
		return E.db.nameplates.debuffs.numAuras
	end,
}

E.GUI.args.NamePlates.args.tabSettings.args.generals.args.FriendlyUnits = {
	name = L['Friendly units'],
	type = "group",
	order = 4.1,
	embend = true,
	args = {},
}
E.GUI.args.NamePlates.args.tabSettings.args.generals.args.FriendlyUnits.args.buff_amount = {
	name = L['Buff amount'],
	order = 3,
	type = "slider",
	min = 0, max = 6, step = 1,
	set = function(self, value)
		E.db.nameplates.buffs.friendlynumAuras = value
		NP:UpdateAllPlates()
	end,
	get = function(self)
		return E.db.nameplates.buffs.friendlynumAuras
	end,
}

E.GUI.args.NamePlates.args.tabSettings.args.generals.args.FriendlyUnits.args.debuff_amount = {
	name = L['Debuff amount'],
	order = 4,
	type = "slider",
	min = 0, max = 6, step = 1,
	set = function(self, value)
		E.db.nameplates.debuffs.friendlynumAuras = value
		NP:UpdateAllPlates()
	end,
	get = function(self)
		return E.db.nameplates.debuffs.friendlynumAuras
	end,
}

E.GUI.args.NamePlates.args.tabSettings.args.generals.args.showmyauras = {
	name = L['Show my auras'],
	order = 1,
	type = "toggle",

	set = function(self, value)
		E.db.nameplates.showmyauras = not E.db.nameplates.showmyauras
	end,
	get = function(self)
		return E.db.nameplates.showmyauras
	end,
}

E.GUI.args.NamePlates.args.tabSettings.args.generals.args.showfromspelllist = {
	name = L['Show from spell list'],
	order = 2,
	type = "toggle",
	set = function(self, value)
		E.db.nameplates.showfromspelllist = not E.db.nameplates.showfromspelllist
	end,
	get = function(self)
		return E.db.nameplates.showfromspelllist
	end,
}

E.GUI.args.NamePlates.args.tabSettings.args.generals.args.showpurge = {
	name = L['Show dispellable auras'],
	order = 2,
	type = "toggle",
	set = function(self, value)
		E.db.nameplates.showpurge = not E.db.nameplates.showpurge
	end,
	get = function(self)
		return E.db.nameplates.showpurge
	end,
}

E.GUI.args.NamePlates.args.tabSettings.args.generals.args.easyPlatesForFriendly = {
	name = L['Easy plates for friendly units'], width = 'full',
	order = 2,
	type = "toggle",
	set = function(self, value)
		E.db.nameplates.easyPlatesForFriendly = not E.db.nameplates.easyPlatesForFriendly
		NP:UpdateBasePlateSize()
	end,
	get = function(self)
		return E.db.nameplates.easyPlatesForFriendly
	end,
}

E.GUI.args.NamePlates.args.tabSettings.args.generals.args.stretchTexture = {
	name = L['Stretch icon texture'], width = 'full',
	order = 2,
	type = "toggle",
	set = function(self, value)
		E.db.nameplates.stretchTexture = not E.db.nameplates.stretchTexture

		NP:UpdateAllPlates()
	end,
	get = function(self)
		return E.db.nameplates.stretchTexture
	end,
}

E.GUI.args.NamePlates.args.tabSettings.args.generals.args.plateFont = {
	name = L["Fonts"],
	type = "group",
	order = 10,
	embend = true,
	args = {},
}

E.GUI.args.NamePlates.args.tabSettings.args.generals.args.plateFont.args.font = {
	name = L["Font"],
	order = 1,
	type = "font",
	values = E.GetFontList,
	set = function(self, value)
		E.db.nameplates.font = value
		NP:UpdateAllPlates()
	end,
	get = function(self)
		return E.db.nameplates.font
	end,
}

E.GUI.args.NamePlates.args.tabSettings.args.generals.args.plateFont.args.fontSize = {
	name = L["Size"],
	order = 1,
	type = "slider",
	min = 1, max = 32, step = 1,
	set = function(self, value)
		E.db.nameplates.fontSize = value
		NP:UpdateAllPlates()
	end,
	get = function(self)
		return E.db.nameplates.fontSize
	end,
}
E.GUI.args.NamePlates.args.tabSettings.args.generals.args.plateFont.args.fontOutline = {
	name = L["Outline"],
	order = 3,
	type = "dropdown",
	values = {
		[""] = NO,
		["OUTLINE"] = "OUTLINE",
	},
	set = function(self, value)
		E.db.nameplates.fontOutline = value
		NP:UpdateAllPlates()
	end,
	get = function(self)
		return E.db.nameplates.fontOutline
	end,
}

E.GUI.args.NamePlates.args.tabSettings.args.generals.args.friendlyPlateFont = {
	name = L["Friendly plate fonts"],
	type = "group",
	order = 10.1,
	embend = true,
	args = {},
}

E.GUI.args.NamePlates.args.tabSettings.args.generals.args.friendlyPlateFont.args.font = {
	name = L["Font"],
	order = 1,
	type = "font",
	values = E.GetFontList,
	set = function(self, value)
		E.db.nameplates.friendlyFont = value
		NP:UpdateAllPlates()
	end,
	get = function(self)
		return E.db.nameplates.friendlyFont
	end,
}

E.GUI.args.NamePlates.args.tabSettings.args.generals.args.friendlyPlateFont.args.fontSize = {
	name = L["Size"],
	order = 1,
	type = "slider",
	min = 1, max = 72, step = 1,
	set = function(self, value)
		E.db.nameplates.friendlyFontSize = value
		NP:UpdateAllPlates()
	end,
	get = function(self)
		return E.db.nameplates.friendlyFontSize
	end,
}
E.GUI.args.NamePlates.args.tabSettings.args.generals.args.friendlyPlateFont.args.fontOutline = {
	name = L["Outline"],
	order = 3,
	type = "dropdown",
	values = {
		[""] = NO,
		["OUTLINE"] = "OUTLINE",
	},
	set = function(self, value)
		E.db.nameplates.friendlyFontOutline = value
		NP:UpdateAllPlates()
	end,
	get = function(self)
		return E.db.nameplates.friendlyFontOutline
	end,
}

E.GUI.args.NamePlates.args.tabSettings.args.plateColors = {
	name = L["Colors"],
	type = "group",
	order = 1.3,
	embend = true,
	args = {},
}

E.GUI.args.NamePlates.args.tabSettings.args.plateColors.args.reactionColors = {
	name = L["Reaction colors"],
	type = "group",
	order = 1.5,
	embend = true,
	args = {},
}

for k,v in pairs(defaults.reactions) do

	E.GUI.args.NamePlates.args.tabSettings.args.plateColors.args.reactionColors.args[k] = {
		name = L[k], desc = k,
		order = 1,
		type = "color",
		set = function(self, r,g,b)
			E.db.nameplates.reactions[k] = { r=r, g=g, b=b, 1 }
		end,
		get = function(self)
			return E.db.nameplates.reactions[k].r, E.db.nameplates.reactions[k].g, E.db.nameplates.reactions[k].b, 1
		end,
	}
end

E.GUI.args.NamePlates.args.tabSettings.args.plateColors.args.auratypeColors = {
	name = L["Aura type colors"],
	type = "group",
	order = 1.5,
	embend = true,
	args = {},
}

E.GUI.args.NamePlates.args.tabSettings.args.plateColors.args.auratypeColors.args.colorbytype = {
	name = L["Color by type"],
	order = 1,
	width = "full",
	type = "toggle",
	set = function(self, value)
		E.db.nameplates.colorByType = not E.db.nameplates.colorByType
	end,
	get = function(self)
		return E.db.nameplates.colorByType
	end,
}

for k,v in pairs(defaults.typecolors) do

	E.GUI.args.NamePlates.args.tabSettings.args.plateColors.args.auratypeColors.args[k] = {
		name = L['colorType'..colorToTypeName[k]],
		order = 2,
		type = "color",
		set = function(self, r,g,b)
			E.db.nameplates.typecolors[k] = {r,g,b,1}
		end,
		get = function(self)
			return E.db.nameplates.typecolors[k][1], E.db.nameplates.typecolors[k][2], E.db.nameplates.typecolors[k][3], 1
		end,
	}
end


E.GUI.args.NamePlates.args.tabSettings.args.plateHealth = {
	name = L["Health bar"],
	type = "group",
	order = 2,
	embend = true,
	args = {},
}


E.GUI.args.NamePlates.args.tabSettings.args.plateHealth.args.BorderOpts = {
	name = L['Borders'],
	order = -1,
	embend = true,
	type = "group",
	args = {}
}

E.GUI.args.NamePlates.args.tabSettings.args.plateHealth.args.BorderOpts.args.border = {
	name = L["Borders"],
	order = 1,
	type = "color",
	hasAlpha = true,
	set = function(self, r,g,b,a)
		E.db.nameplates.bordercolor = { r, g, b, a }
		NP:UpdateAllPlates()
	end,
	get = function(self)
		return E.db.nameplates.bordercolor[1], E.db.nameplates.bordercolor[2], E.db.nameplates.bordercolor[3], E.db.nameplates.bordercolor[4]
	end,
}

E.GUI.args.NamePlates.args.tabSettings.args.plateHealth.args.BorderOpts.args.backgroundcolor = {
	name = L["Background"],
	order = 2,
	type = "color",
	hasAlpha = true,
	set = function(self, r,g,b,a)
		E.db.nameplates.backdropfadecolor = { r, g, b, a }
		NP:UpdateAllPlates()
	end,
	get = function(self)
		return E.db.nameplates.backdropfadecolor[1], E.db.nameplates.backdropfadecolor[2], E.db.nameplates.backdropfadecolor[3], E.db.nameplates.backdropfadecolor[4]
	end,
}

E.GUI.args.NamePlates.args.tabSettings.args.plateHealth.args.BorderOpts.args.BorderTexture = {
	order = 2.1,
	type = 'border',
	name = L['Border texture'],
	values = E:GetBorderList(),
	set = function(info,value)
		E.db.nameplates.borderTexture = value
		NP:UpdateAllPlates()
	end,
	get = function(info) return E.db.nameplates.borderTexture end,
}

E.GUI.args.NamePlates.args.tabSettings.args.plateHealth.args.BorderOpts.args.BackgroundTexture = {
	order = 2.2,
	type = 'statusbar',
	name = L['Background texture'],
	values = E.GetTextureList,
	set = function(info,value)
		E.db.nameplates.background_texture = value;
		NP:UpdateAllPlates()
	end,
	get = function(info) return E.db.nameplates.background_texture end,
}

E.GUI.args.NamePlates.args.tabSettings.args.plateHealth.args.BorderOpts.args.BorderSize = {
	name = L['Border size'],
	type = "slider",
	order	= 2.3,
	min		= 1,
	max		= 32,
	step	= 1,
	set = function(info,val)
		E.db.nameplates.borderSize = val
		NP:UpdateAllPlates()
	end,
	get =function(info)
		return E.db.nameplates.borderSize
	end,
}

E.GUI.args.NamePlates.args.tabSettings.args.plateHealth.args.BorderOpts.args.BorderInset = {
	name = L['Border inset'],
	type = "slider",
	order	= 2.4,
	min		= -32,
	max		= 32,
	step	= 1,
	set = function(info,val)
		E.db.nameplates.borderInset = val
		NP:UpdateAllPlates()
	end,
	get =function(info)
		return E.db.nameplates.borderInset
	end,
}

E.GUI.args.NamePlates.args.tabSettings.args.plateHealth.args.BorderOpts.args.backgroundInset = {
	name = L['Background inset'],
	type = "slider",
	order	= 2.5,
	min		= -32,
	max		= 32,
	step	= 1,
	set = function(info,val)
		E.db.nameplates.backgroundInset = val
		NP:UpdateAllPlates()
	end,
	get =function(info)
		return E.db.nameplates.backgroundInset
	end,
}

E.GUI.args.NamePlates.args.tabSettings.args.plateHealth.args.width = {
	name = L["Width"],
	order = 3,
	type = "slider",
	min = 1, max = 300, step = 1,
	set = function(self, value)
		E.db.nameplates.healthBar_width = value

	--	NP:UpdateBasePlateSize()

		NP:UpdateAllPlates()
	end,
	get = function(self)
		return E.db.nameplates.healthBar_width
	end,
}
E.GUI.args.NamePlates.args.tabSettings.args.plateHealth.args.height = {
	name = L["Height"],
	order = 4,
	type = "slider",
	min = 1, max = 50, step = 1,
	set = function(self, value)
		E.db.nameplates.healthBar_height = value

	--	NP:UpdateBasePlateSize()

		NP:UpdateAllPlates()
	end,
	get = function(self)
		return E.db.nameplates.healthBar_height
	end,
}

E.GUI.args.NamePlates.args.tabSettings.args.plateHealth.args.texture = {
	name = L["Texture"],
	order = 5,
	type = "statusbar",
	values = E.GetTextureList,
	set = function(self, value)
		E.db.nameplates.healthBar_texture = value
		NP:UpdateAllPlates()
	end,
	get = function(self)
		return E.db.nameplates.healthBar_texture
	end,
}

E.GUI.args.NamePlates.args.tabSettings.args.plateHealth.args.auraSize = {
	name = L["Aura size"],
	order = 6,
	type = "slider",
	min = 1, max = 32, step = 1,
	set = function(self, value)
		E.db.nameplates.auraSize = value
		NP:UpdateAllPlates()
	end,
	get = function(self)
		return E.db.nameplates.auraSize
	end,
}
--[==[
E.GUI.args.NamePlates.args.AuraParen = {
	name = " репление аур",
	type = "group",
	order = 2.2,
	embend = true,
	args = {},
}

E.GUI.args.NamePlates.args.AuraParen.args.xOffset = {
	name = "xOffset",
	order = 1,
	type = "slider",
	min = -200, max = 200, step = 1,
	set = function(self, value)
		E.db.nameplates.aura_xOffset = value
		NP:UpdateAllPlates()
	end,
	get = function(self)
		return E.db.nameplates.aura_xOffset
	end,
}
E.GUI.args.NamePlates.args.AuraParen.args.yOffset = {
	name = "yOffset",
	order = 1,
	type = "slider",
	min = -200, max = 200, step = 1,
	set = function(self, value)
		E.db.nameplates.aura_yOffset = value
		NP:UpdateAllPlates()
	end,
	get = function(self)
		return E.db.nameplates.aura_yOffset
	end,
}
]==]
E.GUI.args.NamePlates.args.tabSettings.args.plateCastBar = {
	name = L["Cast Bar"],
	type = "group",
	order = 3,
	embend = true,
	args = {},
}

E.GUI.args.NamePlates.args.tabSettings.args.plateCastBar.args.height = {
	name = L["Height"],
	order = 4,
	type = "slider",
	min = 1, max = 50, step = 1,
	set = function(self, value)
		E.db.nameplates.castBar_height = value
		NP:UpdateAllPlates()
	end,
	get = function(self)
		return E.db.nameplates.castBar_height
	end,
}

E.GUI.args.NamePlates.args.tabSettings.args.plateCastBar.args.color = {
	name = L["Interruptable"],
	order = 3,
	type = "color",
	set = function(self, r,g,b)
		E.db.nameplates.castBar_color = { r, g, b, 1 }
	end,
	get = function(self)
		return E.db.nameplates.castBar_color[1], E.db.nameplates.castBar_color[2], E.db.nameplates.castBar_color[3], 1
	end,
}

E.GUI.args.NamePlates.args.tabSettings.args.plateCastBar.args.noInterrupt = {
	name = L["Not Interruptable"],
	order = 5,
	type = "color",
	set = function(self, r,g,b)
		E.db.nameplates.castBar_noInterrupt = { r, g, b, 1 }
	end,
	get = function(self)
		return E.db.nameplates.castBar_noInterrupt[1], E.db.nameplates.castBar_noInterrupt[2], E.db.nameplates.castBar_noInterrupt[3], 1
	end,
}

E.GUI.args.NamePlates.args.tabSettings.args.plateCastBar.args.offset = {
	name = L["Offset"],
	order = 6,
	type = "slider",
	min = -50, max = 50, step = 1,
	set = function(self, value)
		E.db.nameplates.castBar_offset = value
		NP:UpdateAllPlates()
	end,
	get = function(self)
		return E.db.nameplates.castBar_offset
	end,
}


--[==[
E.GUI.args.NamePlates.args.plateCastBar.args.border = {
	name = L["Borders"],
	order = 1,
	type = "color",
	hasAlpha = true,
	set = function(self, r,g,b,a)
		E.db.nameplates.castBar_bordercolor = { r, g, b, a }

		NP:UpdateAllPlates()
	end,
	get = function(self)
		return E.db.nameplates.castBar_bordercolor[1], E.db.nameplates.castBar_bordercolor[2], E.db.nameplates.castBar_bordercolor[3], E.db.nameplates.castBar_bordercolor[4]
	end,
}

E.GUI.args.NamePlates.args.plateCastBar.args.backgroundcolor = {
	name = L["Background"],
	order = 2,
	type = "color",
	hasAlpha = true,
	set = function(self, r,g,b,a)
		E.db.nameplates.castBar_background = { r, g, b, a }
		NP:UpdateAllPlates()
	end,
	get = function(self)
		return E.db.nameplates.castBar_background[1], E.db.nameplates.castBar_background[2], E.db.nameplates.castBar_background[3], E.db.nameplates.castBar_background[4]
	end,
}
]==]

E.GUI.args.NamePlates.args.tabSettings.args.plateCastBar.args.BorderOpts = {
	name = L['Borders'],
	order = -1,
	embend = true,
	type = "group",
	args = {}
}

E.GUI.args.NamePlates.args.tabSettings.args.plateCastBar.args.BorderOpts.args.border = {
	name = L["Borders"],
	order = 1,
	type = "color",
	hasAlpha = true,
	set = function(self, r,g,b,a)
		E.db.nameplates.castBar_bordercolor = { r, g, b, a }
		NP:UpdateAllPlates()
	end,
	get = function(self)
		return E.db.nameplates.castBar_bordercolor[1], E.db.nameplates.castBar_bordercolor[2], E.db.nameplates.castBar_bordercolor[3], E.db.nameplates.castBar_bordercolor[4]
	end,
}

E.GUI.args.NamePlates.args.tabSettings.args.plateCastBar.args.BorderOpts.args.backgroundcolor = {
	name = L["Background"],
	order = 2,
	type = "color",
	hasAlpha = true,
	set = function(self, r,g,b,a)
		E.db.nameplates.castBar_background = { r, g, b, a }
		NP:UpdateAllPlates()
	end,
	get = function(self)
		return E.db.nameplates.castBar_background[1], E.db.nameplates.castBar_background[2], E.db.nameplates.castBar_background[3], E.db.nameplates.castBar_background[4]
	end,
}

E.GUI.args.NamePlates.args.tabSettings.args.plateCastBar.args.BorderOpts.args.BorderTexture = {
	order = 2.1,
	type = 'border',
	name = L['Border texture'],
	values = E:GetBorderList(),
	set = function(info,value)
		E.db.nameplates.castBar_borderTexture = value
		NP:UpdateAllPlates()
	end,
	get = function(info) return E.db.nameplates.castBar_borderTexture end,
}

E.GUI.args.NamePlates.args.tabSettings.args.plateCastBar.args.BorderOpts.args.BackgroundTexture = {
	order = 2.2,
	type = 'statusbar',
	name = L['Background texture'],
	values = E.GetTextureList,
	set = function(info,value)
		E.db.nameplates.castBar_background_texture = value;
		NP:UpdateAllPlates()
	end,
	get = function(info) return E.db.nameplates.castBar_background_texture end,
}

E.GUI.args.NamePlates.args.tabSettings.args.plateCastBar.args.BorderOpts.args.BorderSize = {
	name = L['Border size'],
	type = "slider",
	order	= 2.3,
	min		= 1,
	max		= 32,
	step	= 1,
	set = function(info,val)
		E.db.nameplates.castBar_borderSize = val
		NP:UpdateAllPlates()
	end,
	get =function(info)
		return E.db.nameplates.castBar_borderSize
	end,
}

E.GUI.args.NamePlates.args.tabSettings.args.plateCastBar.args.BorderOpts.args.BorderInset = {
	name = L['Border inset'],
	type = "slider",
	order	= 2.4,
	min		= -32,
	max		= 32,
	step	= 1,
	set = function(info,val)
		E.db.nameplates.castBar_borderInset = val
		NP:UpdateAllPlates()
	end,
	get =function(info)
		return E.db.nameplates.castBar_borderInset
	end,
}

E.GUI.args.NamePlates.args.tabSettings.args.plateCastBar.args.BorderOpts.args.backgroundInset = {
	name = L['Background inset'],
	type = "slider",
	order	= 2.5,
	min		= -32,
	max		= 32,
	step	= 1,
	set = function(info,val)
		E.db.nameplates.castBar_backgroundInset = val
		NP:UpdateAllPlates()
	end,
	get =function(info)
		return E.db.nameplates.castBar_backgroundInset
	end,
}

E.GUI.args.NamePlates.args.tabSettings.args.healthBar_nameText = {
	name = L['Name text'],
	type = "group",
	order = 3.1,
	embend = true,
	args = {},
}

E.GUI.args.NamePlates.args.tabSettings.args.healthBar_nameText.args.Visability = {
	order = 0.1,
	type = 'dropdown',
	name = L['Visability'],
	values = {
		L['Always'],
		L['Only target'],
		L['Never'],
	},
	set = function(info,value)
		E.db.nameplates.healthBar_name_visability = value;
		NP:UpdateAllPlates()
		NP:UpdateCustomName()
	end,
	get = function(info) return E.db.nameplates.healthBar_name_visability end,
}

E.GUI.args.NamePlates.args.tabSettings.args.healthBar_nameText.args.attachTo = {
	order = 0.2,
	type = 'dropdown',
	name = L['Attach To'],
	values = {
		['TOPLEFT'] = L['Top left'],
		['TOPRIGHT'] = L['Top right'],
		['CENTER'] = L['Center'],
		['BOTTOMLEFT'] = L['Bottom left'],
		['BOTTOMRIGHT'] = L['Bottom right'],
		['BOTTOM'] = L['Bottom'],
		['TOP'] = L['Top'],
		['LEFT'] = L['Left'],
		['RIGHT'] = L['Right'],
	},
	set = function(info,value)
		E.db.nameplates.healthBar_name_attachTo = value;
		NP:UpdateAllPlates()
	end,
	get = function(info) return E.db.nameplates.healthBar_name_attachTo end,
}

E.GUI.args.NamePlates.args.tabSettings.args.healthBar_nameText.args.widthUpTo = {
	order = 0.3,
	type = 'dropdown',
	name = L['Width adjustment'],
	values = {
		L['To level text'],
		L['To bar'],
		L['Full width'],
		L['To health text'],
	},
	set = function(info,value)
		E.db.nameplates.healthBar_name_widthUpTo = value;
		NP:UpdateAllPlates()
	end,
	get = function(info) return E.db.nameplates.healthBar_name_widthUpTo end,
}

E.GUI.args.NamePlates.args.tabSettings.args.healthBar_nameText.args.xOffset = {
	name = L["Horizontal offset"],
	order = 1,
	type = "slider",
	min = -200, max = 200, step = 1,
	set = function(self, value)
		E.db.nameplates.healthBar_name_xOffset = value
		NP:UpdateAllPlates()
	end,
	get = function(self)
		return E.db.nameplates.healthBar_name_xOffset
	end,
}
E.GUI.args.NamePlates.args.tabSettings.args.healthBar_nameText.args.yOffset = {
	name = L["Vertical offset"],
	order = 1,
	type = "slider",
	min = -200, max = 200, step = 1,
	set = function(self, value)
		E.db.nameplates.healthBar_name_yOffset = value
		NP:UpdateAllPlates()
	end,
	get = function(self)
		return E.db.nameplates.healthBar_name_yOffset
	end,
}

E.GUI.args.NamePlates.args.tabSettings.args.healthBar_hpText = {
	name = L['Health text'],
	type = "group",
	order = 3.2,
	embend = true,
	args = {},
}
E.GUI.args.NamePlates.args.tabSettings.args.healthBar_hpText.args.textFormat = {
	name = L['Format'],
	type = 'dropdown',
	order = 0.1,
	values = {
		NO,
		L['Percent'],
		L['Current value'],
		L['Both'],
		L['Short percent']
	},
	set = function(info, value)
		E.db.nameplates.healthBar_hp_format = value

	end,
	get = function(info)
		return E.db.nameplates.healthBar_hp_format
	end,
}
E.GUI.args.NamePlates.args.tabSettings.args.healthBar_hpText.args.attachTo = {
	order = 0.2,
	type = 'dropdown',
	name = L['Attach To'],
	values = {
		['TOPLEFT'] = L['Top left'],
		['TOPRIGHT'] = L['Top right'],
		['CENTER'] = L['Center'],
		['BOTTOMLEFT'] = L['Bottom left'],
		['BOTTOMRIGHT'] = L['Bottom right'],
		['BOTTOM'] = L['Bottom'],
		['TOP'] = L['Top'],
		['LEFT'] = L['Left'],
		['RIGHT'] = L['Right'],
	},
	set = function(info,value)
		E.db.nameplates.healthBar_hp_attachTo = value;
		NP:UpdateAllPlates()
	end,
	get = function(info) return E.db.nameplates.healthBar_hp_attachTo end,
}

E.GUI.args.NamePlates.args.tabSettings.args.healthBar_hpText.args.xOffset = {
	name = L["Horizontal offset"],
	order = 1,
	type = "slider",
	min = -200, max = 200, step = 1,
	set = function(self, value)
		E.db.nameplates.healthBar_hp_xOffset = value
		NP:UpdateAllPlates()
	end,
	get = function(self)
		return E.db.nameplates.healthBar_hp_xOffset
	end,
}
E.GUI.args.NamePlates.args.tabSettings.args.healthBar_hpText.args.yOffset = {
	name = L["Vertical offset"],
	order = 1,
	type = "slider",
	min = -200, max = 200, step = 1,
	set = function(self, value)
		E.db.nameplates.healthBar_hp_yOffset = value
		NP:UpdateAllPlates()
	end,
	get = function(self)
		return E.db.nameplates.healthBar_hp_yOffset
	end,
}

E.GUI.args.NamePlates.args.tabSettings.args.healthBar_lvlText = {
	name = L['Level text'],
	type = "group",
	order = 3.2,
	embend = true,
	args = {},
}

E.GUI.args.NamePlates.args.tabSettings.args.healthBar_lvlText.args.Visability = {
	order = 0.1,
	type = 'dropdown',
	name = L['Visability'],
	values = {
		L['Always'],
		L['Only target'],
		L['Never'],
	},
	set = function(info,value)
		E.db.nameplates.healthBar_lvl_visability = value;
		NP:UpdateAllPlates()
		NP:UpdateCustomName()
	end,
	get = function(info) return E.db.nameplates.healthBar_lvl_visability end,
}

E.GUI.args.NamePlates.args.tabSettings.args.healthBar_lvlText.args.attachTo = {
	order = 0.2,
	type = 'dropdown',
	name = L['Attach To'],
	values = {
		['TOPLEFT'] = L['Top left'],
		['TOPRIGHT'] = L['Top right'],
		['CENTER'] = L['Center'],
		['BOTTOMLEFT'] = L['Bottom left'],
		['BOTTOMRIGHT'] = L['Bottom right'],
		['BOTTOM'] = L['Bottom'],
		['TOP'] = L['Top'],
		['LEFT'] = L['Left'],
		['RIGHT'] = L['Right'],
	},
	set = function(info,value)
		E.db.nameplates.healthBar_lvl_attachTo = value;
		NP:UpdateAllPlates()
	end,
	get = function(info) return E.db.nameplates.healthBar_lvl_attachTo end,
}

E.GUI.args.NamePlates.args.tabSettings.args.healthBar_lvlText.args.xOffset = {
	name = L["Horizontal offset"],
	order = 1,
	type = "slider",
	min = -200, max = 200, step = 1,
	set = function(self, value)
		E.db.nameplates.healthBar_lvl_xOffset = value
		NP:UpdateAllPlates()
	end,
	get = function(self)
		return E.db.nameplates.healthBar_lvl_xOffset
	end,
}
E.GUI.args.NamePlates.args.tabSettings.args.healthBar_lvlText.args.yOffset = {
	name = L["Vertical offset"],
	order = 1,
	type = "slider",
	min = -200, max = 200, step = 1,
	set = function(self, value)
		E.db.nameplates.healthBar_lvl_yOffset = value
		NP:UpdateAllPlates()
	end,
	get = function(self)
		return E.db.nameplates.healthBar_lvl_yOffset
	end,
}

E.GUI.args.NamePlates.args.spellList = {
	name = L["Spell List"],
	type = "group",
	order = 1,
	args = {},
}

E.GUI.args.NamePlates.args.spellList.args.create = {
	name = "",
	type = "group",
	order = 1,
	embend = true,
	args = {},
}

E.GUI.args.NamePlates.args.spellList.args.settings = {
	name = "",
	type = "group",
	order = 2,
	embend = true,
	args = {},
}

E.GUI.args.NamePlates.args.spellList.args.create.args.spellid = {
	name = "SpellID",
	type = "editbox",
	order = 1,
	set = function(self, value)
		local num = tonumber(value)
		if num and GetSpellInfo(num) then
			if not E.db.nameplates.spelllist[GetSpellInfo(num)] then

				E.db.nameplates.spelllist[GetSpellInfo(num)] = {}
				E.db.nameplates.spelllist[GetSpellInfo(num)].show = 1
				E.db.nameplates.spelllist[GetSpellInfo(num)].size = 1
				E.db.nameplates.spelllist[GetSpellInfo(num)].checkID = false
				E.db.nameplates.spelllist[GetSpellInfo(num)].spellID = num
				E.db.nameplates.spelllist[GetSpellInfo(num)].filter = 3
			end

			selectedspell = GetSpellInfo(num)
		end
	end,
	get = function(self)
		return ''
	end,

}

local spellListFilter = nil

E.GUI.args.NamePlates.args.spellList.args.create.args.spelllist = {
	name = L["Select spell"], width = 'full',
	type = "dropdown",
	order = 3,
	values = function()
		local t = {}

		for spellname, params in pairs(E.db.nameplates.spelllist) do
			if not spellListFilter or spellListFilter == 1 then
				t[spellname] = NP:SpellString(params.spellID)
			elseif spellListFilter == 3 and not params.filter then
				t[spellname] = NP:SpellString(params.spellID)
			elseif spellListFilter == params.filter then
				t[spellname] = NP:SpellString(params.spellID)
			end
			--t[spellname] = (spellname).." "..( params.size or 1 ).." "..( params.show and "SHOW" or "HIDE" ).." "..(params.spellID or "000000").." "..(params.checkID and "CheckID" or "NoCheckID")
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


E.GUI.args.NamePlates.args.spellList.args.create.args.spelllistFilter = {
	name = L['Filter'],
	order = 2,
	type = 'dropdown',
	values = {
		'All',
		'Embend',
		'Custom',
	},
	set = function(self, value)
		spellListFilter = value
	end,
	get = function(self)
		return 1
	end
}

E.GUI.args.NamePlates.args.spellList.args.settings.args.show = {
	name = L["Show"],
	type = "dropdown",
	order = 4,
	values = {
		 L["Always"],
		 L["Never"],
		 L["Only mine"],
		 L["Only on enemy"],
		 L["Only on friendly"],
	},
	set = function(self, value)
		if selectedspell then
			E.db.nameplates.spelllist[selectedspell].show = value
		end
	end,
	get = function(self)
		if selectedspell then
			return E.db.nameplates.spelllist[selectedspell].show or 1
		else
			return 1
		end
	end,
}

E.GUI.args.NamePlates.args.spellList.args.settings.args.spellID = {
	name = "SpellID",
	type = "editbox",
	order = 4,
	set = function(self, value)
		local num = tonumber(value)

		if selectedspell and num then
			E.db.nameplates.spelllist[selectedspell].spellID = num
		end
	end,
	get = function(self)
		if selectedspell then
			return E.db.nameplates.spelllist[selectedspell].spellID or ''
		else
			return ''
		end
	end,
}

E.GUI.args.NamePlates.args.spellList.args.settings.args.checkID = {
	name = "CheckID",
	type = "toggle",
	order = 4,
	set = function(self, value)
		if selectedspell then
			E.db.nameplates.spelllist[selectedspell].checkID = not E.db.nameplates.spelllist[selectedspell].checkID
		end
	end,
	get = function(self)
		if selectedspell then
			return E.db.nameplates.spelllist[selectedspell].checkID or false
		else
			return false
		end
	end,
}

E.GUI.args.NamePlates.args.spellList.args.settings.args.size = {
	name = L["Size"],
	type = "slider", min = 1, max = 2, step = 0.1,
	order = 4,
	set = function(self, value)
		if selectedspell then
			E.db.nameplates.spelllist[selectedspell].size = value
		end
	end,
	get = function(self)
		if selectedspell then
			return E.db.nameplates.spelllist[selectedspell].size or 1
		else
			return 1
		end
	end,
}


E.GUI.args.NamePlates.args.nameList = {
	name = L["Name List"],
	type = "group",
	order = 1,
	args = {},
}

E.GUI.args.NamePlates.args.nameList.args.create = {
	name = "",
	type = "group",
	order = 1,
	embend = true,
	args = {},
}

E.GUI.args.NamePlates.args.nameList.args.settings = {
	name = "",
	type = "group",
	order = 2,
	embend = true,
	args = {},
}

E.GUI.args.NamePlates.args.nameList.args.create.args.spellid = {
	name = L["Name"],
	type = "editbox",
	order = 1,
	set = function(self, value)
		if value and #value > 0 then
			if not E.db.nameplates.namelist[value] then
				E.db.nameplates.namelist[value] = {
					show = true,
					subname = value
				}
			end
			selectedname = value

			NP:UpdateCustomName()
		end
	end,
	get = function(self)
		return ''
	end,

}


E.GUI.args.NamePlates.args.nameList.args.create.args.namelist = {
	name = L["Select name"],
	type = "dropdown",
	order = 2,
	values = function()
		local t = {}

		for name,params in pairs(E.db.nameplates.namelist) do
			t[name] = name
		end

		NP:UpdateCustomName()

		return t
	end,
	set = function(self, value)
		selectedname = value
	end,
	get = function(self)
		return selectedname
	end,
}

E.GUI.args.NamePlates.args.nameList.args.create.args.namefromtarget = {
	name = L["Name from target"],
	type = "execute",
	order = 3,
	set = function(self, value)
		if UnitExists("target") and not UnitIsPlayer("target") then
			local name = UnitName("target")
			E.db.nameplates.namelist[name] = {
				show = true,
				subname = name
			}

			NP:UpdateCustomName()

			selectedname = name
		end
	end,
	get = function(self)
		return ''
	end,

}

E.GUI.args.NamePlates.args.nameList.args.settings.args.checkID = {
	name = L["Enable"],
	type = "toggle",
	order = 4,
	set = function(self, value)
		if selectedname then
			E.db.nameplates.namelist[selectedname].show = not E.db.nameplates.namelist[selectedname].show
			NP:UpdateCustomName()
		end
	end,
	get = function(self)
		if selectedname then
			return E.db.nameplates.namelist[selectedname].show
		else
			return false
		end
	end,
}

E.GUI.args.NamePlates.args.nameList.args.settings.args.subname = {
	name = L["Name"],
	type = "editbox",
	width = 'full',
	order = 1,
	set = function(self, value)
		if selectedname then
			if value and #value > 0 then
				E.db.nameplates.namelist[selectedname].subname = value
				NP:UpdateCustomName()
			end
		end
	end,
	get = function(self)
		if selectedname then
			return E.db.nameplates.namelist[selectedname].subname or ''
		else
			return ''
		end
	end,

}

E.GUI.args.NamePlates.args.blackList = {
	name = L["Black List"],
	type = "group",
	order = 1,
	args = {},
}

E.GUI.args.NamePlates.args.blackList.args.create = {
	name = "",
	type = "group",
	order = 1,
	embend = true,
	args = {},
}

E.GUI.args.NamePlates.args.blackList.args.settings = {
	name = "",
	type = "group",
	order = 2,
	embend = true,
	args = {},
}

E.GUI.args.NamePlates.args.blackList.args.create.args.spellid = {
	name = L["Name"],
	type = "editbox",
	order = 1,
	set = function(self, value)
		if value and #value > 0 then
			local name, rank, icon, castingTime, minRange, maxRange, spellID = GetSpellInfo(value)

			if name then
				E.db.nameplates.blacklist[name] = { enable = true, spellID = spellID }
			end

			selectedspellbl = name
		end
	end,
	get = function(self)
		return ''
	end,

}


E.GUI.args.NamePlates.args.blackList.args.create.args.namelist = {
	name = L["Select spell"],
	type = "dropdown",
	order = 2,
	values = function()
		local t = {}

		for spellname,params in pairs(E.db.nameplates.blacklist) do
			t[spellname] = NP:SpellString(params.spellID)
		end

		return t
	end,
	set = function(self, value)
		selectedspellbl = value
	end,
	get = function(self)
		return selectedspellbl
	end,
}


E.GUI.args.NamePlates.args.blackList.args.settings.args.enable = {
	name = L["Enable"],
	type = "toggle",
	order = 4,
	set = function(self, value)
		if selectedspellbl then
			E.db.nameplates.blacklist[selectedspellbl].enable = not E.db.nameplates.blacklist[selectedspellbl].enable
		end
	end,
	get = function(self)
		if selectedspellbl then
			return E.db.nameplates.blacklist[selectedspellbl].enable
		else
			return false
		end
	end,
}

E.GUI.args.NamePlates.args.blackList.args.settings.args.spellID = {
	name = "SpellID",
	type = "editbox",
	order = 4,
	set = function(self, value)
		local num = tonumber(value)

		if selectedspellbl and num then
			E.db.nameplates.blacklist[selectedspellbl].spellID = num
		end
	end,
	get = function(self)
		if selectedspellbl then
			return E.db.nameplates.blacklist[selectedspellbl].spellID or ''
		else
			return ''
		end
	end,
}

E.GUI.args.NamePlates.args.blackList.args.settings.args.checkID = {
	name = "CheckID",
	type = "toggle",
	order = 4,
	set = function(self, value)
		if selectedspellbl then
			E.db.nameplates.blacklist[selectedspellbl].checkID = not E.db.nameplates.blacklist[selectedspellbl].checkID
		end
	end,
	get = function(self)
		if selectedspellbl then
			return E.db.nameplates.blacklist[selectedspellbl].checkID or false
		else
			return false
		end
	end,
}

do
	local hidegametooltip = CreateFrame("Frame")
	hidegametooltip:Hide()
	local gametooltip = CreateFrame("GameTooltip", "KFDjkfsjdfkljsdfshdfkjhsdfGameToolTip", hidegametooltip, 'GameToolTipTemplate')
	gametooltip:SetScript('OnTooltipAddMoney', function()end)
	gametooltip:SetScript('OnTooltipCleared', function()end)
	gametooltip:SetScript('OnHide', function()end)
	gametooltip:SetScript('OnTooltipSetDefaultAnchor',function()end)
	gametooltip:SetOwner(hidegametooltip,"ANCHOR_NONE")

	local match = string.match
	local lower = string.lower
	--SetUnitAura
	function NP.GetCustomTooltip()
		return gametooltip
	end

	function NP.CheckForContainTooltip(tooltip, str)

		if not tooltip or not str then return end
		str = lower(str)

		for i = 1, tooltip:NumLines() do
			local left = _G[tooltip:GetName().."TextLeft"..i]:GetText()
			local right = _G[tooltip:GetName().."TextRight"..i]:GetText()

			if left then
				local result = match(lower(left), str)
				if result then
					return result, left
				end
			end

			if right then
				local result = match(lower(right), str)
				if result then
					return result, right
				end
			end
		end

		return false
	end

	function NP.GetAuraControllType(tooltip)
		if not tooltip then return end

		local text = _G[tooltip:GetName().."TextLeft2"]:GetText()
	--	local text2 = _G[tooltip:GetName().."TextLeft3"]:GetText()

		local result

		if text then
			if match(lower(text), 'оглушение.$') then
				result = 'STUN'
			elseif match(lower(text), 'дезориентаци¤.$') then
				result = 'DEZO'
			elseif match(lower(text), 'немота.$') then
				result = 'SILENT'
			elseif match(lower(text), 'паралич.$') then
				result = 'PARA'
			end
		end

		return result, text
	end
end

E.spellContol = {
	[118905] = "STUN",
	[221792] = "STUN",
	[1833] = "STUN",
	[223911] = "STUN",
	[226943] = "STUN",
	[22703] = "STUN",
	[91800] = "STUN",
	[200200] = "STUN",
	[132168] = "STUN",
	[224729] = "DEZO",
	[132169] = "STUN",
	[15487] = "SILENT",
	[232055] = "STUN",
	[207171] = "STUN",
	[1330] = "SILENT",
	[211881] = "STUN",
	[8122] = "DEZO",
	[222897] = "STUN",
	[179057] = "STUN",
	[163505] = "STUN",
	[212337] = "STUN",
	[171017] = "STUN",
	[91797] = "STUN",
	[207167] = "DEZO",
	[30283] = "STUN",
	[200166] = "STUN",
	[105421] = "DEZO",
	[196958] = "STUN",
	[5211] = "STUN",
	[205290] = "STUN",
	[99] = "PARA",
	[1776] = "PARA",
	[200196] = "PARA",
	[201070] = "STUN",
	[81261] = "SILENT",
	[207165] = "STUN",
	[118699] = "DEZO",
	[207685] = "DEZO",
	[51514] = "PARA",
	[5246] = "DEZO",
	[77505] = "STUN",
	[853] = "STUN",
	[204399] = "STUN",
	[212332] = "STUN",
	[117526] = "STUN",
	[408] = "STUN",
	[224074] = "STUN",
	[221562] = "STUN",
	[31935] = "SILENT",
	[214459] = "SILENT",
	[222783] = "SILENT",
	[119381] = "STUN",
	[199804] = "STUN",
	[2094] = "DEZO",
	[205238] = "STUN",
	[204490] = "SILENT",
	[214203] = "STUN",
	[24394] = "STUN",
	[6770] = "PARA",
}

E.StunList = {}
E.StunDRs = {}
E.StunTimer = {}

--NP:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

function NP:COMBAT_LOG_EVENT_UNFILTERED(event, ...)
	local timestamp, eventType, hideCaster,
			srcGUID, srcName, srcFlags, srcFlags2,
			dstGUID, dstName, dstFlags, dstFlags2,
			spellID, spellName, spellSchool = ...

	if ( eventType == 'SPELL_AURA_APPLIED' or eventType == 'SPELL_AURA_REFRESH' ) and E.spellContol[spellID] == 'STUN' then
		if not E.StunTimer[dstGUID] or E.StunTimer[dstGUID] < GetTime() then
			E.StunTimer[dstGUID] = GetTime()+18
			E.StunDRs[dstGUID] = 1
		end

		if E.StunTimer[dstGUID] then
			E.StunDRs[dstGUID] = E.StunDRs[dstGUID] * 0.5
		end


		for _, frame in pairs(GetNamePlates()) do
			if frame.AleaNP.unit and frame.AleaNP.guid == dstGUID then
				frame.AleaNP:UpdateDRs('Stun')
			end
		end
	end
end
