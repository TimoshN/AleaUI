local addonName, E = ...
local CBF = E:Module("ClassBars")

local class1, class = UnitClass("player")
if class ~= "PALADIN" then return end


local w, h = 80, 10
local maxw, maxh = 200, 10

local HOLYPOWER_NUM_BARS = 5

local function HolyPower()

	local f = CreateFrame("Frame", nil, E.UIParent)
	E:Mover(f, "holypowerFrame")
	f.orbs = {}
	f.eventlist = { 
		["UNIT_POWER_UPDATE"]		= "player",
		}


	f:SetSize(maxw, maxh)
	
	local o = CreateFrame("StatusBar", nil, f)
	o:SetSize(maxw, maxh)
	o:SetStatusBarTexture([[Interface\Buttons\WHITE8x8]])
	o:SetPoint("LEFT", f, "LEFT", 0, 0)
	o:SetStatusBarColor(1,1,0,1)
	o:SetMinMaxValues(0,HOLYPOWER_NUM_BARS)
	
	o.art = CreateFrame("Frame", nil, o)
	o.art:SetFrameLevel(o:GetFrameLevel()-1)
	o.art:SetBackdrop({
	  bgFile = [[Interface\Buttons\WHITE8x8]], 
	  edgeFile = [[Interface\Buttons\WHITE8x8]], 
	  edgeSize = 1, 
	})
	o.art:SetBackdropColor(1*0.4,1*0.4,0*0.4, 1)
	o.art:SetBackdropBorderColor(0,0,0,1)
	o.art:SetPoint('TOPLEFT', o, 'TOPLEFT', -1, 1)
	o.art:SetPoint('BOTTOMRIGHT', o, 'BOTTOMRIGHT', 1, -1)

	f.bar = o
	
	f.bar.separators = {}
	
	for i=1, HOLYPOWER_NUM_BARS-1 do
		local s = f.bar:CreateTexture()
		s:SetDrawLayer('ARTWORK', 1)
		s:SetSize(1, maxh)
		s:SetColorTexture(0,0,0,1)
		s:SetPoint('LEFT', f.bar, 'LEFT', maxw/HOLYPOWER_NUM_BARS*i, 0)
		
		f.bar.separators[i] = s
	end
	
	function f:UNIT_POWER_UPDATE(event, unit, powerType)	
	
		if unit == "player" and powerType == E.PowerTypeString.HolyPower then
			local power = UnitPower("player", E.PowerType.HolyPower)
			f.bar:SetValue(power)
		end
	end
	
	function f:UpdateStyle()
		local opts = CBF:GetOptions()
		f:SetSize(opts.width, opts.height)
		f.bar:SetSize(opts.width, opts.height)
		f.bar:SetStatusBarTexture(E:GetTexture(opts.texture))
		
		for i=1, #f.bar.separators do
			f.bar.separators[i]:SetPoint('LEFT', f.bar, 'LEFT', opts.width/HOLYPOWER_NUM_BARS*i, 0)
			f.bar.separators[i]:SetSize(1, opts.height)
		end
	end
	
	f.Update = function(self)	
		f:UNIT_POWER_UPDATE(_, "player", E.PowerTypeString.HolyPower)
		f:UpdateStyle()
	end
	
	f:Update()
	
	E.GUI.args.unitframes.args.classBars.args.unlock = {
		name = E.L['Unlock'],
		order = 2,
		type = "execute",
		set = function(self, value)
			E:UnlockMover("holypowerFrame") 
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

CBF:AddClassBar(class, 1, HolyPower)
CBF:AddClassBar(class, 2, HolyPower)
CBF:AddClassBar(class, 3, HolyPower)