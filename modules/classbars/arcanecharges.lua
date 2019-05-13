local E = AleaUI

if not E.IsClass("MAGE") then return end
local CBF = E:Module("ClassBars")

local w, h = 50, 10
local maxw, maxh = 200, 10

local NUM_ARCANE_CHARGES = 4

local color = { RAID_CLASS_COLORS["MAGE"].r, RAID_CLASS_COLORS["MAGE"].g, RAID_CLASS_COLORS["MAGE"].b, 1 }

local function ArcaneChanges()
	local f = CreateFrame("Frame", nil, E.UIParent)
	E:Mover(f, "arcaneChargesFrame")
	
	f.orbs = {}
	f.eventlist = {
		["UNIT_POWER_FREQUENT"]		= "player",
		["UNIT_DISPLAYPOWER"]		= "player",
		}
	
	f:SetSize(maxw, 10)
		
	local o = CreateFrame("StatusBar", nil, f)
	o:SetFrameLevel(f:GetFrameLevel()+1)
	o:SetSize(maxw, maxh)
	o:SetStatusBarTexture([[Interface\Buttons\WHITE8x8]])
	o:SetPoint("LEFT", f, "LEFT", 0, 0)
	o:SetStatusBarColor(color[1]*0.7,color[2]*0.7,color[3]*0.7, 1)
	o:SetMinMaxValues(0, NUM_ARCANE_CHARGES)
	
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
	
	f.bar.separators = {}
	
	for i=1, NUM_ARCANE_CHARGES-1 do
		local s = f.bar:CreateTexture()
		s:SetDrawLayer('ARTWORK', 1)
		s:SetSize(1, maxh)
		s:SetColorTexture(0,0,0,1)
		s:SetPoint('LEFT', f.bar, 'LEFT', maxw/NUM_ARCANE_CHARGES*i, 0)
		
		f.bar.separators[i] = s
	end
	
	function f:UNIT_POWER_FREQUENT(event, unit, powerType)	
		if("player" ~= unit) then return end
		local numOrbs = UnitPower("player", E.PowerType.ArcaneCharges)
	
		f.bar:SetValue(numOrbs)
	end
	
	f.UNIT_DISPLAYPOWER = f.UNIT_POWER_FREQUENT
	f.PLAYER_REGEN_ENABLED = f.PLAYER_REGEN_ENABLED
	
	f.Update = function(self)
		self:UNIT_POWER_FREQUENT(_, "player")
		f:UpdateStyle()
	end
	
	function f:UpdateStyle()
		local opts = CBF:GetOptions()
		
		f:SetSize(opts.width, opts.height)
		f.bar:SetSize(opts.width, opts.height)
		f.bar:SetStatusBarTexture(E:GetTexture(opts.texture))
		
		for i=1, #f.bar.separators do
			f.bar.separators[i]:SetPoint('LEFT', f.bar, 'LEFT', opts.width/NUM_ARCANE_CHARGES*i, 0)
			f.bar.separators[i]:SetSize(1, opts.height)
		end
	end

	f:Update()
	
	
	E.GUI.args.unitframes.args.classBars.args.unlock = {
		name = E.L['Unlock'],
		order = 2,
		type = "execute",
		set = function(self, value)
			E:UnlockMover("arcaneChargesFrame") 
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

CBF:AddClassBar("MAGE", 1, ArcaneChanges)
--CBF:AddClassBar("MAGE", 2, SouldShards)
--CBF:AddClassBar("MAGE", 3, SouldShards)