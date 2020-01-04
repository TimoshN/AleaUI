local E = AleaUI
local UF = E:Module("UnitFrames")
local CBF = E:Module("ClassBars")
local CB = E:Module("CastBar")

local tags_list = {
	["health"] = {
		["leftText"] = " [namecolor][name:20] ",
		["centerText"] = "",
		["rightText"] = "[health] | [health:percent]",
	},
	["power"] = {
		["leftText"] = " [autoinfo]",
		["centerText"] = "[range]",
		["rightText"] = "[bothpower:percent]",
	},
	["altpower"] = {
		["leftText"] = "",
		["centerText"] = "",
		["rightText"] = "",
	},
}
local helpfulFilter = {
	[110909] = true,

}
local harmfulFilter = {
	[110909] = true,
}

local defaults = {
	width = 260,
	height = 45,
	show3DPortrair = false,
	tags_list = tags_list,
	border = {
		texture = AleaUI.media.default_bar_texture_name3,
		background_texture = AleaUI.media.default_bar_texture_name3,
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
		texture = AleaUI.media.default_bar_texture_name3,
		text = {
			left = {
				point = 'LEFT',
				pos = { 0, 0 },
				font = AleaUI.media.default_font_name,
				fontSize = AleaUI.media.default_font_size,
				fontOutline = 'OUTLINE',
			},
			right = {
				point = 'RIGHT',
				pos = { 0, 0 },
				font = AleaUI.media.default_font_name,
				fontSize = AleaUI.media.default_font_size,
				fontOutline = 'OUTLINE',
			},
			center = {
				point = 'CENTER',
				pos = { 0, 0 },
				font = AleaUI.media.default_font_name,
				fontSize = AleaUI.media.default_font_size,
				fontOutline = 'OUTLINE',
			},
		},
		border = {
			texture = AleaUI.media.default_bar_texture_name3,
			background_texture = AleaUI.media.default_bar_texture_name3,
			color = { 0, 0, 0, 1 },
			background_color = { 0, 0, 0, 0 },
			size = 1,
			inset = 0,
			background_inset = 0,
		},
		point = 'CENTER',
		pos = { 0, 12 },
		level = 1,
		alpha = 1,
	},
	power = {
		width = 260,
		height = 20,	
		texture = AleaUI.media.default_bar_texture_name3,		
		text = {
			left = {
				point = 'LEFT',
				pos = { 0, 0 },
				font = AleaUI.media.default_font_name,
				fontSize = AleaUI.media.default_font_size,
				fontOutline = 'OUTLINE',
			},
			right = {
				point = 'RIGHT',
				pos = { 0, 0 },
				font = AleaUI.media.default_font_name,
				fontSize = AleaUI.media.default_font_size,
				fontOutline = 'OUTLINE',
			},
			center = {
				point = 'CENTER',
				pos = { 0, 0 },
				font = AleaUI.media.default_font_name,
				fontSize = AleaUI.media.default_font_size,
				fontOutline = 'OUTLINE',
			},
		},
		border = {
			texture = AleaUI.media.default_bar_texture_name3,
			background_texture = AleaUI.media.default_bar_texture_name3,
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
		height = 7,		
		texture = AleaUI.media.default_bar_texture_name3,
		text = {
			left = {
				point = 'LEFT',
				pos = { 0, 0 },
				font = AleaUI.media.default_font_name,
				fontSize = AleaUI.media.default_font_size,
				fontOutline = 'OUTLINE',
			},
			right = {
				point = 'RIGHT',
				pos = { 0, 0 },
				font = AleaUI.media.default_font_name,
				fontSize = AleaUI.media.default_font_size,
				fontOutline = 'OUTLINE',
			},
			center = {
				point = 'CENTER',
				pos = { 0, 0 },
				font = AleaUI.media.default_font_name,
				fontSize = AleaUI.media.default_font_size,
				fontOutline = 'OUTLINE',
			},
		},
		border = {
			texture = AleaUI.media.default_bar_texture_name3,
			background_texture = AleaUI.media.default_bar_texture_name3,
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
		enable = true,
		showIcon = true,
		alpha = 1,
		width = 417, 
		height = 20,
		colors = CB.colors,
		texture = AleaUI.media.default_bar_texture_name1,
		font = AleaUI.media.default_font_name,
		fontSize = AleaUI.media.default_font_size,
		fontOutline = 'OUTLINE',
		border = {
			texture = AleaUI.media.default_bar_texture_name3,
			background_texture = AleaUI.media.default_bar_texture_name3,
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
		row = 2,
		perrow = 5,
		size = 18,
		direction = 'left',
		point = 'bottom',
		newrowdirection = "bottom",
		pos = { 121, 0 },
	},
	debuff = {
		enable = true,
		row = 2,
		perrow = 5,
		size = 18,
		direction = 'right',
		point = 'bottom',
		newrowdirection = "bottom",
		pos = { -121, 0 },
	},
}

AleaUI.default_settings.unitframes.unitopts.target = defaults

local w = 260
local powerh = 20
local healthh = 20
local altpowerh = 7
local inset = 1
local h = powerh+healthh+altpowerh-inset-inset

function UF:UpdateTargetFrameSettings()
	local opts = E.db.unitframes.unitopts.target
	
	local f = E.TargetFrame

	f:UpdateFrameConstruct(opts)
	
	
	f.taglist = opts.tags_list
	f:UpdateExistsTags()
	f:PostUpdate()
	
	if ( f.castBar ) then
		if opts.castBar.enable then
			f.castBar:Enable()
			f.castBar:UpdateSettings(opts.castBar)
		else
			f.castBar:Disable()
		end
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

function UF:TargetFrameTestFrame()
	E.TargetFrame:ToggleTestFrames()
end

local function TargetFrame()

	local f = CreateFrame('Button', 'AleaUI_TargetFrame', E.UIParent, "SecureUnitButtonTemplate")
	f.taglist = tags_list
	f:SetSize(w, h)
--	f:SetAttribute("unit", "target")
	
	E:Mover(f, "targetFrame")
	
	local health = UF:StatusBar(f, "health")
	health:SetSize(w, healthh)
	health:SetStatusBarColor(0.2, 0.2, 0.2, 1)
	health.bg:SetColorTexture(0,0,0,1)

	local power = UF:StatusBar(f,"power")
	power:SetSize(w, powerh)
	power:SetStatusBarColor(0.2, 0.2, 1, 1)
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
	
	UF:UnitEvent(f, "target")

	f.model = UF:CreateModel(f)
	
	
	f:RegisterEvent("PLAYER_TARGET_CHANGED")
	
	f.PLAYER_TARGET_CHANGED = function(self)
		if UnitExists("target") then
			self:PostUpdate()
			if self.CastBarUpdate then self:CastBarUpdate() end
		end
	end
	
	UF:UnitAuraWidgets(f)

	if ( not E.isClassic ) then
		local castbar = UF:CreateCastBar(f, 417, 20)
		castbar:SetAlpha(0.7)
		E:Mover(castbar, "targetcastbarFrame")
	end 

	E.TargetFrame = f

	E.GUI.args.unitframes.args.targetFrame = UF:GetUnitFrameOptions('target', 'UpdateTargetFrameSettings', "targetFrame", 'targetFrame', 'TargetFrameTestFrame')
	E.GUI.args.unitframes.args.targetFrame.name = E.L['Target']
	if ( not E.isClassic ) then
	E.GUI.args.unitframes.args.targetFrame.args.castBar = CB:GetCastBarOptions('target', 'UpdateTargetFrameSettings', "targetcastbarFrame", 'targetFrame')
	end
	E.GUI.args.unitframes.args.targetFrame.args.model = UF:GetModelSettings('target', 'UpdateTargetFrameSettings', 'targetFrame')
	E.GUI.args.unitframes.args.targetFrame.args.auraWidget = UF:GetAuraWidgetSettings('target', 'UpdateTargetFrameSettings', 'targetFrame')
	
	f:Show()
	
	UF:UpdateTargetFrameSettings()
	
	RegisterUnitWatch(f)
end

E:OnInit2(TargetFrame)