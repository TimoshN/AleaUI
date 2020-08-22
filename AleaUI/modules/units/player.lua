local addonName, E = ...
local UF = E:Module("UnitFrames")
local CBF = E:Module("ClassBars")
local CB = E:Module("CastBar")
local show_castbar = false

local tags_list = {
	["health"] = {
		["leftText"] = "[playerlevel]",
		["centerText"] = "",
		["rightText"] = " [health] - [health:max] | [health:percent]",
	},
	["power"] = {
		["leftText"] = "",
		["centerText"] = "[classification]",
		["rightText"] = "[bothpower:percent]",
	},
	["altpower"] = {
		["leftText"] = "",
		["centerText"] = "",
		["rightText"] = "",
	},
	['altmanabar'] = {
		["leftText"] = "",
		["centerText"] = "",
		["rightText"] = "",
	},
}

local defaults = {
	["width"] = 260,
	["height"] = 45,
	tags_list = tags_list,
	
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
		backgroundRotate = 1,
	},
	["health"] = {
		["point"] = "CENTER",
		["text"] = {
			["right"] = {
				["font"] = E.media.default_font_name,
				["point"] = "RIGHT",
				["fontOutline"] = "OUTLINE",
				["fontSize"] = 10,
				["pos"] = {
					0,  
					0,  
				},
			},
			["left"] = {
				["font"] = E.media.default_font_name,
				["point"] = "LEFT",
				["fontOutline"] = "OUTLINE",
				["fontSize"] = 10,
				["pos"] = {
					0,  
					0,  
				},
			},
			["center"] = {
				["font"] = E.media.default_font_name,
				["point"] = "CENTER",
				["fontOutline"] = "OUTLINE",
				["fontSize"] = 10,
				["pos"] = {
					0,  
					0,  
				},
			},
		},
		["border"] = {
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
				0,  
			},
			["texture"] = E.media.default_bar_texture_name3,
		},
		["width"] = 260,
		["pos"] = {
			0,  
			12,  
		},
		["height"] = 20,
		["level"] = 1,
		["alpha"] = 1,
		["texture"] = E.media.default_bar_texture_name3,
	},
	["power"] = {
		["point"] = "CENTER",
		["text"] = {
			["right"] = {
				["font"] = E.media.default_font_name,
				["point"] = "RIGHT",
				["fontOutline"] = "OUTLINE",
				["fontSize"] = 10,
				["pos"] = {
					0,  
					0,  
				},
			},
			["left"] = {
				["font"] = E.media.default_font_name,
				["point"] = "LEFT",
				["fontOutline"] = "OUTLINE",
				["fontSize"] = 10,
				["pos"] = {
					0,  
					0,  
				},
			},
			["center"] = {
				["font"] = E.media.default_font_name,
				["point"] = "CENTER",
				["fontOutline"] = "OUTLINE",
				["fontSize"] = 10,
				["pos"] = {
					0,  
					0,  
				},
			},
		},
		["border"] = {
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
				1,  
				1,  
				1,  
				0,  
			},
			["texture"] = E.media.default_bar_texture_name3,
		},
		["width"] = 260,
		["pos"] = {
			0,  
			-7,  
		},
		["height"] = 20,
		["level"] = 1,
		["alpha"] = 1,
		["texture"] = E.media.default_bar_texture_name3,
	},
	["altpower"] = {
		["point"] = "CENTER",
		["text"] = {
			["right"] = {
				["font"] = E.media.default_font_name,
				["point"] = "RIGHT",
				["fontOutline"] = "OUTLINE",
				["fontSize"] = 10,
				["pos"] = {
					0,  
					0,  
				},
			},
			["left"] = {
				["font"] = E.media.default_font_name,
				["point"] = "LEFT",
				["fontOutline"] = "OUTLINE",
				["fontSize"] = 10,
				["pos"] = {
					0,  
					0,  
				},
			},
			["center"] = {
				["font"] = E.media.default_font_name,
				["point"] = "CENTER",
				["fontOutline"] = "OUTLINE",
				["fontSize"] = 10,
				["pos"] = {
					0,  
					0,  
				},
			},
		},
		["border"] = {
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
				1,  
			},
			["texture"] = E.media.default_bar_texture_name3,
		},
		["width"] = 260,
		["pos"] = {
			0,  
			-19,  
		},
		["height"] = 7,
		["level"] = 1,
		["alpha"] = 1,
		["texture"] = E.media.default_bar_texture_name3,
	},
	["altmanabar"] = {
		["point"] = "CENTER",
		["text"] = {
			["right"] = {
				["font"] = E.media.default_font_name,
				["point"] = "RIGHT",
				["fontOutline"] = "OUTLINE",
				["fontSize"] = 10,
				["pos"] = {
					0,  
					0,  
				},
			},
			["left"] = {
				["font"] = E.media.default_font_name,
				["point"] = "LEFT",
				["fontOutline"] = "OUTLINE",
				["fontSize"] = 10,
				["pos"] = {
					0,  
					0,  
				},
			},
			["center"] = {
				["font"] = E.media.default_font_name,
				["point"] = "CENTER",
				["fontOutline"] = "OUTLINE",
				["fontSize"] = 10,
				["pos"] = {
					0,  
					0,  
				},
			},
		},
		["border"] = {
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
				1,  
			},
			["texture"] = E.media.default_bar_texture_name3,
		},
		["width"] = 260,
		["pos"] = {
			0,  
			-19,  
		},
		["height"] = 7,
		["level"] = 1,
		["alpha"] = 1,
		["texture"] = E.media.default_bar_texture_name3,
	},
	castBar = {
		enable = true,
		showIcon = true,
		alpha = 1,
		width = 310, 
		height = 18,
		gcdoffset = 1,
		colors = CB.colors,
		texture = E.media.default_bar_texture_name1,
		font = E.media.default_font_name,
		fontSize = E.media.default_font_size,
		fontOutline = 'OUTLINE',
		border = {
			texture = E.media.default_bar_texture_name3,
			background_texture = E.media.default_bar_texture_name3,
			color = { 0, 0, 0, 1 },
			background_color = { 0, 0, 0, 0 },
			size = 1,
			inset = 0,
			background_inset = 0,
		},
	},
	
	model = {
		enable = false,
		width = 260,
		height = 45,
		point = 'CENTER',
		pos = { 0, 0 },
		level = 1,
		alpha = 0.4,
		portraitZoom = 1,
		rotate = 4.25,
		facing = math.pi,
		x = 0,
		y = 0,
		z = 0,
	},
	
	["buff"] = {
		["pos"] = {
			-121,  
			0,  
		},
		["direction"] = "right",
		["point"] = "bottom",
		["newrowdirection"] = "bottom",
		["enable"] = true,
		["size"] = 18,
		["row"] = 2,
		["perrow"] = 5,
	},
	["debuff"] = {
		["pos"] = {
			121,  
			0,  
		},
		["direction"] = "left",
		["newrowdirection"] = "bottom",
		["point"] = "bottom",
		["enable"] = true,
		["size"] = 18,
		["row"] = 2,
		["perrow"] = 5,
	},
}

E.default_settings.unitframes.unitopts.player = defaults


local w = 260
local powerh = 20
local healthh = 20
local altpowerh = 7
local inset = 1
local h = powerh+healthh+altpowerh-inset-inset

function UF:UpdatePlayerFrameSettings()
	local opts = E.db.unitframes.unitopts.player
	
	local f = E.PlayerFrame

	f:UpdateFrameConstruct(opts)
	
	
	f.taglist = opts.tags_list
	f:UpdateExistsTags()
	f:PostUpdate()
	
	if opts.castBar.enable then
		f.castBar:Enable()
		f.castBar:UpdateSettings(opts.castBar)
	else
		f.castBar:Disable()
	end
	
	if opts.model.enable then
		f.model:Enable()
		f.model:UpdateSettings(opts.model)
	else
		f.model:Disable()
	end
	
	if opts.buff.enable or opts.debuff.enable then
		f.AuraWidget:Enable()
		f.AuraWidget:UpdateSettings(opts)
	else
		f.AuraWidget:Disable()
	end
	
	UF:ReEnableTestFrames()
end

function UF:PlayerFrameTestFrame()
	E.PlayerFrame:ToggleTestFrames()
end


local function PlayerFrame()

	local f = CreateFrame('Button', 'AleaUI_PlayerFrame', E.UIParent, "SecureUnitButtonTemplate")
	f.taglist = tags_list
	f:SetSize(w, h)

	E:Mover(f, "playerFrame")
	
	local health = UF:StatusBar(f, "health")
	health:SetSize(w, healthh)
	health:SetStatusBarColor(0.2, 0.2, 0.2, 1)
	health.bg:SetColorTexture(0,0,0,1)

	local power = UF:StatusBar(f, "power")
	power:SetSize(w, powerh)
	power:SetStatusBarColor(1, 0.2, 0.2, 0.6)
	power.bg:SetColorTexture(0,0,0,1)

	local altpower = UF:StatusBar(f, "altpower")
	altpower:SetSize(w, altpowerh)
	altpower:SetStatusBarColor(0.2, 1, 0.2, 0.6)
	altpower.bg:SetColorTexture(0,0,0,1)
	
	f.health = health
	f.power = power
	f.altpower = altpower
	
	f.health:SetPoint("TOP", f , "TOP", 0, 1)
	f.power:SetPoint("TOP", f.health , "BOTTOM", 0, 1)
	f.altpower:SetPoint("TOP", f.power , "BOTTOM", 0, 1)
	
	if E:HasAltManaBar() then
		local altmanabar = UF:StatusBar(f, "altmanabar")
		altmanabar:SetSize(w, altpowerh)
		altmanabar:SetStatusBarColor(0.2, 1, 0.2, 0.6)
		altmanabar.bg:SetColorTexture(0,0,0,1)
		f.altmanabar = altmanabar
		f.altmanabar:SetPoint("TOP", f.altpower , "BOTTOM", 0, 1)
	end
	
	local combatParent = CreateFrame('Frame', nil, f) 
	combatParent:SetFrameLevel(f:GetFrameLevel()+6)
	
	local combat = health:CreateTexture(nil, "ARTWORK", nil, 2)
	combat:SetTexture("Interface\\CharacterFrame\\UI-StateIcon")
	combat:SetTexCoord(0.5, 1, 0, 0.5)
	combat:SetSize(18,18)
	combat:SetPoint("CENTER", f, "TOPLEFT", 0, 0)
	combat:Hide()
	combat:SetParent(combatParent)
	
	f.combat = combat
	
	f:RegisterEvent("PLAYER_REGEN_DISABLED")
	f:RegisterEvent("PLAYER_REGEN_ENABLED")
	f:RegisterEvent("PLAYER_UPDATE_RESTING")
	
	
	local function CheckCombat()
		if UnitAffectingCombat("player") then
			combat:Show()
			combat:SetTexCoord(0.5, 1, 0, 0.5)
		elseif IsResting() then
			combat:Show()
			combat:SetTexCoord(0, 0.5, 0, 0.421875)
		else
			combat:Hide()	
		end
	end
	
	local playerLogin = CreateFrame('Frame')
	playerLogin:RegisterEvent('PLAYER_LOGIN')
	playerLogin:RegisterEvent('ZONE_CHANGED')
	playerLogin:SetScript('OnEvent', CheckCombat)
	
	f.PLAYER_REGEN_DISABLED = CheckCombat	
	f.PLAYER_REGEN_ENABLED = CheckCombat
	f.PLAYER_UPDATE_RESTING = CheckCombat
	
	local ThreatStatusColor = {
		[0] = { 0.7, 0.7, 0.7 },
		[1] = { 1, 1, 0.47 },
		[2] = { 1, 0.5, 0 },
		[3] = { 0.6, 0, 0 },
	}
	local UpdateAggro = function(self)
		local status = UnitThreatSituation(self.displayerUnit or self.unit)
		if (status and status > 0) then
			self.threat:SetBackdropBorderColor(ThreatStatusColor[status][1], ThreatStatusColor[status][2], ThreatStatusColor[status][3])
			self.threat:Show()
		else
			self.threat:Hide()
		end
	end
	if (not E.isClassic) then 
	f:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE")
	f.UNIT_THREAT_SITUATION_UPDATE = UpdateAggro
	end
	
	f:RegisterEvent('UPDATE_SHAPESHIFT_FORM')
	f.UPDATE_SHAPESHIFT_FORM = function(self)
		
		local hasAltManabar = false
		
		local curBar = UnitPower('player')
		local manaBar = UnitPower('player', 0)
		
		if curBar ~= manaBar then
			hasAltManabar = true
		end
		
		
	end
	
	UF:UnitEvent(f, "player")
	
	f.threat = UF.AddAggroBorder(f)
	
	f.model = UF:CreateModel(f)
	
	CheckCombat()

	UF:UnitAuraWidgets(f) --, 10, 10, 25, 5, "right-bottom", "left-bottom")

	local castbar = UF:CreateCastBar(f,310, 18)
	E:Mover(castbar, "castbarFrame")

	E.PlayerFrame = f
	
	E.GUI.args.unitframes.args.playerFrame = UF:GetUnitFrameOptions('player', 'UpdatePlayerFrameSettings', "playerFrame", 'playerFrame', 'PlayerFrameTestFrame')
	E.GUI.args.unitframes.args.playerFrame.name = E.L['Player']
	E.GUI.args.unitframes.args.playerFrame.args.castBar = CB:GetCastBarOptions('player', 'UpdatePlayerFrameSettings', "castbarFrame", 'playerFrame')
	E.GUI.args.unitframes.args.playerFrame.args.model = UF:GetModelSettings('player', 'UpdatePlayerFrameSettings', 'playerFrame')
	E.GUI.args.unitframes.args.playerFrame.args.auraWidget = UF:GetAuraWidgetSettings('player', 'UpdatePlayerFrameSettings', 'playerFrame')
	
	UF:UpdatePlayerFrameSettings()
end

E:OnInit2(PlayerFrame)