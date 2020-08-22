local addonName, E = ...
local CBF = E:Module("ClassBars")

local class1, class = UnitClass("player")
if class ~= "DRUID" then return end

local w, h = 50, 10
local maxw, maxh = 200, 10

local color = { 0, 238/255, 1, 1  }

local function LunarPowerBar()

	local f = CreateFrame("Frame", nil, E.UIParent)
	f:SetSize(maxw, maxh)
	E:Mover(f, "eclipseFrame")

	f.eventlist = {
		["UNIT_POWER_FREQUENT"] 	 = "player",
		["PLAYER_ENTERING_WORLD"]	= '',
		["UPDATE_SHAPESHIFT_FORM"]	= '',
		["PLAYER_TALENT_UPDATE"]	= '',
	}
	
	local o = CreateFrame("StatusBar", nil, f)
	o:SetFrameLevel(f:GetFrameLevel()+1)
	o:SetSize(maxw, maxh)
	o:SetStatusBarTexture([[Interface\Buttons\WHITE8x8]])
	o:SetPoint("LEFT", f, "LEFT", 0, 0)
	o:SetStatusBarColor(color[1]*0.8,color[2]*0.8,color[3]*0.8, 1)
	o:SetMinMaxValues(0, 100)
	
	o.art = CreateFrame("Frame", nil, o)
	o.art:SetFrameLevel(o:GetFrameLevel()-1)
	o.art:SetBackdrop({
	  bgFile = [[Interface\Buttons\WHITE8x8]], 
	  edgeFile = [[Interface\Buttons\WHITE8x8]], 
	  edgeSize = 1, 
	})
	o.art:SetBackdropColor(color[1]*0.2,color[2]*0.2,color[3]*0.2, 1)
	o.art:SetBackdropBorderColor(0,0,0,1)
	o.art:SetPoint('TOPLEFT', o, 'TOPLEFT', -1, 1)
	o.art:SetPoint('BOTTOMRIGHT', o, 'BOTTOMRIGHT', 1, -1)
	
	f.bar = o
	
	
	function f:UNIT_POWER_FREQUENT(event, unit)	
		if unit ~= "player" then return end
		
		local power = UnitPower("player", E.PowerType.LunarPower );
		local maxPower = UnitPowerMax("player", E.PowerType.LunarPower );
		
		f.bar:SetMinMaxValues(0, maxPower)
		f.bar:SetValue(power)
	end

	function f:PLAYER_ENTERING_WORLD()
		local form  = GetShapeshiftFormID();
		
		if form == MOONKIN_FORM then
			self:Show()
		else
			self:Hide()
		end
	end
	
	f.UPDATE_SHAPESHIFT_FORM = f.PLAYER_ENTERING_WORLD
	f.PLAYER_TALENT_UPDATE = f.PLAYER_ENTERING_WORLD
	
	f.Update = function(self)
		self:UNIT_POWER_FREQUENT(_, "player")
	end
	
	f.EnableState = function(self)		
		return CBF:GetOptions('enableLunar')
	end
	
	function f:UpdateStyle()
		f:SetSize(CBF:GetOptions('widthLunar'), CBF:GetOptions('heightLunar'))
		f.bar:SetSize(CBF:GetOptions('widthLunar'), CBF:GetOptions('heightLunar'))
		f.bar:SetStatusBarTexture(E:GetTexture(CBF:GetOptions('textureLunar')))
	end
	
	f:Update()

	E.GUI.args.unitframes.args.classBars.args.LunarPower = {
		name = E.L['Lunar power'],
		order = 1,
		type = 'group',
		embend = true,
		args = {},	
	}
	
	E.GUI.args.unitframes.args.classBars.args.LunarPower.args.Enable = {
		name = E.L['Enable'],
		order = 1,
		type = "toggle",
		set = function(me, value)
			CBF:SetOptions('enableLunar', not CBF:GetOptions('enableLunar') )				
			CBF.ClassBarUpdate()
		end,
		get = function(me)
			return CBF:GetOptions('enableLunar')
		end
	}
		
	E.GUI.args.unitframes.args.classBars.args.LunarPower.args.unlock = {
		name = E.L['Unlock'],
		order = 2,
		type = "execute",
		set = function(self, value)
			E:UnlockMover("eclipseFrame") 
		end,
		get = function(self)end
	}
	
	E.GUI.args.unitframes.args.classBars.args.LunarPower.args.width = {
		name = E.L['Width'],
		order = 3,
		type = 'slider',
		min=1, max = 600, step = 1,
		set = function(info, value)
			CBF:SetOptions('widthLunar', value)
			f:UpdateStyle()
		end,
		get = function(info)
			return CBF:GetOptions('widthLunar')
		end,
	}
	
	E.GUI.args.unitframes.args.classBars.args.LunarPower.args.height = {
		name = E.L['Height'],
		order = 4,
		type = 'slider',
		min=1, max = 600, step = 1,
		set = function(info, value)
			CBF:SetOptions('heightLunar', value)
			f:UpdateStyle()
		end,
		get = function(info)
			return CBF:GetOptions('heightLunar')
		end,
	}
	
	E.GUI.args.unitframes.args.classBars.args.LunarPower.args.texture = {
		order = 5,
		type = 'statusbar',
		name = E.L['Texture'],
		values = E.GetTextureList,
		set = function(info,value) 
			CBF:SetOptions('textureLunar', value)
			f:UpdateStyle()
		end,
		get = function(info) 
			return CBF:GetOptions('textureLunar')
		end,
	}
	
	E.GUI.args.unitframes.args.classBars.args.Enable = nil
	
	return f
end



CBF:AddClassBar(class, 1, LunarPowerBar)