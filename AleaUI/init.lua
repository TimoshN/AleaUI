local addonName, E = ...
local LSM = LibStub("LibSharedMedia-3.0")
local L = E.L
_G[addonName] = E

local core = E:Module('Core')
----------------------------------
--			GLOBALS				--
----------------------------------
E.myname = UnitName("player") 
E.myrealm = GetRealmName()
E.myclass = select(2, UnitClass("player"))

E.resolution = ({GetScreenResolutions()})[GetCurrentResolution()] or GetCVar("gxWindowedResolution")
E.screenwidth, E.screenheight = DecodeResolution(E.resolution)
E.multi = 768/string.match(E.resolution, "%d+x(%d+)")/ ( math.max(0.64, math.min(1.15, 768/E.screenheight)))


local versionStr, internalVersion, dateofpatch, uiVersion = GetBuildInfo(); internalVersion = tonumber(internalVersion)

E.version = GetAddOnMetadata(addonName, "Version")
E.wowbuild = internalVersion
E.uibuild	= tonumber(uiVersion)
E.IsLegion	= true

if E.uibuild >= 70200 then
	E.removeLagTolerance = true
end


E.isClassic = E.uibuild < 20000

E.media = {}
E.media.default_font_name = "Gothic-Bold"
E.media.default_font = [[Interface\AddOns\AleaUI\media\GOTHICB.TTF]]
E.media.default_font_size = 10

E.media.default_font_name2 = "PT-Sans-Narrow-Bold"
E.media.default_font2 = [[Interface\AddOns\AleaUI\media\PT-Sans-Narrow-Bold.TTF]]
E.media.default_font_size2 = 12
E.media.default_bar_texture_name1 = "Minimalist"
E.media.default_bar_texture1 = [[Interface\AddOns\AleaUI\media\Minimalist.tga]]

E.media.default_bar_texture_name2 = "Flat"
E.media.default_bar_texture2 = [[Interface\AddOns\AleaUI\media\Flat.tga]]

E.media.default_bar_texture_name3 = "WHITE8x8"
E.media.default_bar_texture3 = [[Interface\Buttons\WHITE8x8]]

E.media.texCoord = { 0.07, 0.93, 0.07, 0.93}

local FontList = {
	["Default"] = STANDARD_TEXT_FONT,
	["Arial"] = "Fonts\\ARIALN.TTF",
	["Skurri"] = "Fonts\\skurri.ttf",
	["Morpheus"] = "Fonts\\MORPHEUS.ttf",
	
	["Gothic-Bold"] = [[Interface\AddOns\AleaUI\media\GOTHICB.TTF]],

	["PT-Sans-Narrow-Bold"] = [[Interface\AddOns\AleaUI\media\PT-Sans-Narrow-Bold.TTF]],
	
	['Homespun'] = [[Interface\AddOns\AleaUI\media\Homespun.ttf]],
	['OpenSans-Bold'] = [[Interface\AddOns\AleaUI\media\OpenSans-Bold.ttf]],
	['OpenSans-SemiBold'] = [[Interface\AddOns\AleaUI\media\OpenSans-SemiBold.ttf]],
	--[==[
	['OpenSans-ExtraBold'] = [[Interface\AddOns\AleaUI\media\OpenSans-ExtraBold.ttf]],
	['Gilroy-Bold'] = [[Interface\AddOns\AleaUI\media\Gilroy-Bold.ttf]],
	['Gilroy-SemiBold'] = [[Interface\AddOns\AleaUI\media\Gilroy-SemiBold.ttf]],
	['AvantGarde'] = [[Interface\AddOns\AleaUI\media\Avant_Garde.ttf]],
	]==]

	['URW Gothic'] = [[Interface\AddOns\AleaUI\media\URW Gothic.ttf]],
}

local Textures = {
	["Blizzad"] = "Interface\\PaperDollInfoFrame\\UI-Character-Skills-Bar", 
	[E.media.default_bar_texture_name1] = E.media.default_bar_texture1,
	[E.media.default_bar_texture_name2] = E.media.default_bar_texture2,
	[E.media.default_bar_texture_name3] = E.media.default_bar_texture3,
	['Glow'] = "Interface\\AddOns\\AleaUI\\media\\glow",
}

do
	local OnLSMUpdate = {}
	
	local function UpdateLSM()
		for i=1, #OnLSMUpdate do	
			OnLSMUpdate[i]()	
		end
	end
	
	local LSM_Update = CreateFrame("Frame")
	LSM_Update:Hide()
	LSM_Update:SetScript("OnUpdate", function(self, elapsed)
		self.elapsed = ( self.elapsed or 0 ) + elapsed	
		if self.elapsed < 0.1 then return end
		
	--	E:UpdateBlizzardFont()
		
		UpdateLSM()
		self:Hide()
		self.elapsed = 0
	end)
	
	E.LSM_Update = LSM_Update
	
	function E.OnLSMUpdateRegister(func)	
		OnLSMUpdate[#OnLSMUpdate+1] = func
	end
end

do
	LSM:Register("font", "Gothic-Bold", [[Interface\AddOns\AleaUI\media\GOTHICB.TTF]], LSM.LOCALE_BIT_ruRU + LSM.LOCALE_BIT_western)
	LSM:Register("font", "PT-Sans-Narrow-Bold", [[Interface\AddOns\AleaUI\media\PT-Sans-Narrow-Bold.TTF]], LSM.LOCALE_BIT_ruRU + LSM.LOCALE_BIT_western)
	LSM:Register('font', 'Homespun', [[Interface\AddOns\AleaUI\media\Homespun.ttf]], LSM.LOCALE_BIT_ruRU + LSM.LOCALE_BIT_western)
	LSM:Register('font', 'OpenSans-Bold', [[Interface\AddOns\AleaUI\media\OpenSans-Bold.ttf]], LSM.LOCALE_BIT_ruRU + LSM.LOCALE_BIT_western)
	LSM:Register('font', 'OpenSans-SemiBold', [[Interface\AddOns\AleaUI\media\OpenSans-SemiBold.ttf]], LSM.LOCALE_BIT_ruRU + LSM.LOCALE_BIT_western)
	--[==[
	LSM:Register('font', 'OpenSans-ExtraBold', [[Interface\AddOns\AleaUI\media\OpenSans-ExtraBold.ttf]], LSM.LOCALE_BIT_ruRU + LSM.LOCALE_BIT_western)
	LSM:Register('font', 'Gilroy-Bold', [[Interface\AddOns\AleaUI\media\Gilroy-Bold.ttf]], LSM.LOCALE_BIT_ruRU + LSM.LOCALE_BIT_western)
	LSM:Register('font', 'Gilroy-SemiBold', [[Interface\AddOns\AleaUI\media\Gilroy-SemiBold.ttf]], LSM.LOCALE_BIT_ruRU + LSM.LOCALE_BIT_western)
	LSM:Register('font', 'AvantGarde', [[Interface\AddOns\AleaUI\media\Avant_Garde.ttf]], LSM.LOCALE_BIT_ruRU + LSM.LOCALE_BIT_western)
	]==]
	LSM:Register('font', 'URW Gothic', [[Interface\AddOns\AleaUI\media\URW Gothic.ttf]], LSM.LOCALE_BIT_ruRU + LSM.LOCALE_BIT_western)
	
	LSM:Register("statusbar", E.media.default_bar_texture_name1,E.media.default_bar_texture1)
	LSM:Register("statusbar", E.media.default_bar_texture_name2,E.media.default_bar_texture2)
	LSM:Register("statusbar", E.media.default_bar_texture_name3, E.media.default_bar_texture3)
	LSM:Register("statusbar", "BantoBar", "Interface\\AddOns\\AleaUI\\media\\Bantobar")
	LSM:Register("statusbar", "Smoothv2", "Interface\\AddOns\\AleaUI\\media\\Smoothv2")

	LSM:Register("border", E.media.default_bar_texture_name3, E.media.default_bar_texture3)
	LSM:Register("border", 'Glow', "Interface\\AddOns\\AleaUI\\media\\glow")
	LSM:Register("border", 'Pixel Border', "Interface\\AddOns\\AleaUI\\media\\BorderSquarePerso2")
	LSM:Register("border", 'Simple Square', "Interface\\AddOns\\AleaUI\\media\\SimpleSquare.tga")
	LSM:Register("border", '2хPixel Border', "Interface\\AddOns\\AleaUI\\media\\2px_tooltip_border.tga")

	LSM:Register('sound', "AleaUI: Cat Meow", "Interface\\AddOns\\AleaUI\\media\\CatMeow2.mp3")
	LSM:Register('sound', "AleaUI: Cat", "Interface\\Addons\\AleaUI\\media\\cat2.mp3")	
end

function E:GetTextureList()
	return LSM:HashTable("statusbar") or Textures
end

function E:GetTexture(value)
	return LSM:Fetch("statusbar",value) or Textures[value] or "Interface\\PaperDollInfoFrame\\UI-Character-Skills-Bar"
end

function E:GetFontList()		
	return LSM:HashTable("font") -- FontList
end	

function E:GetFont(value)
	return LSM:Fetch("font",value) or FontList[value] or STANDARD_TEXT_FONT
end

function E:GetBorderList()
	return LSM:HashTable("border") -- FontList
end

function E:GetBorder(value)
	return LSM:Fetch("border",value) or Textures[value] or E.media.default_bar_texture3
end

local altManaBar = {}
altManaBar['DRUID'] = true
altManaBar['MONK'] = true
function E:HasAltManaBar()
	local class = E.myclass
	
	return true
end
---------------------------------

function E.IsClass(class)
	return E.myclass == class
end


local CanDispel = {
	PRIEST = { Magic = true, Disease = true },
	SHAMAN = { Magic = false, Curse = true },
	PALADIN = { Magic = false, Poison = true, Disease = true },
	DRUID = { Magic = false, Curse = true, Poison = true, Disease = false },
	MONK = { Magic = false, Poison = true, Disease = true }
}

---------------------------------
function GetMiniMapButtonsRad()
	return 80 --( E.db and  E.db.minimap ) and E.db.minimap.minimap_size or 65
end

function GetMinimapShape()
	return 'SQUARE'
end

local parent = CreateFrame('Frame', addonName..'Parent', UIParent)
	parent:SetFrameLevel(UIParent:GetFrameLevel())
	parent:SetPoint('TOPLEFT', UIParent, 'TOPLEFT')
	parent:SetPoint('BOTTOMRIGHT', UIParent, 'BOTTOMRIGHT')
	parent:SetSize(1,1)	
E.UIParent = parent

function E:SetupCVars()
	
	SetCVar("cameraSmoothTrackingStyle", E.db.cVars.cameraSmoothTrackingStyle and 0 or 4)

	SetCVar("SpellQueueWindow", E.db.cVars.MaxSpellStartRecoveryOffset)	

	if ( not E.isClassic ) then 
		E:LockCVar("cameraDistanceMaxFactor", 2.6)
		MoveViewOutStart(50000)
	end

	SetCVar("statusTextDisplay", "BOTH")
	SetCVar("ShowClassColorInNameplate", 1)
	SetCVar("screenshotQuality", 10)
	SetCVar("chatMouseScroll", 1)
	SetCVar("chatStyle", 'im') -- im
	SetCVar("WholeChatWindowClickable", 0)
--	SetCVar("ConversationMode", "inline")
	SetCVar("showTutorials", 0)
	SetCVar("UberTooltips", 1)
	if ( not E.isClassic ) then 
		SetCVar("threatWarning", 3)
	end
	SetCVar('alwaysShowActionBars', 1)
	SetCVar('lockActionBars', 1)
	SetCVar('SpamFilter', 0)
	SetCVar("whisperMode","inline")
	if ( not E.isClassic ) then 
		E:LockCVar('displaySpellActivationOverlays', E.chardb.cVars['displaySpellActivationOverlays'] and 1 or 0)
	end
	
	core:UpdateQuestTrackingTooltips()
end

function core:PLAYER_LOGIN() -- self - core, 1 - event , 2+ - args
	
--	E:UpdateBlizzardFont()
	
	E.myname = UnitName("player") 
	E.myrealm = GetRealmName()
	E.myclass = select(2, UnitClass("player"))
	
	if ( not E.isClassic ) then 
		core:PLAYER_SPECIALIZATION_CHANGED()	 
		core:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
	end

	E:InitFrames()
	E:InitFrames3()
	
	E:SetupCVars()
	
	ToggleChatColorNamesByClassGroup(true, "SAY")
	ToggleChatColorNamesByClassGroup(true, "EMOTE")
	ToggleChatColorNamesByClassGroup(true, "YELL")
	ToggleChatColorNamesByClassGroup(true, "GUILD")
	ToggleChatColorNamesByClassGroup(true, "OFFICER")
	ToggleChatColorNamesByClassGroup(true, "GUILD_ACHIEVEMENT")
	ToggleChatColorNamesByClassGroup(true, "ACHIEVEMENT")
	ToggleChatColorNamesByClassGroup(true, "WHISPER")
	ToggleChatColorNamesByClassGroup(true, "PARTY")
	ToggleChatColorNamesByClassGroup(true, "PARTY_LEADER")
	ToggleChatColorNamesByClassGroup(true, "RAID")
	ToggleChatColorNamesByClassGroup(true, "RAID_LEADER")
	ToggleChatColorNamesByClassGroup(true, "RAID_WARNING")
	ToggleChatColorNamesByClassGroup(true, "BATTLEGROUND")
	ToggleChatColorNamesByClassGroup(true, "BATTLEGROUND_LEADER")
	ToggleChatColorNamesByClassGroup(true, "INSTANCE_CHAT")
	ToggleChatColorNamesByClassGroup(true, "INSTANCE_CHAT_LEADER")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL1")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL2")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL3")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL4")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL5")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL6")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL7")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL8")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL9")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL10")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL11")
	
	E.LSM_Update:Show()
end

-- "BOTTOMAleaUIParentBOTTOM0130"

local default_settings = {
	Frames = {
		["staggerFrame"] = {
			["point"] = "BOTTOMAleaUIParentBOTTOM0130",
		},
		["arenaFrames"] = {
			["point"] = "RIGHTAleaUIParentRIGHT-9020",
		},
		["arcaneChargesFrame"] = {
			["point"] = "BOTTOMAleaUIParentBOTTOM0130",
		},
		["insanityFrame"] = {
			["point"] = "BOTTOMAleaUIParentBOTTOM0130",
		},
		["maelstromFrame"] = {
			["point"] = "BOTTOMAleaUIParentBOTTOM0130",
		},
		["eclipseFrame"] = {
			["point"] = "BOTTOMAleaUIParentBOTTOM0130",
		},
		["bossFrames"] = {
			["point"] = "RIGHTAleaUIParentRIGHT-10020",
		},
		["totembarFrame"] = {
			["point"] = "BOTTOMAleaUIParentBOTTOM0130",
		},
		["demonicFrame"] = {
			["point"] = "BOTTOMAleaUIParentBOTTOM0130",
		},
		["targetFrame"] = {
			["point"] = "TOPAleaUIParentTOP295-44",
		},
		["holypowerFrame"] = {
			["point"] = "CENTERAleaUIParentCENTER00",
		},
		["targetcastbarFrame"] = {
			["point"] = "CENTERAleaUIParentCENTER-6198",
		},
		["castbarFrame"] = {
			["point"] = "BOTTOMAleaUIParentBOTTOM-1148",
		},
		["watchFrameMover"] = {
			["point"] = "TOPRIGHTAleaUIParentTOPRIGHT-40-180",
		},
		["soulshardFrame"] = {
			["point"] = "BOTTOMAleaUIParentBOTTOM0130",
		},
		["lootrollFrame"] = {
			["point"] = "CENTERAleaUIParentCENTER0-233",
		},
		["targettargetFrame"] = {
			["point"] = "TOPAleaUIParentTOP295-20",
		},
		["shadoworbFrame"] = {
			["point"] = "BOTTOMAleaUIParentBOTTOM0135",
		},
		["chibarFrame"] = {
			["point"] = "BOTTOMAleaUIParentBOTTOM0130",
		},
		["garrisonMinimapButton"] = {
			["minimapPos"] = 39.1735780182619,
		},
		["tankMoverFrame"] = {
			["point"] = "BOTTOMRIGHTAleaUIParentBOTTOMRIGHT-10183",
		},
		["minimapFrames"] = {
			["point"] = "TOPLEFTAleaUIParentTOPLEFT27-6",
		},
		["debuffframeHeader"] = {
			["point"] = "TOPRIGHTAleaUIParentTOPRIGHT-5-150",
		},
		["draenorZoneAbilityFrame"] = {
			["point"] = "TOPLEFTAleaUIParentTOPLEFT206-87",
			["scale"] = 0.5,
		},
		["BagFrameButonsMover"] = {
			["point"] = "BOTTOMAleaUIParentBOTTOM-2675",
		},
		["combopointFrame"] = {
			["point"] = "BOTTOMAleaUIParentBOTTOM0130",
		},
		["OverrideBarMover"] = {
			["point"] = "CENTERAleaUIParentCENTER0-176",
		},
		["focusFrame"] = {
			["point"] = "CENTERAleaUIParentCENTER-41089",
		},
		["runesFrame"] = {
			["point"] = "BOTTOMAleaUIParentBOTTOM0130",
		},
		["focustcastbarFrame"] = {
			["point"] = "CENTERAleaUIParentCENTER-41055",
		},
		["extraActionFrame"] = {
			["point"] = "BOTTOMAleaUIParentBOTTOM33247",
		},
		["GameTooltipMover"] = {
			["point"] = "CENTERAleaUIParentCENTER415-134",
		},
		["petFrame"] = {
			["point"] = "TOPAleaUIParentTOP-295-22",
		},
		["xpbarFrame"] = {
			["point"] = "TOPAleaUIParentTOP0-5",
		},
		["playerFrame"] = {
			["point"] = "TOPAleaUIParentTOP-295-44",
		},
		["buffframeHeader"] = {
			["point"] = "TOPRIGHTAleaUIParentTOPRIGHT-5-5",
		},
		["alertMover"] = {
			["point"] = "BOTTOMAleaUIParentBOTTOM0170",
		},
		["powerbarFrame"] = {
			["point"] = "BOTTOMAleaUIParentBOTTOM333107",
		},
		["bagsFrameHeader"] = {
			["point"] = "BOTTOMRIGHTAleaUIParentBOTTOMRIGHT-425",
		},
		["raidframeHeader"] = {
			["point"] = "BOTTOMLEFTAleaUIParentBOTTOMLEFT4196",
		},
		["AleaAB_1"] = {
			["point"] = "BOTTOMAleaUIParentBOTTOM04",
		},
		["AleaAB_2"] = {
			["point"] = "BOTTOMAleaUIParentBOTTOM064",
		},
		["AleaAB_3"] = {
			["point"] = "BOTTOMAleaUIParentBOTTOM034",
		},
		["AleaAB_4"] = {
			["point"] = "CENTERAleaUIParentCENTER00",
		},
		["AleaAB_5"] = {
			["point"] = "CENTERAleaUIParentCENTER00",
		},
		["AleaAB_6"] = {
			["point"] = "CENTERAleaUIParentCENTER00",
		},
		["ShiftActionBar"] = {
			["point"] = "TOPLEFTAleaUIParentTOPLEFT172-4",
		},
		["PetAB"] = {
			["point"] = "RIGHTAleaUIParentRIGHT-30-35",
		},
		['MinimapDataTextPanel'] = {
			["point"] = "TOPLEFTMinimapBOTTOMLEFT-10",
		},
		['LeftDataTextPanel'] = {
			["point"] = "BOTTOMLEFTAleaUIParentBOTTOMLEFT33",
		},
		['RightDataTextPanel'] = {
			["point"] = "BOTTOMRIGHTAleaUIParentBOTTOMRIGHT-33",
		},	
		["actionBarMover"] = {
			["showOnEnter"] = true,
			["enable"] = true,
			["point"] = "TOPLEFTAleaUIParentTOPLEFT7-172",
			["perrow"] = 6,
		},
		['TalkingHeadMover'] = {
			["point"] = "TOPAleaUIParentTOP0-30",		
		},
	},
	cVars = {
		["cameraDistanceMax"] = 50,
		["cameraDistanceMaxFactor"] = 5,
		["cameraSmoothTrackingStyle"] = true,
		
		['reducedLagTolerance'] = false,
		['MaxSpellStartRecoveryOffset'] = 50,
		['disableSpellAlerts'] = false,
		
		['displaySpellActivationOverlays'] = false,
		
		['showQuestTrackingTooltips'] = true,
	},
	
	applyChatSettings = {},
	
	disableTooltipInCombat = false,
}	

E.default_settings = default_settings

local default_chat_settings = {
	cVars = {
		['displaySpellActivationOverlays'] = true,	
		['showQuestTrackingTooltips'] = true,
	},
}

E.default_chat_settings = default_chat_settings

local gui = {}
gui.title = format("%s %s", addonName..( E.version and ' v'..E.version or '' ), L["(moving is there)"])
gui.args = {}
gui.args.general = {		
	name = L["General"],
	order = 1,
	expand = false,
	type = "group",
	args = {}
}

gui.args.general.args.cameraSmoothTrackingStyle = {
	name = L["Disable following camera by channeling spells"],
	order = 3, width = 'full',
	type = "toggle",
	set = function(self, value)		
		E.db.cVars.cameraSmoothTrackingStyle = not E.db.cVars.cameraSmoothTrackingStyle
		SetCVar("cameraSmoothTrackingStyle", E.db.cVars.cameraSmoothTrackingStyle and 0 or 4)
	end,
	get = function(self)
		return E.db.cVars.cameraSmoothTrackingStyle
	end
}

gui.args.general.args.MaxSpellStartRecoveryOffset = {
	name = L["Spell Queue Window"],
	order = 4,
	type = "slider",
	min = 0, max = 400, step = 1,
	set = function(self, value)		
		E.db.cVars.MaxSpellStartRecoveryOffset = value
		SetCVar("SpellQueueWindow", value)
	end,
	get = function(self)
		return E.db.cVars.MaxSpellStartRecoveryOffset 
	end
}

gui.args.general.args.displaySpellActivationOverlays = {
	name = L["Display spell activation alerts"],
	order = 3, width = 'full',
	type = "toggle",
	set = function(self, value)		
		E.chardb.cVars['displaySpellActivationOverlays'] = not E.chardb.cVars['displaySpellActivationOverlays']
		E:LockCVar("displaySpellActivationOverlays", E.chardb.cVars['displaySpellActivationOverlays'] and 1 or 0)
	end,
	get = function(self)
		return E.chardb.cVars['displaySpellActivationOverlays']
	end
}

gui.args.general.args.showQuestTrackingTooltips = {
	name = L["Show quest tracking for tooltip in raid"],
	order = 3.1, width = 'full',
	type = "toggle",
	set = function(self, value)		
		E.chardb.cVars['showQuestTrackingTooltips'] = not E.chardb.cVars['showQuestTrackingTooltips']	
		core:UpdateQuestTrackingTooltips()
	end,
	get = function(self)
		return E.chardb.cVars['showQuestTrackingTooltips']
	end
}

gui.args.general.args.disableTooltipInCombat = {
	name = L["Disable tooltip while in combat"],
	order = 4.1, width = 'full',
	type = "toggle",
	set = function(self, value)		
		E.db.disableTooltipInCombat = not E.db.disableTooltipInCombat
	end,
	get = function(self)
		return E.db.disableTooltipInCombat
	end
}

gui.args.actionbars = {		
	name = L["Action Bars"],
	order = 2,
	expand = false,
	type = "group",
	args = {
		Binging = {
			type = 'execute',
			order = 0.1,
			name = L['Key Binds'],
			func = function(info, value)
				E:Module('ActionBars'):ToggleKeyBinds()		
			end,
		},	
	}
}

gui.args.unitframes = {		
	name = L["Unit frames"],
	order = 3,
	expand = false,
	type = "group",
	args = {}
}

gui.args.filters = {		
	name = L["Filters"],
	order = 3,
	expand = false,
	type = "group",
	args = {}
}

gui.args.import_export ={
	order = 99997,name = L["Export & Import Profile"],type = "group",
	args={
		Export = {
			type = 'execute',
			order = -99,
			name = L['Export'],
			func = function(info, value)
				E:ExportProfile()			
			end,
		},
		Import = {
			type = 'execute',
			order = -98,
			name = L['Import'],
			func = function(info, value)
				E:ImportProfile()	
			end,
		},
	},
}
	
E.GUI = gui
AleaUI_GUI:RegisterMainFrame(addonName, E.GUI, 820, 550, 820, 550)
local function ShowHideUI()
	if AleaUI_GUI:IsOpened(addonName) then
		AleaUI_GUI:Close(addonName)
	else
		AleaUI_GUI:Open(addonName)
	end
end

function core:ADDON_LOADED(event, name)
	if addonName ~= name then return end
	
	E:UpdateBlizzardFont()
	
	E.myname = UnitName("player") 
	E.myrealm = GetRealmName()
	E.myclass = select(2, UnitClass("player"))
	E.profileDir = E.myname..' - '..E.myrealm
	
	E.db = ALEAUI_NewDB("AleaUIDB", default_settings, true)
	
	E.db.cVars.profiles = nil
	
	E.dispellList = CanDispel[E.myclass] or {}
	
--	if not AleaUIDB_PC then AleaUIDB_PC = {} end
	
	E.chardb =  ALEAUI_NewDB("AleaUIDB_PC", default_chat_settings, true) -- AleaUIDB_PC 
	
	gui.args.profiles = ALEAUI_GetProfileOptions("AleaUIDB")
	

	E:InstallAddon()
	
	E:InitFrames2()
	E:InitFrames4()
	
	E.db.minimap = E.db.minimap or {}
	
	AleaUI_GUI.SlashCommand(addonName, "/aleaui", ShowHideUI)
	
	
	ALEAUI_OnProfileEvent("AleaUIDB","PROFILE_CHANGED", function()	
		core:OnProfileChange()
	end)
	
	ALEAUI_OnProfileEvent("AleaUIDB","PROFILE_RESET", function()	
		core:OnProfileChange()
	end)
	
	LSM.RegisterCallback(E.LSM_Update, "LibSharedMedia_Registered", function(mtype, key)
		E.LSM_Update:Show()
	end)
end


function core:OnProfileChange()
	if true then

		E.db = ALEAUI_NewDB("AleaUIDB", default_settings, true)
		E.chardb = ALEAUI_NewDB("AleaUIDB_PC", default_chat_settings, true) -- AleaUIDB_PC  
		
		E:InstallAddon()
		E:SetupCVars()	
		E:Module("UnitFrames"):UpdatFrameStyle()
		E:Module("RaidFrames"):OnProfileChange()
	--	E:Module("RaidFrames"):UdapteByLSM()
		E:Module('ActionBars'):UpdateButtonSettings()
		E:Module('NamePlates'):UpdateProfileSettings()
		E:UpdateChatSettings()
		E:UpdateCombatTextSettings()
		E:Module("ClassBars"):ClassBarUpdate()
		E:Module("DataText"):UpdateDataTexts()
		E:Module("MicroButtons"):UpdateMicroPositionDimensions()
		E:UpdateBuffFrameSettings()		
		E:UpdateAllMovers()
		E:UpdateMiniMapSize()
		E:UpdateMinimapArtBorder()
		E:Module('Cooldown'):UpdateSettings()
		E:Module('Alerts'):UpdateSettings()
		E:UpdateVehicleSeatMover()	
		E:Module("Skins"):UpdateAddonSkins()
	
		E:UpdateXPBars()
	else
		ReloadUI()
	end
end
core:RegisterEvent("PLAYER_LOGIN")
core:RegisterEvent("ADDON_LOADED")

function core:GROUP_ROSTER_UPDATE(event)
--	print('T', 'Core:GROUP_ROSTER_UPDATE', E.chardb.cVars['showQuestTrackingTooltips'])
	if (E.isClassic) then 
		return 
	end
	
	if E.chardb.cVars['showQuestTrackingTooltips'] then
		E:LockCVar('showQuestTrackingTooltips', 1)		
	else
		if IsInRaid() then
			E:LockCVar('showQuestTrackingTooltips', 0)
		else
			E:LockCVar('showQuestTrackingTooltips', 1)
		end
	end
end

core.GROUP_JOINED = core.GROUP_ROSTER_UPDATE
core.GROUP_LEFT = core.GROUP_ROSTER_UPDATE
core.UpdateQuestTrackingTooltips = core.GROUP_ROSTER_UPDATE

core:RegisterEvent("GROUP_ROSTER_UPDATE")
core:RegisterEvent("GROUP_JOINED")
core:RegisterEvent('GROUP_LEFT')


function core:PLAYER_SPECIALIZATION_CHANGED()	
	local spec = E.isClassic and 1 or GetSpecialization()
	
	if E.myclass == "PRIEST" then
		if spec == 3 then
			E.dispellList.Disease = false
		else
			E.dispellList.Disease = true	
		end		
	elseif E.myclass == "PALADIN" then
		if spec == 1 then
			E.dispellList.Magic = true
		else
			E.dispellList.Magic = false	
		end
	elseif E.myclass == "SHAMAN" then
		if spec == 3 then
			E.dispellList.Magic = true
		else
			E.dispellList.Magic = false	
		end
	elseif E.myclass == "DRUID" then
		if spec == 4 then
			E.dispellList.Magic = true
		else
			E.dispellList.Magic = false	
		end
	elseif E.myclass == "MONK" then
		if spec == 2 then
			E.dispellList.Magic = true
		else
			E.dispellList.Magic = false	
		end		
	end
end