local Skins = AleaUI:Module("Skins")

if ( AleaUI.isClassic ) then 
	return 
end

local defaults = {
	enable = true,
	texture = 'Minimalist',
	fonts = "Gothic-Bold",
	textSize = 10,
	width = 392,
	showSpecIcon = true,
	monoLineColor = true,
	pos = { 'BOTTOMRIGHT', 'BOTTOMRIGHT', -3, 24 },
	["border"] = {
		["background_texture"] = AleaUI.media.default_bar_texture_name3,
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
		["texture"] = AleaUI.media.default_bar_texture_name3,
	},
}

local defalt_pos = { 'BOTTOMRIGHT', 'BOTTOMRIGHT', -3, 3 } --24

local SetColor = function(f, r, g, b, a, revert)
	if revert then
		f:SetStatusBarColor(r, g, b, 1)
		f.value:SetTextColor(1, 1, 1, 1)
		f.name:SetTextColor(1, 1, 1, 1)
	else
		f:SetStatusBarColor(0.2, 0.2, 0.2, 1)
		f.value:SetTextColor(r, g, b, 1)
		f.name:SetTextColor(r, g, b, 1)
	end
end

local ltexture = [[Interface\AddOns\AleaUI\media\Minimalist.tga]]
local lfonts = [[Interface\AddOns\AleaUI\media\GOTHICB.TTF]]
local ltextsize = 10
local ltextsize2 = 10
local lwidth = 200 --392
local showSpecIcon = true

local function SkinNumeration()
	local addon = Numeration
	local opts = Skins:GetAddOnOpts('Numeration')
	
	if not ALEAUINUMERATION then return end
	
	hooksecurefunc(addon.window, 'GetLine', function(self, id)
		
		if not addon.lines[id]._OldSetColor then
			addon.lines[id]._OldSetColor = addon.lines[id].SetColor
		end
		
		if Skins:GetAddOnOpts('Numeration').monoLineColor then
			if addon.lines[id].aleauistyled then return end
			addon.lines[id].aleauistyled = true
			addon.lines[id].SetColor = SetColor
		else
			if not addon.lines[id].aleauistyled then return end
			addon.lines[id].aleauistyled = false		
			addon.lines[id].SetColor = addon.lines[id]._OldSetColor
		end
	end)
	
	
	addon.windows.width = opts.width

	addon.windows.titlefont = AleaUI:GetFont(opts.fonts)
	addon.windows.titlefontsize = opts.textSize
	
	addon.windows.linefont = addon.windows.titlefont
	addon.windows.linefontsize = opts.textSize
	addon.windows.linetexture = AleaUI:GetTexture(opts.texture)
	addon.windows.lineshowSpecIcon = opts.showSpecIcon
	
	NumerationFrame:SetWidth( addon.windows.width )
	
	for id, line in pairs(addon.lines) do
		line:SetWidth(addon.windows.width-2)
	end
	
	hooksecurefunc(NumerationFrame, 'SetPoint', function(self, point, anchor, relative, x, y)	
		local pos = Skins:GetAddOnOpts('Numeration').pos
		if point ~= pos[1] or relative ~= pos[2] or x ~= pos[3] or y ~= pos[4] then
			self:ClearAllPoints()
			self:SetPoint(pos[1], UIParent, pos[2], pos[3], pos[4])
		end
	end)
	
	hooksecurefunc(NumerationFrame, 'StartMoving', function(self)	
		local pos = Skins:GetAddOnOpts('Numeration').pos
		
		self:StopMovingOrSizing()
		self:ClearAllPoints()
		self:SetPoint(pos[1], UIParent, pos[2], pos[3], pos[4])
	end)
	
	C_Timer.After(1, function()
		local pos = Skins:GetAddOnOpts('Numeration').pos
		
		NumerationFrame:ClearAllPoints()
		NumerationFrame:SetPoint(pos[1], UIParent, pos[2], pos[3], pos[4])
	end)
	
	NumerationFrame.artWork = CreateFrame("Frame", nil, NumerationFrame)
	NumerationFrame.artWork:SetFrameLevel(NumerationFrame:GetFrameLevel())
	NumerationFrame.artWork:SetBackdrop({
	  edgeFile = AleaUI:GetBorder(opts.border.texture),
	  edgeSize = opts.border.size, 
	})
	NumerationFrame.artWork:SetBackdropBorderColor(opts.border.color[1],opts.border.color[2],opts.border.color[3],opts.border.color[4])
	NumerationFrame.artWork:SetPoint("TOPLEFT", NumerationFrame, "TOPLEFT", opts.border.inset, -opts.border.inset)
	NumerationFrame.artWork:SetPoint("BOTTOMRIGHT", NumerationFrame, "BOTTOMRIGHT", -opts.border.inset, opts.border.inset)

	NumerationFrame.artWork.back = NumerationFrame:CreateTexture()
	NumerationFrame.artWork.back:SetDrawLayer('BACKGROUND', -2)
	NumerationFrame.artWork.back:SetTexture(AleaUI:GetTexture(opts.border.background_texture))
	NumerationFrame.artWork.back:SetVertexColor(opts.border.background_color[1],opts.border.background_color[2],opts.border.background_color[3],opts.border.background_color[4])
	NumerationFrame.artWork.back:SetPoint("TOPLEFT", NumerationFrame, "TOPLEFT", opts.border.background_inset, -opts.border.background_inset)
	NumerationFrame.artWork.back:SetPoint("BOTTOMRIGHT", NumerationFrame, "BOTTOMRIGHT", -opts.border.background_inset, opts.border.background_inset)
end

local function UpdateSettings()
	local addon = Numeration
	
	if not addon then return end
	
	if not ALEAUINUMERATION then return end
	
	local opts = Skins:GetAddOnOpts('Numeration')
	
	addon.windows.width = opts.width
	
	addon.windows.titlefont = AleaUI:GetFont(opts.fonts)
	addon.windows.titlefontsize = opts.textSize
	
	addon.windows.linefont = addon.windows.titlefont
	addon.windows.linefontsize = opts.textSize
	addon.windows.linetexture = AleaUI:GetTexture(opts.texture)
	addon.windows.lineshowSpecIcon = opts.showSpecIcon
	
	NumerationFrame:SetWidth( addon.windows.width )
	for id, line in pairs(addon.lines) do
		line:SetWidth(addon.windows.width-2)
	end
	
	NumerationFrame:ClearAllPoints()
	NumerationFrame:SetPoint(opts.pos[1], UIParent, opts.pos[2], opts.pos[3], opts.pos[4])

	NumerationFrame.artWork:SetBackdrop({
	  edgeFile = AleaUI:GetBorder(opts.border.texture),
	  edgeSize = opts.border.size, 
	})
	NumerationFrame.artWork:SetBackdropBorderColor(opts.border.color[1],opts.border.color[2],opts.border.color[3],opts.border.color[4])
	NumerationFrame.artWork:SetPoint("TOPLEFT", NumerationFrame, "TOPLEFT", opts.border.inset, -opts.border.inset)
	NumerationFrame.artWork:SetPoint("BOTTOMRIGHT", NumerationFrame, "BOTTOMRIGHT", -opts.border.inset, opts.border.inset)

	NumerationFrame.artWork.back:SetTexture(AleaUI:GetTexture(opts.border.background_texture))
	NumerationFrame.artWork.back:SetVertexColor(opts.border.background_color[1],opts.border.background_color[2],opts.border.background_color[3],opts.border.background_color[4])
	NumerationFrame.artWork.back:SetPoint("TOPLEFT", NumerationFrame, "TOPLEFT", opts.border.background_inset, -opts.border.background_inset)
	NumerationFrame.artWork.back:SetPoint("BOTTOMRIGHT", NumerationFrame, "BOTTOMRIGHT", -opts.border.background_inset, opts.border.background_inset)
end


local gui = {
	name = '',
	order = 2,
	type = 'group',
	embend = true,
	args = {},
}

gui.args.Enable = {
	name = 'Включить',
	order = 1,
	type = 'toggle',
	width = 'full',
	set = function()
		Skins:GetAddOnOpts('Numeration').enable = not Skins:GetAddOnOpts('Numeration').enable
		UpdateSettings()
	end,
	get = function()
		return Skins:GetAddOnOpts('Numeration').enable
	end,
}

gui.args.showSpecIcon = {
	name = 'Показывать специализацию',
	order = 1.1,
	type = 'toggle',
	width = 'full',
	set = function()
		Skins:GetAddOnOpts('Numeration').showSpecIcon = not Skins:GetAddOnOpts('Numeration').showSpecIcon
		UpdateSettings()
	end,
	get = function()
		return Skins:GetAddOnOpts('Numeration').showSpecIcon
	end,
}

gui.args.monoLineColor = {
	name = 'Обратить цвет полос и текста',
	order = 1.2,
	type = 'toggle',
	width = 'full',
	set = function()
		Skins:GetAddOnOpts('Numeration').monoLineColor = not Skins:GetAddOnOpts('Numeration').monoLineColor
	end,
	get = function()
		return Skins:GetAddOnOpts('Numeration').monoLineColor
	end,
}

gui.args.Width = {
	name = 'Ширина',
	order = 1.9,
	type = 'slider',
	width = 'full',
	min = 50, max = 500, step = 1,
	set = function(info, value)
		Skins:GetAddOnOpts('Numeration').width = value
		UpdateSettings()
	end,
	get = function(info)
		return Skins:GetAddOnOpts('Numeration').width
	end,
}

gui.args.StatusBar = {
	name = 'Текстура полос',
	order = 2,
	type = 'statusbar',
	values = AleaUI.GetTextureList,
	set = function(info, value)
		Skins:GetAddOnOpts('Numeration').texture = value
		UpdateSettings()
	end,
	get = function(info)
		return Skins:GetAddOnOpts('Numeration').texture
	end,
}

gui.args.Font = {
	name = 'Текст полос',
	order = 3,
	type = 'font',
	values = AleaUI.GetFontList,
	set = function(info, value)
		Skins:GetAddOnOpts('Numeration').fonts = value
		UpdateSettings()
	end,
	get = function(info)
		return Skins:GetAddOnOpts('Numeration').fonts
	end,
}

gui.args.FontSize = {
	name = 'Размер текста',
	order = 4,
	type = 'slider',
	min = 6, max = 32, step = 1,
	set = function(info, value)
		Skins:GetAddOnOpts('Numeration').textSize = value
		UpdateSettings()
	end,
	get = function(info)
		return Skins:GetAddOnOpts('Numeration').textSize
	end,
}

gui.args.OffSetX = {
	name = 'Отступ по горизонтали',
	order = 6,
	type = 'slider',
	min = -500, max = 500, step = 1,
	set = function(info, value)
		Skins:GetAddOnOpts('Numeration').pos[3] = value
		UpdateSettings()
	end,
	get = function(info)
		return Skins:GetAddOnOpts('Numeration').pos[3]
	end,
}
gui.args.OffSetY = {
	name = 'Отступ по вертикали',
	order = 7,
	type = 'slider',
	min = -500, max = 500, step = 1,
	set = function(info, value)
		Skins:GetAddOnOpts('Numeration').pos[4] = value
		UpdateSettings()
	end,
	get = function(info)
		return Skins:GetAddOnOpts('Numeration').pos[4]
	end,
}
gui.args.attach = {
	name = 'Крепление',
	order = 8,
	type = 'dropdown',
	values = {
		['TOPLEFT'] = 'Левый верхний',
		['TOPRIGHT'] = 'Правый верхний',
		['BOTTOMLEFT'] = 'Нижний левый',
		['BOTTOMRIGHT'] = 'Нижний правый',
	},
	set = function(info, value)
		Skins:GetAddOnOpts('Numeration').pos[1] = value
		Skins:GetAddOnOpts('Numeration').pos[2] = value
		UpdateSettings()
	end,
	get = function(info)
		return Skins:GetAddOnOpts('Numeration').pos[1]
	end,
}

gui.args.BorderOpts = {
	name = "Границы",
	order = 10,
	embend = true,
	type = "group",
	args = {}
}

gui.args.BorderOpts.args.BorderTexture = {
	order = 1,
	type = 'border',
	name = "Текстура границы",
	values = AleaUI:GetBorderList(),
	set = function(info,value) 
		Skins:GetAddOnOpts('Numeration').border.texture = value;
		UpdateSettings()
	end,
	get = function(info) return Skins:GetAddOnOpts('Numeration').border.texture end,
}

gui.args.BorderOpts.args.BorderColor = {
	order = 2,
	name = "Цвет границы",
	type = "color", 
	hasAlpha = true,
	set = function(info,r,g,b,a) 
		Skins:GetAddOnOpts('Numeration').border.color={ r, g, b, a}; 
		UpdateSettings()
	end,
	get = function(info) 
		return Skins:GetAddOnOpts('Numeration').border.color[1],
				Skins:GetAddOnOpts('Numeration').border.color[2],
				Skins:GetAddOnOpts('Numeration').border.color[3],
				Skins:GetAddOnOpts('Numeration').border.color[4] 
	end,
}

gui.args.BorderOpts.args.BorderSize = {
	name = 'Ширина границы',
	type = "slider",
	order	= 3,
	min		= 1,
	max		= 32,
	step	= 1,
	set = function(info,val) 
		Skins:GetAddOnOpts('Numeration').border.size = val
		UpdateSettings()
	end,
	get =function(info)
		return Skins:GetAddOnOpts('Numeration').border.size
	end,
}

gui.args.BorderOpts.args.BorderInset = {
	name = 'Отступ границы',
	type = "slider",
	order	= 4,
	min		= -32,
	max		= 32,
	step	= 1,
	set = function(info,val) 
		Skins:GetAddOnOpts('Numeration').border.inset = val
		UpdateSettings()
	end,
	get =function(info)
		return Skins:GetAddOnOpts('Numeration').border.inset
	end,
}


gui.args.BorderOpts.args.BackgroundTexture = {
	order = 5,
	type = 'statusbar',
	name = "Текстура фона",
	values = AleaUI.GetTextureList,
	set = function(info,value) 
		Skins:GetAddOnOpts('Numeration').border.background_texture = value;
		UpdateSettings()
	end,
	get = function(info) return Skins:GetAddOnOpts('Numeration').border.background_texture end,
}

gui.args.BorderOpts.args.BackgroundColor = {
	order = 6,
	name = "Цвет фона",
	type = "color", 
	hasAlpha = true,
	set = function(info,r,g,b,a) 
		Skins:GetAddOnOpts('Numeration').border.background_color={ r, g, b, a}
		UpdateSettings()
	end,
	get = function(info) 
		return Skins:GetAddOnOpts('Numeration').border.background_color[1],
				Skins:GetAddOnOpts('Numeration').border.background_color[2],
				Skins:GetAddOnOpts('Numeration').border.background_color[3],
				Skins:GetAddOnOpts('Numeration').border.background_color[4] 
	end,
}


gui.args.BorderOpts.args.backgroundInset = {
	name = 'Отступ фона',
	type = "slider",
	order	= 7,
	min		= -32,
	max		= 32,
	step	= 1,
	set = function(info,val) 
		Skins:GetAddOnOpts('Numeration').border.background_inset = val
		UpdateSettings()
	end,
	get =function(info)
		return Skins:GetAddOnOpts('Numeration').border.background_inset
	end,
}
		

Skins:RegisterCategory('Numeration', nil, defaults, gui, UpdateSettings)

AleaUI:OnAddonLoad('Numeration', SkinNumeration)