local addonName, E = ...
local UF = E:Module("UnitFrames")
local CBF = E:Module("ClassBars")
local CB = E:Module("CastBar")

local tags_list = {
	["health"] = {
		["leftText"] = " [namecolor][name:20]",
		["centerText"] = "",
		["rightText"] = "",
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
		color = { 0, 0, 0, 0 },
		background_color = { 0, 0, 0, 0  },
		size = 1,
		inset = 0,
		background_inset = 0,
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

E.default_settings.unitframes.unitopts.targettarget = defaults

function UF:UpdateTargetTargetFrameSettings()
	local opts = E.db.unitframes.unitopts.targettarget
	
	local f = E.TargetTargetFrame

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

function UF:TargetTargetFrameTestFrame()
	E.TargetTargetFrame:ToggleTestFrames()
end

local function TargetTargetFrame()
	local w = 260
	
	local f = CreateFrame('Button', 'AleaUI_TargetTargetFrame', E.UIParent, "SecureUnitButtonTemplate")
	f.taglist = tags_list
	f:SetSize(w, 20)
--	f:SetAttribute("unit", "targettarget")
--	RegisterUnitWatch(f)
	
	E:Mover(f, "targettargetFrame")
	
	f:Hide()
	
	local power = UF:StatusBar(f,"power")
	power:SetSize(w, 0)
	power:SetPoint("TOP", f , "TOP", 0, 1)
	power:SetStatusBarColor(0.2, 0.2, 1, 1)
	power.bg:SetColorTexture(0,0,0,1)
	f.power = power
	
	local health = UF:StatusBar(f, "health")
	health:SetSize(w, 20)
	health:SetPoint("TOP", f , "TOP", 0, -1)
	health:SetStatusBarColor(1, 0.2, 0.2, 1)
	health.bg:SetColorTexture(0,0,0,1)

	f.health = health

	local altpower = UF:StatusBar(f, "altpower")
	altpower:SetSize(w, 0)
	altpower:SetPoint("TOPLEFT", f.health , "TOPLEFT", 0, -24)
	altpower:SetStatusBarColor(0.2, 1, 0.2, 0.6)
	altpower.bg:SetColorTexture(0,0,0,1)
	f.altpower = altpower
	
	UF:UnitEvent(f, "targettarget")

	f:RegisterEvent("PLAYER_TARGET_CHANGED")
	f:RegisterEvent("UNIT_TARGET")
	
	f.model = UF:CreateModel(f)
	
	function f:PLAYER_TARGET_CHANGED()
		if not UnitExists("targettarget") then return end
		self:PostUpdate()
	end
	
	function f:UNIT_TARGET()
		if not UnitExists("targettarget") then return end
		self:PostUpdate()
	end

	UF:UnitAuraWidgets(f)
	
	local castbar = UF:CreateCastBar(f,310, 18)
	E:Mover(castbar, "targettargetcastbarFrame")
	
	E.TargetTargetFrame = f
	
	
	E.GUI.args.unitframes.args.targettargetFrame = UF:GetUnitFrameOptions('targettarget', 'UpdateTargetTargetFrameSettings', "targettargetFrame", 'targettargetFrame', 'TargetTargetFrameTestFrame')
	E.GUI.args.unitframes.args.targettargetFrame.name = E.L['Target of target']
	E.GUI.args.unitframes.args.targettargetFrame.args.castBar = CB:GetCastBarOptions('targettarget', 'UpdateTargetTargetFrameSettings', "targettargetcastbarFrame", 'targettargetFrame')
	E.GUI.args.unitframes.args.targettargetFrame.args.model = UF:GetModelSettings('targettarget', 'UpdateTargetTargetFrameSettings', 'targettargetFrame')
	E.GUI.args.unitframes.args.targettargetFrame.args.auraWidget = UF:GetAuraWidgetSettings('targettarget', 'UpdateTargetTargetFrameSettings', 'targettargetFrame')
	
	UF:UpdateTargetTargetFrameSettings()

end
if ( not E.isClassic ) then
E:OnInit2(TargetTargetFrame)
end