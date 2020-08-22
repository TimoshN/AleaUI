local addonName, E = ...
local UF = E:Module("UnitFrames")
local CBF = E:Module("ClassBars")
local CB = E:Module("CastBar")

local tags_list = {
	["health"] = {
		["leftText"] = "[namecolor][name:20]",
		["centerText"] = "",
		["rightText"] = "[health:percent]",
	},
	["power"] = {
		["leftText"] = "",
		["centerText"] = "",
		["rightText"] = "",
	},
	["altpower"] = {
		["leftText"] = "",
		["centerText"] = "",
		["rightText"] = "",
	},
}

local defaults = {
	width = 260,
	height = 20,
	tags_list = tags_list,
	border = {
		texture = E.media.default_bar_texture_name3,
		background_texture = E.media.default_bar_texture_name3,
		color = { 1, 1, 1, 0 },
		background_color = { 1, 1, 1, 0  },
		size = 1,
		inset = 1,
		background_inset = 1,
		backgroundRotate = 1,
	},
	health = {
		width = 260,
		height = 20,		
		texture = E.media.default_bar_texture_name3,
		text = {
			left = {
				point = 'LEFT',
				pos = { 0, 0 },
				font = E.media.default_font_name,
				fontSize = E.media.default_font_size,
				fontOutline = 'OUTLINE',
			},
			right = {
				point = 'RIGHT',
				pos = { 0, 0 },
				font = E.media.default_font_name,
				fontSize = E.media.default_font_size,
				fontOutline = 'OUTLINE',
			},
			center = {
				point = 'CENTER',
				pos = { 0, 0 },
				font = E.media.default_font_name,
				fontSize = E.media.default_font_size,
				fontOutline = 'OUTLINE',
			},
		},
		border = {
			texture = E.media.default_bar_texture_name3,
			background_texture = E.media.default_bar_texture_name3,
			color = { 0, 0, 0, 1 },
			background_color = { 0, 0, 0, 0 },
			size = 1,
			inset = 0,
			background_inset = 0,
		},
		point = 'CENTER',
		pos = { 0, 0 },
		level = 1,
		alpha = 1,
	},
	power = {
		width = 260,
		height = 0,	
		texture = E.media.default_bar_texture_name3,		
		text = {
			left = {
				point = 'LEFT',
				pos = { 0, 0 },
				font = E.media.default_font_name,
				fontSize = E.media.default_font_size,
				fontOutline = 'OUTLINE',
			},
			right = {
				point = 'RIGHT',
				pos = { 0, 0 },
				font = E.media.default_font_name,
				fontSize = E.media.default_font_size,
				fontOutline = 'OUTLINE',
			},
			center = {
				point = 'CENTER',
				pos = { 0, 0 },
				font = E.media.default_font_name,
				fontSize = E.media.default_font_size,
				fontOutline = 'OUTLINE',
			},
		},
		border = {
			texture = E.media.default_bar_texture_name3,
			background_texture = E.media.default_bar_texture_name3,
			color = { 0, 0, 0, 1 },
			background_color = { 0, 0, 0, 0 },
			size = 1,
			inset = 0,
			background_inset = 0,
		},
		point = 'CENTER',
		pos = { 0, -7 },
		level = 1,
		alpha = 1,
	},
	altpower = {
		width = 260,
		height = 0,		
		texture = E.media.default_bar_texture_name3,
		text = {
			left = {
				point = 'LEFT',
				pos = { 0, 0 },
				font = E.media.default_font_name,
				fontSize = E.media.default_font_size,
				fontOutline = 'OUTLINE',
			},
			right = {
				point = 'RIGHT',
				pos = { 0, 0 },
				font = E.media.default_font_name,
				fontSize = E.media.default_font_size,
				fontOutline = 'OUTLINE',
			},
			center = {
				point = 'CENTER',
				pos = { 0, 0 },
				font = E.media.default_font_name,
				fontSize = E.media.default_font_size,
				fontOutline = 'OUTLINE',
			},
		},
		border = {
			texture = E.media.default_bar_texture_name3,
			background_texture = E.media.default_bar_texture_name3,
			color = { 0, 0, 0, 1 },
			background_color = { 0, 0, 0, 1 },
			size = 1,
			inset = 0,
			background_inset = 0,
		},
		point = 'CENTER',
		pos = { 0, -19 },
		level = 1,
		alpha = 1,
	},
	castBar = {
		enable = false,
		showIcon = true,
		alpha = 1,
		width = 310, 
		height = 18,
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
	buff = {
		enable = true,
		row = 1,
		perrow = 5,
		size = 18,
		direction = 'right',
		point = 'top',
		newrowdirection = "bottom",
		pos = { -121, 0 },
	},
	debuff = {
		enable = true,
		row = 1,
		perrow = 5,
		size = 18,
		direction = 'left',
		point = 'top',
		newrowdirection = "bottom",
		pos = { 121, 0 },
	},
}

E.default_settings.unitframes.unitopts.pet = defaults

function UF:UpdatePetFrameSettings()
	local opts = E.db.unitframes.unitopts.pet
	
	local f = E.PetFrame

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

function UF:PetFrameTestFrame()
	E.PetFrame:ToggleTestFrames()
end

local unit = "pet"
local function PlayerPetFrame()
	local w = 260
	
	local f = CreateFrame('Button', 'AleaUI_PetFrame', E.UIParent, "SecureUnitButtonTemplate")
	f:SetSize(w, 20)

	E:Mover(f, "petFrame")
	
	f:Hide()
	
	f.taglist = tags_list
	
	local health = UF:StatusBar(f, "health")
	health:SetSize(w, 20)
	health:SetPoint("TOP", f , "TOP", 0, 0)
	health:SetStatusBarColor(1, 0.2, 0.2, 1)
	health.bg:SetColorTexture(0,0,0,1)
	f.health = health
	
	local power = UF:StatusBar(f, "power")
	power:SetSize(w, 0)
	power:SetPoint("TOP", f , "TOP", 0, 1)
	power.bg:SetColorTexture(0,0,0,1)
	f.power = power
	
	local altpower = UF:StatusBar(f, "altpower")
	altpower:SetSize(w, 0)
	altpower:SetPoint("TOP", f.health , "BOTTOM", 0, 1)
	altpower:SetStatusBarColor(0.2, 1, 0.2, 0.6)
	altpower.bg:SetColorTexture(0,0,0,1)
	f.altpower = altpower
	
	UF:UnitEvent(f, unit)
	
	f.model = UF:CreateModel(f)

	f:RegisterEvent("UNIT_PET")
	
	function f:UNIT_PET(event, unit)
		if not UnitExists(self.displayerUnit or self.unit) then return end
		self:PostUpdate()
	end
	
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
	
	f.threat = UF.AddAggroBorder(f)
	
	
	UF:UnitAuraWidgets(f)
	
	local castbar = UF:CreateCastBar(f,310, 18)
	E:Mover(castbar, "petcastbarFrame")
	
	E.PetFrame = f
	
	E.GUI.args.unitframes.args.petFrame = UF:GetUnitFrameOptions('pet', 'UpdatePetFrameSettings', "petFrame", 'petFrame', 'PetFrameTestFrame')
	E.GUI.args.unitframes.args.petFrame.name = E.L['Pet']
	E.GUI.args.unitframes.args.petFrame.args.castBar = CB:GetCastBarOptions('pet', 'UpdatePetFrameSettings', "petcastbarFrame", 'petFrame')
	E.GUI.args.unitframes.args.petFrame.args.model = UF:GetModelSettings('pet', 'UpdatePetFrameSettings', 'petFrame')
	E.GUI.args.unitframes.args.petFrame.args.auraWidget = UF:GetAuraWidgetSettings('pet', 'UpdatePetFrameSettings', 'petFrame')
	
	UF:UpdatePetFrameSettings()
end

E:OnInit2(PlayerPetFrame)