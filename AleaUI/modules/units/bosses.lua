local E = AleaUI
local UF = E:Module("UnitFrames")
local CBF = E:Module("ClassBars")
local CB = E:Module("CastBar")

E.BossFrames = {}

local bossFrameMover = CreateFrame('Frame', 'AleaUI_BossFrameParent', E.UIParent)
bossFrameMover:SetSize(100, 100)
bossFrameMover:EnableMouse(false)
bossFrameMover:SetPoint('CENTER', E.UIParent, 'CENTER', 0, 0)

local tags_list = {
	["health"] = {
		["leftText"] = "[bothpower:percent]",
		["centerText"] = "",
		["rightText"] = " [health] | [health:percent]",
	},
	["power"] = {
		["leftText"] = "",
		["centerText"] = "[classification] [range]",
		["rightText"] = "",
	},
	["altpower"] = {
		["leftText"] = "",
		["centerText"] = "",
		["rightText"] = "[namecolor][name:20] [level]",
	},
}

local defaults = {
	width = 190,
	height = 32,
	show3DPortrair = false,
	tags_list = tags_list,
	growup = false,
	spacing = 40,
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
		width = 190,
		height = 18,		
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
		width = 190,
		height = 8,	
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
	altpower = {
		width = 190,
		height = 8,		
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
		pos = { 0, -12 },
		level = 1,
		alpha = 1,
	},
	castBar = {
		enable = true,
		showIcon = true,
		alpha = 1,
		width = 190, 
		height = 18,
		colors = CB.colors,
		texture = AleaUI.media.default_bar_texture_name1,
		font = AleaUI.media.default_font_name,
		fontSize = AleaUI.media.default_font_size,
		fontOutline = 'OUTLINE',
		point = 'CENTER',
		pos = { 0, -28 },
		level = 1,
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
		width = 190,
		height = 32,
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
		direction = 'left',
		point = 'top',
		newrowdirection = "bottom",
		pos = { 86, 0 },
	},
	debuff = {
		enable = true,
		row = 1,
		perrow = 5,
		size = 18,
		direction = 'right',
		point = 'top',
		newrowdirection = "bottom",
		pos = { -86, 0 },
	},
}

AleaUI.default_settings.unitframes.unitopts.bosses = defaults

local testframe = false

function UF:UpdateBossFramesSettings()
	local opts = E.db.unitframes.unitopts.bosses

	for i=1, MAX_BOSS_FRAMES, 1 do
		local f = E.BossFrames[i]
		f:ClearAllPoints()
		
		f:UpdateFrameConstruct(opts)
		
		
		f.taglist = opts.tags_list
		f:UpdateExistsTags()
		f:PostUpdate()
		
		if opts.castBar.enable then
			f.castBar:Enable()
			f.castBar:UpdateSettings(opts.castBar, true)
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
	end
	

	for i=1, MAX_BOSS_FRAMES do
		local f = E.BossFrames[i]
		local prev = E.BossFrames[i-1]
		
		if opts.growup then
			if not prev then
				f:SetPoint('BOTTOM', bossFrameMover, 'BOTTOM', 0, 0)
			else
				f:SetPoint('BOTTOM', prev, 'TOP', 0, opts.spacing)
			end
		else
			if not prev then
				f:SetPoint('TOP', bossFrameMover, 'TOP', 0, 0)
			else
				f:SetPoint('TOP', prev, 'BOTTOM', 0, -opts.spacing)
			end
		end
	end

	UF:ReEnableTestFrames()
	bossFrameMover:SetSize(opts.width, (opts.height+opts.spacing)*4 + opts.height)
end

function UF:BossFramesTestFrame()
	for i=1, #E.BossFrames do
		E.BossFrames[i]:ToggleTestFrames()
		
		E.BossFrames[i].centerStatusIcon.texture:SetTexture("Interface\\TargetingFrame\\UI-PhasingIcon");
		E.BossFrames[i].centerStatusIcon.texture:SetTexCoord(0.15625, 0.84375, 0.15625, 0.84375);
		E.BossFrames[i].centerStatusIcon.border:Show();
		E.BossFrames[i].centerStatusIcon:Show();
	end
end


local w = 190
local powerh = 8
local healthh = 18
local altpowerh = 8
local inset = 1
local h = powerh+healthh+altpowerh-inset-inset

local function BossesFrame()

	for i=1, MAX_BOSS_FRAMES, 1 do
		local unit = "boss"..i
		
		local f = CreateFrame('Button', 'AleaUI_Boss'..i..'Frame', E.UIParent, "SecureUnitButtonTemplate")
		f.taglist = tags_list
		f:SetSize(w, h)
	--	f:SetAttribute("unit", unit)
	--	f:Hide()
	--	RegisterUnitWatch(f)

		local power = UF:StatusBar(f,"power")
		power:SetSize(w, powerh)
		power:SetStatusBarColor(0.2, 0.2, 1, 1)
		power.bg:SetColorTexture(0,0,0,1)
		f.power = power
		
		local health = UF:StatusBar(f, "health", 2, 0)
		health:SetSize(w, healthh)
		health:SetStatusBarColor(1, 0.2, 0.2, 1)
		health.bg:SetColorTexture(0,0,0,1)

		f.health = health
		
		local altpower = UF:StatusBar(f, "altpower", 0, -3)
		altpower:SetSize(w, altpowerh)
		altpower:SetStatusBarColor(0.2, 1, 0.2, 0.6)
		altpower.bg:SetColorTexture(0,0,0,1)
		f.altpower = altpower

		f.power:SetPoint("TOP", f , "TOP", 0, 0)
		f.health:SetPoint("TOP", f.power , "BOTTOM", 0, inset)
		f.altpower:SetPoint("TOP", f.health , "BOTTOM", 0, inset)
		
		
		UF:UnitEvent(f, unit, true)
		
		f.aggro = UF.AddAggroBorder(f)
		f.aggro:SetBackdropBorderColor(1, 1, 1, 0.8)
		f.model = UF:CreateModel(f)

		f:RegisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT")
		f:RegisterEvent("PLAYER_TARGET_CHANGED")
		
		
		function f:INSTANCE_ENCOUNTER_ENGAGE_UNIT()
			if UnitName(self.unit) then
				self:PostUpdate()
			end
			self:CastBarUpdate()
		end
		
		function f:PLAYER_TARGET_CHANGED()
			if UnitIsUnit(self:GetAttribute("unit"), "target") then
				self.aggro:Show()
			else
				self.aggro:Hide()
			end
		end

		UF:UnitAuraWidgets(f)

		UF:CreateCastBar(f, w, 18):SetPoint("TOP", f, "BOTTOM", 0, -inset-inset-inset)
		
		E.BossFrames[i] = f
	end
	
	E.GUI.args.unitframes.args.bossFrames = UF:GetUnitFrameOptions('bosses', 'UpdateBossFramesSettings', "bossFrames", 'bossFrames', 'BossFramesTestFrame')
	E.GUI.args.unitframes.args.bossFrames.name = E.L['Bosses']
	E.GUI.args.unitframes.args.bossFrames.args.castBar = CB:GetGroupedCastBarOptions('bosses', 'UpdateBossFramesSettings', 'bossFrames')
	E.GUI.args.unitframes.args.bossFrames.args.model = UF:GetModelSettings('bosses', 'UpdateBossFramesSettings', 'bossFrames')
	E.GUI.args.unitframes.args.bossFrames.args.auraWidget = UF:GetAuraWidgetSettings('bosses', 'UpdateBossFramesSettings', 'bossFrames')
	
	E:Mover(bossFrameMover, "bossFrames")
	
	UF:UpdateBossFramesSettings()
end

E:OnInit2(BossesFrame)