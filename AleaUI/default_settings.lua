local addonName, E = ...


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
