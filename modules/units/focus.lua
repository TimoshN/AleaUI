local E = AleaUI
local UF = E:Module("UnitFrames")
local CBF = E:Module("ClassBars")
local CB = E:Module("CastBar")

local tags_list = {
	["health"] = {
		["leftText"] = "[bothpower:percent]",
		["centerText"] = "",
		["rightText"] = "[health] | [health:percent]",
	},
	["power"] = {
		["leftText"] = "",
		["centerText"] = "[classification]",
		["rightText"] = "",
	},
	["altpower"] = {
		["leftText"] = "[level] [namecolor][name:30]",
		["centerText"] = "",
		["rightText"] = "",
	},
}

local defaults = {
	width = 220,
	height = 38,
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
		width = 220,
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
		pos = { 0, 0 },
		level = 1,
		alpha = 1,
	},
	power = {
		width = 220,
		height = 10,	
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
		pos = { 0, 14 },
		level = 1,
		alpha = 1,
	},
	altpower = {
		width = 220,
		height = 10,		
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
		pos = { 0, -14 },
		level = 1,
		alpha = 1,
	},
	castBar = {
		enable = true,
		showIcon = true,
		alpha = 1,
		width = 220, 
		height = 18,
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
		width = 220,
		height = 38,
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
		pos = { -101, 0 },
	},
	debuff = {
		enable = true,
		row = 1,
		perrow = 5,
		size = 18,
		direction = 'left',
		point = 'top',
		newrowdirection = "bottom",
		pos = { 101, 0 },
	},
}

AleaUI.default_settings.unitframes.unitopts.focus = defaults

local unit = "focus"
local testframe = false
local w = 220
local powerh = 10
local healthh = 20
local altpowerh = 10
local inset = 1
local h = powerh+healthh+altpowerh-inset-inset

function UF:UpdateFocusFrameSettings()
	local opts = E.db.unitframes.unitopts.focus
	
	local f = E.FocusFrame

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

function UF:FocusFrameTestFrame()
	E.FocusFrame:ToggleTestFrames()
end

local function FocusFrame()

	local f = CreateFrame('Button', 'AleaUI_FocusFrame', E.UIParent, "SecureUnitButtonTemplate")
	f:SetSize(w, h)
	f:SetAttribute("unit", unit)
	
	E:Mover(f, "focusFrame")
	
	RegisterUnitWatch(f)
	
	f:Hide()
	
	f.taglist = tags_list
	
	local health = UF:StatusBar(f, "health", 2, 0)
	health:SetSize(w, healthh)
	health:SetStatusBarColor(1, 0.2, 0.2, 1)
	health.bg:SetColorTexture(0,0,0,1)

	local power = UF:StatusBar(f, "power")
	power:SetSize(w, powerh)
	power.bg:SetColorTexture(0,0,0,1)

	local altpower = UF:StatusBar(f, "altpower", 0, -3)
	altpower:SetSize(w, altpowerh)
	altpower:SetStatusBarColor(0.2, 1, 0.2, 0.6)
	altpower.bg:SetColorTexture(0,0,0,1)
	
	f.health = health
	f.power = power
	f.altpower = altpower

	f.power:SetPoint("TOP", f , "TOP", 0, 0)
	f.health:SetPoint("TOP", f.power , "BOTTOM", 0, inset)
	f.altpower:SetPoint("TOP", f.health , "BOTTOM", 0, inset)
		
	UF:UnitEvent(f, unit)

	f.model = UF:CreateModel(f)

	f:RegisterEvent("PLAYER_FOCUS_CHANGED")
	
	function f:PLAYER_FOCUS_CHANGED()
		if not UnitExists(unit) then return end
		self:PostUpdate()
		f:PLAYER_TARGET_CHANGED()
	end
	
	f.aggro = UF.AddAggroBorder(f)
	f.aggro:SetBackdropBorderColor(1, 1, 1, 0.8)
	
	f:RegisterEvent("PLAYER_TARGET_CHANGED")
	function f:PLAYER_TARGET_CHANGED()
		if UnitIsUnit(self:GetAttribute("unit"), "target") then
			self.aggro:Show()
		else
			self.aggro:Hide()
		end
	end
		
	UF:UnitAuraWidgets(f)
	
	local castbar = UF:CreateCastBar(f, w, 18)
	E:Mover(castbar, "focustcastbarFrame")

	E.FocusFrame = f
		
	E.GUI.args.unitframes.args.focusFrame = UF:GetUnitFrameOptions('focus', 'UpdateFocusFrameSettings', "focusFrame", 'focusFrame', 'FocusFrameTestFrame')
	E.GUI.args.unitframes.args.focusFrame.name = E.L['Focus']
	E.GUI.args.unitframes.args.focusFrame.args.castBar = CB:GetCastBarOptions('focus', 'UpdateFocusFrameSettings', "focustcastbarFrame", 'focusFrame')
	E.GUI.args.unitframes.args.focusFrame.args.model = UF:GetModelSettings('focus', 'UpdateFocusFrameSettings', 'focusFrame')
	E.GUI.args.unitframes.args.focusFrame.args.auraWidget = UF:GetAuraWidgetSettings('focus', 'UpdateFocusFrameSettings', 'focusFrame')
	
	UF:UpdateFocusFrameSettings()
end

E:OnInit2(FocusFrame)