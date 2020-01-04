local E = AleaUI
local CBF = E:Module("ClassBars")

local class1, class = UnitClass("player")
if class ~= "MONK" then return end

local maxw, maxh = 200, 10

local lastmaxpower = -1

local f

local function UpdateBarSeparator()
	local opts = CBF:GetOptions()
	
	for i=1, #f.bar.separators do
		f.bar.separators[i]:Hide()
	end
	
	for i=1, lastmaxpower-1 do
		
		local s = f.bar.separators[i]
		s:SetDrawLayer('ARTWORK', 1)
		s:SetSize(1, opts.height)
		s:SetColorTexture(0,0,0,1)
		s:ClearAllPoints()
		s:SetPoint('LEFT', f.bar, 'LEFT', opts.width/lastmaxpower*i, 0)
		s:Show()
	end
end

local function ChiBar()

	f = CreateFrame("Frame", nil, E.UIParent)
	E:Mover(f, "chibarFrame")
	
	f.orbs = {}
	f.eventlist = { 
		["UNIT_POWER_UPDATE"]		= "player",
		["UNIT_MAXPOWER"]	= "player",
		["PLAYER_TALENT_UPDATE"]	= '',
	}


	f:SetSize(maxw, maxh)
		
	local o = CreateFrame("StatusBar", nil, f)
	o:SetSize(maxw, maxh)
	o:SetStatusBarTexture([[Interface\Buttons\WHITE8x8]])
	o:SetPoint("LEFT", f, "LEFT", 0, 0)
	o:SetStatusBarColor(0, 255/255, 150/255 ,1)
	o:SetMinMaxValues(0,1)
	
	o.art = CreateFrame("Frame", nil, o)
	o.art:SetFrameLevel(o:GetFrameLevel()-1)
	o.art:SetBackdrop({
	  bgFile = [[Interface\Buttons\WHITE8x8]], 
	  edgeFile = [[Interface\Buttons\WHITE8x8]], 
	  edgeSize = 1, 
	})
	o.art:SetBackdropColor(0*0.4,255/255*0.4,150/255*0.4, 1)
	o.art:SetBackdropBorderColor(0,0,0,1)
	o.art:SetPoint('TOPLEFT', o, 'TOPLEFT', -1, 1)
	o.art:SetPoint('BOTTOMRIGHT', o, 'BOTTOMRIGHT', 1, -1)

	f.bar = o
	
	f.bar.separators = {}
	
	for i=1, 5 do
		local s = f.bar:CreateTexture()
		s:SetDrawLayer('ARTWORK', 1)
		s:SetSize(1, maxh)
		s:SetColorTexture(0,0,0,1)
		s:SetPoint('LEFT', f.bar, 'LEFT', maxw/6*i, 0)
		
		f.bar.separators[i] = s
	end
	
	function f:UNIT_POWER_UPDATE(event, unit, powerType)	
		local power = UnitPower("player", E.PowerType.Chi)
		local maxLight = UnitPowerMax("player", E.PowerType.Chi)
		
		self.bar:SetMinMaxValues(0, maxLight)
		self.bar:SetValue(power)
		
		if lastmaxpower ~= maxLight then
			lastmaxpower = maxLight
			
			UpdateBarSeparator()
		end
	end

	f.UNIT_MAXPOWER = f.UNIT_POWER_UPDATE
	
	f.PLAYER_TALENT_UPDATE = f.UNIT_POWER_UPDATE
	
	function f:UpdateStyle()
		local opts = CBF:GetOptions()
		
		f:SetSize(opts.width, opts.height)
		f.bar:SetSize(opts.width, opts.height)
		f.bar:SetStatusBarTexture(E:GetTexture(opts.texture))

		lastmaxpower = UnitPowerMax("player", E.PowerType.Chi);
				
		UpdateBarSeparator()
	end
	
	f.Update = function(self)	
		f:UNIT_POWER_UPDATE(_, "player", "CHI")
		f:UpdateStyle()
	end
	
	f:Update()
	
	E.GUI.args.unitframes.args.classBars.args.unlock = {
		name = E.L['Unlock'],
		order = 2,
		type = "execute",
		set = function(self, value)
			E:UnlockMover("chibarFrame") 
		end,
		get = function(self)end
	}
	
	E.GUI.args.unitframes.args.classBars.args.width = {
		name = E.L['Width'],
		order = 3,
		type = 'slider',
		min=1, max = 600, step = 1,
		set = function(info, value)
			CBF:SetOptions('width', value)
			f:UpdateStyle()
		end,
		get = function(info)
			return CBF:GetOptions('width')
		end,
	}
	
	E.GUI.args.unitframes.args.classBars.args.height = {
		name = E.L['Height'],
		order = 4,
		type = 'slider',
		min=1, max = 600, step = 1,
		set = function(info, value)
			CBF:SetOptions('height', value)
			f:UpdateStyle()
		end,
		get = function(info)
			return CBF:GetOptions('height')
		end,
	}
	
	E.GUI.args.unitframes.args.classBars.args.texture = {
		order = 5,
		type = 'statusbar',
		name = E.L['Texture'],
		values = E.GetTextureList,
		set = function(info,value) 
			CBF:SetOptions('texture', value)
			f:UpdateStyle()
		end,
		get = function(info) 
			return CBF:GetOptions('texture')
		end,
	}
	
	return f
end

--CBF:AddClassBar(class, 1, ChiBar)
--CBF:AddClassBar(class, 2, ChiBar)
CBF:AddClassBar(class, 3, ChiBar)