local addonName, E = ...
if not E.IsClass("MONK") then return end

local CBF = E:Module("ClassBars")


local w, h = 50, 10
local maxw, maxh = 200, 10

local color = { RAID_CLASS_COLORS["MONK"].r, RAID_CLASS_COLORS["MONK"].g, RAID_CLASS_COLORS["MONK"].b, 1 }

local function OnUpdateStagger(self)
	local currstagger = UnitStagger("player");
	if (not currstagger) then
		return;
	end
	
	self:SetValue(currstagger)
	
	local maxhealth = UnitHealthMax("player");
	self:SetMinMaxValues(0, maxhealth);

	local percent = currstagger/maxhealth;
	local info = PowerBarColor[BREWMASTER_POWER_BAR_NAME];
	
	if (percent > STAGGER_YELLOW_TRANSITION and percent < STAGGER_RED_TRANSITION) then
		info = info[STAGGER_YELLOW_INDEX];
	elseif (percent > STAGGER_RED_TRANSITION) then
		info = info[STAGGER_RED_INDEX];
	else
		info = info[STAGGER_GREEN_INDEX];
	end
	self:SetStatusBarColor(info.r, info.g, info.b);
	self.art:SetBackdropColor(info.r*0.2, info.g*0.2, info.b*0.2, 1)
end

local function StaggerBar()
	local f = CreateFrame("Frame", nil, E.UIParent)
	E:Mover(f, "staggerFrame")
	
	f.orbs = {}
	f.eventlist = {}
	
	f:SetSize(maxw, 10)
		
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

	o:SetScript('OnUpdate', OnUpdateStagger)

	function f:UpdateStyle()
		local opts = CBF:GetOptions()
		f:SetSize(opts.width, opts.height)
		f.bar:SetSize(opts.width, opts.height)
		f.bar:SetStatusBarTexture(E:GetTexture(opts.texture))
	end
	
	f.Update = function(self)
		f:UpdateStyle()
	end
	
	f:Update()
	
	E.GUI.args.unitframes.args.classBars.args.unlock = {
		name = E.L['Unlock'],
		order = 2,
		type = "execute",
		set = function(self, value)
			E:UnlockMover("staggerFrame") 
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

CBF:AddClassBar('MONK', 1, StaggerBar)