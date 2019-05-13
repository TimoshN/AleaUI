local E = AleaUI
local UF = E:Module("UnitFrames")
local CBF = E:Module("ClassBars")
local CB = E:Module("CastBar")

E.ArenaFrames = {}

local arenaFrameMover = CreateFrame('Frame', 'AleaUI_ArenaFrameParent', AleaUI.UIParent)
arenaFrameMover:SetSize(100, 100)
arenaFrameMover:EnableMouse(false)
arenaFrameMover:SetPoint('CENTER', AleaUI.UIParent, 'CENTER', 0, 0)

local tags_list = {
	["health"] = {
		["leftText"] = "[namecolor][name:20]",
		["centerText"] = "",
		["rightText"] = "[health] - [health:percent]",
	},
	["power"] = {
		["leftText"] = "",
		["centerText"] = "[range]",
		["rightText"] = "",
	},
	["altpower"] = {
		["leftText"] = "",
		["centerText"] = "",
		["rightText"] = "",
	},
}

local defaults = {
	width = 190,
	height = 30,
	show3DPortrair = false,
	tags_list = tags_list,
	growup = false,
	spacing = 40,
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
		width = 190,
		height = 23,		
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
		pos = { 0, -4 },
		level = 1,
	},
	power = {
		width = 190,
		height = 9,	
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
		pos = { 0, 11 },
		level = 1,
		alpha = 1,
	},
	altpower = {
		width = 190,
		height = 1,		
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
		pos = { 0, -15},
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
		pos = { 0, -25 },
		level = 1,
		alpha = 1,
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

AleaUI.default_settings.unitframes.unitopts.arenas = defaults

local testframe = false

local function AddAggroBorder(f)

	f.aggro = CreateFrame("Frame", nil, f)
	f.aggro:SetFrameStrata("LOW")
	f.aggro:SetBackdrop( {	
 		edgeFile = "Interface\\AddOns\\AleaUI\\media\\glow", edgeSize = 3,
 		insets = {left = 5, right = 5, top = 5, bottom = 5},
 	})		
	f.aggro:SetBackdropBorderColor(1, 0, 0, 1)
	f.aggro:SetScale(2)
	f.aggro:SetPoint("TOPLEFT", f, "TOPLEFT", -3, 3)
	f.aggro:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 3, -3)
	
end

function UF:UpdateArenaFramesSettings()
	local opts = E.db.unitframes.unitopts.arenas

	for i=1, 5, 1 do
		local f = E.ArenaFrames[i]
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
	

	for i=1, 5 do
		local f = E.ArenaFrames[i]
		local prev = E.ArenaFrames[i-1]
		
		if opts.growup then
			if not prev then
				f:SetPoint('BOTTOM', arenaFrameMover, 'BOTTOM', 0, 0)
			else
				f:SetPoint('BOTTOM', prev, 'TOP', 0, opts.spacing)
			end
		else
			if not prev then
				f:SetPoint('TOP', arenaFrameMover, 'TOP', 0, 0)
			else
				f:SetPoint('TOP', prev, 'BOTTOM', 0, -opts.spacing)
			end
		end
	end

	arenaFrameMover:SetSize(opts.width, (opts.height+opts.spacing)*4 + opts.height)
	
	UF:ReEnableTestFrames()
end

function UF:ArenaFramesTestFrame()
	for i=1, #E.ArenaFrames do
		E.ArenaFrames[i]:ToggleTestFrames()
	end
end

local w = 220
local powerh = 10
local healthh = 20
local altpowerh = 10
local inset = 1
local h = powerh+healthh+altpowerh-inset-inset

local function ArenaFrame()
	
	for i=1, 5 do
		local unit = "arena"..i
		
		local f = CreateFrame('Button', 'AleaUI_Arena'..i..'Frame', E.UIParent, "SecureUnitButtonTemplate")
		f.taglist = tags_list
		f.id = i
		f:SetSize(w, h)
	--	f:SetAttribute("unit", unit)
	--	RegisterUnitWatch(f)
	
		f:Hide()
		
		local health = UF:StatusBar(f,"health")
		health:SetSize(w, healthh)
		health:SetStatusBarColor(1, 0.2, 0.2, 0.6)
		health.bg:SetColorTexture(0,0,0,1)
		
		local power = UF:StatusBar(f,"power")
		power:SetSize(w, powerh)
		power.bg:SetColorTexture(0,0,0,1)
		
		local altpower = UF:StatusBar(f, "altpower")
		altpower:SetSize(w, altpowerh)
		altpower:SetStatusBarColor(0.2, 1, 0.2, 0.6)
		altpower.bg:SetColorTexture(0,0,0,1)
		
		f.power = power
		f.health = health
		f.altpower = altpower
		
		f.power:SetPoint("TOP", f , "TOP", 0, 0)
		f.health:SetPoint("TOP", f.power , "BOTTOM", 0, inset)
		f.altpower:SetPoint("TOP", f.health , "BOTTOM", 0, inset)
		
		AddAggroBorder(f)
		
		f.prepFrames = CreateFrame("Frame", nil, E.UIParent)
		f.prepFrames:SetPoint("TOPLEFT", f, "TOPLEFT")
		f.prepFrames:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT")
		
		f.prepFrames.class = f.prepFrames:CreateTexture(nil, "ARTWORK", nil, 1)
		f.prepFrames.class:SetAllPoints()
		f.prepFrames.class:SetColorTexture(1,1,0,1)
		
		f.prepFrames.bg = f.prepFrames:CreateTexture(nil, "ARTWORK", nil, 0)
		f.prepFrames.bg:SetPoint("TOPLEFT", f.prepFrames, "TOPLEFT", -1, 1)
		f.prepFrames.bg:SetPoint("BOTTOMRIGHT", f.prepFrames, "BOTTOMRIGHT", 1, -1)
		f.prepFrames.bg:SetColorTexture(0, 0, 0, 1)
		
		
		f.prepFrames.pvpIcon = f.prepFrames:CreateTexture(nil, "ARTWORK", nil, 1)
		f.prepFrames.pvpIcon:SetSize(h-2,h-2)
		f.prepFrames.pvpIcon:SetPoint("LEFT", f.prepFrames, "RIGHT", 2, 0)
		f.prepFrames.pvpIcon:SetTexCoord(unpack(AleaUI.media.texCoord))
		f.prepFrames.pvpIcon:SetTexture("INTERFACE\\ICONS\\INV_MISC_QUESTIONMARK")

		f.prepFrames.pvpIcon.bg = f.prepFrames:CreateTexture(nil, "ARTWORK", nil, 0)
		f.prepFrames.pvpIcon.bg:SetPoint("TOPLEFT", f.prepFrames.pvpIcon, "TOPLEFT", -1, 1)
		f.prepFrames.pvpIcon.bg:SetPoint("BOTTOMRIGHT", f.prepFrames.pvpIcon, "BOTTOMRIGHT", 1, -1)
		f.prepFrames.pvpIcon.bg:SetColorTexture(0, 0, 0, 1)
		
		f.prepFrames.name = f.prepFrames:CreateFontString(nil, "ARTWORK", "GameFontNormal")
		f.prepFrames.name:SetFont(AleaUI.media.default_font, 14, "OUTLINE")
		f.prepFrames.name:SetPoint("LEFT", f.prepFrames, "LEFT", 3, 0)
		f.prepFrames.name:SetText("TEST")
		f.prepFrames.name:SetTextColor(1, 1, 1, 1)
		
		UF:UnitEvent(f, unit)
		
		local model = UF:CreateModel(f)
		f.model = model
		
		local pvpIcon = f:CreateTexture(nil, "ARTWORK", nil, 1)
		pvpIcon:SetSize(h-2,h-2)
		pvpIcon:SetPoint("LEFT", f.health, "RIGHT", 2, 0)
		pvpIcon:SetTexCoord(unpack(AleaUI.media.texCoord))
		pvpIcon:SetTexture("INTERFACE\\ICONS\\INV_MISC_QUESTIONMARK")

		pvpIcon.bg = f:CreateTexture(nil, "ARTWORK", nil, 0)
		pvpIcon.bg:SetPoint("TOPLEFT", pvpIcon, "TOPLEFT", -1, 1)
		pvpIcon.bg:SetPoint("BOTTOMRIGHT", pvpIcon, "BOTTOMRIGHT", 1, -1)
		pvpIcon.bg:SetColorTexture(0, 0, 0, 1)
		
		f.pvpIcon = pvpIcon
		
		f:RegisterEvent("ARENA_OPPONENT_UPDATE")
		f:RegisterEvent("ARENA_PREP_OPPONENT_SPECIALIZATIONS")		
		f:RegisterEvent("PLAYER_ENTERING_WORLD")
		f:RegisterEvent("ZONE_CHANGED_NEW_AREA")
		
		function f:ARENA_OPPONENT_UPDATE(event, unit, status) -- cleared , seen
		
		--	print('ARENA_OPPONENT_UPDATE', status, self.id, GetArenaOpponentSpec(self.id), UnitExists(self.unit))
			
			local _, instanceType = IsInInstance();
			if instanceType == "arena" and UnitExists(self.unit) then			
				local specID, gender = GetArenaOpponentSpec(self.id);
				
				if specID and specID > 0 then
					local _, name, _, specIcon, _, class = GetSpecializationInfoByID(specID, gender)
				
					local c = class and RAID_CLASS_COLORS[strupper(class)] or { r=0.3, g=0.3, b=0.3 }
					
					self.prepFrames.class:SetColorTexture(c.r,c.g,c.b,1)			
					
					self.pvpIcon:SetTexture(specIcon or "INTERFACE\\ICONS\\INV_MISC_QUESTIONMARK")				
					self.pvpIcon:Show()
					self.prepFrames:Show()
					
					self.prepFrames.name:SetText(name)
					self.prepFrames.name:SetTextColor(c.r,c.g,c.b,1)		
				else
					self.prepFrames:Hide()
					self.pvpIcon:Hide()
				end
			elseif instanceType == "pvp" and UnitExists(self.unit) then
				local faction = UnitFactionGroup(self.unit)
				
				if faction then
					if faction == "Horde" then
						self.pvpIcon:SetTexture([[Interface\Icons\INV_BannerPVP_01]])
					elseif faction == 'Alliance' then
						self.pvpIcon:SetTexture([[Interface\Icons\INV_BannerPVP_02]])
					else
						self.pvpIcon:SetTexture([[INTERFACE\ICONS\INV_MISC_QUESTIONMARK]])
					end
				end			
				self.pvpIcon:Show()
				self.prepFrames:Hide()
			else
				self.prepFrames:Hide()
				self.prepFrames.pvpIcon:Hide()
			end
			
			if UnitName(self.unit) then
				self:PostUpdate()
			end
		end

		f.ARENA_PREP_OPPONENT_SPECIALIZATIONS = function(self)		
			local specID, gender = GetArenaOpponentSpec(self.id);
			
		--	print('ARENA_PREP_OPPONENT_SPECIALIZATIONS', specID, gender, self.id, UnitExists(self.unit))
			if specID and specID > 0 then
				local _, name, _, specIcon, _, class = GetSpecializationInfoByID(specID, gender)
				local c = class and RAID_CLASS_COLORS[strupper(class)] or { r=0.3, g=0.3, b=0.3 }
				
				self.prepFrames.class:SetColorTexture(c.r,c.g,c.b,1)			
				self.prepFrames.pvpIcon:SetTexture(specIcon or "INTERFACE\\ICONS\\INV_MISC_QUESTIONMARK")				
				self.prepFrames.pvpIcon:Show()
				self.prepFrames.name:SetText(name)
				self.prepFrames.name:SetTextColor(c.r,c.g,c.b,1)	
				self.prepFrames:Show()
			else
				self.prepFrames:Hide()
				self.prepFrames.pvpIcon:Hide()
			end
		end
		f.ZONE_CHANGED_NEW_AREA = f.ARENA_PREP_OPPONENT_SPECIALIZATIONS
		f.PLAYER_ENTERING_WORLD = f.ARENA_PREP_OPPONENT_SPECIALIZATIONS
		
		f:RegisterEvent("PLAYER_TARGET_CHANGED")
		
		function f:PLAYER_TARGET_CHANGED()
			if UnitIsUnit(self:GetAttribute("unit"), "target") then
				self.aggro:Show()
			else
				self.aggro:Hide()
			end
		end

		UF:UnitAuraWidgets(f)
		
		UF:CreateCastBar(f, w, 18):SetPoint("TOP", f, "BOTTOM", 0, -inset-inset-inset)
		
		f.model = UF:CreateModel(f)
		
		E.ArenaFrames[i] = f
		
		if testframe then
			f:SetAttribute("unit", "player")
			f:Show()		
			f.AuraWidget:TestUnitAuras()
			f.castBar:TestCastBar()
		end
	end
	
	E.GUI.args.unitframes.args.arenaFrames = UF:GetUnitFrameOptions('arenas', 'UpdateArenaFramesSettings', "arenaFrames", 'arenaFrames', 'ArenaFramesTestFrame')
	E.GUI.args.unitframes.args.arenaFrames.name = E.L['Arena']
	E.GUI.args.unitframes.args.arenaFrames.args.castBar = CB:GetGroupedCastBarOptions('arenas', 'UpdateArenaFramesSettings', 'arenaFrames')
	E.GUI.args.unitframes.args.arenaFrames.args.model = UF:GetModelSettings('arenas', 'UpdateArenaFramesSettings', 'arenaFrames')
	E.GUI.args.unitframes.args.arenaFrames.args.auraWidget = UF:GetAuraWidgetSettings('arenas', 'UpdateArenaFramesSettings', 'arenaFrames')
	
		
	E:Mover(arenaFrameMover, "arenaFrames")	
	
	UF:UpdateArenaFramesSettings()
end

E:OnInit(ArenaFrame)